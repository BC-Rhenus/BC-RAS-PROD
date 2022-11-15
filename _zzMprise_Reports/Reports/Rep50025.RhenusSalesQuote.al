report 50025 "Rhenus Sales - Quote"
{
    // version NAVW18.00

    DefaultLayout = RDLC;
    RDLCLayout = './Rhenus Sales - Quote.rdlc';
    Caption = 'Sales - Quote';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Sales Header";"Sales Header")
        {
            DataItemTableView = SORTING("Document Type","No.") WHERE("Document Type"=CONST(Quote));
            RequestFilterFields = "No.","Sell-to Customer No.","No. Printed";
            RequestFilterHeading = 'Quote';
            column(DocType_SalesHeader;"Document Type")
            {
            }
            column(No_SalesHeader;"No.")
            {
            }
            column(SalesLineVATIdentifierCaption;SalesLineVATIdentifierCaptionLbl)
            {
            }
            column(PaymentTermsDescriptionCaption;PaymentTermsDescriptionCaptionLbl)
            {
            }
            column(ShipmentMethodDescriptionCaption;ShipmentMethodDescriptionCaptionLbl)
            {
            }
            column(CompanyInfoHomePageCaption;CompanyInfoHomePageCaptionLbl)
            {
            }
            column(CompanyInfoEmailCaption;CompanyInfoEmailCaptionLbl)
            {
            }
            column(DocumentDateCaption;DocumentDateCaptionLbl)
            {
            }
            column(SalesLineAllowInvoiceDiscCaption;SalesLineAllowInvoiceDiscCaptionLbl)
            {
            }
            column(RepairText;RepairText)
            {
            }
            dataitem(CopyLoop;"Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop;"Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                    column(CompanyIBAN;CompanyInfo.IBAN)
                    {
                    }
                    column(CompanyIBANLbl;CompanyInfo.FieldCaption(IBAN))
                    {
                    }
                    column(CompanySWIFT;CompanyInfo."SWIFT Code")
                    {
                    }
                    column(CompanySWIFTLbl;CompanyInfo.FieldCaption("SWIFT Code"))
                    {
                    }
                    column(CompanyInfo2Picture;CompanyInfo2.Picture)
                    {
                    }
                    column(PaymentTermsDescription;PaymentTerms.Description)
                    {
                    }
                    column(ShipmentMethodDescription;ShipmentMethod.Description)
                    {
                    }
                    column(CompanyInfo3Picture;CompanyInfo3.Picture)
                    {
                    }
                    column(CompanyInfo1Picture;CompanyInfo1.Picture)
                    {
                    }
                    column(SalesCopyText;StrSubstNo(Text004,CopyText))
                    {
                    }
                    column(CustAddr1;CustAddr[1])
                    {
                    }
                    column(CompanyAddr1;CompanyAddr[1])
                    {
                    }
                    column(CustAddr2;CustAddr[2])
                    {
                    }
                    column(CompanyAddr2;CompanyAddr[2])
                    {
                    }
                    column(CustAddr3;CustAddr[3])
                    {
                    }
                    column(CompanyAddr3;CompanyAddr[3])
                    {
                    }
                    column(CustAddr4;CustAddr[4])
                    {
                    }
                    column(CompanyAddr4;CompanyAddr[4])
                    {
                    }
                    column(CustAddr5;CustAddr[5])
                    {
                    }
                    column(CompanyInfoEmail;CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoHomePage;CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoPhoneNo;CompanyInfo."Phone No.")
                    {
                    }
                    column(CustAddr6;CustAddr[6])
                    {
                    }
                    column(CompanyInfoVATRegNo;CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoGiroNo;CompanyInfo."Giro No.")
                    {
                    }
                    column(CompanyInfoBankName;CompanyInfo."Bank Name")
                    {
                    }
                    column(CompanyInfoBankAccountNo;CompanyInfo."Bank Account No.")
                    {
                    }
                    column(BilltoCustNo_SalesHeader;"Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(DocDate_SalesHeader;Format("Sales Header"."Document Date",0,4))
                    {
                    }
                    column(VATNoText;VATNoText)
                    {
                    }
                    column(VATRegNo_SalesHeader;"Sales Header"."VAT Registration No.")
                    {
                    }
                    column(ShipmentDate_SalesHeader;Format("Sales Header"."Shipment Date"))
                    {
                    }
                    column(SalesPersonText;SalesPersonText)
                    {
                    }
                    column(SalesPurchPersonName;SalesPurchPerson.Name)
                    {
                    }
                    column(No1_SalesHeader;"Sales Header"."No.")
                    {
                    }
                    column(ReferenceText;ReferenceText)
                    {
                    }
                    column(YourReference_SalesHeader;"Sales Header"."Your Reference")
                    {
                    }
                    column(CustAddr7;CustAddr[7])
                    {
                    }
                    column(CustAddr8;CustAddr[8])
                    {
                    }
                    column(CompanyAddr5;CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr6;CompanyAddr[6])
                    {
                    }
                    column(PricesIncludingVAT_SalesHdr;"Sales Header"."Prices Including VAT")
                    {
                    }
                    column(PageCaption;StrSubstNo(Text005,''))
                    {
                    }
                    column(OutputNo;OutputNo)
                    {
                    }
                    column(PricesInclVATYesNo_SalesHdr;Format("Sales Header"."Prices Including VAT"))
                    {
                    }
                    column(CompanyInfoPhoneNoCaption;CompanyInfoPhoneNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoVATRegNoCaption;CompanyInfoVATRegNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoGiroNoCaption;CompanyInfoGiroNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoBankNameCaption;CompanyInfoBankNameCaptionLbl)
                    {
                    }
                    column(CompanyInfoBankAccountNoCaption;CompanyInfoBankAccountNoCaptionLbl)
                    {
                    }
                    column(SalesHeaderShipmentDateCaption;SalesHeaderShipmentDateCaptionLbl)
                    {
                    }
                    column(SalesHeaderNoCaption;SalesHeaderNoCaptionLbl)
                    {
                    }
                    column(BilltoCustNo_SalesHeaderCaption;"Sales Header".FieldCaption("Bill-to Customer No."))
                    {
                    }
                    column(PricesIncludingVAT_SalesHdrCaption;"Sales Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    column(gTxtVat;gTxtVat)
                    {
                    }
                    column(gTxtFooter;gTxtFooter)
                    {
                    }
                    dataitem(DimensionLoop1;"Integer")
                    {
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = SORTING(Number) WHERE(Number=FILTER(1..));
                        column(DimText;DimText)
                        {
                        }
                        column(HeaderDimensionsCaption;HeaderDimensionsCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                              if not DimSetEntry1.FindSet then
                                CurrReport.Break;
                            end else
                              if not Continue then
                                CurrReport.Break;

                            Clear(DimText);
                            Continue := false;
                            repeat
                              OldDimText := DimText;
                              if DimText = '' then
                                DimText := StrSubstNo('%1 %2',DimSetEntry1."Dimension Code",DimSetEntry1."Dimension Value Code")
                              else
                                DimText :=
                                  StrSubstNo(
                                    '%1, %2 %3',DimText,DimSetEntry1."Dimension Code",DimSetEntry1."Dimension Value Code");
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
                    dataitem("Sales Line";"Sales Line")
                    {
                        DataItemLink = "Document Type"=FIELD("Document Type"),"Document No."=FIELD("No.");
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = SORTING("Document Type","Document No.","Line No.");

                        trigger OnPreDataItem()
                        begin
                            CurrReport.Break;
                        end;
                    }
                    dataitem(RoundLoop;"Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(LineAmt_SalesLine;SalesLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(No_SalesLine;"Sales Line"."No.")
                        {
                        }
                        column(Desc_SalesLine;"Sales Line".Description)
                        {
                        }
                        column(Quantity_SalesLine;"Sales Line".Quantity)
                        {
                        }
                        column(UnitofMeasure_SalesLine;"Sales Line"."Unit of Measure")
                        {
                        }
                        column(LineAmt1_SalesLine;"Sales Line"."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(UnitPrice_SalesLine;"Sales Line"."Unit Price")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 2;
                        }
                        column(LineDiscount_SalesLine;"Sales Line"."Line Discount %")
                        {
                        }
                        column(AllowInvoiceDisc_SalesLine;"Sales Line"."Allow Invoice Disc.")
                        {
                            IncludeCaption = false;
                        }
                        column(VATIdentifier_SalesLine;"Sales Line"."VAT Identifier")
                        {
                        }
                        column(Type_SalesLine;Format("Sales Line".Type))
                        {
                        }
                        column(No1_SalesLine;"Sales Line"."Line No.")
                        {
                        }
                        column(AllowInvoiceDisYesNo;Format("Sales Line"."Allow Invoice Disc."))
                        {
                        }
                        column(InvDiscountAmount_SalesLine;-SalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalText;TotalText)
                        {
                        }
                        column(DiscountAmt_SalesLine;SalesLine."Line Amount" - SalesLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmtTxt;VATAmountLine.VATAmountText)
                        {
                        }
                        column(TotalExclVATText;TotalExclVATText)
                        {
                        }
                        column(TotalInclVATText;TotalInclVATText)
                        {
                        }
                        column(VATAmount;VATAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATDiscountAmount;-VATDiscountAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmountInclVAT;TotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseAmount;VATBaseAmount)
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(UnitPriceCaption;UnitPriceCaptionLbl)
                        {
                        }
                        column(SalesLineLineDiscCaption;SalesLineLineDiscCaptionLbl)
                        {
                        }
                        column(AmountCaption;AmountCaptionLbl)
                        {
                        }
                        column(SalesLineInvDiscAmtCaption;SalesLineInvDiscAmtCaptionLbl)
                        {
                        }
                        column(SubtotalCaption;SubtotalCaptionLbl)
                        {
                        }
                        column(VATDiscountAmountCaption;VATDiscountAmountCaptionLbl)
                        {
                        }
                        column(No_SalesLineCaption;"Sales Line".FieldCaption("No."))
                        {
                        }
                        column(Desc_SalesLineCaption;"Sales Line".FieldCaption(Description))
                        {
                        }
                        column(Quantity_SalesLineCaption;"Sales Line".FieldCaption(Quantity))
                        {
                        }
                        column(UnitofMeasure_SalesLineCaption;"Sales Line".FieldCaption("Unit of Measure"))
                        {
                        }
                        dataitem(DimensionLoop2;"Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number=FILTER(1..));
                            column(DimText_DimnLoop2;DimText)
                            {
                            }
                            column(LineDimensionsCaption;LineDimensionsCaptionLbl)
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
                                    DimText := StrSubstNo('%1 %2',DimSetEntry2."Dimension Code",DimSetEntry2."Dimension Value Code")
                                  else
                                    DimText :=
                                      StrSubstNo(
                                        '%1, %2 %3',DimText,
                                        DimSetEntry2."Dimension Code",DimSetEntry2."Dimension Value Code");
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

                                DimSetEntry2.SetRange("Dimension Set ID","Sales Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                              SalesLine.Find('-')
                            else
                              SalesLine.Next;
                            "Sales Line" := SalesLine;

                            if not "Sales Header"."Prices Including VAT" and
                               (SalesLine."VAT Calculation Type" = SalesLine."VAT Calculation Type"::"Full VAT")
                            then
                              SalesLine."Line Amount" := 0;

                            if (SalesLine.Type = SalesLine.Type::"G/L Account") and (not ShowInternalInfo) then
                              "Sales Line"."No." := '';
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
                            SalesLine.SetRange("Line No.",0,SalesLine."Line No.");
                            SetRange(Number,1,SalesLine.Count);
                            //CurrReport.CreateTotals(SalesLine."Line Amount",SalesLine."Inv. Discount Amount");
                        end;
                    }
                    dataitem(VATCounter;"Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(VATBase_VATAmtLine;VATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmt_VATAmtLine;VATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(LineAmount_VATAmtLine;VATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(InvDiscBaseAmt_VATAmtLine;VATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(InvoiceDiscAmt_VATAmtLine;VATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Sales Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VAT_VATAmtLine;VATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0:5;
                        }
                        column(VATIdentifier_VATAmtLine;VATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATAmountLineVATCaption;VATAmountLineVATCaptionLbl)
                        {
                        }
                        column(VATBaseCaption;VATBaseCaptionLbl)
                        {
                        }
                        column(VATAmtCaption;VATAmtCaptionLbl)
                        {
                        }
                        column(VATAmountSpecificationCaption;VATAmountSpecificationCaptionLbl)
                        {
                        }
                        column(LineAmtCaption;LineAmtCaptionLbl)
                        {
                        }
                        column(InvoiceDiscBaseAmtCaption;InvoiceDiscBaseAmtCaptionLbl)
                        {
                        }
                        column(InvoiceDiscAmtCaption;InvoiceDiscAmtCaptionLbl)
                        {
                        }
                        column(TotalCaption;TotalCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if VATAmount = 0 then
                              CurrReport.Break;
                            SetRange(Number,1,VATAmountLine.Count);
                            //CurrReport.CreateTotals(
                            //  VATAmountLine."Line Amount",VATAmountLine."Inv. Disc. Base Amount",
                            //  VATAmountLine."Invoice Discount Amount",VATAmountLine."VAT Base",VATAmountLine."VAT Amount");
                        end;
                    }
                    dataitem(VATCounterLCY;"Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(VALExchRate;VALExchRate)
                        {
                        }
                        column(VALSpecLCYHeader;VALSpecLCYHeader)
                        {
                        }
                        column(VALVATBaseLCY;VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATAmountLCY;VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATCtrl_VATAmtLine;VATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0:5;
                        }
                        column(VATIdentifierCtrl_VATAmtLine;VATAmountLine."VAT Identifier")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                            VALVATBaseLCY :=
                              VATAmountLine.GetBaseLCY(
                                "Sales Header"."Posting Date","Sales Header"."Currency Code","Sales Header"."Currency Factor");
                            VALVATAmountLCY :=
                              VATAmountLine.GetAmountLCY(
                                "Sales Header"."Posting Date","Sales Header"."Currency Code","Sales Header"."Currency Factor");
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GLSetup."Print VAT specification in LCY") or
                               ("Sales Header"."Currency Code" = '') or
                               (VATAmountLine.GetTotalVATAmount = 0)
                            then
                              CurrReport.Break;

                            SetRange(Number,1,VATAmountLine.Count);
                            //CurrReport.CreateTotals(VALVATBaseLCY,VALVATAmountLCY);

                            if GLSetup."LCY Code" = '' then
                              VALSpecLCYHeader := Text008 + Text009
                            else
                              VALSpecLCYHeader := Text008 + Format(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency("Sales Header"."Order Date","Sales Header"."Currency Code",1);
                            VALExchRate := StrSubstNo(Text010,CurrExchRate."Relational Exch. Rate Amount",CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem(Total;"Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                    }
                    dataitem(Total2;"Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                        column(SelltoCustNo_SalesHeader;"Sales Header"."Sell-to Customer No.")
                        {
                        }
                        column(ShipToAddr1;ShipToAddr[1])
                        {
                        }
                        column(ShipToAddr2;ShipToAddr[2])
                        {
                        }
                        column(ShipToAddr3;ShipToAddr[3])
                        {
                        }
                        column(ShipToAddr4;ShipToAddr[4])
                        {
                        }
                        column(ShipToAddr5;ShipToAddr[5])
                        {
                        }
                        column(ShipToAddr6;ShipToAddr[6])
                        {
                        }
                        column(ShipToAddr7;ShipToAddr[7])
                        {
                        }
                        column(ShipToAddr8;ShipToAddr[8])
                        {
                        }
                        column(ShiptoAddressCaption;ShiptoAddressCaptionLbl)
                        {
                        }
                        column(SelltoCustNo_SalesHeaderCaption;"Sales Header".FieldCaption("Sell-to Customer No."))
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if not ShowShippingAddr then
                              CurrReport.Break;
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                var
                    SalesPost: Codeunit "Sales-Post";
                begin
                    Clear(SalesLine);
                    Clear(SalesPost);
                    SalesLine.DeleteAll;
                    VATAmountLine.DeleteAll;
                    SalesPost.GetSalesLines("Sales Header",SalesLine,0);
                    SalesLine.CalcVATAmountLines(0,"Sales Header",SalesLine,VATAmountLine);
                    SalesLine.UpdateVATOnLines(0,"Sales Header",SalesLine,VATAmountLine);
                    VATAmount := VATAmountLine.GetTotalVATAmount;
                    VATBaseAmount := VATAmountLine.GetTotalVATBase;
                    VATDiscountAmount :=
                      VATAmountLine.GetTotalVATDiscount("Sales Header"."Currency Code","Sales Header"."Prices Including VAT");
                    TotalAmountInclVAT := VATAmountLine.GetTotalAmountInclVAT;

                    if Number > 1 then begin
                      CopyText := Text003;
                      OutputNo += 1;
                    end;
                    //CurrReport.PageNo := 1;
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
                    SetRange(Number,1,NoOfLoops);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            var
                "Sell-to Country": Text[50];
            begin
                CurrReport.Language := Language.GetLanguageID("Language Code");

                if RespCenter.Get("Responsibility Center") then begin
                  FormatAddr.RespCenter(CompanyAddr,RespCenter);
                  CompanyInfo."Phone No." := RespCenter."Phone No.";
                  CompanyInfo."Fax No." := RespCenter."Fax No.";
                end else
                  FormatAddr.Company(CompanyAddr,CompanyInfo);

                DimSetEntry1.SetRange("Dimension Set ID","Dimension Set ID");

                if "Salesperson Code" = '' then begin
                  SalesPurchPerson.Init;
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
                  TotalText := StrSubstNo(Text001,GLSetup."LCY Code");
                  TotalInclVATText := StrSubstNo(Text002,GLSetup."LCY Code");
                  TotalExclVATText := StrSubstNo(Text006,GLSetup."LCY Code");
                end else begin
                  TotalText := StrSubstNo(Text001,"Currency Code");
                  TotalInclVATText := StrSubstNo(Text002,"Currency Code");
                  TotalExclVATText := StrSubstNo(Text006,"Currency Code");
                end;
                FormatAddr.SalesHeaderBillTo(CustAddr,"Sales Header");

                if "Payment Terms Code" = '' then
                  PaymentTerms.Init
                else begin
                  PaymentTerms.Get("Payment Terms Code");
                  PaymentTerms.TranslateDescription(PaymentTerms,"Language Code");
                end;
                if "Shipment Method Code" = '' then
                  ShipmentMethod.Init
                else begin
                  ShipmentMethod.Get("Shipment Method Code");
                  ShipmentMethod.TranslateDescription(ShipmentMethod,"Language Code");
                end;

                if Country.Get("Sell-to Country/Region Code") then
                  "Sell-to Country" := Country.Name;
                FormatAddr.SalesHeaderShipTo(ShipToAddr,CustAddr,"Sales Header");
                ShowShippingAddr := "Sell-to Customer No." <> "Bill-to Customer No.";
                for i := 1 to ArrayLen(ShipToAddr) do
                  if (ShipToAddr[i] <> CustAddr[i]) and (ShipToAddr[i] <> '') and (ShipToAddr[i] <> "Sell-to Country") then
                    ShowShippingAddr := true;

                if Print then begin
                  if ArchiveDocument then
                    ArchiveManagement.StoreSalesDocument("Sales Header",LogInteraction);

                  if LogInteraction then begin
                    CalcFields("No. of Archived Versions");
                    if "Bill-to Contact No." <> '' then
                      SegManagement.LogDocument(
                        1,"No.","Doc. No. Occurrence",
                        "No. of Archived Versions",DATABASE::Contact,"Bill-to Contact No.",
                        "Salesperson Code","Campaign No.","Posting Description","Opportunity No.")
                    else
                      SegManagement.LogDocument(
                        1,"No.","Doc. No. Occurrence",
                        "No. of Archived Versions",DATABASE::Customer,"Bill-to Customer No.",
                        "Salesperson Code","Campaign No.","Posting Description","Opportunity No.");
                  end;
                end;
                Mark(true);

                //ABC-PRO
                gTxtVat := VATAmountLine.VATAmountText;

                if ((("Sales Header"."VAT Bus. Posting Group" = 'NON-EU B2B') and (("Sales Header"."Customer Posting Group" = 'NON-EU') or ("Sales Header"."Customer Posting Group" = 'ACC REC')))
                      or ("Sales Header"."VAT Bus. Posting Group" = 'NON-EU B2C')) then begin
                  gTxtVat := TxtVat1;
                  gTxtFooter := TxtFooter1;
                end;
                if "Sales Header"."VAT Bus. Posting Group" = 'EU B2B' then begin
                  gTxtVat := TxtVat2;
                  gTxtFooter := TxtFooter2;
                end;
                if "Sales Header"."VAT Bus. Posting Group" = 'NL 0%' then begin
                  gTxtVat := TxtVat3;
                  gTxtFooter := TxtFooter3;
                end;
                if (("Sales Header"."VAT Bus. Posting Group" = 'NON-EU B2B') and ("Sales Header"."Customer Posting Group" = 'NON-EU IC')) then begin
                  gTxtVat := TxtVat3;
                  gTxtFooter := TxtFooter3;
                end;
                //
            end;

            trigger OnPostDataItem()
            var
                ToDo: Record "To-do";
                FileManagement: Codeunit "File Management";
            begin
                MarkedOnly := true;
                Commit;
                CurrReport.Language := GlobalLanguage;
                if not FileManagement.IsWebClient then
                  if Find('-') and ToDo.WritePermission then
                    if Print and (NoOfRecords = 1) then
                      if Confirm(Text007) then
                        CreateTask;
            end;

            trigger OnPreDataItem()
            begin
                NoOfRecords := Count;
                Print := Print or not CurrReport.Preview;

                //ABC-PRO
                gTxtFooter := '';
                //
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
                    field(NoOfCopies;NoOfCopies)
                    {
                        Caption = 'No. of Copies';
                    }
                    field(ShowInternalInfo;ShowInternalInfo)
                    {
                        Caption = 'Show Internal Information';
                    }
                    field(ArchiveDocument;ArchiveDocument)
                    {
                        Caption = 'Archive Document';

                        trigger OnValidate()
                        begin
                            if not ArchiveDocument then
                              LogInteraction := false;
                        end;
                    }
                    field(LogInteraction;LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;

                        trigger OnValidate()
                        begin
                            if LogInteraction then
                              ArchiveDocument := ArchiveDocumentEnable;
                        end;
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
            LogInteraction := SegManagement.FindInteractTmplCode(1) <> '';

            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get;
        CompanyInfo.Get;
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

    var
        Text000: Label 'Salesperson';
        Text001: Label 'Total %1 Incl VAT';
        Text002: Label 'Total %1 Incl. VAT';
        Text003: Label 'COPY';
        Text004: Label 'Quote %1';
        Text005: Label 'Page %1';
        Text006: Label 'Total %1 Excl. VAT';
        GLSetup: Record "General Ledger Setup";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInfo: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        VATAmountLine: Record "VAT Amount Line" temporary;
        SalesLine: Record "Sales Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        Language: Record Language;
        Country: Record "Country/Region";
        CurrExchRate: Record "Currency Exchange Rate";
        SalesCountPrinted: Codeunit "Sales-Printed";
        FormatAddr: Codeunit "Format Address";
        SegManagement: Codeunit SegManagement;
        ArchiveManagement: Codeunit ArchiveManagement;
        CustAddr: array [8] of Text[50];
        ShipToAddr: array [8] of Text[50];
        CompanyAddr: array [8] of Text[50];
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
        Text007: Label 'Do you want to create a follow-up to-do?';
        NoOfRecords: Integer;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        Text008: Label 'VAT Amount Specification in ';
        Text009: Label 'Local Currency';
        Text010: Label 'Exchange rate: %1/%2';
        OutputNo: Integer;
        Print: Boolean;
        [InDataSet]
        ArchiveDocumentEnable: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        CompanyInfoPhoneNoCaptionLbl: Label 'Phone No.';
        CompanyInfoVATRegNoCaptionLbl: Label 'VAT Registration No.';
        CompanyInfoGiroNoCaptionLbl: Label 'Giro No.';
        CompanyInfoBankNameCaptionLbl: Label 'Bank Information';
        CompanyInfoBankAccountNoCaptionLbl: Label 'Account No.';
        SalesHeaderShipmentDateCaptionLbl: Label 'Shipment Date';
        SalesHeaderNoCaptionLbl: Label 'Quote No.';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        UnitPriceCaptionLbl: Label 'Unit Price';
        SalesLineLineDiscCaptionLbl: Label 'Discount %';
        AmountCaptionLbl: Label 'Amount';
        SalesLineInvDiscAmtCaptionLbl: Label 'Invoice Discount Amount';
        SubtotalCaptionLbl: Label 'Subtotal';
        VATDiscountAmountCaptionLbl: Label 'Payment Discount on VAT';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        VATAmountLineVATCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmtCaptionLbl: Label 'VAT Amount';
        VATAmountSpecificationCaptionLbl: Label 'VAT Amount Specification';
        LineAmtCaptionLbl: Label 'Line Amount';
        InvoiceDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        InvoiceDiscAmtCaptionLbl: Label 'Invoice Discount Amount';
        TotalCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        SalesLineVATIdentifierCaptionLbl: Label 'VAT Identifier';
        PaymentTermsDescriptionCaptionLbl: Label 'Payment Terms';
        ShipmentMethodDescriptionCaptionLbl: Label 'Shipment Method';
        CompanyInfoHomePageCaptionLbl: Label 'Home Page';
        CompanyInfoEmailCaptionLbl: Label 'E-Mail';
        DocumentDateCaptionLbl: Label 'Document Date';
        SalesLineAllowInvoiceDiscCaptionLbl: Label 'Allow Invoice Discount';
        RepairText: Label 'Repair activities will start after your approval.';
        TxtVat1: Label '0% VAT (Export Supply)';
        TxtVat2: Label '0% VAT (IC-supply)';
        TxtVat3: Label '0% VAT (Reverse Charge)';
        TxtFooter1: Label '0% Dutch VAT - Export supply (Article 146 EU VAT Directive Applies)';
        TxtFooter2: Label '0% Dutch VAT - IC-supply (Article 138 VAT Directive)';
        TxtFooter3: Label '0% Dutch VAT - Reverse Charge (VAT shifted to customer, Article 12-3, Dutch VAT Act)';
        gTxtVat: Text;
        gTxtFooter: Text;

    procedure InitializeRequest(NoOfCopiesFrom: Integer;ShowInternalInfoFrom: Boolean;ArchiveDocumentFrom: Boolean;LogInteractionFrom: Boolean;PrintFrom: Boolean)
    begin
        NoOfCopies := NoOfCopiesFrom;
        ShowInternalInfo := ShowInternalInfoFrom;
        ArchiveDocument := ArchiveDocumentFrom;
        LogInteraction := LogInteractionFrom;
        Print := PrintFrom;
    end;
}

