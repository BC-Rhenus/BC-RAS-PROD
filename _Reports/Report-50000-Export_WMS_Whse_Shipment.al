report 50000 "Export WMS Whse. Shipment"

//  RHE-TNA 15-10-2020..16-11-2020 BDS-4551
//  - Modified dataitem()

//  RHE-TNA 23-11-2020 BDS-4705 
//  - Modified trigger OnAfterGetRecord()
//  - Added procedure AddIFLogEntry()

//  RHE-TNA 22-12-2020 BDS-4779
//  - Modified trigger OnAfterGetRecord()
//  - Added procedure SendShipReadyFile()

//  RHE-TNA 14-06-2021..23-06-2021 BDS-5337
//  - Modified trigger OnAfterGetRecord()
//  - Modified trigger OnInitReport()

//  RHE-TNA 26-08-2021 BDS-5563
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 16-11-2021..19-11-2021 BDS-5676 
//  - Modified trigger OnAfterGetRecord()
//  - Modified trigger OnPostReport()

//  RHE-TNA 19-01-2022 BDS-5585
//  - Modified trigger OnAfterGetRecord()
//  - Modified trigger OnInitReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = true;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
        {
            trigger OnAfterGetRecord()
            var
                ShipmentXMLPort: XmlPort "Export WMS Shipment";
                FileName: Text[250];
                FileNameComplete: Text[250];
                ExportFile: File;
                ExportFileComplete: File;
                varOutStream: OutStream;
                VarInStream: InStream;
                TempBlob: Record TempBlob temporary;
                CharactersCount: Integer;
                i: Integer;
                CharacterText: Text[1];
                TextToInsert: Text;
                TextToInsert2: Text;
                WhseShipment: Record "Warehouse Shipment Header";
                ShipReadyXMLPort: XmlPort "Export Ship Ready Order";
                SalesHdr: Record "Sales Header";
                WhseShipmentLine: Record "Warehouse Shipment Line";
                Customer: Record Customer;
                FileNameArchive: Text[250];
                FileMgt: Codeunit "File Management";
                IFSetup2: Record "Interface Setup";
                WMSReady: Boolean;
                "3PLShipmentXMLPort": XmlPort "Export 3PL Shipment";
            begin
                //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                IFSetup.GetWMSIFSetupEntryNo("Warehouse Shipment Header"."Location Code");
                IFSetup.TestField("WMS Client ID");
                IFSetup.TestField("WMS Site ID");
                IFSetup.TestField("WMS Upload Directory");
                //RHE-TNA 19-01-2022 BDS-5585 END

                WhseShipment.SetRange("No.", "Warehouse Shipment Header"."No.");
                WhseShipment.FindFirst();

                //RHE-TNA 16-11-2021..19-11-2021 BDS-5676 BEGIN    
                //Check if Sales Order was set to be send via EDI to customer and stop process if order is not set correct (if applicable)                
                EDINotSentCounter := 0;
                WMSReady := true;
                WhseShipmentLine.Reset();
                WhseShipmentLine.SetRange("No.", "Warehouse Shipment Header"."No.");
                if (WhseShipmentLine.FindFirst()) and (WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order") then
                    if (IFSetup2.Get(IFSetup2.GetIFSetupRecforDocNo(WhseShipmentLine."Source No."))) and (IFSetup2."Send Sales Order Message") then begin
                        SalesHdr.Get(SalesHdr."Document Type"::Order, WhseShipmentLine."Source No.");
                        if SalesHdr."EDI Status" = SalesHdr."EDI Status"::" " then begin
                            WMSReady := false;
                            EDINotSentCounter += 1;
                        end;
                    end;

                if WMSReady then begin
                    //RHE-TNA 16-11-2021..19-11-2021 BDS-5676 END
                    Sleep(1000); //Wait a second to get a unique Filename
                    FileName :=
                        IFSetup."WMS Upload Directory"
                        + 'Shipment_' + IFSetup."WMS Client ID" + '_'
                        + Format(Today, 0, '<Year,2><Month,2><Day,2>')
                        + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                        + '.tmp';
                    FileNameComplete :=
                        IFSetup."WMS Upload Directory"
                        + 'Shipment_' + IFSetup."WMS Client ID" + '_'
                        + Format(Today, 0, '<Year,2><Month,2><Day,2>')
                        + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                        + '.xml';

                    //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                    /*ExportFile.TextMode(true);
                    ExportFile.WriteMode(true);
                    ExportFile.Create(FileName);
                    TempBlob.Blob.CreateOutStream(varOutStream);
                    ShipmentXMLPort.SetTableView(WhseShipment);
                    ShipmentXMLPort.SetDestination(varOutStream);
                    ShipmentXMLPort.Export();*/
                    if IFSetup.Type = IFSetup.Type::"Blue Yonder WMS" then begin
                        ExportFile.TextMode(true);
                        ExportFile.WriteMode(true);
                        ExportFile.Create(FileName);
                        TempBlob.Blob.CreateOutStream(varOutStream);
                        ShipmentXMLPort.SetTableView(WhseShipment);
                        ShipmentXMLPort.SetDestination(varOutStream);
                        ShipmentXMLPort.Export();
                    end else begin
                        ExportFileComplete.TextMode(true);
                        ExportFileComplete.WriteMode(true);
                        ExportFileComplete.Create(FileNameComplete);
                        ExportFileComplete.CreateOutStream(varOutStream);
                        "3PLShipmentXMLPort".SetTableView(WhseShipment);
                        "3PLShipmentXMLPort".SetDestination(varOutStream);
                        "3PLShipmentXMLPort".Export();
                    end;
                    //RHE-TNA 19-01-2022 BDS-5585 END

                    //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                    if IFSetup.Type = IFSetup.Type::"Blue Yonder WMS" then begin
                        //RHE-TNA 19-01-2022 BDS-5585 END
                        //Load XML into BLOB to add !DOCTYPE line.
                        TempBlob.Blob.CreateInStream(varInstream);
                        CharactersCount := StrLen('?xml version="1.0" encoding="UTF-8"? standalone="no"?');
                        //Create duplicate XML file
                        ExportFileComplete.TextMode(true);
                        ExportFileComplete.WriteMode(true);
                        ExportFileComplete.Create(FileNameComplete);
                        //Add first line to XML. ?xml version'"1.0"......
                        for i := 1 to (CharactersCount + 1) do begin
                            varInstream.ReadText(CharacterText, i);
                            TextToInsert := TextToInsert + CharacterText;
                        end;
                        ExportFileComplete.Write(TextToInsert);

                        TextToInsert := '<!DOCTYPE dcsmergedata SYSTEM "../lib/interface_order_header.dtd">';
                        ExportFileComplete.Write(TextToInsert);

                        //Add the rest of the xml file
                        while not varInstream.EOS do begin
                            varInstream.ReadText(TextToInsert);
                            TextToInsert := TextToInsert;
                            while StrPos(TextToInsert, '_XMLConvert') > 0 do begin
                                //Copy text until _XMLConvert text
                                TextToInsert2 := CopyStr(TextToInsert, 1, StrPos(TextToInsert, '_XMLConvert') - 1);
                                //Copy text after _XMLConvert text
                                TextToInsert := CopyStr(TextToInsert, StrPos(TextToInsert, '_XMLConvert') + StrLen('_XMLConvert'));
                                TextToInsert := TextToInsert2 + TextToInsert;
                            end;
                            ExportFileComplete.Write(TextToInsert);
                        end;
                        //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                    end;
                    //RHE-TNA 19-01-2022 BDS-5585 END

                    //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                    /*ExportFile.Close();
                    ExportFileComplete.Close();
                    Erase(FileName); //Delete temp file*/
                    if IFSetup.Type = IFSetup.Type::"Blue Yonder WMS" then begin
                        ExportFile.Close();
                        Erase(FileName); //Delete temp file
                    end;
                    ExportFileComplete.Close();
                    //RHE-TNA 19-01-2022 BDS-5585 END

                    WhseShipment.Validate("Exported to WMS", true);
                    WhseShipment.Modify(true);
                    RecordCount := RecordCount + 1;
                    Sleep(500);

                    //RHE-TNA 15-10-2020..16-11-2020 BDS-4551 BEGIN
                    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                    //if IFSetup."Send Ship Ready Message" then begin
                    //RHE-TNA 14-06-2021 BDS-5337 END
                    WhseShipmentLine.Reset();
                    WhseShipmentLine.SetRange("No.", "Warehouse Shipment Header"."No.");
                    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                    //if (WhseShipmnentLine.FindFirst()) and (WhseShipmnentLine."Source Document" = WhseShipmnentLine."Source Document"::"Sales Order") then
                    if (WhseShipmentLine.FindFirst()) and (WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order") then begin
                        //RHE-TNA 14-06-2021 BDS-5337 END
                        SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
                        SalesHdr.SetRange("No.", WhseShipmentLine."Source No.");
                        if SalesHdr.FindFirst() then begin
                            //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                            Customer.SetRange("No.", SalesHdr."Sell-to Customer No.");
                            if Customer.FindFirst() and Customer."Send Ship Ready Message" and SendShipReadyFile(SalesHdr."No.") then begin
                                //RHE-TNA 26-08-2021 BDS-5563 BEGIN
                                /*
                                IFSetup2.Get(IFSetup2.GetIFSetupRecforDocNo(SalesHdr."No."));
                                if IFSetup2."Send Ship Ready Message" then begin
                                */
                                if (IFSetup2.Get(IFSetup2.GetIFSetupRecforDocNo(SalesHdr."No."))) and (IFSetup2."Send Ship Ready Message") then begin
                                    //RHE-TNA 26-08-2021 BDS-5563 END
                                    IFSetup2.TestField("Ship Confirmation Directory");
                                    //RHE-TNA 14-06-2021 BDS-5337 END
                                    /*RHE-TNA 23-06-2021 BDS-5337 BEGIN
                                    Customer.SetRange("No.", SalesHdr."Sell-to Customer No.");
                                    //RHE-TNA 22-12-2020 BDS-4779 BEGIN
                                    //if Customer.FindFirst() and Customer."Send Ship Ready Message" then begin
                                    if Customer.FindFirst() and Customer."Send Ship Ready Message" and SendShipReadyFile(SalesHdr."No.") then begin
                                    //RHE-TNA 22-12-2020 BDS-4779 END
                                    RHE-TNA 23-06-2021 BDS-5337 END*/
                                    FileName :=
                                        IFSetup2."Ship Ready Export Directory"
                                        + 'ShipReady_' + SalesHdr."No." + '_'
                                        + Format(Today, 0, '<Year,2><Month,2><Day,2>')
                                        + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                                        + '.xml';

                                    ExportFile.TextMode(true);
                                    ExportFile.WriteMode(true);
                                    ExportFile.Create(FileName);
                                    ExportFile.CreateOutStream(varOutStream);
                                    ShipReadyXMLPort.SetTableView(SalesHdr);
                                    ShipReadyXMLPort.SetDestination(varOutStream);
                                    ShipReadyXMLPort.Export();
                                    ExportFile.Close();

                                    //RHE-TNA 23-11-2020 BDS-4705 BEGIN
                                    FileNameArchive := 'ShipReady_' + SalesHdr."No." + '_'
                                       + Format(Today, 0, '<Year,2><Month,2><Day,2>')
                                       + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                                       + '.xml';
                                    AddIFLogEntry(false, SalesHdr."No.", IFSetup2."Ship Ready Export Directory" + 'Archive\' + FileNameArchive, FileNameArchive);

                                    FileNameArchive :=
                                       IFSetup2."Ship Ready Export Directory" + 'Archive\'
                                       + FileNameArchive;
                                    FileMgt.CopyServerFile(FileName, FileNameArchive, true);
                                    //RHE-TNA 23-11-2020 BDS-4705 END
                                end;
                            end;
                        end;
                        //RHE-TNA 15-10-2020..16-11-2020 BDS-4551 END
                        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                    end;
                    //RHE-TNA 14-06-2021 BDS-5337 END
                    //RHE-TNA 16-11-2021 BDS-5676 BEGIN
                end;
                //RHE-TNA 16-11-2021 BDS-5676 END
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
        IFLog.Source := 'Report 50000 - Export Ship Ready File';
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

    //RHE-TNA 22-12-2020 BDS-4779 BEGIN
    procedure SendShipReadyFile(OrderNo: Code[20]): Boolean
    var
        IFLog: Record "Interface Log";
    begin
        IFLog.SetRange(Source, 'Report 50000 - Export Ship Ready File');
        IFLog.SetRange(Direction, IFLog.Direction::"To Customer");
        IFLog.SetRange(Reference, OrderNo);
        if IFLog.FindFirst() then
            exit(false)
        else
            exit(true);
    end;
    //RHE-TNA 22-12-2020 BDS-4779 END

    trigger OnInitReport()
    //Local variables
    var
    begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        /*RHE-TNA 19-01-2022 BDS-5585 BEGIN
        IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = WMS.');
        //RHE-TNA 14-06-2021 BDS-5337 END
        IFSetup.TestField("WMS Client ID");
        IFSetup.TestField("WMS Upload Directory");
        RHE-TNA 19-01-2022 BDS-5585 END*/
    end;

    trigger OnPostReport()
    begin
        if GuiAllowed then begin
            Message(Format(RecordCount) + ' shipment(s) exported to WMS.');
            //RHE-TNA 16-11-2021 BDS-5676 BEGIN
            if EDINotSentCounter > 0 then
                Message(Format(EDINotSentCounter) + ' shipment(s) not sent to WMS as the Sales Order was not sent (EDI) to ' + CompanyName);
            //RHE-TNA 16-11-2021 BDS-5676 END
        end;
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        RecordCount: Integer;
        EDINotSentCounter: Integer;
}