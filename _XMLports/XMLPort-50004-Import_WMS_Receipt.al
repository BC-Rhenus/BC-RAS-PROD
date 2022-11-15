xmlport 50004 "Import WMS Receipt"

//  RHE-TNA 19-03-2020..14-05-2020 BDS-3866
//  - Modified elements
//  - Added elements
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreXMLPort()

//  RHE-TNA 03-02-2022 BDS-5585
//  - Modified trigger OnPreXMLPort()
//  - Modified procedure SetFileName()

//  RHE-TNA 17-02-2022 BDS-5977
//  - Modified element (batch_id)
//  - Modified element (expiry_dstamp)
//  - Modified trigger OnAfterInsertRecord()

//  RHE-TNA 16-05-2022 BDS-6332
//  - Modified element (expiry_dstamp), made it availabe again after it was disabled with BDS-5977

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
                tableelement(dataheader; "WMS Import Line")
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
                        trigger OnAfterAssignVariable()
                        begin
                            if not DecimalSignIsComma then begin
                                if StrPos(update_qty, ',') <> 0 then
                                    update_qty := DelChr(update_qty, '=', ',');
                            end else begin
                                if StrPos(update_qty, ',') <> 0 then
                                    update_qty := ConvertStr(update_qty, ',', '.');
                            end;
                            if update_qty <> '' then
                                Evaluate(dataheader."Qty. shipped / Received", update_qty);
                        end;
                    }
                    textelement(dstamp)
                    {

                    }
                    textelement(client_id)
                    {

                    }
                    fieldelement(sku_id; dataheader."Item No.")
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
                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                    fieldelement(tag_id; dataheader."Tag Id")
                    //textelement(tag_id)
                    {

                    }
                    //RHE-TNA 17-03-2020 BDS-3866 END
                    fieldelement(reference_id; dataheader."Source No.")
                    {

                    }
                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                    //textelement(line_id)
                    fieldelement(line_id; dataheader."WMS Line Id")
                    {

                    }
                    //RHE-TNA 17-03-2020 BDS-3866 END
                    textelement(condition_id)
                    {

                    }
                    textelement(notes)
                    {

                    }
                    textelement(reason_id)
                    {

                    }
                    //RHE-TNA 17-02-2022 BDS-5977 BEGIN
                    //fieldelement(batch_id; dataheader."Batch id")
                    //RHE-TNA 17-02-2022 BDS-5977 BEGIN
                    textelement(batch_id)
                    {

                    }
                    textelement(expiry_dstamp)
                    {
                        trigger OnAfterAssignVariable()
                        var
                            Day: Integer;
                            Month: Integer;
                            Year: Integer;
                        begin
                            if expiry_dstamp <> '' then begin
                                Evaluate(Day, CopyStr(expiry_dstamp, 7, 2));
                                Evaluate(Month, CopyStr(expiry_dstamp, 5, 2));
                                Evaluate(Year, CopyStr(expiry_dstamp, 1, 4));
                                dataheader.Validate("Expiration Date", DMY2Date(Day, Month, Year));
                            end;
                        end;
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
                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                    //textelement(pallet_id)
                    fieldelement(pallet_id; dataheader."WMS Pallet Id")
                    {

                    }
                    //RHE-TNA 17-03-2020 BDS-3866 END
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
                        trigger OnAfterAssignVariable()
                        begin
                            dataheader.Validate("Location Code", CopyStr(user_def_type_1, 1, 10));
                        end;
                    }
                    textelement(user_def_type_2)
                    {

                    }
                    fieldelement(user_def_type_3; dataheader."Source Line No.")
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
                        trigger OnAfterAssignVariable()
                        var
                            Item: Record Item;
                            ItemTrackingCode: Record "Item Tracking Code";
                        begin
                            dataheader."Serial/Lot" := dataheader."Serial/Lot"::" ";
                            if user_def_type_8 = 'SNerial No.' then
                                dataheader."Serial/Lot" := dataheader."Serial/Lot"::Serial
                            else
                                if user_def_type_8 = 'LOT NO.' then
                                    dataheader."Serial/Lot" := dataheader."Serial/Lot"::Lot
                                else begin
                                    if Item.Get(dataheader."Item No.") then
                                        if (Item."Item Tracking Code" <> '') and (ItemTrackingCode.Get(Item."Item Tracking Code")) then begin
                                            //TNA                                                                                  
                                            case user_def_type_4 of
                                                '39':
                                                    begin
                                                        if ItemTrackingCode."SN Purchase Inbound Tracking" then
                                                            dataheader."Serial/Lot" := dataheader."Serial/Lot"::Serial
                                                        else
                                                            if ItemTrackingCode."Lot Purchase Inbound Tracking" then
                                                                dataheader."Serial/Lot" := dataheader."Serial/Lot"::Lot;
                                                    end;
                                                '5407':
                                                    begin
                                                        if ItemTrackingCode."SN Transfer Tracking" then
                                                            dataheader."Serial/Lot" := dataheader."Serial/Lot"::Serial
                                                        else
                                                            if ItemTrackingCode."Lot Transfer Tracking" then
                                                                dataheader."Serial/Lot" := dataheader."Serial/Lot"::Lot;
                                                    end;
                                                '37':
                                                    begin
                                                        if ItemTrackingCode."SN Sales Inbound Tracking" then
                                                            dataheader."Serial/Lot" := dataheader."Serial/Lot"::Serial
                                                        else
                                                            if ItemTrackingCode."Lot Sales Inbound Tracking" then
                                                                dataheader."Serial/Lot" := dataheader."Serial/Lot"::Lot;
                                                    end;
                                            end;
                                        end;
                                end;
                            //Clear value to be ensure correct value on next record
                            user_def_type_8 := '';
                        end;
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
                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
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
                    //RHE-TNA 17-03-2020 BDS-3866 END
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
                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                    textelement(from_status)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(to_status)
                    {
                        MinOccurs = Zero;
                    }
                    //RHE-TNA 17-03-2020 BDS-3866 END
                    textelement(uploaded_tm)
                    {

                    }
                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                    textelement(kit_plan_id)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(plan_sequence)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(master_order_id)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(master_order_line_id)
                    {
                        MinOccurs = Zero;
                    }
                    //RHE-TNA 17-03-2020 BDS-3866 END
                    textelement(dock_door_id)
                    {

                    }
                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                    textelement(ce_colli_count)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ce_colli_count_expected)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ce_seals_ok)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ce_invoice_number)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ce_avail_status)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(rdt_user_mode)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(kit_ce_consignment_id)
                    {
                        MinOccurs = Zero;
                    }
                    //RHE-TNA 17-03-2020 BDS-3866 END
                    trigger OnBeforeInsertRecord()
                    var
                        Day: Integer;
                        Month: Integer;
                        Year: Integer;
                        WhseReceiptLine: Record "Warehouse Receipt Line";
                    begin
                        if dataheader."Source No." <> PrevOrderid then begin
                            //Enter a header record
                            WMSImportHeader.Init();
                            WMSImportHeader.Insert(true);
                            WMSImportHeader.Validate(type, WMSImportHeader.type::Receipt);
                            WMSImportHeader.Validate("Whse. Document No.", dataheader."Whse. Document No.");
                            WMSImportHeader.Validate("Source No.", dataheader."Source No.");
                            if dstamp <> '' then begin
                                Evaluate(Day, CopyStr(dstamp, 7, 2));
                                Evaluate(Month, CopyStr(dstamp, 5, 2));
                                Evaluate(Year, CopyStr(dstamp, 1, 4));
                                WMSImportHeader.Validate("Receipt Date", DMY2Date(Day, Month, Year));
                            end;
                            WMSImportHeader.Validate("Import Date", Today);
                            WMSImportHeader.Validate(Process, true);
                            //Get Warehouse Receipt No.
                            WhseReceiptLine.SetRange("Source No.", dataheader."Source No.");
                            WhseReceiptLine.SetRange("Item No.", dataheader."Item No.");
                            if WhseReceiptLine.FindFirst() then
                                WMSImportHeader.Validate("Whse. Document No.", WhseReceiptLine."No.")
                            else begin
                                WMSImportHeader.Validate(Error, true);
                                WMSImportHeader.Validate("Error Text", 'No Warehouse Receipt is found for this Order No.');
                            end;
                            WMSImportHeader.Modify(true);
                            PrevOrderid := dataheader."Source No.";
                        end;
                        dataheader."Entry No." := WMSImportHeader."Entry No.";
                        dataheader."Whse. Document No." := WMSImportHeader."Whse. Document No.";
                    end;

                    //RHE-TNA 19-03-2020..14-05-2020 BDS-3866 BEGIN
                    trigger OnAfterInsertRecord()
                    var
                        WMSItemTracking: Record "WMS Import Serial Number";
                        Day: Integer;
                        Month: Integer;
                        Year: Integer;
                    begin
                        if (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016) and (dataheader."Batch Id" <> '') then begin
                            dataheader."Serial/Lot" := dataheader."Serial/Lot"::Lot;
                            dataheader.Modify(false);
                        end;

                        //RHE-TNA 17-02-2022 BDS-5977 BEGIN
                        if batch_id <> '' then begin
                            WMSItemTracking.Init();
                            WMSItemTracking."WMS Import Entry No." := dataheader."Entry No.";
                            WMSItemTracking."Item No." := dataheader."Item No.";
                            WMSItemTracking.Quantity := dataheader."Qty. Shipped / Received";
                            WMSItemTracking."WMS Import Line No." := dataheader."Line No.";
                            WMSItemTracking."Lot No." := batch_id;
                            WMSItemTracking."Pallet Id" := dataheader."WMS Pallet Id";
                            WMSItemTracking."Tag Id" := dataheader."Tag Id";
                            if expiry_dstamp <> '' then begin
                                Evaluate(Day, CopyStr(expiry_dstamp, 7, 2));
                                Evaluate(Month, CopyStr(expiry_dstamp, 5, 2));
                                Evaluate(Year, CopyStr(expiry_dstamp, 1, 4));
                                WMSItemTracking.Validate("Expiration Date", DMY2Date(Day, Month, Year));
                            end;
                            WMSItemTracking.Insert(true);
                        end;
                        //RHE-TNA 17-02-2022 BDS-5977 END
                    end;
                    //RHE-TNA 19-03-2020..14-05-2020 BDS-3866 END
                }
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        /*
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = WMS.');        
        //RHE-TNA 14-06-2021 BDS-5337 END
        */
        //RHE-TNA 03-02-2022 BDS-5585 END
    end;

    procedure SetFileName(FileName: Text[250]; IFSetupEntryNo: Integer)
    begin
        currXMLport.Filename := FileName;
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        IFSetup.Get(IFSetupEntryNo);
        //RHE-TNA 03-02-2022 BDS-5585 END

    end;

    //Global variable
    var
        IFSetup: Record "Interface Setup";
        DecimalSignIsComma: Boolean;
        WMSImportHeader: Record "WMS Import Header";
        PrevOrderid: Text[20];
}