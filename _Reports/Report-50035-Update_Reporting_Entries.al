report 50035 "Update Reporting Entries"

//  RHE-TNA 11-01-2021 BDS-4835
//  - New report

//  RHE-TNA 19-02-2021 BDS-4989
//  - Modified trigger OnPreReport()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreReport()

//  RHE-TNA 10-01-2022 BDS-5994
//  - Modified trigger OnPreReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    trigger OnInitReport()
    begin
        AnalysisViewCodeText := 'RAS_REPORT';
    end;

    trigger OnPreReport()
    var
        AnalysisEntry: Record "Item Analysis View Entry";
        Company: Record Company;
        IFSetup: Record "Interface Setup";
        SalesShipmentHdr: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        TransferShipmentHdr: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
        SalesHdrArchive: Record "Sales Header Archive";
        SalesHdr: Record "Sales Header";
        ReturnRcptHdr: Record "Return Receipt Header";
        ReturnRcptLine: Record "Return Receipt Line";
        PurchRcptHdr: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnShptHdr: Record "Return Shipment Header";
        ReturnShptLine: Record "Return Shipment Line";
        IssuedReminderHdr: Record "Issued Reminder Header";
        ValueEntry: Record "Value Entry";
        CurrDateTime: DateTime;
        PredefinedCust: Boolean;
    begin
        AnalysisEntry.SetRange("Analysis View Code", AnalysisViewCodeText);
        AnalysisEntry.DeleteAll();

        CurrDateTime := CurrentDateTime;

        Company.FindSet();
        repeat
            IFSetup.ChangeCompany(Company.Name);
            //RHE-TNA 14-06-2021 BDS-5337 BEGIN
            //IFSetup.Get();
            //RHE-TNA 14-06-2021 BDS-5337 END
            //Data for shipped orders
            SalesShipmentHdr.ChangeCompany(Company.Name);
            if SalesShipmentHdr.FindSet() then begin
                SalesShipmentLine.ChangeCompany(Company.Name);
                repeat
                    //RHE-TNA 19-02-2021 BDS-4989 BEGIN
                    //Only create a record for sales shipments with a shipped quantity (exclude when only GL order lines were posted)
                    SalesShipmentLine.SetRange("Document No.", SalesShipmentHdr."No.");
                    SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
                    SalesShipmentLine.SetFilter(Quantity, '<>%1', 0);
                    if SalesShipmentLine.FindSet() then begin
                        //RHE-TNA 19-02-2021 BDS-4989 END
                        AnalysisEntry.Init();
                        AnalysisEntry."Analysis Area" := AnalysisEntry."Analysis Area"::Sales;
                        AnalysisEntry."Analysis View Code" := AnalysisViewCodeText;
                        AnalysisEntry."Source Type" := AnalysisEntry."Source Type"::Customer;
                        AnalysisEntry."Source No." := SalesShipmentHdr."Sell-to Customer No.";
                        AnalysisEntry."Location Code" := SalesShipmentHdr."Location Code";
                        AnalysisEntry."Posting Date" := SalesShipmentHdr."Posting Date";
                        AnalysisEntry."Entry No." := GetNextAnalysisEntryNo();
                        AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::Sale;
                        //RHE-TNA 19-02-2021 BDS-4989 BEGIN
                        //SalesShipmentLine.SetRange("Document No.", SalesShipmentHdr."No.");
                        //SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
                        //RHE-TNA 19-02-2021 BDS-4989 END
                        AnalysisEntry.Quantity := SalesShipmentLine.Count;
                        AnalysisEntry."Qty." := AnalysisEntry.Quantity;
                        AnalysisEntry."Reporting Entry No." := AnalysisEntry."Entry No.";
                        AnalysisEntry.Company := Company.Name;
                        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                        //if (SalesShipmentHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2B") and (SalesShipmentHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2C") then
                        //        AnalysisEntry.Name := SalesShipmentHdr."Sell-to Customer Name";
                        PredefinedCust := true;
                        IFSetup.SetRange(Type, IFSetup.Type::Customer);
                        IFSetup.SetRange(Active, true);
                        if IFSetup.FindSet() then
                            repeat
                                if not ((SalesShipmentHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2B") and (SalesShipmentHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2C")) then
                                    PredefinedCust := false;
                            until IFSetup.Next() = 0;
                        if PredefinedCust = true then
                            AnalysisEntry.Name := SalesShipmentHdr."Sell-to Customer Name";
                        //RHE-TNA 14-06-2021 BDS-5337 END
                        AnalysisEntry."Shipping Agent" := SalesShipmentHdr."Shipping Agent Code";
                        AnalysisEntry."Ship-to Country" := SalesShipmentHdr."Ship-to Country/Region Code";
                        AnalysisEntry.Status := 'Shipped';
                        AnalysisEntry.Return := 'No';
                        AnalysisEntry."Document No." := SalesShipmentHdr."No.";
                        AnalysisEntry."Last Updated" := CurrDateTime;
                        if StrPos(SalesShipmentHdr."VAT Bus. Posting Group", 'B2B') > 0 then
                            AnalysisEntry."B2B/B2C" := 'B2B'
                        else
                            if StrPos(SalesShipmentHdr."VAT Bus. Posting Group", 'B2C') > 0 then
                                AnalysisEntry."B2B/B2C" := 'B2C';
                        //RHE-TNA 10-01-2022 BDS-5994 BEGIN
                        AnalysisEntry."Source Document No." := SalesShipmentHdr."Order No.";
                        //RHE-TNA 10-01-2022 BDS-5994 END
                        AnalysisEntry.Insert();
                        //RHE-TNA 19-02-2021 BDS-4989 BEGIN
                    end;
                    //RHE-TNA 19-02-2021 BDS-4989 END
                until SalesShipmentHdr.Next() = 0;
            end;

            //Data for shipped transfer orders
            TransferShipmentHdr.ChangeCompany(Company.Name);
            TransferShipmentHdr.SetFilter("Transfer-from Code", 'CEN*');
            if TransferShipmentHdr.FindSet() then begin
                TransferShipmentLine.ChangeCompany(Company.Name);
                repeat
                    AnalysisEntry.Init();
                    AnalysisEntry."Analysis Area" := AnalysisEntry."Analysis Area"::Sales;
                    AnalysisEntry."Analysis View Code" := AnalysisViewCodeText;
                    AnalysisEntry."Source Type" := AnalysisEntry."Source Type"::" ";
                    AnalysisEntry."Source No." := TransferShipmentHdr."Transfer-to Code";
                    AnalysisEntry."Location Code" := TransferShipmentHdr."Transfer-from Code";
                    AnalysisEntry."Posting Date" := TransferShipmentHdr."Posting Date";
                    AnalysisEntry."Entry No." := GetNextAnalysisEntryNo();
                    AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::Transfer;
                    TransferShipmentLine.SetRange("Document No.", TransferShipmentHdr."No.");
                    AnalysisEntry.Quantity := TransferShipmentLine.Count;
                    AnalysisEntry."Qty." := AnalysisEntry.Quantity;
                    AnalysisEntry."Reporting Entry No." := AnalysisEntry."Entry No.";
                    AnalysisEntry.Company := Company.Name;
                    AnalysisEntry.Name := TransferShipmentHdr."Transfer-to Name";
                    AnalysisEntry."Shipping Agent" := TransferShipmentHdr."Shipping Agent Code";
                    AnalysisEntry."Ship-to Country" := TransferShipmentHdr."Trsf.-to Country/Region Code";
                    AnalysisEntry.Status := 'Shipped';
                    AnalysisEntry.Return := 'No';
                    AnalysisEntry."Document No." := TransferShipmentHdr."No.";
                    AnalysisEntry."Last Updated" := CurrDateTime;
                    //RHE-TNA 10-01-2022 BDS-5994 BEGIN
                    AnalysisEntry."Source Document No." := TransferShipmentHdr."Transfer Order No.";
                    //RHE-TNA 10-01-2022 BDS-5994 END
                    AnalysisEntry.Insert();
                until TransferShipmentHdr.Next() = 0;
            end;

            //Data for archived orders
            SalesHdrArchive.ChangeCompany(Company.Name);
            SalesHdrArchive.SetFilter("Reason Code", '<>%1', '');
            if SalesHdrArchive.FindSet() then
                repeat
                    AnalysisEntry.Init();
                    AnalysisEntry."Analysis Area" := AnalysisEntry."Analysis Area"::Sales;
                    AnalysisEntry."Analysis View Code" := AnalysisViewCodeText;
                    AnalysisEntry."Source Type" := AnalysisEntry."Source Type"::Customer;
                    AnalysisEntry."Source No." := SalesHdrArchive."Sell-to Customer No.";
                    AnalysisEntry."Posting Date" := SalesHdrArchive."Date Archived";
                    AnalysisEntry."Entry No." := GetNextAnalysisEntryNo();
                    AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::Sale;
                    AnalysisEntry."Reporting Entry No." := AnalysisEntry."Entry No.";
                    AnalysisEntry.Company := Company.Name;
                    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                    //if (SalesHdrArchive."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2B") and (SalesHdrArchive."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2C") then
                    //    AnalysisEntry.Name := SalesHdrArchive."Sell-to Customer Name";
                    PredefinedCust := true;
                    IFSetup.SetRange(Type, IFSetup.Type::Customer);
                    IFSetup.SetRange(Active, true);
                    if IFSetup.FindSet() then
                        repeat
                            if not ((SalesHdrArchive."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2B") and (SalesHdrArchive."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2C")) then
                                PredefinedCust := false;
                        until IFSetup.Next() = 0;
                    if PredefinedCust = true then
                        AnalysisEntry.Name := SalesHdrArchive."Sell-to Customer Name";
                    //RHE-TNA 14-06-2021 BDS-5337 END
                    AnalysisEntry."Shipping Agent" := SalesHdrArchive."Shipping Agent Code";
                    AnalysisEntry."Ship-to Country" := SalesHdrArchive."Ship-to Country/Region Code";
                    AnalysisEntry.Status := 'Canceled';
                    AnalysisEntry.Return := 'No';
                    AnalysisEntry."Document No." := SalesHdrArchive."No.";
                    AnalysisEntry."Last Updated" := CurrDateTime;
                    AnalysisEntry."Reason Code" := SalesHdrArchive."Reason Code";
                    if StrPos(SalesHdrArchive."VAT Bus. Posting Group", 'B2B') > 0 then
                        AnalysisEntry."B2B/B2C" := 'B2B'
                    else
                        if StrPos(SalesHdrArchive."VAT Bus. Posting Group", 'B2C') > 0 then
                            AnalysisEntry."B2B/B2C" := 'B2C';
                    //RHE-TNA 10-01-2022 BDS-5994 BEGIN
                    AnalysisEntry."Source Document No." := SalesHdrArchive."No.";
                    //RHE-TNA 10-01-2022 BDS-5994 END
                    AnalysisEntry.Insert();
                until SalesHdrArchive.Next() = 0;

            //Data for open Sales Orders
            SalesHdr.ChangeCompany(Company.Name);
            SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
            if SalesHdr.FindSet() then
                repeat
                    AnalysisEntry.Init();
                    AnalysisEntry."Analysis Area" := AnalysisEntry."Analysis Area"::Sales;
                    AnalysisEntry."Analysis View Code" := AnalysisViewCodeText;
                    AnalysisEntry."Source Type" := AnalysisEntry."Source Type"::Customer;
                    AnalysisEntry."Source No." := SalesHdr."Sell-to Customer No.";
                    AnalysisEntry."Location Code" := SalesHdr."Location Code";
                    AnalysisEntry."Posting Date" := SalesHdr."Document Date";
                    AnalysisEntry."Entry No." := GetNextAnalysisEntryNo();
                    AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::Sale;
                    AnalysisEntry."Reporting Entry No." := AnalysisEntry."Entry No.";
                    AnalysisEntry.Company := Company.Name;
                    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                    //if (SalesHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2B") and (SalesHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2C") then
                    //    AnalysisEntry.Name := SalesHdr."Sell-to Customer Name";
                    PredefinedCust := true;
                    IFSetup.SetRange(Type, IFSetup.Type::Customer);
                    IFSetup.SetRange(Active, true);
                    if IFSetup.FindSet() then
                        repeat
                            if not ((SalesHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2B") and (SalesHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2C")) then
                                PredefinedCust := false;
                        until IFSetup.Next() = 0;
                    if PredefinedCust = true then
                        AnalysisEntry.Name := SalesHdr."Sell-to Customer Name";
                    //RHE-TNA 14-06-2021 BDS-5337 END
                    AnalysisEntry."Shipping Agent" := SalesHdr."Shipping Agent Code";
                    AnalysisEntry."Ship-to Country" := SalesHdr."Ship-to Country/Region Code";
                    AnalysisEntry.Status := Format(SalesHdr.Status);
                    AnalysisEntry.Return := 'No';
                    AnalysisEntry."Document No." := SalesHdr."No.";
                    AnalysisEntry."Last Updated" := CurrDateTime;
                    if StrPos(SalesHdr."VAT Bus. Posting Group", 'B2B') > 0 then
                        AnalysisEntry."B2B/B2C" := 'B2B'
                    else
                        if StrPos(SalesHdr."VAT Bus. Posting Group", 'B2C') > 0 then
                            AnalysisEntry."B2B/B2C" := 'B2C';
                    //RHE-TNA 10-01-2022 BDS-5994 BEGIN
                    AnalysisEntry."Source Document No." := SalesHdr."No.";
                    //RHE-TNA 10-01-2022 BDS-5994 END
                    AnalysisEntry.Insert();
                until SalesHdr.Next() = 0;

            //Data for Sales return orders received
            ReturnRcptHdr.ChangeCompany(Company.Name);
            if ReturnRcptHdr.FindSet() then begin
                ReturnRcptLine.ChangeCompany(Company.Name);
                repeat
                    AnalysisEntry.Init();
                    AnalysisEntry."Analysis Area" := AnalysisEntry."Analysis Area"::Sales;
                    AnalysisEntry."Analysis View Code" := AnalysisViewCodeText;
                    AnalysisEntry."Source Type" := AnalysisEntry."Source Type"::Customer;
                    AnalysisEntry."Source No." := ReturnRcptHdr."Sell-to Customer No.";
                    AnalysisEntry."Location Code" := ReturnRcptHdr."Location Code";
                    AnalysisEntry."Posting Date" := ReturnRcptHdr."Posting Date";
                    AnalysisEntry."Entry No." := GetNextAnalysisEntryNo();
                    AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::Sale;
                    ReturnRcptLine.SetRange("Document No.", ReturnRcptHdr."No.");
                    ReturnRcptLine.SetRange(Type, ReturnRcptLine.Type::Item);
                    AnalysisEntry.Quantity := ReturnRcptLine.Count;
                    AnalysisEntry."Qty." := AnalysisEntry.Quantity;
                    AnalysisEntry."Reporting Entry No." := AnalysisEntry."Entry No.";
                    AnalysisEntry.Company := Company.Name;
                    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                    //if (ReturnRcptHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2B") and (ReturnRcptHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2C") then
                    //    AnalysisEntry.Name := ReturnRcptHdr."Sell-to Customer Name";
                    PredefinedCust := true;
                    IFSetup.SetRange(Type, IFSetup.Type::Customer);
                    IFSetup.SetRange(Active, true);
                    if IFSetup.FindSet() then
                        repeat
                            if not ((ReturnRcptHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2B") and (ReturnRcptHdr."Sell-to Customer No." <> IFSetup."Order Import Cust. No. B2C")) then
                                PredefinedCust := false;
                        until IFSetup.Next() = 0;
                    if PredefinedCust = true then
                        AnalysisEntry.Name := ReturnRcptHdr."Sell-to Customer Name";
                    //RHE-TNA 14-06-2021 BDS-5337 END
                    AnalysisEntry."Shipping Agent" := ReturnRcptHdr."Shipping Agent Code";
                    AnalysisEntry."Ship-to Country" := ReturnRcptHdr."Ship-to Country/Region Code";
                    AnalysisEntry.Status := 'Received';
                    AnalysisEntry.Return := 'Yes';
                    AnalysisEntry."Document No." := ReturnRcptHdr."No.";
                    AnalysisEntry."Last Updated" := CurrDateTime;
                    if StrPos(ReturnRcptHdr."VAT Bus. Posting Group", 'B2B') > 0 then
                        AnalysisEntry."B2B/B2C" := 'B2B'
                    else
                        if StrPos(ReturnRcptHdr."VAT Bus. Posting Group", 'B2C') > 0 then
                            AnalysisEntry."B2B/B2C" := 'B2C';
                    //RHE-TNA 10-01-2022 BDS-5994 BEGIN
                    AnalysisEntry."Source Document No." := ReturnRcptHdr."Return Order No.";
                    //RHE-TNA 10-01-2022 BDS-5994 END
                    AnalysisEntry.Insert();
                until ReturnRcptHdr.Next() = 0;
            end;

            //Data for received orders
            PurchRcptHdr.ChangeCompany(Company.Name);
            if PurchRcptHdr.FindSet() then begin
                PurchRcptLine.ChangeCompany(Company.Name);
                repeat
                    AnalysisEntry.Init();
                    AnalysisEntry."Analysis Area" := AnalysisEntry."Analysis Area"::Purchase;
                    AnalysisEntry."Analysis View Code" := AnalysisViewCodeText;
                    AnalysisEntry."Source Type" := AnalysisEntry."Source Type"::Vendor;
                    AnalysisEntry."Source No." := PurchRcptHdr."Buy-from Vendor No.";
                    AnalysisEntry."Location Code" := PurchRcptHdr."Location Code";
                    AnalysisEntry."Posting Date" := PurchRcptHdr."Posting Date";
                    AnalysisEntry."Entry No." := GetNextAnalysisEntryNo();
                    AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::Purchase;
                    PurchRcptLine.SetRange("Document No.", PurchRcptHdr."No.");
                    PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
                    AnalysisEntry.Quantity := PurchRcptLine.Count;
                    AnalysisEntry."Qty." := AnalysisEntry.Quantity;
                    AnalysisEntry."Reporting Entry No." := AnalysisEntry."Entry No.";
                    AnalysisEntry.Company := Company.Name;
                    AnalysisEntry.Name := PurchRcptHdr."Buy-from Vendor Name";
                    AnalysisEntry."Ship-to Country" := PurchRcptHdr."Ship-to Country/Region Code";
                    AnalysisEntry."Buy-from Country" := PurchRcptHdr."Buy-from Country/Region Code";
                    AnalysisEntry.Status := 'Received';
                    AnalysisEntry.Return := 'No';
                    AnalysisEntry."Document No." := PurchRcptHdr."No.";
                    AnalysisEntry."Last Updated" := CurrDateTime;
                    //RHE-TNA 10-01-2022 BDS-5994 BEGIN
                    AnalysisEntry."Source Document No." := PurchRcptHdr."Order No.";
                    //RHE-TNA 10-01-2022 BDS-5994 END
                    AnalysisEntry.Insert();
                until PurchRcptHdr.Next() = 0;
            end;

            //RHE-TNA 19-02-2021 BDS-4989 BEGIN
            //Data for Purchase return orders shipped
            ReturnShptHdr.ChangeCompany(Company.Name);
            if ReturnShptHdr.FindSet() then begin
                ReturnShptLine.ChangeCompany(Company.Name);
                repeat
                    AnalysisEntry.Init();
                    AnalysisEntry."Analysis Area" := AnalysisEntry."Analysis Area"::Purchase;
                    AnalysisEntry."Analysis View Code" := AnalysisViewCodeText;
                    AnalysisEntry."Source Type" := AnalysisEntry."Source Type"::Vendor;
                    AnalysisEntry."Source No." := ReturnShptHdr."Buy-from Vendor No.";
                    AnalysisEntry."Location Code" := ReturnShptHdr."Location Code";
                    AnalysisEntry."Posting Date" := ReturnShptHdr."Posting Date";
                    AnalysisEntry."Entry No." := GetNextAnalysisEntryNo();
                    AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::Purchase;
                    ReturnShptLine.SetRange("Document No.", ReturnShptHdr."No.");
                    ReturnShptLine.SetRange(Type, ReturnShptLine.Type::Item);
                    AnalysisEntry.Quantity := ReturnShptLine.Count;
                    AnalysisEntry."Qty." := AnalysisEntry.Quantity;
                    AnalysisEntry."Reporting Entry No." := AnalysisEntry."Entry No.";
                    AnalysisEntry.Company := Company.Name;
                    AnalysisEntry.Name := ReturnShptHdr."Buy-from Vendor Name";
                    AnalysisEntry."Ship-to Country" := ReturnShptHdr."Ship-to Country/Region Code";
                    AnalysisEntry."Buy-from Country" := ReturnShptHdr."Buy-from Country/Region Code";
                    AnalysisEntry.Status := 'Shipped';
                    AnalysisEntry.Return := 'Yes';
                    AnalysisEntry."Document No." := ReturnShptHdr."No.";
                    AnalysisEntry."Last Updated" := CurrDateTime;
                    //RHE-TNA 10-01-2022 BDS-5994 BEGIN
                    AnalysisEntry."Source Document No." := ReturnShptHdr."Return Order No.";
                    //RHE-TNA 10-01-2022 BDS-5994 END
                    AnalysisEntry.Insert();
                until ReturnShptHdr.Next() = 0;
            end;
            //RHE-TNA 19-02-2021 BDS-4989 END

            //Data for issued reminders
            IssuedReminderHdr.ChangeCompany(Company.Name);
            if IssuedReminderHdr.FindSet() then
                repeat
                    AnalysisEntry.Init();
                    AnalysisEntry."Analysis Area" := AnalysisEntry."Analysis Area"::Sales;
                    AnalysisEntry."Analysis View Code" := AnalysisViewCodeText;
                    AnalysisEntry."Source Type" := AnalysisEntry."Source Type"::Customer;
                    AnalysisEntry."Source No." := IssuedReminderHdr."Customer No.";
                    AnalysisEntry."Posting Date" := IssuedReminderHdr."Posting Date";
                    AnalysisEntry."Entry No." := GetNextAnalysisEntryNo();
                    AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::Sale;
                    AnalysisEntry."Reporting Entry No." := AnalysisEntry."Entry No.";
                    AnalysisEntry.Company := Company.Name;
                    AnalysisEntry.Name := IssuedReminderHdr.Name;
                    AnalysisEntry."Ship-to Country" := IssuedReminderHdr."Country/Region Code";
                    AnalysisEntry.Status := 'Issued';
                    AnalysisEntry.Return := 'No';
                    AnalysisEntry."Document No." := IssuedReminderHdr."No.";
                    AnalysisEntry."Last Updated" := CurrDateTime;
                    AnalysisEntry.Insert();
                until IssuedReminderHdr.Next() = 0;

            //Data for inventory adjustments (pos., neg., relocates)
            ValueEntry.ChangeCompany(Company.Name);
            ValueEntry.SetFilter("Item Ledger Entry Type", '%1|%2|%3', ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.", ValueEntry."Item Ledger Entry Type"::"Negative Adjmt.", ValueEntry."Item Ledger Entry Type"::Transfer);
            ValueEntry.SetFilter("Item Ledger Entry Quantity", '<>%1', 0);
            ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::" ");
            ValueEntry.SetFilter("Document No.", '<>%1', 'START INV');
            if ValueEntry.FindSet() then
                repeat
                    AnalysisEntry.Init();
                    AnalysisEntry."Analysis Area" := AnalysisEntry."Analysis Area"::Inventory;
                    AnalysisEntry."Analysis View Code" := AnalysisViewCodeText;
                    AnalysisEntry."Item No." := ValueEntry."Item No.";
                    AnalysisEntry."Source Type" := AnalysisEntry."Source Type"::Item;
                    AnalysisEntry."Source No." := ValueEntry."Item No.";
                    AnalysisEntry."Location Code" := ValueEntry."Location Code";
                    AnalysisEntry."Posting Date" := ValueEntry."Posting Date";
                    AnalysisEntry."Entry No." := GetNextAnalysisEntryNo();
                    case ValueEntry."Item Ledger Entry Type" of
                        ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.":
                            AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::"Positive Adjmt.";
                        ValueEntry."Item Ledger Entry Type"::"Negative Adjmt.":
                            AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::"Negative Adjmt.";
                        ValueEntry."Item Ledger Entry Type"::Transfer:
                            AnalysisEntry."Item Ledger Entry Type" := AnalysisEntry."Item Ledger Entry Type"::Transfer;
                    end;
                    AnalysisEntry.Quantity := ValueEntry."Item Ledger Entry Quantity";
                    AnalysisEntry."Invoiced Quantity" := ValueEntry."Item Ledger Entry Quantity";
                    AnalysisEntry."Qty." := ValueEntry."Item Ledger Entry Quantity";
                    AnalysisEntry."Reporting Entry No." := AnalysisEntry."Entry No.";
                    AnalysisEntry."Cost Amount (Actual)" := ValueEntry."Cost Amount (Actual)";
                    AnalysisEntry."Cost Amount (Expected)" := ValueEntry."Cost Amount (Expected)";
                    AnalysisEntry."Total Cost" := AnalysisEntry."Cost Amount (Actual)";
                    AnalysisEntry.Company := Company.Name;
                    AnalysisEntry."Last Updated" := CurrDateTime;
                    AnalysisEntry."Reason Code" := ValueEntry."Reason Code";
                    AnalysisEntry.Insert();
                until ValueEntry.Next() = 0;

        until Company.Next() = 0;
    end;

    trigger OnPostReport()
    begin
        if GuiAllowed then
            Message('Done');
    end;

    procedure GetNextAnalysisEntryNo(): Integer
    var
        AnalysisViewEntry: Record "Item Analysis View Entry";
    begin
        AnalysisViewEntry.SetCurrentKey("Entry No.");
        AnalysisViewEntry.SetRange("Analysis View Code", AnalysisViewCodeText);
        if AnalysisViewEntry.FindLast() then
            exit(AnalysisViewEntry."Entry No." + 1)
        else
            exit(1);
    end;

    //Global Variables
    var
        AnalysisViewCodeText: Text[10];
}