xmlport 50008 "Export Inventory"

//  RHE-TNA 19-10-2020..20-11-2020 BDS-4552
//  - Added textelement(ItemReference)
//  - Added textelement(LocationId)
//  - Added textelement(ReferenceNumber)
//  - Added trigger OnPreXmlPort()
//  - Modified textelement QtyAvailable

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified textelement QtyAvailable
//  - Modified trigger OnPreXMLPort()

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
                textelement(QtyAvailable)
                {
                    trigger OnBeforePassVariable()
                    var
                        Available: Decimal;
                        AvailableText: Text[100];
                    begin
                        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                        IFSetup.SetRange(Type, IFSetup.Type::Customer);
                        IFSetup.SetRange("In Progress", true);
                        IFSetup.FindFirst();
                        //RHE-TNA 14-06-2021 BDS-5337 END
                        if IFSetup."Inv. Export Loc. Filter" <> '' then
                            Item.SetFilter("Location Filter", IFSetup."Inv. Export Loc. Filter");
                        Item.CalcFields(Inventory, "Qty. on Asm. Component", "Qty. on Sales Order", "Qty. on Purch. Return");
                        Available := Item.Inventory - Item."Qty. on Asm. Component" - Item."Qty. on Sales Order" - Item."Qty. on Purch. Return";
                        if Available < 0 then
                            Available := 0;

                        //RHE-TNA 20-11-2020 BDS-4552 BEGIN
                        //QtyAvailable := Format(Available);

                        if DecimalSignIsComma then begin
                            AvailableText := Format(Available);
                            IFSetup.SwitchPointComma(AvailableText);
                            QtyAvailable := AvailableText;
                        end else
                            QtyAvailable := Format(Available);
                        if StrPos(QtyAvailable, ',') > 0 then
                            QtyAvailable := DelChr(QtyAvailable, '=', ',');
                        //RHE-TNA 20-11-2020 BDS-4552 BEGIN
                    end;
                }
                //RHE-TNA 19-10-2020 BDS-4552 BEGIN
                textelement(References)
                {
                    tableelement(Reference; "Interface Record Parameters")
                    {
                        textelement(ItemReference)
                        //fieldelement(ItemReference; Reference.Param3)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                if Reference."Source No." = Item."No." then
                                    ItemReference := Reference.Param3;
                            end;
                        }
                        textelement(LocationId)
                        //fieldelement(LocationId; Reference.Param2)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                if Reference."Source No." = Item."No." then
                                    LocationId := Reference.Param2;
                            end;
                        }
                        textelement(ReferenceNumber)
                        //fieldelement(ReferenceNumber; Reference.Param1)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                if Reference."Source No." = Item."No." then
                                    ReferenceNumber := Reference.Param1;
                            end;
                        }
                        trigger OnPreXmlItem()
                        begin
                            ItemReference := '';
                            LocationId := '';
                            ReferenceNumber := '';
                            Reference.Reset();
                            Reference.SetRange("Source Type", Reference."Source Type"::Item);
                            Reference.SetRange("Source No.", Item."No.");
                        end;
                    }
                }
                //RHE-TNA 19-10-2020 BDS-4552 END
            }
        }
    }

    //RHE-TNA 19-10-2020..20-11-2020 BDS-4552 BEGIN
    trigger OnPreXmlPort()
    begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        //IFSetup.TestField("Inv. Export Directory");
        //RHE-TNA 14-06-2021 BDS-5337 END
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
    end;
    //RHE-TNA 19-10-2020..20-11-2020 BDS-4552 END

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        DecimalSignIsComma: Boolean;
}