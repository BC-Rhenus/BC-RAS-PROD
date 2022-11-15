report 50043 "Intrastat Report"

//  RHE-TNA 27-06-2022 BDS-6361
//  - New Report

{
    UsageCategory = ReportsandAnalysis;
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
                    field("Start Date"; StartDate)
                    {

                    }
                    field("End Date"; EndDate)
                    {

                    }
                    field("Sales G/L Account"; SalesGLAccountFilter)
                    {

                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        CurrReport.Language(1033);
        GLSetup.Get();
        CompanyInfo.Get();
        if EndDate - StartDate > 31 then BEGIN
            if StartDate = CalcDate('<-CY>', StartDate) then
                "Month/Quarter Text" := 'Q1';
            if StartDate = CALCDATE('<-CY+3M>', StartDate) then
                "Month/Quarter Text" := 'Q2';
            if StartDate = CALCDATE('<-CY+6M>', StartDate) then
                "Month/Quarter Text" := 'Q3';
            if StartDate = CALCDATE('<-CY+9M>', StartDate) then
                "Month/Quarter Text" := 'Q4';
        END else
            "Month/Quarter Text" := Format(StartDate, 0, '<Month Text>'); //Get Month of reporting period
        Year := Date2DMY(StartDate, 3);  //Get Year of reporting period

        ExcelBuffer.DELETEALL;
        CreateIntrastatSheet;
        CreateSalesSheet;
    end;

    trigger OnPostReport()
    begin
        ExcelBuffer.CloseBook;
        ExcelBuffer.SetFriendlyFilename('Intrastat ' + "Month/Quarter Text" + ' ' + Format(Year) + ' ' + CompanyInfo.Name);
        ExcelBuffer.OpenExcel;
    end;

    procedure CreateIntrastatSheet()
    var
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
        Country: Record "Country/Region";
        Location: Record Location;
        Item: Record Item;
        SheetHdrText: Text[100];
        SheetName: Text[250];
        GrossWeight: Decimal;
    begin
        SheetHdrText := 'Intrastat ' + "Month/Quarter Text" + ' ' + Format(Year);
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn(SheetHdrText, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow; //Row 2
        ExcelBuffer.NewRow; //Row 3

        //Create Excel Table Headers
        ExcelBuffer.AddColumn(Format(SalesInvLine.FieldCaption("Document No.")), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column A
        ExcelBuffer.AddColumn(Format(SalesInvHdr.FieldCaption("Posting Date")), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column B
        ExcelBuffer.AddColumn(Format(SalesInvLine.FieldCaption(Type)), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column C
        ExcelBuffer.AddColumn(Format(SalesInvLine.FieldCaption("No.")), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column D
        ExcelBuffer.AddColumn('GN-code (US)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column E
        ExcelBuffer.AddColumn('GN-code (EU)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column F
        ExcelBuffer.AddColumn(Format(SalesInvLine.FieldCaption(Quantity)), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column G
        ExcelBuffer.AddColumn('Gross weight per item', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column H
        ExcelBuffer.AddColumn('Gross weight total', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column I
        ExcelBuffer.AddColumn('CoO', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column J
        ExcelBuffer.AddColumn('Ship Method', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column K
        ExcelBuffer.AddColumn('Statistisch stelsel', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column L
        ExcelBuffer.AddColumn('Aard transactie', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column M
        ExcelBuffer.AddColumn('Ship-to Country', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column N
        ExcelBuffer.AddColumn('VAT Number', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column O
        ExcelBuffer.AddColumn(Format(SalesInvHdr.FieldCaption("Currency Code")), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column P
        ExcelBuffer.AddColumn('Invoice Value', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column Q
        ExcelBuffer.AddColumn('Value in Fin.Adm. (' + GLSetup."LCY Code" + ')', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column R
        ExcelBuffer.AddColumn('Exchange Rate', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column S
        ExcelBuffer.AddColumn('Region', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column T
        ExcelBuffer.AddColumn(Format(SalesInvHdr.FieldCaption("Bill-to Customer No.")), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column U
        ExcelBuffer.NewRow; //Row 4

        //Create Excel Table data
        SalesInvHdr.Reset();
        SalesInvLine.Reset();
        SalesInvHdr.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
        if SalesInvHdr.FindSet() then
            repeat
                SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                SalesInvLine.SetFilter("No.", '<>%1', ' ');
                if SalesInvLine.FindSet() then
                    repeat
                        Item.Get(SalesInvLine."No.");
                        ExcelBuffer.AddColumn(SalesInvLine."Document No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column A
                        ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date); //Row 4 and further, Column B
                        ExcelBuffer.AddColumn(SalesInvLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column C
                        ExcelBuffer.AddColumn(SalesInvLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column D
                        ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column E
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column F
                        ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column G
                        if Item."Gross Weight" = 0 then
                            GrossWeight := 0.01
                        else
                            GrossWeight := Item."Gross Weight";
                        ExcelBuffer.AddColumn(GrossWeight, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column H
                        ExcelBuffer.AddColumn(SalesInvLine.Quantity * GrossWeight, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column I
                        ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column J
                        /*Disabled below as it could be variable data
                        if StrPos(SalesInvLine."VAT Bus. Posting Group", 'NON-EU') > 0 then
                            ExcelBuffer.AddColumn(4, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number) //Row 4 and further, Column K
                        else
                            ExcelBuffer.AddColumn(3, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column K                        
                        ExcelBuffer.AddColumn(2, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column L
                        */
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column K
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column L
                        if SalesInvLine."Line Amount" = 0 then
                            ExcelBuffer.AddColumn(2, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number) //Row 4 and further, Column M
                        else
                            ExcelBuffer.AddColumn(1, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column M
                        ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column N
                        ExcelBuffer.AddColumn(SalesInvHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column O
                        if SalesInvHdr."Currency Code" = '' then
                            ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text) //Row 4 and further, Column P
                        else
                            ExcelBuffer.AddColumn(SalesInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column P
                        ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column Q
                        if (SalesInvHdr."Currency Factor" <> 0) AND (SalesInvLine.Amount <> 0) then
                            ExcelBuffer.AddColumn(Round(SalesInvLine.Amount / SalesInvHdr."Currency Factor", 0.01), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number) //Row 4 and further, Column R
                        else
                            ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column R
                        ExcelBuffer.AddColumn(SalesInvHdr."Currency Factor", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column S
                        Location.Get(SalesInvLine."Location Code");
                        if SalesInvHdr."Ship-to Country/Region Code" = Location."Country/Region Code" then
                            ExcelBuffer.AddColumn('DOMESTIC', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text) //Row 4 and further, Column T
                        else
                            if Country.IsEUCountry(SalesInvHdr."Ship-to Country/Region Code") then
                                ExcelBuffer.AddColumn('EU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text) //Row 4 and further, Column T
                            else
                                ExcelBuffer.AddColumn('NON EU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column T                        
                        ExcelBuffer.AddColumn(SalesInvHdr."Bill-to Customer No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column U
                        ExcelBuffer.NewRow; //Row 5 and further
                    until SalesInvLine.Next() = 0;
            until SalesInvHdr.Next() = 0;

        SalesCrHdr.Reset();
        SalesCrLine.Reset();
        SalesCrHdr.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
        if SalesCrHdr.FindSet() then
            repeat
                SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                SalesCrLine.SetRange(Type, SalesCrLine.Type::Item);
                SalesCrLine.SetFilter("No.", '<>%1', ' ');
                if SalesCrLine.FINDSET then
                    repeat
                        Item.GET(SalesCrLine."No.");
                        ExcelBuffer.AddColumn(SalesCrLine."Document No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column A
                        ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date); //Row 4 and further, Column B
                        ExcelBuffer.AddColumn(SalesCrLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column C
                        ExcelBuffer.AddColumn(SalesCrLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column D
                        ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column E
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column F
                        ExcelBuffer.AddColumn(SalesCrLine.Quantity, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column G
                        if Item."Gross Weight" = 0 then
                            GrossWeight := 0.01
                        else
                            GrossWeight := Item."Gross Weight";
                        ExcelBuffer.AddColumn(GrossWeight, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column H
                        ExcelBuffer.AddColumn(SalesCrLine.Quantity * GrossWeight, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column I
                        ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column J
                        /*Disabled below as it could be variable data
                        if STRPOS(SalesCrLine."VAT Bus. Posting Group", 'NON-EU') > 0 then
                            ExcelBuffer.AddColumn(4, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number) //Row 4 and further, Column K
                        else
                            ExcelBuffer.AddColumn(3, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column K
                        ExcelBuffer.AddColumn(2, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column L
                        */
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column K
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column L
                        ExcelBuffer.AddColumn(2, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column M
                        ExcelBuffer.AddColumn(SalesCrHdr."Ship-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column N
                        ExcelBuffer.AddColumn(SalesCrHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column O
                        if SalesCrHdr."Currency Code" = '' then
                            ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text) //Row 4 and further, Column P
                        else
                            ExcelBuffer.AddColumn(SalesCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column P
                        ExcelBuffer.AddColumn(-SalesCrLine.Amount, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column Q
                        if (SalesCrHdr."Currency Factor" <> 0) AND (SalesCrLine.Amount <> 0) then
                            ExcelBuffer.AddColumn(ROUND(-SalesCrLine.Amount / SalesCrHdr."Currency Factor", 0.01), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number) //Row 4 and further, Column R
                        else
                            ExcelBuffer.AddColumn(-SalesCrLine.Amount, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column R
                        ExcelBuffer.AddColumn(SalesCrHdr."Currency Factor", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column S
                        Location.Get(SalesCrLine."Location Code");
                        if SalesCrHdr."Ship-to Country/Region Code" = Location."Country/Region Code" then
                            ExcelBuffer.AddColumn('DOMESTIC', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text) //Row 4 and further, Column T
                        else
                            if Country.IsEUCountry(SalesCrHdr."Ship-to Country/Region Code") then
                                ExcelBuffer.AddColumn('EU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text) //Row 4 and further, Column T
                            else
                                ExcelBuffer.AddColumn('NON EU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column T
                        ExcelBuffer.AddColumn(SalesCrHdr."Bill-to Customer No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column U
                        ExcelBuffer.NewRow; //Row 5 and further
                    until SalesCrLine.Next() = 0;
            until SalesCrHdr.Next() = 0;

        SheetName := 'Intrastat ' + CopyStr("Month/Quarter Text", 1, 3) + ' ' + Format(Year);
        CreateNewExcelSheet(true, SheetName);
    end;

    procedure CreateSalesSheet()
    var
        GLEntry: Record "G/L Entry";
        SheetHdrText: Text[100];
        SheetName: Text[250];
    begin
        SheetHdrText := 'Sales ' + "Month/Quarter Text" + ' ' + Format(Year);
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn(SheetHdrText, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow; //Row 2
        ExcelBuffer.NewRow; //Row 3

        //Create Excel Table Headers
        ExcelBuffer.AddColumn(Format(GLEntry.FieldCaption("Posting Date")), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column A
        ExcelBuffer.AddColumn(Format(GLEntry.FieldCaption(Description)), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column B
        ExcelBuffer.AddColumn(Format(GLEntry.FieldCaption("Document No.")), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column C
        ExcelBuffer.AddColumn(Format(GLEntry.FieldCaption("G/L Account No.")), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column D
        ExcelBuffer.AddColumn(Format(GLEntry.FieldCaption("G/L Account Name")), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column E
        ExcelBuffer.AddColumn(Format(GLEntry.FieldCaption(Amount)), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 3, Column F
        ExcelBuffer.NewRow; //Row 4

        //Create Excel Table data
        GLEntry.Reset();
        GLEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
        GLEntry.SetFilter("G/L Account No.", SalesGLAccountFilter);
        if GLEntry.FindSet() then
            repeat
                ExcelBuffer.AddColumn(GLEntry."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date); //Row 4 and further, Column A
                ExcelBuffer.AddColumn(GLEntry.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column B
                ExcelBuffer.AddColumn(GLEntry."Document No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column C
                ExcelBuffer.AddColumn(GLEntry."G/L Account No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column D
                GLEntry.CalcFields("G/L Account Name");
                ExcelBuffer.AddColumn(GLEntry."G/L Account Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text); //Row 4 and further, Column E
                ExcelBuffer.AddColumn(GLEntry.Amount, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number); //Row 4 and further, Column F
                ExcelBuffer.NewRow; //Row 5 and further
            until GLEntry.Next() = 0;

        SheetName := 'Sales ' + CopyStr("Month/Quarter Text", 1, 3) + ' ' + Format(Year);
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateNewExcelSheet(NewBook: Boolean; Name: Text[250])
    begin
        if NewBook then
            ExcelBuffer.CreateNewBook(Name)
        else
            ExcelBuffer.SelectorAddSheet(Name);
        ExcelBuffer.WriteSheet('', CompanyName, UserId);
        ExcelBuffer.DeleteAll();
        ExcelBuffer.ClearNewRow();
    end;

    var
        StartDate: Date;
        EndDate: Date;
        SalesGLAccountFilter: Text;
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company InFormation";
        ExcelBuffer: Record "Excel Buffer";
        "Month/Quarter Text": Text[10];
        Year: Integer;
}