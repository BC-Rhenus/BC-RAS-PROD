report 50038 "Export Inventory Update"

//  RHE-TNA 18-10-2021 BDS-5677
//  - New report

//  RHE-TNA 08-06-2022 BDS-6378
//  - Modified trigger OnPreReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        InvUpdateXMLPort: XmlPort "Export Inventory Update";
        FileName: Text[250];
        ExportFile: File;
        varOutStream: OutStream;
        ILE: Record "Item Ledger Entry";
        FileNameArchive: Text[250];
        FileMgt: Codeunit "File Management";
        FileNameShort: Text[250];
        Item: Record Item;
    begin
        IFSetup.SetRange(Type, IFSetup.Type::Customer);
        IFSetup.SetRange("Export Inventory Update", true);
        if IFSetup.FindSet() then
            repeat
                IFSetup.TestField("Inv. Export Directory");
                IFSetup."In Progress" := true;
                IFSetup.Modify(false);
                Counter += 1;
                FileNameShort := 'Inventory_Update_'
                    + Format(WorkDate, 0, '<Day,2><Month,2><Year,2>')
                    + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                    + '_'
                    + Format(Counter)
                    + '.xml';
                FileName := IFSetup."Inv. Export Directory" + FileNameShort;

                ILE.SetFilter("Entry Type", '%1|%2|%3', ILE."Entry Type"::"Negative Adjmt.", ILE."Entry Type"::"Positive Adjmt.", ILE."Entry Type"::Transfer);
                ILE.SetRange("Document Type", ILE."Document Type"::" ");
                ILE.SetFilter("Entry No.", '>%1', IFSetup."Last ILE No. Exported");
                if ILE.FindSet() then begin
                    //Make sure for ILE entry type = Transfer only positive lines are exported
                    repeat
                        //RHE-TNA 08-06-2022 BDS-6378 BEGIN
                        Item.Get(ILE."Item No.");
                        if not Item.ExclItemEDI then begin
                            //RHE-TNA 08-06-2022 BDS-6378 END
                            if ILE."Entry Type" = ILE."Entry Type"::Transfer then begin
                                if ILE.Positive then
                                    ILE.Mark(true);
                            end else
                                ILE.Mark(true);
                            //RHE-TNA 08-06-2022 BDS-6378 BEGIN
                        end;
                        //RHE-TNA 08-06-2022 BDS-6378 END
                    until ILE.Next() = 0;
                    ILE.MarkedOnly(true);

                    ExportFile.TextMode(true);
                    ExportFile.WriteMode(true);
                    ExportFile.Create(FileName);
                    ExportFile.CreateOutStream(varOutStream);
                    InvUpdateXMLPort.SetTableView(ILE);
                    InvUpdateXMLPort.SetDestination(varOutStream);
                    InvUpdateXMLPort.Export();
                    ExportFile.Close();

                    FileNameArchive := IFSetup."Inv. Export Directory" + 'Archive\' + FileNameShort;
                    FileMgt.CopyServerFile(FileName, FileNameArchive, true);
                    AddIFLogEntry(false, FileNameArchive, FileNameShort);

                    ILE.FindLast();
                    IFSetup."Last ILE No. Exported" := ILE."Entry No.";
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
        IFLog.Source := 'Report 50038 - Export Inventory Update';
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
            Message('Inventory Update(s) exported.');
    end;
    //Global variables
    var
        IFSetup: Record "Interface Setup";
        Counter: Integer;

}