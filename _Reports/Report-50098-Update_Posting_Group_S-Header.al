report 50098 "Update Posting Group S-Headers"

//  RHE-TNA 18-12-2020 BDS-4784
//  - New report

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

//  RHE-TNA 08-02-2022 BDS-6102
//  - Removed var Carrier in trigger OnAfterGetRecord()

{
    UsageCategory = Tasks;
    UseRequestPage = true;
    ProcessingOnly = true;
    Caption = 'Update Posting Groups Sales (Return) Order';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            RequestFilterFields = "No.", "Vat Country/Region Code";
            DataItemTableView = where (Status = filter (Open));

            trigger OnAfterGetRecord()
            var
                IFSetup: Record "Interface Setup";
                Country: Record "Country/Region";
                Customer: Record Customer;
                SalesLine: Record "Sales Line";
                SalesLineType: Text[20];
                OrderType: Text[10];
            begin
                IFSetup.Get();
                OrderType := '';
                TotalCount := "Sales Header".Count;
                //Check if orders is created with generic customer ID
                if ("Sales Header"."Sell-to Customer No." = IFSetup."Order Import Cust. No. B2B") or ("Sales Header"."Sell-to Customer No." = IFSetup."Order Import Cust. No. B2C") then begin
                    Country.SetRange(Code, "Sales Header"."Ship-to Country/Region Code");
                    if Country.FindFirst() then begin
                        SalesLine.SetRange("Document Type", "Sales Header"."Document Type");
                        SalesLine.SetRange("Document No.", "Sales Header"."No.");
                        if SalesLine.FindSet() then
                            repeat
                                if "Sales Header"."Document Type" = "Sales Header"."Document Type"::Order then
                                    OrderType := 'Order';
                                if "Sales Header"."Document Type" = "Sales Header"."Document Type"::"Return Order" then
                                    OrderType := 'R.-Order';
                                SalesLineType := Format(SalesLine.Type);
                                StoreLineDetails(OrderType, SalesLine."Document No.", SalesLine."Line No.", SalesLineType, SalesLine."No.", SalesLine.Description, SalesLine.Quantity, SalesLine."VAT %", SalesLine."Unit Price", SalesLine."Line Discount %");
                            until SalesLine.Next() = 0;
                        SalesLine.DeleteAll(true);
                        //B2B orders via interface
                        if "Sales Header"."Sell-to Customer No." = IFSetup."Order Import Cust. No. B2B" then begin
                            "Sales Header".Validate("Gen. Bus. Posting Group", Country."B2B Gen. Bus. Posting Group");
                            "Sales Header".Validate("VAT Bus. Posting Group", Country."B2B VAT Bus. Posting Group");
                            "Sales Header".Modify(true);
                        end else begin
                            //B2C orders via interface
                            "Sales Header".Validate("Gen. Bus. Posting Group", Country."B2C Gen. Bus. Posting Group");
                            "Sales Header".Validate("VAT Bus. Posting Group", Country."B2C VAT Bus. Posting Group");
                            "Sales Header".Modify(true);
                        end;
                        RestoreLines("Sales Header"."No.");
                        ProcessedCount := ProcessedCount + 1;
                    end;
                end else begin
                    //Order is created with a specific customer
                    if Customer.Get("Sales Header"."Sell-to Customer No.") then begin
                        SalesLine.SetRange("Document Type", "Sales Header"."Document Type");
                        SalesLine.SetRange("Document No.", "Sales Header"."No.");
                        if SalesLine.FindSet() then
                            repeat
                                SalesLineType := Format(SalesLine.Type);
                                if "Sales Header"."Document Type" = "Sales Header"."Document Type"::Order then
                                    OrderType := 'Order';
                                if "Sales Header"."Document Type" = "Sales Header"."Document Type"::"Return Order" then
                                    OrderType := 'R.-Order';
                                StoreLineDetails(OrderType, SalesLine."Document No.", SalesLine."Line No.", SalesLineType, SalesLine."No.", SalesLine.Description, SalesLine.Quantity, SalesLine."VAT %", SalesLine."Unit Price", SalesLine."Line Discount %");
                            until SalesLine.Next() = 0;
                        SalesLine.DeleteAll(true);
                        "Sales Header".Validate("Gen. Bus. Posting Group", Customer."Gen. Bus. Posting Group");
                        "Sales Header".Validate("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
                        "Sales Header".Validate("Customer Posting Group", Customer."Customer Posting Group");
                        "Sales Header".Modify(true);
                        RestoreLines("Sales Header"."No.");
                        ProcessedCount := ProcessedCount + 1;
                    end;
                end;
            end;
        }
    }

    procedure StoreLineDetails(Ordertype: Text[10]; OrderNo: Code[20]; LineNo: integer; Type: Text[20]; No: code[20]; Description: Text[100]; Qty: Decimal; VATPerc: Decimal; Price: Decimal; DiscountPerc: Decimal)
    var
        ExcelBuffer: Record "Excel Buffer";
    begin
        if ExcelBuffer.FindLast() then
            ExcelBuffer.SetCurrent(ExcelBuffer."Row No.", ExcelBuffer."Column No.");

        ExcelBuffer.NewRow;
        //Excelbuffer variables: Value,Formula,Comment text,Bold,Italic,Underline,NumFormat,Celltype
        ExcelBuffer.AddColumn('R50098', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(OrderNo, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(LineNo, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Type, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(No, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Description, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Qty, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(VATPerc, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(Price, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(DiscountPerc, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(Ordertype, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
    end;

    procedure RestoreLines(OrderNo: Code[20])
    var
        ExcelBuffer: Record "Excel Buffer";
        ExcelBuffer2: Record "Excel Buffer";
        SalesLine: Record "Sales Line";
    begin
        ExcelBuffer.SetRange("Cell Value as Text", OrderNo);
        if ExcelBuffer.FindSet() then
            repeat
                ExcelBuffer2.SetRange("Row No.", ExcelBuffer."Row No.");
                ExcelBuffer2.SetRange("Column No.", 1);
                if (ExcelBuffer2.FindFirst()) and (ExcelBuffer2."Cell Value as Text" = 'R50098') then begin
                    SalesLine.Init();
                    //Add Document Type
                    ExcelBuffer2.SetRange("Column No.", 11);
                    ExcelBuffer2.FindFirst();
                    if ExcelBuffer2."Cell Value as Text" = 'Order' then
                        SalesLine."Document Type" := SalesLine."Document Type"::Order;
                    if ExcelBuffer2."Cell Value as Text" = 'R.-Order' then
                        SalesLine."Document Type" := SalesLine."Document Type"::"Return Order";
                    ExcelBuffer2.SetRange("Column No.", 2);
                    ExcelBuffer2.FindFirst();
                    SalesLine."Document No." := ExcelBuffer2."Cell Value as Text";
                    //Add Line no.
                    ExcelBuffer2.SetRange("Column No.", 3);
                    ExcelBuffer2.FindFirst();
                    Evaluate(SalesLine."Line No.", ExcelBuffer2."Cell Value as Text");
                    SalesLine.Validate("Line No.", SalesLine."Line No.");
                    SalesLine.Insert(true);
                    //Add line type
                    ExcelBuffer2.SetRange("Column No.", 4);
                    ExcelBuffer2.FindFirst();
                    if ExcelBuffer2."Cell Value as Text" = 'Item' then
                        SalesLine.Validate(Type, SalesLine.Type::Item);
                    if ExcelBuffer2."Cell Value as Text" = 'G/L Account' then
                        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                    if ExcelBuffer2."Cell Value as Text" = '' then
                        SalesLine.Validate(Type, SalesLine.Type::" ");
                    //Add No.
                    ExcelBuffer2.SetRange("Column No.", 5);
                    ExcelBuffer2.FindFirst();
                    if SalesLine.Type <> SalesLine.Type::" " then begin
                        Evaluate(SalesLine."No.", ExcelBuffer2."Cell Value as Text");
                        SalesLine.Validate("No.", SalesLine."No.");
                    end;
                    //Add Description
                    ExcelBuffer2.SetRange("Column No.", 6);
                    ExcelBuffer2.FindFirst();
                    SalesLine.Description := ExcelBuffer2."Cell Value as Text";
                    //Add qty
                    ExcelBuffer2.SetRange("Column No.", 7);
                    ExcelBuffer2.FindFirst();
                    if SalesLine.Type <> SalesLine.Type::" " then begin
                        Evaluate(SalesLine.Quantity, ExcelBuffer2."Cell Value as Text");
                        SalesLine.Validate(Quantity, SalesLine.Quantity);
                    end;
                    //Add VAT%
                    //ExcelBuffer2.SetRange("Column No.", 8);
                    //ExcelBuffer2.FindFirst();
                    //if SalesLine.Type <> SalesLine.Type::" " then begin
                    //    Evaluate(SalesLine."VAT %", ExcelBuffer2."Cell Value as Text");
                    //    SalesLine.Validate("VAT %", SalesLine."VAT %");
                    //end;
                    //Add Unit Price
                    ExcelBuffer2.SetRange("Column No.", 9);
                    ExcelBuffer2.FindFirst();
                    if SalesLine.Type <> SalesLine.Type::" " then begin
                        Evaluate(SalesLine."Unit Price", ExcelBuffer2."Cell Value as Text");
                        SalesLine.Validate("Unit Price", SalesLine."Unit Price");
                    end;
                    //Add Discount %
                    ExcelBuffer2.SetRange("Column No.", 10);
                    ExcelBuffer2.FindFirst();
                    if SalesLine.Type <> SalesLine.Type::" " then begin
                        Evaluate(SalesLine."Line Discount %", ExcelBuffer2."Cell Value as Text");
                        SalesLine.Validate("Line Discount %", SalesLine."Line Discount %");
                    end;
                    SalesLine.Modify(true);
                    ExcelBuffer2.Reset();
                    ExcelBuffer2.SetRange("Row No.", ExcelBuffer."Row No.");
                    ExcelBuffer2.DeleteAll();
                end;
            until ExcelBuffer.Next() = 0;
    end;

    trigger OnPostReport()
    begin
        if GuiAllowed then
            Message(Text001, ProcessedCount, TotalCount);
    end;

    var
        TotalCount: Integer;
        ProcessedCount: Integer;
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //Text001: TextConst
        //    ENU = 'Orders processed / Total orders in filter: %1 / %2.';
        Text001: Label 'Orders processed / Total orders in filter: %1 / %2.';
        //RHE-TNA 21-01-2022 BDS-6037 END
}