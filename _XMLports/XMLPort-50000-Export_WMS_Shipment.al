xmlport 50000 "Export WMS Shipment"

//  RHE-TNA 17-03-2020..16-06-2020 BDS-3866
//  - Modified schema

//  RHE-TNA 19-11-2020..25-11-2020 BDS-4695
//  - Modified schema

//  RHE-TNA 07-12-2020 BDS-4733
//  - Modified schema

// RHE-TNA 05-01-2021 BDS-4828
//  - Modified element contact_email

// RHE-TNA 30-04-2021 BDS-5306
//  - Modified element inv_total_1

// RHE-TNA 11-06-2021 BDS-5385
//  - Modified element product_price 
//  - Modified element inv_currency
//  - Modified element product_currency
//  - Modified element inv_total_1

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreXmlPort()

//  RHE-TNA 26-08-2021..01-09-2021 BDS-5584
//  - Modified element product_price
//  - Modified element inv_total_1
//  - Modified element inv_total_2
//  - Modified element user_def_num_3_XMLConvert

//  RHE-TNA 24-11-2021 BDS-5858
//  - Modified textelement(seller_name)

//  RHE-TNA 22-12-2021..23-12-2021 PM-1328
//  - Modified element inv_total_1
//  - Modified element product_price
//  - Modified element user_def_num_3_XMLConvert

//  RHE-TNA 21-01-2022 BDS-5903
//  - Added textelement(user_def_chk_2_XMLConvert)

//  RHE-TNA 12-01-2022 BDS-5585
//  - Modified trigger OnPreXmlPort()
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 12-01-2022 BDS-5564
//  - Modified trigger OnPreXmlPort()

//  RHE-TNA 25-03-2025 BDS-6200
//  - Modified element contact_email
//  - Modified element contact_phone

//  RHE-TNA 18-05-2022 BDS-6350
//  - Modified textelement(documentation_text_2)

//  RHE-TNA 03-06-2022 BDS-6043
//  - Modified textelement(user_def_chk_4_XMLConvert)

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
                tableelement(dataheader; "Warehouse Shipment Header")
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
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        address1 := Sales_Hdr."Ship-to Address";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        address1 := Purch_Hdr."Ship-to Address";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        address1 := Transfer_Hdr."Transfer-to Address";
                                    end;
                            end;
                            if StrLen(address1) > 35 then
                                address1 := CopyStr(address1, 1, 35);
                        end;
                    }
                    textelement(address2)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        address2 := Sales_Hdr."Ship-to Address 2";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        address2 := Purch_Hdr."Ship-to Address 2";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        address2 := Transfer_Hdr."Transfer-to Address 2";
                                    end;
                            end;
                            if StrLen(address2) > 35 then
                                address2 := CopyStr(address2, 1, 35);
                        end;
                    }
                    textelement(cancel_reason_code)
                    {
                        //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                        trigger OnBeforePassVariable()
                        begin
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                        end;
                        //RHE-TNA 17-03-2020 BDS-3866 END
                    }
                    textelement(carrier_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 14-04-2020 BDS-3866 BEGIN
                            carrier_id := '';
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then begin
                                //RHE-TNA 14-04-2020 BDS-3866 END
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            carrier_id := Sales_Hdr."Shipping Agent Code";
                                        end;
                                    Source_Doc::T_Order:
                                        begin
                                            carrier_id := Transfer_Hdr."Shipping Agent Code";
                                        end;
                                end;
                                //RHE-TNA 14-04-2020 BDS-3866 BEGIN
                            end;
                            //RHE-TNA 14-04-2020 BDS-3866 END
                        end;
                    }
                    textelement(ce_customs_customer)
                    {

                    }
                    textelement(ce_excise_customer)
                    {

                    }
                    textelement(ce_instructions)
                    {

                    }
                    textelement(ce_order_type)
                    {

                    }
                    textelement(ce_reason_code)
                    {

                    }
                    textelement(ce_reason_notes)
                    {

                    }
                    textelement(cheapest_carrier)
                    {

                    }
                    textelement(cid_number)
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
                    textelement(cod)
                    {

                    }
                    textelement(cod_currency)
                    {

                    }
                    textelement(cod_type)
                    {

                    }
                    textelement(cod_value)
                    {

                    }
                    textelement(collective_mode)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            collective_mode := 'Y';
                        end;
                    }
                    textelement(consignment)
                    {

                    }
                    textelement(contact)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        contact := Sales_Hdr."Ship-to Contact";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        contact := Purch_Hdr."Ship-to Contact";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        contact := Transfer_Hdr."Transfer-to Contact";
                                    end;
                            end;
                            if StrLen(contact) > 25 then
                                contact := CopyStr(contact, 1, 25);
                        end;
                    }
                    textelement(contact_email)
                    {
                        trigger OnBeforePassVariable()

                        var
                            Customer: Record Customer;
                            Vendor: Record Vendor;
                            Location: Record Location;
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        //RHE-TNA 05-01-2021 BDS-4828 BEGIN
                                        //if Sales_Hdr."E-mail" <> '' then
                                        //    contact_email := Sales_Hdr."E-mail"
                                        if Sales_Hdr."Sell-to E-Mail" <> '' then
                                            contact_email := Sales_Hdr."Sell-to E-Mail"
                                        //RHE-TNA 05-01-2021 BDS-4828 END
                                        else
                                            if Customer.Get(Sales_Hdr."Sell-to Customer No.") then
                                                contact_email := Customer."E-Mail";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        if Vendor.Get(Purch_Hdr."Buy-from Vendor No.") then
                                            contact_email := Vendor."E-Mail";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        //RHE-TNA 25-03-2025 BDS-6200 BEGIN
                                        //if Location.Get() then
                                        if Location.Get(Transfer_Hdr."Transfer-to Code") then
                                            //RHE-TNA 25-03-2025 BDS-6200 END
                                            contact_email := Location."E-Mail";
                                    end;
                            end;
                        end;
                    }
                    textelement(contact_fax)
                    {

                    }
                    textelement(contact_mobile)
                    {

                    }
                    textelement(contact_phone)
                    {
                        trigger OnBeforePassVariable()

                        var
                            Customer: Record Customer;
                            Vendor: Record Vendor;
                            Location: Record Location;
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if Sales_Hdr."Ship-to Phone No." <> '' then
                                            contact_phone := Sales_Hdr."Ship-to Phone No."
                                        else
                                            if Customer.Get(Sales_Hdr."Sell-to Customer No.") then
                                                contact_phone := Customer."Phone No.";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        if Vendor.Get(Purch_Hdr."Buy-from Vendor No.") then
                                            contact_phone := Vendor."Phone No.";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        //RHE-TNA 25-03-2025 BDS-6200 BEGIN
                                        //if Location.Get() then
                                        if Location.Get(Transfer_Hdr."Transfer-to Code") then
                                            //RHE-TNA 25-03-2025 BDS-6200 END
                                            contact_phone := Location."Phone No.";
                                    end;
                            end;
                            if StrLen(contact_phone) > 25 then
                                contact_phone := CopyStr(contact_phone, 1, 25);
                        end;
                    }
                    textelement(country)
                    {
                        trigger OnBeforePassVariable()

                        begin
                            country := '';
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if (Reccountry.Get(Sales_Hdr."Ship-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                            country := RecCountry."ISO3 Code";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        if (RecCountry.Get(Purch_Hdr."Ship-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                            country := RecCountry."ISO3 Code";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        if (RecCountry.Get(Transfer_Hdr."Trsf.-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                            country := RecCountry."ISO3 Code";
                                    end;
                            end;
                        end;
                    }
                    textelement(county)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        county := Sales_Hdr."Ship-to County";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        county := Purch_Hdr."Ship-to County";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        county := Transfer_Hdr."Transfer-to County";
                                    end;
                            end;
                        end;
                    }
                    textelement(cross_dock_to_site)
                    {

                    }
                    textelement(customer_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        customer_id := Sales_Hdr."Sell-to Customer No.";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        customer_id := Purch_Hdr."Buy-from Vendor No.";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        customer_id := Transfer_Hdr."Transfer-to Code";
                                    end;
                            end;
                        end;
                    }
                    textelement(delivered_dstamp)
                    {

                    }
                    textelement(delivery_point)
                    {

                    }
                    textelement(deliver_by_date)
                    {
                        trigger OnBeforePassVariable()

                        var
                            Day: Text[2];
                            Month: Text[2];
                            Year: Text[4];
                        begin
                            deliver_by_date := '';
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then begin
                                            Day := Format(Date2DMY(Sales_Hdr."Due Date", 1));
                                            Month := Format(Date2DMY(Sales_Hdr."Due Date", 2));
                                            Year := Format(Date2DMY(Sales_Hdr."Due Date", 3));
                                        end else
                                            if Sales_Hdr."Requested Delivery Date" <> 0D then begin
                                                Day := Format(Date2DMY(Sales_Hdr."Requested Delivery Date", 1));
                                                Month := Format(Date2DMY(Sales_Hdr."Requested Delivery Date", 2));
                                                Year := Format(Date2DMY(Sales_Hdr."Requested Delivery Date", 3));
                                            end;
                                        if (StrLen(Day) > 0) and (StrLen(Day) < 2) then
                                            Day := '0' + Day;
                                        if (StrLen(Month) > 0) and (StrLen(Month) < 2) then
                                            Month := '0' + Month;
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then begin
                                            Day := Format(Date2DMY(Purch_Hdr."Due Date", 1));
                                            Month := Format(Date2DMY(Purch_Hdr."Due Date", 2));
                                            Year := Format(Date2DMY(Purch_Hdr."Due Date", 3));
                                        end else
                                            if Purch_Hdr."Expected Receipt Date" <> 0D then begin
                                                Day := Format(Date2DMY(Purch_Hdr."Expected Receipt Date", 1));
                                                Month := Format(Date2DMY(Purch_Hdr."Expected Receipt Date", 2));
                                                Year := Format(Date2DMY(Purch_Hdr."Expected Receipt Date", 3));
                                            end;
                                        if (StrLen(Day) > 0) and (StrLen(Day) < 2) then
                                            Day := '0' + Day;
                                        if (StrLen(Month) > 0) and (StrLen(Month) < 2) then
                                            Month := '0' + Month;
                                    end;
                            end;
                            //Convert to YYYYMMDD24HHMMSS
                            if deliver_by_date <> '' then
                                deliver_by_date := Year + Month + Day + '000000';
                        end;
                    }
                    textelement(disallow_merge_rules)
                    {

                    }
                    textelement(disallow_short_ship)
                    {

                    }
                    textelement(discount)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        discount := Format(Sales_Hdr."Payment Discount %");
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        discount := Format(Purch_Hdr."Payment Discount %");
                                    end;
                            end;
                            if not DecimalSignIsComma then begin
                                if StrPos(discount, ',') <> 0 then
                                    discount := DelChr(discount, '=', ',');
                            end else begin
                                if StrPos(discount, ',') <> 0 then
                                    discount := ConvertStr(discount, ',', '.');
                            end;
                        end;
                    }
                    textelement(dispatch_method)
                    {
                        //RHE-TNA 14-04-2020 BDS-3866 BEGIN
                        trigger OnBeforePassVariable()
                        var
                            ShipAgentService: Record "Shipping Agent Services";
                        begin
                            dispatch_method := '';
                            if IFSetup."WMS Version" <> IFSetup."WMS Version"::WMS2009 then begin
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            if ShipAgentService.Get(Sales_Hdr."Shipping Agent Code", Sales_Hdr."Shipping Agent Service Code") then
                                                dispatch_method := ShipAgentService."WMS Dispatch Method";
                                        end;
                                    Source_Doc::T_Order:
                                        begin
                                            if ShipAgentService.Get(Transfer_Hdr."Shipping Agent Code", Transfer_Hdr."Shipping Agent Service Code") then
                                                dispatch_method := ShipAgentService."WMS Dispatch Method";
                                        end;
                                end;
                            end;
                        end;
                        //RHE-TNA 14-04-2020 BDS-3866 END
                    }
                    textelement(documentation_text_1)
                    {
                        //RHE-TNA 16-06-2020 BDS-3866 BEGIN
                        trigger OnBeforePassVariable()
                        begin
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then begin
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            documentation_text_1 := Sales_Hdr."Customer Comment Text";
                                            if StrLen(documentation_text_1) > 180 then
                                                documentation_text_1 := CopyStr(documentation_text_1, 1, 180);
                                        end;
                                end;
                            end;
                        end;
                        //RHE-TNA 16-06-2020 BDS-3866 END
                    }
                    textelement(documentation_text_2)
                    {
                        //RHE-TNA 18-05-2022 BDS-6350 BEGIN
                        trigger OnBeforePassVariable()
                        begin
                            documentation_text_2 := Sales_Hdr."Your Reference";
                        end;
                        //RHE-TNA 18-05-2022 BDS-6350 END
                    }
                    textelement(documentation_text_3)
                    {

                    }
                    textelement(expected_value)
                    {

                    }
                    textelement(expected_volume)
                    {

                    }
                    textelement(expected_weight)
                    {

                    }
                    textelement(export)
                    {

                    }
                    textelement(fastest_carrier)
                    {

                    }
                    textelement(force_single_carrier)
                    {

                    }
                    textelement(freight_charges)
                    {
                        trigger OnBeforePassVariable()
                        var
                            Customer: Record Customer;
                        begin
                            if Source_Doc = Source_Doc::S_Order then begin
                                if Customer.Get(Sales_Hdr."Sell-to Customer No.") then
                                    freight_charges := Format(Customer."WMS Freight Charges");
                            end;
                        end;
                    }
                    textelement(freight_cost)
                    {

                    }
                    textelement(freight_terms)
                    {

                    }
                    textelement(from_site_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            from_site_id := IFSetup."WMS Site ID";
                        end;
                    }
                    textelement(hub_address1)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ShippingAgentService: Record "Shipping Agent Services";
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if Sales_Hdr."Shipping Agent Service Code" <> '' then begin
                                            if (ShippingAgentService.Get(Sales_Hdr."Shipping Agent Code", Sales_Hdr."Shipping Agent Service Code")) and (ShippingAgentService.Hub) then
                                                hub_address1 := Sales_Hdr."Ship-to Address";
                                        end;
                                    end;
                            end;
                        end;
                    }
                    textelement(hub_address2)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ShippingAgentService: Record "Shipping Agent Services";
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if Sales_Hdr."Shipping Agent Service Code" <> '' then begin
                                            if (ShippingAgentService.Get(Sales_Hdr."Shipping Agent Code", Sales_Hdr."Shipping Agent Service Code")) and (ShippingAgentService.Hub) then
                                                hub_address2 := Sales_Hdr."Ship-to Address 2";
                                        end;
                                    end;
                            end;
                        end;
                    }
                    textelement(hub_address_id)
                    {

                    }
                    textelement(hub_carrier_id)
                    {

                    }
                    textelement(hub_contact)
                    {

                    }
                    textelement(hub_contact_email)
                    {

                    }
                    textelement(hub_contact_fax)
                    {

                    }
                    textelement(hub_contact_mobile)
                    {

                    }
                    textelement(hub_contact_phone)
                    {

                    }
                    textelement(hub_country)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ShippingAgentService: Record "Shipping Agent Services";
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if Sales_Hdr."Shipping Agent Service Code" <> '' then begin
                                            if (ShippingAgentService.Get(Sales_Hdr."Shipping Agent Code", Sales_Hdr."Shipping Agent Service Code")) and (ShippingAgentService.Hub) then
                                                hub_country := Sales_Hdr."Ship-to Country/Region Code";
                                        end;
                                    end;
                            end;
                        end;
                    }
                    textelement(hub_county)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ShippingAgentService: Record "Shipping Agent Services";
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if Sales_Hdr."Shipping Agent Service Code" <> '' then begin
                                            if (ShippingAgentService.Get(Sales_Hdr."Shipping Agent Code", Sales_Hdr."Shipping Agent Service Code")) and (ShippingAgentService.Hub) then
                                                hub_county := Sales_Hdr."Ship-to County";
                                        end;
                                    end;
                            end;
                        end;
                    }
                    textelement(hub_name)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ShippingAgentService: Record "Shipping Agent Services";
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if Sales_Hdr."Shipping Agent Service Code" <> '' then begin
                                            if (ShippingAgentService.Get(Sales_Hdr."Shipping Agent Code", Sales_Hdr."Shipping Agent Service Code")) and (ShippingAgentService.Hub) then
                                                hub_name := Sales_Hdr."Ship-to Name";
                                        end;
                                    end;
                            end;
                        end;
                    }
                    textelement(hub_postcode)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ShippingAgentService: Record "Shipping Agent Services";
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if Sales_Hdr."Shipping Agent Service Code" <> '' then begin
                                            if (ShippingAgentService.Get(Sales_Hdr."Shipping Agent Code", Sales_Hdr."Shipping Agent Service Code")) and (ShippingAgentService.Hub) then
                                                hub_postcode := Sales_Hdr."Ship-to Post Code";
                                        end;
                                    end;
                            end;
                        end;
                    }
                    textelement(hub_service_level)
                    {

                    }
                    textelement(hub_town)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ShippingAgentService: Record "Shipping Agent Services";
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if Sales_Hdr."Shipping Agent Service Code" <> '' then begin
                                            if (ShippingAgentService.Get(Sales_Hdr."Shipping Agent Code", Sales_Hdr."Shipping Agent Service Code")) and (ShippingAgentService.Hub) then
                                                hub_town := Sales_Hdr."Ship-to City";
                                        end;
                                    end;
                            end;
                        end;
                    }
                    textelement(hub_vat_number)
                    {
                        trigger OnBeforePassVariable()
                        var
                            Customer: Record Customer;
                        begin
                            if Source_Doc = Source_Doc::S_Order then begin
                                if (Customer.Get(Sales_Hdr."Sell-to Customer No.")) and (Customer."WMS Freight Charges" <> Customer."WMS Freight Charges"::" ") then
                                    hub_vat_number := Format(Customer."WMS Hub Vat Number");
                            end;
                        end;
                    }
                    textelement(instructions)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 16-06-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then begin
                                //RHE-TNA 16-06-2020 BDS-3866 END
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            instructions := Sales_Hdr."Customer Comment Text";
                                            if StrLen(instructions) > 180 then
                                                instructions := CopyStr(instructions, 1, 180);
                                        end;
                                end;
                                //RHE-TNA 16-06-2020 BDS-3866 BEGIN
                            end;
                            //RHE-TNA 16-06-2020 BDS-3866 END
                        end;
                    }
                    textelement(insurance_cost)
                    {

                    }
                    textelement(inv_address1)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_address1 := Sales_Hdr."Bill-to Address";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_address1 := Purch_Hdr."Pay-to Address";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        inv_address1 := Transfer_Hdr."Transfer-to Address";
                                    end;
                            end;
                            if StrLen(inv_address1) > 35 then
                                inv_address1 := CopyStr(inv_address1, 1, 35);
                        end;
                    }
                    textelement(inv_address2)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_address2 := Sales_Hdr."Bill-to Address 2";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_address2 := Purch_Hdr."Pay-to Address 2";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        inv_address2 := Transfer_Hdr."Transfer-to Address 2";
                                    end;
                            end;
                            if StrLen(inv_address2) > 35 then
                                inv_address2 := CopyStr(inv_address2, 1, 35);
                        end;
                    }
                    textelement(inv_address_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_address_id := Sales_Hdr."Bill-to Customer No.";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_address_id := Purch_Hdr."Pay-to Vendor No.";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        inv_address_id := Transfer_Hdr."Transfer-to Code";
                                    end;
                            end;
                        end;
                    }
                    textelement(inv_contact)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_contact := Sales_Hdr."Bill-to Contact";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_contact := Purch_Hdr."Pay-to Contact";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        inv_contact := Transfer_Hdr."Transfer-to Contact";
                                    end;
                            end;
                            if StrLen(inv_contact) > 25 then
                                inv_contact := CopyStr(inv_contact, 1, 25);
                        end;
                    }
                    textelement(inv_contact_email)
                    {

                    }
                    textelement(inv_contact_fax)
                    {

                    }
                    textelement(inv_contact_mobile)
                    {

                    }
                    textelement(inv_contact_phone)
                    {

                    }
                    textelement(inv_country)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            inv_country := '';
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        if (RecCountry.Get(Sales_Hdr."Bill-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                            inv_country := RecCountry."ISO3 Code";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        if (RecCountry.Get(Purch_Hdr."Pay-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                            inv_country := RecCountry."ISO3 Code";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        if (RecCountry.Get(Transfer_Hdr."Trsf.-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                            inv_country := RecCountry."ISO3 Code";
                                    end;
                            end;
                        end;
                    }
                    textelement(inv_county)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_county := Sales_Hdr."Bill-to County";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_county := Purch_Hdr."Pay-to County";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        inv_county := Transfer_Hdr."Transfer-to County";
                                    end;
                            end;
                        end;
                    }
                    textelement(inv_currency)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_currency := Sales_Hdr."Currency Code";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_currency := Purch_Hdr."Currency Code";
                                    end;
                                //RHE-TNA 11-06-2021 BDS-5385 BEGIN
                                Source_Doc::T_Order:
                                    begin
                                        inv_currency := Transfer_Hdr."Currency Code";
                                    end;
                                    //RHE-TNA 11-06-2021 BDS-5385 BEGIN
                            end;
                            if inv_currency = '' then
                                inv_currency := GLSetup."LCY Code";
                        end;
                    }
                    textelement(inv_dstamp)
                    {
                        trigger OnBeforePassVariable()

                        var
                            Day: Text[2];
                            Month: Text[2];
                            Year: Text[4];
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        Day := Format(Date2DMY(Sales_Hdr."Posting Date", 1));
                                        if StrLen(Day) < 2 then
                                            Day := '0' + Day;
                                        Month := Format(Date2DMY(Sales_Hdr."Posting Date", 2));
                                        if StrLen(Month) < 2 then
                                            Month := '0' + Month;
                                        Year := Format(Date2DMY(Sales_Hdr."Posting Date", 3));
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        Day := Format(Date2DMY(Purch_Hdr."Posting Date", 1));
                                        if StrLen(Day) < 2 then
                                            Day := '0' + Day;
                                        Month := Format(Date2DMY(Purch_Hdr."Posting Date", 2));
                                        if StrLen(Month) < 2 then
                                            Month := '0' + Month;
                                        Year := Format(Date2DMY(Purch_Hdr."Posting Date", 3));
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        Day := Format(Date2DMY(Transfer_Hdr."Posting Date", 1));
                                        if StrLen(Day) < 2 then
                                            Day := '0' + Day;
                                        Month := Format(Date2DMY(Transfer_Hdr."Posting Date", 2));
                                        if StrLen(Month) < 2 then
                                            Month := '0' + Month;
                                        Year := Format(Date2DMY(Transfer_Hdr."Posting Date", 3));
                                    end;
                            end;
                            //Convert to YYYYMMDD24HHMMSS
                            inv_dstamp := Year + Month + Day + '000000';
                        end;
                    }
                    textelement(inv_name)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_name := Sales_Hdr."Bill-to Name";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_name := Purch_Hdr."Pay-to Name";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        inv_name := Transfer_Hdr."Transfer-to Name";
                                    end;
                            end;
                            if StrLen(inv_name) > 30 then
                                inv_name := CopyStr(inv_name, 1, 30);
                        end;
                    }
                    textelement(inv_postcode)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_postcode := Sales_Hdr."Bill-to Post Code";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_postcode := Purch_Hdr."Pay-to Post Code";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        inv_postcode := Transfer_Hdr."Transfer-to Post Code";
                                    end;
                            end;
                        end;
                    }
                    textelement(inv_reference)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_reference := Sales_Hdr."No.";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_reference := Purch_Hdr."No.";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        inv_reference := Transfer_Hdr."No.";
                                    end;
                            end;
                        end;
                    }
                    textelement(inv_total_1)
                    {
                        trigger OnBeforePassVariable()
                        var
                            Country: Record "Country/Region";
                            TransferLine: Record "Transfer Line";
                            Amount1: Decimal;
                            SalesLine: Record "Sales Line";
                            PurchLine: Record "Purchase Line";
                            Item: Record Item;
                            Currency: Record Currency;
                            Amount2: Decimal;
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        //RHE-TNA 30-04-2021 BDS-5306 BEGIN
                                        //Sales_Hdr.CalcFields("Amount Including VAT");
                                        //inv_total_1 := Format(Sales_Hdr."Amount Including VAT");
                                        //RHE-TNA 26-08-2021 BDS-5584 BEGIN
                                        //Country.Get(Sales_Hdr."Ship-to Country/Region Code");
                                        //if Country."EU Country/Region Code" <> '' then begin
                                        //    Sales_Hdr.CalcFields("Amount Including VAT");
                                        //    inv_total_1 := Format(Sales_Hdr."Amount Including VAT");
                                        //end else begin
                                        //    Sales_Hdr.CalcFields(Amount);
                                        //    inv_total_1 := Format(Sales_Hdr.Amount);
                                        //end;
                                        //RHE-TNA 30-04-2021 BDS-5306 END
                                        Amount1 := 0;
                                        Amount2 := 0;
                                        SalesLine.SetRange("Document Type", Sales_Hdr."Document Type");
                                        SalesLine.SetRange("Document No.", Sales_Hdr."No.");
                                        SalesLine.SetRange(Type, SalesLine.Type::Item);
                                        SalesLine.FindSet();
                                        repeat
                                            if Country.IsEUCountry(Sales_Hdr."Ship-to Country/Region Code") then begin
                                                Amount1 += SalesLine."Amount Including VAT";
                                                Amount2 += SalesLine.Amount;
                                            end else
                                                //RHE-TNA 22-12-2021 PM-1328 BEGIN
                                                /*if SalesLine.Amount <> 0 then begin
                                                    Amount1 += SalesLine.Amount;
                                                    Amount2 := Amount1;
                                                end else begin
                                                    Item.Get(SalesLine."No.");
                                                    Amount1 += Item."Unit Cost" * SalesLine.Quantity;
                                                    Amount2 := Amount1;
                                                end;*/
                                                if SalesLine."Customs Price" > 0 then begin
                                                    Amount1 += (SalesLine.Quantity * SalesLine."Customs Price") * ((100 + SalesLine."VAT %") / 100);
                                                    Amount2 += SalesLine.Quantity * SalesLine."Customs Price";
                                                end else begin
                                                    if SalesLine.Amount <> 0 then begin
                                                        Amount1 += SalesLine."Amount Including VAT";
                                                        Amount2 += SalesLine.Amount;
                                                    end else begin
                                                        Amount1 += (SalesLine."Unit Cost" * SalesLine.Quantity) * ((100 + SalesLine."VAT %") / 100);
                                                        Amount2 += SalesLine."Unit Cost" * SalesLine.Quantity;
                                                    end;
                                                end;
                                            //RHE-TNA 22-12-2021 PM-1328 END
                                        until SalesLine.Next() = 0;
                                        if Sales_Hdr."Currency Code" = '' then begin
                                            Amount1 := Round(Amount1, GLSetup."Amount Rounding Precision");
                                            Amount2 := Round(Amount2, GLSetup."Amount Rounding Precision");
                                        end else begin
                                            Currency.Get(Sales_Hdr."Currency Code");
                                            Amount1 := Round(Amount1, Currency."Amount Rounding Precision");
                                            Amount2 := Round(Amount2, Currency."Amount Rounding Precision");
                                        end;
                                        inv_total_1 := Format(Amount1);
                                        inv_total_2 := Format(Amount2);
                                        //RHE-TNA 26-08-2021 BDS-5584 END
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        //RHE-TNA 30-04-2021 BDS-5306 BEGIN
                                        //Purch_Hdr.CalcFields("Amount Including VAT");
                                        //inv_total_1 := Format(Purch_Hdr."Amount Including VAT");
                                        //RHE-TNA 26-08-2021 BDS-5584 BEGIN
                                        //Country.Get(Purch_Hdr."Ship-to Country/Region Code");
                                        //if Country."EU Country/Region Code" <> '' then begin
                                        //    Purch_Hdr.CalcFields("Amount Including VAT");
                                        //    inv_total_1 := Format(Purch_Hdr."Amount Including VAT");
                                        //end else begin
                                        //    Purch_Hdr.CalcFields(Amount);
                                        //    inv_total_1 := Format(Purch_Hdr.Amount);
                                        //end;
                                        //RHE-TNA 30-04-2021 BDS-5306 END
                                        Amount1 := 0;
                                        Amount2 := 0;
                                        PurchLine.SetRange("Document Type", Purch_Hdr."Document Type");
                                        PurchLine.SetRange("Document No.", Purch_Hdr."No.");
                                        PurchLine.SetRange(Type, PurchLine.Type::Item);
                                        PurchLine.FindSet();
                                        repeat
                                            if Country.IsEUCountry(Purch_Hdr."Ship-to Country/Region Code") then begin
                                                Amount1 += PurchLine."Amount Including VAT";
                                                Amount2 += PurchLine.Amount;
                                            end else
                                                if PurchLine.Amount <> 0 then begin
                                                    Amount1 += PurchLine.Amount;
                                                    Amount2 := Amount1;
                                                end else begin
                                                    Item.Get(PurchLine."No.");
                                                    Amount1 += Item."Unit Cost" * PurchLine.Quantity;
                                                    Amount2 := Amount1;
                                                end;
                                        until PurchLine.Next() = 0;
                                        if Purch_Hdr."Currency Code" = '' then begin
                                            Amount1 := Round(Amount1, GLSetup."Amount Rounding Precision");
                                            Amount2 := Round(Amount2, GLSetup."Amount Rounding Precision");
                                        end else begin
                                            Currency.Get(Purch_Hdr."Currency Code");
                                            Amount1 := Round(Amount1, Currency."Amount Rounding Precision");
                                            Amount2 := Round(Amount2, Currency."Amount Rounding Precision");
                                        end;
                                        inv_total_1 := Format(Amount1);
                                        inv_total_2 := Format(Amount2);
                                        //RHE-TNA 26-08-2021 BDS-5584 END
                                    end;
                                //RHE-TNA 11-06-2021 BDS-5385 BEGIN
                                Source_Doc::T_Order:
                                    begin
                                        Amount1 := 0;
                                        TransferLine.SetRange("Document No.", Transfer_Hdr."No.");
                                        if TransferLine.FindSet() then
                                            repeat
                                                //RHE-TNA 26-08-2021 BDS-5584 BEGIN
                                                //Amount += TransferLine."Line Amount";
                                                if TransferLine."Line Amount" <> 0 then
                                                    Amount1 += TransferLine."Line Amount"
                                                else
                                                    if not Country.IsEUCountry(Transfer_Hdr."Trsf.-to Country/Region Code") then begin
                                                        item.Get(TransferLine."Item No.");
                                                        Amount1 += Item."Unit Cost" * TransferLine.Quantity;
                                                    end;
                                                //RHE-TNA 26-08-2021 BDS-5584 END
                                            until TransferLine.Next() = 0;
                                        Amount1 := Round(Amount1, GLSetup."Amount Rounding Precision");
                                        inv_total_1 := Format(Amount1);
                                        inv_total_2 := Format(Amount1);
                                    end;
                                    //RHE-TNA 11-06-2021 BDS-5385 END
                            end;
                            if not DecimalSignIsComma then begin
                                if StrPos(inv_total_1, ',') <> 0 then
                                    inv_total_1 := DelChr(inv_total_1, '=', ',');
                            end else begin
                                if StrPos(inv_total_1, ',') <> 0 then
                                    inv_total_1 := ConvertStr(inv_total_1, ',', '.');
                            end;
                        end;
                    }
                    textelement(inv_total_2)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 26-08-2021..01-09-2021 BDS-5584 BEGIN
                            //case Source_Doc of
                            //    Source_Doc::S_Order:
                            //        begin
                            //            Sales_Hdr.CalcFields(Amount);
                            //            inv_total_2 := Format(Sales_Hdr.Amount);
                            //        end;
                            //    Source_Doc::P_Order:
                            //        begin
                            //            Purch_Hdr.CalcFields(Amount);
                            //            inv_total_2 := Format(Purch_Hdr.Amount);
                            //        end;
                            //end;
                            //RHE-TNA 26-08-2021..01-09-2021 BDS-5584 END
                            if not DecimalSignIsComma then begin
                                if StrPos(inv_total_2, ',') <> 0 then
                                    inv_total_2 := DelChr(inv_total_2, '=', ',');
                            end else begin
                                if StrPos(inv_total_2, ',') <> 0 then
                                    inv_total_2 := ConvertStr(inv_total_2, ',', '.');
                            end;
                        end;
                    }
                    textelement(inv_total_3)
                    {

                    }
                    textelement(inv_total_4)
                    {

                    }
                    textelement(inv_town)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        inv_town := Sales_Hdr."Bill-to City";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        inv_town := Purch_Hdr."Pay-to City";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        inv_town := Transfer_Hdr."Transfer-to City";
                                    end;
                            end;
                            if StrLen(inv_town) > 35 then
                                inv_town := CopyStr(inv_town, 1, 35);
                        end;
                    }
                    textelement(inv_vat_number)
                    {

                    }
                    textelement(language)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        language := Sales_Hdr."Language Code";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        language := Purch_Hdr."Language Code";
                                    end;
                            end;
                        end;
                    }
                    textelement(letter_of_credit)
                    {

                    }
                    textelement(load_sequence)
                    {

                    }
                    textelement(location_number)
                    {

                    }
                    textelement(metapack_carrier_pre)
                    {

                    }
                    textelement(misc_charges)
                    {

                    }
                    textelement(move_task_status)
                    {

                    }
                    textelement(name)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        name := Sales_Hdr."Ship-to Name";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        name := Purch_Hdr."Ship-to Name";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        name := Transfer_Hdr."Transfer-to Name";
                                    end;
                            end;
                            if StrLen(name) > 30 then
                                name := CopyStr(name, 1, 30);
                        end;
                    }
                    textelement(order_date)
                    {
                        trigger OnBeforePassVariable()

                        var
                            Day: Text[2];
                            Month: Text[2];
                            Year: Text[4];
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        Day := Format(Date2DMY(Sales_Hdr."Order Date", 1));
                                        if StrLen(Day) < 2 then
                                            Day := '0' + Day;
                                        Month := Format(Date2DMY(Sales_Hdr."Order Date", 2));
                                        if StrLen(Month) < 2 then
                                            Month := '0' + Month;
                                        Year := Format(Date2DMY(Sales_Hdr."Order Date", 3));
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        Day := Format(Date2DMY(Purch_Hdr."Order Date", 1));
                                        if StrLen(Day) < 2 then
                                            Day := '0' + Day;
                                        Month := Format(Date2DMY(Purch_Hdr."Order Date", 2));
                                        if StrLen(Month) < 2 then
                                            Month := '0' + Month;
                                        Year := Format(Date2DMY(Purch_Hdr."Order Date", 3));
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        Day := Format(Date2DMY(Transfer_Hdr."Shipment Date", 1));
                                        if StrLen(Day) < 2 then
                                            Day := '0' + Day;
                                        Month := Format(Date2DMY(Transfer_Hdr."Shipment Date", 2));
                                        if StrLen(Month) < 2 then
                                            Month := '0' + Month;
                                        Year := Format(Date2DMY(Transfer_Hdr."Shipment Date", 3));
                                    end;
                            end;
                            order_date := Year + Month + Day + '000000';
                        end;
                    }
                    fieldelement(order_id; dataheader."No.")
                    {

                    }
                    textelement(order_reference)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        order_reference := Sales_Hdr."No.";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        order_reference := Purch_Hdr."No.";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        order_reference := Transfer_Hdr."No.";
                                    end;
                            end;
                        end;
                    }
                    textelement(order_type)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        order_type := Sales_Hdr."Order Class";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        order_type := Purch_Hdr."Order Class";
                                    end;
                            end;
                        end;
                    }
                    textelement(other_fee)
                    {

                    }
                    textelement(owner_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            owner_id := IFSetup."WMS Client ID";
                        end;
                    }
                    textelement(payment_terms)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        payment_terms := Sales_Hdr."Payment Terms Code";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        payment_terms := Purch_Hdr."Payment Terms Code";
                                    end;
                            end;
                        end;
                    }
                    textelement(postcode)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        postcode := Sales_Hdr."Ship-to Post Code";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        postcode := Purch_Hdr."Ship-to Post Code";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        postcode := Transfer_Hdr."Transfer-to Post Code";
                                    end;
                            end;
                        end;
                    }
                    textelement(print_invoice)
                    {

                    }
                    textelement(priority)
                    {

                    }
                    textelement(purchase_order)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        purchase_order := Sales_Hdr."External Document No.";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        purchase_order := Transfer_Hdr."External Document No.";
                                    end;
                            end;
                            if StrLen(purchase_order) > 25 then
                                purchase_order := CopyStr(purchase_order, 1, 25);
                        end;
                    }
                    textelement(repack)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 09-04-2020..14-04-2020 BDS-3866 BEGIN
                            //repack := 'Y';
                            repack := '';
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                repack := 'Y';
                            //RHE-TNA 09-04-2020..14-04-2020 BDS-3866 END
                        end;
                    }
                    textelement(repack_loc_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                //RHE-TNA 17-03-2020 BDS-3866 END
                                repack_loc_id := 'MEDDUMYREP';
                        end;
                    }
                    textelement(route_id)
                    {

                    }
                    textelement(seller_name)
                    {
                        trigger OnBeforePassVariable()
                        var
                            SalesPerson: Record "Salesperson/Purchaser";
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        //RHE-TNA 24-11-2021 BDS-5858 BEGIN
                                        //seller_name := Sales_Hdr."Salesperson Code";
                                        seller_name := '';
                                        if SalesPerson.Get(Sales_Hdr."Salesperson Code") then
                                            seller_name := SalesPerson.Name;
                                        //RHE-TNA 24-11-2021 BDS-5858 END
                                    end;
                            end;
                        end;
                    }
                    textelement(seller_phone)
                    {

                    }
                    textelement(service_level)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 14-04-2020 BDS-3866 BEGIN
                            service_level := '';
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then begin
                                //RHE-TNA 14-04-2020 BDS-3866 END
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            service_level := Sales_Hdr."Shipping Agent Service Code";
                                        end;
                                    Source_Doc::T_Order:
                                        begin
                                            service_level := Transfer_Hdr."Shipping Agent Service Code";
                                        end;
                                end;
                                //RHE-TNA 14-04-2020 BDS-3866 BEGIN
                            end;
                            //RHE-TNA 14-04-2020 BDS-3866 END
                        end;
                    }
                    textelement(ship_by_date)
                    {

                    }
                    textelement(ship_dock)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 14-04-2020 BDS-3866 BEGIN
                            ship_dock := '';
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then begin
                                //RHE-TNA 14-04-2020 BDS-3866 END
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            ship_dock := Sales_Hdr."Shipping Agent Code";
                                        end;
                                    Source_Doc::T_Order:
                                        begin
                                            ship_dock := Transfer_Hdr."Shipping Agent Code";
                                        end;
                                end;
                            end;
                            //RHE-TNA 14-04-2020 BDS-3866 BEGIN
                        end;
                        //RHE-TNA 14-04-2020 BDS-3866 END
                    }
                    textelement(sid_number)
                    {

                    }
                    textelement(signatory)
                    {

                    }
                    textelement(single_order_sortation)
                    {

                    }
                    textelement(site_replen)
                    {

                    }
                    textelement(soh_id)
                    {

                    }
                    textelement(stage_route_id)
                    {

                    }
                    textelement(start_by_date)
                    {

                    }
                    textelement(status)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 09-04-2020..14-04-2020 BDS-3866 BEGIN
                            //status := 'Released';
                            status := 'Hold';
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                status := 'Released';
                            //RHE-TNA 09-04-2020..14-04-2020 BDS-3866 END
                        end;
                    }
                    //RHE-TNA 14-04-2020 BDS-3866 BEGIN
                    textelement(status_reason_code)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                currXMLport.Skip()
                            else
                                status_reason_code := 'CSREQUIRED';
                        end;
                    }
                    //RHE-TNA 14-04-2020 BDS-3866 END
                    textelement(subtotal_1)
                    {

                    }
                    textelement(subtotal_2)
                    {

                    }
                    textelement(subtotal_3)
                    {

                    }
                    textelement(subtotal_4)
                    {

                    }
                    textelement(tax_amount_1)
                    {

                    }
                    textelement(tax_amount_2)
                    {

                    }
                    textelement(tax_amount_3)
                    {

                    }
                    textelement(tax_amount_4)
                    {

                    }
                    textelement(tax_amount_5)
                    {

                    }
                    textelement(tax_basis_1)
                    {

                    }
                    textelement(tax_basis_2)
                    {

                    }
                    textelement(tax_basis_3)
                    {

                    }
                    textelement(tax_basis_4)
                    {

                    }
                    textelement(tax_basis_5)
                    {

                    }
                    textelement(time_zone_name)
                    {

                    }
                    textelement(tod)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        tod := Sales_Hdr."Shipment Method Code";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        tod := Purch_Hdr."Shipment Method Code";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        tod := Transfer_Hdr."Shipment Method Code";
                                    end;
                            end;
                        end;
                    }
                    textelement(tod_place)
                    {

                    }
                    textelement(town)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        town := Sales_Hdr."Ship-to City";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        town := Purch_Hdr."Ship-to City";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        town := Transfer_Hdr."Transfer-to City";
                                    end;
                            end;
                            if StrLen(town) > 35 then
                                town := CopyStr(town, 1, 35);
                        end;
                    }
                    textelement(to_site_id)
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
                    textelement(vat_number)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        vat_number := Sales_Hdr."VAT Registration No.";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        vat_number := Purch_Hdr."VAT Registration No.";
                                    end;
                            end;
                        end;
                    }
                    textelement(v_address3)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 17-03-2020 BDS-3866 END
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        v_address3 := Sales_Hdr."Ship-to Name 2";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        v_address3 := Purch_Hdr."Ship-to Name 2";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        v_address3 := Transfer_Hdr."Transfer-to Name 2";
                                    end;
                            end;
                            if StrLen(v_address3) > 35 then
                                v_address3 := CopyStr(v_address3, 1, 35);
                        end;
                    }
                    textelement(v_address4)
                    {
                        //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                        trigger OnBeforePassVariable()
                        begin
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                        end;
                        //RHE-TNA 17-03-2020 BDS-3866 END
                    }
                    textelement(v_hub_address3)
                    {
                        //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                        trigger OnBeforePassVariable()
                        begin
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                        end;
                        //RHE-TNA 17-03-2020 BDS-3866 END
                    }
                    textelement(v_hub_address4)
                    {
                        //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                        trigger OnBeforePassVariable()
                        begin
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                        end;
                        //RHE-TNA 17-03-2020 BDS-3866 END
                    }
                    textelement(v_inv_address3)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 17-03-2020 BDS-3866 END
                            case Source_Doc of
                                Source_Doc::S_Order:
                                    begin
                                        v_inv_address3 := Sales_Hdr."Bill-to Name 2";
                                    end;
                                Source_Doc::P_Order:
                                    begin
                                        v_inv_address3 := Purch_Hdr."Pay-to Name 2";
                                    end;
                                Source_Doc::T_Order:
                                    begin
                                        v_inv_address3 := Transfer_Hdr."Transfer-to Name 2";
                                    end;
                            end;
                            if StrLen(v_inv_address3) > 35 then
                                v_inv_address3 := CopyStr(v_inv_address3, 1, 35);
                        end;
                    }
                    textelement(v_inv_address4)
                    {
                        //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                        trigger OnBeforePassVariable()
                        begin
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                        end;
                        //RHE-TNA 17-03-2020 BDS-3866 END
                    }
                    textelement(web_service_alloc_clean)
                    {

                    }
                    textelement(web_service_alloc_immed)
                    {

                    }
                    textelement(work_group)
                    {

                    }
                    textelement(work_order_type)
                    {

                    }
                    textelement(datalines)
                    {
                        tableelement(dataline; "Warehouse Shipment Line")
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
                            //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                            textelement(record_type_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(allocate)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(back_ordered)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            //RHE-TNA 17-03-2020 BDS-3866 END
                            textelement(batch_id)
                            {
                                trigger OnBeforePassVariable()

                                var
                                    ResEntry: Record "Reservation Entry";
                                    ATOLink: Record "Assemble-to-Order Link";
                                begin
                                    batch_id := '';
                                    if dataline."Qty. Shipped" <> 0 then begin
                                        ResEntry.SetRange("Entry No.", dataline."Qty. Shipped");
                                        if ResEntry.FindFirst() then begin
                                            //RHE-TNA 17-03-2020.BDS-3866 BEGIN
                                            //if ResEntry."Serial No." <> '' then
                                            if (ResEntry."Serial No." <> '') and (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009) then
                                                batch_id := ResEntry."Serial No."
                                            else
                                                if ResEntry."Lot No." <> '' then
                                                    batch_id := ResEntry."Lot No.";
                                            //RHE-TNA 17-03-2020BDS-3866 BEGIN
                                        end;
                                    end;
                                end;
                            }
                            //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                            textelement(batch_mixing)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(ce_coo)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(ce_receipt_type)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(client_group_XMLConvert)
                            {
                                //WMS Specs require client_id again, but this is already used at header level as textelement.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            //RHE-TNA 17-03-2020 BDS-3866 END
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
                                trigger OnBeforePassVariable()
                                begin
                                    collective_mode_XMLConvert := 'Y';
                                end;
                            }
                            //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                            textelement(collective_sequence)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(condition_id)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(config_id)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            //RHE-TNA 17-03-2020 BDS-3866 END
                            textelement(customer_sku_desc1)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    customer_sku_desc1 := dataline.Description;
                                    //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                                    //if StrLen(customer_sku_desc1) > 40 then
                                    if (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009) and (StrLen(customer_sku_desc1) > 40) then
                                        //RHE-TNA 22-05-2020 BDS-3866 END
                                        customer_sku_desc1 := CopyStr(customer_sku_desc1, 1, 40)
                                end;
                            }
                            textelement(customer_sku_desc2)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    customer_sku_desc2 := dataline."Description 2";
                                    //RHE-TNA 22-05-2020 BDS-3866 BEGIN
                                    //if StrLen(customer_sku_desc2) > 40 then
                                    //customer_sku_desc2 := CopyStr(customer_sku_desc2, 1, 40)
                                    if (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009) and (StrLen(customer_sku_desc2) > 40) then
                                        customer_sku_desc2 := CopyStr(customer_sku_desc2, 1, 40);
                                    if (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016) and (StrLen(customer_sku_desc2) > 50) then
                                        customer_sku_desc2 := CopyStr(customer_sku_desc2, 1, 50);
                                    //RHE-TNA 22-05-2020 BDS-3866 END
                                end;
                            }
                            textelement(customer_sku_id)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    SalesLine: Record "Sales Line";
                                begin
                                    //In case of sales orders the shipment line can contain the Assembly component item, therefore get the sales order item no.
                                    if dataline."Source Document" = dataline."Source Document"::"Sales Order" then begin
                                        if SalesLine.Get(SalesLine."Document Type"::Order, dataline."Source No.", dataline."Source Line No.") then
                                            customer_sku_id := SalesLine."No.";
                                    end else
                                        customer_sku_id := dataline."Item No.";
                                end;
                            }
                            //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                            textelement(deallocate)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(disallow_merge_rules_XMLConvert)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(disallow_substitution)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(documentation_text_1_XMLConvert)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(documentation_unit)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(expected_value_XMLConvert)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(expected_volume_XMLConvert)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(expected_weight_XMLConvert)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(extended_price)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(full_tracking_level_only)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            //RHE-TNA 17-03-2020 BDS-3866 END
                            textelement(host_line_id)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    host_line_id := '';
                                    host_line_id := Format(dataline."Source Line No.");
                                end;
                            }
                            //RHE-TNA 17-03-2020..22-05-2020 BDS-3866 BEGIN
                            textelement(host_order_id)
                            {

                            }
                            textelement(ignore_weight_capture)
                            {

                            }
                            textelement(kit_plan_id)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(kit_split)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                    kit_split := 'N';
                                    if dataline."Assemble to Order" then
                                        kit_split := 'Y';
                                end;
                            }
                            //RHE-TNA 17-03-2020..22-05-2020 BDS-3866 END
                            fieldelement(line_id; dataline."Line No.")
                            {

                            }
                            //RHE-TNA 17-03-2020..22-05-2020 BDS-3866 BEGIN
                            textelement(line_value)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(location_id)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(lock_code)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(max_full_pallet_perc)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(max_qty_ordered)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(min_full_pallet_perc)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                end;
                            }
                            //RHE-TNA 17-03-2020..22-05-2020 BDS-3866 END
                            textelement(min_qty_ordered)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    SalesLine: Record "Sales Line";
                                begin
                                    min_qty_ordered := '';
                                    if (dataline."Assemble to Order" = true) and (Source_Doc = Source_Doc::S_Order) then begin
                                        SalesLine.Get(SalesLine."Document Type"::Order, dataline."Source No.", dataline."Source Line No.");
                                        min_qty_ordered := Format(SalesLine.Quantity);
                                        if not DecimalSignIsComma then begin
                                            if StrPos(min_qty_ordered, ',') <> 0 then
                                                min_qty_ordered := DelChr(min_qty_ordered, '=', ',');
                                        end else begin
                                            if StrPos(min_qty_ordered, ',') <> 0 then
                                                min_qty_ordered := ConvertStr(min_qty_ordered, ',', '.');
                                        end;
                                    end;
                                end;
                            }
                            textelement(order_id)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    //As text XML is added to shipment no. Delete first 3 characters which is XML
                                    order_id := DelStr(dataline."No.", 1, 3);
                                end;
                            }
                            fieldelement(owner_id; dataline."WMS Client ID")
                            {

                            }
                            textelement(product_currency)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    product_currency := '';
                                    case Source_Doc of
                                        Source_Doc::S_Order:
                                            begin
                                                product_currency := Sales_Hdr."Currency Code";
                                            end;
                                        Source_Doc::P_Order:
                                            begin
                                                product_currency := Purch_Hdr."Currency Code";
                                            end;
                                        //RHE-TNA 11-06-2021 BDS-5385 BEGIN
                                        Source_Doc::T_Order:
                                            begin
                                                product_currency := Transfer_Hdr."Currency Code";
                                            end;
                                            //RHE-TNA 11-06-2021 BDS-5385 BEGIN
                                    end;
                                    if product_currency = '' then
                                        product_currency := GLSetup."LCY Code";
                                end;
                            }
                            textelement(product_price)
                            {
                                trigger OnBeforePassVariable()

                                var
                                    SalesLine: Record "Sales Line";
                                    PurchReturnLine: Record "Purchase Line";
                                    SalesHdr: Record "Sales Header";
                                    TransferLine: Record "Transfer Line";
                                    Country: Record "Country/Region";
                                    Item: Record Item;
                                    PurchHdr: Record "Purchase Header";
                                    TransferHdr: Record "Transfer Header";
                                begin
                                    product_price := '';

                                    case Source_Doc of
                                        Source_Doc::S_Order:
                                            begin
                                                SalesLine.Get(SalesLine."Document Type"::Order, dataline."Source No.", dataline."Source Line No.");
                                                //RHE-TNA 30-04-2021 BDS-5306 BEGIN
                                                //product_price := Format(SalesLine."Unit Price");
                                                SalesHdr.Get(SalesHdr."Document Type"::Order, dataline."Source No.");
                                                //RHE-TNA 23-12-2021 PM-1328 BEGIN
                                                /*if SalesHdr."Prices Including VAT" then
                                                    product_price := Format(Round(SalesLine."Unit Price" / (100 + SalesLine."VAT %") * 100))
                                                else
                                                    product_price := Format(SalesLine."Unit Price");
                                                //RHE-TNA 30-04-2021 BDS-5306 END
                                                //RHE-TNA 26-08-2021 BDS-5584 BEGIN
                                                //Always send a product price for export orders
                                                if (SalesLine."Unit Price" = 0) and (not Country.IsEUCountry(SalesHdr."Ship-to Country/Region Code")) then begin
                                                    Item.Get(dataline."Item No.");
                                                    product_price := Format(Item."Unit Cost");
                                                end;
                                                //RHE-TNA 26-08-2021 BDS-5584 END
                                                */
                                                if SalesHdr."Prices Including VAT" then
                                                    product_price := Format(Round(SalesLine."Unit Price" / (100 + SalesLine."VAT %") * 100))
                                                else
                                                    product_price := Format(SalesLine."Unit Price");

                                                if not Country.IsEUCountry(Sales_Hdr."Ship-to Country/Region Code") then begin
                                                    if SalesLine."Customs Price" > 0 then
                                                        product_price := Format(SalesLine."Customs Price")
                                                    else
                                                        if SalesLine."Unit Price" = 0 then begin
                                                            //Always send a product price for export orders
                                                            product_price := Format(SalesLine."Unit Cost");
                                                        end;
                                                end;
                                                //RHE-TNA 23-12-2021 PM-1328 END
                                            end;
                                        Source_Doc::P_Order:
                                            begin
                                                PurchReturnLine.Get(PurchReturnLine."Document Type"::"Return Order", dataline."Source No.", dataline."Source Line No.");
                                                product_price := Format(PurchReturnLine."Direct Unit Cost");
                                                //RHE-TNA 26-08-2021 BDS-5584 BEGIN
                                                //Always send a product price for export orders
                                                PurchHdr.Get(PurchHdr."Document Type"::"Return Order", dataline."Source No.");
                                                if (PurchReturnLine."Direct Unit Cost" = 0) and (not Country.IsEUCountry(PurchHdr."Ship-to Country/Region Code")) then begin
                                                    Item.Get(dataline."Item No.");
                                                    product_price := Format(Item."Unit Cost");
                                                end;
                                                //RHE-TNA 26-08-2021 BDS-5584 END
                                            end;
                                        //RHE-TNA 11-06-2021 BDS-5385 BEGIN
                                        Source_Doc::T_Order:
                                            begin
                                                TransferLine.Get(dataline."Source No.", dataline."Source Line No.");
                                                product_price := Format(TransferLine."Unit Price");
                                                //RHE-TNA 26-08-2021 BDS-5584 BEGIN
                                                //Always send a product price for export orders
                                                TransferHdr.Get(dataline."Source No.");
                                                if (TransferLine."Unit Price" = 0) and (not Country.IsEUCountry(TransferHdr."Trsf.-to Country/Region Code")) then begin
                                                    Item.Get(dataline."Item No.");
                                                    product_price := Format(Item."Unit Cost");
                                                end;
                                                //RHE-TNA 26-08-2021 BDS-5584 END
                                            end;
                                            //RHE-TNA 11-06-2021 BDS-5385 END
                                    end;
                                    if not DecimalSignIsComma then begin
                                        if StrPos(product_price, ',') <> 0 then
                                            product_price := DelChr(product_price, '=', ',');
                                    end else begin
                                        if StrPos(product_price, ',') <> 0 then
                                            product_price := ConvertStr(product_price, ',', '.');
                                    end;
                                end;
                            }
                            textelement(purchase_order_XMLConvert)
                            {
                                //WMS Specs require client_id again, but this is already used at header level as textelement.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    purchase_order_XMLConvert := purchase_order;
                                end;
                            }
                            textelement(qty_ordered)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    qty_ordered := Format(dataline.Quantity);
                                    if not DecimalSignIsComma then begin
                                        if StrPos(qty_ordered, ',') <> 0 then
                                            qty_ordered := DelChr(qty_ordered, '=', ',');
                                    end else begin
                                        if StrPos(qty_ordered, ',') <> 0 then
                                            qty_ordered := ConvertStr(qty_ordered, ',', '.');
                                    end;
                                end;
                            }
                            textelement(serial_number)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    ResEntry: Record "Reservation Entry";
                                begin
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2009 then
                                        currXMLport.Skip();
                                    serial_number := '';
                                    if dataline."Qty. Shipped" <> 0 then begin
                                        ResEntry.SetRange("Entry No.", dataline."Qty. Shipped");
                                        if ResEntry.FindFirst() then begin
                                            if ResEntry."Serial No." <> '' then
                                                serial_number := ResEntry."Serial No.";
                                        end;
                                    end;
                                end;
                            }
                            fieldelement(sku_id; dataline."Item No.")
                            {

                            }
                            //RHE-TNA 21-01-2022 BDS-5903 BEGIN
                            textelement(user_def_chk_2_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    user_def_chk_2_XMLConvert := '';
                                    if (dataline."Assemble to Order" = true) and (Source_Doc = Source_Doc::S_Order) then
                                        user_def_chk_2_XMLConvert := 'Y';
                                end;
                            }
                            //RHE-TNA 21-01-2022 BDS-5903 END
                            textelement(user_def_chk_4_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                begin
                                    //RHE-TNA 03-06-2022 BDS-6043 BEGIN
                                    /*
                                    user_def_chk_4_XMLConvert := '';
                                    if (dataline."Assemble to Order" = true) and (Source_Doc = Source_Doc::S_Order) then
                                        user_def_chk_4_XMLConvert := 'Y';
                                    */
                                    //RHE-TNA 03-06-2022 BDS-6043 END
                                end;
                            }
                            textelement(user_def_note_1_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                var
                                    SalesLine: Record "Sales Line";
                                begin
                                    user_def_note_1_XMLConvert := '';
                                    if (dataline."Assemble to Order" = true) and (Source_Doc = Source_Doc::S_Order) then begin
                                        SalesLine.Get(SalesLine."Document Type"::Order, dataline."Source No.", dataline."Source Line No.");
                                        user_def_note_1_XMLConvert := SalesLine.Description;
                                    end;
                                end;
                            }
                            textelement(user_def_num_1_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                var
                                    SalesLine: Record "Sales Line";
                                begin
                                    user_def_num_1_XMLConvert := '';
                                    if (dataline."Assemble to Order" = true) and (Source_Doc = Source_Doc::S_Order) then begin
                                        SalesLine.Get(SalesLine."Document Type"::Order, dataline."Source No.", dataline."Source Line No.");
                                        user_def_num_1_XMLConvert := Format(SalesLine.Quantity);
                                        if not DecimalSignIsComma then begin
                                            if StrPos(user_def_num_1_XMLConvert, ',') <> 0 then
                                                user_def_num_1_XMLConvert := DelChr(user_def_num_1_XMLConvert, '=', ',');
                                        end else begin
                                            if StrPos(user_def_num_1_XMLConvert, ',') <> 0 then
                                                user_def_num_1_XMLConvert := ConvertStr(user_def_num_1_XMLConvert, ',', '.');
                                        end;
                                    end;
                                end;
                            }
                            textelement(user_def_num_2_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                var
                                begin
                                    user_def_num_2_XMLConvert := '';
                                    user_def_num_2_XMLConvert := Format(dataline."Source Line No.");
                                end;
                            }
                            textelement(user_def_num_3_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                var
                                    SalesLine: Record "Sales Line";
                                    PurchReturnLine: Record "Purchase Line";
                                    Country: Record "Country/Region";
                                    Item: Record Item;
                                    Currency: Record Currency;
                                    TransferLine: Record "Transfer Line";
                                begin
                                    user_def_num_3_XMLConvert := '';
                                    case Source_Doc of
                                        Source_Doc::S_Order:
                                            begin
                                                SalesLine.Get(SalesLine."Document Type"::Order, dataline."Source No.", dataline."Source Line No.");
                                                user_def_num_3_XMLConvert := Format(SalesLine."Line Amount");
                                                //RHE-TNA 22-12-2021 PM-1328 BEGIN
                                                /*
                                            //RHE-TNA 26-08-2021 BDS-5584 BEGIN
                                            if (SalesLine."Line Amount" = 0) and (not Country.IsEUCountry(Sales_Hdr."Ship-to Country/Region Code")) then begin
                                                Item.Get(dataline."Item No.");
                                                if Sales_Hdr."Currency Code" = '' then
                                                    user_def_num_3_XMLConvert := Format(Round((Item."Unit Cost" * SalesLine.Quantity), GLSetup."Amount Rounding Precision"))
                                                else begin
                                                    Currency.Get(Sales_Hdr."Currency Code");
                                                    user_def_num_3_XMLConvert := Format(Round((Item."Unit Cost" * SalesLine.Quantity), Currency."Amount Rounding Precision"));
                                                end;
                                            end;
                                            //RHE-TNA 26-08-2021 BDS-5584 END
                                            */
                                                if SalesLine."Customs Price" > 0 then
                                                    user_def_num_3_XMLConvert := Format(Round((SalesLine."Customs Price" * SalesLine.Quantity), GLSetup."Amount Rounding Precision"))
                                                else
                                                    //Always send a product price for export orders
                                                    if (SalesLine."Unit Price" = 0) and (not Country.IsEUCountry(Sales_Hdr."Ship-to Country/Region Code")) then
                                                        user_def_num_3_XMLConvert := Format(Round((SalesLine."Unit Cost" * SalesLine.Quantity), Currency."Amount Rounding Precision"));
                                                //RHE-TNA 22-12-2021 PM-1328 END
                                            end;
                                        Source_Doc::P_Order:
                                            begin
                                                PurchReturnLine.Get(PurchReturnLine."Document Type"::"Return Order", dataline."Source No.", dataline."Source Line No.");
                                                user_def_num_3_XMLConvert := Format(PurchReturnLine."Line Amount");
                                                //RHE-TNA 26-08-2021 BDS-5584 BEGIN
                                                if (PurchReturnLine."Line Amount" = 0) and (not Country.IsEUCountry(Purch_Hdr."Ship-to Country/Region Code")) then begin
                                                    Item.Get(dataline."Item No.");
                                                    if Purch_Hdr."Currency Code" = '' then
                                                        user_def_num_3_XMLConvert := Format(Round((Item."Unit Cost" * PurchReturnLine.Quantity), GLSetup."Amount Rounding Precision"))
                                                    else begin
                                                        Currency.Get(Sales_Hdr."Currency Code");
                                                        user_def_num_3_XMLConvert := Format(Round((Item."Unit Cost" * PurchReturnLine.Quantity), Currency."Amount Rounding Precision"));
                                                    end;
                                                end;
                                                //RHE-TNA 26-08-2021 BDS-5584 END
                                            end;
                                        //RHE-TNA 26-08-2021 BDS-5584 BEGIN
                                        Source_Doc::T_Order:
                                            begin
                                                TransferLine.Get(dataline."Source No.", dataline."Source Line No.");
                                                user_def_num_3_XMLConvert := Format(TransferLine."Line Amount");
                                                if (TransferLine."Line Amount" = 0) and (not Country.IsEUCountry(Transfer_Hdr."Trsf.-to Country/Region Code")) then begin
                                                    Item.Get(dataline."Item No.");
                                                    user_def_num_3_XMLConvert := Format(Round((Item."Unit Cost" * TransferLine.Quantity), GLSetup."Amount Rounding Precision"));
                                                end;
                                            end;
                                            //RHE-TNA 26-08-2021 BDS-5584 END
                                    end;
                                    if not DecimalSignIsComma then begin
                                        if StrPos(user_def_num_3_XMLConvert, ',') <> 0 then
                                            user_def_num_3_XMLConvert := DelChr(user_def_num_3_XMLConvert, '=', ',');
                                    end else begin
                                        if StrPos(user_def_num_3_XMLConvert, ',') <> 0 then
                                            user_def_num_3_XMLConvert := ConvertStr(user_def_num_3_XMLConvert, ',', '.');
                                    end;
                                end;
                            }
                            fieldelement(user_def_type_1; dataline."Location Code")
                            {

                            }
                            fieldelement(user_def_type_2; dataline."Source No.")
                            {

                            }
                            textelement(user_def_type_3_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                var
                                    ATOLink: Record "Assemble-to-Order Link";
                                    SalesLine: Record "Sales Line";
                                    Item: Record Item;
                                begin
                                    user_def_type_3_XMLConvert := '';
                                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                                    //RHE-TNA 11-10-2020..25-11-2020 BDS-4695 BEGIN
                                    //if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                    //    currXMLport.Skip();
                                    if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then begin
                                        //Document Type,Document No.,Line No.
                                        if dataline."Source Document" = dataline."Source Document"::"Sales Order" then begin
                                            SalesLine.Get(SalesLine."Document Type"::Order, dataline."Source No.", dataline."Source Line No.");
                                            Item.Get(SalesLine."No.");
                                            //Send HS code/Tariff No. and CoO of parent item in case of assembly
                                            if SalesLine."Qty. to Asm. to Order (Base)" > 0 then begin
                                                user_def_type_3_XMLConvert := Item."Tariff No.";
                                                user_def_type_4_XMLConvert := Item."Country/Region of Origin Code";
                                            end;
                                        end;
                                    end else begin
                                        //RHE-TNA 11-10-2020..25-11-2020 BDS-4695 END    
                                        //RHE-TNA 17-03-2020 BDS-3866 END
                                        ATOLink.SetRange(Type, ATOLink.Type::Sale);
                                        ATOLink.SetRange("Assembly Document Type", ATOLink."Assembly Document Type"::Order);
                                        ATOLink.SetRange("Document Type", ATOLink."Document Type"::Order);
                                        ATOLink.SetRange("Document No.", dataline."Source No.");
                                        ATOLink.SetRange("Document Line No.", dataline."Source Line No.");
                                        if ATOLink.FindFirst() then
                                            user_def_type_3_XMLConvert := ATOLink."Assembly Document No.";
                                        //RHE-TNA 11-10-2020 BDS-4695 BEGIN
                                    end;
                                    //RHE-TNA 11-10-2020 BDS-4695 END                                    
                                end;
                            }
                            textelement(user_def_type_4_XMLConvert)
                            {
                                //WMS required this attribute on header and line level.
                                //_XMLConvert will be deleted in the report which calls this XMLport
                                trigger OnBeforePassVariable()
                                var
                                    ATOLink: Record "Assemble-to-Order Link";
                                    AssemblyLine: Record "Assembly Line";
                                begin
                                    user_def_type_4_XMLConvert := '';
                                    //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                                    //RHE-TNA 11-10-2020 BDS-4695 BEGIN
                                    //if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                    //    currXMLport.Skip();
                                    if IFSetup."WMS Version" <> IFSetup."WMS Version"::WMS2016 then begin
                                        //RHE-TNA 11-10-2020 BDS-4695 END
                                        //RHE-TNA 17-03-2020 BDS-3866 END
                                        ATOLink.SetRange(Type, ATOLink.Type::Sale);
                                        ATOLink.SetRange("Assembly Document Type", ATOLink."Assembly Document Type"::Order);
                                        ATOLink.SetRange("Document Type", ATOLink."Document Type"::Order);
                                        ATOLink.SetRange("Document No.", dataline."Source No.");
                                        ATOLink.SetRange("Document Line No.", dataline."Source Line No.");
                                        if ATOLink.FindFirst() then begin
                                            AssemblyLine.SetRange("Document Type", ATOLink."Assembly Document Type");
                                            AssemblyLine.SetRange("Document No.", ATOLink."Assembly Document No.");
                                            AssemblyLine.SetRange("No.", dataline."Item No.");
                                            if AssemblyLine.FindFirst() then
                                                user_def_type_4_XMLConvert := Format(AssemblyLine."Line No.");
                                        end;
                                        if not DecimalSignIsComma then begin
                                            if StrPos(user_def_type_4_XMLConvert, ',') <> 0 then
                                                user_def_type_4_XMLConvert := DelChr(user_def_type_4_XMLConvert, '=', ',');
                                        end else begin
                                            if StrPos(user_def_type_4_XMLConvert, ',') <> 0 then
                                                user_def_type_4_XMLConvert := ConvertStr(user_def_type_4_XMLConvert, ',', '.');
                                        end;
                                        //RHE-TNA 11-10-2020 BDS-4695 BEGIN
                                    end;
                                    //RHE-TNA 11-10-2020 BDS-4695 END
                                end;
                            }
                            //RHE-TNA 07-12-2020 BDS-4733 BEGIN
                            textelement(user_def_type_5_XMLConvert)
                            {

                            }
                            textelement(user_def_type_6_XMLConvert)
                            {

                            }
                            textelement(user_def_type_7_XMLConvert)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    SalesLine: Record "Sales Line";
                                begin
                                    user_def_type_7_XMLConvert := '';
                                    case Source_Doc of
                                        Source_Doc::S_Order:
                                            begin
                                                SalesLine.Get(SalesLine."Document Type"::Order, dataline."Source No.", dataline."Source Line No.");
                                                user_def_type_7_XMLConvert := SalesLine."Cross-Reference No.";
                                            end;
                                    end;
                                end;
                            }
                            //RHE-TNA 07-12-2020 BDS-4733 END
                            trigger OnPreXmlItem()
                            var
                                ATOLink: Record "Assemble-to-Order Link";
                                WhseShipmentLine: Record "Warehouse Shipment Line";
                                WhseShipmentLine2: Record "Warehouse Shipment Line";
                                WhseShipmentNo: text[20];
                                AssemblyLine: Record "Assembly Line";
                                ResEntry: Record "Reservation Entry";
                                UntrackedQty: Decimal;
                            begin
                                WhseShipmentLine.SetRange("No.", dataheader."No.");
                                if WhseShipmentLine.FindSet() then begin
                                    ATOLink.SetRange(Type, ATOLink.Type::Sale);
                                    ATOLink.SetRange("Assembly Document Type", ATOLink."Assembly Document Type"::Order);
                                    ATOLink.SetRange("Document Type", ATOLink."Document Type"::Order);
                                    ATOLink.SetRange("Document No.", WhseShipmentLine."Source No.");
                                    repeat
                                        //Create dummy datalines incl. Assembly datalines to loop through
                                        WhseShipmentNo := 'XML' + WhseShipmentLine."No.";
                                        WhseShipmentLine2.Init();
                                        WhseShipmentLine2.Copy(WhseShipmentLine);
                                        WhseShipmentLine2."No." := WhseShipmentNo;

                                        //Add a warehouse shipment line for the assembly components
                                        ATOLink.SetRange("Document Line No.", WhseShipmentLine."Source Line No.");
                                        if ATOLink.FindFirst() then begin
                                            AssemblyLine.SetRange("Document Type", ATOLink."Assembly Document Type");
                                            AssemblyLine.SetRange("Document No.", ATOLink."Assembly Document No.");
                                            AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
                                            if AssemblyLine.FindSet() then
                                                repeat
                                                    //Add a warehouse shipment line for Item Tracking datalines of the Assembly Line
                                                    UntrackedQty := AssemblyLine.Quantity;
                                                    ResEntry.Reset();
                                                    ResEntry.SetRange("Source Type", 901);
                                                    ResEntry.SetRange("Source Subtype", 1);
                                                    ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
                                                    ResEntry.SetRange("Source ID", AssemblyLine."Document No.");
                                                    ResEntry.SetRange("Item No.", AssemblyLine."No.");
                                                    if ResEntry.FindSet() then begin
                                                        repeat
                                                            AddDummyShipmentLine(WhseShipmentLine2, AssemblyLine."No.", AssemblyLine."Description", AssemblyLine."Description 2", AssemblyLine."Unit of Measure Code", Abs(ResEntry.Quantity), true, WhseShipmentLine."Line No.", AssemblyLine."Line No.", ResEntry."Entry No.");
                                                            UntrackedQty := UntrackedQty - Abs(ResEntry.Quantity);
                                                        until (ResEntry.Next() = 0) or (UntrackedQty <= 0);
                                                        if UntrackedQty > 0 then
                                                            //Add a line for the remaining quantity
                                                            AddDummyShipmentLine(WhseShipmentLine2, AssemblyLine."No.", AssemblyLine."Description", AssemblyLine."Description 2", AssemblyLine."Unit of Measure Code", UntrackedQty, true, WhseShipmentLine."Line No.", AssemblyLine."Line No.", 0);
                                                    end else
                                                        AddDummyShipmentLine(WhseShipmentLine2, AssemblyLine."No.", AssemblyLine."Description", AssemblyLine."Description 2", AssemblyLine."Unit of Measure Code", AssemblyLine.Quantity, true, WhseShipmentLine."Line No.", AssemblyLine."Line No.", 0);
                                                until AssemblyLine.Next() = 0;
                                        end else begin
                                            //Add a warehouse shipment for Item Tracking datalines of the Warehouse Shipment Line
                                            UntrackedQty := WhseShipmentLine.Quantity;
                                            ResEntry.Reset();
                                            ResEntry.SetRange("Source Type", WhseShipmentLine."Source Type");
                                            ResEntry.SetRange("Source Subtype", WhseShipmentLine."Source Subtype");
                                            ResEntry.SetRange("Source ID", WhseShipmentLine."Source No.");
                                            ResEntry.SetRange("Source Ref. No.", WhseShipmentLine."Source Line No.");
                                            ResEntry.SetRange(Binding, ResEntry.Binding::" ");
                                            //RHE-TNA 12-01-2022 BDS-5564 BEGIN
                                            ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
                                            //RHE-TNA 12-01-2022 BDS-5564 END
                                            if ResEntry.FindSet() then begin
                                                repeat
                                                    AddDummyShipmentLine(WhseShipmentLine2, WhseShipmentLine."Item No.", WhseShipmentLine.Description, WhseShipmentLine."Description 2", WhseShipmentLine."Unit of Measure Code", Abs(ResEntry.Quantity), false, WhseShipmentLine."Line No.", 0, ResEntry."Entry No.");
                                                    UntrackedQty := UntrackedQty - Abs(ResEntry.Quantity);
                                                until (ResEntry.Next() = 0) or (UntrackedQty <= 0);
                                                if UntrackedQty > 0 then
                                                    //Add a line for the remaining quantity
                                                    AddDummyShipmentLine(WhseShipmentLine2, WhseShipmentLine."Item No.", WhseShipmentLine.Description, WhseShipmentLine."Description 2", WhseShipmentLine."Unit of Measure Code", UntrackedQty, false, WhseShipmentLine."Line No.", 0, 0);
                                            end else
                                                AddDummyShipmentLine(WhseShipmentLine2, WhseShipmentLine."Item No.", WhseShipmentLine.Description, WhseShipmentLine."Description 2", WhseShipmentLine."Unit of Measure Code", WhseShipmentLine.Quantity, false, WhseShipmentLine."Line No.", 0, 0);
                                        end;
                                    until WhseShipmentLine.Next() = 0;
                                end;
                                dataline.SetRange("No.", WhseShipmentNo);
                            end;
                        }
                    }
                    trigger OnAfterGetRecord()
                    var
                        WhseShipmentLine: Record "Warehouse Shipment Line";
                    begin
                        WhseShipmentLine.SetRange("No.", dataheader."No.");
                        WhseShipmentLine.FindFirst();
                        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order" then begin
                            Sales_Hdr.Get(Sales_Hdr."Document Type"::Order, WhseShipmentLine."Source No.");
                            Source_Doc := Source_Doc::S_Order;
                        end;
                        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Purchase Return Order" then begin
                            Purch_Hdr.Get(Purch_Hdr."Document Type"::"Return Order", WhseShipmentLine."Source No.");
                            Source_Doc := Source_Doc::P_Order;
                        end;
                        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Outbound Transfer" then begin
                            Transfer_Hdr.Get(WhseShipmentLine."Source No.");
                            Source_Doc := Source_Doc::T_Order;
                        end;

                        //RHE-TNA 12-01-2022 BDS-5585 BEGIN
                        IFSetup.GetWMSIFSetupEntryNo(dataheader."Location Code");
                        //RHE-TNA 12-01-2022 BDS-5585 END                        
                    end;
                }
            }
        }
    }
    procedure AddDummyShipmentLine(var WhseShipmentLine: Record "Warehouse Shipment Line"; ItemNo: Code[20]; Description: Text[100]; Description2: Text[50]; UOM: Code[10]; Quantity: Decimal; ATO: Boolean; OriginalWhseLineNo: Integer; OriginalAssLineNo: Integer; ResEntryNo: Integer)
    var
        WhseShipmentLine2: Record "Warehouse Shipment Line";
    begin
        WhseShipmentLine."Line No." := 1;
        WhseShipmentLine2.SetRange("No.", WhseShipmentLine."No.");
        if WhseShipmentLine2.FindLast() then begin
            if WhseShipmentLine."Line No." <= WhseShipmentLine2."Line No." then
                WhseShipmentLine."Line No." := WhseShipmentLine2."Line No." + 1;
        end;
        WhseShipmentLine."Item No." := ItemNo;
        WhseShipmentLine.Description := Description;
        WhseShipmentLine."Description 2" := Description2;
        WhseShipmentLine."Unit of Measure Code" := UOM;
        WhseShipmentLine.Quantity := Quantity;
        WhseShipmentLine."WMS Client ID" := IFSetup."WMS Client ID";
        //Set field Assemble to Order for assembly datalines
        WhseShipmentLine."Assemble to Order" := ATO;
        //Set field Shelf No. to store the original Whse. Shipment Line No.
        WhseShipmentLine."Shelf No." := Format(OriginalWhseLineNo);
        //Set field Qty. to Ship to store the original Assembly Line No.
        WhseShipmentLine."Qty. to Ship" := OriginalAssLineNo;
        //Set field Qty. Shipped to store the ResEntryNo in case a Lot or Serial No. is entered
        WhseShipmentLine."Qty. Shipped" := ResEntryNo;
        //Set field Zone Code to know this is a line to be deleted.
        WhseShipmentLine."Zone Code" := 'XML50002';
        WhseShipmentLine.Insert(false);
    end;

    trigger OnPreXmlPort()
    begin
        //Check if the decimal sign is a comma
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
        GLSetup.Get();
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
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        //Delete created Whse shipment datalines which are based on assembly datalines
        WhseShipmentLine.SetRange("Zone Code", 'XML50002');
        WhseShipmentLine.DeleteAll(false);
    end;

    //Global Variables
    var
        Sales_Hdr: Record "Sales Header";
        Purch_Hdr: Record "Purchase Header";
        Transfer_Hdr: Record "Transfer Header";
        Source_Doc: Option S_Order,P_Order,T_Order;
        IFSetup: Record "Interface Setup";
        DecimalSignIsComma: Boolean;
        GLSetup: Record "General Ledger Setup";
        RecCountry: Record "Country/Region";
}