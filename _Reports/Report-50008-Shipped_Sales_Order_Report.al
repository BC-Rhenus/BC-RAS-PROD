report 50008 "Shipped Sales Order Report"
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
                    field("End Date (Posting Date)"; EndDateFilter)
                    {
                        ApplicationArea = all;
                    }
                    field("Sell-to Customer No. Filter"; CustomerFilter)
                    {
                        ApplicationArea = all;
                    }
                    field("Item No. Filter"; ItemFilter)
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

        ExcelBuffer.DeleteAll();
        CreateShippedOrderSheet();
    end;

    procedure CreateShippedOrderSheet()
    var
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SheetName: Text[250];
        SalesHdrArchive: Record "Sales Header Archive";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        ValueEntry: Record "Value Entry";
        ILE: Record "Item Ledger Entry";
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesInvHdr.Reset();
        SalesInvHdr.SetFilter("Sell-to Customer No.", CustomerFilter);
        if EndDateFilter <> 0D then
            SalesInvHdr.SetFilter("Posting Date", '%1..%2', StartDateFilter, EndDateFilter)
        else
            SalesInvHdr.SetFilter("Posting Date", '%1..%2', StartDateFilter, Today);
        if SalesInvHdr.FindSet() then begin
            //Create Excel Header Line
            //Excel Buffer variables: Value,Formula,Comment text,Bold,Italic,Underline,Numformat,Celltype
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Posting Date"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdrArchive.FieldCaption("Order Date"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("External Document No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Sell-to Customer No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Ship-to Name"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Ship-to Name 2"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Ship-to Address"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Ship-to Address 2"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Ship-to City"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Ship-to Country/Region Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Bill-to Name"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Bill-to Address"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Bill-to Address 2"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Bill-to Post Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Bill-to City"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Bill-to Country/Region Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Package Tracking No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(PostedWhseShipmentLine.FieldCaption("Whse. Shipment No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption("Line No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption(Type), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption("No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption(Description), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption("Description 2"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption("Unit of Measure"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption(Quantity), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvHdr.FieldCaption("Currency Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption("Unit Price"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption("VAT %"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption("Line Discount Amount"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption(Amount), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesInvLine.FieldCaption("Amount Including VAT"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            repeat
                SalesInvLine.Reset();
                SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                if ItemFilter <> '' then
                    SalesInvLine.SetFilter("No.", ItemFilter);
                if SalesInvLine.FindSet() then
                    repeat
                        ExcelBuffer.NewRow();
                        ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                        if SalesInvHdr."Order No." <> '' then begin
                            SalesHdrArchive.SetRange("Document Type", SalesHdrArchive."Document Type"::Order);
                            SalesHdrArchive.SetRange("No.", SalesInvHdr."Order No.");
                            if SalesHdrArchive.FindFirst() then
                                ExcelBuffer.AddColumn(SalesHdrArchive."Order Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date)
                            else
                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                        end else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                        ExcelBuffer.AddColumn(SalesInvHdr."External Document No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Sell-to Customer No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Name 2", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Address", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Address 2", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Ship-to City", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Bill-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Bill-to Address", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Bill-to Address 2", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Bill-to Post Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Bill-to City", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Bill-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvHdr."Package Tracking No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                        ValueEntry.SetCurrentKey("Document No.");
                        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                        ValueEntry.SetRange("Document No.", SalesInvLine."Document No.");
                        ValueEntry.SetRange("Document Line No.", SalesInvLine."Line No.");
                        if ValueEntry.FindFirst() then begin
                            ILE.Get(ValueEntry."Item Ledger Entry No.");
                            if ILE."Document Type" = ILE."Document Type"::"Sales Shipment" then
                                if SalesShipmentLine.Get(ILE."Document No.", ILE."Document Line No.") then begin
                                    PostedWhseShipmentLine.SetRange("Source No.", SalesShipmentLine."Order No.");
                                    PostedWhseShipmentLine.SetRange("Source Line No.", SalesShipmentLine."Order Line No.");
                                    if PostedWhseShipmentLine.FindFirst() then
                                        ExcelBuffer.AddColumn(PostedWhseShipmentLine."Whse. Shipment No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                                    else
                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                end else
                                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                            else
                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        end else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvLine."Line No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvLine."Description 2", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvLine."Unit of Measure", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        if SalesInvHdr."Currency Code" <> '' then
                            ExcelBuffer.AddColumn(SalesInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvLine."Unit Price", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesInvLine."VAT %", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesInvLine."Line Discount Amount", false, '#,##0.00', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesInvLine."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    until SalesInvLine.Next() = 0;
            until SalesInvHdr.Next() = 0;
        end;

        SheetName := 'Shipped Order';
        CreateNewExcelSheet(true, SheetName);
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
        ExcelBuffer.SetFriendlyFilename('Shipped Order Report_' + Format(CompanyName) + '_' + Format(WorkDate(), 0, '<Day,2>-<Month,2>-<Year,4>'));
        ExcelBuffer.OpenExcel();
    end;

    //Global variables
    var
        ExcelBuffer: Record "Excel Buffer";
        GLSetup: Record "General Ledger Setup";
        StartDateFilter: Date;
        EndDateFilter: Date;
        CustomerFilter: Text;
        ItemFilter: Text;
}