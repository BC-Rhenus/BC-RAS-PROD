report 50010 "Import ASN"

//  RHE-TNA 10-06-2020 BDS-4229
//  - Modified function .....

//  RHE-TNA 25-01-2022 BDS-6037
//  - Modified several TextConst into Label

// RHE-AMKE 24-08-2022 BDS-6558
// Added ManufacturingDate-ManufDstamp 


{
    UsageCategory = None;
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
                    field("Vendor No."; VendorNo)
                    {
                        ApplicationArea = All;
                        TableRelation = Vendor;
                        ToolTip = 'Set the Vendor No. for which to create the Purchase Order if no vendor is set in the file.';
                    }
                    field("Vendor Invoice No."; VendorInvoiceNo)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Enter the received Invoice No.';
                    }
                    field("Location Code"; LocationCode)
                    {
                        ApplicationArea = All;
                        TableRelation = Location;
                        ToolTip = 'Set the Location Code to use in the Purchase Order if no location is set in the file.';
                    }
                    field("Number of Excel Header Line(s)"; NoOfExcelHdrLine)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the number of header lines in Excel. The import function will ignore these lines at importing.';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        InventorySetup.Get();
    end;

    trigger OnPostReport()
    var
        SheetName: Text[31];
        ResEntry: Record "Reservation Entry";
        //RHE-TNA 10-06-2020 BDS-4229 BEGIN
        //MessageText001: TextConst
        //    ENU = 'Purchase Order %1 created with %2 line(s).';
        TotalQtyOrderedOrder: Decimal;
        TotalQtySerialNoOrder: Decimal;
        TotalQtyLotNoOrder: Decimal;
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //MessageText001: TextConst
        //    ENU = 'Purchase Order %1 created (read %2 line(s) from import file):\- Total qty. in Order Lines: %3 / In import file: %4.\- Total qty. Serial No.: %5 / In import file: %6.\- Total qty. Lot No.: %7 / In import file: %8.';
        MessageText001: Label 'Purchase Order %1 created (read %2 line(s) from import file):\- Total qty. in Order Lines: %3 / In import file: %4.\- Total qty. Serial No.: %5 / In import file: %6.\- Total qty. Lot No.: %7 / In import file: %8.';
    //RHE-TNA 21-01-2022 BDS-6037 END
    //RHE-TNA 10-06-2020 BDS-4229 END
    begin
        if UploadIntoStream('Select File', 'C:', 'Excel files(*.xlsx)|*.xlsx|Excel File (*.xls)|*.xls', FileName, InStream) then begin
            SheetName := ExcelBuffer.SelectSheetsNameStream(InStream);
            ExcelBuffer.OpenBookStream(InStream, SheetName);
            ExcelBuffer.ReadSheet();
            ProcessExcelBuffer();
            //RHE-TNA 10-06-2020 BDS-4229 BEGIN
            //Message(MessageText001, PurchHdr."No.", LineCount);
            PurchLine.Reset();
            PurchLine.SetRange("Document Type", PurchHdr."Document Type");
            PurchLine.SetRange("Document No.", PurchHdr."No.");
            if PurchLine.FindSet() then
                repeat
                    TotalQtyOrderedOrder := TotalQtyOrderedOrder + PurchLine.Quantity;
                until PurchLine.Next() = 0;
            ResEntry.Reset();
            ResEntry.SetRange("Source Type", 39);
            ResEntry.SetRange("Source Subtype", 1);
            ResEntry.SetRange("Source ID", PurchHdr."No.");
            if ResEntry.FindSet() then
                repeat
                    if ResEntry."Serial No." <> '' then
                        TotalQtySerialNoOrder := TotalQtySerialNoOrder + ResEntry.Quantity;
                    if ResEntry."Lot No." <> '' then
                        TotalQtyLotNoOrder := TotalQtyLotNoOrder + ResEntry.Quantity;
                until ResEntry.Next() = 0;
            Message(MessageText001, PurchHdr."No.", LineCount, TotalQtyOrderedOrder, TotalQtyOrderedImportFile, TotalQtySerialNoOrder, TotalQtySerialNoImportFile, TotalQtyLotNoOrder, TotalQtyLotNoImportFile);
            //RHE-TNA 10-06-2020 BDS-4229 END
        end;
    end;

    procedure ProcessExcelBuffer()
    var
        HeaderCreated: Boolean;
        OrderNo: Code[20];
        LineNo: Integer;
        ItemNo: Code[20];
        Quantity: Decimal;
        UnitCost: Decimal;
        LotNo: Code[50];
        SerialNo: Code[50];
        Supplier: Code[20];
        ShipToWhse: Code[10];
        ManufDstamp: Date;
        LocalMandDstamp: Code[20];

        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Line number %1 is found more than once.';
        ErrorText001: Label 'Line number %1 is found more than once.';
    //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        If ExcelBuffer.FindSet() then begin
            repeat
                if ExcelBuffer."Row No." > NoOfExcelHdrLine then begin
                    if ExcelBuffer."Row No." = NoOfExcelHdrLine + 1 then
                        FirstOrderLine := true
                    else
                        FirstOrderLine := false;
            
                    //Purchase Order No.
                    if ExcelBuffer."Column No." = 1 then begin
                        //Only create the header after completely processing processing the first line to know all data in the file.
                        OrderNo := ExcelBuffer."Cell Value as Text";
                        if (not HeaderCreated) and (not FirstOrderLine) then begin
                            CreatePurchHdr(Supplier, ShipToWhse, OrderNo);
                            HeaderCreated := true;

                            //Insert first order line
                            //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                            //CreatePurchLine(LineNo, ItemNo, Quantity, UnitCost);
                            CreatePurchLine(0, ItemNo, Quantity, UnitCost, ManufDstamp);
                                    ManufDstamp := 0D;
                            //RHE-TNA 10-06-2020 BDS-4229 END
                        end;
                    end;
                    //Line No.
                    if ExcelBuffer."Column No." = 2 then begin
                        //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                        LineCount := LineCount + 1;
                        //RHE-TNA 10-06-2020 BDS-4229 END
                        Evaluate(LineNo, ExcelBuffer."Cell Value as Text");
                        if not FirstOrderLine then begin
                            //Finalize previous line and create reservation entry
                            PurchLine.Modify(true);
                            if (LotNo <> '') or (SerialNo <> '') then
                                //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                                //CreateReservationEntry(LotNo, SerialNo, ExpirationDate);
                                CreateReservationEntry(LotNo, SerialNo, ExpirationDate, Quantity);
                            //Do not create a line per Excel buffer line, line creation moved to Column. No = 8 below
                            //if not PurchLine.Get(PurchLine."Document Type"::Order, PurchHdr."No.", LineNo) then begin
                            //    Quantity := 0;
                            //    UnitCost := 0;
                            //    LotNo := '';
                            //    SerialNo := '';
                            //    ExpirationDate := 0D;

                            //    PurchLine.Init();
                            //    PurchLine."Document Type" := PurchHdr."Document Type";
                            //    PurchLine."Document No." := PurchHdr."No.";
                            //    PurchLine."Line No." := LineNo;
                            //    PurchLine.Insert(true);
                            //    LineCount := LineCount + 1;

                            //    PurchLine.Validate("Buy-from Vendor No.", PurchHdr."Buy-from Vendor No.");
                            //    PurchLine.Validate(Type, PurchLine.Type::Item);
                            //end else
                            //    Error(ErrorText001, LineNo);
                            //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                            Quantity := 0;
                            UnitCost := 0;
                            LotNo := '';
                            SerialNo := '';
                            ExpirationDate := 0D;
                            // ManufDstamp := 0D;

                            //RHE-TNA 10-06-2020 BDS-4229 END
                        end;
                    end;
                    //Item No.
                    if ExcelBuffer."Column No." = 3 then begin
                        ItemNo := ExcelBuffer."Cell Value as Text";
                        //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                        //if not FirstOrderLine then begin
                        //    PurchLine.Validate("No.", ItemNo);
                        //    PurchLine.Validate("Location Code", PurchHdr."Location Code");
                        //end;
                        //RHE-TNA 10-06-2020 BDS-4229 END
                    end;
                    //Quantity
                    if ExcelBuffer."Column No." = 4 then begin
                        Evaluate(Quantity, ExcelBuffer."Cell Value as Text");
                        //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                        //if not FirstOrderLine then
                        //    PurchLine.Validate(Quantity, Quantity);
                        TotalQtyOrderedImportFile := TotalQtyOrderedImportFile + Quantity;
                        //RHE-TNA 10-06-2020 BDS-4229 END
                    end;
                    //Lot No.
                    if ExcelBuffer."Column No." = 5 then begin
                        LotNo := ExcelBuffer."Cell Value as Text";
                    end;
                    //Expiration Date
                    if ExcelBuffer."Column No." = 6 then begin
                        Evaluate(ExpirationDate, ExcelBuffer."Cell Value as Text");
                    end;
                    //Serial No.
                    if ExcelBuffer."Column No." = 7 then begin
                        SerialNo := ExcelBuffer."Cell Value as Text";
                    end;
                    //Manufacture Date
                    if ExcelBuffer."Column No." = 8 then begin
                        LocalMandDstamp := ExcelBuffer."Cell Value as Text";
                        Evaluate(ManufDstamp, LocalMandDstamp);
                        if ManufDstamp <> 0D then
                            PurchLine.Validate("Manufacture Date", ManufDstamp)
                        else
                            ManufDstamp := 0D;
                    end;
                    //Unit Cost
                    if ExcelBuffer."Column No." = 9 then begin
                        Evaluate(UnitCost, ExcelBuffer."Cell Value as Text");
                        //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                        //if not FirstOrderLine then
                        //    PurchLine.Validate("Direct Unit Cost", UnitCost);
                        if not FirstOrderLine then begin
                            //Check if order line with same Item exists
                            PurchLine.SetRange("Document Type", PurchHdr."Document Type");
                            PurchLine.SetRange("Document No.", PurchHdr."No.");
                            PurchLine.SetRange(Type, PurchLine.Type::Item);
                            PurchLine.SetRange("No.", ItemNo);
                            PurchLine.SetRange("Direct Unit Cost", UnitCost);
                            if not PurchLine.FindFirst() then begin
                                CreatePurchLine(0, ItemNo, Quantity, UnitCost, ManufDstamp);
                                ManufDstamp := 0D;
                            end else
                                PurchLine.Validate(Quantity, PurchLine.Quantity + Quantity);
                        end;
                        //RHE-TNA 10-06-2020 BDS-4229 END
                    end;
                    //Vendor
                    if ExcelBuffer."Column No." = 11 then begin
                        VendorNo := ExcelBuffer."Cell Value as Text";
                    end;
                    //Location code
                    if ExcelBuffer."Column No." = 12 then begin
                        LocationCode := ExcelBuffer."Cell Value as Text";
                    end;


                end;
            until ExcelBuffer.Next() = 0;
            //If only 1 line is present in file the order is not yet created
            if (not HeaderCreated) and (FirstOrderLine) then begin
                CreatePurchHdr(Supplier, ShipToWhse, OrderNo);
                HeaderCreated := true;

                //Insert first order line
                //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                //CreatePurchLine(LineNo, ItemNo, Quantity, UnitCost);
                CreatePurchLine(0, ItemNo, Quantity, UnitCost, ManufDstamp);
                ManufDstamp := 0D;
                //RHE-TNA 10-06-2020 BDS-4229 END
                if (LotNo <> '') or (SerialNo <> '') then
                    //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                    //CreateReservationEntry(LotNo, SerialNo, ExpirationDate);
                    CreateReservationEntry(LotNo, SerialNo, ExpirationDate, Quantity);
                //RHE-TNA 10-06-2020 BDS-4229 END
            end;

            //Finalize last line
            if not FirstOrderLine then begin
                PurchLine.Modify(true);
                if (LotNo <> '') or (SerialNo <> '') then
                    //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                    //CreateReservationEntry(LotNo, SerialNo, ExpirationDate);
                    CreateReservationEntry(LotNo, SerialNo, ExpirationDate, Quantity);
                //RHE-TNA 10-06-2020 BDS-4229 END
                ExcelBuffer.DeleteAll();
            end;
        end else
            Message('No Excel lines found.');
    end;

    procedure CreatePurchHdr(Supplier: Code[20]; ShipToWhse: Code[10]; OrderNo: Code[20])
    var
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Order already present, Order No.: %1';
        ErrorText001: Label 'Order already present, Order No.: %1';
    //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        if PurchHdr.Get(PurchHdr."Document Type"::Order, OrderNo) then
            Error(ErrorText001, OrderNo);
        PurchHdr.Init();
        PurchHdr."Document Type" := PurchHdr."Document Type"::Order;
        PurchHdr."No." := OrderNo;
        PurchHdr.Insert(true);
        if Supplier <> '' then
            PurchHdr.Validate("Buy-from Vendor No.", Supplier)
        else
            PurchHdr.Validate("Buy-from Vendor No.", VendorNo);
        if ShipToWhse <> '' then
            PurchHdr.Validate("Location Code", ShipToWhse)
        else
            if LocationCode <> '' then
                PurchHdr.Validate("Location Code", LocationCode);
        PurchHdr.Validate("Vendor Order No.", OrderNo);
        if VendorInvoiceNo <> '' then
            PurchHdr.Validate("Vendor Invoice No.", VendorInvoiceNo);
        PurchHdr.Modify(true);
    end;

    procedure CreatePurchLine(LineNo: Integer; ItemNo: Code[20]; Quantity: Decimal; UnitCost: Decimal; ManufDstamp: Date)
    var
        PurchLine2: Record "Purchase Line";
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Line number %1 is found more than once.';
        ErrorText001: Label 'Line number %1 is found more than once.';
    //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        //RHE-TNA 10-06-2020 BDS-4229 BEGIN
        if LineNo > 0 then begin
            //RHE-TNA 10-06-2020 BDS-4229 END
            if not PurchLine.Get(PurchLine."Document Type"::Order, PurchHdr."No.", LineNo) then begin
                PurchLine.Init();
                PurchLine."Document Type" := PurchHdr."Document Type";
                PurchLine."Document No." := PurchHdr."No.";
                PurchLine."Line No." := LineNo;
                // PurchLine."Manufacture Date" := ManufDstamp;
                PurchLine.Insert(true);
                //RHE-TNA 10-06-2020 BDS-4229 BEGIN
                //LineCount := LineCount + 1;
                //RHE-TNA 10-06-2020 BDS-4229 END

                PurchLine.Validate("Buy-from Vendor No.", PurchHdr."Buy-from Vendor No.");
                PurchLine.Validate(Type, PurchLine.Type::Item);
                PurchLine.Validate("No.", ItemNo);
                PurchLine.Validate("Location Code", PurchHdr."Location Code");
                PurchLine.Validate(Quantity, Quantity);
                PurchLine.Validate("Direct Unit Cost", UnitCost);
                if ManufDstamp <> 0D then
                    PurchLine.Validate("Manufacture Date", ManufDstamp);
                PurchLine.Modify(true);
            end else
                Error(ErrorText001, LineNo);
            //RHE-TNA 10-06-2020 BDS-4229 BEGIN
        end else begin
            PurchLine.SetRange("Document Type", PurchHdr."Document Type");
            PurchLine.SetRange("Document No.", PurchHdr."No.");
            PurchLine.SetRange(Type, PurchLine.Type::Item);
            PurchLine.SetRange("No.", ItemNo);
            PurchLine.SetRange("Direct Unit Cost", UnitCost);

            if (PurchLine.FindFirst()) and (ItemNo <> '') then
                PurchLine.Validate(Quantity, PurchLine.Quantity + Quantity)
            else begin
                PurchLine.Reset();
                PurchLine.Init();
                PurchLine."Document Type" := PurchHdr."Document Type";
                PurchLine."Document No." := PurchHdr."No.";
                PurchLine2.SetRange("Document Type", PurchHdr."Document Type");
                PurchLine2.SetRange("Document No.", PurchHdr."No.");
                if PurchLine2.FindLast() then
                    PurchLine."Line No." := PurchLine2."Line No." + 10000
                else
                    PurchLine."Line No." := 10000;
                PurchLine.Insert(true);

                PurchLine.Validate("Buy-from Vendor No.", PurchHdr."Buy-from Vendor No.");
                PurchLine.Validate(Type, PurchLine.Type::Item);
                if ItemNo <> '' then begin
                    PurchLine.Validate("No.", ItemNo);
                    PurchLine.Validate("Location Code", PurchHdr."Location Code");
                    PurchLine.Validate(Quantity, Quantity);
                    PurchLine.Validate("Direct Unit Cost", UnitCost);
                    if ManufDstamp <> 0D then
                        PurchLine.Validate("Manufacture Date", ManufDstamp);
                end;

            end;
            PurchLine.Modify(true);

        end;
        //RHE-TNA 10-06-2020 BDS-4229 END
    end;

    //RHE-TNA 10-06-2020 BDS-4229 BEGIN
    //procedure CreateReservationEntry(LotNo: Code[50]; SerialNo: Code[50]; ExpirationDate: Date)
    procedure CreateReservationEntry(LotNo: Code[50]; SerialNo: Code[50]; ExpirationDate: Date; Quantity: Decimal)
    //RHE-TNA 10-06-2020 BDS-4229 END
    var
        ResEntry: Record "Reservation Entry";
        EntryNo: Integer;
    begin
        //RHE-TNA 10-06-2020 BDS-4229 BEGIN
        if LotNo <> '' then
            TotalQtyLotNoImportFile := TotalQtyLotNoImportFile + Quantity;
        if SerialNo <> '' then
            TotalQtySerialNoImportFile := TotalQtySerialNoImportFile + Quantity;
        //RHE-TNA 10-06-2020 BDS-4229 END
        ResEntry.Reset();
        IF ResEntry.FindLast() THEN
            EntryNo := ResEntry."Entry No." + 1
        ELSE
            EntryNo := 1;

        ResEntry.Init();
        ResEntry."Entry No." := EntryNo;
        ResEntry.Validate("Item No.", PurchLine."No.");
        ResEntry.Validate("Location Code", PurchLine."Location Code");
        //RHE-TNA 10-06-2020 BDS-4229 BEGIN
        //ResEntry.Validate(Quantity, PurchLine.Quantity);
        ResEntry.Validate(Quantity, Quantity);
        //RHE-TNA 10-06-2020 BDS-4229 END
        ResEntry.Validate("Reservation Status", ResEntry."Reservation Status"::Surplus);
        ResEntry.Validate("Creation Date", Today);
        ResEntry.Validate("Created By", UserId);
        ResEntry.Validate("Source Type", 39);
        ResEntry.Validate("Source Subtype", 1);
        ResEntry.Validate("Source ID", PurchLine."Document No.");
        ResEntry.Validate("Source Ref. No.", PurchLine."Line No.");
        if SerialNo <> '' then begin
            ResEntry.Validate("Serial No.", SerialNo);
            ResEntry.Validate("Item Tracking", ResEntry."Item Tracking"::"Serial No.");
        end;
        if LotNo <> '' then begin
            ResEntry.Validate("Lot No.", LotNo);
            if ResEntry."Item Tracking" = ResEntry."Item Tracking"::"Serial No." then
                ResEntry.Validate("Item Tracking", ResEntry."Item Tracking"::"Lot and Serial No.")
            else
                ResEntry.Validate("Item Tracking", ResEntry."Item Tracking"::"Lot No.");
        end;
        ResEntry.Validate(Positive, true);
        ResEntry.Validate("Quantity (Base)", ResEntry.Quantity);
        if ExpirationDate <> 0D then
            ResEntry.Validate("Expiration Date", ExpirationDate);
        ResEntry.Validate("Expected Receipt Date", PurchLine."Expected Receipt Date");
        ResEntry.Insert(true);
    end;

    //Global variables
    var
        ExcelBuffer: Record "Excel Buffer";
        InStream: InStream;
        FileName: Text;
        PurchHdr: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        VendorNo: Code[20];
        LocationCode: Code[10];
        InventorySetup: Record "Inventory Setup";
        NoOfExcelHdrLine: Integer;
        ExpirationDate: Date;
        FirstOrderLine: Boolean;
        LineCount: Integer;
        VendorInvoiceNo: code[35];
        //RHE-TNA 10-06-2020 BDS-4229 BEGIN
        TotalQtyOrderedImportFile: Decimal;
        TotalQtySerialNoImportFile: Decimal;
        TotalQtyLotNoImportFile: Decimal;
    //RHE-TNA 10-06-2020 BDS-4229 END
}