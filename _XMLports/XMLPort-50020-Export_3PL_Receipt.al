xmlport 50020 "Export 3PL Receipt"

//  RHE-TNA 30-12-2021..11-02-2022 BDS-5967
//  - New XMLPort

{
    Direction = Export;
    Format = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;

    schema
    {
        textelement(Root)
        {
            tableelement(DataHeader; "Warehouse Receipt Header")
            {
                textelement(ClientId)
                {
                    trigger OnBeforePassVariable()
                    begin
                        ClientId := IFSetup."WMS Client ID";
                    end;
                }
                textelement(SiteId)
                {
                    trigger OnBeforePassVariable()
                    begin
                        SiteId := IFSetup."WMS Site ID";
                    end;
                }
                fieldelement(ReceiptNo; DataHeader."No.")
                {

                }
                textelement(OrderNo)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    OrderNo := Sales_Hdr."No.";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    OrderNo := Purch_Hdr."No.";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    OrderNo := Transfer_Hdr."No.";
                                end;
                        end;
                    end;
                }
                textelement(Return)
                {
                    trigger OnBeforePassVariable()
                    begin
                        Return := 'N';
                        if Source_Doc = Source_Doc::S_Order then
                            Return := 'Y'
                    end;
                }
                textelement(SenderOrderReference)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SenderOrderReference := Sales_Hdr."External Document No.";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    SenderOrderReference := Purch_Hdr."Vendor Order No.";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    SenderOrderReference := Transfer_Hdr."External Document No.";
                                end;
                        end;
                    end;
                }
                textelement(ShipFromID)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipFromID := Sales_Hdr."Sell-to Customer No.";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipFromID := Purch_Hdr."Buy-from Vendor No.";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipFromID := Transfer_Hdr."Transfer-from Code";
                                end;
                        end;
                    end;
                }
                textelement(ShipFromName)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipFromName := Sales_Hdr."Sell-to Customer Name";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipFromName := Purch_Hdr."Buy-from Vendor Name";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipFromName := Transfer_Hdr."Transfer-from Name";
                                end;
                        end;
                    end;
                }
                textelement(ShipFromAddress1)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipFromAddress1 := Sales_Hdr."Sell-to Address";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipFromAddress1 := Purch_Hdr."Buy-from Address";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipFromAddress1 := Transfer_Hdr."Transfer-from Address";
                                end;
                        end;
                    end;
                }
                textelement(ShipFromAddress2)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipFromAddress2 := Sales_Hdr."Sell-to Address 2";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipFromAddress2 := Purch_Hdr."Buy-from Address 2";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipFromAddress2 := Transfer_Hdr."Transfer-from Address 2";
                                end;
                        end;
                    end;
                }
                textelement(ShipFromPostcode)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipFromPostcode := Sales_Hdr."Sell-to Post Code";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipFromPostcode := Purch_Hdr."Buy-from Post Code";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipFromPostcode := Transfer_Hdr."Transfer-from Post Code";
                                end;
                        end;
                    end;
                }
                textelement(ShipFromCity)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipFromCity := Sales_Hdr."Sell-to City";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipFromCity := Purch_Hdr."Buy-from City";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipFromCity := Transfer_Hdr."Transfer-from City";
                                end;
                        end;
                    end;
                }
                textelement(ShipFromCounty)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipFromCounty := Sales_Hdr."Sell-to County";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipFromCounty := Purch_Hdr."Buy-from County";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipFromCounty := Transfer_Hdr."Transfer-from County";
                                end;
                        end;
                    end;
                }
                textelement(ShipFromCountry)
                {
                    trigger OnBeforePassVariable()

                    begin
                        ShipFromCountry := '';
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    if (Reccountry.Get(Sales_Hdr."Sell-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                        ShipFromCountry := RecCountry."ISO3 Code";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    if (RecCountry.Get(Purch_Hdr."Buy-from Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                        ShipFromCountry := RecCountry."ISO3 Code";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    if (RecCountry.Get(Transfer_Hdr."Trsf.-from Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                        ShipFromCountry := RecCountry."ISO3 Code";
                                end;
                        end;
                    end;
                }
                textelement(PhoneNo)
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
                                        PhoneNo := Sales_Hdr."Ship-to Phone No."
                                    else
                                        if Customer.Get(Sales_Hdr."Sell-to Customer No.") then
                                            PhoneNo := Customer."Phone No.";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    if Vendor.Get(Purch_Hdr."Buy-from Vendor No.") then
                                        PhoneNo := Vendor."Phone No.";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    if Location.Get() then
                                        PhoneNo := Location."Phone No.";
                                end;
                        end;
                    end;
                }
                textelement(Contact)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    Contact := Sales_Hdr."Sell-to Contact";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    Contact := Purch_Hdr."Buy-from Contact";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    Contact := Transfer_Hdr."Transfer-to Contact";
                                end;
                        end;
                    end;
                }
                textelement(ContactEmail)
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
                                    if Sales_Hdr."Sell-to E-Mail" <> '' then
                                        ContactEmail := Sales_Hdr."Sell-to E-Mail"
                                    else
                                        if Customer.Get(Sales_Hdr."Sell-to Customer No.") then
                                            ContactEmail := Customer."E-Mail";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    if Vendor.Get(Purch_Hdr."Buy-from Vendor No.") then
                                        ContactEmail := Vendor."E-Mail";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    if Location.Get() then
                                        ContactEmail := Location."E-Mail";
                                end;
                        end;
                    end;
                }
                textelement(ExpectedReceiptDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::P_Order:
                                begin
                                    if Purch_Hdr."Expected Receipt Date" <> 0D then
                                        ExpectedReceiptDate := Format(Purch_Hdr."Expected Receipt Date", 0, '<Year4>-<Month,2>-<Day,2>');
                                end;
                        end;
                    end;
                }
                textelement(DataLines)
                {
                    tableelement(DataLine; "Warehouse Receipt Line")
                    {
                        LinkTable = DataHeader;
                        LinkFields = "No." = field ("No.");

                        textelement(LineNo)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                LineId := LineId + 1;
                                LineNo := Format(LineId);
                            end;
                        }
                        fieldelement(ItemNo; DataLine."Item No.")
                        {

                        }
                        fieldelement(Description; DataLine.Description)
                        {

                        }
                        fieldelement(Description2; DataLine."Description 2")
                        {

                        }
                        textelement(Quantity)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                Quantity := Format(DataLine.Quantity);
                                if not DecimalSignIsComma then begin
                                    if StrPos(Quantity, ',') <> 0 then
                                        Quantity := DelChr(Quantity, '=', ',');
                                end else begin
                                    if StrPos(Quantity, ',') <> 0 then
                                        Quantity := ConvertStr(Quantity, ',', '.');
                                end;
                            end;
                        }
                        textelement(OrderLineNo)
                        {
                            trigger OnBeforePassVariable()
                            var
                            begin
                                OrderLineNo := '';
                                OrderLineNo := Format(DataLine."Source Line No.");
                            end;
                        }
                        textelement(ItemTrackingLines)
                        {
                            tableelement(ItemTrackingLine; "Reservation Entry")
                            {
                                textelement(TrackingQuantity)
                                {
                                    trigger OnBeforePassVariable()
                                    var
                                        TrackingQuantityText: Text[100];
                                    begin
                                        TrackingQuantity := '';
                                        if ItemTrackingLine.Quantity <> 0 then begin
                                            TrackingQuantity := Format(Abs(ItemTrackingLine.Quantity));
                                            if DecimalSignIsComma then begin
                                                TrackingQuantityText := Format(TrackingQuantity);
                                                IFSetup.SwitchPointComma(TrackingQuantityText);
                                                TrackingQuantity := TrackingQuantityText;
                                                if StrPos(TrackingQuantity, ',') > 0 then
                                                    TrackingQuantity := DelChr(TrackingQuantity, '=', ',');
                                            end;
                                        end;
                                    end;
                                }
                                fieldelement(SerialNo; ItemTrackingLine."Serial No.")
                                {

                                }
                                fieldelement(LotNo; ItemTrackingLine."Lot No.")
                                {

                                }
                                textelement(ExpiryDate)
                                {
                                    trigger OnBeforePassVariable()
                                    begin
                                        if ItemTrackingLine."Expiration Date" <> 0D then
                                            ExpiryDate := Format(ItemTrackingLine."Expiration Date", 0, '<Year4>-<Month,2>-<Day,2>')
                                        else
                                            ExpiryDate := '';
                                    end;
                                }

                                trigger OnPreXmlItem()
                                begin
                                    ItemTrackingLine.Reset();
                                    ItemTrackingLine.SetRange("Source Type", DataLine."Source Type");
                                    ItemTrackingLine.SetRange("Source Subtype", DataLine."Source Subtype");
                                    ItemTrackingLine.SetRange("Source ID", DataLine."Source No.");
                                    ItemTrackingLine.SetRange("Source Ref. No.", DataLine."Source Line No.");
                                    ItemTrackingLine.SetRange("Item No.", DataLine."Item No.");
                                    ItemTrackingLine.SetRange("Reservation Status", ItemTrackingLine."Reservation Status"::Surplus);
                                    //Init to make sure no old data is passed to the next dataline
                                    if not ItemTrackingLine.FindSet() then
                                        ItemTrackingLine.Init();
                                end;
                            }
                        }
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

                    IFSetup.GetWMSIFSetupEntryNo(dataheader."Location Code");
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        //Check if the decimal sign is a comma
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
    end;

    //Global Variables
    var
        IFSetup: Record "Interface Setup";
        Sales_Hdr: Record "Sales Header";
        Purch_Hdr: Record "Purchase Header";
        Transfer_Hdr: Record "Transfer Header";
        Source_Doc: Option S_Order,P_Order,T_Order;
        DecimalSignIsComma: Boolean;
        LineId: Integer;
        RecCountry: Record "Country/Region";
}