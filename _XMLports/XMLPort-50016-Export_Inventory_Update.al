xmlport 50016 "Export Inventory Update"

//  RHE-TNA 18-10-2021..22-12-2021 BDS-5677
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
            tableelement(Transaction; "Item Ledger Entry")
            {
                textelement(TransactionDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        TransactionDate := Format(Transaction."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>');
                    end;
                }
                fieldelement(TransactionNo; Transaction."Entry No.")
                {

                }
                fieldelement(ItemNo; Transaction."Item No.")
                {

                }
                textelement(Quantity)
                {
                    trigger OnBeforePassVariable()
                    var
                        QuantityText: Text[100];
                    begin
                        if DecimalSignIsComma then begin
                            QuantityText := Format(Transaction.Quantity);
                            IFSetup.SwitchPointComma(QuantityText);
                            Quantity := QuantityText;
                        end else
                            Quantity := Format(Transaction.Quantity);
                        if StrPos(Quantity, ',') > 0 then
                            Quantity := DelChr(Quantity, '=', ',');
                    end;
                }
                textelement(TransactionType)
                {
                    trigger OnBeforePassVariable()
                    begin
                        if Transaction."Entry Type" = Transaction."Entry Type"::Transfer then
                            TransactionType := 'Inventory Update'
                        else
                            TransactionType := 'Adjustment';
                    end;
                }
                fieldelement(LocationCode; Transaction."Location Code")
                {

                }
                textelement(OldLocationCode)
                {
                    trigger OnBeforePassVariable()
                    var
                        ILE: Record "Item Ledger Entry";
                    begin
                        OldLocationCode := '';
                        if Transaction."Entry Type" = Transaction."Entry Type"::Transfer then begin
                            if ILE.Get(Transaction."Entry No." - 1) then
                                OldLocationCode := ILE."Location Code";
                        end else
                            currXMLport.Skip();
                    end;
                }
                textelement(SerialNumber)
                {
                    trigger OnBeforePassVariable()
                    begin
                        SerialNumber := '';
                        if Transaction."Serial No." <> '' then
                            SerialNumber := Transaction."Serial No."
                        else
                            currXMLport.Skip();
                    end;
                }
                textelement(LotNumber)
                {
                    trigger OnBeforePassVariable()
                    begin
                        LotNumber := '';
                        if Transaction."Lot No." <> '' then
                            LotNumber := Transaction."Lot No."
                        else
                            currXMLport.Skip();
                    end;
                }
                textelement(ExpiryDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        ExpiryDate := '';
                        if Transaction."Expiration Date" <> 0D then
                            ExpiryDate := Format(Transaction."Expiration Date", 0, '<Year4>-<Month,2>-<Day,2>')
                        else
                            currXMLport.Skip();
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