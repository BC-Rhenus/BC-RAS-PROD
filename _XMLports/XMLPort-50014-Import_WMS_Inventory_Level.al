xmlport 50014 "Import WMS Inventory Level"

//  RHE-TNA 31-12-2020..01-02-2021 BDS-4324
//  - New XMLPort

//  RHE-TNA 12-03-2021..17-03-2021 BDS-5075
//  - Modified procedure AddWMSInvRec
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 21-04-2021..22-04-2021 BDS-5280
//  - Modified trigger OnBeforeInsertRecord()
//  - Modified procedure AddWMSInvRec()

//  RHE-TNA 28-04-2021 BDS-5302
//  - Modified trigger OnBeforeInsertRecord()
//  - Modified trigger OnPreXmlPort()

//  RHE-TNA 02-02-2022 BDS-5585
//  - Changed trigger OnPreXmlPort()
//  - Changed procedure SetFileName()
//  - Changed procedure GetFromLocation()
//  - Changed procedure GetReasonCode()

{
    Direction = Import;
    Format = Xml;
    FormatEvaluate = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;
    UseRequestPage = false;

    schema
    {
        textelement(dcsextractdata)
        {
            textelement(dataheaders)
            {
                textelement(dataheader)
                {
                    textelement(record_type)
                    {

                    }
                    textelement(action)
                    {

                    }
                    textelement(tag_id)
                    {

                    }
                    textelement(client_id)
                    {

                    }
                    textelement(sku_id)
                    {

                    }
                    textelement(config_id)
                    {

                    }
                    textelement(site_id)
                    {

                    }
                    textelement(location_id)
                    {

                    }
                    textelement(zone_1)
                    {

                    }
                    textelement(quantity_sign)
                    {

                    }
                    textelement(qty_on_hand)
                    {

                    }
                    textelement(qty_allocated)
                    {

                    }
                    textelement(condition_id)
                    {

                    }
                    textelement(receipt_dstamp)
                    {

                    }
                    textelement(move_dstamp)
                    {

                    }
                    textelement(receipt_id)
                    {

                    }
                    textelement(qc_status)
                    {

                    }
                    textelement(batch_id)
                    {

                    }
                    textelement(expiry_dstamp)
                    {

                    }
                    textelement(expired)
                    {

                    }
                    textelement(count_dstamp)
                    {

                    }
                    textelement(count_needed)
                    {

                    }
                    textelement(lock_status)
                    {

                    }
                    textelement(lock_code)
                    {

                    }
                    textelement(supplier_id)
                    {

                    }
                    textelement(full_pallet)
                    {

                    }
                    textelement(outer)
                    {

                    }
                    textelement(description)
                    {

                    }
                    textelement(notes)
                    {

                    }
                    textelement(container_id)
                    {

                    }
                    textelement(pallet_id)
                    {

                    }
                    textelement(pallet_config)
                    {

                    }
                    textelement(owner_id)
                    {

                    }
                    textelement(origin_id)
                    {

                    }
                    textelement(manuf_dstamp)
                    {

                    }
                    textelement(user_def_type_1)
                    {

                    }
                    textelement(user_def_type_2)
                    {

                    }
                    textelement(user_def_type_3)
                    {

                    }
                    textelement(user_def_type_4)
                    {

                    }
                    textelement(user_def_type_5)
                    {

                    }
                    textelement(user_def_type_6)
                    {

                    }
                    textelement(user_def_type_7)
                    {

                    }
                    textelement(user_def_type_8)
                    {

                    }
                    textelement(user_def_chk_1)
                    {

                    }
                    textelement(user_def_chk_2)
                    {

                    }
                    textelement(user_def_chk_3)
                    {

                    }
                    textelement(user_def_chk_4)
                    {

                    }
                    textelement(user_def_date_1)
                    {

                    }
                    textelement(user_def_date_2)
                    {

                    }
                    textelement(user_def_date_3)
                    {

                    }
                    textelement(user_def_date_4)
                    {

                    }
                    textelement(user_def_num_1)
                    {

                    }
                    textelement(user_def_num_2)
                    {

                    }
                    textelement(user_def_num_3)
                    {

                    }
                    textelement(user_def_num_4)
                    {

                    }
                    textelement(user_def_note_1)
                    {

                    }
                    textelement(user_def_note_2)
                    {

                    }
                    textelement(from_site_id)
                    {

                    }
                    textelement(to_site_id)
                    {

                    }
                    textelement(time_zone_name)
                    {

                    }
                    textelement(spec_code)
                    {

                    }
                    textelement(pallet_volume)
                    {

                    }
                    textelement(pallet_height)
                    {

                    }
                    textelement(pallet_depth)
                    {

                    }
                    textelement(pallet_width)
                    {

                    }
                    textelement(pallet_weight)
                    {

                    }
                    textelement(receipt_type)
                    {

                    }
                    textelement(line_id)
                    {

                    }
                    textelement(entered_height)
                    {

                    }
                    textelement(sampling_type)
                    {

                    }
                    textelement(next_sampling_action)
                    {

                    }
                    textelement(sampled)
                    {

                    }
                    textelement(ab_last_trans_dstamp)
                    {

                    }
                    textelement(beam_id)
                    {

                    }
                    textelement(beam_start_unit)
                    {

                    }
                    textelement(beam_end_unit)
                    {

                    }
                    textelement(ce_rotation_id)
                    {

                    }
                    textelement(ce_consignment_id)
                    {

                    }
                    textelement(ce_receipt_type)
                    {

                    }
                    textelement(ce_originator)
                    {

                    }
                    textelement(ce_originator_reference)
                    {

                    }
                    textelement(ce_coo)
                    {

                    }
                    textelement(ce_cwc)
                    {

                    }
                    textelement(ce_ucr)
                    {

                    }
                    textelement(ce_under_bond)
                    {

                    }
                    textelement(ce_document_dstamp)
                    {

                    }
                    textelement(pre_received)
                    {

                    }
                    textelement(disallow_alloc)
                    {

                    }
                    textelement(ce_duty_stamp)
                    {

                    }
                    textelement(created_inventory)
                    {

                    }
                    textelement(pick_face)
                    {

                    }
                    textelement(breakpack_done)
                    {

                    }
                    textelement(ce_invoice_number)
                    {

                    }
                    textelement(serial_numbers)
                    {
                        tableelement(serial_number; Integer)
                        {
                            textelement(serial_no)
                            {

                            }
                            trigger OnBeforeInsertRecord()
                            var
                                WmsInvRec: Record "WMS Inventory Reconciliation";
                                QtyOnHandDec: Decimal;
                                Item: Record Item;
                                ItemTrackingCode: Record "Item Tracking Code";
                                Day: Integer;
                                Month: Integer;
                                Year: Integer;
                                ExpirationDate: Date;
                            begin
                                //RHE-TNA 28-04-2021 BDS-5302 BEGIN
                                //Moved below section to OnPreXMLPort
                                //Check if old stock level entries are present which are not processed and set them to Disapproved to prevent double prcessing
                                //WmsInvRec.Reset();
                                //WmsInvRec.SetRange("Transaction Code", WmsInvRec."Transaction Code"::"Stock Level");
                                //WmsInvRec.SetFilter("Inventory Level Run", '<>%1', InvLevelRun);
                                //WmsInvRec.SetRange("Processed by User", '');
                                //if WmsInvRec.FindSet() then begin
                                //    WMSInvRec.ModifyAll(Approved, false);
                                //    WMSInvRec.ModifyAll(Disapproved, true);
                                //    WMSInvRec.ModifyAll("Approved / Disapproved by User", UserId);
                                //    WMSInvRec.ModifyAll(Process, false);
                                //end;
                                //RHE-TNA 28-04-2021 BDS-5302 END

                                if not DecimalSignIsComma then begin
                                    if StrPos(qty_on_hand, ',') <> 0 then
                                        qty_on_hand := DelChr(qty_on_hand, '=', ',');
                                end else begin
                                    if StrPos(qty_on_hand, ',') <> 0 then
                                        qty_on_hand := ConvertStr(qty_on_hand, ',', '.');
                                end;
                                Evaluate(QtyOnHandDec, qty_on_hand);

                                //RHE-TNA 21-04-2021 BDS-5280 BEGIN
                                ExpirationDate := 0D;
                                if expiry_dstamp <> '' then begin
                                    Evaluate(Day, CopyStr(expiry_dstamp, 7, 2));
                                    Evaluate(Month, CopyStr(expiry_dstamp, 5, 2));
                                    Evaluate(Year, CopyStr(expiry_dstamp, 1, 4));
                                    ExpirationDate := DMY2Date(Day, Month, Year);
                                end;
                                //RHE-TNA 21-04-2021 BDS-5280 END

                                WmsInvRec.Reset();
                                //check if record is already created during processing of xml file.
                                WmsInvRec.SetRange("Item No.", sku_id);
                                WmsInvRec.SetRange("From Location Code", GetFromLocation());
                                //RHE-TNA 21-04-2021 BDS-5280 BEGIN
                                //WmsInvRec.SetRange("Lock Code", lock_code);
                                //WmsInvRec.SetRange("Condition Code", condition_id);
                                //RHE-TNA 21-04-2021 BDS-5280 END
                                WmsInvRec.SetRange("Inventory Level Run", InvLevelRun);
                                WmsInvRec.SetRange("Serial No.", '');
                                WmsInvRec.SetRange("Lot No.", batch_id);
                                //Check if item is setup to store serial numbers in inventory, if not continue without serial number.
                                if serial_no <> '' then
                                    if (Item.Get(sku_id)) and (Item."Item Tracking Code" <> '') then
                                        if ItemTrackingCode.Get(Item."Item Tracking Code") and (ItemTrackingCode."SN Purchase Inbound Tracking" or ItemTrackingCode."SN Assembly Inbound Tracking") then begin
                                            WmsInvRec.SetRange("Serial No.", serial_no);
                                            QtyOnHandDec := 1;
                                            //RHE-TNA 17-03-2021 BDS-5075 BEGIN
                                            //end else
                                            //    serial_no := '';
                                        end else begin
                                            serial_no := '';
                                            //If serial numbers are not in inventory, but are present in XML only process XML dataheader once
                                            if (sku_id = PrevItem) and (tag_id = PrevTag) and (location_id = PrevLocation) then
                                                currXMLport.Skip()
                                            else begin
                                                PrevItem := sku_id;
                                                PrevTag := tag_id;
                                                PrevLocation := location_id;
                                            end;
                                        end;
                                //RHE-TNA 17-03-2021 BDS-5075 END
                                if WmsInvRec.FindFirst() then begin
                                    //Update record with additional inventory, only when serial no. is empty as inventory with sn is always 1
                                    if serial_no = '' then begin
                                        WmsInvRec.Validate("WMS Qty.", WmsInvRec."WMS Qty." + QtyOnHandDec);
                                        WmsInvRec.Validate("Inv. Level Difference", WmsInvRec."Inv. Level Difference" + QtyOnHandDec);
                                        WmsInvRec.Modify(true);
                                    end;
                                end else
                                    //RHE-TNA 21-04-2021 BDS-5280 BEGIN
                                    //AddWMSInvRec(sku_id, GetFromLocation(), serial_no, batch_id, QtyOnHandDec, 0, lock_code, condition_id);
                                    AddWMSInvRec(sku_id, GetFromLocation(), serial_no, batch_id, QtyOnHandDec, 0, lock_code, condition_id, ExpirationDate);
                                //RHE-TNA 21-04-2021 BDS-5280 END

                                //Do not actually import into Integer table
                                currXMLport.Skip();
                            end;
                        }
                    }
                    trigger OnAfterAssignVariable()
                    begin
                        condition_id := '';
                        lock_code := '';
                        batch_id := '';
                        serial_no := '';
                        expiry_dstamp := '';
                        notes := '';
                    end;
                }
            }
        }
    }

    //RHE-TNA 03-02-2022 BDS-5585BEGIN
    //trigger OnPreXmlPort()
    procedure OnAfterSetFileName()
    //RHE-TNA 03-02-2022 BDS-5585END
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
        WMSInvLevelRec: Record "WMS Inventory Reconciliation";
    begin
        //Check WMS Location setup is present, if not present stop processing
        //RHE-TNA 03-02-2022 BDS-5585BEGIN
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585 END
        WMSLocationSetup.FindFirst();

        DecimalSignIsComma := IFSetup.DecimalSignIsComma();

        //RHE-TNA 03-02-2022 BDS-5585BEGIN
        /*
        InvLevelRun := 1;
        WMSInvLevelRec.SetRange("Transaction Code", WMSInvLevelRec."Transaction Code"::"Stock Level");
        if WMSInvLevelRec.FindLast() then
            InvLevelRun := WMSInvLevelRec."Inventory Level Run" + 1;
            */
        //RHE-TNA 03-02-2022 BDS-5585END

        //RHE-TNA 28-04-2021 BDS-5302 BEGIN
        WmsInvLevelRec.Reset();
        WmsInvLevelRec.SetRange("Transaction Code", WmsInvLevelRec."Transaction Code"::"Stock Level");
        WmsInvLevelRec.SetFilter("Inventory Level Run", '<>%1', InvLevelRun);
        WMSInvLevelRec.SetRange(Process, true);
        //RHE-TNA 03-02-2022 BDS-5585BEGIN
        WMSInvLevelRec.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585END
        if WmsInvLevelRec.FindSet() then begin
            repeat
                if (WMSInvLevelRec."Processed Date" = 0D) or (WMSInvLevelRec.Error) then begin
                    WMSInvLevelRec.Approved := false;
                    WMSInvLevelRec.Disapproved := true;
                    WMSInvLevelRec."Approved / Disapproved by User" := 'Interface';
                    WMSInvLevelRec.Process := false;
                    WMSInvLevelRec.Modify();
                end;
            until WMSInvLevelRec.Next() = 0;
            //RHE-TNA 03-02-2022 BDS-5585BEGIN
            Commit();
            //RHE-TNA 03-02-2022 BDS-5585END
        end;
        //RHE-TNA 28-04-2021 BDS-5302 END
    end;

    procedure SetFileName(FileName: Text[250]; IFSetupEntryNo: Integer; InvLvlRun: Integer)
    begin
        currXMLport.Filename := FileName;
        //RHE-TNA 03-02-2022 BDS-5585BEGIN
        IFSetup.Get(IFSetupEntryNo);
        InvLevelRun := InvLvlRun;
        OnAfterSetFileName();
        //RHE-TNA 01-02-2022 BDS-5585 END
    end;

    procedure GetFromLocation(): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
        PrevCode: Code[10];
        FromLocation: Code[10];
        i: Integer;
        TempText: Text[10];
    begin
        //RHE-TNA 03-02-2022 BDS-5585BEGIN
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585END
        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
        WMSLocationSetup.FindFirst();
        FromLocation := WMSLocationSetup."Location Code";

        //Check if inventory has a lock code
        if lock_code <> '' then begin
            WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
            WMSLocationSetup.SetRange(Code, lock_code);
            if WMSLocationSetup.FindFirst() then
                exit(WMSLocationSetup."Location Code")
            else
                exit('Unknown');
        end else begin
            //Check if inventory has a condition code
            if condition_id <> '' then begin
                WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                WMSLocationSetup.SetRange(Code, condition_id);
                if WMSLocationSetup.FindFirst() then
                    exit(WMSLocationSetup."Location Code")
                else
                    exit('Unknown');
            end else
                //If no previous lock code and no condition, use base warehouse
                exit(FromLocation);
        end;
    end;

    procedure GetReasonCode(): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
    begin
        WMSLocationSetup.Reset();
        //RHE-TNA 03-02-2022 BDS-5585BEGIN
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585BEGIN
        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
        WMSLocationSetup.FindFirst();
        exit(WMSLocationSetup."Reason Code Inv. Level");
    end;

    procedure AddWMSInvRec(ItemNo: Code[20]; Location: Code[10]; SerialNo: Code[50]; LotNo: Code[50]; QtyWMS: Decimal; QtyBC: Decimal; LockCode: Code[10]; ConditionCode: Code[10]; ExpirationDate: Date)
    var
        WMSInvRec: Record "WMS Inventory Reconciliation";
        Item: Record Item;
        ErrorText: Text[250];
    begin
        WMSInvRec.Insert(true);
        WMSInvRec.Validate("Transaction Date", Today);
        WMSInvRec.Validate(Process, true);
        WMSInvRec.Validate("Item No.", ItemNo);
        //RHE-TNA 12-03-2021 BDS-5075 BEGIN
        if Item.Get(ItemNo) then
            WMSInvRec.Validate(Description, Item.Description);
        //RHE-TNA 12-03-2021 BDS-5075 END
        WMSInvRec."From Location Code" := Location;
        WMSInvRec.Validate("Serial No.", SerialNo);
        WMSInvRec.Validate("Lot No.", LotNo);
        WMSInvRec.Validate("WMS Qty.", QtyWMS);
        WMSInvRec.Validate("Calculated Inv. Level", QtyBC);
        WMSInvRec.Validate("Inv. Level Difference", QtyWMS - QtyBC);
        //RHE-TNA 21-04-2021 BDS-5280 BEGIN
        //WMSInvRec.Validate("Lock Code", LockCode);
        //WMSInvRec.Validate("Condition Code", ConditionCode);
        WMSInvRec.Validate("Expiry Date", ExpirationDate);
        //RHE-TNA 21-04-2021 BDS-5280 END
        WMSInvRec.Validate("Reason Code", GetReasonCode());
        WMSInvRec.Validate("Inventory Level Run", InvLevelRun);
        //RHE-TNA 22-04-2021 BDS-5280 BEGIN
        if Location = 'UNKNOWN' then begin
            if LockCode <> '' then
                ErrorText := 'No From Location setup found in "WMS Inventory Location Setup" for (at least) Condition or Lock Code ' + LockCode
            else
                ErrorText := 'No From Location setup found in "WMS Inventory Location Setup" for (at least) Condition or Lock Code ' + ConditionCode;
            WMSInvRec.validate("Error Text", ErrorText);
        end;
        //RHE-TNA 22-04-2021 BDS-5280 END
        //RHE-TNA 03-02-2022 BDS-5585BEGIN
        WMSInvRec.Validate("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585END
        WMSInvRec.Modify(true);
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        DecimalSignIsComma: Boolean;
        InvLevelRun: Decimal;
        PrevItem: Text[20];
        PrevTag: Text[20];
        PrevLocation: Text[20];
}