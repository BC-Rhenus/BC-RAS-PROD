xmlport 50018 "Export 3PL Shipment"

//  RHE-TNA 03-02-2022 BDS-5971
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
            tableelement(DataHeader; "Warehouse Shipment Header")
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
                fieldelement(ShipmentNo; DataHeader."No.")
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
                        if Source_Doc = Source_Doc::P_Order then
                            Return := 'Y'
                    end;
                }
                textelement(ReceiverOrderReference)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ReceiverOrderReference := Sales_Hdr."External Document No.";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ReceiverOrderReference := Transfer_Hdr."External Document No.";
                                end;
                        end;
                    end;
                }
                textelement(ReceiverOrderReference2)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ReceiverOrderReference2 := Sales_Hdr."Your Reference";
                                end;
                        end;
                    end;
                }
                textelement(SellToCustomerNo)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SellToCustomerNo := Sales_Hdr."Sell-to Customer No.";
                                end;
                        end;
                    end;
                }
                textelement(SellToName)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SellToName := Sales_Hdr."Sell-to Customer Name";
                                end;
                        end;
                    end;
                }
                textelement(SellToAddress1)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SellToAddress1 := Sales_Hdr."Sell-to Address";
                                end;
                        end;
                    end;
                }
                textelement(SellToAddress2)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SellToAddress2 := Sales_Hdr."Sell-to Address 2";
                                end;
                        end;
                    end;
                }
                textelement(SellToPostcode)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SellToPostcode := Sales_Hdr."Sell-to Post Code";
                                end;
                        end;
                    end;
                }
                textelement(SellToCity)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SellToCity := Sales_Hdr."Sell-to City";
                                end;
                        end;
                    end;
                }
                textelement(SellToCounty)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SellToCounty := Sales_Hdr."Sell-to County";
                                end;
                        end;
                    end;
                }
                textelement(SellToCountry)
                {
                    trigger OnBeforePassVariable()

                    begin
                        SellToCountry := '';
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    if (Reccountry.Get(Sales_Hdr."Sell-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                        SellToCountry := RecCountry."ISO3 Code";
                                end;
                        end;
                    end;
                }
                textelement(VATNumber)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    VATNumber := Sales_Hdr."VAT Registration No.";
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
                textelement(ShipToName)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipToName := Sales_Hdr."Ship-to Name";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipToName := Purch_Hdr."Ship-to Name";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipToName := Transfer_Hdr."Transfer-to Name";
                                end;
                        end;
                    end;
                }
                textelement(ShipToAddress1)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipToAddress1 := Sales_Hdr."Ship-to Address";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipToAddress1 := Purch_Hdr."Ship-to Address";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipToAddress1 := Transfer_Hdr."Transfer-to Address";
                                end;
                        end;
                    end;
                }
                textelement(ShipToAddress2)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipToAddress2 := Sales_Hdr."Ship-to Address 2";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipToAddress2 := Purch_Hdr."Ship-to Address 2";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipToAddress2 := Transfer_Hdr."Transfer-to Address 2";
                                end;
                        end;
                    end;
                }
                textelement(ShipToPostcode)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SellToPostcode := Sales_Hdr."Ship-to Post Code";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipToPostcode := Purch_Hdr."Ship-to Post Code";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipToPostcode := Transfer_Hdr."Transfer-to Post Code";
                                end;
                        end;
                    end;
                }
                textelement(ShipToCity)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipToCity := Sales_Hdr."Ship-to City";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipToCity := Purch_Hdr."Ship-to City";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipToCity := Transfer_Hdr."Transfer-to City";
                                end;
                        end;
                    end;
                }
                textelement(ShipToCounty)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    ShipToCounty := Sales_Hdr."Ship-to County";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    ShipToCounty := Purch_Hdr."Ship-to County";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    ShipToCounty := Transfer_Hdr."Transfer-to County";
                                end;
                        end;
                    end;
                }
                textelement(ShipToCountry)
                {
                    trigger OnBeforePassVariable()

                    begin
                        ShipToCountry := '';
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    if (Reccountry.Get(Sales_Hdr."Ship-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                        ShipToCountry := RecCountry."ISO3 Code";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    if (RecCountry.Get(Purch_Hdr."Ship-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                        ShipToCountry := RecCountry."ISO3 Code";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    if (RecCountry.Get(Transfer_Hdr."Trsf.-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                        ShipToCountry := RecCountry."ISO3 Code";
                                end;
                        end;
                    end;
                }
                textelement(InvoiceToCustomerNo)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    InvoiceToCustomerNo := Sales_Hdr."Bill-to Customer No.";
                                end;
                        end;
                    end;
                }
                textelement(InvoiceToName)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    InvoiceToName := Sales_Hdr."Bill-to Name";
                                end;
                        end;
                    end;
                }
                textelement(InvoiceToAddress1)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    InvoiceToAddress1 := Sales_Hdr."Bill-to Address";
                                end;
                        end;
                    end;
                }
                textelement(InvoiceToAddress2)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    InvoiceToAddress2 := Sales_Hdr."Bill-to Address 2";
                                end;
                        end;
                    end;
                }
                textelement(InvoiceToPostcode)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    InvoiceToPostcode := Sales_Hdr."Bill-to Post Code";
                                end;
                        end;
                    end;
                }
                Textelement(InvoiceToCity)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    InvoiceToCity := Sales_Hdr."Bill-to City";
                                end;
                        end;
                    end;
                }
                textelement(InvoiceToCounty)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    InvoiceToCounty := Sales_Hdr."Bill-to County";
                                end;
                        end;
                    end;
                }
                textelement(InvoiceToCountry)
                {
                    trigger OnBeforePassVariable()
                    begin
                        InvoiceToCountry := '';
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    if (RecCountry.Get(Sales_Hdr."Bill-to Country/Region Code")) and (RecCountry."ISO3 Code" <> '') then
                                        InvoiceToCountry := RecCountry."ISO3 Code";
                                end;
                        end;
                    end;
                }
                textelement(InvoiceToContact)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    InvoiceToContact := Sales_Hdr."Bill-to Contact";
                                end;
                        end;
                    end;
                }
                textelement(OrderDate)
                {
                    trigger OnBeforePassVariable()
                    var
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    OrderDate := Format(Sales_Hdr."Order Date", 0, '<Year4>-<Month,2>-<Day,2>');
                                end;
                            Source_Doc::P_Order:
                                begin
                                    OrderDate := Format(Purch_Hdr."Order Date", 0, '<Year4>-<Month,2>-<Day,2>');
                                end;
                            Source_Doc::T_Order:
                                begin
                                    OrderDate := Format(Transfer_Hdr."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>');
                                end;
                        end;
                    end;
                }

                textelement(RequestedDeliveryDate)
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
                                    RequestedDeliveryDate := Format(Sales_Hdr."Requested Delivery Date", 0, '<Year4>-<Month,2>-<Day,2>');
                                end;
                        end;
                    end;
                }
                textelement(CustomerComment)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    CustomerComment := Sales_Hdr."Customer Comment Text";
                                end;
                        end;
                    end;
                }
                textelement(Currency)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    Currency := Sales_Hdr."Currency Code";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    Currency := Purch_Hdr."Currency Code";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    Currency := Transfer_Hdr."Currency Code";
                                end;
                        end;
                        if Currency = '' then
                            Currency := GLSetup."LCY Code";
                    end;
                }
                textelement(InvoiceAmountInclVAT)
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
                                    until SalesLine.Next() = 0;
                                    if Sales_Hdr."Currency Code" = '' then begin
                                        Amount1 := Round(Amount1, GLSetup."Amount Rounding Precision");
                                        Amount2 := Round(Amount2, GLSetup."Amount Rounding Precision");
                                    end else begin
                                        Currency.Get(Sales_Hdr."Currency Code");
                                        Amount1 := Round(Amount1, Currency."Amount Rounding Precision");
                                        Amount2 := Round(Amount2, Currency."Amount Rounding Precision");
                                    end;
                                    InvoiceAmountInclVAT := Format(Amount1);
                                    InvoiceAmountExclVAT := Format(Amount2);
                                end;
                            Source_Doc::P_Order:
                                begin
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
                                    InvoiceAmountInclVAT := Format(Amount1);
                                    InvoiceAmountExclVAT := Format(Amount2);
                                end;
                            Source_Doc::T_Order:
                                begin
                                    Amount1 := 0;
                                    TransferLine.SetRange("Document No.", Transfer_Hdr."No.");
                                    if TransferLine.FindSet() then
                                        repeat
                                            if TransferLine."Line Amount" <> 0 then
                                                Amount1 += TransferLine."Line Amount"
                                            else
                                                if not Country.IsEUCountry(Transfer_Hdr."Trsf.-to Country/Region Code") then begin
                                                    item.Get(TransferLine."Item No.");
                                                    Amount1 += Item."Unit Cost" * TransferLine.Quantity;
                                                end;
                                        until TransferLine.Next() = 0;
                                    Amount1 := Round(Amount1, GLSetup."Amount Rounding Precision");
                                    InvoiceAmountInclVAT := Format(Amount1);
                                    InvoiceAmountExclVAT := Format(Amount1);
                                end;
                        end;
                        VATAmount := Format(Amount1 - Amount2);
                        if not DecimalSignIsComma then begin
                            if StrPos(InvoiceAmountInclVAT, ',') <> 0 then
                                InvoiceAmountInclVAT := DelChr(InvoiceAmountInclVAT, '=', ',');
                        end else begin
                            if StrPos(InvoiceAmountInclVAT, ',') <> 0 then
                                InvoiceAmountInclVAT := ConvertStr(InvoiceAmountInclVAT, ',', '.');
                        end;
                    end;
                }
                textelement(InvoiceAmountExclVAT)
                {
                    trigger OnBeforePassVariable()
                    begin
                        if not DecimalSignIsComma then begin
                            if StrPos(InvoiceAmountExclVAT, ',') <> 0 then
                                InvoiceAmountExclVAT := DelChr(InvoiceAmountExclVAT, '=', ',');
                        end else begin
                            if StrPos(InvoiceAmountExclVAT, ',') <> 0 then
                                InvoiceAmountExclVAT := ConvertStr(InvoiceAmountExclVAT, ',', '.');
                        end;
                    end;
                }
                textelement(VATAmount)
                {
                    trigger OnBeforePassVariable()
                    begin
                        if not DecimalSignIsComma then begin
                            if StrPos(VATAmount, ',') <> 0 then
                                VATAmount := DelChr(VATAmount, '=', ',');
                        end else begin
                            if StrPos(VATAmount, ',') <> 0 then
                                VATAmount := ConvertStr(VATAmount, ',', '.');
                        end;
                    end;
                }
                textelement(SalesPersonName)
                {
                    trigger OnBeforePassVariable()
                    var
                        SalesPerson: Record "Salesperson/Purchaser";
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    SalesPersonName := '';
                                    if SalesPerson.Get(Sales_Hdr."Salesperson Code") then
                                        SalesPersonName := SalesPerson.Name;
                                end;
                        end;
                    end;
                }
                textelement(PaymentTerms)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    PaymentTerms := Sales_Hdr."Payment Terms Code";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    PaymentTerms := Purch_Hdr."Payment Terms Code";
                                end;
                        end;
                    end;
                }
                textelement(PaymentDiscountPerc)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    PaymentDiscountPerc := Format(Sales_Hdr."Payment Discount %");
                                end;
                            Source_Doc::P_Order:
                                begin
                                    PaymentDiscountPerc := Format(Purch_Hdr."Payment Discount %");
                                end;
                        end;
                        if not DecimalSignIsComma then begin
                            if StrPos(PaymentDiscountPerc, ',') <> 0 then
                                PaymentDiscountPerc := DelChr(PaymentDiscountPerc, '=', ',');
                        end else begin
                            if StrPos(PaymentDiscountPerc, ',') <> 0 then
                                PaymentDiscountPerc := ConvertStr(PaymentDiscountPerc, ',', '.');
                        end;
                    end;
                }
                textelement(TOD)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    TOD := Sales_Hdr."Shipment Method Code";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    TOD := Purch_Hdr."Shipment Method Code";
                                end;
                            Source_Doc::T_Order:
                                begin
                                    TOD := Transfer_Hdr."Shipment Method Code";
                                end;
                        end;
                    end;
                }
                textelement(Carrier)
                {
                    trigger OnBeforePassVariable()
                    var
                        ShippingAgentService: Record "Shipping Agent Services";
                    begin
                        Carrier := '';
                        ServiceLevel := '';
                        CarrierService := '';
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    if ShippingAgentService.Get(Sales_Hdr."Shipping Agent Code", Sales_Hdr."Shipping Agent Service Code") then begin
                                        Carrier := ShippingAgentService."WMS Carrier";
                                        ServiceLevel := ShippingAgentService."WMS Service Level";
                                        CarrierService := ShippingAgentService."WMS Dispatch Method";
                                    end;
                                end;
                            Source_Doc::T_Order:
                                begin
                                    if ShippingAgentService.Get(Transfer_Hdr."Shipping Agent Code", Transfer_Hdr."Shipping Agent Service Code") then begin
                                        Carrier := ShippingAgentService."WMS Carrier";
                                        ServiceLevel := ShippingAgentService."WMS Service Level";
                                        CarrierService := ShippingAgentService."WMS Dispatch Method";
                                    end;
                                end;
                        end;
                    end;
                }
                textelement(ServiceLevel)
                {

                }
                textelement(CarrierService)
                {

                }
                textelement(FreightCharges)
                {
                    trigger OnBeforePassVariable()
                    var
                        Customer: Record Customer;
                    begin
                        if Source_Doc = Source_Doc::S_Order then begin
                            if (Customer.Get(Sales_Hdr."Sell-to Customer No.")) and (Customer."WMS Freight Charges" <> Customer."WMS Freight Charges"::" ") then
                                FreightCharges := Format(Customer."WMS Freight Charges");
                        end;
                    end;
                }
                textelement(FreightChargesVATNumber)
                {
                    trigger OnBeforePassVariable()
                    var
                        Customer: Record Customer;
                    begin
                        if Source_Doc = Source_Doc::S_Order then begin
                            if (Customer.Get(Sales_Hdr."Sell-to Customer No.")) and (Customer."WMS Freight Charges" <> Customer."WMS Freight Charges"::" ") then
                                FreightChargesVATNumber := Format(Customer."WMS Hub Vat Number");
                        end;
                    end;
                }
                textelement(LanguageCode)
                {
                    trigger OnBeforePassVariable()
                    begin
                        case Source_Doc of
                            Source_Doc::S_Order:
                                begin
                                    LanguageCode := Sales_Hdr."Language Code";
                                end;
                            Source_Doc::P_Order:
                                begin
                                    LanguageCode := Purch_Hdr."Language Code";
                                end;
                        end;
                    end;
                }
                textelement(DataLines)
                {
                    tableelement(DataLine; "Warehouse Shipment Line")
                    {
                        fieldelement(LineNo; DataLine."Line No.")
                        {

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
                        textelement(HSCode)
                        {
                            trigger OnBeforePassVariable()
                            var
                                SalesLine: Record "Sales Line";
                                PurchReturnLine: Record "Purchase Line";
                                TransferLine: Record "Transfer Line";
                                Item: Record Item;
                            begin
                                HSCode := '';
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            SalesLine.Get(SalesLine."Document Type"::Order, DataLine."Source No.", DataLine."Source Line No.");
                                            Item.Get(SalesLine."No.");
                                            HSCode := Item."Tariff No.";
                                        end;
                                    Source_Doc::P_Order:
                                        begin
                                            PurchReturnLine.Get(PurchReturnLine."Document Type"::"Return Order", DataLine."Source No.", DataLine."Source Line No.");
                                            Item.Get(PurchReturnLine."No.");
                                            HSCode := Item."Tariff No.";
                                        end;
                                    Source_Doc::T_Order:
                                        begin
                                            TransferLine.Get(DataLine."Source No.", DataLine."Source Line No.");
                                            Item.Get(TransferLine."Item No.");
                                            HSCode := Item."Tariff No.";
                                        end;
                                end;
                            end;
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
                        textelement(ParentItemNo)
                        {
                            trigger OnBeforePassVariable()
                            var
                                SalesLine: Record "Sales Line";
                            begin
                                ParentItemNo := '';
                                //In case of sales orders the shipment line can contain the Assembly component item, therefore get the sales order item no.
                                if (DataLine."Assemble to Order" = true) and (DataLine."Source Document" = DataLine."Source Document"::"Sales Order") then begin
                                    SalesLine.Get(SalesLine."Document Type"::Order, DataLine."Source No.", DataLine."Source Line No.");
                                    ParentItemNo := SalesLine."No.";
                                end;
                            end;
                        }
                        textelement(ParentDescription)
                        {
                            trigger OnBeforePassVariable()
                            var
                                SalesLine: Record "Sales Line";
                            begin
                                ParentDescription := '';
                                if (DataLine."Assemble to Order" = true) and (DataLine."Source Document" = DataLine."Source Document"::"Sales Order") then begin
                                    SalesLine.Get(SalesLine."Document Type"::Order, DataLine."Source No.", DataLine."Source Line No.");
                                    ParentDescription := SalesLine.Description;
                                end;
                            end;
                        }
                        textelement(ParentQuantity)
                        {
                            trigger OnBeforePassVariable()
                            var
                                SalesLine: Record "Sales Line";
                            begin
                                ParentQuantity := '';
                                if (DataLine."Assemble to Order" = true) and (DataLine."Source Document" = DataLine."Source Document"::"Sales Order") then begin
                                    SalesLine.Get(SalesLine."Document Type"::Order, DataLine."Source No.", DataLine."Source Line No.");
                                    ParentQuantity := Format(SalesLine.Quantity);
                                    if not DecimalSignIsComma then begin
                                        if StrPos(ParentQuantity, ',') <> 0 then
                                            ParentQuantity := DelChr(ParentQuantity, '=', ',');
                                    end else begin
                                        if StrPos(ParentQuantity, ',') <> 0 then
                                            ParentQuantity := ConvertStr(ParentQuantity, ',', '.');
                                    end;
                                end;
                            end;
                        }
                        textelement(ParentHSCode)
                        {
                            trigger OnBeforePassVariable()
                            var
                                ATOLink: Record "Assemble-to-Order Link";
                                SalesLine: Record "Sales Line";
                                Item: Record Item;
                            begin
                                ParentHSCode := '';
                                if (DataLine."Assemble to Order" = true) and (DataLine."Source Document" = DataLine."Source Document"::"Sales Order") then begin
                                    SalesLine.Get(SalesLine."Document Type"::Order, DataLine."Source No.", DataLine."Source Line No.");
                                    Item.Get(SalesLine."No.");
                                    ParentHSCode := Item."Tariff No.";
                                end;
                            end;
                        }
                        textelement(UnitPrice)
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
                                UnitPrice := '';

                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            SalesLine.Get(SalesLine."Document Type"::Order, DataLine."Source No.", DataLine."Source Line No.");
                                            SalesHdr.Get(SalesHdr."Document Type"::Order, DataLine."Source No.");
                                            if SalesHdr."Prices Including VAT" then
                                                UnitPrice := Format(Round(SalesLine."Unit Price" / (100 + SalesLine."VAT %") * 100))
                                            else
                                                UnitPrice := Format(SalesLine."Unit Price");
                                            //Always send a product price for export orders
                                            if (SalesLine."Unit Price" = 0) and (not Country.IsEUCountry(SalesHdr."Ship-to Country/Region Code")) then begin
                                                Item.Get(DataLine."Item No.");
                                                UnitPrice := Format(Item."Unit Cost");
                                            end;
                                        end;
                                    Source_Doc::P_Order:
                                        begin
                                            PurchReturnLine.Get(PurchReturnLine."Document Type"::"Return Order", DataLine."Source No.", DataLine."Source Line No.");
                                            UnitPrice := Format(PurchReturnLine."Direct Unit Cost");
                                            //Always send a product price for export orders
                                            PurchHdr.Get(PurchHdr."Document Type"::"Return Order", DataLine."Source No.");
                                            if (PurchReturnLine."Direct Unit Cost" = 0) and (not Country.IsEUCountry(PurchHdr."Ship-to Country/Region Code")) then begin
                                                Item.Get(DataLine."Item No.");
                                                UnitPrice := Format(Item."Unit Cost");
                                            end;
                                        end;
                                    Source_Doc::T_Order:
                                        begin
                                            TransferLine.Get(DataLine."Source No.", DataLine."Source Line No.");
                                            UnitPrice := Format(TransferLine."Unit Price");
                                            //Always send a product price for export orders
                                            TransferHdr.Get(DataLine."Source No.");
                                            if (TransferLine."Unit Price" = 0) and (not Country.IsEUCountry(TransferHdr."Trsf.-to Country/Region Code")) then begin
                                                Item.Get(DataLine."Item No.");
                                                UnitPrice := Format(Item."Unit Cost");
                                            end;
                                        end;
                                end;
                                if not DecimalSignIsComma then begin
                                    if StrPos(UnitPrice, ',') <> 0 then
                                        UnitPrice := DelChr(UnitPrice, '=', ',');
                                end else begin
                                    if StrPos(UnitPrice, ',') <> 0 then
                                        UnitPrice := ConvertStr(UnitPrice, ',', '.');
                                end;
                            end;
                        }
                        textelement(LineAmount)
                        {
                            trigger OnBeforePassVariable()
                            var
                                SalesLine: Record "Sales Line";
                                PurchReturnLine: Record "Purchase Line";
                                Country: Record "Country/Region";
                                Item: Record Item;
                                Currency: Record Currency;
                                TransferLine: Record "Transfer Line";
                            begin
                                LineAmount := '';
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            SalesLine.Get(SalesLine."Document Type"::Order, DataLine."Source No.", DataLine."Source Line No.");
                                            LineAmount := Format(SalesLine."Line Amount");
                                            if (SalesLine."Line Amount" = 0) and (not Country.IsEUCountry(Sales_Hdr."Ship-to Country/Region Code")) then begin
                                                Item.Get(DataLine."Item No.");
                                                if Sales_Hdr."Currency Code" = '' then
                                                    LineAmount := Format(Round((Item."Unit Cost" * SalesLine.Quantity), GLSetup."Amount Rounding Precision"))
                                                else begin
                                                    Currency.Get(Sales_Hdr."Currency Code");
                                                    LineAmount := Format(Round((Item."Unit Cost" * SalesLine.Quantity), Currency."Amount Rounding Precision"));
                                                end;
                                            end;
                                        end;
                                    Source_Doc::P_Order:
                                        begin
                                            PurchReturnLine.Get(PurchReturnLine."Document Type"::"Return Order", DataLine."Source No.", DataLine."Source Line No.");
                                            LineAmount := Format(PurchReturnLine."Line Amount");
                                            if (PurchReturnLine."Line Amount" = 0) and (not Country.IsEUCountry(Purch_Hdr."Ship-to Country/Region Code")) then begin
                                                Item.Get(DataLine."Item No.");
                                                if Purch_Hdr."Currency Code" = '' then
                                                    LineAmount := Format(Round((Item."Unit Cost" * PurchReturnLine.Quantity), GLSetup."Amount Rounding Precision"))
                                                else begin
                                                    Currency.Get(Sales_Hdr."Currency Code");
                                                    LineAmount := Format(Round((Item."Unit Cost" * PurchReturnLine.Quantity), Currency."Amount Rounding Precision"));
                                                end;
                                            end;
                                        end;
                                    Source_Doc::T_Order:
                                        begin
                                            TransferLine.Get(DataLine."Source No.", DataLine."Source Line No.");
                                            LineAmount := Format(TransferLine."Line Amount");
                                            if (TransferLine."Line Amount" = 0) and (not Country.IsEUCountry(Transfer_Hdr."Trsf.-to Country/Region Code")) then begin
                                                Item.Get(DataLine."Item No.");
                                                LineAmount := Format(Round((Item."Unit Cost" * TransferLine.Quantity), GLSetup."Amount Rounding Precision"));
                                            end;
                                        end;
                                end;
                                if not DecimalSignIsComma then begin
                                    if StrPos(LineAmount, ',') <> 0 then
                                        LineAmount := DelChr(LineAmount, '=', ',');
                                end else begin
                                    if StrPos(LineAmount, ',') <> 0 then
                                        LineAmount := ConvertStr(LineAmount, ',', '.');
                                end;
                            end;
                        }
                        textelement(LineAmountInclVAT)
                        {
                            trigger OnBeforePassVariable()
                            var
                                SalesLine: Record "Sales Line";
                                PurchReturnLine: Record "Purchase Line";
                                Country: Record "Country/Region";
                                Currency: Record Currency;
                                Item: Record Item;
                                TransferLine: Record "Transfer Line";
                            begin
                                LineAmountInclVAT := '';
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            SalesLine.Get(SalesLine."Document Type"::Order, DataLine."Source No.", DataLine."Source Line No.");
                                            LineAmountInclVAT := Format(SalesLine."Amount Including VAT");
                                            if (SalesLine."Amount Including VAT" = 0) and (not Country.IsEUCountry(Sales_Hdr."Ship-to Country/Region Code")) then begin
                                                if SalesLine."Customs Price" > 0 then
                                                    LineAmountInclVAT := Format(Round((SalesLine.Quantity * SalesLine."Customs Price") * ((100 + SalesLine."VAT %") / 100), GLSetup."Amount Rounding Precision"))
                                                else
                                                    LineAmountInclVAT := Format(Round((SalesLine."Unit Cost" * SalesLine.Quantity) * ((100 + SalesLine."VAT %") / 100), GLSetup."Amount Rounding Precision"));
                                            end;
                                        end;
                                    Source_Doc::P_Order:
                                        begin
                                            PurchReturnLine.Get(PurchReturnLine."Document Type"::"Return Order", DataLine."Source No.", DataLine."Source Line No.");
                                            LineAmountInclVAT := Format(PurchReturnLine."Amount Including VAT");
                                            if (PurchReturnLine."Amount Including VAT" = 0) and (not Country.IsEUCountry(Purch_Hdr."Ship-to Country/Region Code")) then
                                                LineAmountInclVAT := Format(Round((PurchReturnLine."Unit Cost" * PurchReturnLine.Quantity) * ((100 + PurchReturnLine."VAT %") / 100), GLSetup."Amount Rounding Precision"));
                                        end;
                                    Source_Doc::T_Order:
                                        begin
                                            LineAmountInclVAT := '0.00';
                                        end;
                                end;
                                if not DecimalSignIsComma then begin
                                    if StrPos(LineAmountInclVAT, ',') <> 0 then
                                        LineAmountInclVAT := DelChr(LineAmountInclVAT, '=', ',');
                                end else begin
                                    if StrPos(LineAmountInclVAT, ',') <> 0 then
                                        LineAmountInclVAT := ConvertStr(LineAmountInclVAT, ',', '.');
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

                        textelement(AdditionalItemReference)
                        {
                            trigger OnBeforePassVariable()
                            var
                                SalesLine: Record "Sales Line";
                            begin
                                AdditionalItemReference := '';
                                case Source_Doc of
                                    Source_Doc::S_Order:
                                        begin
                                            SalesLine.Get(SalesLine."Document Type"::Order, DataLine."Source No.", DataLine."Source Line No.");
                                            AdditionalItemReference := SalesLine."Cross-Reference No.";
                                        end;
                                end;
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

                                trigger OnPreXmlItem()
                                var
                                    ATOLink: Record "Assemble-to-Order Link";
                                begin
                                    ItemTrackingLine.Reset();
                                    if (DataLine."Assemble to Order" = true) and (DataLine."Source Document" = DataLine."Source Document"::"Sales Order") then begin
                                        ATOLink.SetRange(Type, ATOLink.Type::Sale);
                                        ATOLink.SetRange("Assembly Document Type", ATOLink."Assembly Document Type"::Order);
                                        ATOLink.SetRange("Document Type", ATOLink."Document Type"::Order);
                                        ATOLink.SetRange("Document No.", DataLine."Source No.");
                                        ATOLink.SetRange("Document Line No.", DataLine."Source Line No.");
                                        if ATOLink.FindFirst() then begin
                                            ItemTrackingLine.SetRange("Source Type", 901);
                                            ItemTrackingLine.SetRange("Source Subtype", 1);
                                            ItemTrackingLine.SetRange("Reservation Status", ItemTrackingLine."Reservation Status"::Surplus);
                                            ItemTrackingLine.SetRange("Source ID", ATOLink."Assembly Document No.");
                                            ItemTrackingLine.SetRange("Item No.", DataLine."Item No.");
                                            //Init to make sure no old data is passed to the next dataline
                                            if not ItemTrackingLine.FindSet() then
                                                ItemTrackingLine.Init();
                                        end;
                                    end else begin
                                        ItemTrackingLine.SetRange("Source Type", DataLine."Source Type");
                                        ItemTrackingLine.SetRange("Source Subtype", DataLine."Source Subtype");
                                        ItemTrackingLine.SetRange("Source ID", DataLine."Source No.");
                                        ItemTrackingLine.SetRange("Source Ref. No.", DataLine."Source Line No.");
                                        ItemTrackingLine.SetRange("Item No.", DataLine."Item No.");
                                        ItemTrackingLine.SetRange(Binding, ItemTrackingLine.Binding::" ");
                                        ItemTrackingLine.SetRange("Reservation Status", ItemTrackingLine."Reservation Status"::Surplus);
                                        //Init to make sure no old data is passed to the next dataline
                                        if not ItemTrackingLine.FindSet() then
                                            ItemTrackingLine.Init();
                                    end;
                                end;
                            }
                        }

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
                            WhseShipmentLine.SetRange("No.", DataHeader."No.");
                            if WhseShipmentLine.FindSet() then begin
                                ATOLink.SetRange(Type, ATOLink.Type::Sale);
                                ATOLink.SetRange("Assembly Document Type", ATOLink."Assembly Document Type"::Order);
                                ATOLink.SetRange("Document Type", ATOLink."Document Type"::Order);
                                ATOLink.SetRange("Document No.", WhseShipmentLine."Source No.");
                                repeat
                                    //Create dummy DataLines incl. Assembly DataLines to loop through
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
                                                AddDummyShipmentLine(WhseShipmentLine2, AssemblyLine."No.", AssemblyLine."Description", AssemblyLine."Description 2", AssemblyLine."Unit of Measure Code", AssemblyLine.Quantity, true, WhseShipmentLine."Line No.", AssemblyLine."Line No.", 0);
                                            until AssemblyLine.Next() = 0;
                                    end else
                                        AddDummyShipmentLine(WhseShipmentLine2, WhseShipmentLine."Item No.", WhseShipmentLine.Description, WhseShipmentLine."Description 2", WhseShipmentLine."Unit of Measure Code", WhseShipmentLine.Quantity, false, WhseShipmentLine."Line No.", 0, 0);
                                until WhseShipmentLine.Next() = 0;
                            end;
                            DataLine.SetRange("No.", WhseShipmentNo);
                        end;
                    }
                }
                trigger OnAfterGetRecord()
                var
                    WhseShipmentLine: Record "Warehouse Shipment Line";
                begin
                    WhseShipmentLine.SetRange("No.", DataHeader."No.");
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

                    IFSetup.GetWMSIFSetupEntryNo(DataHeader."Location Code");
                end;
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
        //Set field Assemble to Order for assembly DataLines
        WhseShipmentLine."Assemble to Order" := ATO;
        //Set field Shelf No. to store the original Whse. Shipment Line No.
        WhseShipmentLine."Shelf No." := Format(OriginalWhseLineNo);
        //Set field Qty. to Ship to store the original Assembly Line No.
        WhseShipmentLine."Qty. to Ship" := OriginalAssLineNo;
        //Set field Qty. Shipped to store the ResEntryNo in case a Lot or Serial No. is entered
        WhseShipmentLine."Qty. Shipped" := ResEntryNo;
        //Set field Zone Code to know this is a line to be deleted.
        WhseShipmentLine."Zone Code" := 'XML50018';
        WhseShipmentLine.Insert(false);
    end;

    trigger OnPreXmlPort()
    begin
        //Check if the decimal sign is a comma
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
        GLSetup.Get();
    end;

    trigger OnPostXmlPort()
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        //Delete created Whse shipment DataLines which are based on assembly DataLines
        WhseShipmentLine.SetRange("Zone Code", 'XML50018');
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