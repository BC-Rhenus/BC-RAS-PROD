report 50023 "Rhenus Customs Invoice"

//  RHE-TNA 18-12-2020 BDS-4798
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 28-01-2021 BDS-4908
//  - Modified trigger OnAfterGetRecord()
//  - Added Global Var EORI

//  RHE-TNA 17-09-2021 BDS-5623
//  - Added column(WhseShipmentNo; WhseShipmentNo)
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 19-11-2021 BDS-5858
//  - Added columns SalesPurchPersonPhoneNo, SalesPurchPersonEmail, SalesRepPhoneNoLbl, SalesRepEmailLbl

//  RHE-TNA 22-12-2021 PM-1328
//  - Changed columns UnitPrice_SalesLine, LineDisc_SalesLine, LineAmt_SalesLine
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 12-01-2022 BDS-5997
//  - Added columns AsmLineUOMCode, AsmLineHSCode, AsmLineCoOCode
//  - Added procedure GetAssLineHSCode()
//  - Added procedure GetAssLineCoOCode()
//  - Added trigger OnPostReport()
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 28-01-2022 BDS-6074

//  HE-TNA 25-05-2022 BDS-6364
//  - Added column PrintLine
//  - Added procedure SetPrintableLine()

{
    // version NAVW18.00.00.39368

    DefaultLayout = RDLC;
    //RHE-TNA 28-01-2021 BDS-4908 BEGIN
    //RDLCLayout = './Rhenus Customs Invoice.rdlc';
    RDLCLayout = './Rhenus Customs Invoice.rdl';
    //RHE-TNA 28-01-2021 BDS-4908 END
    Caption = 'Customs Invoice SO16';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(Order));
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'Sales Order';
            column(DocType_SalesHeader; "Document Type")
            {
            }
            column(No_SalesHeader; "No.")
            {
            }
            column(InvDiscAmtCaption; InvDiscAmtCaptionLbl)
            {
            }
            column(PhoneNoCaption; PhoneNoCaptionLbl)
            {
            }
            column(AmountCaption; AmountCaptionLbl)
            {
            }
            column(VATPercentageCaption; VATPercentageCaptionLbl)
            {
            }
            column(VATBaseCaption; VATBaseCaptionLbl)
            {
            }
            column(VATAmtCaption; VATAmtCaptionLbl)
            {
            }
            column(VATAmtSpecCaption; VATAmtSpecCaptionLbl)
            {
            }
            column(LineAmtCaption; LineAmtCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(UnitPriceCaption; UnitPriceCaptionLbl)
            {
            }
            column(PaymentTermsCaption; PaymentTermsCaptionLbl)
            {
            }
            column(ShipmentMethodCaption; ShipmentMethodCaptionLbl)
            {
            }
            column(DocumentDateCaption; DocumentDateCaptionLbl)
            {
            }
            column(AllowInvDiscCaption; AllowInvDiscCaptionLbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo3Picture; CompanyInfo3.Picture)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(OrderConfirmCopyCaption; StrSubstNo(Text004, CopyText))
                    {
                    }
                    column(CustAddr1; CustAddr[1])
                    {
                    }
                    column(CompanyAddr1; CompanyAddr[1])
                    {
                    }
                    column(CustAddr2; CustAddr[2])
                    {
                    }
                    column(CompanyAddr2; CompanyAddr[2])
                    {
                    }
                    column(CustAddr3; CustAddr[3])
                    {
                    }
                    column(CompanyAddr3; CompanyAddr[3])
                    {
                    }
                    column(CustAddr4; CustAddr[4])
                    {
                    }
                    column(CompanyAddr4; CompanyAddr[4])
                    {
                    }
                    column(CustAddr5; CustAddr[5])
                    {
                    }
                    column(CompanyInfoPhNo; CompanyInfo."Phone No.")
                    {
                        IncludeCaption = false;
                    }
                    column(CustAddr6; CustAddr[6])
                    {
                    }
                    column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoGiroNo; CompanyInfo."Giro No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyInfo."Bank Name")
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoEmail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoBankAccNo; CompanyInfo."Bank Account No.")
                    {
                    }
                    column(BilltoCustNo_SalesHeader; "Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(DocDate_SalesHeader; Format("Sales Header"."Document Date"))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_SalesHeader; "Sales Header"."VAT Registration No.")
                    {
                    }
                    column(ShptDate_SalesHeader; Format("Sales Header"."Shipment Date"))
                    {
                    }
                    column(SalesPersonText; SalesPersonText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    //RHE-TNA 19-11-2021 BDS-5858 BEGIN
                    column(SalesRepPhoneNoLbl; SalesRepPhoneNoLbl)
                    {

                    }
                    column(SalesRepEmailLbl; SalesRepEmailLbl)
                    {

                    }
                    column(SalesPurchPersonPhoneNo; SalesPurchPerson."Phone No.")
                    {

                    }
                    column(SalesPurchPersonEmail; SalesPurchPerson."E-Mail")
                    {

                    }
                    //RHE-TNA 19-11-2021 BDS-5858 END
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(SalesOrderReference_SalesHeader; "Sales Header"."Your Reference")
                    {
                    }
                    column(CustAddr7; CustAddr[7])
                    {
                    }
                    column(CustAddr8; CustAddr[8])
                    {
                    }
                    column(CompanyAddr5; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr6; CompanyAddr[6])
                    {
                    }
                    column(PricesInclVAT_SalesHeader; "Sales Header"."Prices Including VAT")
                    {
                    }
                    column(PageCaption; PageCaptionCap)
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PmntTermsDesc; PaymentTerms.Description)
                    {
                    }
                    column(ShptMethodDesc; ShipmentMethod.Code)
                    {
                    }
                    column(PricesInclVATYesNo_SalesHeader; Format("Sales Header"."Prices Including VAT"))
                    {
                    }
                    column(VATRegNoCaption; VATRegNoCaptionLbl)
                    {
                    }
                    column(GiroNoCaption; GiroNoCaptionLbl)
                    {
                    }
                    column(BankCaption; BankCaptionLbl)
                    {
                    }
                    column(AccountNoCaption; AccountNoCaptionLbl)
                    {
                    }
                    column(ShipmentDateCaption; ShipmentDateCaptionLbl)
                    {
                    }
                    column(OrderNoCaption; OrderNoCaptionLbl)
                    {
                    }
                    column(HomePageCaption; HomePageCaptionCap)
                    {
                    }
                    column(EmailCaption; EmailCaptionLbl)
                    {
                    }
                    column(BilltoCustNo_SalesHeaderCaption; "Sales Header".FieldCaption("Bill-to Customer No."))
                    {
                    }
                    column(PricesInclVAT_SalesHeaderCaption; "Sales Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    column(ShipToAddr8; ShipToAddr[8])
                    {
                    }
                    column(ShipToAddr7; ShipToAddr[7])
                    {
                    }
                    column(ShipToAddr6; ShipToAddr[6])
                    {
                    }
                    column(ShipToAddr5; ShipToAddr[5])
                    {
                    }
                    column(ShipToAddr4; ShipToAddr[4])
                    {
                    }
                    column(ShipToAddr3; ShipToAddr[3])
                    {
                    }
                    column(ShipToAddr2; ShipToAddr[2])
                    {
                    }
                    column(ShipToAddr1; ShipToAddr[1])
                    {
                    }
                    column(DeliveryToCaption; DeliveryToCaption)
                    {
                    }
                    column(InvoiceToCaption; InvoiceToCaption)
                    {
                    }
                    column(ShippingAgentCode_SalesLine; "Sales Header"."Shipping Agent Code")
                    {
                    }
                    column(ShippingAgentCodeLbl; ShippingAgentCodeLbl)
                    {
                    }
                    column(ExtDocNo_SalesHeader; "Sales Header"."External Document No.")
                    {
                    }
                    column(ExtDocNoLbl; ExtDocNoLbl)
                    {
                    }
                    column(CompanyInfoIBAN; CompanyInfo.IBAN)
                    {
                    }
                    column(CompanyInfoSWIFT; CompanyInfo."SWIFT Code")
                    {
                    }
                    column(CompanyInfoIBANLbl; CompanyInfo.FieldCaption(IBAN))
                    {
                    }
                    column(CompanyInfoSWIFTLbl; CompanyInfo.FieldCaption("SWIFT Code"))
                    {
                    }
                    column(CompanyInfoFax; CompanyInfo."Fax No.")
                    {
                    }
                    column(CompanyInfoFaxLbl; CompanyInfo.FieldCaption("Fax No."))
                    {
                    }
                    column(FooterNote; FooterNote)
                    {
                    }
                    column(FooterNote2; FooterNote2)
                    {
                    }
                    column(CompanyInfoCountry; CompanyInfo."Country/Region Code")
                    {
                    }
                    column(gCodCountryName; gCodCountryName)
                    {
                    }
                    column(VATNoLbl; VATNoLbl)
                    {
                    }
                    column(ShipFromLbl; ShipFromLbl)
                    {
                    }
                    column(CompanyInfoShipToName; CompanyInfo."Ship-to Name")
                    {
                    }
                    column(CompanyInfoShipToAddress; CompanyInfo."Ship-to Address")
                    {
                    }
                    column(CompanyInfoShipToAddress2; CompanyInfo."Ship-to Address 2")
                    {
                    }
                    column(CompanyInfoShipToCity; CompanyInfo."Ship-to City")
                    {
                    }
                    column(CompanyInfoShipToPostCode; CompanyInfo."Ship-to Post Code")
                    {
                    }
                    column(CompanyInfoShipToCountry; CompanyInfo."Ship-to Country/Region Code")
                    {
                    }
                    column(TxtFooter; gTxtFooter)
                    {
                    }
                    //RHE-TNA 28-01-2021 BDS-4908 BEGIN
                    column(EORI; EORI)
                    {

                    }
                    //RHE-TNA 28-01-2021 BDS-4908 END
                    //RHE-TNA 17-09-2021 BDS-5623 BEGIN
                    column(WhseShipmentNo; WhseShipmentNo)
                    {

                    }
                    //RHE-TNA 17-09-2021 BDS-5623 END                    
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(DimensionLoop1Number; Number)
                        {
                        }
                        column(HeaderDimCaption; HeaderDimCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not DimSetEntry1.Find('-') then
                                    CurrReport.Break;
                            end else
                                if not Continue then
                                    CurrReport.Break;

                            Clear(DimText);
                            Continue := false;
                            repeat
                                OldDimText := DimText;
                                if DimText = '' then
                                    DimText := StrSubstNo('%1 %2', DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code")
                                else
                                    DimText :=
                                      StrSubstNo(
                                        '%1, %2 %3', DimText,
                                        DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code");
                                if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                    DimText := OldDimText;
                                    Continue := true;
                                    exit;
                                end;
                            until DimSetEntry1.Next = 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowInternalInfo then
                                CurrReport.Break;
                        end;
                    }
                    dataitem("Sales Line"; "Sales Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");

                        trigger OnPreDataItem()
                        begin
                            CurrReport.Break;
                        end;
                    }
                    dataitem(RoundLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(UnitOfMeasureLbl; UnitOfMeasureLbl)
                        {
                        }
                        column(SalesLineAmt; SalesLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        //RHE-TNA 28-01-2022 BDS-6074 BEGIN
                        /*
                        column(Desc_SalesLine; "Sales Line".Description)
                        {
                        }
                        */
                        column(Desc_SalesLine; Description)
                        {

                        }
                        //RHE-TNA 28-01-2022 BDS-6074 END
                        column(NNCSalesLineLineAmt; NNCSalesLineLineAmt)
                        {
                        }
                        column(NNCSalesLineInvDiscAmt; NNCSalesLineInvDiscAmt)
                        {
                        }
                        column(NNCTotalLCY; NNCTotalLCY)
                        {
                        }
                        column(NNCTotalExclVAT; NNCTotalExclVAT)
                        {
                        }
                        column(NNCVATAmt; NNCVATAmt)
                        {
                        }
                        column(NNCTotalInclVAT; NNCTotalInclVAT)
                        {
                        }
                        column(NNCPmtDiscOnVAT; NNCPmtDiscOnVAT)
                        {
                        }
                        column(NNCTotalInclVAT2; NNCTotalInclVAT2)
                        {
                        }
                        column(NNCVATAmt2; NNCVATAmt2)
                        {
                        }
                        column(NNCTotalExclVAT2; NNCTotalExclVAT2)
                        {
                        }
                        column(VATBaseDisc_SalesHeader; "Sales Header"."VAT Base Discount %")
                        {
                        }
                        column(DisplayAssemblyInfo; DisplayAssemblyInformation)
                        {
                        }
                        column(ShowInternalInfo; ShowInternalInfo)
                        {
                        }
                        column(No2_SalesLine; "Sales Line"."No.")
                        {
                        }
                        column(Qty_SalesLine; "Sales Line".Quantity)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        //RHE-TNA 28-01-2022 BDS-6074 BEGIN
                        /*
                        column(UOM_SalesLine; "Sales Line"."Unit of Measure")
                        {
                        }
                        */
                        column(UOM_SalesLine; "Sales Line"."Unit of Measure Code")
                        {
                        }
                        //RHE-TNA 28-01-2022 BDS-6074 END
                        //RHE-TNA 22-12-2021 PM-1328 BEGIN
                        //column(UnitPrice_SalesLine; "Sales Line"."Unit Price")
                        column(UnitPrice_SalesLine; UnitPrice)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 2;
                            IncludeCaption = false;
                        }
                        //column(LineDisc_SalesLine; "Sales Line"."Line Discount %")
                        column(LineDisc_SalesLine; DiscountPerc)
                        {
                        }
                        //column(LineAmt_SalesLine; "Sales Line"."Line Amount")
                        column(LineAmt_SalesLine; LineAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        //RHE-TNA 22-12-2021 PM-1328 END
                        column(AllowInvDisc_SalesLine; "Sales Line"."Allow Invoice Disc.")
                        {
                        }
                        column(VATIdentifier_SalesLine; "Sales Line"."VAT Identifier")
                        {
                        }
                        column(Type_SalesLine; Format("Sales Line".Type))
                        {
                        }
                        column(No_SalesLine; "Sales Line"."Line No.")
                        {
                        }
                        column(AllowInvDiscountYesNo_SalesLine; Format("Sales Line"."Allow Invoice Disc."))
                        {
                        }
                        column(AsmInfoExistsForLine; AsmInfoExistsForLine)
                        {
                        }
                        column(SalesLineInvDiscAmt; SalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalText; TotalText)
                        {
                        }
                        column(SalsLinAmtExclLineDiscAmt; SalesLine."Line Amount" - SalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(VATAmtLineVATAmtText3; VATAmountLine.VATAmountText)
                        {
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(VATAmount; VATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(SalesLineAmtExclLineDisc; SalesLine."Line Amount" - SalesLine."Inv. Discount Amount" + VATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATDiscountAmount; VATDiscountAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseAmount; VATBaseAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmountInclVAT; TotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(DiscountPercentCaption; DiscountPercentCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(PaymentDiscountVATCaption; PaymentDiscountVATCaptionLbl)
                        {
                        }
                        column(Desc_SalesLineCaption; "Sales Line".FieldCaption(Description))
                        {
                        }
                        column(No2_SalesLineCaption; "Sales Line".FieldCaption("No."))
                        {
                        }
                        column(Qty_SalesLineCaption; "Sales Line".FieldCaption(Quantity))
                        {
                        }
                        column(UOM_SalesLineCaption; "Sales Line".FieldCaption("Unit of Measure"))
                        {
                        }
                        column(VATIdentifier_SalesLineCaption; "Sales Line".FieldCaption("VAT Identifier"))
                        {
                        }
                        //RHE-TNA 28-01-2022 BDS-6074 BEGIN
                        /*
                        column(Desc2_SalesLine; "Sales Line"."Description 2")
                        {
                        }
                        */
                        column(Desc2_SalesLine; Description2)
                        {

                        }
                        //RHE-TNA 28-01-2022 BDS-6074 END
                        column(gCodHSCode; gCodHSCode)
                        {
                        }
                        column(gCodCOO; gCodCOO)
                        {
                        }
                        column(HSCodeLbl; HSCodeLbl)
                        {
                        }
                        column(ItemLbl; ItemLbl)
                        {
                        }
                        column(TxtVat; gTxtVat)
                        {
                        }
                        column(QtyLbl; QtyLbl)
                        {
                        }
                        //RHE-TNA 25-05-2022 BDS-6364 BEGIN
                        column(PrintLine; SetPrintableLine("Sales Line"))
                        {

                        }
                        //RHE-TNA 25-05-2022 BDS-6364 END
                        dataitem(DimensionLoop2; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                            column(DimText2; DimText)
                            {
                            }
                            column(LineDimCaption; LineDimCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not DimSetEntry2.FindSet then
                                        CurrReport.Break;
                                end else
                                    if not Continue then
                                        CurrReport.Break;

                                Clear(DimText);
                                Continue := false;
                                repeat
                                    OldDimText := DimText;
                                    if DimText = '' then
                                        DimText := StrSubstNo('%1 %2', DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code")
                                    else
                                        DimText :=
                                          StrSubstNo(
                                            '%1, %2 %3', DimText,
                                            DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code");
                                    if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                        DimText := OldDimText;
                                        Continue := true;
                                        exit;
                                    end;
                                until DimSetEntry2.Next = 0;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowInternalInfo then
                                    CurrReport.Break;

                                DimSetEntry2.SetRange("Dimension Set ID", "Sales Line"."Dimension Set ID");
                            end;
                        }
                        dataitem(AsmLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(AsmLineType; AsmLine.Type)
                            {
                            }
                            column(AsmLineNo; BlanksForIndent + AsmLine."No.")
                            {
                            }
                            column(AsmLineDescription; BlanksForIndent + AsmLine.Description)
                            {
                            }
                            column(AsmLineQuantity; AsmLine.Quantity)
                            {
                            }
                            column(AsmLineUOMText; GetUnitOfMeasureDescr(AsmLine."Unit of Measure Code"))
                            {
                            }
                            //RHE-TNA 12-01-2022 BDS-5997 BEGIN
                            column(AsmLineUOMCode; AsmLine."Unit of Measure Code")
                            {

                            }
                            column(AsmLineHSCode; GetAssLineHSCode(AsmLine."No."))
                            {

                            }
                            column(AsmLineCoOCode; GetAssLineCoOCode(AsmLine."No."))
                            {

                            }
                            //RHE-TNA 12-01-2022 BDS-5997 END

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then
                                    AsmLine.FindSet
                                else
                                    AsmLine.Next;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not DisplayAssemblyInformation then
                                    CurrReport.Break;
                                if not AsmInfoExistsForLine then
                                    CurrReport.Break;
                                AsmLine.SetRange("Document Type", AsmHeader."Document Type");
                                AsmLine.SetRange("Document No.", AsmHeader."No.");
                                SetRange(Number, 1, AsmLine.Count);
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            VATBusPostingGroup: Record "VAT Business Posting Group";
                        begin
                            if Number = 1 then
                                SalesLine.Find('-')
                            else
                                SalesLine.Next;
                            //RHE-TNA 12-01-2022 BDS-5997 BEGIN
                            if SalesLine.Type = SalesLine.Type::"G/L Account" then
                                CurrReport.Skip();
                            //RHE-TNA 12-01-2022 BDS-5997 END
                            "Sales Line" := SalesLine;
                            if DisplayAssemblyInformation then
                                AsmInfoExistsForLine := SalesLine.AsmToOrderExists(AsmHeader);

                            if not "Sales Header"."Prices Including VAT" and
                               (SalesLine."VAT Calculation Type" = SalesLine."VAT Calculation Type"::"Full VAT")
                            then
                                SalesLine."Line Amount" := 0;

                            if (SalesLine.Type = SalesLine.Type::"G/L Account") and (not ShowInternalInfo) then
                                "Sales Line"."No." := '';

                            //RHE-TNA 22-12-2021 PM-1328 BEGIN
                            //NNCSalesLineLineAmt += SalesLine."Line Amount";
                            //NNCSalesLineInvDiscAmt += SalesLine."Inv. Discount Amount";
                            if SalesLine."Customs Price" > 0 then begin
                                NNCSalesLineLineAmt += SalesLine.Quantity * SalesLine."Customs Price";
                                NNCSalesLineInvDiscAmt += 0;
                            end else
                                if SalesLine."Line Amount" > 0 then begin
                                    NNCSalesLineLineAmt += SalesLine."Line Amount";
                                    NNCSalesLineInvDiscAmt += SalesLine."Inv. Discount Amount";
                                end else begin
                                    NNCSalesLineLineAmt += SalesLine.Quantity * SalesLine."Unit Cost";
                                    NNCSalesLineInvDiscAmt += 0;
                                end;
                            //RHE-TNA 22-12-2021 PM-1328 END

                            NNCTotalLCY := NNCSalesLineLineAmt - NNCSalesLineInvDiscAmt;

                            NNCTotalExclVAT := NNCTotalLCY;
                            //RHE-TNA 22-12-2021 PM-1328 BEGIN
                            //NNCVATAmt := VATAmount;
                            if SalesLine."Customs Price" > 0 then begin
                                if SalesLine."VAT Calculation Type" <> SalesLine."VAT Calculation Type"::"Reverse Charge VAT" then
                                    NNCVATAmt += (SalesLine.Quantity * SalesLine."Customs Price") * (SalesLine."VAT %" / 100);
                            end else
                                if SalesLine."Line Amount" > 0 then
                                    NNCVATAmt += SalesLine."Amount Including VAT" - SalesLine.Amount
                                else begin
                                    if SalesLine."VAT Calculation Type" <> SalesLine."VAT Calculation Type"::"Reverse Charge VAT" then
                                        NNCVATAmt += (SalesLine.Quantity * SalesLine."Unit Cost") * (SalesLine."VAT %" / 100);
                                end;
                            //RHE-TNA 22-12-2021 PM-1328 END
                            NNCTotalInclVAT := NNCTotalLCY - NNCVATAmt;

                            NNCPmtDiscOnVAT := -VATDiscountAmount;

                            NNCTotalInclVAT2 := TotalAmountInclVAT;

                            NNCVATAmt2 := VATAmount;
                            NNCTotalExclVAT2 := VATBaseAmount;

                            //RHE-TNA 12-01-2022 BDS-5997 BEGIN
                            //As the VATAmountLine table also contains VAT records for G/L Account line, we cannot use it
                            //gTxtVat := VATAmountLine.VATAmountText;
                            if Number = 1 then begin
                                gVATPerc := SalesLine."VAT %";
                                gTxtVat := Format(SalesLine."VAT %") + '% VAT';
                            end else
                                if gVATPerc <> SalesLine."VAT %" then
                                    gTxtVat := 'VAT Amount';
                            //RHE-TNA 12-01-2022 BDS-5997 END

                            //if (("Sales Header"."VAT Bus. Posting Group" = 'NON-EU B2B') or ("Sales Header"."VAT Bus. Posting Group" = 'NON-EU B2C')) then begin
                            //    gTxtVat := TxtVat1;
                            //    gTxtFooter := TxtFooter1;
                            //end;
                            //if "Sales Header"."VAT Bus. Posting Group" = 'EU B2B' then begin
                            //    gTxtVat := TxtVat2;
                            //    gTxtFooter := TxtFooter2;
                            //end;
                            //if "Sales Header"."VAT Bus. Posting Group" = 'NL 0%' then begin
                            //    gTxtVat := TxtVat3;
                            //    gTxtFooter := TxtFooter3;
                            //end;
                            if VATBusPostingGroup.Get("Sales Header"."VAT Bus. Posting Group") then begin
                                if VATBusPostingGroup."Order Confirmation Totals Text" <> '' then
                                    gTxtVat := VATBusPostingGroup."Order Confirmation Totals Text";
                                if VATBusPostingGroup."Order Confirmation Footer Text" <> '' then
                                    gTxtFooter := VATBusPostingGroup."Order Confirmation Footer Text";
                            end;
                            //RHE-TNA END

                            if gRecItem.Get("Sales Line"."No.") then
                                gCodHSCode := gRecItem."Tariff No."
                            else
                                gCodHSCode := '';

                            if gRecItem.Get("Sales Line"."No.") then
                                gCodCOO := gRecItem."Country/Region of Origin Code"
                            else
                                gCodCOO := '';

                            //RHE-TNA 22-12-2021 PM-1328 BEGIN
                            UnitPrice := 0;
                            DiscountPerc := 0;
                            LineAmount := 0;
                            if SalesLine."Customs Price" > 0 then begin
                                UnitPrice := SalesLine."Customs Price";
                                LineAmount := SalesLine.Quantity * SalesLine."Customs Price";
                            end else
                                if SalesLine."Unit Price" > 0 then begin
                                    UnitPrice := SalesLine."Unit Price";
                                    DiscountPerc := SalesLine."Line Discount %";
                                    LineAmount := SalesLine."Line Amount";
                                end else begin
                                    UnitPrice := SalesLine."Unit Cost";
                                    LineAmount := SalesLine.Quantity * SalesLine."Unit Cost";
                                end;
                            //RHE-TNA 22-12-2021 PM-1328 END

                            //RHE-TNA 28-01-2022 BDS-6074 BEGIN
                            if SalesLine.Type = SalesLine.Type::Item then begin
                                Description := gRecItem.Description;
                                Description2 := gRecItem."Description 2";
                            end else begin
                                Description := SalesLine.Description;
                                Description2 := SalesLine."Description 2";
                            end;
                            //RHE-TNA 28-01-2022 BDS-6074 END
                        end;

                        trigger OnPostDataItem()
                        begin
                            SalesLine.DeleteAll;
                        end;

                        trigger OnPreDataItem()
                        begin
                            MoreLines := SalesLine.Find('+');
                            while MoreLines and (SalesLine.Description = '') and (SalesLine."Description 2" = '') and
                                  (SalesLine."No." = '') and (SalesLine.Quantity = 0) and
                                  (SalesLine.Amount = 0)
                            do
                                MoreLines := SalesLine.Next(-1) <> 0;
                            if not MoreLines then
                                CurrReport.Break;
                            SalesLine.SetRange("Line No.", 0, SalesLine."Line No.");
                            SetRange(Number, 1, SalesLine.Count);
                            //CurrReport.CreateTotals(SalesLine."Line Amount",SalesLine."Inv. Discount Amount");

                            gTxtFooter := '';
                        end;
                    }
                    dataitem(VATCounter; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(VATAmountLineVATBase; VATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmt; VATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineLineAmt; VATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscBaseAmt; VATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscAmt; VATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATPercentage; VATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmtLineVATIdentifier; VATAmountLine."VAT Identifier")
                        {
                        }
                        column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
                        {
                        }
                        column(VATIdentifierCaption; VATIdentifierCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);


                            gTxtVat := VATAmountLine.VATAmountText;
                            if (("Sales Header"."VAT Bus. Posting Group" = 'NON-EU B2B') or ("Sales Header"."VAT Bus. Posting Group" = 'NON-EU B2C')) then
                                gTxtVat := '0% VAT (Export Supply)';
                            if "Sales Header"."VAT Bus. Posting Group" = 'EU B2B' then
                                gTxtVat := '0% VAT (IC Supply)';
                            if "Sales Header"."VAT Bus. Posting Group" = 'NL 0%' then
                                gTxtVat := '0% VAT (Reverse Charge)';
                        end;

                        trigger OnPreDataItem()
                        begin
                            if VATAmount = 0 then
                                CurrReport.Break;
                            SetRange(Number, 1, VATAmountLine.Count);
                            //CurrReport.CreateTotals(
                            //  VATAmountLine."Line Amount",VATAmountLine."Inv. Disc. Base Amount",
                            //  VATAmountLine."Invoice Discount Amount",VATAmountLine."VAT Base",VATAmountLine."VAT Amount");
                        end;
                    }
                    dataitem(VATCounterLCY; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(VALExchRate; VALExchRate)
                        {
                        }
                        column(VALSpecLCYHeader; VALSpecLCYHeader)
                        {
                        }
                        column(VALVATBaseLCY; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATAmountLCY; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATPercentage2; VATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmtLineVATIdentifier2; VATAmountLine."VAT Identifier")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                            VALVATBaseLCY :=
                              VATAmountLine.GetBaseLCY(
                                "Sales Header"."Posting Date", "Sales Header"."Currency Code", "Sales Header"."Currency Factor");
                            VALVATAmountLCY :=
                              VATAmountLine.GetAmountLCY(
                                "Sales Header"."Posting Date", "Sales Header"."Currency Code", "Sales Header"."Currency Factor");
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GLSetup."Print VAT specification in LCY") or
                               ("Sales Header"."Currency Code" = '') or
                               (VATAmountLine.GetTotalVATAmount = 0)
                            then
                                CurrReport.Break;

                            SetRange(Number, 1, VATAmountLine.Count);
                            //CurrReport.CreateTotals(VALVATBaseLCY,VALVATAmountLCY);

                            if GLSetup."LCY Code" = '' then
                                VALSpecLCYHeader := Text007 + Text008
                            else
                                VALSpecLCYHeader := Text007 + Format(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency("Sales Header"."Posting Date", "Sales Header"."Currency Code", 1);
                            VALExchRate := StrSubstNo(Text009, CurrExchRate."Relational Exch. Rate Amount", CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem(Total2; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                        column(SelltoCustNo_SalesHeader; "Sales Header"."Sell-to Customer No.")
                        {
                        }
                        column(ShiptoAddrCaption; ShiptoAddrCaptionLbl)
                        {
                        }
                        column(SelltoCustNo_SalesHeaderCaption; "Sales Header".FieldCaption("Sell-to Customer No."))
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if not ShowShippingAddr then
                                CurrReport.Break;
                        end;
                    }
                    dataitem(PrepmtLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                        column(PrepmtLineAmount; PrepmtLineAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtInvBufDesc; PrepmtInvBuf.Description)
                        {
                        }
                        column(PrepmtInvBufGLAccNo; PrepmtInvBuf."G/L Account No.")
                        {
                        }
                        column(TotalExclVATText2; TotalExclVATText)
                        {
                        }
                        column(PrepmtVATAmtLineVATAmtTxt; PrepmtVATAmountLine.VATAmountText)
                        {
                        }
                        column(TotalInclVATText2; TotalInclVATText)
                        {
                        }
                        column(PrepmtInvAmount; PrepmtInvBuf.Amount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmount; PrepmtVATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtInvAmtInclVATAmt; PrepmtInvBuf.Amount + PrepmtVATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmtText2; VATAmountLine.VATAmountText)
                        {
                        }
                        column(PrepmtTotalAmountInclVAT; PrepmtTotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATBaseAmount; PrepmtVATBaseAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtLoopNumber; Number)
                        {
                        }
                        column(DescriptionCaption; DescriptionCaptionLbl)
                        {
                        }
                        column(GLAccountNoCaption; GLAccountNoCaptionLbl)
                        {
                        }
                        column(PrepaymentSpecCaption; PrepaymentSpecCaptionLbl)
                        {
                        }
                        dataitem(PrepmtDimLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                            column(DimText3; DimText)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not TempPrepmtDimSetEntry.Find('-') then
                                        CurrReport.Break;
                                end else
                                    if not Continue then
                                        CurrReport.Break;

                                Clear(DimText);
                                Continue := false;
                                repeat
                                    OldDimText := DimText;
                                    if DimText = '' then
                                        DimText :=
                                          StrSubstNo('%1 %2', TempPrepmtDimSetEntry."Dimension Code", TempPrepmtDimSetEntry."Dimension Value Code")
                                    else
                                        DimText :=
                                          StrSubstNo(
                                            '%1, %2 %3', DimText,
                                            TempPrepmtDimSetEntry."Dimension Code", TempPrepmtDimSetEntry."Dimension Value Code");
                                    if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                        DimText := OldDimText;
                                        Continue := true;
                                        exit;
                                    end;
                                until TempPrepmtDimSetEntry.Next = 0;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not PrepmtInvBuf.Find('-') then
                                    CurrReport.Break;
                            end else
                                if PrepmtInvBuf.Next = 0 then
                                    CurrReport.Break;

                            if ShowInternalInfo then
                                DimMgt.GetDimensionSet(TempPrepmtDimSetEntry, PrepmtInvBuf."Dimension Set ID");

                            if "Sales Header"."Prices Including VAT" then
                                PrepmtLineAmount := PrepmtInvBuf."Amount Incl. VAT"
                            else
                                PrepmtLineAmount := PrepmtInvBuf.Amount;
                        end;

                        trigger OnPreDataItem()
                        begin
                            //CurrReport.CreateTotals(
                            //  PrepmtInvBuf.Amount,PrepmtInvBuf."Amount Incl. VAT",
                            //  PrepmtVATAmountLine."Line Amount",PrepmtVATAmountLine."VAT Base",
                            //  PrepmtVATAmountLine."VAT Amount",
                            //  PrepmtLineAmount);
                        end;
                    }
                    dataitem(PrepmtVATCounter; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(PrepmtVATAmtLineVATAmt; PrepmtVATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmtLineVATBase; PrepmtVATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmtLineLineAmt; PrepmtVATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PrepmtVATAmtLineVATPerc; PrepmtVATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(PrepmtVATAmtLineVATIdent; PrepmtVATAmountLine."VAT Identifier")
                        {
                        }
                        column(PrepmtVATCounterNumber; Number)
                        {
                        }
                        column(PrepaymentVATAmtSpecCap; PrepaymentVATAmtSpecCapLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            PrepmtVATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number, 1, PrepmtVATAmountLine.Count);
                        end;
                    }
                    dataitem(PrepmtTotal; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                        column(PrepmtPmtTermsDesc; PrepmtPaymentTerms.Description)
                        {
                        }
                        column(PrepmtPmtTermsDescCaption; PrepmtPmtTermsDescCaptionLbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if not PrepmtInvBuf.Find('-') then
                                CurrReport.Break;
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                var
                    PrepmtSalesLine: Record "Sales Line" temporary;
                    SalesPost: Codeunit "Sales-Post";
                    TempSalesLine: Record "Sales Line" temporary;
                begin
                    Clear(SalesLine);
                    Clear(SalesPost);
                    VATAmountLine.DeleteAll;
                    SalesLine.DeleteAll;
                    SalesPost.GetSalesLines("Sales Header", SalesLine, 0);
                    SalesLine.CalcVATAmountLines(0, "Sales Header", SalesLine, VATAmountLine);
                    SalesLine.UpdateVATOnLines(0, "Sales Header", SalesLine, VATAmountLine);
                    VATAmount := VATAmountLine.GetTotalVATAmount;
                    VATBaseAmount := VATAmountLine.GetTotalVATBase;
                    VATDiscountAmount :=
                      VATAmountLine.GetTotalVATDiscount("Sales Header"."Currency Code", "Sales Header"."Prices Including VAT");
                    TotalAmountInclVAT := VATAmountLine.GetTotalAmountInclVAT;

                    PrepmtInvBuf.DeleteAll;
                    SalesPostPrepmt.GetSalesLines("Sales Header", 0, PrepmtSalesLine);

                    if not PrepmtSalesLine.IsEmpty then begin
                        SalesPostPrepmt.GetSalesLinesToDeduct("Sales Header", TempSalesLine);
                        if not TempSalesLine.IsEmpty then
                            SalesPostPrepmt.CalcVATAmountLines("Sales Header", TempSalesLine, PrepmtVATAmountLineDeduct, 1);
                    end;
                    SalesPostPrepmt.CalcVATAmountLines("Sales Header", PrepmtSalesLine, PrepmtVATAmountLine, 0);
                    PrepmtVATAmountLine.DeductVATAmountLine(PrepmtVATAmountLineDeduct);
                    SalesPostPrepmt.UpdateVATOnLines("Sales Header", PrepmtSalesLine, PrepmtVATAmountLine, 0);
                    SalesPostPrepmt.BuildInvLineBuffer2("Sales Header", PrepmtSalesLine, 0, PrepmtInvBuf);
                    PrepmtVATAmount := PrepmtVATAmountLine.GetTotalVATAmount;
                    PrepmtVATBaseAmount := PrepmtVATAmountLine.GetTotalVATBase;
                    PrepmtTotalAmountInclVAT := PrepmtVATAmountLine.GetTotalAmountInclVAT;

                    if Number > 1 then begin
                        CopyText := Text003;
                        OutputNo += 1;
                    end;
                    //CurrReport.PageNo := 1;

                    NNCTotalLCY := 0;
                    NNCTotalExclVAT := 0;
                    NNCVATAmt := 0;
                    NNCTotalInclVAT := 0;
                    NNCPmtDiscOnVAT := 0;
                    NNCTotalInclVAT2 := 0;
                    NNCVATAmt2 := 0;
                    NNCTotalExclVAT2 := 0;
                    NNCSalesLineLineAmt := 0;
                    NNCSalesLineInvDiscAmt := 0;
                end;

                trigger OnPostDataItem()
                begin
                    if Print then
                        SalesCountPrinted.Run("Sales Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            var
                Country: Record "Country/Region";
                IoRCustomer: Record Customer;
                WhseShipmentLine: Record "Warehouse Shipment Line";
            begin
                CompanyInfo.Get;
                CurrReport.Language := Language.GetLanguageID("Language Code");

                //RHE-TNA 12-01-2022 BDS-5997 BEGIN
                //If document is printed via Sales Order function "Save PDF Customs Invoice" then check if header was set with print components
                if not DisplayAssemblyInformation then
                    if "Print Assembly Comp." then
                        DisplayAssemblyInformation := true;
                //RHE-TNA 12-01-2022 BDS-5997 END

                if RespCenter.Get("Responsibility Center") then begin
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                    FormatAddr.Company(CompanyAddr, CompanyInfo);

                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");

                if "Salesperson Code" = '' then begin
                    Clear(SalesPurchPerson);
                    SalesPersonText := '';
                end else begin
                    SalesPurchPerson.Get("Salesperson Code");
                    SalesPersonText := Text000;
                end;
                if "Your Reference" = '' then
                    ReferenceText := ''
                else
                    ReferenceText := FieldCaption("Your Reference");
                if "VAT Registration No." = '' then
                    VATNoText := ''
                else
                    VATNoText := FieldCaption("VAT Registration No.");
                if "Currency Code" = '' then begin
                    GLSetup.TestField("LCY Code");
                    TotalText := StrSubstNo(Text001, GLSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(Text002, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(Text006, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(Text001, "Currency Code");
                    TotalInclVATText := StrSubstNo(Text002, "Currency Code");
                    TotalExclVATText := StrSubstNo(Text006, "Currency Code");
                end;
                //RHE-TNA 28-01-2021 BDS-4908 BEGIN
                EORI := '';
                //RHE-TNA 28-01-2021 BDS-4908 END
                FormatAddr.SalesHeaderBillTo(CustAddr, "Sales Header");
                //RHE-TNA 18-12-2020 BDS-4798 BEGIN
                if Country.Get("Sales Header"."Ship-to Country/Region Code") then begin
                    //RHE-TNA 28-01-2021 BDS-4908 BEGIN
                    EORI := Country."EORI No.";
                    //RHE-TNA 28-01-2021 BDS-4908 ENDs
                    if (Country."Importer of Record" <> '') then begin
                        IoRCustomer.Get(Country."Importer of Record");
                        FormatAddr.Customer(CustAddr, IoRCustomer);
                    end;
                end;
                //RHE-TNA 18-12-2020 BDS-4798 END

                if "Payment Terms Code" = '' then
                    PaymentTerms.Init
                else begin
                    PaymentTerms.Get("Payment Terms Code");
                    PaymentTerms.TranslateDescription(PaymentTerms, "Language Code");
                end;
                if "Prepmt. Payment Terms Code" = '' then
                    PrepmtPaymentTerms.Init
                else begin
                    PrepmtPaymentTerms.Get("Prepmt. Payment Terms Code");
                    PrepmtPaymentTerms.TranslateDescription(PrepmtPaymentTerms, "Language Code");
                end;
                if "Prepmt. Payment Terms Code" = '' then
                    PrepmtPaymentTerms.Init
                else begin
                    PrepmtPaymentTerms.Get("Prepmt. Payment Terms Code");
                    PrepmtPaymentTerms.TranslateDescription(PrepmtPaymentTerms, "Language Code");
                end;
                if "Shipment Method Code" = '' then
                    ShipmentMethod.Init
                else begin
                    ShipmentMethod.Get("Shipment Method Code");
                    ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                end;

                FormatAddr.SalesHeaderShipTo(ShipToAddr, CustAddr, "Sales Header");
                ShowShippingAddr := "Sell-to Customer No." <> "Bill-to Customer No.";
                for i := 1 to ArrayLen(ShipToAddr) do
                    if ShipToAddr[i] <> CustAddr[i] then
                        ShowShippingAddr := true;

                if Print then begin
                    if ArchiveDocument then
                        ArchiveManagement.StoreSalesDocument("Sales Header", LogInteraction);

                    if LogInteraction then begin
                        CalcFields("No. of Archived Versions");
                        if "Bill-to Contact No." <> '' then
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Contact, "Bill-to Contact No."
                              , "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.")
                        else
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Customer, "Bill-to Customer No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
                    end;
                end;


                if gRecCountry.Get(CompanyInfo."Country/Region Code") then
                    gCodCountryName := gRecCountry.Name
                else
                    gCodCountryName := '';

                //RHE-TNA 17-09-2021 BDS-5623 BEGIN
                WhseShipmentNo := '';
                WhseShipmentLine.Reset();
                WhseShipmentLine.SetRange("Source Type", 37);
                WhseShipmentLine.SetRange("Source Subtype", 1);
                WhseShipmentLine.SetRange("Source No.", "No.");
                if WhseShipmentLine.FindFirst() then
                    WhseShipmentNo := WhseShipmentLine."No.";
                //RHE-TNA 17-09-2021 BDS-5623 END
            end;

            trigger OnPreDataItem()
            begin
                Print := Print or not CurrReport.Preview;
                AsmInfoExistsForLine := false;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoOfCopies; NoOfCopies)
                    {
                        Caption = 'No. of Copies';
                    }
                    field(ShowInternalInfo; ShowInternalInfo)
                    {
                        Caption = 'Show Internal Information';
                    }
                    field(ArchiveDocument; ArchiveDocument)
                    {
                        Caption = 'Archive Document';

                        trigger OnValidate()
                        begin
                            if not ArchiveDocument then
                                LogInteraction := false;
                        end;
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;

                        trigger OnValidate()
                        begin
                            if LogInteraction then
                                ArchiveDocument := ArchiveDocumentEnable;
                        end;
                    }
                    field(ShowAssemblyComponents; DisplayAssemblyInformation)
                    {
                        Caption = 'Show Assembly Components';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            //ArchiveDocument := SalesSetup."Archive Quotes and Orders";
            LogInteraction := SegManagement.FindInteractTmplCode(3) <> '';

            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get;

        SalesSetup.Get;

        case SalesSetup."Logo Position on Documents" of
            SalesSetup."Logo Position on Documents"::"No Logo":
                ;
            SalesSetup."Logo Position on Documents"::Left:
                begin
                    CompanyInfo3.Get;
                    CompanyInfo3.CalcFields(Picture);
                end;
            SalesSetup."Logo Position on Documents"::Center:
                begin
                    CompanyInfo1.Get;
                    CompanyInfo1.CalcFields(Picture);
                end;
            SalesSetup."Logo Position on Documents"::Right:
                begin
                    CompanyInfo2.Get;
                    CompanyInfo2.CalcFields(Picture);
                end;
        end;
    end;

    //RHE-TNA 12-01-2022 BDS-5997 BEGIN
    trigger OnPostReport()
    begin
        "Sales Header".Validate("Print Assembly Comp.", false);
        "Sales Header".Modify(false);
    end;
    //RHE-TNA 12-01-2022 BDS-5997 END

    var
        Text000: Label 'Sales rep';
        //RHE-TNA 19-11-2021 BDS-5858 BEGIN
        SalesRepPhoneNoLbl: Label 'Phone No.';
        SalesRepEmailLbl: Label 'E-mail';
        //RHE-TNA 19-11-2021 BDS-5858 END
        Text001: Label 'Total %1';
        Text002: Label 'Total %1 Incl. VAT';
        Text003: Label 'COPY';
        Text004: Label 'Customs Invoice%1';
        PageCaptionCap: Label 'Page %1 of %2';
        Text006: Label 'Total %1 Excl. VAT';
        GLSetup: Record "General Ledger Setup";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        PrepmtPaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInfo: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        VATAmountLine: Record "VAT Amount Line" temporary;
        PrepmtVATAmountLine: Record "VAT Amount Line" temporary;
        PrepmtVATAmountLineDeduct: Record "VAT Amount Line" temporary;
        SalesLine: Record "Sales Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        TempPrepmtDimSetEntry: Record "Dimension Set Entry" temporary;
        PrepmtInvBuf: Record "Prepayment Inv. Line Buffer" temporary;
        RespCenter: Record "Responsibility Center";
        Language: Record Language;
        CurrExchRate: Record "Currency Exchange Rate";
        AsmHeader: Record "Assembly Header";
        AsmLine: Record "Assembly Line";
        SalesCountPrinted: Codeunit "Sales-Printed";
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        ArchiveManagement: Codeunit ArchiveManagement;
        SalesPostPrepmt: Codeunit "Sales-Post Prepayments";
        DimMgt: Codeunit DimensionManagement;
        CustAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        CompanyAddr: array[8] of Text[50];
        SalesPersonText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        TotalText: Text[50];
        TotalExclVATText: Text[50];
        TotalInclVATText: Text[50];
        MoreLines: Boolean;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        ShowShippingAddr: Boolean;
        i: Integer;
        DimText: Text[120];
        OldDimText: Text[75];
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        ArchiveDocument: Boolean;
        LogInteraction: Boolean;
        VATAmount: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        Text007: Label 'VAT Amount Specification in ';
        Text008: Label 'Local Currency';
        Text009: Label 'Exchange rate: %1/%2';
        VALExchRate: Text[50];
        PrepmtVATAmount: Decimal;
        PrepmtVATBaseAmount: Decimal;
        PrepmtTotalAmountInclVAT: Decimal;
        PrepmtLineAmount: Decimal;
        OutputNo: Integer;
        NNCTotalLCY: Decimal;
        NNCTotalExclVAT: Decimal;
        NNCVATAmt: Decimal;
        NNCTotalInclVAT: Decimal;
        NNCPmtDiscOnVAT: Decimal;
        NNCTotalInclVAT2: Decimal;
        NNCVATAmt2: Decimal;
        NNCTotalExclVAT2: Decimal;
        NNCSalesLineLineAmt: Decimal;
        NNCSalesLineInvDiscAmt: Decimal;
        Print: Boolean;
        [InDataSet]
        ArchiveDocumentEnable: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        DisplayAssemblyInformation: Boolean;
        AsmInfoExistsForLine: Boolean;
        InvDiscAmtCaptionLbl: Label 'Invoice Discount Amount';
        VATRegNoCaptionLbl: Label 'VAT Registration No.';
        GiroNoCaptionLbl: Label 'Giro No.';
        BankCaptionLbl: Label 'Bank Information';
        AccountNoCaptionLbl: Label 'Account No.';
        ShipmentDateCaptionLbl: Label 'Shipment Date';
        OrderNoCaptionLbl: Label 'Order No.';
        HomePageCaptionCap: Label 'Home Page';
        EmailCaptionLbl: Label 'E-Mail';
        HeaderDimCaptionLbl: Label 'Header Dimensions';
        DiscountPercentCaptionLbl: Label 'Disc.%';
        SubtotalCaptionLbl: Label 'Subtotal';
        PaymentDiscountVATCaptionLbl: Label 'Payment Discount on VAT';
        LineDimCaptionLbl: Label 'Line Dimensions';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        ShiptoAddrCaptionLbl: Label 'Ship-to Address';
        DescriptionCaptionLbl: Label 'Description';
        GLAccountNoCaptionLbl: Label 'G/L Account No.';
        PrepaymentSpecCaptionLbl: Label 'Prepayment Specification';
        PrepaymentVATAmtSpecCapLbl: Label 'Prepayment VAT Amount Specification';
        PrepmtPmtTermsDescCaptionLbl: Label 'Prepmt. Payment Terms';
        PhoneNoCaptionLbl: Label 'Phone No.';
        AmountCaptionLbl: Label 'Amount';
        VATPercentageCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmtCaptionLbl: Label 'VAT Amount';
        VATAmtSpecCaptionLbl: Label 'VAT Amount Specification';
        LineAmtCaptionLbl: Label 'Line Amount';
        TotalCaptionLbl: Label 'Total';
        UnitPriceCaptionLbl: Label 'Unit Price';
        PaymentTermsCaptionLbl: Label 'Payment Terms';
        ShipmentMethodCaptionLbl: Label 'Freight Terms';
        DocumentDateCaptionLbl: Label 'Order Date';
        AllowInvDiscCaptionLbl: Label 'Allow Invoice Discount';
        DeliveryToCaption: Label 'Delivery To:';
        ShippingAgentCodeLbl: Label 'Carrier';
        ExtDocNoLbl: Label 'Ext. Document No.';
        UnitOfMeasureLbl: Label 'UOM';
        InvoiceToCaption: Label 'Invoice To:';
        HSCodeLbl: Label 'HS Code';
        ItemLbl: Label 'Item';
        gRecItem: Record Item;
        gCodHSCode: Code[10];
        FooterNote: Label 'VALUE FOR CUSTOMS PURPOSES ONLY';
        gRecCountry: Record "Country/Region";
        gCodCountryName: Text;
        FooterNote2: Label '0% Dutch VAT - Export supply (Article 146 EU VAT Directive Applies)';
        VATNoLbl: Label 'VAT Reg. No.';
        ShipFromLbl: Label 'Ship From:';
        gTxtVat: Text;
        //RHE-TNA 12-01-2022 BDS-5997 BEGIN
        gVATPerc: Decimal;
        //RHE-TNA 12-01-2022 BDS-5997 END
        gTxtFooter: Text;
        TxtVat1: Label '0% VAT (Export Supply)';
        TxtVat2: Label '0% VAT (IC-supply)';
        TxtVat3: Label '0% VAT (Reverse Charge)';
        TxtFooter1: Label '0% Dutch VAT - Export supply (Article 146 EU VAT Directive Applies)';
        TxtFooter2: Label '0% Dutch VAT - IC-supply (Article 138 VAT Directive)';
        TxtFooter3: Label '0% Dutch VAT - Reverse Charge (VAT shifted to customer, Article 12-3, Dutch VAT Act)';
        QtyLbl: Label 'Qty';
        gCodCOO: Code[10];
        //RHE-TNA 28-01-2021 BDS-4908 BEGIN
        EORI: Text[20];
        //RHE-TNA 28-01-2021 BDS-4908 END
        //RHE-TNA 17-09-2021 BDS-5623 BEGIN
        WhseShipmentNo: Code[20];
        //RHE-TNA 17-09-2021 BDS-5623 END
        //RHE-TNA 22-12-2021 PM-1328 BEGIN
        UnitPrice: Decimal;
        DiscountPerc: Decimal;
        LineAmount: Decimal;
        //RHE-TNA 22-12-2021 PM-1328 END
        Description: Text[100];
        Description2: Text[50];


    procedure InitializeRequest(NoOfCopiesFrom: Integer; ShowInternalInfoFrom: Boolean; ArchiveDocumentFrom: Boolean; LogInteractionFrom: Boolean; PrintFrom: Boolean; DisplayAsmInfo: Boolean)
    begin
        NoOfCopies := NoOfCopiesFrom;
        ShowInternalInfo := ShowInternalInfoFrom;
        ArchiveDocument := ArchiveDocumentFrom;
        LogInteraction := LogInteractionFrom;
        Print := PrintFrom;
        DisplayAssemblyInformation := DisplayAsmInfo;
    end;

    procedure GetUnitOfMeasureDescr(UOMCode: Code[10]): Text[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.Get(UOMCode) then
            exit(UOMCode);
        exit(UnitOfMeasure.Description);
    end;

    procedure BlanksForIndent(): Text[10]
    begin
        exit(PadStr('', 2, ' '));
    end;

    //RHE-TNA 12-01-2022 BDS-5997 BEGIN
    procedure GetAssLineHSCode(ItemNo: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then
            exit(Item."Tariff No.")
        else
            exit('');
    end;

    procedure GetAssLineCoOCode(ItemNo: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then
            exit(Item."Country/Region of Origin Code")
        else
            exit('');
    end;
    //RHE-TNA 12-01-2022 BDS-5997 END

    //RHE-TNA 25-05-2022 BDS-6364 BEGIN
    // procedure SetPrintableLine(SalesLineToCheck: Record "Sales Line"): Boolean
    // var
    //     Item: Record Item;
    // begin
    //     if SalesLineToCheck.Type = SalesLineToCheck.Type::Item then begin
    //         Item.Get(SalesLineToCheck."No.");
    //         if Item.ExclItemPrint = false then
    //             exit(true)
    //         else
    //             if SalesLineToCheck."Line Amount" <> 0 then
    //                 exit(true)
    //             else
    //                 exit(false);
    //     end else
    //         exit(true);
    // end;
    // //RHE-TNA 25-05-2022 BDS-6364 END

    procedure SetPrintableLine(SalesLineToCheck: Record "Sales Line"): Boolean
    var
        Item: Record Item;
    begin
        if SalesLineToCheck.Type = SalesLineToCheck.Type::Item then begin
            Item.Get(SalesLineToCheck."No.");
            // if Item.ExclItemPrint = false then
            //     exit(true)
            if Item.ExclItemPrint = true then
                exit(false)
            else
                //  if SalesLineToCheck."Line Amount" then
                if SalesLineToCheck."Line Amount" <> 0 then
                    exit(true)
                //RHE-AMKE 09-08-2022 BDS-6542 END
                else
                    exit(false);
        end else
            exit(true);
    end;
}

