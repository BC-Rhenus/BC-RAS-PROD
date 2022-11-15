xmlport 50001 "Export WMS Receipt"

//RHE-TNA 17-03-2020..12-06-2020 BDS-3866
//  - Modified Elements

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreXmlPort()

//  RHE-TNA 12-01-2022 BDS-5585
//  - Modified trigger OnPreXmlPort()
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 13-05-2022 BDS-6330
//  - Modified trigger OnPreXmlPort()
//  - Modified textelement(expiry_dstamp)

//  RHE-AMKE 25-08-2022 BDS-6558
// - Modified textelement(manuf_dstamp)

{
    Direction = Export;
    Format = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;

    schema
    {
        textelement(dcsmergedata)
        {
            textelement(dataheaders)
            {
                tableelement(dataheader; "Warehouse Receipt Header")
                {
                    textattribute(transaction)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            transaction := 'add';
                        end;
                    }
                    textelement(record_type)
                    {

                    }
                    textelement(address1)
                    {

                    }
                    textelement(address2)
                    {

                    }
                    textelement(bookref_id)
                    {

                    }
                    textelement(carrier_name)
                    {

                    }
                    textelement(carrier_reference)
                    {

                    }
                    textelement(ce_consignment_id)
                    {

                    }
                    textelement(client_group)
                    {

                    }
                    textelement(client_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            client_id := IFSetup."WMS Client ID";
                        end;
                    }
                    textelement(collection_reqd)
                    {

                    }
                    textelement(collective_mode)
                    {

                    }
                    textelement(consignment)
                    {

                    }
                    textelement(contact)
                    {

                    }
                    textelement(contact_email)
                    {

                    }
                    textelement(contact_fax)
                    {

                    }
                    textelement(contact_mobile)
                    {

                    }
                    textelement(contact_phone)
                    {

                    }
                    textelement(country)
                    {

                    }
                    textelement(county)
                    {

                    }
                    textelement(disallow_merge_rules)
                    {

                    }
                    textelement(disallow_replens)
                    {

                    }
                    textelement(due_dstamp)
                    {
                        trigger OnBeforePassVariable()
                        var
                            Day: Text[2];
                            Month: Text[2];
                            Year: Text[4];
                            WhseReceiptLine: Record "Warehouse Receipt Line";
                        begin
                            due_dstamp := '';
                            WhseReceiptLine.SetRange("No.", dataheader."No.");
                            if WhseReceiptLine.FindFirst() then begin
                                Day := Format(Date2DMY(WhseReceiptLine."Due Date", 1));
                                if StrLen(Day) < 2 then
                                    Day := '0' + Day;
                                Month := Format(Date2DMY(WhseReceiptLine."Due Date", 2));
                                if StrLen(Month) < 2 then
                                    Month := '0' + Month;
                                Year := Format(Date2DMY(WhseReceiptLine."Due Date", 3));
                            end;
                            due_dstamp := Year + Month + Day + '000000';
                        end;
                    }
                    textelement(email_confirm)
                    {

                    }
                    textelement(load_sequence)
                    {

                    }
                    textelement(master_pre_advice)
                    {

                    }
                    textelement(mode_of_transport)
                    {

                    }
                    textelement(name)
                    {

                    }
                    textelement(notes)
                    {

                    }
                    textelement(owner_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            owner_id := IFSetup."WMS Client ID";
                        end;
                    }
                    textelement(postcode)
                    {

                    }
                    textelement(pre_advice_id)
                    {
                        trigger OnBeforePassVariable()
                        var
                            WhseReceiptLine: Record "Warehouse Receipt Line";
                        begin
                            pre_advice_id := '';
                            WhseReceiptLine.SetRange("No.", dataheader."No.");
                            if WhseReceiptLine.FindFirst() then
                                pre_advice_id := Format(WhseReceiptLine."Source No.");
                        end;
                    }
                    textelement(pre_advice_type)
                    {

                    }
                    textelement(returned_order_id)
                    {

                    }
                    textelement(return_flag)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            return_flag := 'N';
                        end;
                    }
                    textelement(sampling_type)
                    {

                    }
                    textelement(site_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            site_id := IFSetup."WMS Site ID";
                        end;
                    }
                    textelement(status)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            status := 'Released';
                        end;
                    }
                    textelement(supplier_id)
                    {

                    }
                    fieldelement(supplier_reference; dataheader."Vendor Shipment No.")
                    {

                    }
                    textelement(time_zone_name)
                    {

                    }
                    textelement(tod)
                    {

                    }
                    textelement(tod_place)
                    {

                    }
                    textelement(town)
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
                    textelement(user_def_note_1)
                    {

                    }
                    textelement(user_def_note_2)
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
                    textelement(datalines)
                    {
                        tableelement(dataline; "Warehouse Receipt Line")
                        {
                            textattribute(transaction_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    transaction_XMLConvert := 'add';
                                end;
                            }
                            textelement(record_type_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            //RHE-TNA 19-05-2020 BDS-3866 BEGIN
                            //fieldelement(batch_id; dataline."Cross-Dock Bin Code")
                            textelement(batch_id)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    ResEntry: Record "Reservation Entry";
                                begin
                                    batch_id := '';
                                    //Do not send serial numbers
                                    if (dataline."Cross-Dock Bin Code" <> '') and (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016) then begin
                                        ResEntry.SetRange("Source Type", dataline."Source Type");
                                        ResEntry.SetRange("Source Subtype", dataline."Source Subtype");
                                        ResEntry.SetRange("Source ID", dataline."Source No.");
                                        ResEntry.SetRange("Source Ref. No.", dataline."Source Line No.");
                                        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
                                        ResEntry.SetRange("Serial No.", dataline."Cross-Dock Bin Code");
                                        if not ResEntry.FindFirst() then
                                            batch_id := dataline."Cross-Dock Bin Code";
                                    end else
                                        batch_id := dataline."Cross-Dock Bin Code";
                                end;
                            }
                            //RHE-TNA 19-05-2020 BDS-3866 END
                            textelement(ce_consignment_id_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(ce_coo)
                            {

                            }
                            textelement(client_group_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(client_id_XMLConvert)
                            {
                                //WMS Specs require client_id again, but this is already used at header level as textelement.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    client_id_XMLConvert := IFSetup."WMS Client ID";
                                end;
                            }
                            textelement(collective_mode_XMLConvert)
                            {
                                //WMS Specs require client_id again, but this is already used at header level as textelement.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(condition_id)
                            {

                            }
                            textelement(config_id)
                            {

                            }
                            textelement(disallow_merge_rules_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(expiry_dstamp)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    Day: Text[2];
                                    Month: Text[2];
                                    Year: Text[4];
                                    ResEntry: Record "Reservation Entry";
                                    ILE: Record "Item Ledger Entry";
                                begin
                                    expiry_dstamp := '';
                                    if dataline."Cross-Dock Bin Code" <> '' then begin
                                        ResEntry.SetRange("Source Type", dataline."Source Type");
                                        ResEntry.SetRange("Source Subtype", dataline."Source Subtype");
                                        ResEntry.SetRange("Source ID", dataline."Source No.");
                                        ResEntry.SetRange("Source Ref. No.", dataline."Source Line No.");
                                        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
                                        ResEntry.SetRange("Serial No.", dataline."Cross-Dock Bin Code");
                                        if (ResEntry.FindFirst()) and (ResEntry."Expiration Date" <> 0D) then begin
                                            Day := Format(Date2DMY(ResEntry."Expiration Date", 1));
                                            if StrLen(Day) < 2 then
                                                Day := '0' + Day;
                                            Month := Format(Date2DMY(ResEntry."Expiration Date", 2));
                                            if StrLen(Month) < 2 then
                                                Month := '0' + Month;
                                            Year := Format(Date2DMY(ResEntry."Expiration Date", 3));
                                            //RHE-TNA 19-05-2020 BDS-3866 BEGIN
                                            //Clear Cross-Dock Bin Code to not enter data in next elements
                                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then begin
                                                dataline."Cross-Dock Bin Code" := '';
                                                dataline.Modify();
                                            end;
                                            //RHE-TNA 19-05-2020 BDS-3866 END
                                        end else begin
                                            ResEntry.SetRange("Serial No.", '');
                                            ResEntry.SetRange("Lot No.", dataline."Cross-Dock Bin Code");
                                            if (ResEntry.FindFirst()) and (ResEntry."Expiration Date" <> 0D) then begin
                                                Day := Format(Date2DMY(ResEntry."Expiration Date", 1));
                                                if StrLen(Day) < 2 then
                                                    Day := '0' + Day;
                                                Month := Format(Date2DMY(ResEntry."Expiration Date", 2));
                                                if StrLen(Month) < 2 then
                                                    Month := '0' + Month;
                                                Year := Format(Date2DMY(ResEntry."Expiration Date", 3));
                                            end;
                                        end;
                                        expiry_dstamp := Year + Month + Day;
                                        //RHE-TNA 13-05-2022 BDS-6330 BEGIN
                                        //For Transfer Orders check ILE in case expiration date is empty
                                        if (expiry_dstamp = '') and (dataline."Source Type" = 5741) and (dataline."Cross-Dock Bin Code" <> '') then begin
                                            ILE.SetRange("Order Type", ILE."Order Type"::Transfer);
                                            ILE.SetRange("Order No.", dataline."Source No.");
                                            ILE.SetRange("Order Line No.", dataline."Source Line No.");
                                            ILE.SetRange("Item No.", dataline."Item No.");
                                            ILE.SetRange("Location Code", Transfer_Hdr."Transfer-from Code");
                                            ILE.SetRange("Lot No.", dataline."Cross-Dock Bin Code");
                                            if ILE.FindFirst() then begin
                                                Day := Format(Date2DMY(ILE."Expiration Date", 1));
                                                if StrLen(Day) < 2 then
                                                    Day := '0' + Day;
                                                Month := Format(Date2DMY(ILE."Expiration Date", 2));
                                                if StrLen(Month) < 2 then
                                                    Month := '0' + Month;
                                                Year := Format(Date2DMY(ILE."Expiration Date", 3));
                                            end;
                                            expiry_dstamp := Year + Month + Day;
                                        end;
                                        //RHE-TNA 13-05-2022 BDS-6330 END
                                        if expiry_dstamp <> '' then
                                            expiry_dstamp := expiry_dstamp + '000000';
                                    end;
                                end;
                            }
                            textelement(host_line_id)
                            {

                            }
                            textelement(host_pre_advice_id)
                            {

                            }
                            textelement(line_id)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    LineId := LineId + 1;
                                    line_id := Format(LineId);
                                end;
                            }
                            textelement(lock_code)
                            {

                            }
                            textelement(manuf_dstamp)
                            {
                                // RHE-AMKE 25-08-2022 BDS-6558 Begin
                                trigger OnBeforePassVariable()
                                var
                                    Day: Text[2];
                                    Month: Text[2];
                                    Year: Text[4];
                                begin
                                    manuf_dstamp := '';
                                    Purch_Line.SetRange(Purch_Line."Document No.", dataline."Source No.");
                                    Purch_Line.SetRange(Purch_Line."Line No.", dataline."Source Line No.");
                                    Purch_Line.SetRange(Purch_Line."No.", dataline."Item No.");
                                    if (Purch_Line.FindFirst()) and (Purch_Line."Manufacture Date" <> 0D) then begin
                                        Day := Format(Date2DMY(Purch_Line."Manufacture Date", 1));
                                        if StrLen(Day) < 2 then
                                            Day := '0' + Day;
                                        Month := Format(Date2DMY(Purch_Line."Manufacture Date", 2));
                                        if StrLen(Month) < 2 then
                                            Month := '0' + Month;
                                        Year := Format(Date2DMY(Purch_Line."Manufacture Date", 3));

                                        manuf_dstamp := Year + Month + Day + '000000';
                                    end;

                                end;
                                // RHE-AMKE 25-08-2022 BDS-6558 End
                            }
                            textelement(notes_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(origin_id)
                            {

                            }
                            textelement(owner_id_XMLConvert)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    //WMS required this attribute on header and line level.
                                    //_XMLConvert will be deleted in the report which calls this XMLport
                                    owner_id_XMLConvert := IFSetup."WMS Client ID";
                                end;
                            }
                            textelement(pallet_config)
                            {

                            }
                            fieldelement(pre_advice_id; dataline."Source No.")
                            {

                            }
                            textelement(qty_due)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    qty_due := Format(dataline.Quantity);
                                    if not DecimalSignIsComma then begin
                                        if StrPos(qty_due, ',') <> 0 then
                                            qty_due := DelChr(qty_due, '=', ',');
                                    end else begin
                                        if StrPos(qty_due, ',') <> 0 then
                                            qty_due := ConvertStr(qty_due, ',', '.');
                                    end;
                                end;
                            }
                            textelement(qty_due_tolerance)
                            {

                            }
                            //RHE-TNA 17-03-2020..19-05-2020 BDS-3866 BEGIN
                            textelement(serial_valid_merge)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    ResEntry: record "Reservation Entry";
                                begin
                                    if IFSetup."WMS Version" <> IFSetup."WMS Version"::WMS2016 then
                                        currXMLport.Skip();
                                    serial_valid_merge := 'N';
                                    ResEntry.SetRange("Source Type", dataline."Source Type");
                                    ResEntry.SetRange("Source Subtype", dataline."Source Subtype");
                                    ResEntry.SetRange("Source ID", dataline."Source No.");
                                    ResEntry.SetRange("Source Ref. No.", dataline."Source Line No.");
                                    ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
                                    ResEntry.SetFilter("Serial No.", '<>%1', '');
                                    if ResEntry.FindSet() then
                                        serial_valid_merge := 'Y';
                                end;
                            }
                            //RHE-TNA 17-03-2020..19-05-2020 BDS-3866 BEGIN
                            fieldelement(sku_id; dataline."Item No.")
                            {

                            }
                            textelement(spec_code)
                            {

                            }
                            //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                            //fieldelement(tag_id; dataline."Cross-Dock Bin Code")
                            textelement(tag_id)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    tag_id := '';
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        tag_id := dataline."Cross-Dock Bin Code";
                                end;
                            }
                            //RHE-TNA 22-05-2020 BDS-3866 END
                            textelement(time_zone_name_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(tracking_level)
                            {

                            }
                            textelement(user_def_chk_1_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_chk_2_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_chk_3_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_chk_4_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_date_1_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_date_2_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_date_3_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_date_4_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_note_1_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_note_2_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                            //fieldelement(user_def_num_1; dataline."Source Type")
                            textelement(user_def_num_1_XMLConvert)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        user_def_num_1_XMLConvert := Format(dataline."Source Type");
                                end;
                                //RHE-TNA 22-05-2020 BDS-3866 END
                            }
                            textelement(user_def_num_2_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                var
                                    ResEntry: Record "Reservation Entry";
                                begin
                                    user_def_num_2_XMLConvert := '';
                                    //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                                    //if dataline."Cross-Dock Bin Code" <> '' then begin
                                    if (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009) and (dataline."Cross-Dock Bin Code" <> '') then begin
                                        //RHE-TNA 22-05-2020 BDS-3866 END
                                        ResEntry.SetRange("Source Type", dataline."Source Type");
                                        ResEntry.SetRange("Source Subtype", dataline."Source Subtype");
                                        ResEntry.SetRange("Source ID", dataline."Source No.");
                                        ResEntry.SetRange("Source Ref. No.", dataline."Source Line No.");
                                        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
                                        ResEntry.SetRange("Serial No.", dataline."Cross-Dock Bin Code");
                                        if ResEntry.FindFirst() then
                                            user_def_num_2_XMLConvert := Format(ResEntry."Entry No.")
                                        else begin
                                            ResEntry.SetRange("Serial No.", '');
                                            ResEntry.SetRange("Lot No.", dataline."Cross-Dock Bin Code");
                                            if ResEntry.FindFirst() then
                                                user_def_num_2_XMLConvert := Format(ResEntry."Entry No.");
                                        end;
                                    end;
                                end;
                            }
                            textelement(user_def_num_3_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                                    //user_def_num_3_XMLConvert := dataline."Shelf No.";
                                    user_def_num_3_XMLConvert := '';
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        user_def_num_3_XMLConvert := dataline."Shelf No.";
                                    //RHE-TNA 22-05-2020 BDS-3866 END
                                end;
                            }
                            textelement(user_def_num_4_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            fieldelement(user_def_type_1; dataline."Location Code")
                            {

                            }
                            textelement(user_def_type_2_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                        user_def_type_2_XMLConvert := ''
                                    else
                                        //RHE-TNA 22-05-2020 BDS-3866 END
                                        user_def_type_2_XMLConvert := dataline."No.";
                                    if StrPos(user_def_type_2_XMLConvert, 'XML') > 0 then
                                        user_def_type_2_XMLConvert := DelChr(user_def_type_2_XMLConvert, '=', 'XML')
                                end;
                            }
                            fieldelement(user_def_type_3; dataline."Source Line No.")
                            {

                            }
                            textelement(user_def_type_4_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    user_def_type_4_XMLConvert := '';
                                    if dataline."Cross-Dock Bin Code" <> '' then
                                        user_def_type_4_XMLConvert := Format(dataline."Source Type");
                                end;
                            }
                            textelement(user_def_type_5_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    user_def_type_5_XMLConvert := '';
                                    //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                                    //if dataline."Cross-Dock Bin Code" <> '' then
                                    if (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009) and (dataline."Cross-Dock Bin Code" <> '') then
                                        //RHE-TNA 22-05-2020 BDS-3866 END
                                        user_def_type_5_XMLConvert := Format(dataline."Source No.");
                                end;
                            }
                            textelement(user_def_type_6_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    user_def_type_6_XMLConvert := '';
                                    //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                                    //if dataline."Cross-Dock Bin Code" <> '' then
                                    if (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009) and (dataline."Cross-Dock Bin Code" <> '') then
                                        //RHE-TNA 22-05-2020 BDS-3866 END
                                        user_def_type_6_XMLConvert := Format(dataline."Source Line No.");
                                end;
                            }
                            textelement(user_def_type_7_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                            }
                            textelement(user_def_type_8_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                var
                                    ResEntry: Record "Reservation Entry";
                                begin
                                    user_def_type_8_XMLConvert := '';
                                    //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                                    //if dataline."Cross-Dock Bin Code" <> '' then
                                    if (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009) and (dataline."Cross-Dock Bin Code" <> '') then begin
                                        //RHE-TNA 22-05-2020 BDS-3866 END
                                        ResEntry.SetRange("Source Type", dataline."Source Type");
                                        ResEntry.SetRange("Source Subtype", dataline."Source Subtype");
                                        ResEntry.SetRange("Source ID", dataline."Source No.");
                                        ResEntry.SetRange("Source Ref. No.", dataline."Source Line No.");
                                        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
                                        ResEntry.SetRange("Serial No.", dataline."Cross-Dock Bin Code");
                                        if ResEntry.FindFirst() then
                                            user_def_type_8_XMLConvert := Format(ResEntry."Item Tracking")
                                        else begin
                                            ResEntry.SetRange("Serial No.", '');
                                            ResEntry.SetRange("Lot No.", dataline."Cross-Dock Bin Code");
                                            if ResEntry.FindFirst() then
                                                user_def_type_8_XMLConvert := Format(ResEntry."Item Tracking");
                                        end;
                                    end;
                                end;
                            }
                            trigger OnPreXmlItem()
                            var
                                WhseReceiptLine: Record "Warehouse Receipt Line";
                                WhseReceiptLine2: Record "Warehouse Receipt Line";
                                WhseReceiptLine3: Record "Warehouse Receipt Line";
                                ResEntry: Record "Reservation Entry";
                                WhseReceiptNo: Text[20];
                            begin
                                WhseReceiptLine.SetRange("No.", dataheader."No.");
                                if WhseReceiptLine.FindSet() then
                                    repeat
                                        //Create dummy lines incl. Reservation entries to loop through
                                        WhseReceiptNo := 'XML' + WhseReceiptLine."No.";
                                        WhseReceiptLine2.Init();
                                        WhseReceiptLine2.Copy(WhseReceiptLine);
                                        WhseReceiptLine2."No." := WhseReceiptNo;

                                        ResEntry.SetRange("Source Type", WhseReceiptLine."Source Type");
                                        ResEntry.SetRange("Source Subtype", WhseReceiptLine."Source Subtype");
                                        ResEntry.SetRange("Source ID", WhseReceiptLine."Source No.");
                                        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
                                        //RHE-TNA 12-06-2020 BDS-3866 BEGIN
                                        if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                            ResEntry.SetFilter("Lot No.", '<>%1', '');
                                        //RHE-TNA 12-06-2020 BDS-3866 END
                                        repeat
                                            //RHE-TNA 13-05-2022 BDS-6330 BEGIN
                                            //ResEntry.SetRange("Source Ref. No.", WhseReceiptLine."Source Line No.");
                                            if WhseReceiptLine."Source Type" <> 5741 then
                                                ResEntry.SetRange("Source Ref. No.", WhseReceiptLine."Source Line No.")
                                            else
                                                ResEntry.SetRange("Source Prod. Order Line", WhseReceiptLine."Source Line No.");
                                            //RHE-TNA 13-05-2022 BDS-6330 END
                                            if ResEntry.FindSet() then begin
                                                repeat
                                                    WhseReceiptLine2."Line No." := WhseReceiptLine."Line No." + 1;
                                                    WhseReceiptLine3.SetRange("No.", WhseReceiptNo);
                                                    if WhseReceiptLine3.FindLast() then begin
                                                        if WhseReceiptLine2."Line No." <= WhseReceiptLine3."Line No." then
                                                            WhseReceiptLine2."Line No." := WhseReceiptLine3."Line No." + 1;
                                                    end;
                                                    WhseReceiptLine2.Quantity := ResEntry.Quantity;
                                                    //Set field Shelf No. to store the original Whse. Receipt Line No.
                                                    WhseReceiptLine2."Shelf No." := Format(WhseReceiptLine."Line No.");
                                                    //Set field Cross-Dock Bin Code to store the Serial/Lot No
                                                    if ResEntry."Serial No." <> '' then begin
                                                        WhseReceiptLine2."Cross-Dock Bin Code" := ResEntry."Serial No.";
                                                    end else
                                                        if ResEntry."Lot No." <> '' then begin
                                                            WhseReceiptLine2."Cross-Dock Bin Code" := ResEntry."Lot No.";
                                                        end;
                                                    //Set field Zone Code to know this is a line to be deleted.
                                                    WhseReceiptLine2."Zone Code" := 'XML50005';
                                                    WhseReceiptLine2.Insert(false);
                                                until ResEntry.Next() = 0;
                                            end else begin
                                                //Set field Shelf No. to store the original Whse. Receipt Line No.
                                                WhseReceiptLine2."Shelf No." := Format(WhseReceiptLine."Line No.");
                                                //Set field Zone Code to know this is a line to be deleted.
                                                WhseReceiptLine2."Zone Code" := 'XML50005';
                                                WhseReceiptLine2.Insert(false);
                                            end;
                                        until ResEntry.Next() = 0;
                                    until WhseReceiptLine.Next() = 0;
                                dataline.SetRange("No.", WhseReceiptNo);
                            end;
                        }
                    }


                    trigger OnAfterGetRecord()
                    var
                        WhseReceiptLine: Record "Warehouse Receipt Line";
                    begin
                        WhseReceiptLine.SetRange("No.", dataheader."No.");
                        if WhseReceiptLine.FindFirst() then begin
                            if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Sales Return Order" then begin
                                Sales_Hdr.Get(Sales_Hdr."Document Type"::"Return Order", WhseReceiptLine."Source No.");
                                Source_Doc := Source_Doc::S_Order;
                            end;
                            if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Purchase Order" then begin
                                Purch_Hdr.Get(Purch_Hdr."Document Type"::Order, WhseReceiptLine."Source No.");
                                Source_Doc := Source_Doc::P_Order;
                            end;
                            if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Inbound Transfer" then begin
                                Transfer_Hdr.Get(WhseReceiptLine."Source No.");
                                Source_Doc := Source_Doc::T_Order;
                            end;
                        end;

                        //RHE-TNA 12-01-2022 BDS-5585 BEGIN
                        IFSetup.GetWMSIFSetupEntryNo(dataheader."Location Code");
                        //RHE-TNA 12-01-2022 BDS-5585 END
                    end;
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        //Check if the decimal sign is a comma
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        //RHE-TNA 12-01-2022 BDS-5585 BEGIN
        /*
        IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Active, true);
        IFSetup.FindFirst();
        //RHE-TNA 14-06-2021 BDS-5337 END
        IFSetup.TestField("WMS Client ID");
        IFSetup.TestField("WMS Site ID");
        IFSetup.TestField("WMS Upload Directory");
        */
        //RHE-TNA 12-01-2022 BDS-5585 END
    end;

    trigger OnPostXmlPort()
    var
        WhseReceipLine: Record "Warehouse Receipt Line";
    begin
        //Delete created Whse receipt lines which are based on reservation entries
        WhseReceipLine.SetRange("Zone Code", 'XML50005');
        WhseReceipLine.DeleteAll(false);
    end;

    //Global Variables
    var
        IFSetup: Record "Interface Setup";
        Sales_Hdr: Record "Sales Header";
        Purch_Hdr: Record "Purchase Header";
        Transfer_Hdr: Record "Transfer Header";
        Purch_Line: Record "Purchase Line";
        Source_Doc: Option S_Order,P_Order,T_Order;
        DecimalSignIsComma: Boolean;
        LineId: Integer;
}