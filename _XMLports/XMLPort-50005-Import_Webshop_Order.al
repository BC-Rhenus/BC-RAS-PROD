xmlport 50005 "Import Webshop Order"

//  RHE-TNA 25-09-2020 BDS-4533
//  - Added TextEncoding to properties

//  RHE-TNA 23-11-2020 BDS-4705
//  - Modified trigger OnPostXmlPort()

//  RHE-TNA 05-01-2021 BDS-4828
//  - Modified procedure UpdateSalesHdr()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreXMLPort()

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

//  RHE-TNA 08-02-2022 BDS-6102
//  - Modified procedure UpdateSalesHdr()

{
    Direction = Import;
    Format = VariableText;
    RecordSeparator = '<LF>';
    UseRequestPage = false;
    //RHE-TNA 25-09-2020 BDS-4533 BEGIN
    TextEncoding = UTF8;
    //RHE-TNA 25-09-2020 BDS-4533 END

    schema
    {
        textelement(Root)
        {
            tableelement(Order; Integer)
            {
                textattribute(Email_Imp)
                {

                }
                textattribute(Created_At_Imp)
                {

                }
                textattribute(Total_Price_Imp)
                {

                }
                textattribute(Subtotal_Price_Imp)
                {

                }
                textattribute(Total_Tax_Imp)
                {

                }
                textattribute(Currency_Imp)
                {

                }
                textattribute(Total_Discount_Imp)
                {

                }
                textattribute(Name_Imp)
                {

                }
                textattribute(Item_Qty_Imp)
                {

                }
                textattribute(Item_Price_Imp)
                {

                }
                textattribute(Item_SKU_Imp)
                {

                }
                textattribute(Item_Name_Imp)
                {

                }
                textattribute(Shipping_Price_Imp)
                {

                }
                textattribute(Billing_Address1_Imp)
                {

                }
                textattribute(Billing_City_Imp)
                {

                }
                textattribute(Billing_Postcode_Imp)
                {

                }
                textattribute(Billing_Country_Name_Imp)
                {

                }
                textattribute(Billing_Address2_Imp)
                {

                }
                textattribute(Billing_Company_Imp)
                {

                }
                textattribute(Billing_Name_Imp)
                {

                }
                textattribute(Billing_Country_Code_Imp)
                {

                }
                textattribute(Shipping_Address1_Imp)
                {

                }
                textattribute(Shipping_Phone_Imp)
                {

                }
                textattribute(Shipping_City_Imp)
                {

                }
                textattribute(Shipping_Postcode_Imp)
                {

                }
                textattribute(Shipping_Address2_Imp)
                {

                }
                textattribute(Shipping_Name_Imp)
                {

                }
                textattribute(Shipping_Country_Code_Imp)
                {

                }
                textattribute(Customer_Note_Imp)
                {

                }
                textattribute(Customer_Tax_Exempt_Imp)
                {

                }

                trigger OnBeforeInsertRecord()
                var
                    SalesHdrArchive: Record "Sales Header Archive";
                    SalesLine: Record "Sales Line";
                    OrderQty: Decimal;
                    UnitPrice: Decimal;
                    LineDiscount: Decimal;
                    LineShippingCost: Decimal;
                    ReleaseSalesDoc: Codeunit "Release Sales Document";
                    //RHE-TNA 21-01-2022 BDS-6037 BEGIN
                    //ErrorText001: TextConst
                    //    ENU = 'Order %1 is already present in Sales Order Archive.';
                    ErrorText001: Label 'Order %1 is already present in Sales Order Archive.';
                    //RHE-TNA 21-01-2022 BDS-6037 END
                begin
                    //Skip first line as this is a header line
                    if FirstLine then begin
                        FirstLine := false;
                        currXMLport.Skip();
                    end;

                    OrderID := CopyStr(Name_Imp, 1, 20);
                    //Skip order lines with no order number
                    if OrderID = '' then
                        currXMLport.Skip();

                    if OrderID <> PrevOrderID then begin
                        //Check if discount and shipping costs need to added for the previous processed order 
                        EndSalesOrder(-OrderDiscount, ShippingCost);
                        OrderDiscount := 0;
                        ShippingCost := 0;

                        SalesHdrArchive.SetRange("Document Type", SalesHdrArchive."Document Type"::Order);
                        SalesHdrArchive.SetRange("No.", OrderID);
                        if SalesHdrArchive.FindFirst() then
                            Error(ErrorText001, OrderID);

                        B2BCustomer := false;
                        if Customer_Note_Imp <> '' then
                            //This CSV field contains customer VAT number
                            B2BCustomer := true;

                        SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
                        SalesHdr.SetRange("No.", OrderID);
                        if SalesHdr.FindFirst() then begin
                            if SalesHdr.Status <> SalesHdr.Status::Open then
                                ReleaseSalesDoc.PerformManualReopen(SalesHdr);
                            //Delete Sales Lines as these will be added again later
                            SalesLine.SetRange("Document Type", SalesHdr."Document Type");
                            SalesLine.SetRange("Document No.", SalesHdr."No.");
                            SalesLine.DeleteAll(true);
                        end else begin
                            SalesHdr.Init();
                            SalesHdr."Document Type" := SalesHdr."Document Type"::Order;
                            SalesHdr.Validate("No.", OrderID);
                            SalesHdr.Insert(true);
                        end;
                        UpdateSalesHdr();
                    end;

                    if DecimalSignIsComma then begin
                        if StrPos(Item_Qty_Imp, '.') <> 0 then
                            Item_Qty_Imp := ConvertStr(Item_Qty_Imp, '.', ',');
                        if StrPos(Item_Price_Imp, '.') <> 0 then
                            Item_Price_Imp := ConvertStr(Item_Price_Imp, '.', ',');
                        if StrPos(Total_Discount_Imp, '.') <> 0 then
                            Total_Discount_Imp := ConvertStr(Total_Discount_Imp, '.', ',');
                        if StrPos(Item_Price_Imp, '.') <> 0 then
                            Item_Price_Imp := ConvertStr(Item_Price_Imp, '.', ',');
                    end;
                    Evaluate(OrderQty, Item_Qty_Imp);
                    Evaluate(UnitPrice, Item_Price_Imp);

                    CreateSalesLine(SalesHdr."Document Type", SalesHdr."No.", 0, Item_SKU_Imp, OrderQty, UnitPrice);
                    PrevOrderID := OrderID;

                    //Store order discount and shipping costs
                    Evaluate(LineDiscount, Total_Discount_Imp);
                    OrderDiscount := -LineDiscount;
                    Evaluate(LineShippingCost, Shipping_Price_Imp);
                    ShippingCost := LineShippingCost;

                    //Do not actually import into Integer table
                    currXMLport.Skip();
                end;
            }
        }
    }

    procedure UpdateSalesHdr()
    var
        Country: Record "Country/Region";
        ShippingCountry: Code[10];
        BillingCountry: Code[10];
        Year: Integer;
        Month: Integer;
        Day: Integer;
        Carrier: Record "Interface Mapping";
        Customer: Record Customer;
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Country Code %1 cannot be found.';
        ErrorText001: Label 'Country Code %1 cannot be found.';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        ShippingCountry := Country.GetCountryCode(CopyStr(Shipping_Country_Code_Imp, 1, 10));
        if ShippingCountry = '' then
            Error(ErrorText001, Shipping_Country_Code_Imp);
        BillingCountry := Country.GetCountryCode(CopyStr(Billing_Country_Code_Imp, 1, 10));
        if BillingCountry = '' then
            Error(ErrorText001, Billing_Country_Code_Imp);

        Country.Get(ShippingCountry);
        if B2BCustomer then begin
            //Set Disable Seach by Name to true to make sure no new customer will be created
            Customer.Get(IFSetup."Order Import Cust. No. B2B");
            if not Customer."Disable Search by Name" then begin
                Customer."Disable Search by Name" := true;
                Customer.Modify(false);
            end;
            SalesHdr.Validate("Sell-to Customer No.", IFSetup."Order Import Cust. No. B2B");
            Country.TestField("B2B Gen. Bus. Posting Group");
            Country.TestField("B2B VAT Bus. Posting Group");
        end else begin
            //Set Disable Seach by Name to true to make sure no new customer will be created
            Customer.Get(IFSetup."Order Import Cust. No. B2C");
            if not Customer."Disable Search by Name" then begin
                Customer."Disable Search by Name" := true;
                Customer.Modify(false);
            end;
            SalesHdr.Validate("Sell-to Customer No.", IFSetup."Order Import Cust. No. B2C");
            Country.TestField("B2C Gen. Bus. Posting Group");
            Country.TestField("B2C VAT Bus. Posting Group");
        end;

        if Billing_Company_Imp <> '' then begin
            SalesHdr.Validate("Sell-to Customer Name", CopyStr(Billing_Company_Imp, 1, 100));
            SalesHdr.Validate("Bill-to Name", CopyStr(Billing_Company_Imp, 1, 100));
            SalesHdr.Validate("Sell-to Contact", CopyStr(Billing_Name_Imp, 1, 100));
            SalesHdr.Validate("Bill-to Contact", CopyStr(Billing_Name_Imp, 1, 100));
            SalesHdr.Validate("Ship-to Contact", CopyStr(Billing_Name_Imp, 1, 100));
        end else begin
            SalesHdr.Validate("Sell-to Customer Name", CopyStr(Billing_Name_Imp, 1, 100));
            SalesHdr.Validate("Bill-to Name", CopyStr(Billing_Name_Imp, 1, 100));
        end;
        SalesHdr.Validate("Ship-to Name", CopyStr(Shipping_Name_Imp, 1, 100));

        SalesHdr.Validate("Sell-to Address", CopyStr(Billing_Address1_Imp, 1, 100));
        SalesHdr.Validate("Bill-to Address", CopyStr(Billing_Address1_Imp, 1, 100));
        SalesHdr.Validate("Ship-to Address", CopyStr(Shipping_Address1_Imp, 1, 100));

        SalesHdr.Validate("Sell-to Address 2", CopyStr(Billing_Address2_Imp, 1, 50));
        SalesHdr.Validate("Bill-to Address 2", CopyStr(Billing_Address2_Imp, 1, 50));
        SalesHdr.Validate("Ship-to Address 2", CopyStr(Shipping_Address2_Imp, 1, 50));

        SalesHdr.Validate("Sell-to Post Code", CopyStr(Billing_Postcode_Imp, 1, 20));
        SalesHdr.Validate("Bill-to Post Code", CopyStr(Billing_Postcode_Imp, 1, 20));
        SalesHdr.Validate("Ship-to Post Code", CopyStr(Shipping_Postcode_Imp, 1, 20));

        SalesHdr.Validate("Sell-to City", CopyStr(Billing_City_Imp, 1, 30));
        SalesHdr.Validate("Bill-to City", CopyStr(Billing_City_Imp, 1, 30));
        SalesHdr.Validate("Ship-to City", CopyStr(Shipping_City_Imp, 1, 30));

        SalesHdr.Validate("Sell-to Country/Region Code", BillingCountry);
        SalesHdr.Validate("Bill-to Country/Region Code", BillingCountry);
        SalesHdr.Validate("Ship-to Country/Region Code", ShippingCountry);

        SalesHdr.Validate("Ship-to Phone No.", CopyStr(Shipping_Phone_Imp, 1, 30));
        //RHE-TNA 05-01-2021 BDS-4828 BEGIN
        //SalesHdr.Validate("E-mail", CopyStr(Email_Imp, 1, 80));
        SalesHdr.Validate("Sell-to E-Mail", CopyStr(Email_Imp, 1, 80));
        //RHE-TNA 05-01-2021 BDS-4828 END
        SalesHdr.Validate("VAT Registration No.", CopyStr(Customer_Note_Imp, 1, 20));
        SalesHdr.Validate("External Document No.", OrderID);
        if B2BCustomer then begin
            SalesHdr.Validate("Gen. Bus. Posting Group", Country."B2B Gen. Bus. Posting Group");
            SalesHdr.Validate("VAT Bus. Posting Group", Country."B2B VAT Bus. Posting Group");
        end else begin
            SalesHdr.Validate("Gen. Bus. Posting Group", Country."B2C Gen. Bus. Posting Group");
            SalesHdr.Validate("VAT Bus. Posting Group", Country."B2C VAT Bus. Posting Group");
        end;
        if Currency_Imp <> GLSetup."LCY Code" then
            SalesHdr.Validate("Currency Code", Currency_Imp);

        //Get carrier based on VAT Bus. Posting Group as carrier settings can be different per country and whether customer is B2B or B2C
        //RHE-TNA 08-02-2022 BDS-6102 BEGIN
        //if Carrier.Get(SalesHdr."VAT Bus. Posting Group") then begin
        Carrier.SetRange(Type, Carrier.Type::Carrier);
        Carrier.SetRange("Interface Value", SalesHdr."VAT Bus. Posting Group");
        if Carrier.FindFirst() then begin
            //RHE-TNA 08-02-2022 BDS-6102 END
            SalesHdr.Validate("Shipping Agent Code", Carrier."Shipping Agent Code");
            if Country.Code = CompanySetup."Country/Region Code" then
                SalesHdr.Validate("Shipping Agent Service Code", Carrier."Ship Agent Service Code Dom.")
            else
                if Country."EU Country/Region Code" <> '' then
                    SalesHdr.Validate("Shipping Agent Service Code", Carrier."Ship Agent Service Code EU")
                else
                    SalesHdr.Validate("Shipping Agent Service Code", Carrier."Ship Agent Service Code Export");
        end;

        Evaluate(Year, CopyStr(Created_At_Imp, 1, 4));
        Evaluate(Month, CopyStr(Created_At_Imp, 6, 2));
        Evaluate(Day, CopyStr(Created_At_Imp, 9, 2));
        SalesHdr.Validate("Order Date", DMY2Date(Day, Month, Year));
        SalesHdr.Modify(true);
    end;

    procedure CreateSalesLine(DocumentType: Option Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order"; DocumentNo: Code[20]; LineType: Option Item,"G/L Account"; No: Code[20]; Quantity: Decimal; UnitPrice: Decimal)
    var
        SalesLine: Record "Sales Line";
        Salesline2: Record "Sales Line";
    begin
        SalesLine2.SetRange("Document Type", DocumentType);
        Salesline2.SetRange("Document No.", DocumentNo);
        if not Salesline2.FindLast() then
            Salesline2.Init();

        SalesLine.Init();
        SalesLine."Document Type" := DocumentType;
        SalesLine."Document No." := DocumentNo;
        SalesLine."Line No." := Salesline2."Line No." + 10000;
        SalesLine.SuspendStatusCheck(true);
        SalesLine.SetHideValidationDialog(true);
        SalesLine.Insert(true);

        if LineType = LineType::Item then
            SalesLine.Validate(Type, SalesLine.Type::Item);
        if LineType = LineType::"G/L Account" then
            SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", No);
        SalesLine.Validate(Quantity, Quantity);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
    end;

    procedure EndSalesOrder(Discount: Decimal; ShippingCost: Decimal)
    begin
        //Do not add discount and shipping costs if PrevOrderID is empty. This means the first order started or no order has been added/modified.
        if PrevOrderID = '' then
            exit;

        if Discount <> 0 then
            CreateSalesLine(SalesHdr."Document Type", SalesHdr."No.", 1, IFSetup."Order Import Discount Account", 1, Discount);
        if ShippingCost <> 0 then
            CreateSalesLine(SalesHdr."Document Type", SalesHdr."No.", 1, IFSetup."Order Import Ship Cost Account", 1, ShippingCost);
    end;

    procedure SetFileName(FileName: Text[250])
    begin
        currXMLport.Filename := FileName;
    end;

    trigger OnPreXmlPort()
    begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        IFSetup.SetRange(Type, IFSetup.Type::Customer);
        IFSetup.SetRange("In Progress", true);
        IFSetup.FindFirst();
        //RHE-TNA 14-06-2021 BDS-5337 END
        GLSetup.Get();
        SalesSetup.Get();
        CompanySetup.Get();
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
        FirstLine := true;

        IFSetup.TestField("Order Import Cust. No. B2B");
        IFSetup.TestField("Order Import Cust. No. B2C");
    end;

    trigger OnPostXmlPort()
    begin
        //Check if discount and shipping costs need to added for the last processed order
        EndSalesOrder(OrderDiscount, ShippingCost);

        //RHE-TNA 23-11-2020 BDS-4705 BEGIN      
        //Set Assigned User ID to store import object ID (will be removed by Report 50016)
        SalesHdr."Assigned User ID" := '50016';
        SalesHdr.Modify(false);
        //RHE-TNA 23-11-2020 BDS-4705 END
    end;

    //Global Variables
    var
        IFSetup: Record "Interface Setup";
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        CompanySetup: Record "Company Information";
        FirstLine: Boolean;
        DecimalSignIsComma: Boolean;
        SalesHdr: Record "Sales Header";
        OrderID: Code[20];
        PrevOrderID: Code[20];
        B2BCustomer: Boolean;
        OrderDiscount: Decimal;
        ShippingCost: Decimal;
}