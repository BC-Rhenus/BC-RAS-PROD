report 50018 "Export Sales Invoice/Shipment"

//  RHE-TNA 08-04-2020 BDS-4089 BEGIN
//  - Modified Trigger OnAfterGetRecord()

//  RHE-TNA 23-11-2020 BDS-4705 
//  - Modified trigger OnAfterGetRecord()
//  - Added procedure AddIFLogEntry()

//  RHE-TNA 22-12-2020 BDS-4779
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnAfterGetRecord()
//  - Modified trigger OnInitReport()

//  RHE-TNA 27-05-2022 BDS-6366
//  - Modified trigger OnAfterGetRecord()
//  - Deleted procedure ProcessFTPFile()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            trigger OnPreDataItem()
            begin
                "Sales Invoice Header".SetRange("Posting Date", CalcDate('<-CM-1M>', WorkDate()), WorkDate());
            end;

            trigger OnAfterGetRecord()
            var
                SalesInvoiceHdr: Record "Sales Invoice Header";
                SalesInvoiceLine: Record "Sales Invoice Line";
                Customer: Record Customer;
                InvoiceXMLPort: XmlPort "Export Sales Invoice";
                FileName: Text[250];
                ExportFile: File;
                varOutStream: OutStream;
                FileNameExclDirectory: Text[250];
                ProcessedFileName: Text[250];
                FileMgt: Codeunit "File Management";
                IFRecordParam: Record "Interface Record Parameters";
                Export: Boolean;
            begin
                //Check if customer is setup to send EDI invoice
                Customer.Get("Sales Invoice Header"."Sell-to Customer No.");
                if Customer."Send EDI Invoice" then begin
                    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                    IFSetup.Get(IFSetup.GetIFSetupRecforDocNo("Sales Invoice Header"."Order No."));
                    IFSetup.TestField("Ship Confirmation Directory");
                    //RHE-TNA 14-06-2021 BDS-5337 END

                    //RHE-TNA 22-12-2020 BDS-4779 BEGIN
                    //Check if a Ship Ready file was sent and feedback is processed
                    if (Customer."Send Ship Ready Message") and (IFSetup."Send Ship Ready Message") then begin
                        IFRecordParam.Reset();
                        IFRecordParam.SetRange("Source Type", IFRecordParam."Source Type"::Order);
                        IFRecordParam.SetRange("Source No.", "Sales Invoice Header"."Order No.");
                        IFRecordParam.SetFilter(IFRecordParam.Param4, '<>%1', '');
                        if IFRecordParam.FindFirst() then
                            Export := true
                        else
                            Export := false;
                    end else
                        Export := true;
                    //RHE-TNA 22-12-2020 BDS-4779 END

                    //RHE-TNA 22-12-2020 BDS-4779 BEGIN
                    //Check if invoice is already sent (present in change log)
                    //if not IFSetup.CheckChangeLog(112, "Sales Invoice Header"."No.", 'XML50007') then begin
                    if (not IFSetup.CheckChangeLog(112, "Sales Invoice Header"."No.", 'XML50007')) and (Export) then begin
                        //RHE-TNA 22-12-2020 BDS-4779 END
                        SalesInvoiceLine.SetRange("Document No.", "Sales Invoice Header"."No.");
                        SalesInvoiceLine.SetFilter(Quantity, '<>%1', 0);
                        if SalesInvoiceLine.FindFirst() then begin
                            SalesInvoiceHdr.SetRange("No.", "Sales Invoice Header"."No.");
                            SalesInvoiceHdr.FindFirst();
                            //RHE-TNA 08-04-2020 BDS-4089 BEGIN
                            //First upload to Archive directory to be sure the file can be copied to a second directory before it is moved by another process
                            //FileName := IFSetup."Ship Confirmation Directory"
                            //+'ShipConfirm_'
                            FileNameExclDirectory :=
                            'ShipConfirm_'
                            //RHE-TNA 08-04-2020 BDS-4089 END
                            + "Sales Invoice Header"."No." + '_'
                            + Format(WorkDate, 0, '<Day,2><Month,2><Year,2>')
                            + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                            + '.xml';

                            //RHE-TNA 08-04-2020 BDS-4089 BEGIN
                            FileName := IFSetup."Ship Confirmation Directory" + 'Archive\' + FileNameExclDirectory;
                            //RHE-TNA 08-04-2020 BDS-4089 END

                            ExportFile.TextMode(true);
                            ExportFile.WriteMode(true);
                            ExportFile.Create(FileName);
                            ExportFile.CreateOutStream(varOutStream);
                            InvoiceXMLPort.SetTableView(SalesInvoiceHdr);
                            InvoiceXMLPort.SetDestination(varOutStream);
                            InvoiceXMLPort.Export();
                            ExportFile.Close();

                            //RHE-TNA 23-11-2020 BDS-4705 BEGIN
                            AddIFLogEntry(false, "Sales Invoice Header"."No.", FileName, FileNameExclDirectory);
                            //RHE-TNA 23-11-2020 BDS-4705 END

                            //RHE-TNA 08-04-2020 BDS-4089 BEGIN
                            ProcessedFileName := IFSetup."Ship Confirmation Directory" + FileNameExclDirectory;
                            FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            //RHE-TNA 08-04-2020 BDS-4089 END                            
                        end;
                        IFSetup.InsertChangeLog(112, "Sales Invoice Header"."No.", 'XML50007');
                    end;
                end;
            end;
        }
    }

    //RHE-TNA 23-11-2020 BDS-4705 BEGIN
    procedure AddIFLogEntry(Error: Boolean; OrderNo: Code[20]; FileName: Text; FileNameShort: Text)
    var
        IFLog: Record "Interface Log";
    begin
        IFLog.Init();
        IFLog.Insert(true);
        IFLog.Source := 'Report 50018 - Export Sales Invoice';
        IFLog.Direction := IFLog.Direction::"To Customer";
        IFLog.Date := Today;
        IFLog.Time := Time;
        IFLog.Filename := FileName;
        IFLog."Filename Short" := FileNameShort;
        IFLog.Reference := OrderNo;
        IFLog.Modify(true);
        Commit();
    end;
    //RHE-TNA 23-11-2020 BDS-4705 END

    trigger OnInitReport()
    begin
        CurrReport.Language(1033);
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        //IFSetup.TestField("Ship Confirmation Directory");
        IFSetup.SetRange(Type, IFSetup.Type::Customer);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = Customer.');
        //RHE-TNA 14-06-2021 BDS-5337 END
    end;

    trigger OnPostReport()
    var
    begin
        if GuiAllowed then
            Message('Invoice(s) exported.');
    end;


    //Global variables
    var
        IFSetup: Record "Interface Setup";
}