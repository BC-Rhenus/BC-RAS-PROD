pageextension 50019 "Customer Report Ext." extends "Customer Report Selections"

//  RHE-TNA 11-02-2022 BDS-6110
//  - Modified field(Usage)
//  - Modfied Procedure SetUsage3PageView()

{
    layout
    {
        addafter(Usage2)
        {
            field(Usage; Usage3)
            {
                trigger OnValidate()
                begin
                    CASE Usage3 OF
                        Usage3::Quote:
                            Usage := Usage::"S.Quote";
                        Usage3::"Confirmation Order":
                            Usage := Usage::"S.Order";
                        Usage3::Invoice:
                            Usage := Usage::"S.Invoice";
                        Usage3::"Credit Memo":
                            Usage := Usage::"S.Cr.Memo";
                        Usage3::"Customer Statement":
                            Usage := Usage::"C.Statement";
                        Usage3::"Job Quote":
                            Usage := Usage::JQ;
                        Usage3::"Prepayment Invoice":
                            Usage := Usage::"S.Invoice Draft";
                        Usage3::"Proforma Invoice":
                            Usage := Usage::"Pro Forma S. Invoice";
                        //RHE-TNA 11-02-2022 BDS-6110 BEGIN
                        Usage3::"Confirmation Blanket Order":
                            Usage := Usage::"S.Blanket";
                            //RHE-TNA 11-02-2022 BDS-6110 END
                    END;
                end;
            }
        }
        addafter(SendToEmail)
        {
            field("Send To Email CC"; "Send To Email CC")
            {

            }
            field("Send To Email BCC"; "Send To Email BCC")
            {

            }
        }
        modify(Usage2)
        {
            Visible = false;
        }
    }

    Procedure SetUsage3PageView()
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        CASE Usage OF
            CustomReportSelection.Usage::"S.Quote":
                Usage3 := Usage::"S.Quote";
            CustomReportSelection.Usage::"S.Order":
                Usage3 := Usage::"S.Order";
            CustomReportSelection.Usage::"S.Invoice":
                Usage3 := Usage::"S.Invoice";
            CustomReportSelection.Usage::"S.Cr.Memo":
                Usage3 := Usage::"S.Cr.Memo";
            CustomReportSelection.Usage::"C.Statement":
                Usage3 := Usage3::"Customer Statement";
            CustomReportSelection.Usage::JQ:
                Usage3 := Usage3::"Job Quote";
            CustomReportSelection.Usage::"S.Invoice Draft":
                Usage3 := Usage3::"Prepayment Invoice";
            CustomReportSelection.Usage::"Pro Forma S. Invoice":
                Usage3 := Usage3::"Proforma Invoice";
            //RHE-TNA 11-02-2022 BDS-6110 BEGIN
            CustomReportSelection.Usage::"S.Blanket":
                Usage3 := Usage3::"Confirmation Blanket Order";
                //RHE-TNA 11-02-2022 BDS-6110 END
        END;
    end;

    trigger OnAfterGetRecord()
    begin
        SetUsage3PageView();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUsage3PageView();
    end;

    //Global Variables
    var
        Usage3: Option Quote,"Confirmation Order",Invoice,"Credit Memo","Customer Statement","Job Quote","Prepayment Invoice","Proforma Invoice","Confirmation Blanket Order";

}