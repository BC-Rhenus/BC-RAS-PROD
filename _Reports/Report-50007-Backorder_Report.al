report 50007 "Backorder Report"

//  RHE-TNA 08-12-2020 BDS-4764
//  - Modified procedure CreateBackOrderSheet()

{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnPreReport()
    begin
        CurrReport.Language(1033);
        GLSetup.Get();

        ExcelBuffer.DeleteAll();
        CreateBackOrderSheet();
    end;

    procedure CreateBackOrderSheet()
    var
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SheetName: Text[250];
    begin
        SalesHdr.Reset();
        SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
        if SalesHdr.FindSet() then begin
            //Create Excel Header Line
            //Excel Buffer variables: Value,Formula,Comment text,Bold,Italic,Underline,Numformat,Celltype
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption(Substatus), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Document Type"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("External Document No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Sell-to Customer No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Sell-to Customer Name"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Sell-to Address"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Sell-to Address 2"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Sell-to Post Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Sell-to City"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Sell-to Country/Region Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Bill-to Name"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Bill-to Address"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Bill-to Address 2"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Bill-to Post Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Bill-to City"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Bill-to Country/Region Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Order Date"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Customer Comment Text"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Shipment Date"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption(Status), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            //RHE-TNA 08-12-2020 BDS-4764 BEGIN
            ExcelBuffer.AddColumn(SalesHdr.FieldCaption("Ship-to Country/Region Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            //RHE-TNA 08-12-2020 BDS-4764 END
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("Line No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption(Type), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("No."), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption(Description), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption(Quantity), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("Qty. Sent to WMS"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("Quantity Shipped"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("Unit of Measure"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("Currency Code"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("Unit Price"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("Line Discount Amount"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("Amount Including VAT"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(SalesLine.FieldCaption("VAT %"), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
            repeat
                SalesLine.Reset();
                SalesLine.SetRange("Document Type", SalesHdr."Document Type");
                SalesLine.SetRange("Document No.", SalesHdr."No.");
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                if SalesLine.FindSet() then
                    repeat
                        ExcelBuffer.NewRow();
                        ExcelBuffer.AddColumn(SalesHdr.Substatus, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Document Type", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."External Document No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Sell-to Customer No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Sell-to Customer Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Sell-to Address", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Sell-to Address 2", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Sell-to Post Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Sell-to City", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Sell-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Bill-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Bill-to Address", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Bill-to Address 2", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Bill-to Post Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Bill-to City", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Bill-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Order Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                        ExcelBuffer.AddColumn(SalesHdr."Customer Comment Text", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesHdr."Shipment Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                        ExcelBuffer.AddColumn(SalesHdr.Status, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        //RHE-TNA 08-12-2020 BDS-4764 BEGIN
                        ExcelBuffer.AddColumn(SalesHdr."Ship-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        //RHE-TNA 08-12-2020 BDS-4764 END
                        ExcelBuffer.AddColumn(SalesLine."Line No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        SalesLine.CalcFields("Qty. Sent to WMS");
                        ExcelBuffer.AddColumn(SalesLine."Qty. Sent to WMS", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesLine."Quantity Shipped", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesLine."Unit of Measure", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        if SalesLine."Currency Code" = '' then
                            ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn(SalesLine."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesLine."Unit Price", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesLine."Line Discount Amount", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesLine."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesLine."VAT %", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    until SalesLine.Next() = 0;
            until SalesHdr.Next() = 0;
        end;

        SheetName := 'Backorder';
        CreateNewExcelSheet(true, SheetName);
    end;

    procedure CreateNewExcelSheet(NewBook: Boolean; Name: Text[250])
    begin
        if NewBook then
            ExcelBuffer.CreateNewBook('Backorder')
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
}