xmlport 50017 "Export Inventory Level"

//  RHE-TNA 14-10-2021 BDS-5678
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
            tableelement(Item; Item)
            {
                fieldelement(ItemNo; Item."No.")
                {

                }
                tableelement(Inventory; Location)
                {
                    fieldelement(LocationCode; Inventory.Code)
                    {
                    }
                    textelement(Quantity)
                    {
                        trigger OnBeforePassVariable()
                        var
                            Qty: Decimal;
                            QtyText: Text[100];
                        begin
                            Item.SetFilter("Location Filter", Inventory.Code);
                            Item.CalcFields(Inventory);
                            Qty := Item.Inventory;

                            if DecimalSignIsComma then begin
                                QtyText := Format(Qty);
                                IFSetup.SwitchPointComma(QtyText);
                                Quantity := QtyText;
                            end else
                                Quantity := Format(Qty);
                            if StrPos(Quantity, ',') > 0 then
                                Quantity := DelChr(Quantity, '=', ',');
                        end;
                    }
                    textelement(ItemTrackingLines)
                    {
                        tableelement(ItemTrackingLine; "Item Ledger Entry")
                        {
                            MinOccurs = Zero;
                            textelement(TrackingQuantity)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    TrackingQuantityText: Text[100];
                                begin
                                    if (ItemTrackingLine."Lot No." = '') and (ItemTrackingLine."Serial No." = '') then
                                        currXMLport.Skip();
                                    TrackingQuantity := Format(ItemTrackingLine."Remaining Quantity");
                                    if DecimalSignIsComma then begin
                                        TrackingQuantityText := Format(TrackingQuantity);
                                        IFSetup.SwitchPointComma(TrackingQuantityText);
                                        TrackingQuantity := TrackingQuantityText;
                                        if StrPos(TrackingQuantity, ',') > 0 then
                                            TrackingQuantity := DelChr(TrackingQuantity, '=', ',');
                                    end;
                                end;
                            }
                            textelement(SerialNumber)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if ItemTrackingLine."Serial No." <> '' then
                                        SerialNumber := ItemTrackingLine."Serial No."
                                    else
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(LotNumber)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if ItemTrackingLine."Lot No." <> '' then
                                        LotNumber := ItemTrackingLine."Lot No."
                                    else
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(ExpiryDate)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if ItemTrackingLine."Expiration Date" <> 0D then
                                        ExpiryDate := FORMAT(ItemTrackingLine."Expiration Date", 0, '<Year4>-<Month,2>-<Day,2>')
                                    else
                                        currXMLport.Skip();
                                end;
                            }

                            trigger OnPreXmlItem()
                            var
                                ItemTrackingCode: Record "Item Tracking Code";
                            begin
                                ItemTrackingLine.SetRange("Item No.", Item."No.");
                                ItemTrackingLine.SetRange("Location Code", Inventory.Code);
                                ItemTrackingLine.SetFilter("Remaining Quantity", '<>0');

                                if (Item."Item Tracking Code" <> '') and (ItemTrackingCode.Get(Item."Item Tracking Code")) then begin
                                    if ItemTrackingCode."SN Purchase Inbound Tracking" then
                                        ItemTrackingLine.SetFilter("Serial No.", '<>%1', '''');
                                    if ItemTrackingCode."Lot Purchase Inbound Tracking" then
                                        ItemTrackingLine.SetFilter("Lot No.", '<>%1', '''');
                                    //Dummy filter to not create XML element ItemTrackingLine
                                    if (not ItemTrackingCode."SN Purchase Inbound Tracking") and (not ItemTrackingCode."Lot Purchase Inbound Tracking") then
                                        ItemTrackingLine.SetRange("Entry No.", 0);
                                end else
                                    //Dummy filter to not create XML element ItemTrackingLine
                                    ItemTrackingLine.SetRange("Entry No.", 0);
                            end;
                        }
                    }
                    trigger OnPreXmlItem()
                    begin
                        //Check if inventory is present on location, otherwise exlude Location
                        Inventory.FindSet();
                        repeat
                            Item.SetFilter("Location Filter", Inventory.Code);
                            Item.CalcFields(Inventory);
                            if Item.Inventory <> 0 then
                                Inventory.Mark(true);
                        until Inventory.Next() = 0;
                        Inventory.MarkedOnly(true);
                    end;
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        DecimalSignIsComma: Boolean;
}