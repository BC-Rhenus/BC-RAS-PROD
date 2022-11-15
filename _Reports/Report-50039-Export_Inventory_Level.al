report 50039 "Export Inventory Level"

//  RHE-TNA 18-10-2021 BDS-5678
//  - New Report

//  RHE-TNA 15-04-2022 BDS-6277
//  - Modified trigger OnPreReport()

//  RHE-TNA 08-06-2022 BDS-6378
//  - Modified trigger OnPreReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        InvLevelXMLPort: XmlPort "Export Inventory Level";
        FileName: Text[250];
        ExportFile: File;
        varOutStream: OutStream;
        Item: Record Item;
        FileNameArchive: Text[250];
        FileMgt: Codeunit "File Management";
        FileNameShort: Text[250];
    begin
        IFSetup.SetRange(Type, IFSetup.Type::Customer);
        IFSetup.SetRange("Export Inventory Level", true);
        if IFSetup.FindSet() then
            repeat
                IFSetup.TestField("Inv. Export Directory");
                IFSetup."In Progress" := true;
                IFSetup.Modify(false);
                Counter += 1;
                FileNameShort := 'Inventory_Level_'
                    + Format(WorkDate, 0, '<Day,2><Month,2><Year,2>')
                    + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                    + '_'
                    + Format(Counter)
                    + '.xml';
                FileName := IFSetup."Inv. Export Directory" + FileNameShort;

                //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                Item.SetRange(Type, Item.Type::Inventory);
                //RHE-TNA 15-04-2022 BDS-6277 END
                //RHE-TNA 08-06-2022 BDS-6378 BEGIN
                Item.SetRange(ExclItemEDI, false);
                //RHE-TNA 08-06-2022 BDS-6378 END
                if Item.FindSet() then
                    repeat
                        Item.CalcFields(Inventory);
                        if Item.Inventory <> 0 then
                            Item.Mark(true);
                    until Item.Next() = 0;

                Item.MarkedOnly(true);
                if Item.FindSet() then begin
                    ExportFile.TextMode(true);
                    ExportFile.WriteMode(true);
                    ExportFile.Create(FileName);
                    ExportFile.CreateOutStream(varOutStream);
                    InvLevelXMLPort.SetTableView(Item);
                    InvLevelXMLPort.SetDestination(varOutStream);
                    InvLevelXMLPort.Export();
                    ExportFile.Close();

                    FileNameArchive := IFSetup."Inv. Export Directory" + 'Archive\' + FileNameShort;
                    FileMgt.CopyServerFile(FileName, FileNameArchive, true);
                    AddIFLogEntry(false, FileNameArchive, FileNameShort);
                end;

                IFSetup."In Progress" := false;
                IFSetup.Modify(false);
            until IFSetup.Next() = 0;
    end;

    procedure AddIFLogEntry(Error: Boolean; FileName: Text; FileNameShort: Text)
    var
        IFLog: Record "Interface Log";
    begin
        IFLog.Init();
        IFLog.Insert(true);
        IFLog.Source := 'Report 50039 - Export Inventory Level';
        IFLog.Direction := IFLog.Direction::"To Customer";
        IFLog.Date := Today;
        IFLog.Time := Time;
        IFLog.Filename := FileName;
        IFLog."Filename Short" := FileNameShort;
        IFLog.Modify(true);
        Commit();
    end;

    trigger OnPostReport()
    var
    begin
        if GuiAllowed then
            Message('Inventory Level exported.');
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        Counter: Integer;

}