report 50002 "Export SKU Master to WMS"

//  RHE-TNA 19-05-2020 BDS-3866
//  - Modified trigger OnInitReport

//  RHE-TNA 14-06-2021 BDS-5337 
//  - Modified trigger OnInitReport

//  RHE-TNA 19-01-2022 BDS-5585
//  - Modified trigger OnInitReport()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            trigger OnPreDataItem()
            var
            begin
                Item.SetFilter("No.", ItemFilter);
            end;

            trigger OnAfterGetRecord()
            var
                ItemXMLPort: XmlPort "Export WMS SKU Master";
                FileName: Text[250];
                FileNameComplete: Text[250];
                ExportFile: File;
                ExportFileComplete: File;
                varOutStream: OutStream;
                varInstream: InStream;
                TempBlob: Record TempBlob;
                CharactersCount: Integer;
                i: Integer;
                CharacterText: Text[1];
                TextToInsert: Text;
            begin
                Sleep(1000); //Wait a second to get a unique Filename
                FileName :=
    IFSetup."WMS Upload Directory"
    + 'ItemMaster_' + IFSetup."WMS Client ID" + '_'
    + Format(Today(), 0, '<Year,2><Month,2><Day,2>')
    + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
    + '.tmp';
                FileNameComplete :=
                    IFSetup."WMS Upload Directory"
                    + 'ItemMaster_' + IFSetup."WMS Client ID" + '_'
                    + Format(Today(), 0, '<Year,2><Month,2><Day,2>')
                    + Format(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>')
                    + '.xml';


                ExportFile.TextMode(true);
                ExportFile.WriteMode(true);
                ExportFile.Create(FileName);
                TempBlob.Blob.CreateOutStream(varOutStream);
                ItemXMLPort.SetTableView(Item);
                ItemXMLPort.SetDestination(varOutStream);
                ItemXMLPort.Export();

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

                TextToInsert := '<!DOCTYPE dcsmergedata SYSTEM "../lib/interface_sku.dtd">';
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

                Item.Validate("Exported to WMS", true);
                Item.Modify(true);
            end;
        }
    }

    procedure SetRecFilter(FilterIn: Text[1024])
    var
    begin
        ItemFilter := FilterIn;
    end;

    trigger OnInitReport()
    var
    begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        //RHE-TNA 19-01-2022 BDS-5585 BEGIN
        //IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Type, IFSetup.Type::"Blue Yonder WMS");
        //RHE-TNA 19-01-2022 BDS-5585 END
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = WMS.');
        //RHE-TNA 14-06-2021 BDS-5337 END
        //RHE-TNA 19-05-2020 BDS-3866 BEGIN
        if IFSetup."WMS Version" = IFSetup."WMS Version"::WMS2016 then
            Error('Ask Masterdata to upload SKU data to WMS.');
        //RHE-TNA 19-05-2020 BDS-3866 END
        IFSetup.TestField("WMS Upload Directory");
    end;

    trigger OnPostReport()
    var
    begin
        if GuiAllowed then
            Message('Item exported to WMS.');
    end;

    //Global Variables
    var
        IFSetup: Record "Interface Setup";
        ItemFilter: Text[1024];
}