pageextension 50016 "Posted Sales Invoice Ext." extends "Posted Sales Invoice"

//  RHE-TNA 08-02-2021 BDS-4944
//  - Added Layout

//RHE-TNA 16-11-2021..14-01-2022 BDS-5853
//  - Added procedure SetReportSelection()
//  - Modified action("Save PDF Invoice")

//  RHE-TNA 28-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

//  RHE-AMKE 21-06-2022 BDS-6408
//  - Do not put "-" in the pdf file name of sales invoices line IF Order.NO is nothing

{
    //RHE-TNA 08-02-2021 BDS-4944 BEGIN
    layout
    {
        addafter("Sell-to Contact")
        {
            field("Sell-to E-Mail"; "Sell-to E-Mail")
            {

            }
        }
    }
    //RHE-TNA 08-02-2021 BDS-4944 END

    actions
    {
        addafter(Print)
        {
            action("Save PDF Invoice")
            {
                Image = SendAsPDF;
                Ellipsis = true;
                ToolTip = 'Store a PDF version of the Invoice.';
                trigger OnAction()
                var
                    SalesInvHdr: Record "Sales Invoice Header";
                    ReportSelections: Record "Report Selections";
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    //MessageText001: TextConst
                    //    ENU = 'Document saved as PDF. Directory:\%1';
                    MessageText001: Label 'Document saved as PDF. Directory:\%1';
                    FileName: Label 'Invoice ';
                    Language: Record Language;
                //RHE-TNA 28-01-2022 BDS-6037 END
                begin
                    SalesSetup.Get();
                    SalesSetup.TestField("PDF S. Invoice Directory");
                    SalesInvHdr.SetRange("No.", Rec."No.");
                    SalesInvHdr.FindFirst();
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    if (SalesInvHdr."Language Code" <> '') and (Language.Get(SalesInvHdr."Language Code")) then
                        GlobalLanguage(Language."Windows Language ID");
                    //RHE-TNA 28-01-2022 BDS-6037 END
                    //RHE-TNA 16-11-2021..14-01-2022 BDS-5853 BEGIN
                    //Check if customer specific document layouts are setup
                    CustomReportSel.SetRange("Source Type", 18);
                    CustomReportSel.SetRange("Source No.", SalesInvHdr."Sell-to Customer No.");
                    CustomReportSel.SetRange(Usage, CustomReportSel.Usage::"S.Invoice");
                    CustomReportSel.SetFilter("Report ID", '<>%1', 0);
                    //RHE-AMKE 21-06-2022 BDS-6408 BEGIN
                    // Added If statment to check Order.NO is empty or not!
                    if SalesInvHdr."Order No." <> '' then
                        if CustomReportSel.FindSet() then begin
                            repeat
                                SetReportSelection(CustomReportSel);
                                ReportLayoutSelection.SetTempLayoutSelected(TempReportSelection."Custom Report Layout Code");
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Invoice Directory" + FileName + SalesInvHdr."No." + '-' + SalesInvHdr."Order No." + '.pdf', SalesInvHdr);
                                ReportLayoutSelection.SetTempLayoutSelected('');
                                TempReportSelection.Delete();
                            until CustomReportSel.Next() = 0;
                        end else begin
                            //Print default layout
                            //RHE-TNA 16-11-2021..14-01-2022 BDS-5853 END
                            ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Invoice");
                            ReportSelections.SetFilter("Report ID", '<>%1', 0);
                            if ReportSelections.FindSet() then
                                repeat
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Invoice Directory" + FileName + SalesInvHdr."No." + '-' + SalesInvHdr."Order No." + '.pdf', SalesInvHdr)
                                until ReportSelections.Next() = 0;
                            //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                        end
                    else
                        if CustomReportSel.FindSet() then begin
                            repeat
                                SetReportSelection(CustomReportSel);
                                ReportLayoutSelection.SetTempLayoutSelected(TempReportSelection."Custom Report Layout Code");
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Invoice Directory" + FileName + SalesInvHdr."No." + '.pdf', SalesInvHdr);
                                ReportLayoutSelection.SetTempLayoutSelected('');
                                TempReportSelection.Delete();
                            until CustomReportSel.Next() = 0;
                        end else begin
                            //Print default layout
                            //RHE-TNA 16-11-2021..14-01-2022 BDS-5853 END
                            ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Invoice");
                            ReportSelections.SetFilter("Report ID", '<>%1', 0);
                            if ReportSelections.FindSet() then
                                repeat
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Invoice Directory" + FileName + SalesInvHdr."No." + '.pdf', SalesInvHdr)
                                until ReportSelections.Next() = 0;
                            //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                        end;
                    //RHE-TNA 16-11-2021 BDS-5853 END
                    Message(MessageText001, SalesSetup."PDF S. Invoice Directory");
                end;
                //RHE-AMKE 21-06-2022 BDS-6408 END
            }
        }
    }

    //RHE-TNA 16-11-2021 BDS-5853 BEGIN
    procedure SetReportSelection(var CustomReportSelection: Record "Custom Report Selection")
    begin
        TempReportSelection.Init();
        TempReportSelection.Usage := CustomReportSelection.Usage;
        TempReportSelection.Sequence := Format(CustomReportSelection.Sequence);
        TempReportSelection."Report ID" := CustomReportSelection."Report ID";
        TempReportSelection."Custom Report Layout Code" := CustomReportSelection."Custom Report Layout Code";
        TempReportSelection."Email Body Layout Code" := CustomReportSelection."Email Body Layout Code";
        TempReportSelection."Use for Email Attachment" := CustomReportSelection."Use for Email Attachment";
        TempReportSelection."Use for Email Body" := CustomReportSelection."Use for Email Body";
        TempReportSelection.Insert();
    end;
    //RHE-TNA 16-11-2021 BDS-5853 END

    //Global variables
    var
        SalesSetup: Record "Sales & Receivables Setup";
        TempReportSelection: Record "Report Selections" temporary;
        CustomReportSel: Record "Custom Report Selection";
        ReportLayoutSelection: Record "Report Layout Selection";
}