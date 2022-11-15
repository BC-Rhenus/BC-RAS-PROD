report 50016 "Import Webshop Order"

//  RHE-TNA 08-04-2020 BDS-4089 BEGIN
//  - Modified Trigger OnPreReport()

//  RHE-TNA 23-11-2020 BDS-4705 
//  - Modified trigger OnPreReport()
//  - Added procedure AddIFLogEntry()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreReport()
//  - Modified procedure AddIFLogEntry()
//  - Modified trigger OnInitReport()

//  RHE-TNA 27-05-2022 BDS-6366
//  - Modified trigger OnPreReport()
//  - Deleted procedure ProcessFTPFile()

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
        ImportWebOrder: XmlPort "Import Webshop Order";
        FileMgt: Codeunit "File Management";
        ProcessedFileName: Text;
        ProcessedCount: Integer;
        TotalCount: Integer;
        FileDeletionDate: Date;
        IFLog: Record "Interface Log";
        SalesHdr: Record "Sales Header";
        ProcessedFileNameShort: Text;
    Begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        Repeat
            IFSetup.TestField("Order Import Directory");
            IFSetup.TestField("Order Import Dir. Processed");
            IFSetup.TestField("Order Import Dir. Error");

            IFSetup."In Progress" := true;
            IFSetup.Modify(false);
            Commit();
            //RHE-TNA 14-06-2021 BDS-5337 END

            //Import order file        
            ImportFile.SetRange(Path, IFSetup."Order Import Directory");
            ImportFile.SetRange("Is a file", true);
            ImportFile.SetFilter(Name, '*.csv');
            if ImportFile.FindSet() then
                repeat
                    TotalCount := TotalCount + 1;
                    FileName := ImportFile.Path + '\' + ImportFile.Name;
                    if File.Open(FileName) then begin
                        File.CreateInStream(FileInStream);
                        Clear(ImportWebOrder);
                        ImportWebOrder.SetSource(FileInStream);
                        ImportWebOrder.SetFileName(FileName);
                        if ImportWebOrder.Import() then begin
                            //Copy to processed directory
                            File.Close();

                            //RHE-TNA 08-04-2020 BDS-4089 BEGIN
                            //ProcessedFileName := IFSetup."Order Import Dir. Processed" + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.csv') - 1);
                            //ProcessedFileName := ProcessedFileName + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.csv';
                            //FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            ProcessedFileName := IFSetup."Order Import Dir. Processed" + ImportFile.Name;
                            FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            //Upload to Archive directory
                            //RHE-TNA 23-11-2020 BDS-4705 BEGIN
                            //ProcessedFileName := IFSetup."Order Import Dir. Processed" + 'Archive\' + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.csv') - 1);
                            //ProcessedFileName := ProcessedFileName + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.csv';
                            ProcessedFileNameShort := CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.csv') - 1) + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.csv';
                            ProcessedFileName := IFSetup."Order Import Dir. Processed" + 'Archive\' + ProcessedFileNameShort;
                            //RHE-TNA 23-11-2020 BDS-4705 END
                            FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            //RHE-TNA 08-04-2020 BDS-4089 END

                            //RHE-TNA 23-11-2020 BDS-4705 BEGIN
                            //Search for created sales order, update it and enter in log
                            SalesHdr.SetRange("Assigned User ID", '50016');
                            if SalesHdr.FindFirst() then begin
                                SalesHdr."Assigned User ID" := '';
                                SalesHdr.Modify(false);

                                AddIFLogEntry(false, SalesHdr."No.", ProcessedFileName, ProcessedFileNameShort);
                            end;
                            //RHE-TNA 23-11-2020 BDS-4705 END

                            FileMgt.DeleteServerFile(FileName);
                            ProcessedCount := ProcessedCount + 1;
                        end else begin
                            //Copy to error directory
                            File.Close();

                            ProcessedFileName := IFSetup."Order Import Dir. Error" + ImportFile.Name;
                            FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            //RHE-TNA 08-04-2020 BDS-4089 BEGIN
                            //Upload to Archive directory
                            ProcessedFileName := IFSetup."Order Import Dir. Error" + 'Archive\' + ImportFile.Name;
                            FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            ///RHE-TNA 08-04-2020 BDS-4089 END

                            //RHE-TNA 23-11-2020 BDS-4705 BEGIN
                            AddIFLogEntry(true, '', ProcessedFileName, ImportFile.Name);
                            //RHE-TNA 23-11-2020 BDS-4705 END

                            FileMgt.DeleteServerFile(FileName);
                            if GuiAllowed then
                                Message(GetLastErrorText);
                        end;
                    end;
                until ImportFile.Next() = 0;

            //RHE-TNA 14-06-2021 BDS-5337 BEGIN
            IFSetup."In Progress" := false;
            IFSetup.Modify(false);
        until IFSetup.Next() = 0;
        //RHE-TNA 14-06-2021 BDS-5337 END

        if GuiAllowed then
            Message(Format(TotalCount) + ' file(s) found, of which ' + Format(ProcessedCount) + ' file(s) imported succesfully.');
    end;

    //RHE-TNA 23-11-2020 BDS-4705 BEGIN
    procedure AddIFLogEntry(Error: Boolean; OrderNo: Code[20]; FileName: Text; FileNameShort: Text)
    var
        IFLog: Record "Interface Log";
    begin
        IFLog.Init();
        IFLog.Insert(true);
        IFLog.Source := 'Report 50016 - Import Webshop Order';
        IFLog.Direction := IFLog.Direction::"From Customer";
        IFLog.Date := Today;
        IFLog.Time := Time;
        IFLog.Filename := FileName;
        IFLog."Filename Short" := FileNameShort;
        IFLog.Reference := OrderNo;
        if Error then begin
            IFLog.Error := true;
            IFLog."Error Text" := GetLastErrorText;
        end;
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        IFLog."Interface Prefix" := IFSetup."Interface Identifier";
        //RHE-TNA 14-06-2021 BDS-5337 END
        IFLog.Modify(true);
        Commit();
    end;
    //RHE-TNA 23-11-2020 BDS-4705 END

    trigger OnInitReport()
    begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        //IFSetup.TestField("Order Import Directory");
        //IFSetup.TestField("Order Import Dir. Processed");
        //IFSetup.TestField("Order Import Dir. Error");
        IFSetup.SetRange(Type, IFSetup.Type::Customer);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = Customer.');
        IFSetup.FindSet();
        //RHE-TNA 14-06-2021 BDS-5337 END
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
}