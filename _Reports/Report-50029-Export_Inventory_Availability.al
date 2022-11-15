report 50029 "Export Inventory Availability"

//  RHE-TNA 19-10-2020..18-11-2020 BDS-4552
//  - Modified trigger OnpreReport()

//  RHE-TNA 23-11-2020..28-12-2020 BDS-4705 
//  - Modified trigger OnAfterGetRecord()
//  - Added procedure AddIFLogEntry()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnpreReport()

//  RHE-TNA 18-10-2021 BDS-5678
//  - Renamed Object from "Export Inventory" to "Export Inventory Availability"

//  RHE-TNA 15-04-2022 BDS-6277

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        InventoryXMLPort: XmlPort "Export Inventory";
        FileName: Text[250];
        ExportFile: File;
        varOutStream: OutStream;
        Item: Record Item;
        FileNameArchive: Text[250];
        FileMgt: Codeunit "File Management";
        FileNameShort: Text[250];
    begin
        /*RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //RHE-TNA 19-10-2020 BDS-4552 BEGIN
        //IFSetup.Get();
        //RHE-TNA 19-10-2020 BDS-4552 END
        RHE-TNA 14-06-2021 BDS-5337 END*/

        IFSetup.SetRange(Type, IFSetup.Type::Customer);
        //RHE-TNA 18-10-2021 BDS-5678 BEGIN
        //IFSetup.SetFilter("Inv. Export Directory", '<>%1', '');
        IFSetup.SetRange("Export Inventory Availability", true);
        //RHE-TNA 18-10-2021 BDS-5678 END
        if IFSetup.FindSet() then
            repeat
                //RHE-TNA 18-10-2021 BDS-5678 BEGIN
                IFSetup.TestField("Inv. Export Directory");
                //RHE-TNA 18-10-2021 BDS-5678 END
                //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                IFSetup."In Progress" := true;
                IFSetup.Modify(false);
                Counter += 1;
                //RHE-TNA 14-06-2021 BDS-5337 END

                /*
                RHE-TNA 23-11-2020 BDS-4705 BEGIN
                FileName := IFSetup."Inv. Export Directory"
                                        + 'Inventory_'
                                        + Format(WorkDate, 0, '<Day,2><Month,2><Year,2>')
                                        + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                                        + '.xml';
                */
                FileNameShort := 'Inventory_'
                                    + Format(WorkDate, 0, '<Day,2><Month,2><Year,2>')
                                    + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                                    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                                    + '_'
                                    + Format(Counter)
                                    //RHE-TNA 14-06-2021 BDS-5337 END
                                    + '.xml';
                FileName := IFSetup."Inv. Export Directory" + FileNameShort;
                //RHE-TNA 23-11-2020 BDS-4705 END

                //RHE-TNA 19-10-2020..18-11-2020 BDS-4552 BEGIN
                Item.SetRange("Export Inventory Level", true);
                //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                Item.SetRange(Type, Item.Type::Inventory);
                //RHE-TNA 15-04-2022 BDS-6277 END
                if Item.FindSet() then begin
                    //RHE-TNA 19-10-2020 BDS-4552 END
                    ExportFile.TextMode(true);
                    ExportFile.WriteMode(true);
                    ExportFile.Create(FileName);
                    ExportFile.CreateOutStream(varOutStream);
                    InventoryXMLPort.SetTableView(Item);
                    InventoryXMLPort.SetDestination(varOutStream);
                    InventoryXMLPort.Export();
                    ExportFile.Close();
                    //RHE-TNA 19-10-2020..18-11-2020 BDS-4552 BEGIN

                    //RHE-TNA 23-11-2020..28-12-2020 BDS-4705 BEGIN
                    FileNameArchive := IFSetup."Inv. Export Directory" + 'Archive\' + FileNameShort;
                    FileMgt.CopyServerFile(FileName, FileNameArchive, true);
                    AddIFLogEntry(false, FileNameArchive, FileNameShort);
                    //RHE-TNA 23-11-2020..28-12-2020 BDS-4705 END
                end;
                //RHE-TNA 19-10-2020..18-11-2020 BDS-4552 END

                //RHE-TNA 14-06-2021 BDS-5337 BEGIN
                IFSetup."In Progress" := false;
                IFSetup.Modify(false);
            until IFSetup.Next() = 0;
        //RHE-TNA 14-06-2021 BDS-5337 END
    end;

    //RHE-TNA 23-11-2020 BDS-4705 BEGIN
    procedure AddIFLogEntry(Error: Boolean; FileName: Text; FileNameShort: Text)
    var
        IFLog: Record "Interface Log";
    begin
        IFLog.Init();
        IFLog.Insert(true);
        IFLog.Source := 'Report 50029 - Export Inventory';
        IFLog.Direction := IFLog.Direction::"To Customer";
        IFLog.Date := Today;
        IFLog.Time := Time;
        IFLog.Filename := FileName;
        IFLog."Filename Short" := FileNameShort;
        IFLog.Modify(true);
        Commit();
    end;
    //RHE-TNA 23-11-2020 BDS-4705 END

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        Counter: Integer;

}