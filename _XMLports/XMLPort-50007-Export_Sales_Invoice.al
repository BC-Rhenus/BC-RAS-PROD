xmlport 50007 "Export Sales Invoice"

//  RHE-TNA 06-04-2020 BDS-4033
//  - Added OnAfterGetRecord of SalesInvoice
//  - Modified textelement(Component_Item)
//  - Modified textelement(Component_Qty)
//  - Modified textelement(WMSOrderNumber)

//  RHE-TNA 25-05-2020 BDS-4175 --> 15-06-2020: removed change
//  - Modified textelement(Component_Item)

//  RHE-TNA 19-10-2020 BDS-4551
//  - Added textelement(ReferenceNumber)
//  - Added textelement(ReferenceNumber2)

//  RHE-TNA 05-01-2021 BDS-4812
//  - Added textelement Tags

//  RHE-TNA 14-06-2021..29-03-2022 BDS-5337
//  - Modified schema
//  - Modified trigger OnPreXmlPort()
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 15-10-2021 BDS-5679
//  - Modified element PackageTrackingNo

//  RHE-TNA 16-11-2021..06-01-2022 BDS-5676
//  - Added textelement LineType
//  - Added textelement BillToCountry
//  - Added textelement ShipToCountry
//  - Added textelement PaymentTerms
//  - Added textelement DueDate
//  - Added textelement CustomerVATNumber
//  - Changed textelement VATAmountTotal

//  RHE-TNA 14-04-2022 BDS-6269
//  - Added versioning to multiple elements

//  RHE-TNA 20-04-2022 BDS-6275
//  - Changed element(Carrier)

//  RHE-TNA 04-05-2022 BDS-6233
//  - Added element(ShippingCost)

//  RHE-TNA 08-06-2022 BDS-6378
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 20-06-2022 BDS-6438
//  - Added ShipFrom* elements

//  RHE-TNA 22-06-2022 BDS-6440
//  - Added Components elements

{
    Direction = Export;
    Format = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;

    schema
    {
        textelement(Root)
        {
            tableelement(SalesInvoice; "Sales Invoice Header")
            {
                fieldelement(InvoiceNumber; SalesInvoice."No.")
                {

                }
                fieldelement(OrderNumber; SalesInvoice."Order No.")
                {

                }
                fieldelement(YourReference; SalesInvoice."Your Reference")
                {

                }
                fieldelement(ExternalDocNumber; SalesInvoice."External Document No.")
                {

                }
                fieldelement(CustomerNumber; SalesInvoice."Sell-to Customer No.")
                {

                }
                textelement(PostingDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        PostingDate := Format(SalesInvoice."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>');
                    end;
                }
                textelement(PaymentTerms)
                {
                    trigger OnBeforePassVariable()
                    begin
                        PaymentTerms := '';
                        //RHE-TNA 14-04-2022 BDS-6269 BEGIN
                        //if IFSetup."Add Payment Information" then
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 0 then
                            //RHE-TNA 14-04-2022 BDS-6269 END
                            PaymentTerms := SalesInvoice."Payment Terms Code"
                        else
                            currXMLport.Skip();
                    end;
                }
                textelement(DueDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        DueDate := '';
                        //RHE-TNA 14-04-2022 BDS-6269 BEGIN
                        //if IFSetup."Add Payment Information" then
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 0 then
                            //RHE-TNA 14-04-2022 BDS-6269 END
                            DueDate := Format(SalesInvoice."Due Date", 0, '<Year4>-<Month,2>-<Day,2>')
                        else
                            currXMLport.Skip();
                    end;
                }
                textelement(CustomerVATNumber)
                {
                    trigger OnBeforePassVariable()
                    begin
                        CustomerVATNumber := '';
                        //RHE-TNA 14-04-2022 BDS-6269 BEGIN
                        //if IFSetup."Add Payment Information" then
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 0 then
                            //RHE-TNA 14-04-2022 BDS-6269 END
                            CustomerVATNumber := SalesInvoice."VAT Registration No."
                        else
                            currXMLport.Skip();
                    end;
                }
                fieldelement(IncoTerms; SalesInvoice."Shipment Method Code")
                {

                }
                //RHE-TNA 20-04-2022 BDS-6275 BEGIN
                //fieldelement(Carrier; SalesInvoice."Shipping Agent Code")
                textelement(Carrier)
                {
                    trigger OnBeforePassVariable()
                    var
                        Location: Record Location;
                        CountryType: Option "Domestic","EU","NON-EU";
                        Country: Record "Country/Region";
                        ValueEntry: Record "Value Entry";
                        ILE: Record "Item Ledger Entry";
                        SalesShipmentHdr: Record "Sales Shipment Header";
                        IFMapping: Record "Interface Mapping";
                    begin
                        Carrier := SalesInvoice."Shipping Agent Code";

                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 1 then begin
                            //Determine if order is Domestic, EU or NON-EU
                            Location.Get(SalesInvoice."Location Code");
                            if Country.Get(SalesInvoice."Ship-to Country/Region Code") then begin
                                if Country.Code = Location."Country/Region Code" then
                                    CountryType := CountryType::Domestic
                                else
                                    if Country."EU Country/Region Code" <> '' then
                                        CountryType := CountryType::EU
                                    else
                                        CountryType := CountryType::"NON-EU";

                                //Determine shipping agent and service via Sales Shipment table as shipping agent service is not present in Sales Invoice
                                ValueEntry.SetRange("Document No.", SalesInvoice."No.");
                                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                                ValueEntry.SetRange("Posting Date", SalesInvoice."Posting Date");
                                if (ValueEntry.FindFirst()) and (ValueEntry."Item Ledger Entry No." <> 0) then begin
                                    if ILE.Get(ValueEntry."Item Ledger Entry No.") then
                                        if (ILE."Document Type" = ILE."Document Type"::"Sales Shipment") and (SalesShipmentHdr.Get(ILE."Document No.")) then begin
                                            IFMapping.SetRange(Type, IFMapping.Type::Carrier);
                                            IFMapping.SetRange("Shipping Agent Code", SalesShipmentHdr."Shipping Agent Code");
                                            case CountryType of
                                                CountryType::Domestic:
                                                    begin
                                                        IFMapping.SetRange("Ship Agent Service Code Dom.", SalesShipmentHdr."Shipping Agent Service Code");
                                                    end;
                                                CountryType::EU:
                                                    begin
                                                        IFMapping.SetRange("Ship Agent Service Code EU", SalesShipmentHdr."Shipping Agent Service Code");
                                                    end;
                                                CountryType::"NON-EU":
                                                    begin
                                                        IFMapping.SetRange("Ship Agent Service Code Export", SalesShipmentHdr."Shipping Agent Service Code");
                                                    end;
                                            end;
                                            if IFMapping.FindFirst() then
                                                Carrier := IFMapping."Interface Value";
                                        end;
                                end;
                            end;
                        end;
                    end;
                }
                //RHE-TNA 20-04-2022 BDS-6275 END

                //RHE-TNA 15-10-2021 BDS-5679 BEGIN
                //fieldelement(PackageTrackingNo; SalesInvoice."Package Tracking No.")
                textelement(PackageTrackingNo)
                {
                    trigger OnBeforePassVariable()
                    var
                        ValueEntry: Record "Value Entry";
                        ILE: Record "Item Ledger Entry";
                        SalesShipmentHdr: Record "Sales Shipment Header";
                        ShippingAgentService: Record "Shipping Agent Services";
                    begin
                        PackageTrackingNo := '';
                        //Determine shipping agent and service via Sales Shipment table as shipping agent service is not present in Sales Invoice
                        ValueEntry.SetRange("Document No.", SalesInvoice."No.");
                        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                        ValueEntry.SetRange("Posting Date", SalesInvoice."Posting Date");
                        if (ValueEntry.FindFirst()) and (ValueEntry."Item Ledger Entry No." <> 0) then begin
                            if ILE.Get(ValueEntry."Item Ledger Entry No.") then
                                if (ILE."Document Type" = ILE."Document Type"::"Sales Shipment") and (SalesShipmentHdr.Get(ILE."Document No.")) then
                                    if ShippingAgentService.Get(SalesShipmentHdr."Shipping Agent Code", SalesShipmentHdr."Shipping Agent Service Code") then
                                        if ShippingAgentService."Service Incl. Tracking No." then
                                            PackageTrackingNo := SalesInvoice."Package Tracking No.";
                        end;
                    end;
                }
                //RHE-TNA 15-10-2021 BDS-5679 END
                textelement(CurrencyCode)
                {
                    trigger OnBeforePassVariable()
                    begin
                        if SalesInvoice."Currency Code" = '' then
                            CurrencyCode := GLSetup."LCY Code"
                        else
                            CurrencyCode := SalesInvoice."Currency Code";
                    end;
                }
                textelement(NetAmountTotal)
                {
                    trigger OnBeforePassVariable()
                    var
                        NetAmountTotalText: Text[100];
                    begin
                        SalesInvoice.CalcFields(Amount);
                        if DecimalSignIsComma then begin
                            NetAmountTotalText := Format(SalesInvoice.Amount);
                            IFSetup.SwitchPointComma(NetAmountTotalText);
                            NetAmountTotal := NetAmountTotalText;
                        end else
                            NetAmountTotal := Format(SalesInvoice.Amount);
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
                        //RHE-TNA 06-01-2022 BDS-5676 BEGIN
                        /*
                        SalesInvoice.CalcFields("Amount Including VAT");
                        VATAmountTotal := Format(SalesInvoice."Amount Including VAT" - SalesInvoice."Amount Including VAT");*/
                        SalesInvoice.CalcFields("Amount Including VAT", Amount);
                        VATAmountTotal := Format(SalesInvoice."Amount Including VAT" - SalesInvoice.Amount);
                        //RHE-TNA 06-01-2022 BDS-5676 BEGIN
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
                        SalesInvoice.CalcFields("Amount Including VAT");
                        if DecimalSignIsComma then begin
                            GrossAmountTotalText := Format(SalesInvoice."Amount Including VAT");
                            IFSetup.SwitchPointComma(GrossAmountTotalText);
                            GrossAmountTotal := GrossAmountTotalText;
                        end else
                            GrossAmountTotal := Format(SalesInvoice."Amount Including VAT");
                        if StrPos(GrossAmountTotal, ',') > 0 then
                            GrossAmountTotal := DelChr(GrossamountTotal, '=', ',');
                    end;
                }
                fieldelement(BillToName; SalesInvoice."Bill-to Name")
                {

                }
                fieldelement(BillToAddress; SalesInvoice."Bill-to Address")
                {

                }
                fieldelement(BillToAddress2; SalesInvoice."Bill-to Address 2")
                {

                }
                fieldelement(BillToPostalCode; SalesInvoice."Bill-to Post Code")
                {

                }
                fieldelement(BillToCity; SalesInvoice."Bill-to City")
                {

                }
                textelement(BillToCountry)
                {
                    trigger OnBeforePassVariable()
                    begin
                        BillToCountry := '';
                        //RHE-TNA 14-04-2022 BDS-6269 BEGIN
                        //if IFSetup."Add Ship-to/Bill-to Country" then
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 0 then
                            //RHE-TNA 14-04-2022 BDS-6269 END
                            BillToCountry := SalesInvoice."Bill-to Country/Region Code"
                        else
                            currXMLport.Skip();
                    end;
                }

                fieldelement(BillToContact; SalesInvoice."Bill-to Contact")
                {

                }
                fieldelement(ShipToName; SalesInvoice."Ship-to Name")
                {

                }
                fieldelement(ShipToAddress; SalesInvoice."Ship-to Address")
                {

                }
                fieldelement(ShipToAddress2; SalesInvoice."Ship-to Address 2")
                {

                }
                fieldelement(ShipToPostalCode; SalesInvoice."Ship-to Post Code")
                {

                }
                fieldelement(ShipToCity; SalesInvoice."Ship-to City")
                {

                }
                textelement(ShipToCountry)
                {
                    trigger OnBeforePassVariable()
                    begin
                        ShipToCountry := '';
                        //RHE-TNA 14-04-2022 BDS-6269 BEGIN
                        //if IFSetup."Add Ship-to/Bill-to Country" then
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 0 then
                            //RHE-TNA 14-04-2022 BDS-6269 END
                            ShipToCountry := SalesInvoice."Ship-to Country/Region Code"
                        else
                            currXMLport.Skip();
                    end;
                }
                fieldelement(ShipToContact; SalesInvoice."Ship-to Contact")
                {

                }
                //RHE-TNA 20-06-2022 BDS-6438 BEGIN
                textelement(ShipFromCode)
                {
                    trigger OnBeforePassVariable()
                    begin
                        ShipFromCode := '';
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 2 then
                            ShipFromCode := SalesInvoice."Location Code"
                        else
                            currXMLport.Skip();
                    end;
                }
                textelement(ShipFromName)
                {
                    trigger OnBeforePassVariable()
                    var
                        Location: Record Location;
                    begin
                        ShipFromCode := '';
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 2 then begin
                            if Location.Get(SalesInvoice."Location Code") then
                                ShipFromName := Location.Name;
                        end else
                            currXMLport.Skip();
                    end;
                }
                textelement(ShipFromAddress)
                {
                    trigger OnBeforePassVariable()
                    var
                        Location: Record Location;
                    begin
                        ShipFromAddress := '';
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 2 then begin
                            if Location.Get(SalesInvoice."Location Code") then
                                ShipFromAddress := Location.Address;
                        end else
                            currXMLport.Skip();
                    end;
                }
                textelement(ShipFromAddress2)
                {
                    trigger OnBeforePassVariable()
                    var
                        Location: Record Location;
                    begin
                        ShipFromAddress2 := '';
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 2 then begin
                            if Location.Get(SalesInvoice."Location Code") then
                                ShipFromAddress2 := Location."Address 2";
                        end else
                            currXMLport.Skip();
                    end;
                }
                textelement(ShipFromPostalCode)
                {
                    trigger OnBeforePassVariable()
                    var
                        Location: Record Location;
                    begin
                        ShipFromPostalCode := '';
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 2 then begin
                            if Location.Get(SalesInvoice."Location Code") then
                                ShipFromPostalCode := Location."Post Code";
                        end else
                            currXMLport.Skip();
                    end;
                }
                textelement(ShipFromCity)
                {
                    trigger OnBeforePassVariable()
                    var
                        Location: Record Location;
                    begin
                        ShipFromCity := '';
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 2 then begin
                            if Location.Get(SalesInvoice."Location Code") then
                                ShipFromCity := Location.City;
                        end else
                            currXMLport.Skip();
                    end;
                }
                textelement(ShipFromCountry)
                {
                    trigger OnBeforePassVariable()
                    var
                        Location: Record Location;
                    begin
                        ShipFromCountry := '';
                        //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                        if IFSetup."Shipment Confirmation Version" > 2 then begin
                            if Location.Get(SalesInvoice."Location Code") then
                                ShipFromCountry := Location."Country/Region Code";
                        end else
                            currXMLport.Skip();
                    end;
                }
                //RHE-TNA 20-06-2022 BDS-6438 END
                //RHE-TNA 19-10-2020 BDS-4551 BEGIN
                textelement(ReferenceNumber)
                {
                    trigger OnBeforePassVariable()
                    var
                        IFRecordParam: Record "Interface Record Parameters";
                    begin
                        ReferenceNumber := '';
                        ReferenceNumber2 := '';
                        if IFSetup."Send Ship Ready Message" then begin
                            IFRecordParam.Reset();
                            IFRecordParam.SetRange("Source Type", IFRecordParam."Source Type"::Order);
                            IFRecordParam.SetRange("Source No.", SalesInvoice."Order No.");
                            if IFRecordParam.FindFirst() then begin
                                ReferenceNumber := IFRecordParam.Param4;
                                ReferenceNumber2 := IFRecordParam.Param1;
                            end;
                        end else
                            currXMLport.Skip();
                    end;
                }
                textelement(ReferenceNumber2)
                {
                    trigger OnBeforePassVariable()
                    begin
                        if not IFSetup."Send Ship Ready Message" then
                            currXMLport.Skip();
                    end;
                }
                //RHE-TNA 19-10-2020 BDS-4551 END
                //RHE-TNA 05-01-2021 BDS-4812 BEGIN
                textelement(Tags)
                {
                    trigger OnBeforePassVariable()
                    begin
                        if IFSetup."Send Ship Ready Message" then begin
                            if SalesInvoice."Work Description".HasValue then
                                Tags := SalesInvoice.GetWorkDescription();
                        end else
                            currXMLport.Skip();
                    end;
                }
                //RHE-TNA 05-01-2021 BDS-4812 END
                textelement(SalesInvoiceLines)
                {
                    tableelement(SalesInvoiceLine; "Sales Invoice Line")
                    {
                        LinkTable = SalesInvoice;
                        LinkFields = "Document No." = field ("No.");
                        SourceTableView = where (Quantity = filter (<> 0));

                        fieldelement(LineNumber; SalesInvoiceLine."Line No.")
                        {

                        }
                        //RHE-TNA 16-11-2021 BDS-5676 BEGIN
                        textelement(LineType)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                //RHE-TNA 14-04-2022 BDS-6269 BEGIN
                                //if IFSetup."Add Line Type" then
                                //IFSetup."Shipment Confirmation Version" version 0 from backend equals version 1.0 from frontend
                                if IFSetup."Shipment Confirmation Version" > 0 then
                                    //RHE-TNA 14-04-2022 BDS-6269 END
                                    LineType := Format(SalesInvoiceLine.Type)
                                else
                                    currXMLport.Skip();
                            end;
                        }
                        //RHE-TNA 16-11-2021 BDS-5676 END
                        fieldelement(ItemNo; SalesInvoiceLine."No.")
                        {

                        }
                        fieldelement(Description; SalesInvoiceLine.Description)
                        {

                        }
                        textelement(Quantity)
                        {
                            trigger OnBeforePassVariable()
                            var
                                QuantityText: Text[100];
                            begin
                                if DecimalSignIsComma then begin
                                    QuantityText := Format(SalesInvoiceLine.Quantity);
                                    IFSetup.SwitchPointComma(QuantityText);
                                    Quantity := QuantityText;
                                end else
                                    Quantity := Format(SalesInvoiceLine.Quantity);
                                if StrPos(Quantity, ',') > 0 then
                                    Quantity := DelChr(Quantity, '=', ',');
                            end;
                        }
                        textelement(UnitPrice)
                        {
                            trigger OnBeforePassVariable()
                            var
                                UnitPriceText: Text[100];
                            begin
                                if DecimalSignIsComma then begin
                                    UnitPriceText := Format(SalesInvoiceLine."Unit Price");
                                    IFSetup.SwitchPointComma(UnitPriceText);
                                    UnitPrice := UnitPriceText;
                                end else
                                    UnitPrice := Format(SalesInvoiceLine."Unit Price");
                                if StrPos(UnitPrice, ',') > 0 then
                                    UnitPrice := DelChr(UnitPrice, '=', ',');
                            end;
                        }
                        textelement(NetAmount)
                        {
                            trigger OnBeforePassVariable()
                            var
                                NetAmountText: Text[100];
                            begin
                                if DecimalSignIsComma then begin
                                    NetAmountText := Format(SalesInvoiceLine.Amount);
                                    IFSetup.SwitchPointComma(NetAmount);
                                    NetAmount := NetAmountText;
                                end else
                                    NetAmount := Format(SalesInvoiceLine.Amount);
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
                                VATAmount := Format(SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount);
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
                                    GrossAmountText := Format(SalesInvoiceLine."Amount Including VAT");
                                    IFSetup.SwitchPointComma(GrossAmount);
                                    GrossAmount := GrossAmountText;
                                end else
                                    GrossAmount := Format(SalesInvoiceLine."Amount Including VAT");
                                if StrPos(GrossAmount, ',') > 0 then
                                    GrossAmount := DelChr(GrossAmount, '=', ',');
                            end;
                        }
                        textelement(Component_Item)
                        {
                            trigger OnBeforePassVariable()
                            var
                                PostedATOLink: Record "Posted Assemble-to-Order Link";
                                PostedAssemblyLine: Record "Posted Assembly Line";
                                Component_QtyText: Text[100];
                            begin
                                //RHE-TNA 06-04-2020 BDS-4033 BEGIN
                                //if not IFSetup."Send SSCC info. with Invoice" then
                                if not Customer."Send SSCC info in EDI Invoice" then
                                    //RHE-TNA 06-04-2020 BDS-4033 END
                                    currXMLport.Skip()

                                else begin
                                    Component_Item := SalesInvoiceLine."No.";
                                    Component_Qty := Quantity;

                                    if SalesInvoice."Order No." <> '' then begin
                                        PostedATOLink.SetRange("Document Type", PostedATOLink."Document Type"::"Sales Shipment");
                                        PostedATOLink.SetRange("Document No.", SalesShipmentHdr."No.");
                                        PostedATOLink.SetRange("Order Line No.", SalesInvoiceLine."Line No.");
                                        if PostedATOLink.FindFirst() then begin
                                            PostedAssemblyLine.SetRange("Document No.", PostedATOLink."Assembly Document No.");
                                            PostedAssemblyLine.SetRange(Type, PostedAssemblyLine.Type::Item);
                                            if PostedAssemblyLine.FindFirst() then begin
                                                Component_Item := PostedAssemblyLine."No.";
                                                if DecimalSignIsComma then begin
                                                    Component_QtyText := Format(PostedAssemblyLine.Quantity);
                                                    IFSetup.SwitchPointComma(Component_QtyText);
                                                    Component_Qty := Component_QtyText;
                                                end else
                                                    Component_Qty := Format(PostedAssemblyLine.Quantity);
                                                if StrPos(Component_Qty, ',') > 0 then
                                                    Component_Qty := DelChr(Component_Qty, '=', ',');
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        }
                        textelement(Component_Qty)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                //RHE-TNA 06-04-2020 BDS-4033 BEGIN
                                //if not IFSetup."Send SSCC info. with Invoice" then
                                if not Customer."Send SSCC info in EDI Invoice" then
                                    //RHE-TNA 06-04-2020 BDS-4033 END
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(WMSOrderNumber)
                        {
                            trigger OnBeforePassVariable()
                            var
                                ValueEntry: Record "Value Entry";
                                ILE: Record "Item Ledger Entry";
                                PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
                            begin
                                WMSOrderNumber := '';
                                //RHE-TNA 06-04-2020 BDS-4033 BEGIN
                                //if not IFSetup."Send SSCC info. with Invoice" then
                                if not Customer."Send SSCC info in EDI Invoice" then
                                    //RHE-TNA 06-04-2020 BDS-4033 END
                                    currXMLport.Skip()
                                else begin
                                    ValueEntry.SetRange("Document No.", SalesInvoice."No.");
                                    ValueEntry.SetRange("Posting Date", SalesInvoice."Posting Date");
                                    ValueEntry.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
                                    ValueEntry.SetFilter("Item Ledger Entry No.", '<>%1', 0);
                                    if ValueEntry.FindFirst() then
                                        if ILE.Get(ValueEntry."Item Ledger Entry No.") then begin
                                            PostedWhseShipmentLine.SetRange("Posted Source Document", PostedWhseShipmentLine."Posted Source Document"::"Posted Shipment");
                                            PostedWhseShipmentLine.SetRange("Posted Source No.", ILE."Document No.");
                                            if PostedWhseShipmentLine.FindFirst() then
                                                WMSOrderNumber := PostedWhseShipmentLine."Whse. Shipment No.";
                                        end;
                                end;
                            end;
                        }
                        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                        textelement(SourceLineID)
                        {
                            trigger OnBeforePassVariable()
                            var
                                IFRecordParam: Record "Interface Record Parameters";
                            begin
                                SourceLineID := '';
                                IFRecordParam.Reset();
                                IFRecordParam.SetRange("Source Type", IFRecordParam."Source Type"::Order);
                                IFRecordParam.SetRange("Source No.", SalesInvoice."Order No.");
                                IFRecordParam.SetRange("Source Line No.", SalesInvoiceLine."Line No.");
                                if (IFRecordParam.FindFirst()) and (IFRecordParam."Source System Line ID" <> '') then
                                    SourceLineID := IFRecordParam."Source System Line ID"
                                else
                                    currXMLport.Skip();
                            end;
                        }
                        //RHE-TNA 14-06-2021 BDS-5337 END
                        //RHE-TNA 04-05-2022 BDS-6233 BEGIN
                        textelement(ShippingCost)
                        {
                            trigger OnBeforePassVariable()
                            var
                                Item: Record Item;
                            begin
                                //IFSetup."Order Version" version 0 from backend equals version 1 from frontend
                                if IFSetup."Shipment Confirmation Version" > 1 then begin
                                    if SalesInvoiceLine.Type = SalesInvoiceLine.Type::Item then begin
                                        Item.Get(SalesInvoiceLine."No.");
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
                        //RHE-TNA 04-05-2022 BDS-6233 END

                        tableelement(ItemTrackingLines; "Item Ledger Entry")
                        {
                            SourceTableView = where ("Item Tracking" = filter (<> None), "Entry Type" = const (Sale), "Document Type" = const ("Sales Shipment"));
                            MinOccurs = Zero;

                            textelement(TrackingQuantity)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    TrackingQuantityText: Text[100];
                                begin
                                    TrackingQuantity := Format(-ItemTrackingLines.Quantity);
                                    if DecimalSignIsComma then begin
                                        TrackingQuantityText := Format(TrackingQuantity);
                                        IFSetup.SwitchPointComma(TrackingQuantityText);
                                        TrackingQuantity := TrackingQuantityText;
                                        if StrPos(TrackingQuantity, ',') > 0 then
                                            TrackingQuantity := DelChr(TrackingQuantity, '=', ',');
                                    end;
                                end;
                            }
                            fieldelement(SerialNumber; ItemTrackingLines."Serial No.")
                            {

                            }
                            fieldelement(LotNumber; ItemTrackingLines."Lot No.")
                            {

                            }
                            textelement(ExpiryDate)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    ExpiryDate := FORMAT(ItemTrackingLines."Expiration Date", 0, '<Year4>-<Month,2>-<Day,2>');
                                end;
                            }
                            trigger OnPreXmlItem()
                            begin
                                ItemTrackingLines.SetRange("Document No.", SalesShipmentHdr."No.");
                                ItemTrackingLines.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
                            end;
                        }
                        //RHE-TNA 21-06-2022 BDS-6440 BEGIN
                        textelement(Components)
                        {
                            MinOccurs = Zero;

                            tableelement(Component; "Posted Assembly Line")
                            {
                                MinOccurs = Zero;

                                textelement(ComponentItemNo)
                                {
                                    MinOccurs = Zero;
                                    trigger OnBeforePassVariable()
                                    begin
                                        ComponentItemNo := '';
                                        if IFSetup."Shipment Confirmation Version" > 3 then begin
                                            ComponentItemNo := Component."No.";
                                        end else
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(ComponentQuantity)
                                {
                                    trigger OnBeforePassVariable()
                                    var
                                        QuantityText: Text[100];
                                    begin
                                        ComponentQuantity := '';
                                        if IFSetup."Shipment Confirmation Version" > 3 then begin
                                            ComponentQuantity := Format(Component.Quantity);
                                            if DecimalSignIsComma then begin
                                                QuantityText := Format(ComponentQuantity);
                                                IFSetup.SwitchPointComma(QuantityText);
                                                ComponentQuantity := QuantityText;
                                                if StrPos(ComponentQuantity, ',') > 0 then
                                                    ComponentQuantity := DelChr(ComponentQuantity, '=', ',');
                                            end;
                                        end else
                                            currXMLport.Skip();
                                    end;
                                }
                                tableelement(ComponentItemTrackingLines; "Item Ledger Entry")
                                {
                                    SourceTableView = where ("Item Tracking" = filter (<> None), "Entry Type" = const ("Assembly Consumption"), "Document Type" = const ("Posted Assembly"));
                                    MinOccurs = Zero;

                                    textelement(ComponentTrackingQuantity)
                                    {
                                        trigger OnBeforePassVariable()
                                        var
                                            TrackingQuantityText: Text[100];
                                        begin
                                            ComponentTrackingQuantity := '';
                                            if IFSetup."Shipment Confirmation Version" > 3 then begin
                                                ComponentTrackingQuantity := Format(-ComponentItemTrackingLines.Quantity);
                                                if DecimalSignIsComma then begin
                                                    TrackingQuantityText := Format(ComponentTrackingQuantity);
                                                    IFSetup.SwitchPointComma(TrackingQuantityText);
                                                    ComponentTrackingQuantity := TrackingQuantityText;
                                                    if StrPos(ComponentTrackingQuantity, ',') > 0 then
                                                        ComponentTrackingQuantity := DelChr(ComponentTrackingQuantity, '=', ',');
                                                end;
                                            end else
                                                currXMLport.Skip();
                                        end;
                                    }
                                    textelement(ComponentSerialNumber)
                                    {
                                        trigger OnBeforePassVariable()
                                        var
                                            TrackingQuantityText: Text[100];
                                        begin
                                            ComponentSerialNumber := '';
                                            if IFSetup."Shipment Confirmation Version" > 3 then
                                                ComponentSerialNumber := ComponentItemTrackingLines."Serial No."
                                            else
                                                currXMLport.Skip();
                                        end;
                                    }
                                    textelement(ComponentLotNumber)
                                    {
                                        trigger OnBeforePassVariable()
                                        var
                                            TrackingQuantityText: Text[100];
                                        begin
                                            ComponentLotNumber := '';
                                            if IFSetup."Shipment Confirmation Version" > 3 then
                                                ComponentLotNumber := ComponentItemTrackingLines."Lot No."
                                            else
                                                currXMLport.Skip();
                                        end;
                                    }
                                    textelement(ComponentExpiryDate)
                                    {
                                        trigger OnBeforePassVariable()
                                        begin
                                            ComponentExpiryDate := '';
                                            if IFSetup."Shipment Confirmation Version" > 3 then
                                                ComponentExpiryDate := FORMAT(ComponentItemTrackingLines."Expiration Date", 0, '<Year4>-<Month,2>-<Day,2>')
                                            else
                                                currXMLport.Skip();
                                        end;
                                    }
                                    trigger OnPreXmlItem()
                                    begin
                                        ComponentItemTrackingLines.SetRange("Document No.", Component."Document No.");
                                        ComponentItemTrackingLines.SetRange("Document Line No.", Component."Line No.");
                                    end;
                                }

                                trigger OnPreXmlItem()
                                var
                                    ValueEntry: Record "Value Entry";
                                    ILE: Record "Item Ledger Entry";
                                    SalesShipmentHdr: Record "Sales Shipment Header";
                                    PostedATOLink: Record "Posted Assemble-to-Order Link";
                                begin
                                    if IFSetup."Shipment Confirmation Version" > 3 then begin
                                        //Determine posted assembly order lines via Sales Shipment table
                                        ValueEntry.SetRange("Document No.", SalesInvoice."No.");
                                        ValueEntry.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
                                        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                                        ValueEntry.SetRange("Posting Date", SalesInvoice."Posting Date");
                                        if (ValueEntry.FindFirst()) and (ValueEntry."Item Ledger Entry No." <> 0) then begin
                                            if ILE.Get(ValueEntry."Item Ledger Entry No.") then begin
                                                if ILE."Document Type" = ILE."Document Type"::"Sales Shipment" then begin
                                                    PostedATOLink.SetRange("Assembly Document Type", PostedATOLink."Assembly Document Type"::Assembly);
                                                    PostedATOLink.SetRange("Document Type", PostedATOLink."Document Type"::"Sales Shipment");
                                                    PostedATOLink.SetRange("Document No.", ILE."Document No.");
                                                    PostedATOLink.SetRange("Document Line No.", ILE."Document Line No.");
                                                    if PostedATOLink.FindFirst() then
                                                        Component.SetRange("Document No.", PostedATOLink."Assembly Document No.")
                                                    else
                                                        //Set a filter to make sure no lines are found
                                                        Component.SetRange("Document No.", 'ZZ');
                                                end else
                                                    //Set a filter to make sure no lines are found
                                                    Component.SetRange("Document No.", 'ZZ');
                                            end else
                                                //Set a filter to make sure no lines are found
                                                Component.SetRange("Document No.", 'ZZ');
                                        end else
                                            //Set a filter to make sure no lines are found
                                            Component.SetRange("Document No.", 'ZZ');
                                    end else
                                        //Set a filter to make sure no lines are found
                                        Component.SetRange("Document No.", 'ZZ');
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if IFSetup."Shipment Confirmation Version" < 4 then begin
                                    currXMLport.Skip();
                                end;
                            end;
                        }
                        //RHE-TNA 21-06-2022 BDS-6440 END

                        trigger OnAfterGetRecord()
                        var
                            ValueEntry: Record "Value Entry";
                            ILE: Record "Item Ledger Entry";
                            Item: Record Item;
                        begin
                            ValueEntry.SetRange("Document No.", SalesInvoice."No.");
                            ValueEntry.SetRange("Posting Date", SalesInvoice."Posting Date");
                            ValueEntry.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
                            ValueEntry.SetFilter("Item Ledger Entry No.", '<>%1', 0);
                            if ValueEntry.FindFirst() then
                                if ILE.Get(ValueEntry."Item Ledger Entry No.") then
                                    if not SalesShipmentHdr.Get(ILE."Document No.") then
                                        SalesShipmentHdr.Init();

                            //RHE-TNA 08-06-2022 BDS-6378 BEGIN
                            if SalesInvoiceLine.Type = SalesInvoiceLine.Type::Item then begin
                                Item.Get(SalesInvoiceLine."No.");
                                if (Item.ExclItemEDI) and (SalesInvoiceLine."Line Amount" = 0) then
                                    currXMLport.Skip();
                            end;
                            //RHE-TNA 08-06-2022 BDS-6378 END
                        end;
                    }
                }
                //RHE-TNA 06-04-2020 BDS-4033 BEGIN
                trigger OnAfterGetRecord()
                begin
                    Customer.Get(SalesInvoice."Sell-to Customer No.");
                    //RHE-TNA 29-03-2022 BDS-5337 BEGIN
                    IFSetup.Get(IFSetup.GetIFSetupRecforDocNo(SalesInvoice."Order No."));
                    //RHE-TNA 29-03-2022 BDS-5337 END
                end;
                //RHE-TNA 06-04-2020 BDS-4033 END
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        GLSetup.Get();
        //RHE-TNA 23-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();        
        //RHE-TNA 23-06-2021 BDS-5337 END
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        GLSetup: Record "General Ledger Setup";
        SalesShipmentHdr: Record "Sales Shipment Header";
        DecimalSignIsComma: Boolean;
        Customer: Record Customer;
}