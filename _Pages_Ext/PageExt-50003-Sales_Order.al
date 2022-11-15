pageextension 50003 Sales_Order_Extensions extends "Sales Order"

//RHE-TNA 07-05-2020 BDS-4135
//  - Added field Reason Code

//RHE-TNA 05-01-2021 BDS-4828
//  - Removed field E-mail

//RHE-TNA 16-11-2021..27-12-2021 BDS-5676
//  - Added trigger OnQueryClosePage()
//  - Added field "EDI status"
//  - Added action("Set EDI Status")
//  - Added field "Last EDI Export Date/Time"

//RHE-TNA 16-11-2021 BDS-5853
//  - Added procedure SetReportSelection()
//  - Modified actions ("Save PDF ....)

//RHE-TNA 28-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

//RHE-TNA 01-03-2022 BDS-6149
//  - Modified action("Set EDI Status")
//  - Modified trigger OnQueryClosePage()

//RHE-TNA 03-03-2022 BDS-5564
//  - Added trigger OnClosePage()

//RHE-TNA 19-05-2022 BDS-6111
//  - Modified field(Substatus)

//RHE-AMKE 20-06-2022 BDS-6430
//  - Added field Location Code

{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("Sell-to Customer Name 2"; "Sell-to Customer Name 2")
            {

            }
        }
        addafter("Bill-to Name")
        {
            field("Bill-to Name 2"; "Bill-to Name 2")
            {

            }
        }
        addafter("Ship-to Name")
        {
            field("Ship-to Name 2"; "Ship-to Name 2")
            {

            }
        }
        addafter(Status)
        {
            field(Substatus; Substatus)
            {
                LookupPageId = "Order Substatus";
            }
            field("EDI Status"; "EDI Status")
            {
                Editable = false;
            }
            field("Last EDI Export Date/Time"; "Last EDI Export Date/Time")
            {
                Editable = false;
            }
            field("Customer Comment Text"; "Customer Comment Text")
            {

            }
            field("Interface Error Text"; "Interface Error Text")
            {
                StyleExpr = 'Unfavorable';
            }
            //RHE-TNA 07-05-2020 BDS-4135 BEGIN
            field("Reason Code"; "Reason Code")
            {

            }
            //RHE-TNA 07-05-2020 BDS-4135 END

            //RHE-AMKE 20-06-2022 BDS-6430 BEGIN
            field("Language Code"; "Language Code")
            {

            }
            //RHE-TNA 07-05-2020 BDS-6430 END

        }
        addafter("VAT Bus. Posting Group")
        {
            field("VAT Registration No."; "VAT Registration No.")
            {

            }
        }
        addafter(SalesLines)
        {
            group("Order Information")
            {
                /*RHE-TNA 05-01-2021 BDS-4828 BEGIN
                field("E-mail"; "E-mail")
                {

                }
                RHE-TNA 05-01-2021 BDS-4828 END*/
                field("Bill-to Phone No."; "Bill-to Phone No.")
                {

                }
                field("Ship-to Phone No."; "Ship-to Phone No.")
                {

                }
            }
        }
        addafter(SalesLines)
        {
            part(Comments; "Sales Order Comment ListPart")
            {
                Enabled = "No." <> '';
                SubPageLink = "Document Type" = field("Document Type"), "No." = field("No.");
            }
        }
    }

    actions
    {
        addafter(CopyDocument)
        {
            action("Create Backorder")
            {
                Image = CopyDocument;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'This function will create a new Sales Order with data from the current Sales Order.';

                trigger OnAction();
                var
                    ReportCreateBackorder: Report "Create Backorder";
                begin
                    ReportCreateBackorder.SetParameters("No.");
                    ReportCreateBackorder.RunModal();
                end;
            }
        }
        addafter(SendEmailConfirmation)
        {
            action("Save PDF Confirmation")
            {
                Image = SendAsPDF;
                Ellipsis = true;
                ToolTip = 'Store a PDF version of the Order Confirmation.';
                trigger OnAction()
                var
                    SalesHdr: Record "Sales Header";
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    //MessageText001: TextConst
                    //    ENU = '%1 Document(s) saved as PDF. Directory:\%2';
                    MessageText001: Label '%1 Document(s) saved as PDF. Directory:\%2';
                    FileName: Label 'Order Confirmation ';
                    Language: Record Language;
                    //RHE-TNA 28-01-2022 BDS-6037 END
                    RepeatCounter: Integer;
                begin
                    SalesSetup.Get();
                    SalesSetup.TestField("PDF S. Order Conf. Directory");
                    SalesHdr.SetRange("Document Type", Rec."Document Type");
                    SalesHdr.SetRange("No.", Rec."No.");
                    SalesHdr.FindFirst();
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    if (SalesHdr."Language Code" <> '') and (Language.Get(SalesHdr."Language Code")) then
                        GlobalLanguage(Language."Windows Language ID");
                    //RHE-TNA 28-01-2022 BDS-6037 END
                    //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                    //Check if customer specific document layouts are setup
                    CustomReportSel.SetRange("Source Type", 18);
                    CustomReportSel.SetRange("Source No.", SalesHdr."Sell-to Customer No.");
                    CustomReportSel.SetRange(Usage, CustomReportSel.Usage::"S.Order");
                    CustomReportSel.SetFilter("Report ID", '<>%1', 0);
                    if CustomReportSel.FindSet() then begin
                        repeat
                            SetReportSelection(CustomReportSel);
                            ReportLayoutSelection.SetTempLayoutSelected(TempReportSelection."Custom Report Layout Code");
                            if RepeatCounter = 0 then
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Order Conf. Directory" + FileName + SalesHdr."No." + '.pdf', SalesHdr)
                            else
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Order Conf. Directory" + FileName + SalesHdr."No." + '-' + Format(RepeatCounter) + '.pdf', SalesHdr);
                            RepeatCounter := RepeatCounter + 1;
                            ReportLayoutSelection.SetTempLayoutSelected('');
                            TempReportSelection.Delete();
                        until CustomReportSel.Next() = 0;
                    end else begin
                        //Print default layout
                        //RHE-TNA 16-11-2021 BDS-5853 END
                        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Order");
                        ReportSelections.SetFilter("Report ID", '<>%1', 0);
                        if ReportSelections.FindSet() then
                            repeat
                                if RepeatCounter = 0 then
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Order Conf. Directory" + FileName + SalesHdr."No." + '.pdf', SalesHdr)
                                else
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Order Conf. Directory" + FileName + SalesHdr."No." + '-' + Format(RepeatCounter) + '.pdf', SalesHdr);
                                RepeatCounter := RepeatCounter + 1;
                            until ReportSelections.Next() = 0;
                        //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                    end;
                    //RHE-TNA 16-11-2021 BDS-5853 END
                    Message(MessageText001, RepeatCounter, SalesSetup."PDF S. Order Conf. Directory");
                end;
            }
            action("Save PDF Prepayment Invoice")
            {
                Image = SendAsPDF;
                Ellipsis = true;
                ToolTip = 'Store a PDF version of the Prepayment Invoice. This action will only print a Prepayment Invoice. No actual Prepayment Invoice is posted.';
                trigger OnAction()
                var
                    SalesHdr: Record "Sales Header";
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    //MessageText001: TextConst
                    //    ENU = '%1 Document(s) saved as PDF. Directory:\%2';
                    MessageText001: Label '%1 Document(s) saved as PDF. Directory:\%2';
                    FileName: Label 'Prepayment Invoice ';
                    Language: Record Language;
                    //RHE-TNA 28-01-2022 BDS-6037 END
                    RepeatCounter: Integer;
                begin
                    SalesSetup.Get();
                    SalesSetup.TestField("PDF S. Prep. Invoice Directory");
                    SalesHdr.SetRange("Document Type", Rec."Document Type");
                    SalesHdr.SetRange("No.", Rec."No.");
                    SalesHdr.FindFirst();
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    if (SalesHdr."Language Code" <> '') and (Language.Get(SalesHdr."Language Code")) then
                        GlobalLanguage(Language."Windows Language ID");
                    //RHE-TNA 28-01-2022 BDS-6037 END
                    //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                    //Check if customer specific document layouts are setup
                    CustomReportSel.SetRange("Source Type", 18);
                    CustomReportSel.SetRange("Source No.", SalesHdr."Sell-to Customer No.");
                    CustomReportSel.SetRange(Usage, CustomReportSel.Usage::"S.Invoice Draft");
                    CustomReportSel.SetFilter("Report ID", '<>%1', 0);
                    if CustomReportSel.FindSet() then begin
                        repeat
                            SetReportSelection(CustomReportSel);
                            ReportLayoutSelection.SetTempLayoutSelected(TempReportSelection."Custom Report Layout Code");
                            if RepeatCounter = 0 then
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Prep. Invoice Directory" + FileName + SalesHdr."No." + '.pdf', SalesHdr)
                            else
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Prep. Invoice Directory" + FileName + SalesHdr."No." + '-' + Format(RepeatCounter) + '.pdf', SalesHdr);
                            RepeatCounter := RepeatCounter + 1;
                            ReportLayoutSelection.SetTempLayoutSelected('');
                            TempReportSelection.Delete();
                        until CustomReportSel.Next() = 0;
                    end else begin
                        //Print default layout
                        //RHE-TNA 16-11-2021 BDS-5853 END
                        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Invoice Draft");
                        ReportSelections.SetFilter("Report ID", '<>%1', 0);
                        if ReportSelections.FindSet() then
                            repeat
                                if RepeatCounter = 0 then
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Prep. Invoice Directory" + FileName + SalesHdr."No." + '.pdf', SalesHdr)
                                else
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Prep. Invoice Directory" + FileName + SalesHdr."No." + '-' + Format(RepeatCounter) + '.pdf', SalesHdr);
                                RepeatCounter := RepeatCounter + 1;
                            until ReportSelections.Next() = 0;
                        //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                    end;
                    //RHE-TNA 16-11-2021 BDS-5853 END
                    Message(MessageText001, RepeatCounter, SalesSetup."PDF S. Prep. Invoice Directory");
                end;
            }
            action("Save PDF Pro Forma Invoice")
            {
                Image = SendAsPDF;
                Ellipsis = true;
                ToolTip = 'Store a PDF version of the Proforma Invoice.';
                trigger OnAction()
                var
                    SalesHdr: Record "Sales Header";
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    //MessageText001: TextConst
                    //    ENU = '%1 Document(s) saved as PDF. Directory:\%2';
                    MessageText001: Label '%1 Document(s) saved as PDF. Directory:\%2';
                    FileName: Label 'Pro Forma Invoice ';
                    Language: Record Language;
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    RepeatCounter: Integer;
                begin
                    SalesSetup.Get();
                    SalesSetup.TestField("PDF S. Proforma Directory");
                    SalesHdr.SetRange("Document Type", Rec."Document Type");
                    SalesHdr.SetRange("No.", Rec."No.");
                    SalesHdr.FindFirst();
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    if (SalesHdr."Language Code" <> '') and (Language.Get(SalesHdr."Language Code")) then
                        GlobalLanguage(Language."Windows Language ID");
                    //RHE-TNA 28-01-2022 BDS-6037 END
                    //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                    //Check if customer specific document layouts are setup
                    CustomReportSel.SetRange("Source Type", 18);
                    CustomReportSel.SetRange("Source No.", SalesHdr."Sell-to Customer No.");
                    CustomReportSel.SetRange(Usage, CustomReportSel.Usage::"Pro Forma S. Invoice");
                    CustomReportSel.SetFilter("Report ID", '<>%1', 0);
                    if CustomReportSel.FindSet() then begin
                        repeat
                            SetReportSelection(CustomReportSel);
                            ReportLayoutSelection.SetTempLayoutSelected(TempReportSelection."Custom Report Layout Code");
                            if RepeatCounter = 0 then
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Proforma Directory" + FileName + SalesHdr."No." + '.pdf', SalesHdr)
                            else
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Proforma Directory" + FileName + SalesHdr."No." + '-' + Format(RepeatCounter) + '.pdf', SalesHdr);
                            RepeatCounter := RepeatCounter + 1;
                            ReportLayoutSelection.SetTempLayoutSelected('');
                            TempReportSelection.Delete();
                        until CustomReportSel.Next() = 0;
                    end else begin
                        //Print default layout
                        //RHE-TNA 16-11-2021 BDS-5853 END
                        ReportSelections.SetRange(Usage, ReportSelections.Usage::"Pro Forma S. Invoice");
                        ReportSelections.SetFilter("Report ID", '<>%1', 0);
                        if ReportSelections.FindSet() then
                            repeat
                                if RepeatCounter = 0 then
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Proforma Directory" + FileName + SalesHdr."No." + '.pdf', SalesHdr)
                                else
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Proforma Directory" + FileName + SalesHdr."No." + '-' + Format(RepeatCounter) + '.pdf', SalesHdr);
                                RepeatCounter := RepeatCounter + 1;
                            until ReportSelections.Next() = 0;
                        //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                    end;
                    //RHE-TNA 16-11-2021 BDS-5853 END
                    Message(MessageText001, RepeatCounter, SalesSetup."PDF S. Proforma Directory");
                end;
            }
            action("Save PDF Customs Invoice")
            {
                Image = SendAsPDF;
                Ellipsis = true;
                ToolTip = 'Store a PDF version of the Customs Invoice.';
                trigger OnAction()
                var
                    SalesHdr: Record "Sales Header";
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    //MessageText001: TextConst
                    //    ENU = '%1 Document(s) saved as PDF. Directory:\%2';
                    MessageText001: Label '%1 Document(s) saved as PDF. Directory:\%2';
                    FileName: Label 'Customs Invoice ';
                    Language: Record Language;
                    //RHE-TNA 28-01-2022 BDS-6037 END
                    RepeatCounter: Integer;
                    ATOLink: Record "Assemble-to-Order Link";
                begin
                    SalesSetup.Get();
                    SalesSetup.TestField("PDF S. Customs Directory");
                    SalesHdr.SetRange("Document Type", Rec."Document Type");
                    SalesHdr.SetRange("No.", Rec."No.");
                    SalesHdr.FindFirst();
                    //RHE-TNA 28-01-2022 BDS-6037 BEGIN
                    if (SalesHdr."Language Code" <> '') and (Language.Get(SalesHdr."Language Code")) then
                        GlobalLanguage(Language."Windows Language ID");
                    //RHE-TNA 28-01-2022 BDS-6037 END
                    //RHE-TNA 12-01-2022 BDS-5997 BEGIN
                    //Check is assembly-to-order lines are present and if the need to be printed
                    ATOLink.SetRange(Type, ATOLink.Type::Sale);
                    ATOLink.SetRange("Assembly Document Type", ATOLink."Assembly Document Type"::Order);
                    ATOLink.SetRange("Document Type", ATOLink."Document Type"::Order);
                    ATOLink.SetRange("Document No.", SalesHdr."No.");
                    if ATOLink.FindFirst() then
                        if Confirm('This order contains Assemble-to-Order items, do you want to show Assembly Components on the report?') then begin
                            SalesHdr.Validate("Print Assembly Comp.", true);
                            SalesHdr.Modify(false);
                        end;
                    //RHE-TNA 12-01-2022 BDS-5997 END
                    //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                    //Check if customer specific document layouts are setup
                    CustomReportSel.SetRange("Source Type", 18);
                    CustomReportSel.SetRange("Source No.", SalesHdr."Sell-to Customer No.");
                    CustomReportSel.SetRange(Usage, CustomReportSel.Usage::"S.Work Order");
                    CustomReportSel.SetFilter("Report ID", '<>%1', 0);
                    if CustomReportSel.FindSet() then begin
                        repeat
                            SetReportSelection(CustomReportSel);
                            ReportLayoutSelection.SetTempLayoutSelected(TempReportSelection."Custom Report Layout Code");
                            if RepeatCounter = 0 then
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Customs Directory" + FileName + SalesHdr."No." + '.pdf', SalesHdr)
                            else
                                Report.SaveAsPdf(TempReportSelection."Report ID", SalesSetup."PDF S. Customs Directory" + FileName + SalesHdr."No." + '-' + Format(RepeatCounter) + '.pdf', SalesHdr);
                            RepeatCounter := RepeatCounter + 1;
                            ReportLayoutSelection.SetTempLayoutSelected('');
                            TempReportSelection.Delete();
                        until CustomReportSel.Next() = 0;
                    end else begin
                        //Print default layout
                        //RHE-TNA 16-11-2021 BDS-5853 END
                        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Work Order");
                        ReportSelections.SetFilter("Report ID", '<>%1', 0);
                        if ReportSelections.FindSet() then
                            repeat
                                if RepeatCounter = 0 then
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Customs Directory" + FileName + SalesHdr."No." + '.pdf', SalesHdr)
                                else
                                    Report.SaveAsPdf(ReportSelections."Report ID", SalesSetup."PDF S. Customs Directory" + FileName + SalesHdr."No." + '-' + Format(RepeatCounter) + '.pdf', SalesHdr);
                                RepeatCounter := RepeatCounter + 1;
                            until ReportSelections.Next() = 0;
                        //RHE-TNA 16-11-2021 BDS-5853 BEGIN
                    end;
                    //RHE-TNA 16-11-2021 BDS-5853 END
                    Message(MessageText001, RepeatCounter, SalesSetup."PDF S. Customs Directory");
                end;
            }
            action("Print Prepayment Invoice")
            {
                Image = PrintDocument;
                Ellipsis = true;
                ToolTip = 'This action will only print a Prepayment Invoice. No actual Prepayment Invoice is posted.';

                trigger OnAction()
                var
                    SalesHdr: Record "Sales Header";
                begin
                    SalesHdr.SetRange("Document Type", Rec."Document Type");
                    SalesHdr.SetRange("No.", Rec."No.");
                    ReportSelections.Print(ReportSelections.Usage::"S.Invoice Draft", SalesHdr, SalesHdr.FIELDNO("No."));
                end;
            }
            action("Print Customs Invoice")
            {
                Image = PrintDocument;
                Ellipsis = true;

                trigger OnAction()
                var
                    SalesHdr: Record "Sales Header";
                begin
                    SalesHdr.SetRange("Document Type", Rec."Document Type");
                    SalesHdr.SetRange("No.", Rec."No.");
                    ReportSelections.Print(ReportSelections.Usage::"S.Work Order", SalesHdr, SalesHdr.FIELDNO("No."));
                end;
            }
        }
        //RHE-TNA 16-11-2021..27-12-2021 BDS-5676 BEGIN
        addafter("F&unctions")
        {
            group(EDI)
            {

                action("Set EDI Status")
                {
                    Image = TransmitElectronicDoc;
                    Ellipsis = true;
                    Promoted = true;

                    trigger OnAction()
                    var
                        Options: Label 'Blank,To Send';
                        DialogDefault: Integer;
                        Instruction: Label 'Select one of the following options:';
                        Selected: Integer;
                        UpdatedMessage: Label ' EDI Status updated.';
                        CanceledMessage: Label 'Process Canceled.';
                        SalesHdrArchive: Record "Sales Header Archive";
                        ArchiveMgt: Codeunit ArchiveManagement;
                        IFLog: Record "Interface Log";
                        SendOrder: Boolean;
                    begin
                        if Rec.Status <> Rec.Status::Open then
                            Error('Status must be equal to Open. Current value is ' + Format(Rec.Status) + '.');
                        if (IFSetup.Get(IFSetup.GetIFSetupRecforDocNo(Rec."No."))) and (IFSetup."Send Sales Order Message") then begin
                            //RHE-TNA 01-03-2022 BDS-6149 BEGIN
                            SendOrder := true;
                            //Do not send orders which are received via interface when they do not need to be send back to the customer
                            IFLog.SetRange(Direction, IFLog.Direction::"From Customer");
                            IFLog.SetRange(Reference, "No.");
                            if IFLog.FindFirst() then
                                if not IFSetup."Send IF Received Orders" then
                                    SendOrder := false;

                            if SendOrder then begin
                                //RHE-TNA 01-03-2022 BDS-6149 END
                                if "EDI Status" = "EDI Status"::" " then
                                    DialogDefault := 2
                                else
                                    DialogDefault := 1;
                                Selected := Dialog.StrMenu(Options, DialogDefault, Instruction);
                                case Selected of
                                    1: //Blank
                                        begin
                                            if "EDI status" = "EDI status"::Sent then begin
                                                if Dialog.Confirm('Are you sure you want to set the EDI Status from: ' + format(xRec."EDI status") + ' to: Blank?') then begin
                                                    "EDI status" := "EDI status"::" ";
                                                    Rec.Modify(true);
                                                    Message(UpdatedMessage);
                                                end else
                                                    Message(CanceledMessage);
                                            end else begin
                                                "EDI status" := "EDI status"::" ";
                                                Rec.Modify(true);
                                                Message(UpdatedMessage);
                                            end;
                                        end;
                                    2: //To Send
                                        begin
                                            if "EDI status" = "EDI status"::Sent then begin
                                                if Dialog.Confirm('Are you sure you want to set the EDI Status from: ' + format(xRec."EDI status") + ' to: To Send?') then begin
                                                    "EDI status" := "EDI status"::"To Send";
                                                    Rec.Modify(true);
                                                    Message(UpdatedMessage);
                                                end else
                                                    Message(CanceledMessage);
                                            end else begin
                                                "EDI status" := "EDI status"::"To Send";
                                                Rec.Modify(true);
                                                Message(UpdatedMessage);
                                            end;
                                        end;
                                end;

                                //Update sales order archive to not send an old version via EDI
                                SalesHdrArchive.SetRange("Document Type", "Document Type");
                                SalesHdrArchive.SetRange("No.", "No.");
                                SalesHdrArchive.SetRange("EDI Status", SalesHdrArchive."EDI Status"::"To Send");
                                SalesHdrArchive.ModifyAll("EDI Status", SalesHdrArchive."EDI Status"::" ");
                                //Add sales order archive to send via EDI (this will already include EDI status field value as set above)
                                if "EDI Status" = "EDI Status"::"To Send" then
                                    ArchiveMgt.StoreSalesDocument(Rec, false);
                                //Reset archive header EDI Date/Time
                                SalesHdrArchive.Reset();
                                SalesHdrArchive.SetRange("Document Type", "Document Type");
                                SalesHdrArchive.SetRange("No.", "No.");
                                SalesHdrArchive.FindLast();
                                SalesHdrArchive."Last EDI Export Date/Time" := 0DT;
                                SalesHdrArchive.Modify();
                                //RHE-TNA 01-03-2022 BDS-6149 BEGIN
                            end else
                                Error('This order is received via EDI and does need to be send via EDI.');
                            //RHE-TNA 01-03-2022 BDS-6149 END
                        end else
                            Error('No EDI setup found.');
                    end;
                }
            }
        }
        //RHE-TNA 16-11-2021..27-12-2021 BDS-5676 END
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

    //RHE-TNA 16-11-2021 BDS-5676 BEGIN
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        IFLog: Record "Interface Log";
    begin
        //Check whether order should be exported and check if EDI status is set accordingly
        if SalesLinesExist() then
            if (IFSetup.Get(IFSetup.GetIFSetupRecforDocNo(Rec."No."))) and (IFSetup."Send Sales Order Message") and ("EDI status" = "EDI status"::" ") then begin
                //RHE-TNA 01-03-2022 BDS-6149 BEGIN
                IFLog.SetRange(Direction, IFLog.Direction::"From Customer");
                IFLog.SetRange(Reference, "No.");
                if (not IFLog.FindFirst()) or ((IFLog.FindFirst()) and (IFSetup."Send IF Received Orders")) then
                    //RHE-TNA 01-03-2022 BDS-6149 END
                    if not Confirm('With the current EDI Status (blank) this order will not be send to ' + CompanyName + '. \Are you sure you want to exit?') then
                        exit(false);
            end;
    end;
    //RHE-TNA 16-11-2021 BDS-5676 END

    trigger OnClosePage()
    begin
        Rec.SetFullyAllocated();
    end;

    //Global variables
    var
        ReportSelections: Record "Report Selections";
        SalesSetup: Record "Sales & Receivables Setup";
        DocPrint: Codeunit "Document-Print";
        IFSetup: Record "Interface Setup";
        TempReportSelection: Record "Report Selections" temporary;
        CustomReportSel: Record "Custom Report Selection";
        ReportLayoutSelection: Record "Report Layout Selection";
}