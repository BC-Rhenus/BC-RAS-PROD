report 50042 "Upload Sales Order"

//  RHE-TNA 28-02-2022..15-06-2022 BDS-6140
//  - New Report

{
    UsageCategory = none;
    UseRequestPage = true;
    ProcessingOnly = true;

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("Number of Excel Header Line(s)"; NoOfExcelHdrLine)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the number of header lines in Excel. The import function will ignore these lines at importing.';
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        SheetName: Text[31];
    begin
        if UploadIntoStream('Select File', 'C:', 'Excel files(*.xlsx)|*.xlsx|Excel File (*.xls)|*.xls', FileName, InStream) then begin
            SheetName := ExcelBuffer.SelectSheetsNameStream(InStream);
            ExcelBuffer.OpenBookStream(InStream, SheetName);
            ExcelBuffer.ReadSheet();
            ProcessExcelBuffer();

            Message('%1 order(s) created with %2 order line(s).', HeaderCount, LineCount);
        end;
    end;

    procedure ProcessExcelBuffer()
    var
        HeaderCreated: Boolean;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        GLSetup: Record "General Ledger Setup";
        DateText: Text;

        //ErrorText001: Label 'Line number %1 is found more than once.';
    begin
        If ExcelBuffer.FindSet() then begin
            repeat
                if ExcelBuffer."Row No." > NoOfExcelHdrLine then begin
                    //Sales Order No.
                    if ExcelBuffer."Column No." = 1 then begin
                        //Only create the header after completely processing processing the first line to know all data in the file.
                        if (not HeaderCreated) and (PrevOrderNo <> '') then begin
                            CreateSalesHdr();
                            HeaderCreated := true;
                            //Insert first order line
                            CreateSalesLine();
                        end;

                        if ExcelBuffer."Cell Value as Text" <> PrevOrderNo then begin
                            PrevOrderNo := ExcelBuffer."Cell Value as Text";
                            FirstOrderLine := true;
                            HeaderCreated := false;
                            ClearGlobalHdrValues();
                        end else begin
                            HeaderCreated := true;
                            FirstOrderLine := false;
                        end;

                        OrderNo := ExcelBuffer."Cell Value as Text";
                    end;

                    //External Doc. No.
                    if ExcelBuffer."Column No." = 2 then begin
                        ExtDocNo := ExcelBuffer."Cell Value as Text";
                    end;

                    //Order Date (YYYYMMDD)
                    if ExcelBuffer."Column No." = 3 then begin
                        if ExcelBuffer."Cell Value as Text" <> '' then begin
                            Evaluate(Day, CopyStr(ExcelBuffer."Cell Value as Text", 7, 2));
                            Evaluate(Month, CopyStr(ExcelBuffer."Cell Value as Text", 5, 2));
                            Evaluate(Year, CopyStr(ExcelBuffer."Cell Value as Text", 1, 4));

                            /*
                            //mm/dd/yyyy
                            DateText := ExcelBuffer."Cell Value as Text";
                            Evaluate(Day, CopyStr(DateText, 1, StrPos(DateText, '/') - 1));
                            DateText := CopyStr(DateText, StrPos(DateText, '/') + 1);
                            Evaluate(Month, CopyStr(DateText, 1, StrPos(DateText, '/') - 1));
                            Evaluate(Year, CopyStr(DateText, StrPos(DateText, '/') + 1));
                            */

                            OrderDate := DMY2Date(Day, Month, Year);
                        end;
                    end;

                    //Substatus
                    if ExcelBuffer."Column No." = 4 then begin
                        Substatus := ExcelBuffer."Cell Value as Text";
                    end;

                    //Requested Delivery Date
                    if ExcelBuffer."Column No." = 5 then begin
                        if ExcelBuffer."Cell Value as Text" <> '' then begin
                            Evaluate(Day, CopyStr(ExcelBuffer."Cell Value as Text", 7, 2));
                            Evaluate(Month, CopyStr(ExcelBuffer."Cell Value as Text", 5, 2));
                            Evaluate(Year, CopyStr(ExcelBuffer."Cell Value as Text", 1, 4));
                            ReqDeliveryDate := DMY2Date(Day, Month, Year);
                        end;
                    end;

                    //Sell-to Customer No.
                    if ExcelBuffer."Column No." = 6 then begin
                        SellToCustomerNo := ExcelBuffer."Cell Value as Text";
                    end;

                    //Sell-to Customer Name
                    if ExcelBuffer."Column No." = 7 then begin
                        SellToName := ExcelBuffer."Cell Value as Text";
                    end;

                    //Sell-to Customer Address
                    if ExcelBuffer."Column No." = 8 then begin
                        SellToAddress := ExcelBuffer."Cell Value as Text";
                    end;

                    //Sell-to Customer Addres 2
                    if ExcelBuffer."Column No." = 9 then begin
                        SellToAddress2 := ExcelBuffer."Cell Value as Text";
                    end;

                    //Sell-to City
                    if ExcelBuffer."Column No." = 10 then begin
                        SellToCity := ExcelBuffer."Cell Value as Text";
                    end;

                    //Sell-to Post Code
                    if ExcelBuffer."Column No." = 11 then begin
                        SellToPostCode := ExcelBuffer."Cell Value as Text";
                    end;

                    //Sell-to Country
                    if ExcelBuffer."Column No." = 12 then begin
                        SellToCountry := ExcelBuffer."Cell Value as Text";
                    end;

                    //Phone No
                    if ExcelBuffer."Column No." = 13 then begin
                        PhoneNo := ExcelBuffer."Cell Value as Text";
                    end;

                    //Email
                    if ExcelBuffer."Column No." = 14 then begin
                        Email := ExcelBuffer."Cell Value as Text";
                    end;

                    //Ship-to Code
                    if ExcelBuffer."Column No." = 15 then begin
                        ShipToCode := ExcelBuffer."Cell Value as Text";
                    end;

                    //Ship-to Name
                    if ExcelBuffer."Column No." = 16 then begin
                        ShipToName := ExcelBuffer."Cell Value as Text";
                    end;

                    //Ship-to Address
                    if ExcelBuffer."Column No." = 17 then begin
                        ShipToAddress := ExcelBuffer."Cell Value as Text";
                    end;

                    //Ship-to Address2
                    if ExcelBuffer."Column No." = 18 then begin
                        ShipToAddress2 := ExcelBuffer."Cell Value as Text";
                    end;

                    //Ship-to City
                    if ExcelBuffer."Column No." = 19 then begin
                        ShipToCity := ExcelBuffer."Cell Value as Text";
                    end;

                    //Ship-to Post Code
                    if ExcelBuffer."Column No." = 20 then begin
                        ShipToPostCode := ExcelBuffer."Cell Value as Text";
                    end;

                    //Ship-to Country
                    if ExcelBuffer."Column No." = 21 then begin
                        ShipToCountry := ExcelBuffer."Cell Value as Text";
                    end;

                    //Incoterm
                    if ExcelBuffer."Column No." = 22 then begin
                        IncoTerm := ExcelBuffer."Cell Value as Text";
                    end;

                    //Carrier
                    if ExcelBuffer."Column No." = 23 then begin
                        Carrier := ExcelBuffer."Cell Value as Text";
                    end;

                    //Service Level
                    if ExcelBuffer."Column No." = 24 then begin
                        ServiceLevel := ExcelBuffer."Cell Value as Text";
                    end;

                    //Currency Code
                    if ExcelBuffer."Column No." = 25 then begin
                        Currency := ExcelBuffer."Cell Value as Text";
                        GLSetup.Get();
                        if Currency = GLSetup."LCY Code" then
                            Currency := '';
                    end;

                    //Vat Registration No.
                    if ExcelBuffer."Column No." = 26 then begin
                        VatNo := ExcelBuffer."Cell Value as Text";
                    end;

                    //Line No.
                    if ExcelBuffer."Column No." = 27 then begin
                        Evaluate(LineNo, ExcelBuffer."Cell Value as Text");
                    end;

                    //Line Type
                    if ExcelBuffer."Column No." = 28 then begin
                        if UpperCase(ExcelBuffer."Cell Value as Text") = 'ITEM' then
                            LineType := LineType::Item
                        else
                            if UpperCase(ExcelBuffer."Cell Value as Text") = 'G/L ACCOUNT' then
                                LineType := LineType::"GL Account"
                            else
                                Error('Line Type value: "%1" is not an acceptable value. Use value Item or value G/L Account.', ExcelBuffer."Cell Value as Text");
                    end;

                    //Item No. or GL Account
                    if ExcelBuffer."Column No." = 29 then begin
                        ItemNo := ExcelBuffer."Cell Value as Text";
                    end;

                    //Quantity
                    if ExcelBuffer."Column No." = 30 then begin
                        Evaluate(Quantity, ExcelBuffer."Cell Value as Text");
                    end;

                    //Unit of Measure
                    if ExcelBuffer."Column No." = 31 then begin
                        UOM := ExcelBuffer."Cell Value as Text";
                    end;

                    //Unit Price
                    if ExcelBuffer."Column No." = 32 then begin
                        Evaluate(UnitPrice, ExcelBuffer."Cell Value as Text");
                    end;

                    //Discount %
                    if ExcelBuffer."Column No." = 33 then begin
                        Evaluate(DiscountPerc, ExcelBuffer."Cell Value as Text");
                        if not FirstOrderLine then
                            CreateSalesLine();
                    end;
                end;
            until ExcelBuffer.Next() = 0;

            //If only 1 line is present in file the order is not yet created
            if (not HeaderCreated) and (FirstOrderLine) then begin
                CreateSalesHdr();
                HeaderCreated := true;

                //Insert first order line
                CreateSalesLine();
            end;

            //Finalize last line
            if not FirstOrderLine then begin
                SalesLine.Modify(true);
                ExcelBuffer.DeleteAll();
            end;
        end else
            Message('No Excel lines found.');
    end;

    procedure CreateSalesHdr()
    var
        ErrorText001: Label 'Order already present, Order No.: %1';
        Customer: Record Customer;
    begin
        HeaderCount += 1;

        if SalesHdr.Get(SalesHdr."Document Type"::Order, OrderNo) then
            Error(ErrorText001, OrderNo);
        SalesHdr.Init();
        SalesHdr."Document Type" := SalesHdr."Document Type"::Order;
        SalesHdr."No." := OrderNo;
        SalesHdr.Insert(true);
        SalesHdr.Validate("Sell-to Customer No.", SellToCustomerNo);
        SalesHdr.Validate("External Document No.", ExtDocNo);

        Customer.Get(SalesHdr."Sell-to Customer No.");
        if not Customer."Disable Search by Name" then begin
            Customer."Disable Search by Name" := true;
            Customer.Modify(false);
        end;

        if SellToName <> '' then
            SalesHdr.Validate("Sell-to Customer Name", SellToName);
        if SellToAddress <> '' then
            SalesHdr.Validate("Sell-to Address", SellToAddress);
        if SellToAddress2 <> '' then
            SalesHdr.Validate("Sell-to Address 2", SellToAddress2);
        if SellToCity <> '' then
            SalesHdr.Validate("Sell-to City", SellToCity);
        if SellToPostCode <> '' then
            SalesHdr.Validate("Sell-to Post Code", SellToPostCode);
        if SellToCountry <> '' then
            SalesHdr.Validate("Sell-to Country/Region Code", SellToCountry);
        if PhoneNo <> '' then
            SalesHdr.Validate("Sell-to Phone No.", PhoneNo);
        if Email <> '' then
            SalesHdr.Validate("Sell-to E-Mail", Email);
        if ShipToCode <> '' then
            SalesHdr.Validate("Ship-to Code", ShipToCode);
        if ShipToName <> '' then
            SalesHdr.Validate("Ship-to Name", ShipToName);
        if ShipToAddress <> '' then
            SalesHdr.Validate("Ship-to Address", ShipToAddress);
        if ShipToAddress2 <> '' then
            SalesHdr.Validate("Ship-to Address 2", ShipToAddress2);
        if ShipToCity <> '' then
            SalesHdr.Validate("Ship-to City", ShipToCity);
        if ShipToPostCode <> '' then
            SalesHdr.Validate("Ship-to Post Code", ShipToPostCode);
        if ShipToCountry <> '' then
            SalesHdr.Validate("Ship-to Country/Region Code", ShipToCountry);
        if IncoTerm <> '' then
            SalesHdr.Validate("Shipment Method Code", IncoTerm);
        if Carrier <> '' then
            SalesHdr.Validate("Shipping Agent Code", Carrier);
        if ServiceLevel <> '' then
            SalesHdr.Validate("Shipping Agent Service Code", ServiceLevel);
        if Currency <> '' then
            SalesHdr.Validate("Currency Code", Currency);
        if VatNo <> '' then
            SalesHdr.Validate("VAT Registration No.", VatNo);
        SalesHdr.Validate("Order Date", OrderDate);
        if ReqDeliveryDate <> 0D then
            SalesHdr.Validate("Requested Delivery Date", ReqDeliveryDate);
        if Substatus <> '' then
            SalesHdr.Validate(Substatus, Substatus);
        SalesHdr.Modify(true);
    end;

    procedure CreateSalesLine()
    var
        ErrorText001: Label 'Line number %1 is found more than once.';
    begin
        LineCount += 1;

        if LineNo = 0 then begin
            SalesLine.Reset();
            SalesLine.Init();
            SalesLine."Document Type" := SalesHdr."Document Type";
            SalesLine."Document No." := SalesHdr."No.";
            if SalesLine.FindLast() then
                LineNo := SalesLine."Line No." + 10000
            else
                LineNo := 10000;
        end;

        if not SalesLine.Get(SalesLine."Document Type"::Order, SalesLine."No.", LineNo) then begin
            SalesLine.Init();
            SalesLine."Document Type" := SalesHdr."Document Type";
            SalesLine."Document No." := SalesHdr."No.";
            SalesLine."Line No." := LineNo;
            SalesLine.Insert(true);

            case LineType of
                LineType::Item:
                    begin
                        SalesLine.Validate(Type, SalesLine.Type::Item);
                    end;
                LineType::"GL Account":
                    begin
                        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                    end;
            end;
            SalesLine.Validate("No.", ItemNo);
            SalesLine.Validate(Quantity, Quantity);
            SalesLine.Validate("Unit of Measure Code", UOM);
            SalesLine.Validate("Unit Price", UnitPrice);
            SalesLine.Validate("Line Discount %", DiscountPerc);
            SalesLine.Modify(true);
        end else
            Error(ErrorText001, LineNo);

        ClearGlobalLineValues();
    end;

    procedure ClearGlobalHdrValues()
    begin
        OrderNo := '';
        ExtDocNo := '';
        SellToCustomerNo := '';
        OrderDate := Today;
        ReqDeliveryDate := 0D;
        SellToName := '';
        SellToAddress := '';
        SellToAddress2 := '';
        SellToCity := '';
        SellToPostCode := '';
        SellToCountry := '';
        PhoneNo := '';
        Email := '';
        ShipToCode := '';
        ShipToName := '';
        ShipToAddress := '';
        ShipToAddress2 := '';
        ShipToCity := '';
        ShipToPostCode := '';
        ShipToCountry := '';
        IncoTerm := '';
        Carrier := '';
        ServiceLevel := '';
        Currency := '';
        VatNo := '';
        Substatus := '';
    end;

    procedure ClearGlobalLineValues()
    begin
        LineNo := 0;
        ItemNo := '';
        Quantity := 0;
        UnitPrice := 0;
        DiscountPerc := 0;
    end;

    //Global variables
    var
        ExcelBuffer: Record "Excel Buffer";
        InStream: InStream;
        FileName: Text;
        LocationCode: Code[10];
        NoOfExcelHdrLine: Integer;
        FirstOrderLine: Boolean;
        HeaderCount: Integer;
        LineCount: Integer;
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PrevOrderNo: Code[20];
        OrderNo: Code[20];
        ExtDocNo: Code[35];
        SellToCustomerNo: Code[20];
        OrderDate: Date;
        ReqDeliveryDate: Date;
        SellToName: Text[100];
        SellToAddress: Text[100];
        SellToAddress2: Text[50];
        SellToCity: Text[30];
        SellToPostCode: Code[20];
        SellToCountry: Code[10];
        PhoneNo: Text[30];
        Email: Text[80];
        ShipToCode: Code[10];
        ShipToName: Text[100];
        ShipToAddress: Text[100];
        ShipToAddress2: Text[50];
        ShipToCity: Text[30];
        ShipToPostCode: Code[20];
        ShipToCountry: Code[10];
        IncoTerm: Code[10];
        Carrier: Code[10];
        ServiceLevel: code[10];
        Currency: Code[10];
        VatNo: Text[20];
        LineNo: Integer;
        LineType: Option Item,"GL Account";
        ItemNo: Code[20];
        Quantity: Decimal;
        UOM: Code[10];
        UnitPrice: Decimal;
        DiscountPerc: Decimal;
        Substatus: Code[10];
}