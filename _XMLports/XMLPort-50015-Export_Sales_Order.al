xmlport 50015 "Export Sales Order"

//  RHE-TNA 16-11-2021 BDS-5676
//  - New XMLPort

//  RHE-TNA 14-04-2022 BDS-6275
//  - Changed element(Carrier)

//  RHE-TNA 19-04-2022 BDS-6233
//  - Added element(ShippingCost)

//  RHE-TNA 08-06-2022 BDS-6378
//  - Added trigger OnAfterGetRecord()

{
    Direction = Export;
    Format = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;

    schema
    {
        textelement(Root)
        {
            tableelement(SalesOrder; "Sales Header Archive")
            {
                fieldelement(OrderID; SalesOrder."No.")
                {

                }
                textelement(YourReference)
                {
                    trigger OnBeforePassVariable()
                    begin
                        //In case of an EDI order, Ext. Doc. No. is entered with order number from interface.
                        if IFLog.CheckEDIOrder(SalesOrder."No.") then
                            YourReference := SalesOrder."External Document No."
                        else
                            YourReference := SalesOrder."Your Reference";
                    end;
                }
                textelement(ExternalDocNumber)
                {
                    trigger OnBeforePassVariable()
                    begin
                        //In case of an EDI order, Your Reference is entered with invoice number from interface (assumption: this is ref. from customer).
                        if IFLog.CheckEDIOrder(SalesOrder."No.") then
                            ExternalDocNumber := SalesOrder."Your Reference"
                        else
                            ExternalDocNumber := SalesOrder."External Document No.";
                    end;
                }
                fieldelement(OrderStatus; SalesOrder.Status)
                {

                }
                textelement(OrderDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        OrderDate := Format(SalesOrder."Order Date", 0, '<Year4>-<Month,2>-<Day,2>');
                    end;
                }
                textelement(RequestedDeliveryDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        RequestedDeliveryDate := Format(SalesOrder."Requested Delivery Date", 0, '<Year4>-<Month,2>-<Day,2>');
                    end;
                }
                textelement(DocumentDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        DocumentDate := Format(SalesOrder."Document Date", 0, '<Year4>-<Month,2>-<Day,2>');
                    end;
                }
                fieldelement(CustomerID; SalesOrder."Sell-to Customer No.")
                {

                }
                textelement(CustomerID2)
                {
                    trigger OnBeforePassVariable()
                    var
                        Customer: Record Customer;
                    begin
                        Customer.Get(SalesOrder."Sell-to Customer No.");
                        if Customer.GLN <> '' then
                            CustomerID2 := Customer.GLN
                        else
                            if Customer."EDI Identifier" <> '' then
                                CustomerID2 := Customer."EDI Identifier"
                            else
                                currXMLport.Skip();
                    end;
                }
                fieldelement(Email; SalesOrder."Sell-to E-Mail")
                {

                }
                fieldelement(Phone; SalesOrder."Sell-to Phone No.")
                {

                }
                fieldelement(BillToName; SalesOrder."Bill-to Name")
                {

                }
                fieldelement(BillToAddress; SalesOrder."Bill-to Address")
                {

                }
                fieldelement(BillToAddress2; SalesOrder."Bill-to Address 2")
                {

                }
                fieldelement(BillToPostalCode; SalesOrder."Bill-to Post Code")
                {

                }
                fieldelement(BillToCity; SalesOrder."Bill-to City")
                {

                }
                fieldelement(BillToCountry; SalesOrder."Bill-to Country/Region Code")
                {

                }
                fieldelement(BillToContact; SalesOrder."Bill-to Contact")
                {

                }
                fieldelement(ShipToName; SalesOrder."Ship-to Name")
                {

                }
                fieldelement(ShipToAddress; SalesOrder."Ship-to Address")
                {

                }
                fieldelement(ShipToAddress2; SalesOrder."Ship-to Address 2")
                {

                }
                fieldelement(ShipToPostalCode; SalesOrder."Ship-to Post Code")
                {

                }
                fieldelement(ShipToCity; SalesOrder."Ship-to City")
                {

                }
                fieldelement(ShipToCountry; SalesOrder."Ship-to Country/Region Code")
                {

                }
                fieldelement(ShipToContact; SalesOrder."Ship-to Contact")
                {

                }
                fieldelement(CustomerVATNumber; SalesOrder."VAT Registration No.")
                {

                }
                fieldelement(PaymentTerms; SalesOrder."Payment Terms Code")
                {

                }
                fieldelement(IncoTerms; SalesOrder."Shipment Method Code")
                {

                }
                //RHE-TNA 14-04-2022 BDS-6269 BEGIN
                //fieldelement(Carrier; SalesOrder."Shipping Agent Code")
                textelement(Carrier)
                {
                    trigger OnBeforePassVariable()
                    var
                        Location: Record Location;
                        CountryType: Option "Domestic","EU","NON-EU";
                        Country: Record "Country/Region";
                        IFMapping: Record "Interface Mapping";
                    begin
                        Carrier := SalesOrder."Shipping Agent Code";

                        //Determine if order is Domestic, EU or NON-EU
                        Location.Get(SalesOrder."Location Code");
                        if Country.Get(SalesOrder."Ship-to Country/Region Code") then begin
                            if Country.Code = Location."Country/Region Code" then
                                CountryType := CountryType::Domestic
                            else
                                if Country."EU Country/Region Code" <> '' then
                                    CountryType := CountryType::EU
                                else
                                    CountryType := CountryType::"NON-EU";

                            //Determine interface value
                            IFMapping.SetRange(Type, IFMapping.Type::Carrier);
                            IFMapping.SetRange("Shipping Agent Code", SalesOrder."Shipping Agent Code");
                            case CountryType of
                                CountryType::Domestic:
                                    begin
                                        IFMapping.SetRange("Ship Agent Service Code Dom.", SalesOrder."Shipping Agent Service Code");
                                    end;
                                CountryType::EU:
                                    begin
                                        IFMapping.SetRange("Ship Agent Service Code EU", SalesOrder."Shipping Agent Service Code");
                                    end;
                                CountryType::"NON-EU":
                                    begin
                                        IFMapping.SetRange("Ship Agent Service Code Export", SalesOrder."Shipping Agent Service Code");
                                    end;
                            end;
                            if IFMapping.FindFirst() then
                                Carrier := IFMapping."Interface Value";
                        end;
                    end;
                }
                //RHE-TNA 14-04-2022 BDS-6269 END
                textelement(CurrencyCode)
                {
                    trigger OnBeforePassVariable()
                    begin
                        if SalesOrder."Currency Code" = '' then
                            CurrencyCode := GLSetup."LCY Code"
                        else
                            CurrencyCode := SalesOrder."Currency Code";
                    end;
                }
                textelement(NetAmountTotal)
                {
                    trigger OnBeforePassVariable()
                    var
                        NetAmountTotalText: Text[100];
                    begin
                        SalesOrder.CalcFields(Amount);
                        if DecimalSignIsComma then begin
                            NetAmountTotalText := Format(SalesOrder.Amount);
                            IFSetup.SwitchPointComma(NetAmountTotalText);
                            NetAmountTotal := NetAmountTotalText;
                        end else
                            NetAmountTotal := Format(SalesOrder.Amount);
                        if StrPos(NetAmountTotal, ',') > 0 then
                            NetAmountTotal := DelChr(NetAmountTotal, '=', ',');
                    end;
                }
                textelement(VATAmountTotal)
                {
                    trigger OnBeforePassVariable()
                    var
                        VATAmountTotalText: Text[100];
                    begin
                        SalesOrder.CalcFields("Amount Including VAT");
                        VATAmountTotal := Format(SalesOrder."Amount Including VAT" - SalesOrder.Amount);
                        if DecimalSignIsComma then begin
                            VATAmountTotalText := Format(VATAmountTotal);
                            IFSetup.SwitchPointComma(VATAmountTotalText);
                            VATAmountTotal := VATAmountTotalText;
                            if StrPos(VATAmountTotal, ',') > 0 then
                                VATAmountTotal := DelChr(VATAmountTotal, '=', ',');
                        end;
                        if StrPos(VATAmountTotal, ',') > 0 then
                            VATAmountTotal := DelChr(VATamountTotal, '=', ',');
                    end;
                }
                textelement(GrossAmountTotal)
                {
                    trigger OnBeforePassVariable()
                    var
                        GrossAmountTotalText: Text[100];
                    begin
                        SalesOrder.CalcFields("Amount Including VAT");
                        if DecimalSignIsComma then begin
                            GrossAmountTotalText := Format(SalesOrder."Amount Including VAT");
                            IFSetup.SwitchPointComma(GrossAmountTotalText);
                            GrossAmountTotal := GrossAmountTotalText;
                        end else
                            GrossAmountTotal := Format(SalesOrder."Amount Including VAT");
                        if StrPos(GrossAmountTotal, ',') > 0 then
                            GrossAmountTotal := DelChr(GrossamountTotal, '=', ',');
                    end;
                }

                textelement(SalesOrderLines)
                {
                    tableelement(SalesOrderLine; "Sales Line Archive")
                    {
                        LinkTable = SalesOrder;
                        LinkFields = "Document Type" = field ("Document Type"), "Document No." = field ("No."), "Version No." = field ("Version No."), "Doc. No. Occurrence" = field ("Doc. No. Occurrence");
                        SourceTableView = where (Quantity = filter (<> 0));

                        fieldelement(LineNumber; SalesOrderLine."Line No.")
                        {

                        }
                        fieldelement(LineType; SalesOrderLine.Type)
                        {

                        }
                        fieldelement(ItemNo; SalesOrderLine."No.")
                        {

                        }
                        fieldelement(Description; SalesOrderLine.Description)
                        {

                        }
                        textelement(Quantity)
                        {
                            trigger OnBeforePassVariable()
                            var
                                QuantityText: Text[100];
                            begin
                                if DecimalSignIsComma then begin
                                    QuantityText := Format(SalesOrderLine.Quantity);
                                    IFSetup.SwitchPointComma(QuantityText);
                                    Quantity := QuantityText;
                                end else
                                    Quantity := Format(SalesOrderLine.Quantity);
                                if StrPos(Quantity, ',') > 0 then
                                    Quantity := DelChr(Quantity, '=', ',');
                            end;
                        }
                        textelement(UnitOfMeasure)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                if SalesOrderLine."Unit of Measure Code" <> '' then
                                    UnitOfMeasure := SalesOrderLine."Unit of Measure Code"
                                else
                                    UnitOfMeasure := 'EA';
                            end;
                        }
                        textelement(UnitPrice)
                        {
                            trigger OnBeforePassVariable()
                            var
                                UnitPriceText: Text[100];
                            begin
                                if DecimalSignIsComma then begin
                                    UnitPriceText := Format(SalesOrderLine."Unit Price");
                                    IFSetup.SwitchPointComma(UnitPriceText);
                                    UnitPrice := UnitPriceText;
                                end else
                                    UnitPrice := Format(SalesOrderLine."Unit Price");
                                if StrPos(UnitPrice, ',') > 0 then
                                    UnitPrice := DelChr(UnitPrice, '=', ',');
                            end;
                        }
                        textelement(DiscountAmount)
                        {
                            trigger OnBeforePassVariable()
                            var
                                DiscountAmountText: Text[100];
                            begin
                                if DecimalSignIsComma then begin
                                    DiscountAmountText := Format(SalesOrderLine."Line Discount Amount");
                                    IFSetup.SwitchPointComma(DiscountAmount);
                                    DiscountAmount := DiscountAmountText;
                                end else
                                    DiscountAmount := Format(SalesOrderLine."Line Discount Amount");
                                if StrPos(DiscountAmount, ',') > 0 then
                                    DiscountAmount := DelChr(DiscountAmount, '=', ',');
                            end;
                        }
                        textelement(NetAmount)
                        {
                            trigger OnBeforePassVariable()
                            var
                                NetAmountText: Text[100];
                            begin
                                if DecimalSignIsComma then begin
                                    NetAmountText := Format(SalesOrderLine.Amount);
                                    IFSetup.SwitchPointComma(NetAmount);
                                    NetAmount := NetAmountText;
                                end else
                                    NetAmount := Format(SalesOrderLine.Amount);
                                if StrPos(NetAmount, ',') > 0 then
                                    NetAmount := DelChr(NetAmount, '=', ',');
                            end;
                        }
                        textelement(VATAmount)
                        {
                            trigger OnBeforePassVariable()
                            var
                                VATAmountText: Text[100];
                            begin
                                VATAmount := Format(SalesOrderLine."Amount Including VAT" - SalesOrderLine.Amount);
                                if DecimalSignIsComma then begin
                                    VATAmountText := Format(VATAmount);
                                    IFSetup.SwitchPointComma(VATAmount);
                                    VATAmount := VATAmountText;
                                end;
                                if StrPos(VATAmount, ',') > 0 then
                                    VATAmount := DelChr(VATAmount, '=', ',');
                            end;
                        }
                        textelement(GrossAmount)
                        {
                            trigger OnBeforePassVariable()
                            var
                                GrossAmountText: Text[100];
                            begin
                                if DecimalSignIsComma then begin
                                    GrossAmountText := Format(SalesOrderLine."Amount Including VAT");
                                    IFSetup.SwitchPointComma(GrossAmount);
                                    GrossAmount := GrossAmountText;
                                end else
                                    GrossAmount := Format(SalesOrderLine."Amount Including VAT");
                                if StrPos(GrossAmount, ',') > 0 then
                                    GrossAmount := DelChr(GrossAmount, '=', ',');
                            end;
                        }
                        //RHE-TNA 19-04-2022 BDS-6233 BEGIN
                        textelement(ShippingCost)
                        {
                            trigger OnBeforePassVariable()
                            var
                                Item: Record Item;
                            begin
                                //IFSetup."Order Version" version 0 from backend equals version 1 from frontend
                                if IFSetup."Order Version" > 0 then begin
                                    if SalesOrderLine.Type = SalesOrderLine.Type::Item then begin
                                        Item.Get(SalesOrderLine."No.");
                                        if Item."Shipping Cost Item" then
                                            ShippingCost := 'Yes'
                                        else
                                            ShippingCost := 'No';
                                    end else
                                        currXMLport.Skip();
                                end else
                                    currXMLport.Skip();
                            end;
                        }
                        //RHE-TNA 19-04-2022 BDS-6233 END
                        textelement(ItemTrackingLines)
                        {
                            tableelement(ItemTrackingLine; "Reservation Entry")
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
                                        TrackingQuantity := Format(-ItemTrackingLine.Quantity);
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
                                //Get tracking lines based upon sales order
                                trigger OnPreXmlItem()
                                begin
                                    ItemTrackingLine.SetFilter("Item Tracking", '<>%1', ItemTrackingLine."Item Tracking"::None);
                                    ItemTrackingLine.SetRange("Source Type", 37);
                                    ItemTrackingLine.SetRange("Source Subtype", 1);
                                    ItemTrackingLine.SetRange("Source ID", SalesOrderLine."Document No.");
                                    ItemTrackingLine.SetRange("Source Ref. No.", SalesOrderLine."Line No.");
                                end;
                            }

                        }
                        //RHE-TNA 08-06-2022 BDS-6378 BEGIN
                        trigger OnAfterGetRecord()
                        var
                            Item: Record Item;
                        begin
                            if SalesOrderLine.Type = SalesOrderLine.Type::Item then begin
                                Item.Get(SalesOrderLine."No.");
                                if (Item.ExclItemEDI) and (SalesOrderLine."Line Amount" = 0) then
                                    currXMLport.Skip();
                            end;
                        end;
                        //RHE-TNA 08-06-2022 BDS-6378 END
                    }
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        GLSetup.Get();
        IFSetup.Get(IFSetup.GetIFSetupRecforDocNo(SalesOrder."No."));
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        GLSetup: Record "General Ledger Setup";
        DecimalSignIsComma: Boolean;
        IFLog: Record "Interface Log";
}