xmlport 50002 "Export WMS SKU Master"

//  RHE-TNA 03-02-2020..14-05-2020 BDS-3866
//  - Modified schema

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreXMLPort()

//  RHE-TNA 19-01-2022 BDS-5585
//  - Modified trigger OnPreXMLPort()

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
                tableelement(dataheader; Item)
                {
                    textattribute(transaction)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            if dataheader."Exported to WMS" then
                                transaction := 'update'
                            else
                                transaction := 'add';
                        end;
                    }
                    textelement("allocation_group")
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 END
                            allocation_group := IFSetup."WMS Client ID";
                        end;
                    }
                    textelement("ce_coo")
                    {
                        trigger OnBeforePassVariable()
                        var
                            Country: Record "Country/Region";
                        begin
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" <> IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 END
                            if (dataheader."Country/Region of Origin Code" <> '') and (Country.Get(dataheader."Country/Region of Origin Code")) and (Country."ISO3 Code" <> '') then begin
                                user_def_type_4 := Country."ISO3 Code";
                            end;
                        end;
                    }
                    textelement("client_id")
                    {
                        trigger OnBeforePassVariable()
                        begin
                            client_id := IFSetup."WMS Client ID";
                        end;
                    }
                    textelement(commodity_code)
                    {
                        trigger OnBeforePassVariable()

                        begin
                            commodity_code := DelChr(dataheader."Tariff No.", '=', '.');
                        end;
                    }
                    textelement(description)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            description := dataheader."Search Description";
                            if StrLen(description) > 40 then
                                description := CopyStr(description, 1, 40);
                        end;
                    }
                    textelement(each_weight)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 END
                            each_weight := Format(dataheader."Gross Weight");
                            each_weight := Format(dataheader."Gross Weight");
                            if not DecimalSignIsComma then begin
                                if StrPos(each_weight, ',') <> 0 then
                                    each_weight := DelChr(each_weight, '=', ',');
                            end else begin
                                if StrPos(each_weight, ',') <> 0 then
                                    each_weight := ConvertStr(each_weight, ',', '.');
                            end;
                        end;
                    }
                    fieldelement(ean; dataheader.GTIN)
                    {

                    }
                    textelement(expiry_reqd)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ItemTrackingCode: Record "Item Tracking Code";
                        begin
                            if (dataheader."Item Tracking Code" <> '') and (ItemTrackingCode.Get(dataheader."Item Tracking Code")) and (ItemTrackingCode."Man. Expir. Date Entry Reqd.") then
                                expiry_reqd := 'Y'
                            else
                                expiry_reqd := 'N';
                        end;
                    }
                    textelement(kit_sku)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" <> IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 END
                            kit_sku := 'N';
                            if dataheader."Replenishment System" = dataheader."Replenishment System"::Assembly then
                                kit_sku := 'Y';
                        end;
                    }
                    textelement(kit_split)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" <> IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 END
                            kit_split := 'N';
                            if kit_sku = 'Y' then
                                kit_split := 'Y';
                        end;
                    }
                    textelement(product_group)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ItemTrackingCode: Record "Item Tracking Code";
                        begin
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 END
                            product_group := '';
                            if (dataheader."Item Tracking Code" <> '') and (ItemTrackingCode.Get(dataheader."Item Tracking Code")) then begin
                                if ItemTrackingCode."SN Sales Outbound Tracking" then
                                    product_group := 'SERIAL'
                                else
                                    if ItemTrackingCode."Lot Sales Outbound Tracking" then
                                        product_group := 'LOT';
                            end;
                        end;
                    }
                    textelement(putaway_group)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 END
                            putaway_group := IFSetup."WMS Client ID";
                        end;
                    }
                    textelement(qc_status)
                    {
                        trigger OnBeforePassVariable()
                        var
                            ItemTrackingCode: Record "Item Tracking Code";
                        begin
                            qc_status := '';
                            if (dataheader."Item Tracking Code" <> '') and (ItemTrackingCode.Get(dataheader."Item Tracking Code") and ((ItemTrackingCode."Lot Sales Outbound Tracking") or (ItemTrackingCode."SN Sales Outbound Tracking"))) then
                                qc_status := 'Released';
                        end;
                    }
                    fieldelement(sku_id; dataheader."No.")
                    {

                    }
                    fieldelement(user_def_note_1; dataheader."Description")
                    {

                    }
                    fieldelement(user_def_note_2; dataheader."Description 2")
                    {

                    }
                    textelement(user_def_num_1)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            user_def_num_1 := Format(dataheader."Unit Price");
                            if not DecimalSignIsComma then begin
                                if StrPos(user_def_num_1, ',') <> 0 then
                                    user_def_num_1 := DelChr(user_def_num_1, '=', ',');
                            end else begin
                                if StrPos(user_def_num_1, ',') <> 0 then
                                    user_def_num_1 := ConvertStr(user_def_num_1, ',', '.');
                            end;
                        end;
                    }
                    textelement(user_def_num_2)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            user_def_num_2 := Format(dataheader."Unit Cost");
                            user_def_num_2 := Format(dataheader."Unit Cost");
                            if not DecimalSignIsComma then begin
                                if StrPos(user_def_num_2, ',') <> 0 then
                                    user_def_num_2 := DelChr(user_def_num_2, '=', ',');
                            end else begin
                                if StrPos(user_def_num_2, ',') <> 0 then
                                    user_def_num_2 := ConvertStr(user_def_num_2, ',', '.');
                            end;
                        end;
                    }
                    textelement(user_def_type_4)
                    {
                        trigger OnBeforePassVariable()
                        var
                            Country: Record "Country/Region";
                        begin
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 BEGIN
                            if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
                                currXMLport.Skip();
                            //RHE-TNA 03-02-2020..14-05-2020 BDS-3866 END
                            if (dataheader."Country/Region of Origin Code" <> '') and (Country.Get(dataheader."Country/Region of Origin Code")) and (Country."ISO3 Code" <> '') then begin
                                user_def_type_4 := Country."ISO3 Code";
                            end;
                        end;
                    }
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
        //RHE-TNA 19-01-2022 BDS-5585 BEGIN
        //IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Type, IFSetup.Type::"Blue Yonder WMS");
        //RHE-TNA 19-01-2022 BDS-5585 END
        IFSetup.SetRange(Active, true);
        IFSetup.FindFirst();
        //RHE-TNA 14-06-2021 BDS-5337 END
        IFSetup.TestField("WMS Client ID");
    end;

    //Global Variables
    var
        IFSetup: Record "Interface Setup";
        DecimalSignIsComma: Boolean;
}