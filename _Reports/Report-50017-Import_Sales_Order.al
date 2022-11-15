report 50017 "Import Sales Order"

//  RHE-TNA 08-04-2020 BDS-4089 BEGIN
//  - Modified Trigger OnPreReport()

//  RHE-TNA 23-11-2020 BDS-4705 
//  - Modified trigger OnPreReport()
//  - Added procedure AddIFLogEntry()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreReport()
//  - Modified procedure AddIFLogEntry()
//  - Modified trigger OnInitReport()

//  RHE-TNA 25-06-2021..09-02-2022 BDS-5390
//  - Modified trigger OnPreReport()

//  RHE-TNA 01-11-2021 BDS-5717
//  - Modified trigger OnPreReport()
//  - Added procedure CheckInternalError()

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
        ImportOrder: XmlPort "Import Sales Order";
        FileMgt: Codeunit "File Management";
        ProcessedFileName: Text;
        ProcessedCount: Integer;
        TotalCount: Integer;
        SalesHdr: Record "Sales Header";
        TempBlob: Record TempBlob temporary;
        ErrorFile: File;
        TextToInsert: Text;
        VarOutStream: OutStream;
        ErrorFileName: Text;
        InternalError: Boolean;
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
            ImportFile.SetFilter(Name, '*.xml');
            if ImportFile.FindSet() then
                repeat
                    TotalCount := TotalCount + 1;
                    FileName := ImportFile.Path + '\' + ImportFile.Name;
                    if File.Open(FileName) then begin
                        File.CreateInStream(FileInStream);
                        Clear(ImportOrder);
                        ImportOrder.SetSource(FileInStream);
                        ImportOrder.SetFileName(FileName);
                        if ImportOrder.Import() then begin
                            //Copy to processed directory
                            File.Close();

                            //RHE-TNA 08-04-2020 BDS-4089 BEGIN
                            //ProcessedFileName := IFSetup."Order Import Dir. Processed" + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.xml') - 1);
                            //ProcessedFileName := ProcessedFileName + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.xml';
                            //FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            ProcessedFileName := IFSetup."Order Import Dir. Processed" + ImportFile.Name;
                            FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            //Upload to Archive directory
                            ProcessedFileName := IFSetup."Order Import Dir. Processed" + 'Archive\' + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.xml') - 1);
                            ProcessedFileName := ProcessedFileName + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.xml';
                            FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            //RHE-TNA 08-04-2020 BDS-4089 END

                            //RHE-TNA 23-11-2020 BDS-4705 BEGIN
                            //Search for created sales order, update it and enter in log
                            SalesHdr.SetRange("Assigned User ID", '50017');
                            if SalesHdr.FindFirst() then begin
                                SalesHdr."Assigned User ID" := '';
                                SalesHdr.Modify(false);

                                AddIFLogEntry(false, SalesHdr."No.", ProcessedFileName, ImportFile.Name);
                            end;
                            //RHE-TNA 23-11-2020 BDS-4705 END

                            FileMgt.DeleteServerFile(FileName);
                            ProcessedCount := ProcessedCount + 1;
                        end else begin
                            //RHE-TNA 01-11-2021 BDS-5717 BEGIN
                            //Leave file in import directory if the error is an internal error
                            InternalError := CheckInternalError(GetLastErrorText);
                            if not InternalError then begin
                                //RHE-TNA 01-11-2021 BDS-5717 END

                                //RHE-TNA 25-06-2021..09-02-2022 BDS-5390 BEGIN
                                //Add error reason to XML
                                if IFSetup."Add Error Text" then begin
                                    ErrorFileName := CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.xml') - 1) + '_Error.xml';
                                    ErrorFileName := IFSetup."Order Import Dir. Error" + 'Archive\' + ErrorFileName;
                                    ErrorFile.TextMode(true);
                                    ErrorFile.WriteMode(true);
                                    ErrorFile.Create(ErrorFileName);
                                    while not FileInStream.EOS do begin
                                        FileInStream.ReadText(TextToInsert);
                                        TextToInsert := TextToInsert;
                                        if StrPos(TextToInsert, '<Lines>') > 0 then
                                            //Insert error text just before element <lines>
                                            TextToInsert := Text.InsStr(TextToInsert, '<ErrorText>' + GetLastErrorText + '</ErrorText>', StrPos(TextToInsert, '<Lines>'));
                                        ErrorFile.Write(TextToInsert);
                                    end;
                                    ErrorFile.Close();
                                end;
                                //RHE-TNA 25-06-2021..09-02-2022 BDS-5390 END

                                //Copy to error directory
                                File.Close();

                                //RHE-TNA 25-06-2021 BDS-5390 BEGIN                                
                                ProcessedFileName := IFSetup."Order Import Dir. Error" + ImportFile.Name;
                                //FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                                if IFSetup."Add Error Text" then
                                    FileMgt.CopyServerFile(ErrorFileName, ProcessedFileName, true)
                                else
                                    FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                                //RHE-TNA 25-06-2021 BDS-5390 END

                                //RHE-TNA 08-04-2020 BDS-4089 BEGIN
                                //Upload to Archive directory
                                ProcessedFileName := IFSetup."Order Import Dir. Error" + 'Archive\' + ImportFile.Name;
                                FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                                ///RHE-TNA 08-04-2020 BDS-4089 END

                                //RHE-TNA 20-11-2020 BDS-4705 BEGIN
                                AddIFLogEntry(true, '', ProcessedFileName, ImportFile.Name);
                                //RHE-TNA 20-11-2020 BDS-4705 END

                                FileMgt.DeleteServerFile(FileName);
                                if GuiAllowed then
                                    Message(GetLastErrorText);
                                //RHE-TNA 01-11-2021 BDS-5717 BEGIN
                            end else
                                File.Close();
                            //RHE-TNA 01-11-2021 BDS-5717 END
                        end;
                    end;
                until ImportFile.Next() = 0;
            //RHE-TNA 14-06-2021 BDS-5337 BEGIN
            IFSetup."In Progress" := false;
            IFSetup.Modify(false);
        until IFSetup.Next() = 0;
        //RHE-TNA 14-06-2021 BDS-5337 END

        if GuiAllowed then
            Message(Format(TotalCount) + ' file(s) found, of which ' + Format(ProcessedCount) + ' file(s) imported.');
    end;

    //RHE-TNA 23-11-2020 BDS-4705 BEGIN
    procedure AddIFLogEntry(Error: Boolean; OrderNo: Code[20]; FileName: Text; FileNameShort: Text)
    var
        IFLog: Record "Interface Log";
    begin
        IFLog.Init();
        IFLog.Insert(true);
        IFLog.Source := 'Report 50017 - Import Sales Order';
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

    //RHE-TNA 01-11-2021 BDS-5717 BEGIN
    procedure CheckInternalError(ErrorText: Text): Boolean
    begin
        if StrPos(ErrorText, 'deadlocked') > 0 then
            exit(true);
        if StrPos(ErrorText, 'locked by another user') > 0 then
            exit(true);
        exit(false);
    end;
    //RHE-TNA 01-11-2021 BDS-5717 END

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