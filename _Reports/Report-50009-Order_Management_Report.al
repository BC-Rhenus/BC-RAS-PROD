report 50009 "Order Management Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    field("Start Date (Posting Date)"; StartDateFilter)
                    {
                        ApplicationArea = all;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        CurrReport.Language(1033);
        GLSetup.Get();
        WriteHeader := true;

        ExcelBuffer.DeleteAll();
        CreateOrderMgtSheet();
    end;

    procedure CreateOrderMgtSheet()
    var
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesArchiveHdr: Record "Sales Header Archive";
        SheetName: Text[250];
    begin
        SalesHdr.Reset();
        SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
        if SalesHdr.FindSet() then begin
            if WriteHeader then
                WriteExcelHeaderLine();
            repeat
                SalesLine.Reset();
                SalesLine.SetRange("Document Type", SalesHdr."Document Type");
                SalesLine.SetRange("Document No.", SalesHdr."No.");
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                if SalesLine.FindSet() then
                    repeat
                        DocumentType := Format(SalesHdr."Document Type");
                        DocNo := Format(SalesHdr."No.");
                        BillToName := SalesHdr."Bill-to Name";
                        ShipDate := SalesHdr."Shipment Date";
                        GenBusPostingGroup := SalesHdr."Gen. Bus. Posting Group";
                        ExtDocNo := SalesHdr."External Document No.";
                        ReqDelDate := SalesHdr."Requested Delivery Date";
                        TargetDelDate := SalesHdr."Shipment Date";
                        Status := Format(SalesHdr.Status);
                        ActDelDate := 0D;
                        DaysOfDelay := 0;
                        ItemNo := SalesLine."No.";
                        LineDescription := SalesLine."Description";
                        Qty := SalesLine.Quantity;
                        OutstandingQty := SalesLine."Outstanding Quantity";
                        QtyToInvoice := SalesLine."Qty. to Invoice";
                        QtyToShip := SalesLine."Qty. to Ship";

                        WriteExcelLine();
                    until SalesLine.Next() = 0;
            until SalesHdr.Next() = 0;
        end;

        SalesInvHdr.Reset();
        SalesInvHdr.SetFilter("Posting Date", '%1..%2', StartDateFilter, Today);
        if SalesInvHdr.FindSet() then begin
            if WriteHeader then
                WriteExcelHeaderLine();
            repeat
                SalesInvLine.Reset();
                SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                if SalesInvLine.FindSet() then
                    repeat
                        DocumentType := 'Invoice';
                        DocNo := Format(SalesInvHdr."No.");
                        BillToName := SalesInvHdr."Bill-to Name";
                        ShipDate := SalesInvHdr."Shipment Date";
                        GenBusPostingGroup := SalesInvHdr."Gen. Bus. Posting Group";
                        ExtDocNo := SalesInvHdr."External Document No.";
                        if SalesInvHdr."Order No." <> '' then begin
                            SalesArchiveHdr.SetRange("Document Type", SalesArchiveHdr."Document Type"::Order);
                            SalesArchiveHdr.SetRange("No.", SalesInvHdr."Order No.");
                            if SalesArchiveHdr.FindLast() then
                                ReqDelDate := SalesArchiveHdr."Requested Delivery Date"
                            else
                                ReqDelDate := 0D;
                        end else
                            ReqDelDate := 0D;
                        TargetDelDate := SalesInvHdr."Shipment Date";
                        Status := 'Shipped';
                        ActDelDate := SalesInvHdr."Shipment Date";
                        if ReqDelDate <> 0D then
                            DaysOfDelay := ReqDelDate - SalesInvHdr."Shipment Date"
                        else
                            DaysOfDelay := 0;
                        ItemNo := SalesInvLine."No.";
                        LineDescription := SalesInvLine."Description";
                        Qty := SalesInvLine.Quantity;
                        OutstandingQty := 0;
                        QtyToInvoice := 0;
                        QtyToShip := 0;

                        WriteExcelLine();
                    until SalesInvLine.Next() = 0;
            until SalesInvHdr.Next() = 0;
        end;

        SheetName := 'Shipped Order';
        CreateNewExcelSheet(true, SheetName);
    end;

    procedure WriteExcelHeaderLine()
    begin
        //Create Excel Header Line
        //Excel Buffer variables: Value,Formula,Comment text,Bold,Italic,Underline,Numformat,Celltype
        ExcelBuffer.AddColumn('Document Type', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Bill-to Name', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Shipment Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gen. bus. Posting Group', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('External Doc. No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Requested Shipment Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Target Delivery Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Status', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Actual Delivery Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Days Of Delay', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Item No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Quantity', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Outstanding Qty.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty. To Invoice', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty. To Ship', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Rhenus Constraint', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Rhenus Comment', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Comment', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        WriteHeader := false;
    end;

    procedure WriteExcelLine()
    begin
        ExcelBuffer.NewRow();
        //Excel Buffer variables: Value,Formula,Comment text,Bold,Italic,Underline,Numformat,Celltype
        ExcelBuffer.AddColumn(DocumentType, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(DocNo, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(BillToName, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(ShipDate, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn(GenBusPostingGroup, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(ExtDocNo, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(ReqDelDate, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn(TargetDelDate, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn(Status, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(ActDelDate, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn(DaysOfDelay, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(ItemNo, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(LineDescription, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Qty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(OutstandingQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(QtyToInvoice, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(QtyToShip, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        DocumentType := '';
        DocNo := '';
        BillToName := '';
        ShipDate := 0D;
        GenBusPostingGroup := '';
        ExtDocNo := '';
        ReqDelDate := 0D;
        TargetDelDate := 0D;
        Status := '';
        ActDelDate := 0D;
        DaysOfDelay := 0;
        ItemNo := '';
        LineDescription := '';
        Qty := 0;
        OutstandingQty := 0;
        QtyToInvoice := 0;
        QtyToShip := 0;
    end;

    procedure CreateNewExcelSheet(NewBook: Boolean;
            Name: Text[250])
    begin
        if NewBook then
            ExcelBuffer.CreateNewBook('Shipped Order')
        else
            ExcelBuffer.SelectOrAddSheet(Name);
        ExcelBuffer.WriteSheet('', CompanyName, UserId);
        ExcelBuffer.DeleteAll();
        ExcelBuffer.ClearNewRow();
    end;

    trigger OnPostReport()
    begin
        ExcelBuffer.CloseBook();
        ExcelBuffer.SetFriendlyFilename('BackOrderReport_' + Format(CompanyName) + '_' + Format(WorkDate(), 0, '<Day,2>-<Month,2>-<Year,4>'));
        ExcelBuffer.OpenExcel();
    end;

    //Global variables
    var
        ExcelBuffer: Record "Excel Buffer";
        GLSetup: Record "General Ledger Setup";
        StartDateFilter: Date;
        WriteHeader: Boolean;
        DocumentType: Text[20];
        DocNo: Code[20];
        BillToName: Text[50];
        ShipDate: Date;
        GenBusPostingGroup: Code[10];
        ExtDocNo: Code[35];
        ReqDelDate: Date;
        TargetDelDate: Date;
        Status: Text[50];
        ActDelDate: Date;
        DaysOfDelay: Integer;
        ItemNo: Code[20];
        LineDescription: Text[50];
        Qty: Decimal;
        OutstandingQty: Decimal;
        QtyToInvoice: Decimal;
        QtyToShip: Decimal;
}