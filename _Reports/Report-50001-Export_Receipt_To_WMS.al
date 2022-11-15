report 50001 "Export Whse. Receipt to WMS"

//RHE-TNA 06-03-2020..14-05-2020 BDS-3866
//  - Modified dataitem Warehouse Receipt Header trigger OnAfterGetRecord

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnInitReport()

//  RHE-TNA 19-01-2022 BDS-5585
//  - Modified trigger OnAfterGetRecord()
//  - Modified trigger OnInitReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem("Warehouse Receipt Header"; "Warehouse Receipt Header")
        {
            trigger OnAfterGetRecord()
            var
                ReceiptXMLPort: XmlPort "Export WMS Receipt";
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
                WhseReceipt: Record "Warehouse Receipt Header";
                ResEntry: Record "Reservation Entry";
                WhseReceiptLine: Record "Warehouse Receipt Line";
                SerialXMLPort: XmlPort "Export WMS Serial No.";
                "3PLReceiptXMLPort": XmlPort "Export 3PL Receipt";
            begin
                //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                IFSetup.GetWMSIFSetupEntryNo("Warehouse Receipt Header"."Location Code");
                IFSetup.TestField("WMS Client ID");
                IFSetup.TestField("WMS Site ID");
                IFSetup.TestField("WMS Upload Directory");
                //RHE-TNA 19-01-2022 BDS-5585 END

                Sleep(1000); //Wait a second to get a unique Filename
                WhseReceipt.SetRange("No.", "Warehouse Receipt Header"."No.");
                WhseReceipt.FindFirst();
                FileName :=
                    IFSetup."WMS Upload Directory"
                    + 'Receipt_' + IFSetup."WMS Client ID" + '_'
                    + Format(Today, 0, '<Year,2><Month,2><Day,2>')
                    + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                    + '.tmp';
                FileNameComplete :=
                    IFSetup."WMS Upload Directory"
                    + 'Receipt_' + IFSetup."WMS Client ID" + '_'
                    + Format(Today, 0, '<Year,2><Month,2><Day,2>')
                    + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                    + '.xml';

                //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                /*ExportFile.TextMode(true);
                ExportFile.WriteMode(true);
                ExportFile.Create(FileName);
                TempBlob.Blob.CreateOutStream(varOutStream);
                ReceiptXMLPort.SetTableView(WhseReceipt);
                ReceiptXMLPort.SetDestination(varOutStream);
                ReceiptXMLPort.Export();*/
                if IFSetup.Type = IFSetup.Type::"Blue Yonder WMS" then begin
                    ExportFile.TextMode(true);
                    ExportFile.WriteMode(true);
                    ExportFile.Create(FileName);
                    TempBlob.Blob.CreateOutStream(varOutStream);
                    ReceiptXMLPort.SetTableView(WhseReceipt);
                    ReceiptXMLPort.SetDestination(varOutStream);
                    ReceiptXMLPort.Export();
                end else begin
                    ExportFileComplete.TextMode(true);
                    ExportFileComplete.WriteMode(true);
                    ExportFileComplete.Create(FileNameComplete);
                    ExportFileComplete.CreateOutStream(varOutStream);
                    "3PLReceiptXMLPort".SetTableView(WhseReceipt);
                    "3PLReceiptXMLPort".SetDestination(varOutStream);
                    "3PLReceiptXMLPort".Export();
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

                    TextToInsert := '<!DOCTYPE dcsmergedata SYSTEM "../lib/interface_pre_advice_header.dtd">';
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

                //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                //RHE-TNA 06-03-2020..14-05-2020 BDS-3866 BEGIN
                //if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then begin
                if (IFSetup.Type = IFSetup.Type::"Blue Yonder WMS") and (IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016) then begin
                    //RHE-TNA 19-01-2022 BDS-5585 END
                    Sleep(1000); //Wait a second to get a unique Filename
                    WhseReceiptLine.SetRange("No.", "Warehouse Receipt Header"."No.");
                    if WhseReceiptLine.FindFirst() then begin
                        ResEntry.SetRange("Source Type", WhseReceiptLine."Source Type");
                        ResEntry.SetRange("Source Subtype", WhseReceiptLine."Source Subtype");
                        ResEntry.SetRange("Source ID", WhseReceiptLine."Source No.");
                        ResEntry.SetFilter("Serial No.", '<>%1', '');
                        if ResEntry.FindSet() then begin
                            FileName :=
                                IFSetup."WMS Upload Directory"
                                + 'Receipt_' + 'SN-' + IFSetup."WMS Client ID" + '_'
                                + Format(Today, 0, '<Year,2><Month,2><Day,2>')
                                + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                                + '.tmp';
                            FileNameComplete :=
                                IFSetup."WMS Upload Directory"
                                + 'Receipt_' + 'SN-' + IFSetup."WMS Client ID" + '_'
                                + Format(Today, 0, '<Year,2><Month,2><Day,2>')
                                + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                                + '.xml';

                            ExportFile.TextMode(true);
                            ExportFile.WriteMode(true);
                            ExportFile.Create(FileName);
                            Clear(TempBlob);
                            TempBlob.Blob.CreateOutStream(varOutStream);
                            SerialXMLPort.SetTableView(ResEntry);
                            SerialXMLPort.SetDestination(varOutStream);
                            SerialXMLPort.Export();

                            //Load XML into BLOB to add !DOCTYPE line.
                            TempBlob.Blob.CreateInStream(varInstream);
                            CharactersCount := StrLen('?xml version="1.0" encoding="UTF-8"? standalone="no"?');
                            //Create duplicate XML file
                            ExportFileComplete.TextMode(true);
                            ExportFileComplete.WriteMode(true);
                            ExportFileComplete.Create(FileNameComplete);
                            //Add first line to XML. ?xml version'"1.0"......
                            TextToInsert := '';
                            for i := 1 to (CharactersCount + 1) do begin
                                VarInStream.ReadText(CharacterText, i);
                                TextToInsert := TextToInsert + CharacterText;
                            end;
                            ExportFileComplete.Write(TextToInsert);

                            TextToInsert := '<!DOCTYPE dcsmergedata SYSTEM "../lib/interface_serial_number.dtd">';
                            ExportFileComplete.Write(TextToInsert);

                            //Add the rest of the xml file
                            while not varInstream.EOS do begin
                                varInstream.ReadText(TextToInsert);
                                TextToInsert := TextToInsert;
                                ExportFileComplete.Write(TextToInsert);
                            end;

                            ExportFile.Close();
                            ExportFileComplete.Close();
                            //Delete temp file
                            Erase(FileName);
                        end;
                    end;
                end;
                //RHE-TNA 06-03-2020..14-05-2020 BDS-3866 END

                WhseReceipt.Validate("Exported to WMS", true);
                WhseReceipt.Modify(true);
                RecordCount := RecordCount + 1;
                Sleep(500);
            end;
        }
    }

    trigger OnInitReport()
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
        IFSetup.TestField("WMS Upload Directory");
        RHE-TNA 19-01-2022 BDS-5585 END*/
    end;

    trigger OnPostReport()
    begin
        if GuiAllowed then
            Message(Format(RecordCount) + ' receipt(s) exported to WMS.');
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        RecordCount: Integer;
}