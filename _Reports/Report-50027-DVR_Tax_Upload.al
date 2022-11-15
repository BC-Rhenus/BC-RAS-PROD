report 50027 "DVR Tax Upload"

//  RHE-TNA 12-05-2020 BDS-4145
//  - Modified function CreateOutputSheet() and CreateInputSheet();

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
                }
                group(Options)
                {
                    field("Print data on Output Sheet"; PrintOutputSheetData)
                    {
                        ApplicationArea = All;
                    }
                    field("Print data on Input Sheet"; PrintInputSheetData)
                    {
                        ApplicationArea = All;
                    }
                    field("Print data on Import Sheet"; PrintImportSheetData)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    begin
        PrintImportSheetData := true;
        PrintInputSheetData := true;
        PrintOutputSheetData := true;
    end;

    trigger OnPreReport()
    begin
        CurrReport.LANGUAGE(1033);
        GLSetup.Get();
        CompanyInfo.Get();
        Month := Format(StartDate, 0, '<Month Text>'); //Get Month of reporting period
        Year := Date2DMY(StartDate, 3);  //Get Year of reporting period

        ExcelBuffer.DeleteAll();
        CreateOutputSheet();
        CreateInputSheet();
        CreateImportSheet();
        CreateTypeOfTransactionSheet();
    end;

    procedure CreateNewExcelSheet(NewBook: Boolean; Name: Text[250])
    begin
        if NewBook then
            ExcelBuffer.CreateNewBook('Output')
        else
            ExcelBuffer.SelectorAddSheet(Name);
        ExcelBuffer.WriteSheet('', CompanyName, UserId);
        ExcelBuffer.DeleteAll();
        ExcelBuffer.ClearNewRow();
    end;

    procedure CreateOutputSheet()
    var
        CurrentExcelRow: Decimal;
        SalesInvHdr: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrHdr: Record "Sales Cr.Memo Header";
        SalesCrLine: Record "Sales Cr.Memo Line";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        VATBusPostingGroup: Record "VAT Business Posting Group";
        SheetName: Text[250];
        TotalQty: Decimal;
        TotalWeight: Decimal;
    begin
        //Create Excel table Headers
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('Type of Transaction', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice #', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('PO Number', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer Name', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Customer VAT #', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Address', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Bill to Country', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Currency', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice Amount Currency', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Amount Currency', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange Rate', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice Amount EUR', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Amount EUR', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Rate', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ship From', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ship To', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('QTY', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Weight', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN Code', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Product Specification', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Transaction Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ship Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ultimate Consignee', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Type of Transport', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Incoterm', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Statement on Invoice', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Remarks Customer', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Remarks DVR', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;

        if PrintOutputSheetData then begin
            SalesInvHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
            if SalesInvHdr.FindSet() then
                repeat
                    //Create Excel table data
                    SalesInvHdr.CalcFields(Amount, "Amount Including VAT");
                    SalesInvLine.SetCurrentKey("Document No.", "Line No.");
                    SalesInvLine.SetRange("Document No.", SalesInvHdr."No.");
                    SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                    SalesInvLine.SetFilter("No.", '<>%1', ' ');
                    if SalesInvLine.FindFirst() then begin
                        VATPostingSetup.SetRange("VAT Bus. Posting Group", SalesInvHdr."VAT Bus. Posting Group");
                        VATPostingSetup.SetRange("VAT Prod. Posting Group", SalesInvLine."VAT Prod. Posting Group");
                        if VATPostingSetup.FindFirst() then
                            ExcelBuffer.AddColumn(VATPostingSetup."DVR Transaction Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    end else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr."Order No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if SalesInvHdr."VAT Registration No." <> '' then
                        ExcelBuffer.AddColumn(SalesInvHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr."Bill-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if SalesInvHdr."Currency Code" <> '' then
                        ExcelBuffer.AddColumn(SalesInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT" - SalesInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if (SalesInvHdr."Currency Factor" <> 0) and (SalesInvHdr."Currency Code" <> 'EUR') then
                        ExcelBuffer.AddColumn(SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                    else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if (SalesInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                        ExcelBuffer.AddColumn(SalesInvHdr.Amount / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn((SalesInvHdr."Amount Including VAT" - SalesInvHdr.Amount) / SalesInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    end else
                        if (SalesInvHdr."Currency Code" = 'EUR') or (GLSetup."LCY Code" = 'EUR') then begin
                            ExcelBuffer.AddColumn(SalesInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            ExcelBuffer.AddColumn(SalesInvHdr."Amount Including VAT" - SalesInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        end else
                            if SalesInvHdr.Amount = 0 then begin
                                ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            end else begin
                                ExcelBuffer.AddColumn('<Manual calculation needed as Company Setup is not in EUR>', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                ExcelBuffer.AddColumn('<Manual calculation needed as Company Setup is not in EUR>', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            end;
                    if SalesInvHdr.Amount <> 0 then
                        ExcelBuffer.AddColumn(Round((SalesInvHdr."Amount Including VAT" - SalesInvHdr.Amount) / SalesInvHdr.Amount * 100, 1), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('0', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                    //RHE-TNA 12-05-2020 BDS-4145 BEGIN
                    //if SalesInvLine.FindFirst() then begin
                    //    ExcelBuffer.AddColumn(SalesInvLine.Quantity, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    //    if Item.Get(SalesInvLine."No.") then begin
                    //        ExcelBuffer.AddColumn(SalesInvLine.Quantity * Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    //        ExcelBuffer.AddColumn(item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    //    end else begin
                    //        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    //        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    //    end;
                    TotalQty := 0;
                    TotalWeight := 0;
                    if SalesInvLine.FindSet() then begin
                        repeat
                            if Item.Get(SalesInvLine."No.") then begin
                                TotalQty := TotalQty + SalesInvLine.Quantity;
                                TotalWeight := TotalWeight + (SalesInvLine.Quantity * Item."Gross Weight");
                            end;
                        until SalesInvLine.Next() = 0;
                        ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        if TotalWeight <> 0 then
                            ExcelBuffer.AddColumn(TotalWeight, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        //RHE-TNA 12-05-2020 BDS-4145 END
                    end else begin
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    end;
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if VATBusPostingGroup.Get(SalesInvHdr."VAT Bus. Posting Group") then
                        ExcelBuffer.AddColumn(VATBusPostingGroup."Order Confirmation Footer Text", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.NewRow();
                until SalesInvHdr.Next() = 0;

            SalesCrHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
            if SalesCrHdr.FindSet() then
                repeat
                    //Create Excel table data
                    SalesCrHdr.CalcFields(Amount, "Amount Including VAT");
                    SalesCrLine.SetCurrentKey("Document No.", "Line No.");
                    SalesCrLine.SetRange("Document No.", SalesCrHdr."No.");
                    SalesCrLine.SetRange(Type, SalesCrLine.Type::Item);
                    SalesCrLine.SetFilter("No.", '<>%1', ' ');
                    if SalesCrLine.FindFirst() then begin
                        VATPostingSetup.SetRange("VAT Bus. Posting Group", SalesCrHdr."VAT Bus. Posting Group");
                        VATPostingSetup.SetRange("VAT Prod. Posting Group", SalesCrLine."VAT Prod. Posting Group");
                        if VATPostingSetup.FindFirst() then
                            ExcelBuffer.AddColumn(VATPostingSetup."DVR Transaction Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    end else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesCrHdr."Return Order No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesCrHdr."Ship-to Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if SalesCrHdr."VAT Registration No." <> '' then
                        ExcelBuffer.AddColumn(SalesCrHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(SalesCrHdr."Bill-to Country/Region Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if SalesCrHdr."Currency Code" <> '' then
                        ExcelBuffer.AddColumn(SalesCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(-SalesCrHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(-(SalesCrHdr."Amount Including VAT" - SalesCrHdr.Amount), false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if (SalesCrHdr."Currency Factor" <> 0) and (SalesCrHdr."Currency Code" <> 'EUR') then
                        ExcelBuffer.AddColumn(SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                    else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if (SalesCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                        ExcelBuffer.AddColumn(-SalesCrHdr.Amount / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(-(SalesCrHdr."Amount Including VAT" - SalesCrHdr.Amount) / SalesCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    end else
                        if (SalesCrHdr."Currency Code" = 'EUR') or (GLSetup."LCY Code" = 'EUR') then begin
                            ExcelBuffer.AddColumn(-SalesCrHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            ExcelBuffer.AddColumn(-(SalesCrHdr."Amount Including VAT" - SalesCrHdr.Amount), false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        end else
                            if SalesCrHdr.Amount = 0 then begin
                                ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            end else begin
                                ExcelBuffer.AddColumn('<Manual calculation needed as Company Setup is not in EUR>', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                ExcelBuffer.AddColumn('<Manual calculation needed as Company Setup is not in EUR>', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            end;
                    if SalesCrHdr.Amount <> 0 then
                        ExcelBuffer.AddColumn(Round((SalesCrHdr."Amount Including VAT" - SalesCrHdr.Amount) / SalesCrHdr.Amount * 100, 1), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('0', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                    //RHE-TNA 12-05-2020 BDS-4145 BEGIN                  
                    //if SalesCrLine.FindFirst() then begin
                    //    ExcelBuffer.AddColumn(-SalesCrLine.Quantity, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    //    if Item.Get(SalesCrLine."No.") then begin
                    //        ExcelBuffer.AddColumn(-SalesCrLine.Quantity * Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    //        ExcelBuffer.AddColumn(item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    //    end else begin
                    //        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    //        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    //    end;
                    TotalQty := 0;
                    TotalWeight := 0;
                    if SalesCrLine.FindSet() then begin
                        repeat
                            if Item.Get(SalesCrLine."No.") then begin
                                TotalQty := TotalQty - SalesCrLine.Quantity;
                                TotalWeight := TotalWeight - (SalesCrLine.Quantity * Item."Gross Weight");
                            end;
                        until SalesCrLine.Next() = 0;
                        ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        if TotalWeight <> 0 then
                            ExcelBuffer.AddColumn(TotalWeight, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        //RHE-TNA 12-05-2020 BDS-4145 END
                    end else begin
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    end;
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if VATBusPostingGroup.Get(SalesCrHdr."VAT Bus. Posting Group") then
                        ExcelBuffer.AddColumn(VATBusPostingGroup."Order Confirmation Footer Text", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.NewRow();
                until SalesCrHdr.Next() = 0;
        end;

        SheetName := 'Output';
        CreateNewExcelSheet(true, SheetName);
    end;

    procedure CreateInputSheet()
    var
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrLine: Record "Purch. Cr. Memo Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        VATBusPostingGroup: Record "VAT Business Posting Group";
        SheetName: Text[250];
        TotalQty: Decimal;
        TotalWeight: Decimal;
    begin
        //Create Excel table Headers
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('Type of Transaction', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice #', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('PO Number', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplier Name', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Supplier VAT #', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Address', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Currency', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice Amount Currency', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Amount Currency', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Exchange Rate', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Invoice Amount EUR', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Amount EUR', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Rate', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ship From', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ship To', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('QTY', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Weight', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN Code', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Product Specification', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Transaction Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ship Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Type of Transport', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Incoterm', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Statement on Invoice', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Remarks Customer', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Remarks DVR', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow;

        if PrintInputSheetData then begin
            PurchInvHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
            if PurchInvHdr.FindSet() then
                repeat
                    //Create Excel table data
                    PurchInvHdr.CalcFields(Amount, "Amount Including VAT");
                    PurchInvLine.SetCurrentKey("Document No.", "Line No.");
                    PurchInvLine.SetRange("Document No.", PurchInvHdr."No.");
                    PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
                    PurchInvLine.SetFilter("No.", '<>%1', ' ');
                    if PurchInvLine.FindFirst() then begin
                        VATPostingSetup.SetRange("VAT Bus. Posting Group", PurchInvHdr."VAT Bus. Posting Group");
                        VATPostingSetup.SetRange("VAT Prod. Posting Group", PurchInvLine."VAT Prod. Posting Group");
                        if VATPostingSetup.FindFirst() then
                            ExcelBuffer.AddColumn(VATPostingSetup."DVR Transaction Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    end else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(PurchInvHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(PurchInvHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(PurchInvHdr."Order No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(PurchInvHdr."Buy-from Vendor Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if PurchInvHdr."VAT Registration No." <> '' then
                        ExcelBuffer.AddColumn(PurchInvHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if PurchInvHdr."Currency Code" <> '' then
                        ExcelBuffer.AddColumn(PurchInvHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(PurchInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(PurchInvHdr."Amount Including VAT" - PurchInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if (PurchInvHdr."Currency Factor" <> 0) and (PurchInvHdr."Currency Code" <> 'EUR') then
                        ExcelBuffer.AddColumn(PurchInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                    else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if (PurchInvHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                        ExcelBuffer.AddColumn(PurchInvHdr.Amount / PurchInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn((PurchInvHdr."Amount Including VAT" - PurchInvHdr.Amount) / PurchInvHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    end else
                        if (PurchInvHdr."Currency Code" = 'EUR') or (GLSetup."LCY Code" = 'EUR') then begin
                            ExcelBuffer.AddColumn(PurchInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            ExcelBuffer.AddColumn(PurchInvHdr."Amount Including VAT" - PurchInvHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        end else
                            if PurchInvHdr.Amount = 0 then begin
                                ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            end else begin
                                ExcelBuffer.AddColumn('<Manual calculation needed as Company Setup is not in EUR>', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                ExcelBuffer.AddColumn('<Manual calculation needed as Company Setup is not in EUR>', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            end;
                    if PurchInvHdr.Amount <> 0 then
                        ExcelBuffer.AddColumn(Round((PurchInvHdr."Amount Including VAT" - PurchInvHdr.Amount) / PurchInvHdr.Amount * 100, 1), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('0', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                    //RHE-TNA 12-05-2020 BDS-4145 BEGIN
                    //if PurchInvLine.FindFirst() then begin
                    //    ExcelBuffer.AddColumn(PurchInvLine.Quantity, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    //    if Item.Get(PurchInvLine."No.") then begin
                    //        ExcelBuffer.AddColumn(PurchInvLine.Quantity * Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    //        ExcelBuffer.AddColumn(item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    //    end else begin
                    //        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    //        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    //    end;
                    TotalQty := 0;
                    TotalWeight := 0;
                    if PurchInvLine.FindSet() then begin
                        repeat
                            if Item.Get(PurchInvLine."No.") then begin
                                TotalQty := TotalQty + PurchInvLine.Quantity;
                                TotalWeight := TotalWeight + (PurchInvLine.Quantity * Item."Gross Weight");
                            end;
                        until PurchInvLine.Next() = 0;
                        ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        if TotalWeight <> 0 then
                            ExcelBuffer.AddColumn(TotalWeight, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        //RHE-TNA 12-05-2020 BDS-4145 END
                    end else begin
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    end;
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if VATBusPostingGroup.Get(PurchInvHdr."VAT Bus. Posting Group") then
                        ExcelBuffer.AddColumn(VATBusPostingGroup."Order Confirmation Footer Text", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.NewRow();
                until PurchInvHdr.Next() = 0;

            PurchCrHdr.SetFilter("Posting Date", '%1..%2', StartDate, endDate);
            if PurchCrHdr.FindSet() then
                repeat
                    //Create Excel table data
                    PurchCrHdr.CalcFields(Amount, "Amount Including VAT");
                    PurchCrLine.SetCurrentKey("Document No.", "Line No.");
                    PurchCrLine.SetRange("Document No.", PurchCrHdr."No.");
                    PurchCrLine.SetRange(Type, PurchCrLine.Type::Item);
                    PurchCrLine.SetFilter("No.", '<>%1', ' ');
                    if PurchCrLine.FindFirst() then begin
                        VATPostingSetup.SetRange("VAT Bus. Posting Group", PurchCrHdr."VAT Bus. Posting Group");
                        VATPostingSetup.SetRange("VAT Prod. Posting Group", PurchCrLine."VAT Prod. Posting Group");
                        if VATPostingSetup.FindFirst() then
                            ExcelBuffer.AddColumn(VATPostingSetup."DVR Transaction Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    end else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(PurchCrHdr."Posting Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(PurchCrHdr."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(PurchCrHdr."Return Order No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(PurchCrHdr."Buy-from Vendor Name", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if PurchCrHdr."VAT Registration No." <> '' then
                        ExcelBuffer.AddColumn(PurchCrHdr."VAT Registration No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if PurchCrHdr."Currency Code" <> '' then
                        ExcelBuffer.AddColumn(PurchCrHdr."Currency Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn(GLSetup."LCY Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn(-PurchCrHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    ExcelBuffer.AddColumn(-(PurchCrHdr."Amount Including VAT" - PurchCrHdr.Amount), false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if (PurchCrHdr."Currency Factor" <> 0) and (PurchCrHdr."Currency Code" <> 'EUR') then
                        ExcelBuffer.AddColumn(PurchCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number)
                    else
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    if (PurchCrHdr."Currency Factor" <> 0) and (GLSetup."LCY Code" = 'EUR') then begin
                        ExcelBuffer.AddColumn(-PurchCrHdr.Amount / PurchCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn(-(PurchCrHdr."Amount Including VAT" - PurchCrHdr.Amount) / PurchCrHdr."Currency Factor", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    end else
                        if (PurchCrHdr."Currency Code" = 'EUR') or (GLSetup."LCY Code" = 'EUR') then begin
                            ExcelBuffer.AddColumn(-PurchCrHdr.Amount, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            ExcelBuffer.AddColumn(-(PurchCrHdr."Amount Including VAT" - PurchCrHdr.Amount), false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        end else
                            if PurchCrHdr.Amount = 0 then begin
                                ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            end else begin
                                ExcelBuffer.AddColumn('<Manual calculation needed as Company Setup is not in EUR>', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                                ExcelBuffer.AddColumn('<Manual calculation needed as Company Setup is not in EUR>', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                            end;
                    if PurchCrHdr.Amount <> 0 then
                        ExcelBuffer.AddColumn(Round((PurchCrHdr."Amount Including VAT" - PurchCrHdr.Amount) / PurchCrHdr.Amount * 100, 1), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                    else
                        ExcelBuffer.AddColumn('0', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

                    //RHE-TNA 12-05-2020 BDS-4145 BEGIN
                    //if PurchCrLine.FindFirst() then begin
                    //    ExcelBuffer.AddColumn(PurchCrLine.Quantity, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                    //    if Item.Get(PurchCrLine."No.") then begin
                    //        ExcelBuffer.AddColumn(PurchCrLine.Quantity * Item."Gross Weight", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    //        ExcelBuffer.AddColumn(item."Tariff No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    //    end else begin
                    //        ExcelBuffer.AddColumn(0, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                    //        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    //    end;
                    TotalQty := 0;
                    TotalWeight := 0;
                    if PurchCrLine.FindSet() then begin
                        repeat
                            if Item.Get(PurchCrLine."No.") then begin
                                TotalQty := TotalQty - PurchCrLine.Quantity;
                                TotalWeight := TotalWeight - (PurchCrLine.Quantity * Item."Gross Weight");
                            end;
                        until PurchCrLine.Next() = 0;
                        ExcelBuffer.AddColumn(TotalQty, false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        if TotalWeight <> 0 then
                            ExcelBuffer.AddColumn(TotalWeight, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text)
                        else
                            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                        //RHE-TNA 12-05-2020 BDS-4145 END
                    end else begin
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                        ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    end;
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    if VATBusPostingGroup.Get(PurchCrHdr."VAT Bus. Posting Group") then
                        ExcelBuffer.AddColumn(VATBusPostingGroup."Order Confirmation Footer Text", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    ExcelBuffer.NewRow();
                until PurchCrHdr.Next() = 0;
        end;

        SheetName := 'Input';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateImportSheet()
    var
        SheetName: Text[250];
    begin
        //Create Excel table Headers
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('Import Date', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Ref. #', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Name Importer of Record', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT # Importer of Record', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Name Customs Agent', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('EORI # Customs Agent', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Tracking #', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('GN Code', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Product Specification', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('QTY', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Weight', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Import Value', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Import Duties', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total Taxable Amount', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('VAT Amount', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Country of Origin', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Container Number', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Lot Number', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('N/A', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        SheetName := 'Import';
        CreateNewExcelSheet(false, SheetName);
    end;

    procedure CreateTypeOfTransactionSheet()
    var
        SheetName: Text[250];
    begin
        //Create Excel table Name
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('Output', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();

        //Create Excel table Headers
        ExcelBuffer.AddColumn('Type of Transaction', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Code to use', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Explanation', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total amount excl. VAT in EUR from overview', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total VAT amount in EUR from overview', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();

        //Create Excel table data
        ExcelBuffer.AddColumn('NL Supplies reversed charge', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLSRC', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Sales to a Dutch resident company with reversed VAT', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B4,Output!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B4,Output!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('NL Supplies VAT 9%', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLS9', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Sales within NL with 9% VAT', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B5,Output!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B5,Output!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('NL Supplies VAT 21%', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLS21', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Sales within NL with 21% VAT', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B6,Output!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B6,Output!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('IC Supplies', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLICG', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Sales of goods to customers from other EU countries', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B7,Output!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B7,Output!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('IC transfer of own goods', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLTRA', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Transfer of own goods within Eu', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B8,Output!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B8,Output!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Export Supplies', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLEXP', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Sales of goods to NEU customer', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B9,Output!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B9,Output!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('IC Services', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLICS', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Services provided to customers from other EU countries', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B10,Output!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B10,Output!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Warehouse/entrepot sales', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLWS', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Sales to NL warehouse', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B11,Output!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B11,Output!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('No Sales', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLNO', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Free shipments/no sales/warranty replacements', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B12,Output!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Output!A:N,B12,Output!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();

        //Create Excel table Name
        ExcelBuffer.AddColumn('Input', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();

        //Create Excel table Headers
        ExcelBuffer.AddColumn('Type of Transaction', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Code to use', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Explanation', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total amount excl. VAT in EUR from overview', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total VAT amount in EUR from overview', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();

        //Create Excel table data
        ExcelBuffer.AddColumn('IC Obtainings', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLICO', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Purchases of goods from other EU countries', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B18,Input!L:L)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B18,Input!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Warehouse/entrepot purchases', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLWP', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Purchases from NL warehouse', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B19,Input!L:L)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B19,Input!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('NL purchases VAT 21%', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLP21', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Purchases from NL with 21% VAT ', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B20,Input!L:L)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B20,Input!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('NL purchases VAT 9%', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLP9', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Purchases from NL with 9% VAT ', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B21,Input!L:L)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B21,Input!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('NL suppliees reversed charge', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('NLPRC', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Purchases from a Dutch resident company with reversed VAT ', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B22,Input!L:L)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUMIF(Input!A:M,B22,Input!M:M)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();

        //Create Excel table Name
        ExcelBuffer.AddColumn('Import', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();

        //Create Excel table Headers
        ExcelBuffer.AddColumn('Type of Transaction', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Code to use', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Explanation', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total amount excl. VAT in EUR from overview', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Total VAT amount in EUR from overview', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();

        //Create Excel table data
        ExcelBuffer.AddColumn('Imports in NL', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('N/A', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Imports from NEU countries into NL (reported in a separate sheet, so no code necessary)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUM(Import!N:N)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('=SUM(Import!O:O)', true, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Text);

        SheetName := 'Type of transaction';
        CreateNewExcelSheet(false, SheetName);

    end;

    trigger OnPostReport()
    begin
        ExcelBuffer.CloseBook;
        ExcelBuffer.SetFriendlyFilename(CompanyInfo.Name + ' DVR Tax upload ' + Format(Year));
        ExcelBuffer.OpenExcel;
    end;

    //Global Variables
    var
        StartDate: Date;
        endDate: Date;
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company InFormation";
        ExcelBuffer: Record "Excel Buffer";
        Month: Text[10];
        Year: Integer;
        LastRowNoICSuppliesData: Integer;
        LastRowNoExportSuppliesData: Integer;
        LastRowNoNLSuppliesData: Integer;
        LastRowNoImportsNLData: Integer;
        LastRowNoInputVATData: Integer;
        ICSuppliesSheetVATFilter: Code[2048];
        ExportSuppliesSheetVATFilter: Code[2048];
        Character: Char;
        PrintOutputSheetData: Boolean;
        PrintInputSheetData: Boolean;
        PrintImportSheetData: Boolean;
}