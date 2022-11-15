report 50006 "VAT Excel Report"

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

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
                    field("Start Date"; StartDate)
                    {
                        ApplicationArea = All;
                    }
                    field("End Date"; EndDate)
                    {
                        ApplicationArea = All;
                    }
                    field("VAT Statement Template"; VATStatementTemplate)
                    {
                        ApplicationArea = All;
                        TableRelation = "VAT Statement Name"."Statement Template Name";
                    }
                    field("VAT Statement"; VATStatementName)
                    {
                        ApplicationArea = All;
                        TableRelation = "VAT Statement Name".Name;
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    var
        VatStatement: Record "VAT Statement Name";
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'VAT Statement cannot be found. Template: %1, Name: %2.';
        ErrorText001: Label 'VAT Statement cannot be found. Template: %1, Name: %2.';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        CurrReport.Language(1033);
        if VATStatementTemplate = '' then
            Error('VAT Statement Template cannot be empty.')
        else
            if VATStatementName = '' then
                Error('VAT Statement cannot be empty.');
        VatStatement.SetRange("Statement Template Name", VATStatementTemplate);
        VatStatement.SetRange(Name, VATStatementName);
        if not VatStatement.FindFirst() then
            Error(ErrorText001, VATStatementTemplate, VATStatementName);

        VATStatementLine.SetRange("Statement Template Name", VATStatementTemplate);
        VATStatementLine.SetRange("Statement Name", VATStatementName);

        GLSetup.Get();
        CompanyInfo.Get();
        if EndDate - StartDate > 31 then begin
            if StartDate = CalcDate('<-CY>', StartDate) then
                "Month/Quarter Text" := 'Q1';
            if StartDate = CalcDate('<-CY+3M>', StartDate) then
                "Month/Quarter Text" := 'Q2';
            if StartDate = CalcDate('<-CY+6M>', StartDate) then
                "Month/Quarter Text" := 'Q3';
            if StartDate = CalcDate('<-CY+9M>', StartDate) then
                "Month/Quarter Text" := 'Q4';
        end else
            "Month/Quarter Text" := Format(StartDate, 0, '<Month Text>'); //Get Month of reporting period
        Year := Date2DMY(StartDate, 3); //Get year of reporting period

        ExcelBuffer.DeleteAll();
        CreateVATReturnSheet();
        create1aDomesticHighSheet();
        Create1bDomesticLowSheet();
        Create3aExportSheet();
        Create3bEUSuppliesSheet();
        Create4aImportSheet();
        Create4bSuppliesfromEUSheet();
        Create5bInputVATSheet();
        CreateECSalesListingSheet();
        CreateIntrastatICLSheet();
        CreateIntrastatICVSheet();
    end;

    procedure CreateNewExcelSheet(NewBook: Boolean; Name: Text[250])
    begin
        if NewBook then
            ExcelBuffer.CreateNewBook('Vat Return')
        else
            ExcelBuffer.SelectOrAddSheet(Name);
        ExcelBuffer.WriteSheet('', CompanyName, UserId);
        ExcelBuffer.DeleteAll();
        ExcelBuffer.ClearNewRow();
    end;

    procedure CreateVATReturnSheet()
    var
        VATEntry: Record "VAT Entry";
        SheetName: Text[250];
        VATEntryTotalBase: Decimal;
        VATEntryTotalAmount: Decimal;
    begin
        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Tax Jurisdiction Code", '');
        VATEntry.SetRange("Use Tax", false);
        VATEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
        //Create Excel Header Line
        //Excel Buffer variables: Value,Formula,Comment text,Bold,Italic,Underline,Numformat,Celltype
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Dutch VAT return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        Textvar := "Month/Quarter Text" + '-' + Format(Year);
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();

        //Create Excel Lines
        VATStatementLine.SetRange(Type, VATStatementLine.Type::"VAT Entry Totaling");
        ExcelBuffer.AddColumn('1.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Goods or service in the Netherlands', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount (Excl. VAT)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('1a.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services taxed at the high rate (21%)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '1A|1A.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
                VATEntryTotalAmount := VATEntryTotalAmount + VATEntry.Amount;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(-Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(-Round(VATEntryTotalAmount, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('1b.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services taxed at the low rate (9%)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '1B|1B.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
                VATEntryTotalAmount := VATEntryTotalAmount + VATEntry.Amount;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(-Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(-Round(VATEntryTotalAmount, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('1c.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services taxed at other rate, except 0%', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '1C|1C.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
                VATEntryTotalAmount := VATEntryTotalAmount + VATEntry.Amount;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(-Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(-Round(VATEntryTotalAmount, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('1d.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Private use', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '1D|1D.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
                VATEntryTotalAmount := VATEntryTotalAmount + VATEntry.Amount;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(-Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(-Round(VATEntryTotalAmount, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('1e.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services taxed at 0% or not taxed at your level', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '1E|1E.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(-Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('2.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Domestic reverse-charge mechanisms', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('2a.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services for which the VAT has been reverse-charged to you', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '2A|2A.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
                VATEntryTotalAmount := VATEntryTotalAmount + VATEntry.Amount;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(-Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(-Round(VATEntryTotalAmount, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('3.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Goods and services to/in foreign countries', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('3a.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies to non EU-countries (export)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '3A|3A.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(-Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('3b.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies to or service in EU-countries', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '3B|3B.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(-Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('3c.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Installation/distance sales within the EU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '3C|3C.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(-Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('4.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Goods and services supplied to you from abroad', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('4a.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services from non EU Member States', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '4A|4A.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
                VATEntryTotalAmount := VATEntryTotalAmount + VATEntry.Amount;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(Round(VATEntryTotalAmount, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        VATEntryTotalBase := 0;
        VATEntryTotalAmount := 0;
        ExcelBuffer.AddColumn('4b.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services from EU Member States', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        VATStatementLine.SetFilter("Row No.", '4B|4B.');
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                VATEntry.CalcSums(Base, Amount);
                VATEntryTotalBase := VATEntryTotalBase + VATEntry.Base;
                VATEntryTotalAmount := VATEntryTotalAmount + VATEntry.Amount;
            until VATStatementLine.Next() = 0;
        ExcelBuffer.AddColumn(Round(VATEntryTotalBase, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(Round(VATEntryTotalAmount, 1, '<'), false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Input tax, small business scheme, estimate, total', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5a.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT (box 1 until 4)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SUM(D6:D22)', true, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5b.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Input vat', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('CEILING(D21+D22+''5b Input VAT''!F8,1)', true, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5c.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Subtotal (box 5a minus 5b)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('D25-D26', true, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5d.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Tax relief under the small business scheme', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5e.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Estimate of previous returns', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5f.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Estimate of this returns', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5g.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total amount due or the be refunded', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('D27', true, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);

        SheetName := 'Vat Return';
        CreateNewExcelSheet(true, SheetName);
    end;

    procedure create1aDomesticHighSheet()
    var
        VATEntry: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
        TaxPercText: Text[10];
        SheetName: Text[250];
        VATPostingSetup: Record "VAT Posting Setup";
        PrevDocNo: Code[20];
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        Item: Record Item;
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
    begin
        VATStatementLine.SetFilter("Row No.", '1A|1A.');
        VATStatementLine.SetRange("Gen. Posting Type", VATStatementLine."Gen. Posting Type"::Sale);
        if VATStatementLine.FindFirst() then begin
            VATPostingSetup.Reset();
            VATPostingSetup.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
            VATPostingSetup.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
            if VATPostingSetup.FindFirst() then
                TaxPercText := Format(VATPostingSetup."VAT %") + '%';
        end;

        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Dutch VAT return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('1a', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services taxed at the high rate (' + TaxPercText + ')', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Invoice No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Type', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('No. / SKU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN-code', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('CoO', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gross weight per item', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gross weight total', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount excl. VAT', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange rate', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Tax Jurisdiction Code", '');
        VATEntry.SetRange("Use Tax", false);
        VATEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);

        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                if VATEntry.FindSet() then
                    repeat
                        if PrevDocNo <> VATEntry."Document No." then begin
                            PrevDocNo := VATEntry."Document No.";
                            case VATEntry."Document Type" of
                                VatEntry."Document Type"::Invoice:
                                    begin
                                        SalesInvHdr.Reset();
                                        SalesInvHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesInvHdr.FindFirst() then begin
                                            SalesInvLine.Reset();
                                            SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                                            SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::Item, SalesInvLine.Type::"G/L Account");
                                            SalesInvLine.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                                            SalesInvLine.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                                            if SalesInvLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesInvLine.Type = SalesInvLine.Type::Item then
                                                        if item.Get(SalesInvLine."No.") then begin
                                                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight" * SalesInvLine."Quantity (Base)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    if (SalesInvHdr."Currency Code" = 'EUR') or ((SalesInvHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then begin
                                                        ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn(SalesInvLine."Amount Including VAT" - SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(SalesInvLine.Amount / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn((SalesInvLine."Amount Including VAT" - SalesInvLine.Amount) / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesInvLine.Next() = 0;
                                        end;
                                    end;
                                VatEntry."Document Type"::"Credit Memo":
                                    begin
                                        SalesCrHdr.Reset();
                                        SalesCrHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesCrHdr.FindFirst() then begin
                                            SalesCrLine.Reset();
                                            SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                                            SalesCrLine.SetFilter(Type, '%1|%2', SalesCrLine.Type::Item, SalesCrLine.Type::"G/L Account");
                                            SalesCrLine.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                                            SalesCrLine.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                                            if SalesCrLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesCrLine.Type = SalesCrLine.Type::Item then
                                                        if item.Get(SalesCrLine."No.") then begin
                                                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight" * SalesCrLine."Quantity (Base)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    ExcelBuffer.AddColumn(SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    if (SalesCrHdr."Currency Code" = 'EUR') or ((SalesCrHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then begin
                                                        ExcelBuffer.AddColumn(-SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn(-SalesCrLine."Amount Including VAT" - SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Amount / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(-(SalesCrLine."Amount Including VAT" - SalesCrLine.Amount) / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesCrLine.Next() = 0;
                                        end;
                                    end;
                            end;
                        end;
                    until VATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        //Create a total field
        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No." + 2);
        ExcelBuffer.Validate("Column No.", 15);
        ExcelBuffer.Validate(Formula, 'SUM(O7:O' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        SheetName := '1a Domestic supplies ' + TaxPercText;
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure Create1bDomesticLowSheet()
    var
        VATEntry: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
        TaxPercText: Text[10];
        SheetName: Text[250];
        VATPostingSetup: Record "VAT Posting Setup";
        PrevDocNo: Code[20];
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        Item: Record Item;
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
    begin
        VATStatementLine.SetFilter("Row No.", '1B|1B.');
        VATStatementLine.SetRange("Gen. Posting Type", VATStatementLine."Gen. Posting Type"::Sale);
        if VATStatementLine.FindFirst() then begin
            VATPostingSetup.Reset();
            VATPostingSetup.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
            VATPostingSetup.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
            if VATPostingSetup.FindFirst() then
                TaxPercText := Format(VATPostingSetup."VAT %") + '%';
        end;

        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Dutch VAT return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('1b.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services taxed at the low rate (' + TaxPercText + ')', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Invoice No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Type', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('No. / SKU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN-code', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('CoO', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gross weight per item', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gross weight total', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount excl. VAT', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange rate', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Tax Jurisdiction Code", '');
        VATEntry.SetRange("Use Tax", false);
        VATEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);

        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                if VATEntry.FindSet() then
                    repeat
                        if PrevDocNo <> VATEntry."Document No." then begin
                            PrevDocNo := VATEntry."Document No.";
                            case VATEntry."Document Type" of
                                VatEntry."Document Type"::Invoice:
                                    begin
                                        SalesInvHdr.Reset();
                                        SalesInvHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesInvHdr.FindFirst() then begin
                                            SalesInvLine.Reset();
                                            SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                                            SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::Item, SalesInvLine.Type::"G/L Account");
                                            SalesInvLine.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                                            SalesInvLine.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                                            if SalesInvLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesInvLine.Type = SalesInvLine.Type::Item then
                                                        if item.Get(SalesInvLine."No.") then begin
                                                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight" * SalesInvLine."Quantity (Base)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    if (SalesInvHdr."Currency Code" = 'EUR') or ((SalesInvHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then begin
                                                        ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn(SalesInvLine."Amount Including VAT" - SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(SalesInvLine.Amount / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn((SalesInvLine."Amount Including VAT" - SalesInvLine.Amount) / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesInvLine.Next() = 0;
                                        end;
                                    end;
                                VatEntry."Document Type"::"Credit Memo":
                                    begin
                                        SalesCrHdr.Reset();
                                        SalesCrHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesCrHdr.FindFirst() then begin
                                            SalesCrLine.Reset();
                                            SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                                            SalesCrLine.SetFilter(Type, '%1|%2', SalesCrLine.Type::Item, SalesCrLine.Type::"G/L Account");
                                            SalesCrLine.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                                            SalesCrLine.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                                            if SalesCrLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesCrLine.Type = SalesCrLine.Type::Item then
                                                        if item.Get(SalesCrLine."No.") then begin
                                                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight" * SalesCrLine."Quantity (Base)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    ExcelBuffer.AddColumn(SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    if (SalesCrHdr."Currency Code" = 'EUR') or ((SalesCrHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then begin
                                                        ExcelBuffer.AddColumn(-SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn(-SalesCrLine."Amount Including VAT" - SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Amount / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(-(SalesCrLine."Amount Including VAT" - SalesCrLine.Amount) / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesCrLine.Next() = 0;
                                        end;
                                    end;
                            end;
                        end;
                    until VATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        //Create a total field
        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No." + 2);
        ExcelBuffer.Validate("Column No.", 15);
        ExcelBuffer.Validate(Formula, 'SUM(O7:O' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        SheetName := '1b Domestic supplies ' + TaxPercText;
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure Create3aExportSheet()
    var
        VATEntry: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
        TaxPercText: Text[10];
        SheetName: Text[250];
        PrevDocNo: Code[20];
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        Item: Record Item;
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
    begin
        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Dutch VAT return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('3a.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies to non EU Member States (Export)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Invoice No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Type', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('No. / SKU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN-code', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('CoO', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gross weight per item', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gross weight total', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange rate', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Tax Jurisdiction Code", '');
        VATEntry.SetRange("Use Tax", false);
        VATEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);

        VATStatementLine.SetFilter("Row No.", '3A|3A.');
        VATStatementLine.SetRange("Gen. Posting Type", VATStatementLine."Gen. Posting Type"::Sale);
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                if VATEntry.FindSet() then
                    repeat
                        if PrevDocNo <> VATEntry."Document No." then begin
                            PrevDocNo := VATEntry."Document No.";
                            case VATEntry."Document Type" of
                                VatEntry."Document Type"::Invoice:
                                    begin
                                        SalesInvHdr.Reset();
                                        SalesInvHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesInvHdr.FindFirst() then begin
                                            SalesInvLine.Reset();
                                            SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                                            SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::Item, SalesInvLine.Type::"G/L Account");
                                            SalesInvLine.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                                            SalesInvLine.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                                            if SalesInvLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesInvLine.Type = SalesInvLine.Type::Item then
                                                        if item.Get(SalesInvLine."No.") then begin
                                                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight" * SalesInvLine."Quantity (Base)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    if (SalesInvHdr."Currency Code" = 'EUR') or ((SalesInvHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then begin
                                                        ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(SalesInvLine.Amount / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesInvLine.Next() = 0;
                                        end;
                                    end;
                                VatEntry."Document Type"::"Credit Memo":
                                    begin
                                        SalesCrHdr.Reset();
                                        SalesCrHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesCrHdr.FindFirst() then begin
                                            SalesCrLine.Reset();
                                            SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                                            SalesCrLine.SetFilter(Type, '%1|%2', SalesCrLine.Type::Item, SalesCrLine.Type::"G/L Account");
                                            SalesCrLine.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                                            SalesCrLine.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                                            if SalesCrLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesCrLine.Type = SalesCrLine.Type::Item then
                                                        if item.Get(SalesCrLine."No.") then begin
                                                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight" * SalesCrLine."Quantity (Base)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    ExcelBuffer.AddColumn(-SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    if (SalesCrHdr."Currency Code" = 'EUR') or ((SalesCrHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then begin
                                                        ExcelBuffer.AddColumn(-SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Amount / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesCrLine.Next() = 0;
                                        end;
                                    end;
                            end;
                        end;
                    until VATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        //Create a total field
        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No." + 2);
        ExcelBuffer.Validate("Column No.", 14);
        ExcelBuffer.Validate(Formula, 'SUM(N7:N' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        SheetName := '3a Export';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure Create3bEUSuppliesSheet()
    var
        VATEntry: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
        TaxPercText: Text[10];
        SheetName: Text[250];
        PrevDocNo: Code[20];
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        Item: Record Item;
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
    begin
        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Dutch VAT return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('3b.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies to or services in EU Member States', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Invoice No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT number', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Type', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('No. / SKU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN-code', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('CoO', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gross weight per item', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gross weight total', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange rate', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Tax Jurisdiction Code", '');
        VATEntry.SetRange("Use Tax", false);
        VATEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);

        VATStatementLine.SetFilter("Row No.", '3B|3B.');
        VATStatementLine.SetRange("Gen. Posting Type", VATStatementLine."Gen. Posting Type"::Sale);
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                if VATEntry.FindSet() then
                    repeat
                        if PrevDocNo <> VATEntry."Document No." then begin
                            PrevDocNo := VATEntry."Document No.";
                            case VATEntry."Document Type" of
                                VatEntry."Document Type"::Invoice:
                                    begin
                                        SalesInvHdr.Reset();
                                        SalesInvHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesInvHdr.FindFirst() then begin
                                            SalesInvLine.Reset();
                                            SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                                            SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::Item, SalesInvLine.Type::"G/L Account");
                                            SalesInvLine.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                                            SalesInvLine.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                                            if SalesInvLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesInvLine.Type = SalesInvLine.Type::Item then
                                                        if item.Get(SalesInvLine."No.") then begin
                                                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight" * SalesInvLine."Quantity (Base)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    if (SalesInvHdr."Currency Code" = 'EUR') or ((SalesInvHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then begin
                                                        ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(SalesInvLine.Amount / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesInvLine.Next() = 0;
                                        end;
                                    end;
                                VatEntry."Document Type"::"Credit Memo":
                                    begin
                                        SalesCrHdr.Reset();
                                        SalesCrHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesCrHdr.FindFirst() then begin
                                            SalesCrLine.Reset();
                                            SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                                            SalesCrLine.SetFilter(Type, '%1|%2', SalesCrLine.Type::Item, SalesCrLine.Type::"G/L Account");
                                            SalesCrLine.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                                            SalesCrLine.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                                            if SalesCrLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesCrLine.Type = SalesCrLine.Type::Item then
                                                        if item.Get(SalesCrLine."No.") then begin
                                                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn(Item."Gross Weight" * SalesCrLine."Quantity (Base)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    ExcelBuffer.AddColumn(-SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    if (SalesCrHdr."Currency Code" = 'EUR') or ((SalesCrHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then begin
                                                        ExcelBuffer.AddColumn(-SalesCrLine.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Amount / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesCrLine.Next() = 0;
                                        end;
                                    end;
                            end;
                        end;
                    until VATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        //Create a total field
        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No." + 2);
        ExcelBuffer.Validate("Column No.", 15);
        ExcelBuffer.Validate(Formula, 'SUM(O7:O' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        SheetName := '3b EU supplies';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure Create4aImportSheet()
    var
        VATEntry: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
        SheetName: Text[250];
        PrevDocNo: Code[20];
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        Item: Record Item;
        PurchCrHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrLine: Record "Purch. Cr. Memo Line";
        TotalQty: decimal;
        TotalAmount: decimal;
        FirstInvoiceLine: Boolean;
        PrevItemNo: Code[20];
        PurchInvLine2: Record "Purch. Inv. Line";
        PurchCrLine2: Record "Purch. Cr. Memo Line";
        RecordCount: Integer;
    begin
        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Dutch VAT return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('4a.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services from non EU Member States', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Invoice No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplier', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Type', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('No. / SKU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN-code', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('CoO', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange rate', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Import Duties', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Tax Jurisdiction Code", '');
        VATEntry.SetRange("Use Tax", false);
        VATEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);

        VATStatementLine.SetFilter("Row No.", '4A|4A.');
        VATStatementLine.SetRange("Gen. Posting Type", VATStatementLine."Gen. Posting Type"::Purchase);
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                if VATEntry.FindSet() then
                    repeat
                        if PrevDocNo <> VATEntry."Document No." then begin
                            PrevDocNo := VATEntry."Document No.";
                            case VATEntry."Document Type" of
                                VatEntry."Document Type"::Invoice:
                                    begin
                                        PurchInvHdr.Reset();
                                        PurchInvHdr.SetRange("No.", VATEntry."Document No.");
                                        if PurchInvHdr.FindFirst() then begin
                                            TotalQty := 0;
                                            TotalAmount := 0;
                                            PurchInvLine.Reset();
                                            PurchInvLine.SetRange("Document No.", PurchInvHdr."No.");
                                            PurchInvLine.SetFilter(Type, '%1|%2', PurchInvLine.Type::Item, PurchInvLine.Type::"G/L Account");
                                            if PurchInvLine.FindSet() then begin
                                                FirstInvoiceLine := true;
                                                repeat
                                                    //Create totals per Item No. in the invoice
                                                    if PrevItemNo = PurchInvLine."No." then begin
                                                        TotalQty := TotalQty + PurchInvLine.Quantity;
                                                        TotalAmount := TotalAmount + PurchInvLine.Amount;
                                                    end else begin
                                                        PrevItemNo := PurchInvLine."No.";
                                                        PurchInvLine2.Reset();
                                                        PurchInvLine2.SetRange("Document No.", PurchInvLine."Document No.");
                                                        PurchInvLine2.SetRange(Type, PurchInvLine.Type);
                                                        PurchInvLine2.SetRange("No.", PurchInvLine."No.");
                                                        RecordCount := PurchInvLine2.Count;
                                                        TotalQty := PurchInvLine.Quantity;
                                                        TotalAmount := PurchInvLine.Amount;
                                                    end;
                                                    RecordCount := RecordCount - 1;
                                                    //Only create an Excelbuffer line for the last invoice line within the filter
                                                    if RecordCount = 0 then begin
                                                        ExcelBuffer.NewRow();
                                                        ExcelBuffer.AddColumn(PurchInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                        ExcelBuffer.AddColumn(PurchInvHdr."Buy-from Vendor Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        if PurchInvLine.Type = PurchInvLine.Type::Item then
                                                            if Item.Get(PurchInvLine."No.") then begin
                                                                ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            end else begin
                                                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            end
                                                        else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(PurchInvLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                        ExcelBuffer.AddColumn(TotalAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn(PurchInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        if (PurchInvHdr."Currency Code" = 'EUR') or ((PurchInvHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then
                                                            ExcelBuffer.AddColumn(TotalAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                                                        else
                                                            if (PurchInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then
                                                                ExcelBuffer.AddColumn(TotalAmount / PurchInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                                                            else
                                                                ExcelBuffer.AddColumn('Manual calculation is needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('L' + Format(ExcelBuffer."Row No."), false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        if FirstInvoiceLine then begin
                                                            ExcelBuffer.AddColumn(VATEntry.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            FirstInvoiceLine := false;
                                                        end else
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                until PurchInvLine.Next() = 0;
                                            end;
                                        end;
                                    end;
                                VatEntry."Document Type"::"Credit Memo":
                                    begin
                                        PurchCrHdr.Reset();
                                        PurchCrHdr.SetRange("No.", VATEntry."Document No.");
                                        if PurchCrHdr.FindFirst() then begin
                                            TotalQty := 0;
                                            TotalAmount := 0;
                                            PurchCrLine.Reset();
                                            PurchCrLine.SetRange("Document No.", PurchCrHdr."No.");
                                            PurchCrLine.SetFilter(Type, '%1|%2', PurchCrLine.Type::Item, PurchCrLine.Type::"G/L Account");
                                            if PurchCrLine.FindSet() then begin
                                                FirstInvoiceLine := true;
                                                repeat
                                                    //Create totals per Item No. in the invoice
                                                    if PrevItemNo = PurchCrLine."No." then begin
                                                        TotalQty := TotalQty + PurchCrLine.Quantity;
                                                        TotalAmount := TotalAmount + PurchCrLine.Amount;
                                                    end else begin
                                                        PrevItemNo := PurchCrLine."No.";
                                                        PurchCrLine2.Reset();
                                                        PurchCrLine2.SetRange("Document No.", PurchCrLine."Document No.");
                                                        PurchCrLine2.SetRange(Type, PurchCrLine.Type);
                                                        PurchCrLine2.SetRange("No.", PurchCrLine."No.");
                                                        RecordCount := PurchCrLine2.Count;
                                                        TotalQty := PurchCrLine.Quantity;
                                                        TotalAmount := PurchCrLine.Amount;
                                                    end;
                                                    RecordCount := RecordCount - 1;
                                                    //Only create an Excelbuffer line for the last invoice line within the filter
                                                    if RecordCount = 0 then begin
                                                        ExcelBuffer.NewRow();
                                                        ExcelBuffer.AddColumn(PurchCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                        ExcelBuffer.AddColumn(PurchCrHdr."Buy-from Vendor Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchCrLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchCrLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchCrLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        if PurchCrLine.Type = PurchCrLine.Type::Item then
                                                            if Item.Get(PurchCrLine."No.") then begin
                                                                ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            end else begin
                                                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            end
                                                        else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(PurchCrLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                        ExcelBuffer.AddColumn(TotalAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn(PurchCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        if (PurchCrHdr."Currency Code" = 'EUR') or ((PurchCrHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then
                                                            ExcelBuffer.AddColumn(TotalAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                                                        else
                                                            if (PurchCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then
                                                                ExcelBuffer.AddColumn(TotalAmount / PurchCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                                                            else
                                                                ExcelBuffer.AddColumn('Manual calculation is needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('L' + Format(ExcelBuffer."Row No."), false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        if FirstInvoiceLine then begin
                                                            ExcelBuffer.AddColumn(VATEntry.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            FirstInvoiceLine := false;
                                                        end else
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                until PurchCrLine.Next() = 0;
                                            end;
                                        end;
                                    end;
                            end;
                        end;
                    until VATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        //Create a total field
        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No." + 2);
        ExcelBuffer.Validate("Column No.", 12);
        ExcelBuffer.Validate(Formula, 'SUM(L7:L' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No.");
        ExcelBuffer.Validate("Column No.", 13);
        ExcelBuffer.Validate(Formula, 'SUM(M7:M' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No.");
        ExcelBuffer.Validate("Column No.", 14);
        ExcelBuffer.Validate(Formula, 'SUM(N7:N' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No.");
        ExcelBuffer.Validate("Column No.", 15);
        ExcelBuffer.Validate(Formula, 'SUM(O7:O' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        SheetName := '4a Import';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure Create4bSuppliesfromEUSheet()
    var
        VATEntry: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
        SheetName: Text[250];
        PrevDocNo: Code[20];
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        Item: Record Item;
        PurchCrHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrLine: Record "Purch. Cr. Memo Line";
        TotalQty: decimal;
        TotalAmount: decimal;
        FirstInvoiceLine: Boolean;
        PrevItemNo: Code[20];
        PurchInvLine2: Record "Purch. Inv. Line";
        PurchCrLine2: Record "Purch. Cr. Memo Line";
        RecordCount: Integer;
    begin
        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Dutch VAT return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('4b.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplies/services from EU Member States', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Invoice No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplier', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT number', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Type', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('No. / SKU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN-code', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('CoO', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange rate', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT EUR', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Tax Jurisdiction Code", '');
        VATEntry.SetRange("Use Tax", false);
        VATEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);

        VATStatementLine.SetFilter("Row No.", '4B|4B.');
        VATStatementLine.SetRange("Gen. Posting Type", VATStatementLine."Gen. Posting Type"::Purchase);
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                if VATEntry.FindSet() then
                    repeat
                        if PrevDocNo <> VATEntry."Document No." then begin
                            PrevDocNo := VATEntry."Document No.";
                            case VATEntry."Document Type" of
                                VatEntry."Document Type"::Invoice:
                                    begin
                                        PurchInvHdr.Reset();
                                        PurchInvHdr.SetRange("No.", VATEntry."Document No.");
                                        if PurchInvHdr.FindFirst() then begin
                                            TotalQty := 0;
                                            TotalAmount := 0;
                                            PurchInvLine.Reset();
                                            PurchInvLine.SetRange("Document No.", PurchInvHdr."No.");
                                            PurchInvLine.SetFilter(Type, '%1|%2', PurchInvLine.Type::Item, PurchInvLine.Type::"G/L Account");
                                            if PurchInvLine.FindSet() then begin
                                                FirstInvoiceLine := true;
                                                repeat
                                                    //Create totals per Item No. in the invoice
                                                    if PrevItemNo = PurchInvLine."No." then begin
                                                        TotalQty := TotalQty + PurchInvLine.Quantity;
                                                        TotalAmount := TotalAmount + PurchInvLine.Amount;
                                                    end else begin
                                                        PrevItemNo := PurchInvLine."No.";
                                                        PurchInvLine2.Reset();
                                                        PurchInvLine2.SetRange("Document No.", PurchInvLine."Document No.");
                                                        PurchInvLine2.SetRange(Type, PurchInvLine.Type);
                                                        PurchInvLine2.SetRange("No.", PurchInvLine."No.");
                                                        RecordCount := PurchInvLine2.Count;
                                                        TotalQty := PurchInvLine.Quantity;
                                                        TotalAmount := PurchInvLine.Amount;
                                                    end;
                                                    RecordCount := RecordCount - 1;
                                                    //Only create an Excelbuffer line for the last invoice line within the filter
                                                    if RecordCount = 0 then begin
                                                        ExcelBuffer.NewRow();
                                                        ExcelBuffer.AddColumn(PurchInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                        ExcelBuffer.AddColumn(PurchInvHdr."Buy-from Vendor Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        if PurchInvLine.Type = PurchInvLine.Type::Item then
                                                            if Item.Get(PurchInvLine."No.") then begin
                                                                ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            end else begin
                                                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            end
                                                        else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(PurchInvLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                        ExcelBuffer.AddColumn(TotalAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn(PurchInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        if (PurchInvHdr."Currency Code" = 'EUR') or ((PurchInvHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then
                                                            ExcelBuffer.AddColumn(TotalAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                                                        else
                                                            if (PurchInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then
                                                                ExcelBuffer.AddColumn(TotalAmount / PurchInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                                                            else
                                                                ExcelBuffer.AddColumn('Manual calculation is needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        if FirstInvoiceLine then begin
                                                            ExcelBuffer.AddColumn(VATEntry.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            FirstInvoiceLine := false;
                                                        end else
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                until PurchInvLine.Next() = 0;
                                            end;
                                        end;
                                    end;
                                VatEntry."Document Type"::"Credit Memo":
                                    begin
                                        PurchCrHdr.Reset();
                                        PurchCrHdr.SetRange("No.", VATEntry."Document No.");
                                        if PurchCrHdr.FindFirst() then begin
                                            TotalQty := 0;
                                            TotalAmount := 0;
                                            PurchCrLine.Reset();
                                            PurchCrLine.SetRange("Document No.", PurchCrHdr."No.");
                                            PurchCrLine.SetFilter(Type, '%1|%2', PurchCrLine.Type::Item, PurchCrLine.Type::"G/L Account");
                                            if PurchCrLine.FindSet() then begin
                                                FirstInvoiceLine := true;
                                                repeat
                                                    //Create totals per Item No. in the invoice
                                                    if PrevItemNo = PurchCrLine."No." then begin
                                                        TotalQty := TotalQty + PurchCrLine.Quantity;
                                                        TotalAmount := TotalAmount + PurchCrLine.Amount;
                                                    end else begin
                                                        PrevItemNo := PurchCrLine."No.";
                                                        PurchCrLine2.Reset();
                                                        PurchCrLine2.SetRange("Document No.", PurchCrLine."Document No.");
                                                        PurchCrLine2.SetRange(Type, PurchCrLine.Type);
                                                        PurchCrLine2.SetRange("No.", PurchCrLine."No.");
                                                        RecordCount := PurchCrLine2.Count;
                                                        TotalQty := PurchCrLine.Quantity;
                                                        TotalAmount := PurchCrLine.Amount;
                                                    end;
                                                    RecordCount := RecordCount - 1;
                                                    //Only create an Excelbuffer line for the last invoice line within the filter
                                                    if RecordCount = 0 then begin
                                                        ExcelBuffer.NewRow();
                                                        ExcelBuffer.AddColumn(PurchCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                        ExcelBuffer.AddColumn(PurchCrHdr."Buy-from Vendor Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchCrHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchCrLine.Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchCrLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchCrLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        if PurchCrLine.Type = PurchCrLine.Type::Item then
                                                            if Item.Get(PurchCrLine."No.") then begin
                                                                ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(Item."Country/Region of Origin Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            end else begin
                                                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                                ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            end
                                                        else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(PurchCrLine.Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                        ExcelBuffer.AddColumn(TotalAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        ExcelBuffer.AddColumn(PurchCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        if (PurchCrHdr."Currency Code" = 'EUR') or ((PurchCrHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'EUR')) then
                                                            ExcelBuffer.AddColumn(TotalAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                                                        else
                                                            if (PurchCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then
                                                                ExcelBuffer.AddColumn(TotalAmount / PurchCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                                                            else
                                                                ExcelBuffer.AddColumn('Manual calculation is needed as company is not setup in EUR', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        if FirstInvoiceLine then begin
                                                            ExcelBuffer.AddColumn(VATEntry.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                            FirstInvoiceLine := false;
                                                        end else
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                until PurchCrLine.Next() = 0;
                                            end;
                                        end;
                                    end;
                            end;
                        end;
                    until VATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        //Create a total field
        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No." + 2);
        ExcelBuffer.Validate("Column No.", 13);
        ExcelBuffer.Validate(Formula, 'SUM(M7:M' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No.");
        ExcelBuffer.Validate("Column No.", 14);
        ExcelBuffer.Validate(Formula, 'SUM(N7:N' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        SheetName := '4b Supplies from EU';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure Create5bInputVATSheet()
    var
        SheetName: Text[250];
    begin
        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Dutch VAT return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5b.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Input VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Invoice No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplier', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount Excl. VAT', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT (EUR)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total Amount', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        //Create a total field
        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No." + 2);
        ExcelBuffer.Validate("Column No.", 6);
        ExcelBuffer.Validate(Formula, 'SUM(F7:F' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, true);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '#,##0.00');
        ExcelBuffer.Insert(true);

        SheetName := '5b Input VAT';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateECSalesListingSheet()
    var
        VATStatementLine: Record "VAT Statement Line";
        SheetName: Text[250];
        PrevVATBusPostingGroup: Code[10];
        Customer: Record Customer;
        TotalAmount: Decimal;
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrLine: Record "Sales Cr.Memo Line";
    begin
        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('EC Sales Listing', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('1.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT group', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();

        ExcelBuffer.AddColumn('2.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Correcting previous declarations', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('2a.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Correction to intra-Community supplies of goods and services', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('2b.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Correction to intra-Community ABC supplies (simplified scheme)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();

        ExcelBuffer.AddColumn('3.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Details of intra-Community transactions', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('3a.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Intra-Community supplies of goods and services and ABC-supplies', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('3b.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Intra-Community ABC supplies (simplified scheme)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();

        ExcelBuffer.AddColumn('3a.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Intra-Community supplies of goods and service and ABC-supplies', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('', false, '', false, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer Name', false, '', false, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Buyers VAT Number', false, '', false, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total', false, '', false, false, true, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();

        VATStatementLine.SetFilter("Row No.", '3B|3B.');
        VATStatementLine.SetRange("Gen. Posting Type", VATStatementLine."Gen. Posting Type"::Sale);
        if VATStatementLine.FindSet() then
            repeat
                if PrevVATBusPostingGroup <> VATStatementLine."VAT Bus. Posting Group" then begin
                    PrevVATBusPostingGroup := VATStatementLine."VAT Bus. Posting Group";
                    Customer.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                    if Customer.FindSet() then
                        repeat
                            TotalAmount := 0;
                            SalesInvLine.Reset();
                            SalesInvLine.SetRange("Sell-to Customer No.", Customer."No.");
                            SalesInvLine.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
                            SalesInvLine.SetFilter(Amount, '<>%1', 0);
                            if SalesInvLine.FindSet() then
                                repeat
                                    TotalAmount := TotalAmount + SalesInvLine.Amount;
                                until SalesInvLine.Next() = 0;
                            SalesCrLine.Reset();
                            SalesCrLine.SetRange("Sell-to Customer No.", Customer."No.");
                            SalesCrLine.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
                            SalesCrLine.SetFilter(Amount, '<>%1', 0);
                            if SalesCrLine.FindSet() then
                                repeat
                                    TotalAmount := TotalAmount - SalesCrLine.Amount;
                                until SalesCrLine.Next() = 0;
                            if TotalAmount <> 0 then begin
                                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                ExcelBuffer.AddColumn(Customer.Name, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                ExcelBuffer.AddColumn(Customer."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                ExcelBuffer.AddColumn(TotalAmount, false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                ExcelBuffer.NewRow();
                            end;
                        until Customer.Next() = 0;
                end;
            until VATStatementLine.Next() = 0;

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        //Create a total field
        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No." + 2);
        ExcelBuffer.Validate("Column No.", 2);
        ExcelBuffer.Validate("Cell Value as Text", 'Total');
        ExcelBuffer.Validate(Bold, false);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.Insert(true);

        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", ExcelBuffer."Row No.");
        ExcelBuffer.Validate("Column No.", 4);
        ExcelBuffer.Validate(Formula, 'SUM(D7:D' + Format(ExcelBuffer."Row No." - 1) + ')');
        ExcelBuffer.Validate(Bold, false);
        ExcelBuffer.Validate("Cell Type", ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.Validate(NumberFormat, '_-"€" * #,##0_-');
        ExcelBuffer.Insert(true);

        SheetName := 'EC Sales Listing';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateIntrastatICLSheet()
    var
        VATEntry: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
        SheetName: Text[250];
        PrevDocNo: Code[20];
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        Item: Record Item;
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
    begin
        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Tax Jurisdiction Code", '');
        VATEntry.SetRange("Use Tax", false);
        VATEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);

        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Intrastat / ICL', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Periode', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Goederenstroom', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Statistisch stelsel', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Land van bestemming', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Transactiesoort', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Vervoerswijze', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Goederencode', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gewicht', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Valutacode (alleen indien geen Euro)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Factuurwaarde (in Euro)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        VATStatementLine.SetFilter("Row No.", '3B|3B.');
        VATStatementLine.SetRange("Gen. Posting Type", VATStatementLine."Gen. Posting Type"::Sale);
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                if VATEntry.FindSet() then
                    repeat
                        if PrevDocNo <> VATEntry."Document No." then begin
                            PrevDocNo := VATEntry."Document No.";
                            case VATEntry."Document Type" of
                                VATEntry."Document Type"::Invoice:
                                    begin
                                        SalesInvHdr.Reset();
                                        SalesInvHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesInvHdr.FindFirst() then begin
                                            SalesInvLine.Reset();
                                            SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                                            SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::Item, SalesInvLine.Type::"G/L Account");
                                            if SalesInvLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn('7', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('02', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('1', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('0', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesInvLine.Type = SalesInvLine.Type::Item then
                                                        if Item.Get(SalesInvLine."No.") then begin
                                                            ExcelBuffer.AddColumn(item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    if (SalesInvHdr."Currency Code" = 'EUR') or ((SalesInvHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'eur')) then begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(SalesInvLine.Amount, false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(SalesInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(SalesInvLine.Amount / SalesInvHdr."Currency Factor", false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn(SalesInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesInvLine.Next() = 0;
                                        end;
                                    end;
                                VATEntry."Document Type"::"Credit Memo":
                                    begin
                                        SalesCrHdr.Reset();
                                        SalesCrHdr.SetRange("No.", VATEntry."Document No.");
                                        if SalesCrHdr.FindFirst() then begin
                                            SalesCrLine.Reset();
                                            SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                                            SalesCrLine.SetFilter(Type, '%1|%2', SalesCrLine.Type::Item, SalesCrLine.Type::"G/L Account");
                                            if SalesCrLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn('7', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('02', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(SalesCrHdr."Ship-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('1', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('0', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if SalesCrLine.Type = SalesCrLine.Type::Item then
                                                        if Item.Get(SalesCrLine."No.") then begin
                                                            ExcelBuffer.AddColumn(item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    if (SalesCrHdr."Currency Code" = 'EUR') or ((SalesCrHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'eur')) then begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(-SalesCrLine.Amount, false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (SalesCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(SalesCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-SalesCrLine.Amount / SalesCrHdr."Currency Factor", false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn(SalesCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until SalesCrLine.Next() = 0;
                                        end;
                                    end;
                            end;
                        end;
                    until VATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        SheetName := 'Intrastat ICL';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateIntrastatICVSheet()
    var
        VATEntry: Record "VAT Entry";
        VATStatementLine: Record "VAT Statement Line";
        SheetName: Text[250];
        PrevDocNo: Code[20];
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        Item: Record Item;
        PurchCrHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrLine: Record "Purch. Cr. Memo Line";
    begin
        VATEntry.Reset();
        VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
        VATEntry.SetRange("Tax Jurisdiction Code", '');
        VATEntry.SetRange("Use Tax", false);
        VATEntry.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);

        //Create Excel header lines        
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Intrastat / ICV', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Textvar, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();

        //Create Excel Lines
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Periode', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Goederenstroom', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Statistisch stelsel', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Land van herkomst', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Transactiecode', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Vervoerswijze', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Goederencode', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Gewicht', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Valutacode (alleen indien geen Euro)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Factuurwaarde (in Euro)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        VATStatementLine.SetFilter("Row No.", '4B|4B.');
        VATStatementLine.SetRange("Gen. Posting Type", VATStatementLine."Gen. Posting Type"::Purchase);
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.SetRange(Type, VATStatementLine."Gen. Posting Type");
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                if VATEntry.FindSet() then
                    repeat
                        if PrevDocNo <> VATEntry."Document No." then begin
                            PrevDocNo := VATEntry."Document No.";
                            case VATEntry."Document Type" of
                                VATEntry."Document Type"::Invoice:
                                    begin
                                        PurchInvHdr.Reset();
                                        PurchInvHdr.SetRange("No.", VATEntry."Document No.");
                                        if PurchInvHdr.FindFirst() then begin
                                            PurchInvLine.Reset();
                                            PurchInvLine.SetRange("Document No.", PurchInvHdr."No.");
                                            PurchInvLine.SetFilter(Type, '%1|%2', PurchInvLine.Type::Item, PurchInvLine.Type::"G/L Account");
                                            if PurchInvLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(PurchInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn('?', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('??', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(PurchInvHdr."Buy-from Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('?', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('?', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if PurchInvLine.Type = PurchInvLine.Type::Item then
                                                        if Item.Get(PurchInvLine."No.") then begin
                                                            ExcelBuffer.AddColumn(item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    if (PurchInvHdr."Currency Code" = 'EUR') or ((PurchInvHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'eur')) then begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(PurchInvLine.Amount, false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (PurchInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(PurchInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(PurchInvLine.Amount / PurchInvHdr."Currency Factor", false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn(PurchInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until PurchInvLine.Next() = 0;
                                        end;
                                    end;
                                VATEntry."Document Type"::"Credit Memo":
                                    begin
                                        PurchCrHdr.Reset();
                                        PurchCrHdr.SetRange("No.", VATEntry."Document No.");
                                        if PurchCrHdr.FindFirst() then begin
                                            PurchCrLine.Reset();
                                            PurchCrLine.SetRange("Document No.", PurchCrHdr."No.");
                                            PurchCrLine.SetFilter(Type, '%1|%2', PurchCrLine.Type::Item, PurchCrLine.Type::"G/L Account");
                                            if PurchCrLine.FindSet() then
                                                repeat
                                                    ExcelBuffer.NewRow();
                                                    ExcelBuffer.AddColumn(PurchCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                                                    ExcelBuffer.AddColumn('?', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('??', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn(PurchCrHdr."Ship-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('?', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    ExcelBuffer.AddColumn('?', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                    if PurchCrLine.Type = PurchCrLine.Type::Item then
                                                        if Item.Get(PurchCrLine."No.") then begin
                                                            ExcelBuffer.AddColumn(item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                        end
                                                    else begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                                    end;
                                                    if (PurchCrHdr."Currency Code" = 'EUR') or ((PurchCrHdr."Currency Code" = '') and (GLSetup."LCY Code" = 'eur')) then begin
                                                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                        ExcelBuffer.AddColumn(-PurchCrLine.Amount, false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                    end else
                                                        if (PurchCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                                                            ExcelBuffer.AddColumn(PurchCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn(-PurchCrLine.Amount / PurchCrHdr."Currency Factor", false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                        end else begin
                                                            ExcelBuffer.AddColumn(PurchCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                                                            ExcelBuffer.AddColumn('Manual calculation needed as company is not setup in EUR', false, '', false, false, false, '_-"€" * #,##0_-', ExcelBuffer."Cell Type"::Number);
                                                        end;
                                                until PurchCrLine.Next() = 0;
                                        end;
                                    end;
                            end;
                        end;
                    until VATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        SheetName := 'Intrastat ICV';
        CreateNewExcelSheet(false, SheetName);
    end;

    trigger OnPostReport()
    begin
        ExcelBuffer.CloseBook();
        ExcelBuffer.SetFriendlyFilename('Intrastat ' + CompanyInfo.Name + ' ' + "Month/Quarter Text" + ' ' + Format(Year));
        ExcelBuffer.OpenExcel();
    end;

    //Global Variables
    var
        StartDate: Date;
        EndDate: Date;
        VATStatementTemplate: Text;
        VATStatementName: Text;
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        "Month/Quarter Text": Text[10];
        Year: Integer;
        ExcelBuffer: Record "Excel Buffer";
        Textvar: Text[20];
        VATStatementLine: Record "VAT Statement Line";
}