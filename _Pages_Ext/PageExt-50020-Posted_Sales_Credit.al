pageextension 50020 "Posted Sales Credit Ext." extends "Posted Sales Credit Memo"

//RHE-TNA 16-11-2021..14-01-2022 BDS-5853
//  - Added procedure SetReportSelection()
//  - Modified action("Save PDF Credit Memo")

//  RHE-TNA 28-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

{
    actions
    {
        addafter(Print)
        {
            action("Save PDF Credit Memo")
            {
                Image = SendAsPDF;
                Ellipsis = true;
                ToolTip = 'Store a PDF version of the Credit Memo.';
                trigger OnAction()
                var
                    SalesCrHdr: Record "Sales Cr.Memo Header";
                    ReportSelections: Record "Report Selections";
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    //MessageText001: TextConst
                    //    ENU = 'Document saved as PDF. Directory:\%1';
                    MessageText001: Label 'Document saved as PDF. Directory:\%1';
                    FileName: Label 'Credit Memo ';
                    Language: Record Language;
                    //RHE-TNA 28-01-2022 BDS-6037 END
                begin
                    SalesSetup.Get();
                    SalesSetup.TestField("PDF S. Credit Memo Directory");
                    SalesCrHdr.SetRange("No.", Rec."No.");
                    SalesCrHdr.FindFirst();
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    if (SalesCrHdr."Language Code" <> '') and (Language.Get(SalesCrHdr."Language Code")) then
                        GlobalLanguage(Language."Windows Language ID");
                    //RHE-TNA 28-01-2022 BDS-6037 END
                    //RHE-TNA 16-11-2021..14-01-2022 BDS-5853 BEGIN
                    //Check if customer specific document layouts are setup
                    CustomReportSel.SetRange("Source Type", 18);
                    CustomReportSel.SetRange("Source No.", SalesCrHdr."Sell-to Customer No.");
                    CustomReportSel.SetRange(Usage, CustomReportSel.Usage::"S.Cr.Memo");
                    CustomReportSel.SetFilter("Report ID", '<>%1', 0);
                    if CustomReportSel.FindSet() then begin
                        repeat
                            SetReportSelection(CustomReportSel);
                            ReportLayoutSelection.SetTempLayoutSelected(TempReportSelection."Custom Report Layout Code");
                            Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Credit Memo Directory" + FileName + SalesCrHdr."No." + '.pdf', SalesCrHdr);
                            ReportLayoutSelection.SetTempLayoutSelected('');
                            TempReportSelection.Delete();
                        until CustomReportSel.Next() = 0;
                    end else begin
                        //Print default layout
                        //RHE-TNA 16-11-2021..14-01-2022 BDS-5853 END
                        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Cr.Memo");
                        ReportSelections.SetFilter("Report ID", '<>%1', 0);
                        if ReportSelections.FindSet() then
                            repeat
                                Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Credit Memo Directory" + FileName + SalesCrHdr."No." + '.pdf', SalesCrHdr)
                            until ReportSelections.Next() = 0;
                        //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                    end;
                    //RHE-TNA 16-11-2021 BDS-5853 END
                    Message(MessageText001, SalesSetup."PDF S. Credit Memo Directory");
                end;
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