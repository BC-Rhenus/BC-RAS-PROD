report 50031 "Process WMS Inventory"

//  RHE-TNA 21-07-2020 BDS-4323
//  - New Report

//  RHE-TNA 09-12-2020..01-02-2021 BDS-4324
//  - Modified trigger OnPreReport()
//  - Modified procedure ProcessItemJnl(): Text[250]

//  RHE-TNA 05-03-2021 BDS-5075
//  - Modified trigger OnPostReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
    begin
        if GuiAllowed then
            if not Dialog.Confirm('Are you sure you want to process the Inventory differences?') then
                Error('Process canceled');
        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
        if not WMSLocationSetup.FindFirst() then
            Error('A record of Type = Warehouse must exist in table WMS Inventory Location Setup');
    end;

    trigger OnPostReport()
    var
        ReasonCode: Record "Reason Code";
        ErrorOccured: Boolean;
    begin
        WMSInvRec.SetRange(Process, true);
        WMSInvRec.SetRange(Approved, true);
        if WMSInvRec.FindSet() then
            repeat
                WMSInvRec.Error := false;
                WMSInvRec."Error Text" := '';

                if WMSInvRec."Reason Code" = '' then
                    WMSInvRec."Error Text" := 'Reason Code must have a value.';
                if not ReasonCode.Get(WMSInvRec."Reason Code") then
                    WMSInvRec."Error Text" := 'Reason Code does not exist.';

                if WMSInvRec."Error Text" = '' then begin
                    if ((WMSInvRec."Transaction Code" = WMSInvRec."Transaction Code"::"Cond Update") or (WMSInvRec."Transaction Code" = WMSInvRec."Transaction Code"::"Inventory Lock") or (WMSInvRec."Transaction Code" = WMSInvRec."Transaction Code"::"Inventory Unlock")) and (WMSInvRec."From Location Code" <> WMSInvRec."To Location Code") then
                        if WMSInvRec."WMS Qty." <= CalcInventory() then
                            WMSInvRec."Error Text" := ProcessReclassification()
                        else
                            WMSInvRec."Error Text" := 'Not enough inventory on Location Code: ' + WMSInvRec."From Location Code" + ' to process line.';

                    if WMSInvRec."Transaction Code" = WMSInvRec."Transaction Code"::Adjustment then begin
                        if WMSInvRec."WMS Qty." < 0 then
                            if Abs(WMSInvRec."WMS Qty.") <= CalcInventory() then
                                WMSInvRec."Error Text" := ProcessItemJnl()
                            else
                                WMSInvRec."Error Text" := 'Not enough inventory on Location Code: ' + WMSInvRec."From Location Code" + ' to process line.'
                        else
                            WMSInvRec."Error Text" := ProcessItemJnl();
                    end;

                    //RHE-TNA 09-12-2020..01-02-2021 BDS-4324 BEGIN
                    if WMSInvRec."Transaction Code" = WMSInvRec."Transaction Code"::"Stock Level" then begin
                        if WMSInvRec."Inv. Level Difference" < 0 then
                            if Abs(WMSInvRec."Inv. Level Difference") <= CalcInventory() then
                                WMSInvRec."Error Text" := ProcessItemJnl()
                            else
                                WMSInvRec."Error Text" := 'Not enough inventory on Location Code: ' + WMSInvRec."From Location Code" + ' to process line.'
                        else
                            if WMSInvRec."Inv. Level Difference" > 0 then
                                WMSInvRec."Error Text" := ProcessItemJnl();
                    end;
                    //RHE-TNA 09-12-2020..01-02-2021 BDS-4324 END
                end;

                //Update Import Record
                //RHE-TNA 12-03-2021 BDS-5075 BEGIN
                //if WMSInvRec."Error Text" <> '' then
                if WMSInvRec."Error Text" <> '' then begin
                    //RHE-TNA 12-03-2021 BDS-5075 END
                    WMSInvRec.Error := true;
                    ErrorOccured := true;
                    //RHE-TNA 12-03-2021 BDS-5075 BEGIN
                end;
                //RHE-TNA 12-03-2021 BDS-5075 END
                WMSInvRec.Process := false;
                WMSInvRec."Processed by User" := UserId;
                WMSInvRec."Processed Date" := Today;
                WMSInvRec.Modify(false);
                Commit();
            until WMSInvRec.Next() = 0;

        if GuiAllowed then
            //RHE-TNA 12-03-2021 BDS-5075 BEGIN
            if ErrorOccured then
                Message('Records processed with errors.')
            else
                //RHE-TNA 12-03-2021 BDS-5075 END
                Message('Records processed.');
    end;

    procedure ProcessReclassification(): Text[250]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlTemplate: Record "Item Journal Template";
        ResEntry: Record "Reservation Entry";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJnlPost: Codeunit "Item Jnl.-Post";
        OK: Boolean;
    begin
        ItemJnlBatch.SetRange("Use for WMS Inventory Reclass.", true);
        if not ItemJnlBatch.FindFirst() then
            Error('No Item Journal Batch is setup to process Reclassification(s).');
        ItemJnlTemplate.Get(ItemJnlBatch."Journal Template Name");
        if (ReclassDocNo = '') and (ItemJnlBatch."No. Series" <> '') then
            ReclassDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", Today, false)
        else
            //Temporary clear No. Series to make posting with same document no. possible
            if ItemJnlBatch."No. Series" <> '' then begin
                NoSeriesReclassJnl := ItemJnlBatch."No. Series";
                ItemJnlBatch."No. Series" := '';
                ItemJnlBatch.Modify(false);
            end;

        ResEntry.SetRange("Source ID", ItemJnlBatch."Journal Template Name");
        ResEntry.SetRange("Source Batch Name", ItemJnlBatch.Name);
        ResEntry.DeleteAll(true);

        ItemJnlLine.SetRange("Journal Template Name", ItemJnlBatch."Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlBatch.Name);
        ItemJnlLine.DeleteAll(true);

        ItemJnlLine.Init();
        ItemJnlLine.Validate("Journal Template Name", ItemJnlBatch."Journal Template Name");
        ItemJnlLine.Validate("Journal Batch Name", ItemJnlBatch.Name);
        ItemJnlLine.Validate("Line No.", 10000);
        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Transfer);
        ItemJnlLine.Validate("Source Code", ItemJnlTemplate."Source Code");
        ItemJnlLine.Insert(true);
        ItemJnlLine.Validate("Document No.", ReclassDocNo);
        ItemJnlLine.Validate("Item No.", WMSInvRec."Item No.");
        ItemJnlLine.Validate("Posting Date", WMSInvRec."Transaction Date");
        ItemJnlLine.Validate("Location Code", WMSInvRec."From Location Code");
        ItemJnlLine.Validate("New Location Code", WMSInvRec."To Location Code");
        ItemJnlLine.Validate(Quantity, WMSInvRec."WMS Qty.");
        ItemJnlLine.Validate("Reason Code", WMSInvRec."Reason Code");
        ItemJnlLine.Validate(HideDialog, true);
        ItemJnlLine.Modify(true);

        if WMSInvRec."Lot No." <> '' then
            CreateReservationEntry(ItemJnlLine, WMSInvRec."Lot No.", '', WMSInvRec."Expiry Date");
        if WMSInvRec."Serial No." <> '' then
            CreateReservationEntry(ItemJnlLine, '', WMSInvRec."Serial No.", WMSInvRec."Expiry Date");

        //Post Reclass. Journal, Post per line to have a new inventory starting point for the next WMS Inventory record
        Commit();
        OK := ItemJnlPost.Run(ItemJnlLine);
        Clear(ItemJnlPost);

        //Enter No. Series which was deleted.
        if ItemJnlBatch."No. Series" = '' then begin
            ItemJnlBatch."No. Series" := NoSeriesReclassJnl;
            ItemJnlBatch.Modify(false);
        end;

        if not OK then
            exit(GetLastErrorText);
    end;

    procedure ProcessItemJnl(): Text[250]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlTemplate: Record "Item Journal Template";
        ResEntry: Record "Reservation Entry";
        ILE: Record "Item Ledger Entry";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJnlPost: Codeunit "Item Jnl.-Post";
        OK: Boolean;
    begin
        ItemJnlBatch.SetRange("Use for WMS Inventory Adj.", true);
        if not ItemJnlBatch.FindFirst() then
            Error('No Item Journal Batch is setup to process Adjustments.');
        ItemJnlTemplate.Get(ItemJnlBatch."Journal Template Name");
        if (AdjustmentDocNo = '') and (ItemJnlBatch."No. Series" <> '') then
            AdjustmentDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", Today, false)
        else
            //Temporary clear No. Series to make posting with same document no. possible
            if ItemJnlBatch."No. Series" <> '' then begin
                NoSeriesAdjustmentJnl := ItemJnlBatch."No. Series";
                ItemJnlBatch."No. Series" := '';
                ItemJnlBatch.Modify(false);
            end;

        ResEntry.SetRange("Source ID", ItemJnlBatch."Journal Template Name");
        ResEntry.SetRange("Source Batch Name", ItemJnlBatch.Name);
        ResEntry.DeleteAll(true);

        ItemJnlLine.SetRange("Journal Template Name", ItemJnlBatch."Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlBatch.Name);
        ItemJnlLine.DeleteAll(true);

        ItemJnlLine.Init();
        ItemJnlLine.Validate("Journal Template Name", ItemJnlBatch."Journal Template Name");
        ItemJnlLine.Validate("Journal Batch Name", ItemJnlBatch.Name);
        ItemJnlLine.Validate("Line No.", 10000);
        //RHE-TNA 09-12-2020 BDS-4324 BEGIN
        //if WMSInvRec."WMS Qty." > 0 then
        //    ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
        //else
        //    ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
        if WMSInvRec."Transaction Code" = WMSInvRec."Transaction Code"::"Stock Level" then begin
            if WMSInvRec."Inv. Level Difference" > 0 then
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
            else
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");

        end else begin
            if WMSInvRec."WMS Qty." > 0 then
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
            else
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
        end;
        //RHE-TNA 09-12-2020 BDS-4324 END
        ItemJnlLine.Validate("Source Code", ItemJnlTemplate."Source Code");
        ItemJnlLine.Insert(true);
        ItemJnlLine.Validate("Document No.", AdjustmentDocNo);
        ItemJnlLine.Validate("Item No.", WMSInvRec."Item No.");
        ItemJnlLine.Validate("Posting Date", WMSInvRec."Transaction Date");
        ItemJnlLine.Validate("Location Code", WMSInvRec."From Location Code");
        //RHE-TNA 09-12-2020 BDS-4324 BEGIN
        //ItemJnlLine.Validate(Quantity, Abs(WMSInvRec."WMS Qty."));
        if WMSInvRec."Transaction Code" = WMSInvRec."Transaction Code"::"Stock Level" then
            ItemJnlLine.Validate(Quantity, Abs(WMSInvRec."Inv. Level Difference"))
        else
            ItemJnlLine.Validate(Quantity, Abs(WMSInvRec."WMS Qty."));
        //RHE-TNA 09-12-2020 BDS-4324 END
        ItemJnlLine.Validate("Reason Code", WMSInvRec."Reason Code");
        ItemJnlLine.Validate(HideDialog, true);
        //Search for last used unit cost
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::"Positive Adjmt." then begin
            ILE.SetRange("Item No.", ItemJnlLine."Item No.");
            ILE.SetRange("Serial No.", WMSInvRec."Serial No.");
            ILE.SetRange("Lot No.", WMSInvRec."Lot No.");
            ILE.SetFilter(Quantity, '>%1', 0);
            if ILE.FindLast() then begin
                ILE.CalcFields("Cost Amount (Actual)");
                ItemJnlLine.Validate("Unit Cost", ILE."Cost Amount (Actual)" / ILE.Quantity);
            end;
        end;
        ItemJnlLine.Modify(true);

        if WMSInvRec."Lot No." <> '' then
            CreateReservationEntry(ItemJnlLine, WMSInvRec."Lot No.", '', WMSInvRec."Expiry Date");
        if WMSInvRec."Serial No." <> '' then
            CreateReservationEntry(ItemJnlLine, '', WMSInvRec."Serial No.", WMSInvRec."Expiry Date");

        //Post Item Journal, Post per line to have a new inventory starting point for the next WMS Inventory record
        Commit();
        OK := ItemJnlPost.Run(ItemJnlLine);
        Clear(ItemJnlPost);

        //Enter No. Series which was deleted.
        if ItemJnlBatch."No. Series" = '' then begin
            ItemJnlBatch."No. Series" := NoSeriesAdjustmentJnl;
            ItemJnlBatch.Modify(false);
        end;

        if not OK then
            exit(GetLastErrorText);
    end;

    procedure CalcInventory(): Decimal
    var
        ILE: Record "Item Ledger Entry";
        Qty: Decimal;
    begin
        ILE.SetCurrentKey("Item No.", Open, "Variant Code", "location Code", "Item Tracking", "Lot No.", "Serial No.");
        ILE.SetRange(Open, true);
        ILE.SetRange("Item No.", WMSInvRec."Item No.");
        ILE.SetRange("Location Code", WMSInvRec."From Location Code");
        ILE.SetRange("Serial No.", WMSInvRec."Serial No.");
        ILE.SetRange("Lot No.", WMSInvRec."Lot No.");
        ILE.CalcSums("Remaining Quantity");
        Qty := ILE."Remaining Quantity";
        exit(Qty);
    end;

    procedure CreateReservationEntry(ItemJnlLine: Record "Item Journal Line"; LotNo: Code[50]; SerialNo: Code[50]; ExpiryDate: Date)
    //Local Variables
    var
        ResEntry: Record "Reservation Entry";
        LastResEntryNo: Integer;
    begin
        if ResEntry.FindLast() then
            LastResEntryNo := ResEntry."Entry No.";
        ResEntry.Init();
        ResEntry."Entry No." := LastResEntryNo + 1;
        ResEntry."Item No." := ItemJnlLine."Item No.";
        ResEntry."Location Code" := ItemJnlLine."Location Code";
        ResEntry."Reservation Status" := ResEntry."Reservation Status"::Prospect;
        ResEntry."Creation Date" := WORKDATE;
        ResEntry."Source Type" := 83;
        ResEntry."Source ID" := ItemJnlLine."Journal Template Name";
        ResEntry."Source Batch Name" := ItemJnlLine."Journal Batch Name";
        ResEntry."Source Ref. No." := ItemJnlLine."Line No.";
        ResEntry."Created By" := USERID;
        if ExpiryDate <> 0D then
            if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then
                ResEntry."New Expiration Date" := ExpiryDate
            else
                ResEntry."Expiration Date" := ExpiryDate;
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::"Positive Adjmt." then begin
            ResEntry.Positive := true;
            ResEntry."Source Subtype" := 2;
            ResEntry."Expected Receipt Date" := ItemJnlLine."Posting Date";
            ResEntry.VALIDATE("Quantity (Base)", ItemJnlLine."Quantity (Base)");
        end;
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::"Negative Adjmt." then begin
            ResEntry.Positive := false;
            ResEntry."Source Subtype" := 3;
            ResEntry."Shipment Date" := ItemJnlLine."Posting Date";
            ResEntry.VALIDATE("Quantity (Base)", -ItemJnlLine."Quantity (Base)");
        end;
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then begin
            ResEntry.Positive := false;
            ResEntry."Source Subtype" := 4;
            ResEntry."Shipment Date" := ItemJnlLine."Posting Date";
            ResEntry.VALIDATE("Quantity (Base)", -ItemJnlLine."Quantity (Base)");
        end;

        if SerialNo <> '' then begin
            ResEntry."Serial No." := SerialNo;
            if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then
                ResEntry."New Serial No." := SerialNo;
            ResEntry."Item Tracking" := ResEntry."Item Tracking"::"Serial No.";
        end;
        if LotNo <> '' then begin
            ResEntry."Lot No." := LotNo;
            if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then
                ResEntry."New Lot No." := LotNo;
            if ResEntry."Item Tracking" = ResEntry."Item Tracking"::None then
                ResEntry."Item Tracking" := ResEntry."Item Tracking"::"Lot No."
            else
                ResEntry."Item Tracking" := ResEntry."Item Tracking"::"Lot and Serial No.";
        end;
        ResEntry.Insert(true);
    end;

    //Global variables
    var
        WMSInvRec: Record "WMS Inventory Reconciliation";

        LocationFilter: Text[250];
        ReclassDocNo: Code[20];
        NoSeriesReclassJnl: Code[20];
        AdjustmentDocNo: Code[20];
        NoSeriesAdjustmentJnl: Code[20];
}