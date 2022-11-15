report 50030 "Import WMS Inventory"

//  RHE-TNA 17-07-2020 BDS-4323
//  - New Report

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnInitReport()

//  RHE-TNA 04-01-2022 BDS-5975
//  - Modified trigger OnPreReport()

//  RHE-TNA 03-02-2022 BDS-5585
//  - Modified trigger OnPreReport()
//  - Modified trigger OnInitReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        FileName: Text;
        FileInStream: InStream;
        ImportFile: Record File;
        File: File;
        ImportInventoryUpdate: XmlPort "Import WMS Inv. Update";
        FileMgt: Codeunit "File Management";
        ProcessedFileName: Text;
        ProcessedCount: Integer;
        TotalCount: Integer;
        FileDeletionDate: Date;
        Import3PLInventoryUpdate: XmlPort "Import 3PL Inv. Update";
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

                //Import file        
                ImportFile.SetRange(Path, IFSetup."WMS Download Directory");
                ImportFile.SetRange("Is a file", true);
                ImportFile.SetFilter(Name, IFSetup."WMS Client ID" + '_BUSINESS_CENTRAL_UITL*.xml');
                if ImportFile.FindSet() then
                    repeat
                        TotalCount := TotalCount + 1;
                        FileName := ImportFile.Path + '\' + ImportFile.Name;
                        if File.Open(FileName) then begin
                            File.CreateInStream(FileInStream);
                            //RHE-TNA 04-01-2022 BDS-5975 BEGIN
                            /*Clear(ImportInventoryUpdate);
                            ImportInventoryUpdate.SetSource(FileInStream);
                            ImportInventoryUpdate.SetFileName(FileName);
                            if ImportInventoryUpdate.Import() then begin*/
                            ImportOK := false;
                            case IFSetup.Type of
                                IFSetup.Type::"Blue Yonder WMS":
                                    begin
                                        Clear(ImportInventoryUpdate);
                                        ImportInventoryUpdate.SetSource(FileInStream);
                                        //RHE-TNA 02-02-2022 BDS-5585 BEGIN
                                        //ImportInventoryUpdate.SetFileName(FileName);
                                        ImportInventoryUpdate.SetFileName(FileName, IFSetup."Entry No.");
                                        //RHE-TNA 02-02-2022 BDS-5585 END
                                        if ImportInventoryUpdate.Import() then
                                            ImportOK := true;
                                    end;
                                IFSetup.Type::"External WMS":
                                    begin
                                        Clear(Import3PLInventoryUpdate);
                                        Import3PLInventoryUpdate.SetSource(FileInStream);
                                        Import3PLInventoryUpdate.SetFileName(FileName, IFSetup."Entry No.");
                                        if Import3PLInventoryUpdate.Import() then
                                            ImportOK := true;
                                    end;
                            end;
                            if ImportOK then begin
                                //RHE-TNA 04-01-2022 BDS-5975 END
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
                //RHE-TNA 03-02-2022 BDS-5585 BEGIN
            until IFSetup.Next() = 0;
        //RHE-TNA 03-02-2022 BDS-5585 END

        if GuiAllowed then
            Message(Format(TotalCount) + ' file(s) found, of which ' + Format(ProcessedCount) + ' file(s) imported succesfully.');
    end;

    trigger OnInitReport()
    begin
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        /*
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = WMS.');
        //RHE-TNA 14-06-2021 BDS-5337 END
        IFSetup.TestField("WMS Download Directory");
        IFSetup.TestField("WMS Download Dir. Processed");
        IFSetup.TestField("WMS Client ID");
        */
        //RHE-TNA 03-02-2022 BDS-5585 END
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
}