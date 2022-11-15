report 50003 "Import WMS MAN & ITL"

//  RHE-TNA 17-03-2020 BDS-3866
//  - Modified trigger OnPreReport

//  RHE-TNA 14-05-2020..28-05-2020 BDS-4147
//  - Modfied trigger OnPreReport --> 28-05-2020: Removed modification due to not using Kitting functionality in WMS

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnInitReport

//  RHE-TNA 03-01-2022 BDS-5972
//  - Modified trigger OnPreReport()

//  RHE-TNA 03-02-2022 BDS-5585
//  - Modified trigger OnPreReport()
//  - Modified trigger OnInitReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;
    Caption = 'Import WMS Shipments & Receipts';

    trigger OnPreReport()
    var
        FileName: Text;
        FileInStream: InStream;
        ImportFile: Record File;
        File: File;
        ImportShipment: XmlPort "Import WMS Shipment";
        ImportReceipt: XmlPort "Import WMS Receipt";
        ImportSN: XmlPort "Import WMS Serial No.";
        FileMgt: Codeunit "File Management";
        ProcessedFileName: Text;
        ProcessedCount: Integer;
        TotalCount: Integer;
        FileDeletionDate: Date;
        Import3PLFile: XmlPort "Import 3PL Shipment & Receipt";
        ImportOK: Boolean;
    Begin
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        IFSetup.SetRange(Active, true);
        IFSetup.SetFilter(Type, '%1|%2', IFSetup.Type::"Blue Yonder WMS", IFSetup.Type::"External WMS");
        if not IFSetup.FindSet() then
            Error('No (active) Interface Setup record exists with Type = WMS or type = External WMS.')
        else
            repeat
                IFSetup.TestField("WMS Download Directory");
                IFSetup.TestField("WMS Download Dir. Processed");
                IFSetup.TestField("WMS Client ID");
                //RHE-TNA 03-02-2022 BDS-5585 END

                //Import shipment file        
                ImportFile.SetRange(Path, IFSetup."WMS Download Directory");
                ImportFile.SetRange("Is a file", true);
                ImportFile.SetFilter(Name, IFSetup."WMS Client ID" + '_BUSINESS_CENTRAL_SHP*.xml');
                if ImportFile.FindSet() then
                    repeat
                        TotalCount := TotalCount + 1;
                        FileName := ImportFile.Path + '\' + ImportFile.Name;
                        if File.Open(FileName) then begin
                            File.CreateInStream(FileInStream);
                            //RHE-TNA 03-01-2022 BDS-5972 BEGIN
                            /*Clear(ImportShipment);
                            ImportShipment.SetSource(FileInStream);
                            ImportShipment.SetFileName(FileName);
                            if ImportShipment.Import() then begin*/
                            ImportOK := false;
                            case IFSetup.Type of
                                IFSetup.Type::"Blue Yonder WMS":
                                    begin
                                        Clear(ImportShipment);
                                        ImportShipment.SetSource(FileInStream);
                                        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
                                        //ImportShipment.SetFileName(FileName);
                                        ImportShipment.SetFileName(FileName, IFSetup."Entry No.");
                                        //RHE-TNA 03-02-2022 BDS-5585 END
                                        if ImportShipment.Import() then
                                            ImportOK := true;
                                    end;
                                IFSetup.Type::"External WMS":
                                    begin
                                        Clear(Import3PLFile);
                                        Import3PLFile.SetSource(FileInStream);
                                        Import3PLFile.SetFileName(FileName);
                                        if Import3PLFile.Import() then
                                            ImportOK := true;
                                    end;
                            end;
                            if ImportOK then begin
                                //RHE-TNA 03-01-2022 BDS-5972 END
                                //Copy to processed directory
                                File.Close();
                                if StrPos(ImportFile.Name, '.xml') - 1 > 0 then
                                    ProcessedFileName := IFSetup."WMS Download Dir. Processed" + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.xml') - 1)
                                else
                                    ProcessedFileName := IFSetup."WMS Download Dir. Processed" + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.XML') - 1);
                                ProcessedFileName := ProcessedFileName + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.xml';
                                FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                                FileMgt.DeleteServerFile(FileName);
                                ProcessedCount := ProcessedCount + 1;
                            end else begin
                                File.Close();
                                Message(GetLastErrorText);
                            end;
                        end;
                    until ImportFile.Next() = 0;

                //Import receipt file        
                ImportFile.SetRange(Path, IFSetup."WMS Download Directory");
                ImportFile.SetRange("Is a file", true);
                ImportFile.SetFilter(Name, IFSetup."WMS Client ID" + '_BUSINESS_CENTRAL_ITL*.xml');
                if ImportFile.FindSet() then
                    repeat
                        TotalCount := TotalCount + 1;
                        FileName := ImportFile.Path + '\' + ImportFile.Name;
                        if File.Open(FileName) then begin
                            File.CreateInStream(FileInStream);
                            //RHE-TNA 03-01-2022 BDS-5972 BEGIN
                            /*Clear(ImportReceipt);
                            ImportReceipt.SetSource(FileInStream);
                            ImportReceipt.SetFileName(FileName);
                            if ImportReceipt.Import() then begin*/
                            ImportOK := false;
                            case IFSetup.Type of
                                IFSetup.Type::"Blue Yonder WMS":
                                    begin
                                        Clear(ImportReceipt);
                                        ImportReceipt.SetSource(FileInStream);
                                        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
                                        //ImportReceipt.SetFileName(FileName);
                                        ImportReceipt.SetFileName(FileName, IFSetup."Entry No.");
                                        //RHE-TNA 03-02-2022 BDS-5585 END
                                        if ImportReceipt.Import() then
                                            ImportOK := true;
                                    end;
                                IFSetup.Type::"External WMS":
                                    begin
                                        Clear(Import3PLFile);
                                        Import3PLFile.SetSource(FileInStream);
                                        Import3PLFile.SetFileName(FileName);
                                        if Import3PLFile.Import() then
                                            ImportOK := true;
                                    end;
                            end;
                            if ImportOK then begin
                                //RHE-TNA 03-01-2022 BDS-5972 END
                                //Copy to processed directory
                                File.Close();
                                if StrPos(ImportFile.Name, '.xml') - 1 > 0 then
                                    ProcessedFileName := IFSetup."WMS Download Dir. Processed" + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.xml') - 1)
                                else
                                    ProcessedFileName := IFSetup."WMS Download Dir. Processed" + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.XML') - 1);
                                ProcessedFileName := ProcessedFileName + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.xml';
                                FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                                FileMgt.DeleteServerFile(FileName);
                                ProcessedCount := ProcessedCount + 1;
                            end else begin
                                File.Close();
                                if GuiAllowed then
                                    Message(GetLastErrorText);
                            end;
                        end;
                    until ImportFile.Next() = 0;

                //RHE-TNA 17-03-2020 BDS-3866 BEGIN
                //Import Serial Number file
                //RHE-TNA 03-01-2022 BDS-5972 BEGIN
                if IFSetup.Type = IFSetup.Type::"Blue Yonder WMS" then begin
                    //RHE-TNA 03-01-2022 BDS-5972 END
                    ImportFile.SetRange(Path, IFSetup."WMS Download Directory");
                    ImportFile.SetRange("Is a file", true);
                    ImportFile.SetFilter(Name, IFSetup."WMS Client ID" + '_BUSINESS_CENTRAL_SRN*.xml');
                    if ImportFile.FindSet() then
                        repeat
                            TotalCount := TotalCount + 1;
                            FileName := ImportFile.Path + '\' + ImportFile.Name;
                            if File.Open(FileName) then begin
                                File.CreateInStream(FileInStream);
                                Clear(ImportReceipt);
                                ImportSN.SetSource(FileInStream);
                                ImportSN.SetFileName(FileName);
                                if ImportSN.Import() then begin
                                    //Copy to processed directory
                                    File.Close();
                                    if StrPos(ImportFile.Name, '.xml') - 1 > 0 then
                                        ProcessedFileName := IFSetup."WMS Download Dir. Processed" + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.xml') - 1)
                                    else
                                        ProcessedFileName := IFSetup."WMS Download Dir. Processed" + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.XML') - 1);
                                    ProcessedFileName := ProcessedFileName + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.xml';
                                    FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                                    FileMgt.DeleteServerFile(FileName);
                                    ProcessedCount := ProcessedCount + 1;
                                end else begin
                                    File.Close();
                                    if GuiAllowed then
                                        Message(GetLastErrorText);
                                end;
                            end;
                        until ImportFile.Next() = 0;
                    //RHE-TNA 17-03-2020 BDS-3866 END
                    //RHE-TNA 03-01-2022 BDS-5972 BEGIN
                end;
                //RHE-TNA 03-01-2022 BDS-5972 END

                //RHE-TNA 03-02-2022 BDS-5585 BEGIN
            until IFSetup.Next() = 0;
        //RHE-TNA 03-02-2022 BDS-5585 END

        if GuiAllowed then
            Message(Format(TotalCount) + ' file(s) found, of which ' + Format(ProcessedCount) + ' file(s) imported.');
    end;

    trigger OnInitReport()
    begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        /*RHE-TNA 03-02-2022 BDS-5585 BEGIN
        IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = WMS.');
        //RHE-TNA 14-06-2021 BDS-5337 END
        IFSetup.TestField("WMS Download Directory");
        IFSetup.TestField("WMS Download Dir. Processed");
        IFSetup.TestField("WMS Client ID");
        RHE-TNA 03-02-2022 BDS-5585 END*/
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
}