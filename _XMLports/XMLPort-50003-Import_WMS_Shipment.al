xmlport 50003 "Import WMS Shipment"

//  RHE-TNA 20-03-2020..24-06-2020 BDS-3866
//  - Modified elements
//  - Modified trigger OnAfterInsertRecord

//  RHE-TNA 06-05-2020 BDS-4213
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 20-07-2020 BDS-4333
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 30-04-2021 BDS-5304
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreXMLPort()

//  RHE-TNA 21-01-2022 BDS-5903
//  - Modified textelement(user_def_chk_2)

//  RHE-TNA 03-02-2022 BDS-5585
//  - Modified trigger OnPreXMLPort()

//  RHE-TNA 17-02-2022 BDS-5977
//  - Modified element (batch_id)
//  - Modified element (expiry_dstamp)
//  - Modified trigger OnAfterInsertRecord()

//  RHE-TNA 10-06-2022 BDS-6043
//  - Modified textelement(user_def_chk_4)

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
                    textelement(client_id)
                    {

                    }
                    fieldelement(order_id; dataheader."Whse. Document No.")
                    {

                    }
                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                    //textelement(line_id)
                    fieldelement(line_id; dataheader."WMS Line Id")
                    {

                    }
                    //RHE-TNA 17-03-2020 BDS-3866 END
                    fieldelement(sku_id; dataheader."Item No.")
                    {

                    }
                    //RHE-TNA 17-02-2022 BDS-5977 BEGIN
                    //fieldelement(batch_id; dataheader."Batch id")
                    //RHE-TNA 17-02-2022 BDS-5977 END
                    textelement(batch_id)
                    {

                    }
                    textelement(expiry_dstamp)
                    {
                        //RHE-TNA 17-02-2022 BDS-5977 BEGIN
                        /*
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
                        */
                        //RHE-TNA 17-02-2022 BDS-5977 END
                    }
                    textelement(config_id)
                    {

                    }
                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                    //textelement(tag_id)
                    fieldelement(tag_id; dataheader."Tag Id")
                    //RHE-TNA 17-03-2020 BDS-3866 END
                    {

                    }
                    textelement(work_group)
                    {

                    }
                    textelement(consignment)
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
                    textelement(pallet_config)
                    {

                    }
                    textelement(site_id)
                    {

                    }
                    textelement(location_id)
                    {

                    }
                    textelement(owner_id)
                    {

                    }
                    textelement(qty_picked)
                    {

                    }
                    textelement(picked_dstamp)
                    {

                    }
                    textelement(qty_shipped)
                    {
                        trigger OnAfterAssignVariable()
                        begin
                            if not DecimalSignIsComma then begin
                                if StrPos(qty_shipped, ',') <> 0 then
                                    qty_shipped := DelChr(qty_shipped, '=', ',');
                            end else begin
                                if StrPos(qty_shipped, ',') <> 0 then
                                    qty_shipped := ConvertStr(qty_shipped, ',', '.');
                            end;
                            if qty_shipped <> '' then
                                Evaluate(dataheader."Qty. shipped / Received", qty_shipped);
                        end;
                    }
                    textelement(shipped_dstamp)
                    {
                        trigger OnAfterAssignVariable()
                        var
                            Day: Integer;
                            Month: Integer;
                            Year: Integer;
                        begin
                            if shipped_dstamp <> '' then begin
                                Evaluate(Day, CopyStr(shipped_dstamp, 7, 2));
                                Evaluate(Month, CopyStr(shipped_dstamp, 5, 2));
                                Evaluate(Year, CopyStr(shipped_dstamp, 1, 4));
                                dataheader.Validate("Shipment Date", DMY2Date(Day, Month, Year));
                            end;
                        end;
                    }
                    textelement(shipped)
                    {

                    }
                    textelement(station_id)
                    {

                    }
                    textelement(user_id)
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
                    textelement(receipt_id)
                    {

                    }
                    textelement(receipt_dstamp)
                    {

                    }
                    textelement(supplier_id)
                    {

                    }
                    textelement(origin_id)
                    {

                    }
                    textelement(condition_id)
                    {

                    }
                    textelement(lock_status)
                    {

                    }
                    textelement(lock_code)
                    {

                    }
                    textelement(notes)
                    {

                    }
                    textelement(manuf_dstamp)
                    {

                    }
                    textelement(trailer_id)
                    {

                    }
                    textelement(bol_id)
                    {

                    }
                    fieldelement(user_def_type_1; dataheader."Location Code")
                    {

                    }
                    fieldelement(user_def_type_2; dataheader."Source No.")
                    {

                    }
                    //RHE-TNA 13-11-2020 BDS-4695 BEGIN 
                    //fieldelement(user_def_type_3; dataheader."Assembly Order No.")
                    textelement(user_def_type_3)
                    //RHE-TNA 13-11-2020 BDS-4695 END
                    {

                    }
                    //RHE-TNA 13-11-2020 BDS-4695 BEGIN 
                    //fieldelement(user_def_type_4; dataheader."Assembly Line No.")
                    textelement(user_def_type_4)
                    //RHE-TNA 13-11-2020 BDS-4695 END
                    {

                    }
                    textelement(user_def_type_5)
                    {


                    }
                    //RHE-TNA 16-06-2020 BDS-3866 BEGIN
                    //fieldelement(user_def_type_6; dataheader."Assembly Item No.")
                    //{

                    //}
                    textelement(user_def_type_6)
                    {
                        trigger OnAfterAssignVariable()
                        begin
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                dataheader."Assembly Item No." := user_def_type_6;
                            //clear value to ensure correct value on next record
                            user_def_type_6 := '';
                        end;
                    }
                    //RHE-TNA 16-06-2020 BDS-3866 BEGIN
                    textelement(user_def_type_7)
                    {

                    }
                    textelement(user_def_type_8)
                    {
                        trigger OnAfterAssignVariable()
                        begin
                            //RHE-TNA 16-06-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then begin
                                //RHE-TNA 16-06-2020 BDS-3866 END
                                dataheader."Serial/Lot" := dataheader."Serial/Lot"::" ";
                                if user_def_type_8 = 'SERIAL' then
                                    dataheader."Serial/Lot" := dataheader."Serial/Lot"::Serial
                                else
                                    if user_def_type_8 = 'LOT' then
                                        dataheader."Serial/Lot" := dataheader."Serial/Lot"::Lot;
                                //Clear value to be ensure correct value on next record
                                user_def_type_8 := '';
                                //RHE-TNA 16-06-2020 BDS-3866 BEGIN
                            end;
                            //RHE-TNA 16-06-2020 BDS-3866 END
                        end;
                    }
                    textelement(user_def_chk_1)
                    {

                    }
                    textelement(user_def_chk_2)
                    {
                        //RHE-TNA 21-01-2022 BDS-5903 BEGIN
                        trigger OnAfterAssignVariable()
                        begin
                            if user_def_chk_2 = 'Y' then
                                dataheader.Validate("Assembly Line", true);
                            //Clear value to be ensure correct value on next record
                            user_def_chk_2 := '';
                        end;
                        //RHE-TNA 21-01-2022 BDS-5903 END
                    }
                    textelement(user_def_chk_3)
                    {

                    }
                    textelement(user_def_chk_4)
                    {
                        trigger OnAfterAssignVariable()
                        begin
                            //RHE-TNA 10-06-2022 BDS-6043 BEGIN
                            /*
                            if user_def_chk_4 = 'Y' then
                                dataheader.Validate("Assembly Line", true);
                            //Clear value to be ensure correct value on next record
                            user_def_chk_4 := '';
                            */
                            //RHE-TNA 10-06-2022 BDS-6043 END
                        end;
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
                        trigger OnAfterAssignVariable()
                        begin
                            user_def_num_2 := CopyStr(user_def_num_2, 1, StrPos(user_def_num_2, '.'));
                            Evaluate(dataheader."Source Line No.", user_def_num_2);
                        end;
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
                    textelement(time_zone_name)
                    {

                    }
                    textelement(spec_code)
                    {

                    }
                    textelement(qty_delivered)
                    {

                    }
                    textelement(delivered_dstamp)
                    {

                    }
                    textelement(delivered)
                    {

                    }
                    textelement(pod_confirmed)
                    {

                    }
                    textelement(pod_exception_reason)
                    {

                    }
                    textelement(trailer_position)
                    {

                    }
                    textelement(kit_ratio)
                    {

                    }
                    textelement(from_label)
                    {

                    }
                    textelement(to_label)
                    {

                    }
                    textelement(pack_despatch_repack)
                    {

                    }
                    textelement(uploaded)
                    {

                    }
                    textelement(uploaded_vview)
                    {

                    }
                    textelement(sap_tid)
                    {

                    }
                    textelement(sap_pick_id)
                    {

                    }
                    textelement(sap_pick_req)
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
                    textelement(customer_id)
                    {

                    }
                    textelement(pick_label_id)
                    {

                    }
                    textelement(ce_duty_stamp)
                    {

                    }
                    textelement(catch_weight)
                    {

                    }
                    textelement(shipment_number)
                    {

                    }
                    textelement(picked_weight)
                    {

                    }
                    textelement(picked_volume)
                    {

                    }
                    textelement(tracking_level)
                    {

                    }
                    textelement(archived)
                    {

                    }
                    textelement(carrier_id)
                    {

                    }
                    textelement(hub_carrier_id)
                    {

                    }
                    textelement(hub_service_level)
                    {

                    }
                    textelement(service_level)
                    {

                    }
                    textelement(proforma_invoice_num)
                    {

                    }
                    textelement(carrier_container_id)
                    {

                    }
                    textelement(container_weight)
                    {

                    }
                    textelement(container_height)
                    {

                    }
                    textelement(container_width)
                    {

                    }
                    textelement(container_depth)
                    {

                    }
                    textelement(packing_pallet_qty)
                    {

                    }
                    textelement(packing_pallet_type)
                    {

                    }
                    textelement(container_type)
                    {

                    }
                    textelement(container_n_of_n)
                    {

                    }
                    textelement(hub_container_id)
                    {

                    }
                    textelement(labelled)
                    {

                    }
                    textelement(reprint_labels)
                    {

                    }
                    textelement(status)
                    {

                    }
                    textelement(pallet_labelled)
                    {

                    }
                    textelement(load_sequence)
                    {

                    }
                    textelement(ce_order_id)
                    {

                    }
                    textelement(ce_status)
                    {

                    }
                    textelement(ce_reason_notes)
                    {

                    }
                    textelement(ce_instructions)
                    {

                    }
                    textelement(uploaded_customs)
                    {

                    }
                    textelement(customer_shipment_number)
                    {

                    }
                    //RHE-TNA 19-03-2020 BDS-3866 BEGIN
                    textelement(shipment_group)
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
                    textelement(shipment_ref)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(carrier_consignment_num)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(carrier_consignment_id)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(total_volume)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(trolley_slot_id)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(carrier_manifest_number)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(transport_boxes)
                    {
                        MinOccurs = Zero;
                    }
                    //RHE-TNA 19-03-2020 BDS-3866 END
                    trigger OnBeforeInsertRecord()
                    var
                        Day: Integer;
                        Month: Integer;
                        Year: Integer;
                    begin
                        if dataheader."Whse. Document No." <> PrevOrderid then begin
                            //RHE-TNA 06-05-2020 BDS-4213 BEGIN
                            WMSImportHeader.SetRange(Type, WMSImportHeader.Type::Shipment);
                            WMSImportHeader.SetRange(Process, true);
                            WMSImportHeader.SetRange("Whse. Document No.", dataheader."Whse. Document No.");
                            WMSImportHeader.SetRange("Source No.", dataheader."Source No.");
                            //HE-TNA 20-07-2020 BDS-4333 BEGIN
                            //WMSImportHeader.SetRange("Bill Of Lading No.", bol_id);
                            WMSImportHeader.SetRange("Bill Of Lading No.", carrier_consignment_id);
                            //HE-TNA 20-07-2020 BDS-4333 END
                            if not WMSImportHeader.FindFirst() then begin
                                //RHE-TNA 06-05-2020 BDS-4213 END
                                //Enter a header record
                                WMSImportHeader.Init();
                                WMSImportHeader.Insert(true);
                                WMSImportHeader.Validate(type, WMSImportHeader.type::Shipment);
                                WMSImportHeader.Validate("Whse. Document No.", dataheader."Whse. Document No.");
                                WMSImportHeader.Validate("Source No.", dataheader."Source No.");
                                if shipped_dstamp <> '' then begin
                                    Evaluate(Day, CopyStr(shipped_dstamp, 7, 2));
                                    Evaluate(Month, CopyStr(shipped_dstamp, 5, 2));
                                    Evaluate(Year, CopyStr(shipped_dstamp, 1, 4));
                                    WMSImportHeader.Validate("Shipment Date", DMY2Date(Day, Month, Year));
                                end;
                                //HE-TNA 20-07-2020 BDS-4333 BEGIN
                                //WMSImportHeader.Validate("Bill Of Lading No.", Bol_id);
                                WMSImportHeader.Validate("Bill Of Lading No.", carrier_consignment_id);
                                //HE-TNA 20-07-2020 BDS-4333 END
                                WMSImportHeader.Validate("Import Date", Today);
                                WMSImportHeader.Validate(Process, true);
                                //RHE-TNA 30-04-2021 BDS-5304 BEGIN
                                WMSImportHeader.Validate(Carrier, carrier_id);
                                WMSImportHeader.Validate("Service Level", service_level);
                                //RHE-TNA 30-04-2021 BDS-5304 END
                                WMSImportHeader.Modify(true);
                                PrevOrderid := dataheader."Whse. Document No.";
                                //RHE-TNA 06-05-2020 BDS-4213 BEGIN
                            end;
                            PrevOrderid := dataheader."Whse. Document No.";
                            //RHE-TNA 06-05-2020 BDS-4213 END
                        end;
                        dataheader."Entry No." := WMSImportHeader."Entry No.";
                    end;

                    //RHE-TNA 20-03-2020..24-06-2020 BDS-3866 BEGIN
                    trigger OnAfterInsertRecord()
                    var
                        ATOLink: Record "Assemble-to-Order Link";
                        AssHdr: Record "Assembly Header";
                        AssLine: Record "Assembly Line";
                        WMSItemTracking: Record "WMS Import Serial Number";
                        Day: Integer;
                        Month: Integer;
                        Year: Integer;
                    begin
                        if (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016) and (dataheader."Batch Id" <> '') then begin
                            dataheader."Serial/Lot" := dataheader."Serial/Lot"::Lot;
                            dataheader.Modify(false);
                        end;
                        //if (dataheader."Assembly Order No." <> '') and (dataheader."Assembly Item No." = '') then
                        if (dataheader."Assembly Line") and ((dataheader."Assembly Order No." = '') or (dataheader."Assembly Item No." = '')) then begin
                            ATOLink.SetRange(Type, ATOLink.Type::Sale);
                            ATOLink.SetRange("Assembly Document Type", ATOLink."Assembly Document Type"::Order);
                            ATOLink.SetRange("Document Type", ATOLink."Document Type"::Order);
                            ATOLink.SetRange("Document No.", dataheader."Source No.");
                            ATOLink.SetRange("Document Line No.", dataheader."Source Line No.");
                            if ATOLink.FindFirst() then begin
                                if AssHdr.Get(AssHdr."Document Type"::Order, ATOLink."Assembly Document No.") then begin
                                    AssLine.SetRange("Document No.", AssHdr."No.");
                                    AssLine.SetRange(Type, AssLine.Type::Item);
                                    AssLine.SetRange("No.", dataheader."Item No.");
                                    if AssLine.FindFirst() then
                                        dataheader."Assembly Line No." := AssLine."Line No.";
                                    dataheader."Assembly Order No." := AssHdr."No.";
                                    dataheader."Assembly Item No." := AssHdr."Item No.";
                                    dataheader.Modify(false);
                                end;
                            end;
                        end;
                        //RHE-TNA 20-03-2020..24-06-2020 BDS-3866 END

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
                }
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        /*
        IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = WMS.');
        */
        //RHE-TNA 03-02-2022 BDS-5585 END
        //RHE-TNA 14-06-2021 BDS-5337 END
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