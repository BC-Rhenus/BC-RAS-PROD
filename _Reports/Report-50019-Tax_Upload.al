report 50019 "Tax Upload"

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

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
                        ApplicationArea = All;
                    }
                    field("end Date"; endDate)
                    {
                        ApplicationArea = All;
                    }
                    field("IC Supplies VAT Bus. Posting Group Filter"; ICSuppliesSheetVATFilter)
                    {
                        ApplicationArea = All;
                        TableRelation = "VAT Business Posting Group";
                    }
                    field("Export Supplies VAT Bus. Posting Group Filter"; ExportSuppliesSheetVATFilter)
                    {
                        ApplicationArea = All;
                        TableRelation = "VAT Business Posting Group";
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        CurrReport.LANGUAGE(1033);
        GLSetup.Get();
        CompanyInfo.Get();
        if endDate - StartDate > 31 then begin
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
        Year := Date2DMY(StartDate, 3);  //Get Year of reporting period

        ExcelBuffer.DeleteAll();
        CreateICSuppliesSheet;
        CreateExportSuppliesSheet;
        CreateNLSuppliesSheet;
        CreateImportsinNLSheet;
        CreateNoSalesSheet;
        CreateInputVATSheet;
        CreateVATReturnSheet;
        CreateICPSheet;
    end;

    procedure CreateNewExcelSheet(NewBook: Boolean; Name: Text[250])
    begin
        if NewBook then
            ExcelBuffer.CreateNewBook('IC supplies')
        else
            ExcelBuffer.SelectorAddSheet(Name);
        ExcelBuffer.WriteSheet('', CompanyName, UserId);
        ExcelBuffer.DeleteAll();
        ExcelBuffer.ClearNewRow();
    end;

    procedure CreateICSuppliesSheet()
    var
        COGSAmount: Decimal;
        COGSAccount: Code[20];
        CurrentExcelRow: Decimal;
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
        GenPostingSetup: Record "General Posting Setup";
        Item: Record Item;
        GLEntry: Record "G/L Entry";
        VATBusPostingGroup: Record "VAT Business Posting Group";
        SheetName: Text[250];
    begin
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('Intracommunity supplies from the Netherlands (Table II, a, 6)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;

        //Create Excel table Headers
        ExcelBuffer.AddColumn('Invoice Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Buyers VAT Number', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer Name', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Quantity', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Nett Weight (KG)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Product commodity code (GN code)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice amount in Currency', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Curr.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice amount in Euro', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange Rate for return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT statement on invoice', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Remarks', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Related COS in Euro', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        SalesInvHdr.Reset();
        SalesInvLine.Reset();
        SalesInvHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        SalesInvHdr.SetFilter("VAT Bus. Posting Group", ICSuppliesSheetVATFilter);
        if SalesInvHdr.FindSet() then
            repeat
                //Create Excel table Data
                //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                ExcelBuffer.NewRow;
                ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(SalesInvHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(SalesInvHdr."Sell-to Customer Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                SalesInvLine.SetCurrentKey("Document No.", "Line No.");
                SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                if SalesInvLine.FindFirst() then begin
                    ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(SalesInvLine."Net Weight", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    if Item.Get(SalesInvLine."No.") then
                        ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end else begin
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;
                SalesInvHdr.CalcFields("Amount Including VAT");
                ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                if SalesInvHdr."Currency Code" <> '' then
                    ExcelBuffer.AddColumn(SalesInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesInvHdr."Currency Factor" <> 0 then
                    if GLSetup."LCY Code" = 'EUR' then begin
                        ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT" / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesInvHdr."Currency Factor", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    end else begin
                        ExcelBuffer.AddColumn('<Manually calculation needed since Company setup is not in EUR>', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('<Manually enter Exchange Rate since Company setup is not in EUR>', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    end
                else begin
                    ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('n/a', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;
                if SalesInvLine.FindFirst() then
                    ExcelBuffer.AddColumn(SalesInvLine."VAT %", false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number);
                if VATBusPostingGroup.Get(SalesInvHdr."VAT Bus. Posting Group") then
                    ExcelBuffer.AddColumn(VATBusPostingGroup."order Confirmation Footer Text", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesInvLine.FindSet() then begin
                    COGSAmount := 0;
                    COGSAccount := '';
                    repeat
                        GenPostingSetup.SetRange("Gen. Bus. Posting Group", SalesInvLine."Gen. Bus. Posting Group");
                        GenPostingSetup.SetRange("Gen. Prod. Posting Group", SalesInvLine."Gen. Prod. Posting Group");
                        if (GenPostingSetup.FindFirst()) and (GenPostingSetup."COGS Account" <> '') and (COGSAccount <> GenPostingSetup."COGS Account") then begin
                            COGSAccount := GenPostingSetup."COGS Account";
                            GLEntry.SetRange("G/L Account No.", GenPostingSetup."COGS Account");
                            GLEntry.SetRange("Posting Date", SalesInvHdr."Posting Date");
                            GLEntry.SetRange("Document No.", SalesInvHdr."No.");
                            if GLEntry.FindSet() then
                                repeat
                                    COGSAmount := COGSAmount + GLEntry.Amount;
                                until GLEntry.Next() = 0;
                        end;
                    until SalesInvLine.Next() = 0;
                end;
                ExcelBuffer.AddColumn(COGSAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
            until SalesInvHdr.Next() = 0;

        SalesCrHdr.Reset();
        SalesCrLine.Reset();
        SalesCrHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        SalesCrHdr.SetFilter("VAT Bus. Posting Group", ICSuppliesSheetVATFilter);
        if SalesCrHdr.FindSet() then
            repeat
                //Create Excel table Data
                //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                ExcelBuffer.NewRow;
                ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                ExcelBuffer.AddColumn(SalesCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(SalesCrHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(SalesCrHdr."Sell-to Customer Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                SalesCrLine.SetCurrentKey("Document No.", "Line No.");
                SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                SalesCrLine.SetRange(Type, SalesCrLine.Type::Item);
                if SalesCrLine.FindFirst() then begin
                    ExcelBuffer.AddColumn(SalesCrLine.Quantity, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(SalesCrLine."Net Weight", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    if Item.Get(SalesCrLine."No.") then
                        ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end else begin
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;
                SalesCrHdr.CalcFields("Amount Including VAT");
                ExcelBuffer.AddColumn(-SalesCrHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                if SalesCrHdr."Currency Code" <> '' then
                    ExcelBuffer.AddColumn(SalesCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesCrHdr."Currency Factor" <> 0 then
                    if GLSetup."LCY Code" = 'EUR' then begin
                        ExcelBuffer.AddColumn(-SalesCrHdr."Amount Including VAT" / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(SalesCrHdr."Currency Factor", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    end else begin
                        ExcelBuffer.AddColumn('<Manually calculation needed since Company setup is not in EUR>', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('<Manually enter Exchange Rate since Company setup is not in EUR>', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    end
                else begin
                    ExcelBuffer.AddColumn(-SalesCrHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('n/a', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;
                if SalesCrLine.FindFirst() then
                    ExcelBuffer.AddColumn(SalesCrLine."VAT %", false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number);
                if VATBusPostingGroup.Get(SalesInvHdr."VAT Bus. Posting Group") then
                    ExcelBuffer.AddColumn(VATBusPostingGroup."order Confirmation Footer Text", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesCrLine.FindSet() then begin
                    COGSAmount := 0;
                    COGSAccount := '';
                    repeat
                        GenPostingSetup.SetRange("Gen. Bus. Posting Group", SalesCrLine."Gen. Bus. Posting Group");
                        GenPostingSetup.SetRange("Gen. Prod. Posting Group", SalesCrLine."Gen. Prod. Posting Group");
                        if (GenPostingSetup.FindFirst()) and (GenPostingSetup."COGS Account" <> '') and (COGSAccount <> GenPostingSetup."COGS Account") then begin
                            COGSAccount := GenPostingSetup."COGS Account";
                            GLEntry.SetRange("G/L Account No.", GenPostingSetup."COGS Account");
                            GLEntry.SetRange("Posting Date", SalesCrHdr."Posting Date");
                            GLEntry.SetRange("Document No.", SalesCrHdr."No.");
                            if GLEntry.FindSet() then
                                repeat
                                    COGSAmount := COGSAmount + GLEntry.Amount;
                                until GLEntry.Next() = 0;
                        end;
                    until SalesCrLine.Next() = 0;
                end;
                ExcelBuffer.AddColumn(COGSAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
            until SalesCrHdr.Next() = 0;

        //Create Total Line
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        CurrentExcelRow := ExcelBuffer."Row No.";
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SUM(J5:J' + Format(CurrentExcelRow) + ')', true, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        LastRowNoICSuppliesData := ExcelBuffer."Row No.";

        SheetName := 'IC supplies';
        CreateNewExcelSheet(true, SheetName);
    end;

    procedure CreateExportSuppliesSheet()
    var
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
        Country: Record "Country/Region";
        Item: Record Item;
        GenPostingSetup: Record "General Posting Setup";
        GLEntry: Record "G/L Entry";
        VATBusPostingGroup: Record "VAT Business Posting Group";
        COGSAmount: Decimal;
        COGSAccount: Code[20];
        CurrentExcelRow: Decimal;
        SheetName: Text[250];
    begin
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('Export supplies from the Netherlands', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;

        //Create Excel table Headers
        ExcelBuffer.AddColumn('Invoice Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SKU Level', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer Name (Sold to)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Goods shipped to (country)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Incoterm', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Quantity', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Nett Weight', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Product commodity code (GN Code)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount in Currency', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount in EUR', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Currency Code', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange Rate for return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT statement on invoice', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Remarks', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Related COS in Euro', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        SalesInvHdr.Reset();
        SalesInvLine.Reset();
        SalesInvHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        SalesInvHdr.SetFilter("VAT Bus. Posting Group", ExportSuppliesSheetVATFilter);
        if SalesInvHdr.FindSet() then
            repeat
                //Create Excel table Data
                //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                ExcelBuffer.NewRow; //Row 5
                ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                SalesInvLine.SetCurrentKey("Document No.", "Line No.");
                SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                if SalesInvLine.FindFirst() then
                    ExcelBuffer.AddColumn(SalesInvLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(SalesInvHdr."Sell-to Customer Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if Country.Get(SalesInvHdr."Ship-to Country/Region Code") then
                    ExcelBuffer.AddColumn(Country.Name, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(SalesInvHdr."Shipment Method Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesInvLine.FindFirst() then begin
                    ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(SalesInvLine."Net Weight", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    if Item.Get(SalesInvLine."No.") then
                        ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end else begin
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;
                SalesInvHdr.CalcFields("Amount Including VAT");
                ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                if SalesInvHdr."Currency Factor" <> 0 then
                    if GLSetup."LCY Code" = 'EUR' then
                        ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT" / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                    else
                        ExcelBuffer.AddColumn('<Manually calculation needed since Company setup is not in EUR>', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number)
                else
                    ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                if SalesInvHdr."Currency Code" <> '' then
                    ExcelBuffer.AddColumn(SalesInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesInvHdr."Currency Factor" <> 0 then
                    if GLSetup."LCY Code" = 'EUR' then
                        ExcelBuffer.AddColumn(SalesInvHdr."Currency Factor", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number)
                    else
                        ExcelBuffer.AddColumn('<Manually enter Exchange Rate since Company setup is not in EUR>', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                if SalesInvLine.FindFirst() then
                    ExcelBuffer.AddColumn(SalesInvLine."VAT %", false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number);
                if VATBusPostingGroup.Get(SalesInvHdr."VAT Bus. Posting Group") then
                    ExcelBuffer.AddColumn(VATBusPostingGroup."order Confirmation Footer Text", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesInvLine.FindSet() then begin
                    COGSAmount := 0;
                    COGSAccount := '';
                    repeat
                        GenPostingSetup.SetRange("Gen. Bus. Posting Group", SalesInvLine."Gen. Bus. Posting Group");
                        GenPostingSetup.SetRange("Gen. Prod. Posting Group", SalesInvLine."Gen. Prod. Posting Group");
                        if (GenPostingSetup.FindFirst()) and (GenPostingSetup."COGS Account" <> '') and (COGSAccount <> GenPostingSetup."COGS Account") then begin
                            COGSAccount := GenPostingSetup."COGS Account";
                            GLEntry.SetRange("G/L Account No.", GenPostingSetup."COGS Account");
                            GLEntry.SetRange("Posting Date", SalesInvHdr."Posting Date");
                            GLEntry.SetRange("Document No.", SalesInvHdr."No.");
                            if GLEntry.FindSet() then
                                repeat
                                    COGSAmount := COGSAmount + GLEntry.Amount;
                                until GLEntry.Next() = 0;
                        end;
                    until SalesInvLine.Next() = 0;
                end;
                ExcelBuffer.AddColumn(COGSAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
            until SalesInvHdr.Next() = 0;

        SalesCrHdr.Reset();
        SalesCrLine.Reset();
        SalesCrHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        SalesCrHdr.SetFilter("VAT Bus. Posting Group", ExportSuppliesSheetVATFilter);
        if SalesCrHdr.FindSet() then
            repeat
                //Create Excel table Data
                //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                ExcelBuffer.NewRow;
                ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                ExcelBuffer.AddColumn(SalesCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                SalesCrLine.SetCurrentKey("Document No.", "Line No.");
                SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                SalesCrLine.SetRange(Type, SalesCrLine.Type::Item);
                if SalesCrLine.FindFirst() then
                    ExcelBuffer.AddColumn(SalesCrLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(SalesCrHdr."Sell-to Customer Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if Country.Get(SalesCrHdr."Ship-to Country/Region Code") then
                    ExcelBuffer.AddColumn(Country.Name, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn(SalesCrHdr."Ship-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(SalesCrHdr."Shipment Method Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesCrLine.FindFirst() then begin
                    ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(SalesCrLine."Net Weight", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    if Item.Get(SalesCrLine."No.") then
                        ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end else begin
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                end;
                SalesCrHdr.CalcFields("Amount Including VAT");
                ExcelBuffer.AddColumn(-SalesCrHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                if SalesCrHdr."Currency Factor" <> 0 then
                    if GLSetup."LCY Code" = 'EUR' then
                        ExcelBuffer.AddColumn(-SalesCrHdr."Amount Including VAT" / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                    else
                        ExcelBuffer.AddColumn('<Manually calculation needed since Company setup is not in EUR>', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number)
                else
                    ExcelBuffer.AddColumn(-SalesCrHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                if SalesCrHdr."Currency Code" <> '' then
                    ExcelBuffer.AddColumn(SalesCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesCrHdr."Currency Factor" <> 0 then
                    if GLSetup."LCY Code" = 'EUR' then
                        ExcelBuffer.AddColumn(SalesCrHdr."Currency Factor", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number)
                    else
                        ExcelBuffer.AddColumn('<Manually enter Exchange Rate since Company setup is not in EUR>', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                if SalesCrLine.FindFirst() then
                    ExcelBuffer.AddColumn(SalesCrLine."VAT %", false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number);
                if VATBusPostingGroup.Get(SalesInvHdr."VAT Bus. Posting Group") then
                    ExcelBuffer.AddColumn(VATBusPostingGroup."order Confirmation Footer Text", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if SalesCrLine.FindSet() then begin
                    COGSAmount := 0;
                    COGSAccount := '';
                    repeat
                        GenPostingSetup.SetRange("Gen. Bus. Posting Group", SalesCrLine."Gen. Bus. Posting Group");
                        GenPostingSetup.SetRange("Gen. Prod. Posting Group", SalesCrLine."Gen. Prod. Posting Group");
                        if (GenPostingSetup.FindFirst()) and (GenPostingSetup."COGS Account" <> '') and (COGSAccount <> GenPostingSetup."COGS Account") then begin
                            COGSAccount := GenPostingSetup."COGS Account";
                            GLEntry.SetRange("G/L Account No.", GenPostingSetup."COGS Account");
                            GLEntry.SetRange("Posting Date", SalesCrHdr."Posting Date");
                            GLEntry.SetRange("Document No.", SalesCrHdr."No.");
                            if GLEntry.FindSet() then
                                repeat
                                    COGSAmount := COGSAmount + GLEntry.Amount;
                                until GLEntry.Next() = 0;
                        end;
                    until SalesCrLine.Next() = 0;
                end;
                ExcelBuffer.AddColumn(COGSAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
            until SalesCrHdr.Next() = 0;

        //Create Total Line
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        CurrentExcelRow := ExcelBuffer."Row No.";
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SUM(K5:K' + Format(CurrentExcelRow) + ')', true, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        LastRowNoExportSuppliesData := ExcelBuffer."Row No.";

        SheetName := 'Export supplies';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateNLSuppliesSheet()
    var
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
        Item: Record Item;
        GenPostingSetup: Record "General Posting Setup";
        GLEntry: Record "G/L Entry";
        COGSAmount: Decimal;
        COGSAccount: Code[20];
        CurrentExcelRow: Decimal;
        SheetName: Text[250];
    begin
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('Sales with Dutch VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;

        //Create Excel table Headers
        ExcelBuffer.AddColumn('Invoice Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Buyers VAT Number (Sold to)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer Name (Sold to)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Product / GN-code/ service', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Quantity', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice Amount Excl. VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Amount', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Perc.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice Amount Incl. VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Remarks', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Related COS in Euro', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        SalesInvHdr.Reset();
        SalesInvLine.Reset();
        SalesInvHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        if SalesInvHdr.FindSet then
            repeat
                SalesInvHdr.CalcFields(Amount, "Amount Including VAT");
                if SalesInvHdr.Amount <> SalesInvHdr."Amount Including VAT" then begin
                    //Create Excel table Data
                    //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                    ExcelBuffer.NewRow;
                    ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                    ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if SalesInvHdr."VAT Registration No." <> '' then
                        ExcelBuffer.AddColumn(SalesInvHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('n/a', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    SalesInvLine.SetCurrentKey("Document No.", "Line No.");
                    SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                    SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                    if SalesInvLine.FindFirst() then begin
                        if Item.Get(SalesInvLine."No.") then
                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    end else begin
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    end;
                    ExcelBuffer.AddColumn(SalesInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT" - SalesInvHdr.Amount, false, '#,##0.00', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(Round((SalesInvHdr."Amount Including VAT" - SalesInvHdr.Amount) / SalesInvHdr.Amount, 0.01, '='), false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if SalesInvLine.FindSet then begin
                        COGSAmount := 0;
                        COGSAccount := '';
                        repeat
                            GenPostingSetup.SetRange("Gen. Bus. Posting Group", SalesInvLine."Gen. Bus. Posting Group");
                            GenPostingSetup.SetRange("Gen. Prod. Posting Group", SalesInvLine."Gen. Prod. Posting Group");
                            if (GenPostingSetup.FindFirst()) and (GenPostingSetup."COGS Account" <> '') and (COGSAccount <> GenPostingSetup."COGS Account") then begin
                                COGSAccount := GenPostingSetup."COGS Account";
                                GLEntry.SetRange("G/L Account No.", GenPostingSetup."COGS Account");
                                GLEntry.SetRange("Posting Date", SalesInvHdr."Posting Date");
                                GLEntry.SetRange("Document No.", SalesInvHdr."No.");
                                if GLEntry.FindSet then
                                    repeat
                                        COGSAmount := COGSAmount + GLEntry.Amount;
                                    until GLEntry.Next() = 0;
                            end;
                        until SalesInvLine.Next() = 0;
                    end;
                    ExcelBuffer.AddColumn(COGSAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                end;
            until SalesInvHdr.Next() = 0;

        SalesCrHdr.Reset();
        SalesCrLine.Reset();
        SalesCrHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        if SalesCrHdr.FindSet then
            repeat
                SalesCrHdr.CalcFields(Amount, "Amount Including VAT");
                if SalesCrHdr.Amount <> SalesCrHdr."Amount Including VAT" then begin
                    //Create Excel table Data
                    //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                    ExcelBuffer.NewRow;
                    ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                    ExcelBuffer.AddColumn(SalesCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if SalesCrHdr."VAT Registration No." <> '' then
                        ExcelBuffer.AddColumn(SalesCrHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('n/a', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesCrHdr."Sell-to Customer Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    SalesCrLine.SetCurrentKey("Document No.", "Line No.");
                    SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                    SalesCrLine.SetRange(Type, SalesCrLine.Type::Item);
                    if SalesCrLine.FindFirst() then begin
                        if Item.Get(SalesCrLine."No.") then
                            ExcelBuffer.AddColumn(Item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    end else begin
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    end;
                    ExcelBuffer.AddColumn(-SalesCrHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(-(SalesCrHdr."Amount Including VAT" - SalesCrHdr.Amount), false, '#,##0.00', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(Round((SalesCrHdr."Amount Including VAT" - SalesCrHdr.Amount) / SalesCrHdr.Amount, 0.01, '='), false, '', false, false, false, '0%', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(-SalesCrHdr."Amount Including VAT", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if SalesCrLine.FindSet then begin
                        COGSAmount := 0;
                        COGSAccount := '';
                        repeat
                            GenPostingSetup.SetRange("Gen. Bus. Posting Group", SalesCrLine."Gen. Bus. Posting Group");
                            GenPostingSetup.SetRange("Gen. Prod. Posting Group", SalesCrLine."Gen. Prod. Posting Group");
                            if (GenPostingSetup.FindFirst()) and (GenPostingSetup."COGS Account" <> '') and (COGSAccount <> GenPostingSetup."COGS Account") then begin
                                COGSAccount := GenPostingSetup."COGS Account";
                                GLEntry.SetRange("G/L Account No.", GenPostingSetup."COGS Account");
                                GLEntry.SetRange("Posting Date", SalesCrHdr."Posting Date");
                                GLEntry.SetRange("Document No.", SalesCrHdr."No.");
                                if GLEntry.FindSet then
                                    repeat
                                        COGSAmount := COGSAmount + GLEntry.Amount;
                                    until GLEntry.Next() = 0;
                            end;
                        until SalesCrLine.Next() = 0;
                    end;
                    ExcelBuffer.AddColumn(COGSAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                end;
            until SalesCrHdr.Next() = 0;


        //Create Total Line
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        CurrentExcelRow := ExcelBuffer."Row No.";
        LastRowNoNLSuppliesData := ExcelBuffer."Row No.";
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SUM(G5:G' + Format(CurrentExcelRow) + ')', true, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('SUM(H5:H' + Format(CurrentExcelRow) + ')', true, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);

        SheetName := 'NL supplies VAT';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateImportsinNLSheet()
    var
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrLine: Record "Purch. Cr. Memo Line";
        TotalTaxableAmount: Decimal;
        TotalVATAmount: Decimal;
        CurrentExcelRow: Decimal;
        SheetName: Text[250];
    begin
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('Import of goods in the Netherlands', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;

        //Create Excel table Headers
        ExcelBuffer.AddColumn('Date clearance', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Reference No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Name customs agent', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT number customs agent', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN-code goods', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty in Kg', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Import value', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Import duties', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total Taxable amount', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        PurchInvHdr.Reset();
        PurchInvHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        if PurchInvHdr.FindSet() then
            repeat
                //Create Excel table Data
                //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                ExcelBuffer.NewRow;
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                ExcelBuffer.AddColumn(PurchInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                PurchInvHdr.CalcFields(Amount, "Amount Including VAT");
                if PurchInvHdr.Amount <> PurchInvHdr."Amount Including VAT" then begin
                    ExcelBuffer.AddColumn(PurchInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    TotalTaxableAmount := TotalTaxableAmount + PurchInvHdr.Amount;
                    TotalVATAmount := TotalVATAmount + (PurchInvHdr."Amount Including VAT" - PurchInvHdr.Amount);
                end else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.AddColumn(PurchInvHdr."Buy-from Vendor Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
            until PurchInvHdr.NEXT = 0;

        PurchCrHdr.Reset();
        PurchCrHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        if PurchCrHdr.FINDSET then
            repeat
                //Create Excel table Data
                //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                ExcelBuffer.NewRow;
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                ExcelBuffer.AddColumn(PurchCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                PurchCrHdr.CALCFIELDS(Amount, "Amount Including VAT");
                if PurchCrHdr.Amount <> PurchCrHdr."Amount Including VAT" then begin
                    ExcelBuffer.AddColumn(-PurchCrHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    TotalTaxableAmount := TotalTaxableAmount - PurchCrHdr.Amount;
                    TotalVATAmount := TotalVATAmount - (PurchCrHdr."Amount Including VAT" - PurchCrHdr.Amount);
                end else
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.AddColumn(PurchCrHdr."Buy-from Vendor Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
            until PurchInvHdr.NEXT = 0;

        //Create Total Line
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        CurrentExcelRow := ExcelBuffer."Row No.";
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SUM(I5:I' + Format(CurrentExcelRow) + ')', true, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        CurrentExcelRow := ExcelBuffer."Row No.";
        LastRowNoImportsNLData := ExcelBuffer."Row No.";
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        if TotalTaxableAmount <> 0 then
            ExcelBuffer.AddColumn(Round(TotalVATAmount / TotalTaxableAmount, 0.01, '='), false, '', true, false, false, '0%', ExcelBuffer."Cell Type"::Number)
        else
            ExcelBuffer.AddColumn(0, false, '', true, false, false, '0%', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('I' + Format(CurrentExcelRow) + '*H' + Format(CurrentExcelRow + 1), true, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);

        SheetName := 'Imports in NL';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateNoSalesSheet()
    var
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
        GenPostingSetup: Record "General Posting Setup";
        GLEntry: Record "G/L Entry";
        CurrentExcelRow: Decimal;
        SheetName: Text[250];
        COGSAmount: Decimal;
        COGSAccount: Code[20];
    begin
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('No Sales', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;

        //Create Excel table Headers
        ExcelBuffer.AddColumn('Invoice Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer/Supplier', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount in Currency', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Curr.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount in Euro', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Quantity', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT statement on invoice', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Remarks', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Related COS in Euro', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        SalesInvHdr.Reset();
        SalesInvLine.Reset();
        SalesInvHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        if SalesInvHdr.FindSet() then
            repeat
                SalesInvHdr.CalcFields(Amount, "Amount Including VAT");
                if SalesInvHdr.Amount = 0 then begin
                    //Create Excel table Data
                    //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                    ExcelBuffer.NewRow;
                    ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                    ExcelBuffer.AddColumn(SalesInvHdr."Sell-to Customer Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if SalesInvHdr."Currency Code" <> '' then
                        ExcelBuffer.AddColumn(SalesInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    SalesInvLine.SetCurrentKey("Document No.", "Line No.");
                    SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                    SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                    if SalesInvLine.FindSet() then begin
                        COGSAmount := 0;
                        COGSAccount := '';
                        repeat
                            GenPostingSetup.SetRange("Gen. Bus. Posting Group", SalesInvLine."Gen. Bus. Posting Group");
                            GenPostingSetup.SetRange("Gen. Prod. Posting Group", SalesInvLine."Gen. Prod. Posting Group");
                            if (GenPostingSetup.FindFirst()) and (GenPostingSetup."COGS Account" <> '') and (COGSAccount <> GenPostingSetup."COGS Account") then begin
                                COGSAccount := GenPostingSetup."COGS Account";
                                GLEntry.SetRange("G/L Account No.", GenPostingSetup."COGS Account");
                                GLEntry.SetRange("Posting Date", SalesInvHdr."Posting Date");
                                GLEntry.SetRange("Document No.", SalesInvHdr."No.");
                                if GLEntry.FindSet() then
                                    repeat
                                        COGSAmount := COGSAmount + GLEntry.Amount;
                                    until GLEntry.NEXT = 0;
                            end;
                        until SalesInvLine.Next() = 0;
                    end;
                    ExcelBuffer.AddColumn(COGSAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                end;
            until SalesInvHdr.Next() = 0;

        SalesCrHdr.Reset();
        SalesCrLine.Reset();
        SalesCrHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
        if SalesCrHdr.FindSet() then
            repeat
                SalesCrHdr.CalcFields(Amount, "Amount Including VAT");
                if SalesCrHdr.Amount = 0 then begin
                    //Create Excel table Data
                    //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
                    ExcelBuffer.NewRow;
                    ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                    ExcelBuffer.AddColumn(SalesCrHdr."Sell-to Customer Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(-SalesCrHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if SalesCrHdr."Currency Code" <> '' then
                        ExcelBuffer.AddColumn(SalesCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(-SalesCrHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    SalesCrLine.SetCurrentKey("Document No.", "Line No.");
                    SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                    SalesCrLine.SetRange(Type, SalesCrLine.Type::Item);
                    if SalesCrLine.FindSet() then begin
                        COGSAmount := 0;
                        COGSAccount := '';
                        repeat
                            GenPostingSetup.SetRange("Gen. Bus. Posting Group", SalesCrLine."Gen. Bus. Posting Group");
                            GenPostingSetup.SetRange("Gen. Prod. Posting Group", SalesCrLine."Gen. Prod. Posting Group");
                            if (GenPostingSetup.FindFirst()) and (GenPostingSetup."COGS Account" <> '') and (COGSAccount <> GenPostingSetup."COGS Account") then begin
                                COGSAccount := GenPostingSetup."COGS Account";
                                GLEntry.SetRange("G/L Account No.", GenPostingSetup."COGS Account");
                                GLEntry.SetRange("Posting Date", SalesCrHdr."Posting Date");
                                GLEntry.SetRange("Document No.", SalesCrHdr."No.");
                                if GLEntry.FindSet() then
                                    repeat
                                        COGSAmount := COGSAmount + GLEntry.Amount;
                                    until GLEntry.Next() = 0;
                            end;
                        until SalesCrLine.Next() = 0;
                    end;
                    ExcelBuffer.AddColumn(COGSAmount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                end;
            until SalesCrHdr.Next() = 0;

        SheetName := 'No Sales';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateInputVATSheet()
    var
        CurrentExcelRow: Decimal;
        SheetName: Text[250];
    begin
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('Deductable Dutch input-VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;

        //Create Excel table Headers
        ExcelBuffer.AddColumn('Invoice Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplier Name', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplier Invoice No.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount in Euro (excl. VAT)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Amount in Euro', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount in Euro (incl. VAT)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        //Create Total Line
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        CurrentExcelRow := ExcelBuffer."Row No.";
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SUM(D5:D6)', true, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('SUM(E5:E6)', true, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
        LastRowNoInputVATData := ExcelBuffer."Row No.";

        SheetName := 'Input VAT';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateVATReturnSheet()
    var
        CurrentExcelRow: Decimal;
        SheetName: Text[250];
        Formula: Text;
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        /*
        SheetName1: TextConst
            ENU = 'NL supplies VAT';
        SheetName2: TextConst
            ENU = 'Export supplies';
        SheetName3: TextConst
            ENU = 'IC supplies';
        SheetName4: TextConst
            ENU = 'Imports in NL';
        SheetName5: TextConst
            ENU = 'Input VAT';
        */
        SheetName1: Label 'NL supplies VAT';
        SheetName2: Label 'Export supplies';
        SheetName3: Label 'IC supplies';
        SheetName4: Label 'Imports in NL';
        SheetName5: Label 'Input VAT';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        Character := 39; //39 = '
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;

        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT number: ' + CompanyInfo."VAT Registration No.", false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Info for VAT tax return', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn("Month/Quarter Text" + ' ' + Format(Year), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('1   Supplies and/or services in this country', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Amount on which VAT is charged', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('1a  Supplies/services taxed at 21%', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        Formula := 'SUMIF(' + Character + SheetName1 + Character + '!I5:I' + Format(LastRowNoNLSuppliesData) + ',21%,' + Character + SheetName1 + Character + '!G5:G' + Format(LastRowNoNLSuppliesData) + ')';
        ExcelBuffer.AddColumn(Formula, true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('D10*21%', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('1b  Supplies/services taxed at 9%', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        Formula := 'SUMIF(' + Character + SheetName1 + Character + '!I5:I' + Format(LastRowNoNLSuppliesData) + ',9%,' + Character + SheetName1 + Character + '!G5:G' + Format(LastRowNoNLSuppliesData) + ')';
        ExcelBuffer.AddColumn(Formula, true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('D12*9%', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('1c  Supplies/services taxed at other rates', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('except 0%', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('1d  Private use', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('1e  Supplies/services taxed at 0% or for which tax is not levied on you', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('2   Reverse charging mechanisms: VAT has been reverse-charged to you', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('2a  Supplies/services taxed for which the levying of', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT has been reverse-charged to you', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('3   Supplies to another country (from the Netherlands)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('3a  Supplies to countries outside the EU (export)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        Formula := Character + SheetName2 + Character + '!K' + Format(LastRowNoExportSuppliesData);
        ExcelBuffer.AddColumn(Formula, true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('3b  Supplies to/services in countries inside the EU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        Formula := Character + SheetName3 + Character + '!J' + Format(LastRowNoICSuppliesData);
        ExcelBuffer.AddColumn(Formula, true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('3b  Supplies to/services in countries inside the EU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('4   Supplies from another country (to the Netherlands)', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('4a  Supplies/services from countries outside the EU (import)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        Formula := Character + SheetName4 + Character + '!I' + Format(LastRowNoImportsNLData);
        ExcelBuffer.AddColumn(Formula, true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('D36*9%', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('4b  Acquisitions of goods/services from countries inside the EU', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('5   Calculation of VAT', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('5a Sales tax owed', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SUM(F10:F38)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('5b Advance tax', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        Formula := 'F36+' + Character + SheetName5 + Character + '!E' + Format(LastRowNoInputVATData);
        ExcelBuffer.AddColumn(Formula, true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('5c Subtotal', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('F42-F44', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('5d Deduction for small businesses', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('5e Estimated on previous VAT return(s)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('5f  Estimated on this VAT return', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('5g Total', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('€', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SUM(F46:F52)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);

        SheetName := 'VAT return';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateICPSheet()
    var
        Customer: Record Customer;
        Formula: Text;
        CurrentExcelRow: Decimal;
        SheetName: Text[250];
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //SheetName1: TextConst
        //    ENU = 'IC supplies';
        SheetName1: Label 'IC supplies';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        Character := 39; //39 = '

        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn(CompanyInfo.Name, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('IC supplies listings ' + "Month/Quarter Text" + ' ' + Format(Year), false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.NewRow;
        ExcelBuffer.AddColumn('Customer Name', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Buyers VAT Number', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;

        Customer.Reset();
        Customer.SetRange("VAT Bus. Posting Group", 'EU B2B');
        if Customer.FindSet() then
            repeat
                ExcelBuffer.AddColumn(Customer.Name, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                if Customer."VAT Registration No." <> '' then
                    ExcelBuffer.AddColumn(Customer."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                else
                    ExcelBuffer.AddColumn('n/a', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                Formula := 'SUMIF(' + Character + SheetName1 + Character + '!D:D,A' + Format(ExcelBuffer."Row No.") + ',' + Character + SheetName1 + Character + '!H:H)';
                ExcelBuffer.AddColumn(Formula, true, '', false, false, false, '_([$EUR] * #,##0.00_)', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.NewRow;
            until Customer.NEXT = 0;
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('SUM(C7:C' + Format(ExcelBuffer."Row No." - 1) + ')', true, '', true, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);

        SheetName := 'ICP';
        CreateNewExcelSheet(false, SheetName);
    end;

    trigger OnPostReport()
    begin
        ExcelBuffer.CloseBook;
        ExcelBuffer.SetFriendlyFilename(CompanyInfo.Name + 'Tax upload ' + "Month/Quarter Text" + ' ' + Format(Year));
        ExcelBuffer.OpenExcel;
    end;

    //Global Variables
    var
        StartDate: Date;
        endDate: Date;
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company InFormation";
        ExcelBuffer: Record "Excel Buffer";
        "Month/Quarter Text": Text[10];
        Year: Integer;
        LastRowNoICSuppliesData: Integer;
        LastRowNoExportSuppliesData: Integer;
        LastRowNoNLSuppliesData: Integer;
        LastRowNoImportsNLData: Integer;
        LastRowNoInputVATData: Integer;
        ICSuppliesSheetVATFilter: Code[2048];
        ExportSuppliesSheetVATFilter: Code[2048];
        Character: Char;
}