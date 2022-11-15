report 50014 "Create Backorder"

//  RHE-TNA 16-11-2021 BDS-5676
//  - Modified trigger OnPostReport()

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

//  RHE-TNA 03-03-2022 BDS-5564
//  - Modified trigger OnPostReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("New Sales Order No."; NewSalesOrderNo)
                    {
                        ApplicationArea = All;

                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        /*
        ErrorText001: textconst
            ENU = 'You need to enter a Sales Order No. for which to create a Backorder.';
        ErrorText002: textconst
            ENU = 'Process canceled.';
        DialogText001: textconst
            ENU = 'No new Sales Order No. is entered, do you want an automatic Sales Order No. to be generated?';
        */
        ErrorText001: Label 'You need to enter a Sales Order No. for which to create a Backorder.';
        ErrorText002: Label 'Process canceled.';
        DialogText001: Label 'No new Sales Order No. is entered, do you want an automatic Sales Order No. to be generated?';
        //RHE-TNA 21-01-2022 BDS-6037 END

    begin
        if CurrSalesOrderNo = '' then
            Error(Errortext001);
        if NewSalesOrderNo = '' then
            if not Confirm(DialogText001) then
                Error(ErrorText002);
        SalesSetup.Get();
        SalesSetup.TestField("Order Nos.");
    end;

    trigger OnPostReport()
    var
        NewSalesHdr: Record "Sales Header";
        NewSalesLine: Record "Sales Line";
        CurrSalesHdr: Record "Sales Header";
        CurrSalesLine: Record "Sales Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DialogText001Text: Text[250];
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        /*
        ErrorText001: TextConst
            ENU = 'No Sales Order is found with number: %1.';
        ErrorText002: TextConst
            ENU = 'No Sales Order is created.';
        DialogText001: TextConst
            ENU = 'Do you want to open the created order? Order No.: ';
        */
        ErrorText001: Label 'No Sales Order is found with number: %1.';
        ErrorText002: Label 'No Sales Order is created.';
        DialogText001: Label 'Do you want to open the created order? Order No.: ';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        CurrSalesHdr.SetRange("Document Type", CurrSalesHdr."Document Type"::Order);
        CurrSalesHdr.SetRange("No.", CurrSalesOrderNo);
        if CurrSalesHdr.FindFirst() then begin
            //Create Sales Order Header
            NewSalesHdr.Copy(CurrSalesHdr, false);
            if NewSalesOrderNo <> '' then
                NewSalesHdr."No." := NewSalesOrderNo
            else
                NewSalesHdr."No." := NoSeriesMgt.GetNextNo(SalesSetup."Order Nos.", Today, true);
            NewSalesHdr.Status := NewSalesHdr.Status::Open;
            NewSalesHdr.Insert();
            NewSalesHdr.Validate("Order Date", Today);
            NewSalesHdr.Validate("Posting Date", Today);
            NewSalesHdr.Validate("Shipment Date", Today);
            NewSalesHdr.Validate("Document Date", Today);
            NewSalesHdr."Posting Description" := 'Order' + NewSalesHdr."No.";
            NewSalesHdr."No. Printed" := 0;
            NewSalesHdr."No. of Archived Versions" := 0;
            //Validate Currency code to get correct Currency Factor
            NewSalesHdr.Validate("Currency Code", CurrSalesHdr."Currency Code");
            NewSalesHdr."Package Tracking No." := '';
            NewSalesHdr.Ship := false;
            NewSalesHdr.Invoice := false;
            NewSalesHdr."Print Posted Documents" := false;
            NewSalesHdr."Shipping No." := '';
            NewSalesHdr."Posting No." := '';
            NewSalesHdr."Last Shipping No." := '';
            NewSalesHdr."Last Posting No." := '';
            NewSalesHdr."Prepayment No." := '';
            NewSalesHdr."Last Prepayment No." := '';
            NewSalesHdr."Prepmt. Cr. Memo No." := '';
            NewSalesHdr."Last Prepmt. Cr. Memo No." := '';
            NewSalesHdr."Reason Code" := 'BACKORDER';
            //RHE-TNA 03-03-2022 BDS-5564 BEGIN
            NewSalesHdr."Completely Allocated" := false;
            //RHE-TNA 03-03-2022 BDS-5564 END
            //RHE-TNA 16-11-10-2021 BDS-5676 BEGIN
            NewSalesHdr."EDI status" := NewSalesHdr."EDI status"::" ";
            //RHE-TNA 16-11-2021 BDS-5676 END
            NewSalesHdr.Modify();

            //Create Sales Order Lines
            CurrSalesLine.SetRange("Document Type", CurrSalesLine."Document Type"::Order);
            CurrSalesLine.SetRange("Document No.", CurrSalesOrderNo);
            if CurrSalesLine.FindSet() then
                repeat
                    NewSalesLine.Copy(CurrSalesLine, false);
                    NewSalesLine."Document No." := NewSalesHdr."No.";
                    NewSalesLine."Qty. to Invoice" := 0;
                    NewSalesLine."Qty. to Invoice (Base)" := 0;
                    NewSalesLine."Qty. to Ship" := 0;
                    NewSalesLine."Qty. to Ship (Base)" := 0;
                    NewSalesLine."Qty. Shipped Not Invoiced" := 0;
                    NewSalesLine."Qty. Shipped Not Invd. (Base)" := 0;
                    NewSalesLine."Shipped Not Invoiced (LCY)" := 0;
                    NewSalesLine."Shipped Not Invoiced" := 0;
                    NewSalesLine."Quantity Shipped" := 0;
                    NewSalesLine."Qty. Shipped (Base)" := 0;
                    NewSalesLine."Quantity Invoiced" := 0;
                    NewSalesLine."Qty. Invoiced (Base)" := 0;
                    NewSalesLine."Outstanding Quantity" := NewSalesLine.Quantity;
                    NewSalesLine."Outstanding Qty. (Base)" := NewSalesLine."Quantity (Base)";
                    NewSalesLine."Shipment No." := '';
                    NewSalesLine."Shipment Line No." := 0;
                    NewSalesLine."Purchase Order No." := '';
                    NewSalesLine."Purch. Order Line No." := 0;
                    NewSalesLine."Reserved Quantity" := 0;
                    NewSalesLine."Reserved Qty. (Base)" := 0;
                    NewSalesLine."Whse. Outstanding Qty." := 0;
                    NewSalesLine."Whse. Outstanding Qty. (Base)" := 0;
                    NewSalesLine.Planned := false;
                    NewSalesLine."Prepmt. Amt. Inv." := 0;
                    NewSalesLine."Prepmt. Amt. Incl. VAT" := 0;
                    NewSalesLine."Prepayment Amount" := 0;
                    NewSalesLine."Prepmt. VAT Base Amt." := 0;
                    NewSalesLine."Prepmt. Amount Inv. Incl. VAT" := 0;
                    NewSalesLine."Prepmt. Amount Inv. (LCY)" := 0;
                    NewSalesLine."Prepmt. VAT Amount Inv. (LCY)" := 0;
                    NewSalesLine.Insert();
                    NewSalesLine.Validate("Planned Delivery Date", Today);
                    NewSalesLine.Validate("Shipment Date", Today);
                    NewSalesLine.Modify();
                    //Validate Quantity and Line Discount to recalculate Outstanding Amounts
                    if CurrSalesLine.Quantity <> 0 then
                        NewSalesLine.Validate(Quantity, CurrSalesLine.Quantity);
                    if CurrSalesLine."Line Discount %" <> 0 then
                        NewSalesLine.Validate("Line Discount %", CurrSalesLine."Line Discount %");
                    NewSalesLine.Modify();
                until CurrSalesLine.Next() = 0;
        end else
            Error(ErrorText001, CurrSalesOrderNo);

        DialogText001Text := DialogText001 + NewSalesHdr."No.";
        NewSalesHdr.Reset();
        NewSalesHdr.SetRange("Document Type", NewSalesHdr."Document Type"::Order);
        NewSalesHdr.SetRange("No.", NewSalesHdr."No.");
        if NewSalesHdr.FindFirst() then
            if Confirm(DialogText001Text) then
                Page.Run(page::"Sales Order", NewSalesHdr)
            else
                exit
        else
            Message(ErrorText002);
    end;

    procedure SetParameters(Var SalesOrderNo: code[20])
    begin
        CurrSalesOrderNo := SalesOrderNo;
    end;

    //Global variables
    var
        CurrSalesOrderNo: code[20];
        NewSalesOrderNo: code[20];
        SalesSetup: Record "Sales & Receivables Setup";
}