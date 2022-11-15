report 50037 "Export Sales Order"

//  RHE-TNA 29-11-2021..25-02-2022 BDS-5676
//  - New Report

//  RHE-TNA 01-03-2022 BDS-6149
//  - Modified trigger OnPreReport()

//  RHE-TNA 20-04-2022 BDS-6233
//  - Redesign

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        SalesHdrArch: Record "Sales Header Archive";
        SalesHdrArch2: Record "Sales Header Archive";
        SalesHdr: Record "Sales Header";
        SalesInvHdr: Record "Sales Invoice Header";
        SalesOrderSent: Boolean;
        SalesOrderInvoiced: Boolean;
        SalesOrderDeleted: Boolean;
        OrderXMLPort: XmlPort "Export Sales Order";
        FileName: Text[250];
        ExportFile: File;
        varOutStream: OutStream;
        FileNameExclDirectory: Text[250];
        ProcessedFileName: Text[250];
        FileMgt: Codeunit "File Management";
        ArchiveMgt: Codeunit ArchiveManagement;
        IFSetup: Record "Interface Setup";
    begin
        //Make a new version of the sales order archive to capture any order updates after the last archived version
        SalesHdr.Reset();
        SalesHdr.SetFilter("EDI Status", '%1|%2', SalesHdrArch."EDI status"::"To Send", SalesHdrArch."EDI Status"::Sent);
        if SalesHdr.FindSet() then
            repeat
                ArchiveMgt.StoreSalesDocument(SalesHdr, false);
                SalesHdrArch.Reset();
                SalesHdrArch.SetRange("Document Type", SalesHdrArch."Document Type"::Order);
                SalesHdrArch.SetRange("No.", SalesHdr."No.");
                SalesHdrArch.FindLast();
                SalesHdrArch."EDI Status" := SalesHdrArch."EDI Status"::"To Send";
                SalesHdrArch."Last EDI Export Date/Time" := 0DT;
                SalesHdrArch.Modify(false);
            until SalesHdr.Next() = 0;
        SalesHdr.Reset();

        //Mark Sales Orders to export
        SalesHdrArch.Reset();
        SalesHdrArch.SetRange("Document Type", SalesHdrArch."Document Type"::Order);
        SalesHdrArch.SetRange("EDI Status", SalesHdr."EDI Status"::"To Send");
        if SalesHdrArch.FindSet() then
            repeat
                //Check if order is already sent (present in change log)
                SalesOrderSent := IFSetup.CheckChangeLog(36, SalesHdrArch."No.", 'XML50015');

                //Check if later archive version is present
                SalesHdrArch2.Reset();
                SalesHdrArch2.SetRange("Document Type", SalesHdrArch."Document Type");
                SalesHdrArch2.SetRange("No.", SalesHdrArch."No.");
                SalesHdrArch2.SetFilter("Version No.", '>%1', SalesHdrArch."Version No.");
                SalesHdrArch2.SetRange(Status, SalesHdrArch.Status);
                if not SalesHdrArch2.FindLast() then begin
                    if MarkArchivedVersion(SalesHdrArch, SalesOrderSent) then
                        SalesHdrArch.Mark(true)
                    else begin
                        SalesHdrArch."EDI Status" := SalesHdrArch."EDI Status"::" ";
                        SalesHdrArch.Modify(false);
                    end;
                end else begin
                    //Found a later version with same status
                    SalesHdrArch."EDI Status" := SalesHdrArch."EDI Status"::" ";
                    SalesHdrArch.Modify(false);
                end;

            until SalesHdrArch.Next() = 0;

        //Create 1 XML file per Interface setup
        IFSetup.Reset();
        IFSetup.SetRange("Send Sales Order Message", true);
        if IFSetup.FindSet() then
            repeat
                //Set tableview to export all orders marked to export
                SalesHdrArch.MarkedOnly(true);
                SalesHdrArch.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
                if SalesHdrArch.FindSet() then begin
                    //Create one xml file containing multiple orders
                    if IFSetup."Qty. of Orders per XML" = IFSetup."Qty. of Orders per XML"::Multiple then begin
                        FileNameExclDirectory :=
                                            'SalesOrders_'
                                            + Format(WorkDate, 0, '<Day,2><Month,2><Year,2>')
                                            + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                                            + '.xml';

                        FileName := IFSetup."Sales Order Export Directory" + 'Archive\' + FileNameExclDirectory;

                        ExportFile.TextMode(true);
                        ExportFile.WriteMode(true);
                        ExportFile.Create(FileName);
                        ExportFile.CreateOutStream(varOutStream);
                        OrderXMLPort.SetTableView(SalesHdrArch);
                        OrderXMLPort.SetDestination(varOutStream);
                        OrderXMLPort.Export();
                        ExportFile.Close();

                        ProcessedFileName := IFSetup."Sales Order Export Directory" + FileNameExclDirectory;
                        FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                        repeat
                            DocumentOrderSent(SalesHdrArch, FileName, FileNameExclDirectory);
                        until SalesHdrArch.Next() = 0;
                    end else begin
                        //Create an xml file per order
                        repeat
                            SalesHdrArch2.Reset();
                            SalesHdrArch2.SetRange("Document Type", SalesHdrArch."Document Type");
                            SalesHdrArch2.SetRange("No.", SalesHdrArch."No.");
                            SalesHdrArch2.SetRange("Version No.", SalesHdrArch."Version No.");
                            SalesHdrArch2.SetRange("Doc. No. Occurrence", SalesHdrArch."Doc. No. Occurrence");
                            SalesHdrArch2.FindFirst();
                            //Wait 1 second to create a unique file name in case of an order which exports status Open and Released at the same time
                            Sleep(1000);
                            FileNameExclDirectory :=
                            'SalesOrder_'
                            + SalesHdrArch2."No." + '_'
                            + Format(WorkDate, 0, '<Day,2><Month,2><Year,2>')
                            + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                            + '.xml';

                            FileName := IFSetup."Sales Order Export Directory" + 'Archive\' + FileNameExclDirectory;

                            ExportFile.TextMode(true);
                            ExportFile.WriteMode(true);
                            ExportFile.Create(FileName);
                            ExportFile.CreateOutStream(varOutStream);
                            OrderXMLPort.SetTableView(SalesHdrArch2);
                            OrderXMLPort.SetDestination(varOutStream);
                            OrderXMLPort.Export();
                            ExportFile.Close();

                            ProcessedFileName := IFSetup."Sales Order Export Directory" + FileNameExclDirectory;
                            FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            DocumentOrderSent(SalesHdrArch2, FileName, FileNameExclDirectory);
                        until SalesHdrArch.Next() = 0;
                    end;
                end;
            until IFSetup.Next() = 0;


        SalesHdrArch.Reset();
        SalesHdrArch.SetRange("Document Type", SalesHdrArch."Document Type"::Order);
        SalesHdrArch.SetRange("Order Deleted/Invoiced", false);
        if SalesHdrArch.FindSet() then
            repeat
                SalesInvHdr.SetRange("Order No.", SalesHdrArch."No.");
                if SalesInvHdr.FindFirst() then begin
                    SalesHdrArch."Order Deleted/Invoiced" := true;
                    SalesHdrArch.Modify(false);
                end else
                    if not SalesHdr.Get(SalesHdrArch."Document Type", SalesHdrArch."No.") then begin
                        SalesHdrArch."Order Deleted/Invoiced" := true;
                        SalesHdrArch.Modify(false);
                    end;
            until SalesHdrArch.Next() = 0;
    end;

    procedure MarkArchivedVersion(var ArchiveHdr: Record "Sales Header Archive"; OrderSent: Boolean): Boolean
    var
        SalesLineArch: Record "Sales Line Archive";
        IFLog: Record "Interface Log";
    begin
        IFSetup.Get(IFSetup.GetIFSetupRecforDocNo(ArchiveHdr."No."));
        ArchiveHdr.Validate("Interface Setup Entry No.", IFSetup."Entry No.");
        ArchiveHdr.Modify(false);
        if IFSetup."Send Sales Order Message" then begin
            IFSetup.TestField("Sales Order Export Directory");

            if (IFSetup."Send New Sales Orders Only") and (OrderSent) and (IFSetup."Order Status to Send" = IFSetup."Order Status to Send"::Open) then
                exit(false); //Order is sent with Status = Open already
            if (IFSetup."Send New Sales Orders Only") and (OrderSent) and (IFSetup."Order Status to Send" = IFSetup."Order Status to Send"::"Open & Released") and (ArchiveHdr.Status = ArchiveHdr.Status::Open) then
                exit(false); //Order is sent with Status = Open already
            if (IFSetup."Send New Sales Orders Only") and (OrderSent) and (IFSetup."Order Status to Send" = IFSetup."Order Status to Send"::"Open & Released") and (ArchiveHdr.Status = ArchiveHdr.Status::Released) then
                if CheckReleasedStatusSent(ArchiveHdr."No.", ArchiveHdr."Version No.") then //Check if order is sent with Status = Released already
                    exit(false);
            if (IFSetup."Send New Sales Orders Only") and (OrderSent) and (IFSetup."Order Status to Send" = IFSetup."Order Status to Send"::Released) and (ArchiveHdr.Status = ArchiveHdr.Status::Open) then
                exit(false); //Only order with Status = Released should be send
            if (IFSetup."Send New Sales Orders Only") and (OrderSent) and (IFSetup."Order Status to Send" = IFSetup."Order Status to Send"::Released) and (ArchiveHdr.Status = ArchiveHdr.Status::Released) then
                if CheckReleasedStatusSent(ArchiveHdr."No.", ArchiveHdr."Version No.") then //Check if order is sent with Status = Released already
                    exit(false);
            if (IFSetup."Send New Sales Orders Only") and (IFSetup."Order Status to Send" = IFSetup."Order Status to Send"::Open) and (ArchiveHdr.Status = ArchiveHdr.Status::Released) then
                exit(false); //Order not be send with status = Released
            if (IFSetup."Send New Sales Orders Only") and (IFSetup."Order Status to Send" = IFSetup."Order Status to Send"::Released) and (ArchiveHdr.Status = ArchiveHdr.Status::Open) then
                exit(false); //Order not be send with status = Open

            //Do not send orders which are received via interface when they do not need to be send back to the customer
            IFLog.SetRange(Direction, IFLog.Direction::"From Customer");
            IFLog.SetRange(Reference, ArchiveHdr."No.");
            if IFLog.FindFirst() then
                if not IFSetup."Send IF Received Orders" then
                    exit(false);

            //Only send orders which have a line with a quantity
            SalesLineArch.SetRange("Document Type", ArchiveHdr."Document Type");
            SalesLineArch.SetRange("Document No.", ArchiveHdr."No.");
            SalesLineArch.SetRange("Version No.", ArchiveHdr."Version No.");
            SalesLineArch.SetRange("Doc. No. Occurrence", ArchiveHdr."Doc. No. Occurrence");
            SalesLineArch.SetFilter(Quantity, '<>%1', 0);
            if SalesLineArch.FindFirst() then
                exit(true)
            else
                exit(false);
        end else
            exit(false);
    end;

    procedure AddIFLogEntry(Error: Boolean;
        OrderNo: Code[20];
        FileName: Text;
        FileNameShort: Text)
    begin
        IFLog.Init();
        IFLog.Insert(true);
        IFLog.Source := 'Report 50037 - Export Sales Order';
        IFLog.Direction := IFLog.Direction::"To Customer";
        IFLog.Date := Today;
        IFLog.Time := Time;
        IFLog.Filename := FileName;
        IFLog."Filename Short" := FileNameShort;
        IFLog.Reference := OrderNo;
        IFLog.Modify(true);
        Commit();
    end;

    procedure DocumentOrderSent(SalesHdrArch: Record "Sales Header Archive"; FileName: Text; FileNameExclDirectory: Text)
    begin
        SalesHdrArch.Validate("Last EDI Export Date/Time", CurrentDateTime);
        SalesHdrArch.Validate("EDI status", SalesHdrArch."EDI status"::Sent);
        SalesHdrArch.Modify(false);

        AddIFLogEntry(false, SalesHdrArch."No.", FileName, FileNameExclDirectory);
        IFSetup.InsertChangeLog(36, SalesHdrArch."No.", 'XML50015');

        UpdateEDIStatusOrder(SalesHdrArch);
    end;

    procedure UpdateEDIStatusOrder(SalesHdrArch: Record "Sales Header Archive")
    var
        SalesHdr: Record "Sales Header";
    begin
        if SalesHdr.Get(SalesHdrArch."Document Type", SalesHdrArch."No.") then begin
            SalesHdr.Validate("EDI Status", SalesHdrArch."EDI Status");
            SalesHdr.Validate("Last EDI Export Date/Time", SalesHdrArch."Last EDI Export Date/Time");
            SalesHdr.Modify(false);
        end;
    end;

    procedure CheckReleasedStatusSent(OrderNo: Code[20]; VersionNo: integer): Boolean
    var
        SalesHdrArchive: Record "Sales Header Archive";
    begin
        SalesHdrArchive.SetRange("Document Type", SalesHdrArchive."Document Type"::Order);
        SalesHdrArchive.SetRange("No.", OrderNo);
        SalesHdrArchive.SetFilter("Version No.", '<%1', VersionNo);
        SalesHdrArchive.SetRange(Status, SalesHdrArchive.Status::Released);
        SalesHdrArchive.SetRange("EDI Status", SalesHdrArchive."EDI Status"::Sent);
        if SalesHdrArchive.FindFirst() then
            exit(true)
        else
            exit(false);
    end;

    trigger OnInitReport()
    begin
        IFSetup.SetRange(Type, IFSetup.Type::Customer);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = Customer.');
    end;

    trigger OnPostReport()
    var
    begin
        if GuiAllowed then
            Message('Order(s) exported.');
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        IFLog: Record "Interface Log";
}