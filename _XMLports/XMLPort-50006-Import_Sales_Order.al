xmlport 50006 "Import Sales Order"

//RHE-TNA 21-08-2020..13-11-2020 BDS-4374
//  - Added Elements

//RHE-TNA 24-11-2020 BDS-4705 
//  - Added trigger OnPostXmlPort()

//RHE-TNA 14-12-2020 BDS-4783
//  - Modified trigger OnAfterInsertRecord()

//RHE-TNA 04-01-2021 BDS-4821
//  - Modified procedure UpdateOrderHdr()
//  - Modified procedure CreateOrderHdrGenericCustomer()

//RHE-TNA 05-01-2021 BDS-4812
//  - Added element Tags
//  - Modified trigger OnAfterInsertRecord()

//RHE-TNA 05-01-2021 BDS-4828
//  - Modified procedure CreateOrderHdrGenericCustomer()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreXMLPort()
//  - Modified procedure UpdateIFRecordParam()

//  RHE-TNA 22-09-2021 BDS-5668
//  - Modified trigger OnAfterInsertRecord()

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

//  RHE-TNA 28-02-2022 BDS-6102
//  - Modified procedure UpdateOrderHdr()
//  - Modified procedure CreateOrderHdrGenericCustomer()

{
    Direction = Import;
    Format = Xml;
    FormatEvaluate = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;
    UseRequestPage = false;

    schema
    {
        textelement(Document)
        {
            tableelement(Order; "Sales Header")
            {
                textelement(OrderID)
                {

                }
                textelement(CustomerID)
                {

                }
                textelement(Email)
                {

                }
                textelement(SalesType)
                {

                }
                textelement(OrderStatus)
                {

                }
                textelement(BillingCompany)
                {

                }
                textelement(BillingStreetAddress)
                {

                }
                textelement(BillingStreetAddress2)
                {

                }
                textelement(BillingCity)
                {

                }
                textelement(BillingCountry)
                {

                }
                textelement(BillingPostalCode)
                {

                }
                textelement(Phone)
                {

                }
                textelement(BillingContact)
                {

                }
                textelement(CustomerVATNumber)
                {

                }
                textelement(CurrencyCode)
                {

                }
                textelement(PaymentTerms)
                {

                }
                textelement(CommentText)
                {
                    MinOccurs = Zero;
                }
                textelement(ShipToDifferent)
                {

                }
                textelement(ShipToCompany)
                {

                }
                textelement(ShipToStreetAddress)
                {

                }
                textelement(ShipToStreetAddress2)
                {

                }
                textelement(ShipToCity)
                {

                }
                textelement(ShipToCountry)
                {

                }
                textelement(ShipToPostalCode)
                {

                }
                textelement(ShipToContact)
                {

                }
                textelement(IncoTerms)
                {

                }
                textelement(Carrier)
                {

                }
                textelement(OrderDate)
                {

                }
                textelement(RequestedDeliveryDate)
                {
                    MinOccurs = Zero;
                }
                textelement(InvoiceNumber)
                {

                }
                //RHE-TNA 21-08-2020 BDS-4374 BEGIN
                textelement(ReferenceNumber)
                {
                    MinOccurs = Zero;
                }
                textelement(ReferenceNumber2)
                {
                    MinOccurs = Zero;
                }
                //RHE-TNA 21-08-2020 BDS-4374 END
                //RHE-TNA 05-01-2021 BDS-4812 BEGIN
                textelement(Tags)
                {
                    MinOccurs = Zero;
                }
                //RHE-TNA 05-01-2021 BDS-4812 END
                textelement(Lines)
                {
                    tableelement(Line; "Sales Line")
                    {
                        LinkTable = Order;
                        LinkFields = "Document Type" = field ("Document Type"), "Document No." = field ("No.");

                        textelement(LineNumber)
                        {

                        }
                        textelement(ItemNumber)
                        {

                        }
                        textelement(ItemDescription)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(ItemDescription2)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(Quantity)
                        {

                        }
                        textelement(UnitPrice)
                        {

                        }
                        textelement(TrackingQuantity)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(SerialNo)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(LotNo)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(ExpiryDate)
                        {
                            MinOccurs = Zero;
                        }
                        //RHE-TNA 21-08-2020 BDS-4374 BEGIN
                        textelement(ReferenceNo)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(TaxRate)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(TaxPrice)
                        {
                            MinOccurs = Zero;
                        }
                        //RHE-TNA 21-08-2020 BDS-4374 END
                        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                        textelement(SourceLineID)
                        {
                            MinOccurs = Zero;
                        }
                        //RHE-TNA 14-06-2021 BDS-5337 END
                        trigger OnAfterInitRecord()
                        var
                            SalesLine: Record "Sales Line";
                        begin
                            SalesLine.SetRange("Document Type", Line."Document Type");
                            SalesLine.SetRange("Document No.", Line."Document No.");
                            if SalesLine.FindLast() then
                                Line.Validate("Line No.", SalesLine."Line No." + 10000)
                            else
                                Line.Validate("Line No.", 10000);
                        end;

                        trigger OnBeforeInsertRecord()
                        var
                            Item: Record Item;
                            ErrorCommentText: Text[250];
                            //RHE-TNA 21-01-2022 BDS-6037 BEGIN
                            //ErrorText001: TextConst
                            //    ENU = 'Item %1 does not exist.';
                            ErrorText001: Label 'Item %1 does not exist.';
                            //RHE-TNA 21-01-2022 BDS-6037 END
                        begin
                            if LineNumber <> '' then
                                Evaluate(Line."Line No.", LineNumber);

                            //RHE-TNA 21-08-2020 BDS-4374 BEGIN
                            UpdateIFRecordParam('A');
                            //RHE-TNA 21-08-2020 BDS-4374 END

                            case UpperCase(ItemNumber) of
                                'SHIPPINGCOSTS':
                                    begin
                                        if IFSetup."Order Import Ship Cost Account" <> '' then begin
                                            Line.Validate(Type, Line.Type::"G/L Account");
                                            Line.Validate("No.", IFSetup."Order Import Ship Cost Account");
                                        end else begin
                                            Order.Substatus := 'IF ERROR';
                                            Order."Interface Error Text" := 'Interface errors are present, see additional comments.';
                                            Order.Modify(true);

                                            ErrorCommentText := 'No Shipping Cost Account is setup in Interface Setup. Qty. in order: ' + Quantity + ', Unit Price: ' + UnitPrice + '.';
                                            Line.Validate(Type, Line.Type::" ");
                                            Line.Validate(Description, ErrorCommentText);
                                            CreateCommentLine(ErrorCommentText);
                                        end;
                                    end;
                                'DOCUMENTCOST':
                                    begin
                                        if IFSetup."Order Import Doc. Cost Account" <> '' then begin
                                            Line.Validate(Type, Line.Type::"G/L Account");
                                            Line.Validate("No.", IFSetup."Order Import Doc. Cost Account");
                                        end else begin
                                            Order.Substatus := 'IF ERROR';
                                            Order."Interface Error Text" := 'Interface errors are present, see additional comments.';
                                            Order.Modify(true);

                                            ErrorCommentText := 'No Document Cost Account is setup in Interface Setup. Qty. in order: ' + Quantity + ', Unit Price: ' + UnitPrice + '.';
                                            Line.Validate(Type, Line.Type::" ");
                                            Line.Validate(Description, ErrorCommentText);
                                            CreateCommentLine(ErrorCommentText);
                                        end;
                                    end;
                                'DISCOUNTS':
                                    begin
                                        if IFSetup."Order Import Discount Account" <> '' then begin
                                            Line.Validate(Type, Line.Type::"G/L Account");
                                            Line.Validate("No.", IFSetup."Order Import Discount Account");
                                        end else begin
                                            Order.Substatus := 'IF ERROR';
                                            Order."Interface Error Text" := 'Interface errors are present, see additional comments.';
                                            Order.Modify(true);

                                            ErrorCommentText := 'No Discount Account is setup in Interface Setup. Qty. in order: ' + Quantity + ', Unit Price: ' + UnitPrice + '.';
                                            Line.Validate(Type, Line.Type::" ");
                                            Line.Validate(Description, ErrorCommentText);
                                            CreateCommentLine(ErrorCommentText);
                                        end;
                                    end;
                                else begin
                                        if Item.Get(ItemSearch(ItemNumber)) then begin
                                            if (not Item.Blocked) and (not item."Sales Blocked") then begin
                                                Line.Validate(Type, Line.Type::Item);
                                                Line.Validate("No.", Item."No.");
                                            end else begin
                                                Order.Substatus := 'IF ERROR';
                                                Order."Interface Error Text" := 'Interface errors are present, see additional comments.';
                                                Order.Modify(true);

                                                ErrorCommentText := 'Item ' + Item."No." + ' is blocked. Qty. in order: ' + Quantity + ', Unit Price: ' + UnitPrice + '.';
                                                Line.Validate(Type, Line.Type::" ");
                                                Line.Validate(Description, ErrorCommentText);
                                                CreateCommentLine(ErrorCommentText);
                                            end;
                                        end else begin
                                            //If item does not exist, delete order

                                            //RHE-TNA 21-08-2020 BDS-4374 BEGIN
                                            UpdateIFRecordParam('D');
                                            //RHE-TNA 21-08-2020 BDS-4374 END

                                            Order.Delete(true);
                                            Error(ErrorText001, ItemNumber);
                                        end;
                                    end;
                            end;
                        end;

                        trigger OnAfterInsertRecord()
                        var
                            Country: Record "Country/Region";
                            UnitPriceDec: Decimal;
                        begin
                            //Enter Quantity after insert to trigger creation of Assembly order
                            if DecimalSignIsComma then begin
                                if StrPos(Quantity, '.') <> 0 then
                                    Quantity := ConvertStr(Quantity, '.', ',');
                                if StrPos(UnitPrice, '.') <> 0 then
                                    UnitPrice := ConvertStr(UnitPrice, '.', ',');
                                //RHE-TNA 21-08-2020 BDS-4374 BEGIN
                                if StrPos(TaxRate, '.') <> 0 then
                                    TaxRate := ConvertStr(TaxRate, '.', ',');
                                //RHE-TNA 21-08-2020 BDS-4374 END
                            end;

                            Evaluate(Line.Quantity, Quantity);
                            Line.Validate(Quantity);
                            //RHE-TNA 21-08-2020..24-08-2020 BDS-4374 BEGIN
                            //RHE-TNA 22-09-2021 BDS-5668 BEGIN
                            //if TaxRate <> '' then begin
                            if (TaxRate <> '') and (Line."VAT Calculation Type" <> Line."VAT Calculation Type"::"Reverse Charge VAT") then begin
                                //RHE-TNA 22-09-2021 BDS-5668 END
                                Evaluate(line."VAT %", TaxRate);
                                Line.Validate("VAT %", Line."VAT %" * 100);
                            end;
                            //RHE-TNA 21-08-2020.24-08-2020 BDS-4374 END
                            //RHE-TNA 14-12-2020 BDS-4783 BEGIN
                            //Evaluate(Line."Unit Price", UnitPrice);
                            //Line.Validate("Unit Price");
                            //RHE-TNA 28-02-2022 BDS-6102 BEGIN
                            if UnitPrice <> '' then
                                //RHE-TNA 28-02-2022 BDS-6102 END
                                Evaluate(UnitPriceDec, UnitPrice);
                            //When export, all lines should have a line value. If unit price = 0, enter a sales price as set up.
                            if (Country.Get(Order."Ship-to Country/Region Code")) and (((Country."EU Country/Region Code" = '') and (UnitPriceDec <> 0)) or (Country."EU Country/Region Code" <> '')) then
                                Line.Validate("Unit Price", UnitPriceDec);
                            //RHE-TNA 14-12-2020 BDS-4783 END
                            line.Modify(true);
                        end;
                    }
                }
                trigger OnAfterInitRecord()
                begin
                    Order."Document Type" := Order."Document Type"::Order;
                end;

                trigger OnBeforeInsertRecord()
                var
                    SalesHdrArchive: Record "Sales Header Archive";
                    SalesHdr: Record "Sales Header";
                    Customer: Record Customer;
                    ShipToAddress: Record "Ship-to Address";
                    NoSeriesMgt: Codeunit NoSeriesManagement;
                    OrderIDPresent: Boolean;
                    SalesOrderNo: Code[20];
                    //RHE-TNA 21-01-2022 BDS-6037 BEGIN
                    /*
                    ErrorText001: TextConst
                        ENU = 'Sales Type cannot be empty, OrderID %1.';
                    ErrorText002: TextConst
                        ENU = 'Order is present in Sales Order Archive, OrderID %1.';
                    ErrorText003: TextConst
                        ENU = 'Status (%1) of order %2 (OrderID %3) does not allow the order to be changed.';
                    ErrorText004: TextConst
                        ENU = 'Customer %1 cannot be found.';
                    */
                    ErrorText001: Label 'Sales Type cannot be empty, OrderID %1.';
                    ErrorText002: Label 'Order is present in Sales Order Archive, OrderID %1.';
                    ErrorText003: Label 'Status (%1) of order %2 (OrderID %3) does not allow the order to be changed.';
                    ErrorText004: Label 'Customer %1 cannot be found.';
                    //RHE-TNA 21-01-2022 BDS-6037 END
                begin
                    if SalesType = '' then
                        Error(ErrorText001, OrderID);

                    //Check if OrderID is present in Sales Order Archive or in Sales Order
                    OrderIDPresent := false;
                    SalesHdrArchive.SetRange("Document Type", SalesHdrArchive."Document Type"::Order);
                    SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
                    case IFSetup."Order Import Order ID Usage" of
                        IFSetup."Order Import Order ID Usage"::"External Document No.":
                            begin
                                SalesHdrArchive.SetRange("External Document No.", OrderID);
                                SalesHdr.SetRange("External Document No.", OrderID);
                            end;
                        IFSetup."Order Import Order ID Usage"::"Order No.":
                            begin
                                SalesHdrArchive.SetRange("No.", OrderID);
                                SalesHdr.SetRange("No.", OrderID);
                            end;
                    end;
                    if SalesHdr.FindFirst() then begin
                        if SalesHdr.Status <> SalesHdr.Status::Open then
                            Error(ErrorText003, SalesHdr.Status, SalesHdr."No.", OrderID);
                        OrderIDPresent := true;
                        SalesOrderNo := SalesHdr."No.";
                        //Delete Sales Header and Line as these will be created again
                        SalesHdr.Delete(true);
                        if GuiAllowed then
                            Commit();
                    end;
                    if not OrderIDPresent then begin
                        if SalesHdrArchive.FindFirst() then
                            Error(ErrorText002, OrderID);
                    end;

                    //Create Sales Header
                    //RHE-TNA 21-08-2020 BDS-4374 BEGIN
                    //if CustomerID = '' then begin
                    if (CustomerID = '') or (IFSetup."Disable Webshop Customer ID") then begin
                        //RHE-TNA 21-08-2020 BDS-4374 END
                        IFSetup.TestField("Order Import Cust. No. B2B");
                        IFSetup.TestField("Order Import Cust. No. B2C");
                    end;
                    if not OrderIDPresent then
                        case IFSetup."Order Import Order ID Usage" of
                            IFSetup."Order Import Order ID Usage"::"External Document No.":
                                begin
                                    Order.Validate("No.", NoSeriesMgt.GetNextNo(IFSetup."Order Import Order Nos.", Today, true))
                                end;
                            IFSetup."Order Import Order ID Usage"::"Order No.":
                                begin
                                    Order.Validate("No.", OrderID);
                                end;
                        end
                    else
                        Order.Validate("No.", SalesOrderNo);
                    //RHE-TNA 21-08-2020 BDS-4374 BEGIN
                    //if CustomerID <> '' then begin
                    if (CustomerID <> '') and not (IFSetup."Disable Webshop Customer ID") then begin
                        //RHE-TNA 21-08-2020 BDS-4374 END
                        //Check if ID belongs to Ship-to Address
                        ShipToAddress.SetRange(Code, CustomerID);
                        if (ShipToAddress.Count = 1) and (ShipToAddress.FindFirst()) then begin
                            Order.Validate("Sell-to Customer No.", ShipToAddress."Customer No.");
                            Order.Validate("Ship-to Code", ShipToAddress.Code);
                        end else begin
                            ShipToAddress.Reset();
                            ShipToAddress.SetRange(GLN, CustomerID);
                            if (ShipToAddress.Count = 1) and (ShipToAddress.FindFirst()) then begin
                                Order.Validate("Sell-to Customer No.", ShipToAddress."Customer No.");
                                Order.Validate("Ship-to Code", ShipToAddress.Code);
                            end else begin
                                ShipToAddress.Reset();
                                ShipToAddress.SetRange("EDI Identifier", CustomerID);
                                if (ShipToAddress.Count = 1) and (ShipToAddress.FindFirst()) then begin
                                    Order.Validate("Sell-to Customer No.", ShipToAddress."Customer No.");
                                    Order.Validate("Ship-to Code", ShipToAddress.Code);
                                end else begin
                                    //Check if ID belongs to Customer
                                    if Customer.Get(CustomerID) then
                                        Order.Validate("Sell-to Customer No.", Customer."No.")
                                    else begin
                                        customer.SetRange(GLN, CustomerID);
                                        if (Customer.Count = 1) and (Customer.FindFirst()) then
                                            Order.Validate("Sell-to Customer No.", Customer."No.")
                                        else begin
                                            Customer.Reset();
                                            Customer.SetRange("EDI Identifier", CustomerID);
                                            if (Customer.Count = 1) and (Customer.FindFirst()) then
                                                Order.Validate("Sell-to Customer No.", Customer."No.")
                                            else begin
                                                Customer.Reset();
                                                Customer.SetRange("VAT Registration No.", CustomerVATNumber);
                                                if (Customer.Count = 1) and (Customer.FindFirst()) then
                                                    Order.Validate("Sell-to Customer No.", Customer."No.")
                                                else
                                                    Error(ErrorText004, CustomerID);
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        UpdateOrderHdr();
                    end else
                        CreateOrderHdrGenericCustomer();
                end;

                trigger OnAfterInsertRecord()
                var
                    Day: Integer;
                    Month: Integer;
                    Year: Integer;
                begin
                    if OrderDate <> '' then begin
                        Evaluate(Day, CopyStr(OrderDate, 9, 2));
                        Evaluate(Month, CopyStr(OrderDate, 6, 2));
                        Evaluate(Year, CopyStr(OrderDate, 1, 4));
                        Order.Validate("Order Date", DMY2Date(Day, Month, Year));
                    end;
                    if RequestedDeliveryDate <> '' then begin
                        Evaluate(Day, CopyStr(RequestedDeliveryDate, 9, 2));
                        Evaluate(Month, CopyStr(RequestedDeliveryDate, 6, 2));
                        Evaluate(Year, CopyStr(RequestedDeliveryDate, 1, 4));
                        Order.Validate("Requested Delivery Date", DMY2Date(Day, Month, Year));
                    end;

                    //RHE-TNA 05-01-2021 BDS-4812 BEGIN
                    if Tags <> '' then
                        Order.SetWorkDescription(Tags);
                    //RHE-TNA 05-01-2021 BDS-4812 END
                end;
            }
        }
    }

    procedure UpdateOrderHdr()
    var
        //RHE-TNA 28-02-2022 BDS-6102 BEGIN
        //RecCarrier: Record Carrier;
        IFMapping: Record "Interface Mapping";
        //RHE-TNA 28-02-2022 BDS-6102 BEGIN
        ShipCountry: Code[10];
        Country: Record "Country/Region";
        Location: Record Location;
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Invalid Carrier (%1).';
        ErrorText001: Label 'Invalid Carrier (%1).';
        //RHE-TNA 21-01-2022 BDS-6037 END
        CarrierValue: Code[30];
        CurrencyValue: Code[30];
    begin
        //Update order with order specific order data
        if UpperCase(ShipToDifferent) = 'TRUE' then begin
            if ShipToCompany <> '' then begin
                Order.Validate("Ship-to Name", CopyStr(ShipToCompany, 1, 100));
                Order.Validate("Ship-to Contact", CopyStr(ShipToContact, 1, 100));
            end else
                Order.Validate("Ship-to Name", CopyStr(ShipToContact, 1, 100));
            Order.Validate("Ship-to Address", CopyStr(ShipToStreetAddress, 1, 100));
            Order.Validate("Ship-to Address 2", CopyStr(ShipToStreetAddress2, 1, 50));
            Order.Validate("Ship-to Post Code", CopyStr(ShipToPostalCode, 1, 20));
            Order.Validate("Ship-to City", CopyStr(ShipToCity, 1, 30));
            Order.Validate("Ship-to Country/Region Code", CountrySearch(CopyStr(ShipToCountry, 1, 10)));
        end;

        if ShipToCountry <> '' then
            ShipCountry := CountrySearch(CopyStr(ShipToCountry, 1, 10))
        else
            ShipCountry := CountrySearch(CopyStr(BillingCountry, 1, 10));
        Country.Get(ShipCountry);

        if (PaymentTerms <> '') and (Order."Payment Terms Code" <> PaymentTerms) then
            Order.Validate("Payment Terms Code", PaymentTerms);
        Order.Validate("Your Reference", InvoiceNumber);
        Order.Validate("External Document No.", OrderID);
        Order.Validate(Substatus, OrderStatus);
        Order.Validate("Customer Comment Text", CopyStr(CommentText, 1, 250));
        Order.Validate("VAT Registration No.", CopyStr(CustomerVATNumber, 1, 20));
        //RHE-TNA 28-02-2022 BDS-6102 BEGIN
        //Get CurrencyCode from Interface Mapping table
        if CurrencyCode <> '' then begin
            IFMapping.Reset();
            IFMapping.SetRange(Type, IFMapping.Type::Currency);
            IFMapping.SetRange("Interface Value", UpperCase(CurrencyCode));
            if IFMapping.FindFirst() then begin
                if IFMapping."LCY Code" then
                    CurrencyCode := GLSetup."LCY Code"
                else
                    CurrencyCode := IFMapping."Currency Code";
            end;
        end;
        //RHE-TNA 28-02-2022 BDS-6102 END

        //Only enter currency when it's different from General Ledger Setup
        if (CurrencyCode <> '') and (CurrencyCode <> GLSetup."LCY Code") and (Order."Currency Code" <> CurrencyCode) then
            Order.Validate("Currency Code", CurrencyCode);
        if (IncoTerms <> '') and (Order."Shipment Method Code" <> IncoTerms) then
            Order.Validate("Shipment Method Code", IncoTerms);

        //RHE-TNA 04-01-2021 BDS-4821 BEGIN        
        //if Carrier <> '' then begin
        //    if not RecCarrier.Get(Carrier) then
        //        Error(ErrorText001, Carrier)
        CarrierValue := '';
        if Carrier <> '' then
            CarrierValue := Carrier
        else
            if Country.Carrier <> '' then
                CarrierValue := Country.Carrier;

        if CarrierValue <> '' then begin
            //RHE-TNA 28-02-2022 BDS-6102 BEGIN
            //if not RecCarrier.Get(CarrierValue) then
            IFMapping.Reset();
            IFMapping.SetRange(Type, IFMapping.Type::Carrier);
            IFMapping.SetRange("Interface Value", CarrierValue);
            if not IFMapping.FindFirst() then
                //RHE-TNA 28-02-2022 BDS-6102 END
                Error(ErrorText001, CarrierValue)
            //RHE-TNA 04-01-2021 BDS-4821 END
            else begin
                Order.Validate("Shipping Agent Code", IFMapping."Shipping Agent Code");
                Location.Get(Order."Location Code");
                if Country.Code = Location."Country/Region Code" then
                    Order.Validate("Shipping Agent Service Code", IFMapping."Ship Agent Service Code Dom.")
                else
                    if Country."EU Country/Region Code" <> '' then
                        Order.Validate("Shipping Agent Service Code", IFMapping."Ship Agent Service Code EU")
                    else
                        Order.Validate("Shipping Agent Service Code", IFMapping."Ship Agent Service Code Export");
            end;
        end;
    end;

    procedure CreateOrderHdrGenericCustomer()
    var
        //RHE-TNA 28-02-2022 BDS-6102 BEGIN
        //RecCarrier: Record Carrier;
        IFMapping: Record "Interface Mapping";
        //RHE-TNA 28-02-2022 BDS-6102 EMD
        Customer: Record Customer;
        B2B: Boolean;
        ShipCountry: Code[10];
        Country: Record "Country/Region";
        Location: Record Location;
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Invalid Carrier (%1).';
        ErrorText001: Label 'Invalid Carrier (%1).';
        //RHE-TNA 21-01-2022 BDS-6037 END
        CarrierValue: Code[30];
    begin
        B2B := false;
        if UpperCase(SalesType) = 'B2B' then
            B2B := true;

        if B2B then begin
            //Set Disable Seach by Name to true to make sure no new customer will be created
            Customer.Get(IFSetup."Order Import Cust. No. B2B");
            if not Customer."Disable Search by Name" then begin
                Customer."Disable Search by Name" := true;
                Customer.Modify(false);
            end;
            Order.Validate("Sell-to Customer No.", IFSetup."Order Import Cust. No. B2B");
        end else begin
            //Set Disable Seach by Name to true to make sure no new customer will be created
            Customer.Get(IFSetup."Order Import Cust. No. B2C");
            if not Customer."Disable Search by Name" then begin
                Customer."Disable Search by Name" := true;
                Customer.Modify(false);
            end;
            Order.Validate("Sell-to Customer No.", IFSetup."Order Import Cust. No. B2C");
        end;

        //Update order with order specific customer data
        if BillingCompany <> '' then begin
            Order.Validate("Sell-to Customer Name", CopyStr(BillingCompany, 1, 100));
            Order.Validate("Sell-to Contact", CopyStr(BillingContact, 1, 100));
            Order.Validate("Bill-to Name", order."Sell-to Customer Name");
            Order.Validate("Bill-to Contact", order."Sell-to Contact");
            Order.Validate("Ship-to Name", order."Sell-to Customer Name");
            Order.Validate("Ship-to Contact", order."Sell-to Contact");
        end else begin
            Order.Validate("Sell-to Customer Name", CopyStr(BillingContact, 1, 100));
            Order.Validate("Bill-to Name", Order."Sell-to Customer Name");
            Order.Validate("Ship-to Name", Order."Sell-to Customer Name");
        end;
        Order.Validate("Sell-to Address", CopyStr(BillingStreetAddress, 1, 100));
        Order.Validate("Sell-to Address 2", CopyStr(BillingStreetAddress2, 1, 50));
        Order.Validate("Sell-to Post Code", CopyStr(BillingPostalCode, 1, 20));
        Order.Validate("Sell-to City", CopyStr(BillingCity, 1, 30));
        if BillingCountry <> '' then
            Order.Validate("Sell-to Country/Region Code", CountrySearch(CopyStr(BillingCountry, 1, 10)));
        Order.Validate("Sell-to Phone No.", CopyStr(Phone, 1, 30));
        Order.Validate("Bill-to Address", Order."Sell-to Address");
        Order.Validate("Bill-to Address 2", Order."Sell-to Address 2");
        Order.Validate("Bill-to Post Code", Order."Sell-to Post Code");
        Order.Validate("Bill-to City", Order."Sell-to City");
        if Order."Sell-to Country/Region Code" <> '' then
            Order.Validate("Bill-to Country/Region Code", Order."Sell-to Country/Region Code");
        Order.Validate("Bill-to Phone No.", Order."Sell-to Phone No.");
        Order.Validate("Ship-to Address", Order."Sell-to Address");
        Order.Validate("Ship-to Address 2", Order."Sell-to Address 2");
        Order.Validate("Ship-to Post Code", Order."Sell-to Post Code");
        Order.Validate("Ship-to City", Order."Sell-to City");
        if Order."Sell-to Country/Region Code" <> '' then
            Order.Validate("Ship-to Country/Region Code", Order."Sell-to Country/Region Code");
        Order.Validate("Ship-to Phone No.", Order."Sell-to Phone No.");
        //RHE-TNA 05-01-2021 BDS-4828 BEGIN
        //Order.Validate("E-mail", CopyStr(Email, 1, 80));
        //order.Validate("Sell-to E-Mail", order."E-mail");
        Order.Validate("Sell-to E-Mail", CopyStr(Email, 1, 80));
        //RHE-TNA 05-01-2021 BDS-4828 END
        if UpperCase(ShipToDifferent) = 'TRUE' then begin
            if ShipToCompany <> '' then begin
                Order.Validate("Ship-to Name", CopyStr(ShipToCompany, 1, 100));
                Order.Validate("Ship-to Contact", CopyStr(ShipToContact, 1, 100));
            end else
                Order.Validate("Ship-to Name", CopyStr(ShipToContact, 1, 100));
            Order.Validate("Ship-to Address", CopyStr(ShipToStreetAddress, 1, 100));
            Order.Validate("Ship-to Address 2", CopyStr(ShipToStreetAddress2, 1, 50));
            Order.Validate("Ship-to Post Code", CopyStr(ShipToPostalCode, 1, 20));
            Order.Validate("Ship-to City", CopyStr(ShipToCity, 1, 30));
            Order.Validate("Ship-to Country/Region Code", CountrySearch(CopyStr(ShipToCountry, 1, 10)));
        end;

        if ShipToCountry <> '' then
            ShipCountry := CountrySearch(CopyStr(ShipToCountry, 1, 10))
        else
            ShipCountry := CountrySearch(CopyStr(BillingCountry, 1, 10));
        Country.Get(ShipCountry);

        if B2B then begin
            Order.Validate("Gen. Bus. Posting Group", Country."B2B Gen. Bus. Posting Group");
            Order.Validate("VAT Bus. Posting Group", Country."B2B VAT Bus. Posting Group");
        end else begin
            Order.Validate("Gen. Bus. Posting Group", Country."B2C Gen. Bus. Posting Group");
            Order.Validate("VAT Bus. Posting Group", Country."B2C VAT Bus. Posting Group");
        end;

        if PaymentTerms <> '' then
            Order.Validate("Payment Terms Code", PaymentTerms);
        Order.Validate("Your Reference", InvoiceNumber);
        Order.Validate("External Document No.", OrderID);
        Order.Validate(Substatus, OrderStatus);
        Order.Validate("Customer Comment Text", CopyStr(CommentText, 1, 250));
        Order.Validate("VAT Registration No.", CopyStr(CustomerVATNumber, 1, 20));
        //RHE-TNA 28-02-2022 BDS-6102 BEGIN
        //Get CurrencyCode from Interface Mapping table
        if CurrencyCode <> '' then begin
            IFMapping.Reset();
            IFMapping.SetRange(Type, IFMapping.Type::Currency);
            IFMapping.SetRange("Interface Value", UpperCase(CurrencyCode));
            if IFMapping.FindFirst() then begin
                if IFMapping."LCY Code" then
                    CurrencyCode := GLSetup."LCY Code"
                else
                    CurrencyCode := IFMapping."Currency Code";
            end;
        end;
        //RHE-TNA 28-02-2022 BDS-6102 END

        //Only enter currency when it's different from General Ledger Setup
        if (CurrencyCode <> '') and (CurrencyCode <> GLSetup."LCY Code") then
            Order.Validate("Currency Code", CurrencyCode);
        if IncoTerms <> '' then
            Order.Validate("Shipment Method Code", IncoTerms);

        //RHE-TNA 04-01-2021 BDS-4821 BEGIN        
        //if Carrier <> '' then begin
        //    if not RecCarrier.Get(Carrier) then
        //        Error(ErrorText001, Carrier)
        CarrierValue := '';
        if Carrier <> '' then
            CarrierValue := Carrier
        else
            if Country.Carrier <> '' then
                CarrierValue := Country.Carrier;

        if CarrierValue <> '' then begin
            //RHE-TNA 28-02-2022 BDS-6102 BEGIN
            //if not RecCarrier.Get(CarrierValue) then
            IFMapping.SetRange(Type, IFMapping.Type::Carrier);
            IFMapping.SetRange("Interface Value", CarrierValue);
            if not IFMapping.FindFirst() then
                //RHE-TNA 28-02-2022 BDS-6102 END
                Error(ErrorText001, CarrierValue)
            //RHE-TNA 04-01-2021 BDS-4821 END
            else begin
                Order.Validate("Shipping Agent Code", IFMapping."Shipping Agent Code");
                Location.Get(Order."Location Code");
                if Country.Code = Location."Country/Region Code" then
                    Order.Validate("Shipping Agent Service Code", IFMapping."Ship Agent Service Code Dom.")
                else
                    if Country."EU Country/Region Code" <> '' then
                        Order.Validate("Shipping Agent Service Code", IFMapping."Ship Agent Service Code EU")
                    else
                        Order.Validate("Shipping Agent Service Code", IFMapping."Ship Agent Service Code Export");
            end;
        end;
    end;

    procedure CountrySearch(SearchValue: Text[10]) Country: Code[10]
    var
        RecCountry: Record "Country/Region";
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Invalid Country code (%1).';
        ErrorText001: Label 'Invalid Country code (%1).';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        if not RecCountry.Get(SearchValue) then begin
            RecCountry.SetRange("ISO Code", SearchValue);
            if RecCountry.FindFirst() then
                Country := RecCountry.Code
            else begin
                RecCountry.Reset();
                RecCountry.SetRange("ISO3 Code", SearchValue);
                if RecCountry.FindFirst() then
                    Country := RecCountry.Code
                else begin
                    RecCountry.Reset();
                    RecCountry.SetRange("ISO Numeric Code");
                    if RecCountry.FindFirst() then
                        Country := RecCountry.Code
                    else
                        Error(ErrorText001, SearchValue);
                end;
            end;
        end else
            Country := RecCountry.Code;
    end;

    procedure CreateCommentLine(CommentText: Text[250])
    var
        SalesComment: Record "Sales Comment Line";
        CommentText2: Text[80];
        LineNo: Integer;
    begin
        SalesComment.Reset();
        SalesComment.SetRange("Document Type", Order."Document Type");
        SalesComment.SetRange("No.", Order."No.");
        SalesComment.SetRange("Document Line No.", 0);
        repeat
            if SalesComment.FindLast() then
                LineNo := SalesComment."Line No." + 10000
            else
                LineNo := 10000;

            CommentText2 := CopyStr(CommentText, 1, 80);
            CommentText := CopyStr(CommentText, 81);

            SalesComment.Init();
            SalesComment."Document Type" := Order."Document Type";
            SalesComment."No." := Order."No.";
            SalesComment."Document Line No." := 0;
            SalesComment."Line No." := LineNo;
            SalesComment.Date := Today;
            SalesComment.Comment := CommentText2;
            SalesComment.Insert(true);
        until CommentText = '';
    end;

    procedure ItemSearch(ItemNo: Text): code[20]
    var
        Item: Record Item;
        CrossReference: Record "Item Cross Reference";
    begin
        if Item.Get(ItemNo) then
            exit(Item."No.")
        else begin
            Item.SetRange(GTIN, ItemNo);
            if (Item.Count = 1) and Item.FindFirst() then
                exit(Item."No.")
            else begin
                CrossReference.SetRange("Cross-Reference Type", CrossReference."Cross-Reference Type"::Customer);
                CrossReference.SetRange("Cross-Reference Type No.", Order."Sell-to Customer No.");
                CrossReference.SetRange("Cross-Reference No.", ItemNo);
                if CrossReference.FindFirst() then
                    exit(CrossReference."Item No.")
                else
                    CrossReference.Reset();
                CrossReference.SetRange("Cross-Reference Type", CrossReference."Cross-Reference Type"::" ");
                CrossReference.SetRange("Cross-Reference No.", ItemNo);
                if CrossReference.FindFirst() then
                    exit(CrossReference."Item No.")
                else
                    exit('');
            end;
        end;
    end;

    //RHE-TNA 21-08-2020..16-11-2020 BDS-4374 BEGIN
    procedure UpdateIFRecordParam(ActionType: Text[1])
    var
        IFRecordParam: Record "Interface Record Parameters";
        IFRecordParam2: Record "Interface Record Parameters";
    begin
        //ActionType A = Add, D = Delete
        IFRecordParam.SetRange("Source Type", IFRecordParam."Source Type"::Order);
        IFRecordParam.SetRange("Source No.", Order."No.");
        if ActionType = 'D' then begin
            IFRecordParam.DeleteAll();
            exit;
        end;
        IFRecordParam.SetRange(Param1, ReferenceNumber2);
        IFRecordParam.SetRange(Param2, ReferenceNumber);
        IFRecordParam.SetRange(Param3, ReferenceNo);
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        IFRecordParam.SetRange("Source System Line ID", SourceLineID);
        //RHE-TNA 14-06-2021 BDS-5337 END
        if not IFRecordParam.FindFirst() then begin
            IFRecordParam.Insert(true);
            IFRecordParam."Source Type" := IFRecordParam."Source Type"::Order;
            IFRecordParam."Source No." := Order."No.";
            IFRecordParam.Param1 := ReferenceNumber2;
            if ReferenceNumber <> '' then
                IFRecordParam.Param2 := ReferenceNumber
            else begin
                IFRecordParam2.SetRange("Source Type", IFRecordParam2."Source Type"::Location);
                IFRecordParam2.SetRange(Param1, ReferenceNumber2);
                if IFRecordParam2.FindFirst() then
                    IFRecordParam.Param2 := IFRecordParam2.Param2;
            end;
            IFRecordParam.Param3 := ReferenceNo;
            IFRecordParam.Param5 := Order."Your Reference";
            //RHE-TNA 14-06-2021 BDS-5337 BEGIN
            IFRecordParam."Source System Line ID" := SourceLineID;
            Evaluate(IFRecordParam."Source Line No.", LineNumber);
            //RHE-TNA 14-06-2021 BDS-5337 END
            IFRecordParam.Modify();
        end else
            exit;
    end;
    //RHE-TNA 21-08-2020..16-11-2020 BDS-4374 END

    procedure SetFileName(FileName: Text[250])
    begin
        currXMLport.Filename := FileName;
    end;

    trigger OnPreXmlPort()
    begin
        GLSetup.Get();
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        IFSetup.SetRange(Type, IFSetup.Type::Customer);
        IFSetup.SetRange("In Progress", true);
        IFSetup.FindFirst();
        //RHE-TNA 14-06-2021 BDS-5337 END
        if IFSetup."Order Import Order ID Usage" = IFSetup."Order Import Order ID Usage"::"External Document No." then
            IFSetup.TestField("Order Import Order Nos.");

        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
    end;

    //RHE-TNA 24-11-2020 BDS-4705 BEGIN
    trigger OnPostXmlPort()
    var
        SalesHdr: Record "Sales Header";
    begin
        //Set Assigned User ID to store import object ID (will be removed by Report 50017)
        SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
        case IFSetup."Order Import Order ID Usage" of
            IFSetup."Order Import Order ID Usage"::"External Document No.":
                begin
                    SalesHdr.SetRange("External Document No.", OrderID);
                end;
            IFSetup."Order Import Order ID Usage"::"Order No.":
                begin
                    SalesHdr.SetRange("No.", OrderID);
                end;
        end;
        if SalesHdr.FindFirst() then begin
            SalesHdr."Assigned User ID" := '50017';
            SalesHdr.Modify(false);
        end;
    end;
    //RHE-TNA 24-11-2020 BDS-4705 END

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        GLSetup: Record "General Ledger Setup";
        DecimalSignIsComma: Boolean;
}