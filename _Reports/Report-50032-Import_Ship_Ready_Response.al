report 50032 "Import Ship Ready Response"

//  RHE-TNA 19-10-2020 BDS-4551
//  - New report

//  RHE-TNA 23-11-2020..03-12-2020 BDS-4705 
//  - Modified trigger OnPreReport()
//  - Added procedure AddIFLogEntry()

//  RHE-TNA 14-06-2021 BDS-5337
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
        FileMgt: Codeunit "File Management";
        ProcessedFileName: Text;
        ImportFulfillment: XmlPort "Import Ship Ready Response";
        IFRecParam: Record "Interface Record Parameters";
        ProcessedFileNameShort: Text;
    Begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        Repeat
            IFSetup.TestField("Ship Ready Import Directory");
            IFSetup.TestField("Ship Ready Dir. Processed");
            //RHE-TNA 14-06-2021 BDS-5337 END

            ImportFile.SetRange(Path, IFSetup."Ship Ready Import Directory");
            ImportFile.SetRange("Is a file", true);
            ImportFile.SetFilter(Name, '*FULFILLMENT*.xml');
            if ImportFile.FindSet() then
                repeat
                    FileName := ImportFile.Path + '\' + ImportFile.Name;
                    if File.Open(FileName) then begin
                        File.CreateInStream(FileInStream);
                        Clear(ImportFulfillment);
                        ImportFulfillment.SetSource(FileInStream);
                        ImportFulfillment.SetFileName(FileName);
                        if ImportFulfillment.Import() then begin
                            //Copy to processed directory
                            File.Close();
                            //RHE-TNA 23-11-2020 BDS-4705 BEGIN      
                            //ProcessedFileName := IFSetup."Ship Ready Dir. Processed" + CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.xml') - 1);
                            //ProcessedFileName := ProcessedFileName + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.xml';
                            ProcessedFileNameShort := CopyStr(ImportFile.Name, 1, StrPos(ImportFile.Name, '.xml') - 1);
                            ProcessedFileNameShort := ProcessedFileNameShort + '_P' + Format(WorkDate(), 0, '<Year4><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>') + '.xml';
                            ProcessedFileName := IFSetup."Ship Ready Dir. Processed" + ProcessedFileNameShort;
                            //RHE-TNA 23-11-2020 BDS-4705 END
                            FileMgt.CopyServerFile(FileName, ProcessedFileName, true);
                            FileMgt.DeleteServerFile(FileName);

                            //RHE-TNA 23-11-2020..03-12-2020 BDS-4705 BEGIN
                            IFRecParam.SetFilter("Source No.", 'R50032-*');
                            if IFRecParam.FindSet() then begin
                                AddIFLogEntry(false, CopyStr(IFRecParam."Source No.", 8), ProcessedFileName, ProcessedFileNameShort);
                                repeat
                                    IFRecParam."Source No." := CopyStr(IFRecParam."Source No.", 8);
                                    IFRecParam.Modify(false);
                                until IFRecParam.Next() = 0;
                                Commit();
                            end;
                            //RHE-TNA 23-11-2020..03-12-2020 BDS-4705 END
                        end else begin
                            //Leave file in to process directory
                            if GuiAllowed then
                                Message(GetLastErrorText);

                            //RHE-TNA 23-11-2020 BDS-4705 BEGIN
                            AddIFLogEntry(true, '', FileName, ImportFile.Name);
                            //RHE-TNA 23-11-2020 BDS-4705 END
                        end;
                    end;
                until ImportFile.Next() = 0;
            //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        until IFSetup.Next() = 0;
        //RHE-TNA 14-06-2021 BDS-5337 END
    end;

    //RHE-TNA 23-11-2020 BDS-4705 BEGIN
    procedure AddIFLogEntry(Error: Boolean; OrderNo: Code[20]; FileName: Text; FileNameShort: Text)
    var
        IFLog: Record "Interface Log";
    begin
        IFLog.Init();
        IFLog.Insert(true);
        IFLog.Source := 'Report 50032 - Import Ship Ready Response';
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
        IFLog.Modify(true);
        Commit();
    end;
    //RHE-TNA 23-11-2020 BDS-4705 END

    trigger OnInitReport()
    begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        //IFSetup.TestField("Ship Ready Import Directory");
        //IFSetup.TestField("Ship Ready Dir. Processed");     
        IFSetup.SetRange(Type, IFSetup.Type::Customer);
        IFSetup.SetRange(Active, true);
        IFSetup.SetFilter("Ship Ready Import Directory", '<>%1', '');
        IFSetup.FindSet();
        //RHE-TNA 14-06-2021 BDS-5337 END
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
}