report 50036 "Rhenus Customs Invoice TO"

//  RHE-TNA 13-07-2021 BDS-5386
//  - New Report

//  RHE-TNA 21-09-2021 BDS-5623
//  - Added column(WhseShipmentNo; WhseShipmentNo)
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

{
    DefaultLayout = RDLC;
    RDLCLayout = './Rhenus Customs Invoice TO.rdl';
    Caption = 'Customs Invoice Transfer Order';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Transfer Header"; "Transfer Header")
        {
            DataItemTableView = SORTING ("No.");
            RequestFilterFields = "No.", "Transfer-from Code", "Transfer-to Code";
            RequestFilterHeading = 'Transfer Order';

            column(No_TransferHdr; "No.")
            {

            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting (Number);

                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = sorting (Number) where (Number = const (1));

                    column(CompanyInfoPicture; CompanyInfo.Picture)
                    {

                    }
                    column(CompanyName; CompanyInfo.Name)
                    {

                    }
                    column(CompanyShipToAddress; CompanyInfo."Ship-to Address")
                    {

                    }
                    column(CompanyShipToPostCode; CompanyInfo."Ship-to Post Code")
                    {

                    }
                    column(CompanyShipToCity; CompanyInfo."Ship-to City")
                    {

                    }
                    column(CompanyShipToCountry; CompanyShipToCountryText)
                    {

                    }
                    column(VatRegNoLbl; VatRegNoLbl)
                    {

                    }
                    column(VatRegNo; CompanyInfo."VAT Registration No.")
                    {

                    }
                    column(EmailLbl; EmailLbl)
                    {

                    }
                    column(Email; CompanyInfo."E-Mail")
                    {

                    }
                    column(PhoneNoLbl; PhoneNoLbl)
                    {

                    }
                    column(PhoneNo; CompanyInfo."Phone No.")
                    {

                    }
                    column(FaxLbl; FaxLbl)
                    {

                    }
                    column(Fax; CompanyInfo."Fax No.")
                    {

                    }
                    column(HdrCaption; STRSUBSTNO(Text001, CopyText))
                    {

                    }
                    column(TransferToAddr1; TransferToAddr[1])
                    {

                    }
                    column(TransferFromAddr1; TransferFromAddr[1])
                    {

                    }
                    column(TransferToAddr2; TransferToAddr[2])
                    {

                    }
                    column(TransferFromAddr2; TransferFromAddr[2])
                    {

                    }
                    column(TransferToAddr3; TransferToAddr[3])
                    {

                    }
                    column(TransferFromAddr3; TransferFromAddr[3])
                    {

                    }
                    column(TransferToAddr4; TransferToAddr[4])
                    {

                    }
                    column(TransferFromAddr4; TransferFromAddr[4])
                    {

                    }
                    column(TransferToAddr5; TransferToAddr[5])
                    {

                    }
                    column(TransferToAddr6; TransferToAddr[6])
                    {

                    }
                    column(BillToAddr1; BillToAddr[1])
                    {

                    }
                    column(BillToAddr2; BillToAddr[2])
                    {

                    }
                    column(BillToAddr3; BillToAddr[3])
                    {

                    }
                    column(BillToAddr4; BillToAddr[4])
                    {

                    }
                    column(BillToAddr5; BillToAddr[5])
                    {

                    }
                    column(BillToAddr6; BillToAddr[6])
                    {

                    }
                    column(BillToAddr7; BillToAddr[7])
                    {

                    }
                    column(BillToAddr8; BillToAddr[8])
                    {

                    }
                    column(InTransitCode_TransHdr; "Transfer Header"."In-Transit Code")
                    {
                        IncludeCaption = true;
                    }
                    column(PostingDate_TransHdr; FORMAT("Transfer Header"."Posting Date"))
                    {

                    }
                    column(OrderDateCaptionLbl; OrderDateCaptionLbl)
                    {

                    }
                    column(OrderDate_TransHdr; FORMAT("Transfer Header"."Shipment Date"))
                    {

                    }
                    column(ShipmentDateCaptionLbl; OrderDateCaptionLbl)
                    {

                    }
                    column(ShipmentDate_TransHdr; FORMAT("Transfer Header"."Shipment Date"))
                    {

                    }
                    column(TransferToAddr7; TransferToAddr[7])
                    {

                    }
                    column(TransferToAddr8; TransferToAddr[8])
                    {

                    }
                    column(ShipFromLbl; ShipFromLbl)
                    {

                    }
                    column(TransferFromAddr5; TransferFromAddr[5])
                    {

                    }
                    column(TransferFromAddr6; TransferFromAddr[6])
                    {

                    }
                    column(PageCaption; STRSUBSTNO(Text002, ''))
                    {

                    }
                    column(OutputNo; OutputNo)
                    {

                    }
                    column(ShipmentMethodCaption; ShipmentMethodCaptionLbl)
                    {

                    }
                    column(ShptMethodDesc; "Transfer Header"."Shipment Method Code")
                    {

                    }
                    column(ShippingAgentCodeCaption; ShippingAgentCaptionLbl)
                    {

                    }
                    column(ShippingAgentCode; "Transfer Header"."Shipping Agent Code")
                    {

                    }
                    column(InvoiceToCaption; STRSUBSTNO(Text003, ''))
                    {

                    }
                    column(DeliverToCaption; STRSUBSTNO(Text004, ''))
                    {

                    }
                    column(CurrentDate; FORMAT(Today))
                    {

                    }
                    column(FooterNote; FooterNote)
                    {

                    }
                    column(FooterNote2; FooterNote2)
                    {

                    }
                    column(EORI; EORI)
                    {

                    }
                    //RHE-TNA 21-09-2021 BDS-5623 BEGIN
                    column(WhseShipmentNo; WhseShipmentNo)
                    {

                    }
                    //RHE-TNA 21-09-2021 BDS-5623 END
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemTableView = sorting (Number) where (Number = filter (1 ..));
                        DataItemLinkReference = "Transfer Header";

                        column(DimText; DimText)
                        {

                        }
                        column(Number_DimensionLoop1; Number)
                        {

                        }
                        column(HdrDimensionsCaption; HdrDimensionsCaptionLbl)
                        {

                        }

                        trigger OnPreDataItem()
                        begin
                            IF NOT ShowInternalInfo THEN
                                CurrReport.BREAK;
                        end;

                        trigger OnAfterGetRecord()
                        begin
                            IF Number = 1 THEN BEGIN
                                IF NOT DimSetEntry1.FINDSET THEN
                                    CurrReport.BREAK;
                            END ELSE
                                IF NOT Continue THEN
                                    CurrReport.BREAK;

                            CLEAR(DimText);
                            Continue := FALSE;
                            REPEAT
                                OldDimText := DimText;
                                IF DimText = '' THEN
                                    DimText := STRSUBSTNO('%1 - %2', DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code")
                                ELSE
                                    DimText :=
                                      STRSUBSTNO(
                                        '%1; %2 - %3', DimText,
                                        DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code");
                                IF STRLEN(DimText) > MAXSTRLEN(OldDimText) THEN BEGIN
                                    DimText := OldDimText;
                                    Continue := TRUE;
                                    EXIT;
                                END;
                            UNTIL DimSetEntry1.NEXT = 0;
                        end;
                    }
                    dataitem("Transfer Line"; "Transfer Line")
                    {
                        DataItemTableView = SORTING ("Document No.", "Line No.") WHERE ("Derived From Line No." = CONST (0));
                        DataItemLinkReference = "Transfer Header";
                        DataItemLink = "Document No." = FIELD ("No.");

                        column(ItemCaption; ItemCaptionLbl)
                        {

                        }
                        column(ItemNo_TransLine;
                        "Item No.")
                        {
                            IncludeCaption = true;
                        }
                        column(Desc_TransLine; Description)
                        {
                            IncludeCaption = true;
                        }
                        column(QtyCaption; QtyCaptionLbl)
                        {

                        }
                        column(Qty_TransLine; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(UOMCaption; UOMCaptionLbl)
                        {

                        }
                        column(UOM_TransLine; "Unit of Measure Code")
                        {
                            IncludeCaption = true;
                        }
                        column(Qty_TransLineShipped; "Quantity Shipped")
                        {
                            IncludeCaption = true;
                        }
                        column(LineNo_TransLine; "Line No.")
                        {

                        }
                        column(HSCodeCaption; HSCodeCaptionLbl)
                        {

                        }
                        column(gCodHSCode; gCodHSCode)
                        {

                        }
                        column(CoOCodeCaption; CoOCodeCaptionLbl)
                        {

                        }
                        column(gCodCOO; gCodCOO)
                        {

                        }
                        column(UnitPriceCaption; UnitPriceCaptionLbl)
                        {

                        }
                        column(UnitPrice; "Unit Price")
                        {

                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {

                        }
                        column(Line_Amount; "Line Amount")
                        {

                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {

                        }
                        column(AmountExclVAT; AmountExclVAT)
                        {
                            AutoFormatExpression = "Transfer Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmount; VATAmount)
                        {
                            AutoFormatExpression = "Transfer Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {

                        }
                        column(AmountInclVAT; AmountInclVAT)
                        {
                            AutoFormatExpression = "Transfer Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TxtVat1; TxtVat1)
                        {

                        }
                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = sorting (Number) where (Number = filter (1 ..));
                            DataItemLinkReference = "Transfer Line";
                            column(DimText2; DimText)
                            {

                            }
                            column(Number_DimensionLoop2; Number)
                            {

                            }
                            column(LineDimensionsCaption; LineDimensionsCaptionLbl)
                            {

                            }


                            trigger OnPreDataItem()
                            begin
                                IF NOT ShowInternalInfo THEN
                                    CurrReport.BREAK;
                            end;

                            trigger OnAfterGetRecord()
                            begin
                                IF Number = 1 THEN BEGIN
                                    IF NOT DimSetEntry2.FINDSET THEN
                                        CurrReport.BREAK;
                                END ELSE
                                    IF NOT Continue THEN
                                        CurrReport.BREAK;

                                CLEAR(DimText);
                                Continue := FALSE;
                                REPEAT
                                    OldDimText := DimText;
                                    IF DimText = '' THEN
                                        DimText := STRSUBSTNO('%1 - %2', DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code")
                                    ELSE
                                        DimText :=
                                          STRSUBSTNO(
                                            '%1; %2 - %3', DimText,
                                            DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code");
                                    IF STRLEN(DimText) > MAXSTRLEN(OldDimText) THEN BEGIN
                                        DimText := OldDimText;
                                        Continue := TRUE;
                                        EXIT;
                                    END;
                                UNTIL DimSetEntry2.NEXT = 0;
                            end;

                        }

                        trigger OnAfterGetRecord()
                        begin
                            DimSetEntry2.SETRANGE("Dimension Set ID", "Dimension Set ID");

                            gCodHSCode := '';
                            gCodCOO := '';

                            If Item.Get("Item No.") then begin
                                gCodHSCode := Item."Tariff No.";
                                gCodCOO := Item."Country/Region of Origin Code";
                            end;
                            VATAmount := 0;
                            AmountExclVAT := AmountExclVAT + "Line Amount";
                            AmountInclVAT := AmountInclVAT + "Line Amount" + VATAmount;
                        end;
                    }
                }

                trigger OnPreDataItem()
                begin
                    NoOfLoops := ABS(NoOfCopies) + 1;
                    CopyText := '';
                    SETRANGE(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;

                trigger OnAfterGetRecord()
                begin
                    IF Number > 1 THEN BEGIN
                        CopyText := Text000;
                        OutputNo += 1;
                    END;
                end;
            }

            trigger OnAfterGetRecord()
            var
                IoRCustomer: Record Customer;
                WhseShipmentLine: Record "Warehouse Shipment Line";
            begin
                DimSetEntry1.SETRANGE("Dimension Set ID", "Dimension Set ID");
                FormatAddr.TransferHeaderTransferFrom(TransferFromAddr, "Transfer Header");
                FormatAddr.TransferHeaderTransferTo(TransferToAddr, "Transfer Header");
                FormatAddr.TransferHeaderTransferTo(BillToAddr, "Transfer Header");

                IF NOT ShipmentMethod.GET("Shipment Method Code") THEN
                    ShipmentMethod.INIT;

                if "Currency Code" = '' then begin
                    GLSetup.TestField("LCY Code");
                    TotalInclVATText := StrSubstNo(AmountInclVATCaptionLbl, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(AmountExclVATCaptionLbl, GLSetup."LCY Code");
                end else begin
                    TotalInclVATText := StrSubstNo(AmountInclVATCaptionLbl, "Currency Code");
                    TotalExclVATText := StrSubstNo(AmountExclVATCaptionLbl, "Currency Code");
                end;

                CompanyShipToCountryText := '';
                if Country.Get(CompanyInfo."Ship-to Country/Region Code") then
                    CompanyShipToCountryText := Country.Name;

                EORI := '';
                if Country.Get("Transfer Header"."Trsf.-to Country/Region Code") then begin
                    EORI := Country."EORI No.";
                    if (Country."Importer of Record" <> '') then begin
                        IoRCustomer.Get(Country."Importer of Record");
                        FormatAddr.Customer(BillToAddr, IoRCustomer);
                    end;
                end;

                //RHE-TNA 21-09-2021 BDS-5623 BEGIN
                WhseShipmentNo := '';
                WhseShipmentLine.Reset();
                WhseShipmentLine.SetRange("Source Type", 5741);
                WhseShipmentLine.SetRange("Source Subtype", 0);
                WhseShipmentLine.SetRange("Source No.", "No.");
                if WhseShipmentLine.FindFirst() then
                    WhseShipmentNo := WhseShipmentLine."No.";
                //RHE-TNA 21-09-2021 BDS-5623 END
            end;
        }
    }

    trigger OnInitReport()
    begin
        GLSetup.Get();
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        ShipmentMethod: Record "Shipment Method";
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        FormatAddr: Codeunit "Format Address";
        Item: Record Item;
        Country: Record "Country/Region";
        TransferFromAddr: array[8] of Text[100];
        TransferToAddr: array[8] of Text[100];
        BillToAddr: array[8] of Text[100];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        DimText: Text[120];
        OldDimText: Text[75];
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        OutputNo: Integer;
        gCodCOO: Code[10];
        gCodHSCode: Code[20];
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        AmountInclVAT: Decimal;
        TotalExclVATText: Text[50];
        TotalInclVATText: Text[50];
        CompanyShipToCountryText: Text[50];
        EORI: Text[20];
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        /*
        Text000: TextConst
            ENU = 'COPY';
        Text001: TextConst
            ENU = 'Customs Invoice %1';
        Text002: TextConst
            ENU = 'Page %1';
        Text003: TextConst
            ENU = 'Invoice To:';
        Text004: TextConst
            ENU = 'Delivery To:';
        ShipFromLbl: TextConst
            ENU = 'Ship From:';
        HdrDimensionsCaptionLbl: TextConst
            ENU = 'Header Dimensions';
        LineDimensionsCaptionLbl: TextConst
            ENU = 'Line Dimensions';
        ShipmentMethodCaptionLbl: TextConst
            ENU = 'Freight Terms';
        ShippingAgentCaptionLbl: TextConst
            ENU = 'Carrier';
        HSCodeCaptionLbl: TextConst
            ENU = 'HS Code';
        CoOCodeCaptionLbl: TextConst
            ENU = 'CoO';
        OrderDateCaptionLbl: TextConst
            ENU = 'Date';
        ShipmentDateCaptionLbl: TextConst
            ENU = 'Shipment Date';
        UnitPriceCaptionLbl: TextConst
            ENU = 'Unit Price';
        AmountCaptionLbl: TextConst
            ENU = 'Amount';
        QtyCaptionLbl: TextConst
            ENU = 'Qty';
        UOMCaptionLbl: TextConst
            ENU = 'UOM';
        ItemCaptionLbl: TextConst
            ENU = 'Item';
        AmountExclVATCaptionLbl: TextConst
            ENU = 'Total %1 Excl. VAT';
        AmountInclVATCaptionLbl: TextConst
            ENU = 'Total %1 Incl. VAT';
        FooterNote: TextConst
            ENU = 'VALUE FOR CUSTOMS PURPOSES ONLY';
        FooterNote2: TextConst
            ENU = '0% Dutch VAT - Export supply (Article 146 EU VAT Directive Applies)';
        VatRegNoLbl: TextConst
            ENU = 'VAT Reg. No.';
        EmailLbl: TextConst
            ENU = 'E-mail';
        PhoneNoLbl: TextConst
            ENU = 'Phone No.';
        FaxLbl: TextConst
            ENU = 'Fax No.';
        TxtVat1: TextConst
            ENU = '0% VAT (Export Supply)';
        */
        Text000: Label 'COPY';
        Text001: Label 'Customs Invoice %1';
        Text002: Label 'Page %1';
        Text003: Label 'Invoice To:';
        Text004: Label 'Delivery To:';
        ShipFromLbl: Label 'Ship From:';
        HdrDimensionsCaptionLbl: Label 'Header Dimensions';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        ShipmentMethodCaptionLbl: Label 'Freight Terms';
        ShippingAgentCaptionLbl: Label 'Carrier';
        HSCodeCaptionLbl: Label 'HS Code';
        CoOCodeCaptionLbl: Label 'CoO';
        OrderDateCaptionLbl: Label 'Date';
        ShipmentDateCaptionLbl: Label 'Shipment Date';
        UnitPriceCaptionLbl: Label 'Unit Price';
        AmountCaptionLbl: Label 'Amount';
        QtyCaptionLbl: Label 'Qty';
        UOMCaptionLbl: Label 'UOM';
        ItemCaptionLbl: Label 'Item';
        AmountExclVATCaptionLbl: Label 'Total %1 Excl. VAT';
        AmountInclVATCaptionLbl: Label 'Total %1 Incl. VAT';
        FooterNote: Label 'VALUE FOR CUSTOMS PURPOSES ONLY';
        FooterNote2: Label '0% Dutch VAT - Export supply (Article 146 EU VAT Directive Applies)';
        VatRegNoLbl: Label 'VAT Reg. No.';
        EmailLbl: Label 'E-mail';
        PhoneNoLbl: Label 'Phone No.';
        FaxLbl: Label 'Fax No.';
        TxtVat1: Label '0% VAT (Export Supply)';
        //RHE-TNA 21-01-2022 BDS-6037 END
        WhseShipmentNo: Code[20];
}