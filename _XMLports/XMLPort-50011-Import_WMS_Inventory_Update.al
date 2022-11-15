xmlport 50011 "Import WMS Inv. Update"

//  RHE-TNA 21-07-2020..10-08-2020 BDS-4323
//  - New XMLPort

//  RHE-TNA 18-01-2021 BDS-4781
//  - Modfied trigger OnBeforeInsertRecord()

//  RHE-TNA 12-03-2021 BDS-5075
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 18-05-2021 BDS-5324
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 19-05-2021 BDS-5335
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 03-02-2022 BDS-5585
//  - Modified procedure GetToLocation()
//  - Modified procedure SetFileName()

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
                    textelement(code)
                    {

                    }
                    textelement(original_quantity_sign)
                    {

                    }
                    textelement(original_qty)
                    {

                    }
                    textelement(update_quantity_sign)
                    {

                    }
                    textelement(update_qty)
                    {

                    }
                    textelement(dstamp)
                    {

                    }
                    textelement(client_id)
                    {

                    }
                    textelement(sku_id)
                    {

                    }
                    textelement(from_loc_id)
                    {

                    }
                    textelement(to_loc_id)
                    {

                    }
                    textelement(final_loc_id)
                    {

                    }
                    textelement(tag_id)
                    {

                    }
                    textelement(reference_id)
                    {

                    }
                    textelement(line_id)
                    {

                    }
                    textelement(condition_id)
                    {

                    }
                    textelement(notes)
                    {

                    }
                    textelement(reason_id)
                    {

                    }

                    textelement(batch_id)
                    {

                    }
                    textelement(expiry_dstamp)
                    {

                    }
                    textelement(user_id)
                    {

                    }
                    textelement(shift)
                    {

                    }
                    textelement(station_id)
                    {

                    }
                    textelement(site_id)
                    {

                    }
                    textelement(container_id)
                    {

                    }
                    textelement(pallet_id)
                    {

                    }
                    textelement(list_id)
                    {

                    }
                    textelement(owner_id)
                    {

                    }
                    textelement(origin_id)
                    {

                    }
                    textelement(work_group)
                    {

                    }
                    textelement(consignment)
                    {

                    }
                    textelement(manuf_dstamp)
                    {

                    }
                    textelement(lock_status)
                    {

                    }
                    textelement(qc_status)
                    {

                    }
                    textelement(session_type)
                    {

                    }
                    textelement(summary_record)
                    {

                    }
                    textelement(elapsed_time)
                    {

                    }
                    textelement(supplier_id)
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
                    textelement(old_user_def_type_1)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_type_2)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_type_3)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_type_4)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_type_5)
                    {

                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_type_6)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_type_7)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_type_8)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_chk_1)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_chk_2)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_chk_3)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_chk_4)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_date_1)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_date_2)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_date_3)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_date_4)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_num_1)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_num_2)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_num_3)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_num_4)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_note_1)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(old_user_def_note_2)
                    {
                        MinOccurs = Zero;
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
                    textelement(job_id)
                    {

                    }
                    textelement(job_unit)
                    {

                    }
                    textelement(manning)
                    {

                    }
                    textelement(spec_code)
                    {

                    }
                    textelement(config_id)
                    {

                    }
                    textelement(estimated_time)
                    {

                    }
                    textelement(task_category)
                    {

                    }
                    textelement(sampling_type)
                    {

                    }
                    textelement(complete_dstamp)
                    {

                    }
                    textelement(grn)
                    {

                    }
                    textelement(group_id)
                    {

                    }
                    textelement(uploaded)
                    {

                    }
                    textelement(uploaded_vview)
                    {

                    }
                    textelement(uploaded_ab)
                    {

                    }
                    textelement(sap_idoc_type)
                    {

                    }
                    textelement(sap_tid)
                    {

                    }
                    textelement(ce_orig_rotation_id)
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
                    textelement(uploaded_customs)
                    {

                    }
                    textelement(uploaded_labor)
                    {

                    }
                    textelement(asn_id)
                    {

                    }
                    textelement(customer_id)
                    {

                    }
                    textelement(print_label_id)
                    {

                    }
                    textelement(lock_code)
                    {

                    }
                    textelement(ship_dock)
                    {

                    }
                    textelement(ce_duty_stamp)
                    {

                    }
                    textelement(pallet_grouped)
                    {

                    }
                    textelement(job_site_id)
                    {

                    }
                    textelement(job_client_id)
                    {

                    }
                    textelement(tracking_level)
                    {

                    }
                    textelement(extra_notes)
                    {

                    }
                    textelement(archived)
                    {

                    }
                    textelement(shipment_number)
                    {

                    }
                    textelement(customer_shipment_number)
                    {

                    }
                    textelement(pallet_config)
                    {

                    }
                    textelement(container_type)
                    {

                    }
                    textelement(master_pah_id)
                    {

                    }
                    textelement(master_pal_id)
                    {

                    }
                    textelement(from_status)
                    {

                    }
                    textelement(to_status)
                    {

                    }
                    textelement(uploaded_tm)
                    {

                    }
                    textelement(kit_plan_id)
                    {

                    }
                    textelement(plan_sequence)
                    {

                    }
                    textelement(master_order_id)
                    {

                    }
                    textelement(master_order_line_id)
                    {

                    }
                    textelement(dock_door_id)
                    {

                    }
                    textelement(ce_colli_count)
                    {

                    }
                    textelement(ce_colli_count_expected)
                    {

                    }
                    textelement(ce_seals_ok)
                    {

                    }
                    textelement(ce_invoice_number)
                    {

                    }
                    textelement(ce_avail_status)
                    {

                    }
                    textelement(rdt_user_mode)
                    {

                    }
                    textelement(kit_ce_consignment_id)
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
                                WMSInvRecon: Record "WMS Inventory Reconciliation";
                                Day: Integer;
                                Month: Integer;
                                Year: Integer;
                                Item: Record Item;
                            begin
                                //RHE-TNA 18-01-2021 BDS-4781 BEGIN
                                if update_qty = '0' then
                                    currXMLport.Skip();
                                //RHE-TNA 18-01-2021 BDS-4781 END
                                WMSInvRecon.Insert(true);
                                if dstamp <> '' then begin
                                    Evaluate(Day, CopyStr(dstamp, 7, 2));
                                    Evaluate(Month, CopyStr(dstamp, 5, 2));
                                    Evaluate(Year, CopyStr(dstamp, 1, 4));
                                    WMSInvRecon.Validate("Transaction Date", DMY2Date(Day, Month, Year));
                                end;
                                WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::"Stock Level");
                                case code of
                                    'Adjustment':
                                        begin
                                            WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::Adjustment);
                                            WMSInvRecon.Validate(Process, true);
                                            WMSInvRecon."Reason Code" := reason_id;
                                        end;
                                    'Cond Update':
                                        begin
                                            WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::"Cond Update");
                                            WMSInvRecon.Validate(Process, true);
                                            //RHE-TNA 12-03-2021 BDS-5075 BEGIN
                                            //WMSInvRecon.Validate(Approved, true);
                                            //WMSInvRecon.Validate("Approved / Disapproved by User", 'INTERFACE');
                                            //RHE-TNA 12-03-2021 BDS-5075 END
                                        end;
                                    'Inv Lock':
                                        begin
                                            WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::"Inventory Lock");
                                            WMSInvRecon.Validate(Process, true);
                                            //RHE-TNA 12-03-2021 BDS-5075 BEGIN
                                            //WMSInvRecon.Validate(Approved, true);
                                            //WMSInvRecon.Validate("Approved / Disapproved by User", 'INTERFACE');
                                            //RHE-TNA 12-03-2021 BDS-5075 END
                                        end;
                                    'Inv UnLock':
                                        begin
                                            WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::"Inventory Unlock");
                                            WMSInvRecon.Validate(Process, true);
                                            //RHE-TNA 12-03-2021 BDS-5075 BEGIN
                                            //WMSInvRecon.Validate(Approved, true);
                                            //WMSInvRecon.Validate("Approved / Disapproved by User", 'INTERFACE');
                                            //RHE-TNA 12-03-2021 BDS-5075 END
                                        end;
                                end;
                                WMSInvRecon.Validate("Item No.", sku_id);
                                Item.Get(sku_id);
                                WMSInvRecon.Validate(Description, Item.Description);
                                if not DecimalSignIsComma then begin
                                    if StrPos(update_qty, ',') <> 0 then
                                        update_qty := DelChr(update_qty, '=', ',');
                                end else begin
                                    if StrPos(update_qty, ',') <> 0 then
                                        update_qty := ConvertStr(update_qty, ',', '.');
                                end;
                                //RHE-TNA 19-05-2021 BDS-5335 BEGIN
                                //if update_qty <> '' then
                                if (update_qty <> '') and (serial_no = '') then
                                    //RHE-TNA 19-05-2021 BDS-5335 END
                                    if update_quantity_sign = '+' then
                                        Evaluate(WMSInvRecon."WMS Qty.", update_qty)
                                    else begin
                                        Evaluate(WMSInvRecon."WMS Qty.", update_qty);
                                        WMSInvRecon.Validate("WMS Qty.", -WMSInvRecon."WMS Qty.");
                                        //RHE-TNA 19-05-2021 BDS-5335 BEGIN
                                        //end;
                                    end else
                                    WMSInvRecon.Validate("WMS Qty.", 1);
                                //RHE-TNA 19-05-2021 BDS-5335 END
                                WMSInvRecon.Validate("Condition Code", condition_id);
                                WMSInvRecon.Validate("Lock Code", lock_code);
                                WMSInvRecon.Validate("Lot No.", batch_id);
                                WMSInvRecon.Validate("Serial No.", serial_no);
                                if expiry_dstamp <> '' then begin
                                    Evaluate(Day, CopyStr(expiry_dstamp, 7, 2));
                                    Evaluate(Month, CopyStr(expiry_dstamp, 5, 2));
                                    Evaluate(Year, CopyStr(expiry_dstamp, 1, 4));
                                    WMSInvRecon.Validate("Expiry Date", DMY2Date(Day, Month, Year));
                                end;
                                WMSInvRecon.Validate("WMS Notes", CopyStr(notes, 1, 250));
                                WMSInvRecon."From Location Code" := GetFromLocation(WMSInvRecon);
                                if not (WMSInvRecon."Transaction Code" = WMSInvRecon."Transaction Code"::Adjustment) then begin
                                    WMSInvRecon."To Location Code" := GetToLocation(WMSInvRecon);
                                    WMSInvRecon.Validate("Reason Code", GetReasonCode(WMSInvRecon));
                                end;
                                WMSInvRecon.Modify(true);
                                //RHE-TNA 18-05-2021 BDS-5324 BEGIN
                                if WMSInvRecon."From Location Code" = WMSInvRecon."To Location Code" then begin
                                    WMSInvRecon.Process := false;
                                    WMSInvRecon."Processed Date" := Today;
                                    WMSInvRecon."Processed by User" := 'INTERFACE';
                                    WMSInvRecon.Approved := true;
                                    WMSInvRecon."Approved / Disapproved by User" := 'INTERFACE';
                                    WMSInvRecon.Modify(true);
                                end;
                                //RHE-TNA 18-05-2021 BDS-5324 END

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
    trigger OnPreXmlPort()
    begin
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
    end;

    procedure SetFileName(FileName: Text[250]; IFSetupEntryNo: Integer)
    begin
        currXMLport.Filename := FileName;
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        IFSetup.Get(IFSetupEntryNo);
    end;

    procedure GetFromLocation(Rec: Record "WMS Inventory Reconciliation"): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
        PrevCode: Code[10];
        FromLocation: Code[10];
        i: Integer;
        TempText: Text[10];
    begin
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585 END
        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
        WMSLocationSetup.FindFirst();
        FromLocation := WMSLocationSetup."Location Code";

        //Determine previous Lock or Condition code
        case Rec."Transaction Code" of
            Rec."Transaction Code"::Adjustment:
                begin
                    //Check if inventory has a lock code
                    if Rec."Lock Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                        WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else begin
                        //Check if inventory has a condition code
                        if Rec."Condition Code" <> '' then begin
                            WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                            WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                            if WMSLocationSetup.FindFirst() then
                                exit(WMSLocationSetup."Location Code")
                            else
                                exit('Unknown');
                        end else
                            //If no previous lock code and no condition, use base warehouse
                            exit(FromLocation);
                    end;
                end;
            Rec."Transaction Code"::"Cond Update":
                begin
                    //When inventory is locked, do not move inventory
                    if Rec."Lock Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                        WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end;

                    //When PrevCode is not empty, check location setup based upon previous condition (stated in WMS notes)
                    //Example of WMS Notes = LOROC ->                
                    i := StrPos(Rec."WMS Notes", '->');
                    if i > 1 then
                        PrevCode := CopyStr(Rec."WMS Notes", 1, i - 1);

                    if PrevCode <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                        WMSLocationSetup.SetRange(Code, PrevCode);
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code");
                    end else
                        //If not locked and no previous condition, use base warehouse
                        exit(FromLocation);
                end;
            Rec."Transaction Code"::"Inventory Lock":
                begin
                    //When PrevCode is not empty, check location setup based upon previous lock code (stated in WMS notes)
                    //Example of WMS Notes = Locked(LOROC) -> Locked(EXPD)
                    TempText := CopyStr(Rec."WMS Notes", 1, 6);
                    if UpperCase(TempText) = 'LOCKED' then begin
                        i := StrPos(Rec."WMS Notes", ') ->');
                        //i + 1 - 8 --> in above example i will return 13. So 13 -8 = 5 will return LOROC
                        PrevCode := CopyStr(Rec."WMS Notes", 8, i - 8);
                    end;

                    if PrevCode <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                        WMSLocationSetup.SetRange(Code, PrevCode);
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else begin
                        //Check if inventory has a condition code
                        if Rec."Condition Code" <> '' then begin
                            WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                            WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                            if WMSLocationSetup.FindFirst() then
                                exit(WMSLocationSetup."Location Code")
                            else
                                exit('Unknown');
                        end else
                            //If no previous lock code and no condition, use base warehouse
                            exit(FromLocation);
                    end;
                end;
            Rec."Transaction Code"::"Inventory Unlock":
                begin
                    //Example of WMS Notes = Locked(EXPD) -> UnLocked()
                    TempText := CopyStr(Rec."WMS Notes", 1, 6);
                    if UpperCase(TempText) = 'LOCKED' then begin
                        i := StrPos(Rec."WMS Notes", ') ->');
                        //i + 1 - 8 --> in above example i will return 12. So 12 -8 = 4 will return EXPD
                        PrevCode := CopyStr(Rec."WMS Notes", 8, i - 8);
                    end;

                    WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                    WMSLocationSetup.SetRange(Code, PrevCode);
                    if WMSLocationSetup.FindFirst() then
                        exit(WMSLocationSetup."Location Code")
                    else
                        exit('Unknown');
                end;
        end;
    end;

    procedure GetToLocation(Rec: Record "WMS Inventory Reconciliation"): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
    begin
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585 END
        case Rec."Transaction Code" of
            Rec."Transaction Code"::"Cond Update":
                begin
                    //When inventory is locked, do not move inventory
                    if Rec."Lock Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                        WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end;

                    if Rec."Condition Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                        WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
                        WMSLocationSetup.FindFirst();
                        exit(WMSLocationSetup."Location Code");
                    end;
                end;
            Rec."Transaction Code"::"Inventory Lock":
                begin
                    WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                    WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                    if WMSLocationSetup.FindFirst() then
                        exit(WMSLocationSetup."Location Code")
                    else
                        exit('Unknown');
                end;
            Rec."Transaction Code"::"Inventory Unlock":
                begin
                    //If inventory has a condition code use this location
                    if Rec."Condition Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                        WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
                        WMSLocationSetup.FindFirst();
                        exit(WMSLocationSetup."Location Code");
                    end;
                end;
        end;
    end;

    procedure GetReasonCode(Rec: Record "WMS Inventory Reconciliation"): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
    begin
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585 END
        case Rec."Transaction Code" of
            Rec."Transaction Code"::"Cond Update":
                begin
                    if Rec."Condition Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                        WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                    end else
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
                    if WMSLocationSetup.FindFirst() then
                        exit(WMSLocationSetup."Reason Code Reclass.");
                end;
            Rec."Transaction Code"::"Inventory Lock":
                begin
                    WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                    WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                    if WMSLocationSetup.FindFirst() then
                        exit(WMSLocationSetup."Reason Code Reclass.");
                end;
            Rec."Transaction Code"::"Inventory Unlock":
                begin
                    WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
                    WMSLocationSetup.FindFirst();
                    exit(WMSLocationSetup."Reason Code Reclass.");
                end;
        end;
    end;

    //Global variable
    var
        IFSetup: Record "Interface Setup";
        DecimalSignIsComma: Boolean;
}