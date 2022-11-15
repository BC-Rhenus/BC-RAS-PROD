report 50033 "Import WMS Inventory Level"

//  RHE-TNA 25-01-2021 BDS-4324
//  - New report

//  RHE-TNA 12-03-2021 BDS-5075
//  - Modified procedure AddWMSInvRec

//  RHE-TNA 21-04-2021 BDS-5280
//  - Modified procedure CalcBCInventory()
//  - Modified procedure AddWMSInvRec()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnInitReport()

//  RHE-TNA 01-02-2022 BDS-5976
//  - Modified trigger OnPreReport()
//  - Modified procedure CalcBCInventory()

//  RHE-TNA 03-02-2022 BDS-5585
//  - Modified trigger OnPreReport()
//  - Modified trigger OnInitReport()
//  - Modified procedure AddWMSInvRec()
//  - Modified procedure GetReasonCode()

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
        ImportInventoryLevel: XmlPort "Import WMS Inventory Level";
        ProcessedCount: Integer;
        TotalCount: Integer;
        WMSInvLevelRec: Record "WMS Inventory Reconciliation";
        Import3PLInventoryLevel: XmlPort "Import 3PL Inventory Level";
        ImportOK: Boolean;
    Begin
        InvLevelRun := 1;
        WMSInvLevelRec.SetRange("Transaction Code", WMSInvLevelRec."Transaction Code"::"Stock Level");
        if WMSInvLevelRec.FindLast() then
            InvLevelRun := WMSInvLevelRec."Inventory Level Run" + 1;

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

                ImportFile.SetRange(Path, IFSetup."WMS Download Directory");
                ImportFile.SetRange("Is a file", true);
                ImportFile.SetFilter(Name, IFSetup."WMS Client ID" + '_BUSINESS_CENTRAL_INV*.xml');
                if ImportFile.FindSet() then
                    repeat
                        TotalCount := TotalCount + 1;
                        FileName := ImportFile.Path + '\' + ImportFile.Name;
                        if File.Open(FileName) then begin
                            File.CreateInStream(FileInStream);
                            //RHE-TNA 01-02-2022 BDS-5976 BEGIN
                            /*Clear(ImportInventoryLevel);
                            ImportInventoryLevel.SetSource(FileInStream);
                            ImportInventoryLevel.SetFileName(FileName);
                            if ImportInventoryLevel.Import() then begin*/
                            ImportOK := false;
                            case IFSetup.Type of
                                IFSetup.Type::"Blue Yonder WMS":
                                    begin
                                        Clear(ImportInventoryLevel);
                                        ImportInventoryLevel.SetSource(FileInStream);
                                        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
                                        //ImportInventoryLevel.SetFileName(FileName);
                                        ImportInventoryLevel.SetFileName(FileName, IFSetup."Entry No.", InvLevelRun);
                                        //RHE-TNA 03-02-2022 BDS-5585 END
                                        if ImportInventoryLevel.Import() then
                                            ImportOK := true;
                                    end;
                                IFSetup.Type::"External WMS":
                                    begin
                                        Clear(Import3PLInventoryLevel);
                                        Import3PLInventoryLevel.SetSource(FileInStream);
                                        Import3PLInventoryLevel.SetFileName(FileName, IFSetup."Entry No.");
                                        if Import3PLInventoryLevel.Import() then
                                            ImportOK := true;
                                    end;
                            end;
                            if ImportOK then begin
                                //RHE-TNA 01-02-2022 BDS-5976 END
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
                                CalcBCInventory();
                                //RHE-TNA 03-02-2022 BDS-5585 BEGIN
                                Commit();
                                //RHE-TNA 03-02-2022 BDS-5585 END
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
        /*RHE-TNA 03-02-2022 BDS-5585 BEGIN
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = WMS.');
        //RHE-TNA 14-06-2021 BDS-5337 END
        IFSetup.TestField("WMS Download Directory");
        IFSetup.TestField("WMS Download Dir. Processed");
        RHE-TNA 03-02-2022 BDS-5585 END*/
    end;

    procedure CalcBCInventory()
    var
        Item: Record Item;
        ILE: Record "Item Ledger Entry";
        WMSLocationSetup: Record "WMS Inventory Location Setup";
        WMSLocationSetup2: Record "WMS Inventory Location Setup";
        FilterText: text;
        NextWMSLocationSetup: Boolean;
        WmsInvRec: Record "WMS Inventory Reconciliation";
    begin
        Item.SetRange(Blocked, false);
        if Item.FindSet() then
            repeat
                FilterText := '';
                NextWMSLocationSetup := true;

                //RHE-TNA 03-02-2022 BDS-5585 BEGIN
                WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
                //RHE-TNA 03-02-2022 BDS-5585 END
                WMSLocationSetup.FindSet();
                //Loop through setup to calc. inventory for needed locations
                repeat
                    ILE.Reset();
                    WMSLocationSetup2.Reset();
                    //RHE-TNA 03-02-2022 BDS-5585 BEGIN
                    WMSLocationSetup2.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
                    //RHE-TNA 03-02-2022 BDS-5585 END
                    if FilterText <> '' then
                        //Set a filter on WMSLocationSetup2 to not calculate inventory for the same location more than once.
                        WMSLocationSetup2.SetFilter("Location Code", FilterText);
                    if WMSLocationSetup2.FindFirst() then begin
                        ILE.SetRange("Item No.", Item."No.");
                        ILE.SetFilter("Remaining Quantity", '>0');
                        ILE.SetRange("Location Code", WMSLocationSetup2."Location Code");
                        if ILE.FindSet() then
                            repeat
                                WmsInvRec.Reset();
                                WmsInvRec.SetRange("Item No.", Item."No.");
                                WmsInvRec.SetRange("Transaction Code", WmsInvRec."Transaction Code"::"Stock Level");
                                WmsInvRec.SetRange("Inventory Level Run", InvLevelRun);
                                if ILE."Serial No." <> '' then
                                    WmsInvRec.SetRange("Serial No.", ILE."Serial No.")
                                else
                                    WmsInvRec.SetRange("Serial No.", '');
                                if ILE."Lot No." <> '' then
                                    WmsInvRec.SetRange("Lot No.", ILE."Lot No.")
                                else
                                    WmsInvRec.SetRange("Lot No.", '');
                                WmsInvRec.SetRange("From Location Code", WMSLocationSetup2."Location Code");
                                if WmsInvRec.FindFirst() then begin
                                    WmsInvRec."Calculated Inv. Level" += ILE."Remaining Quantity";
                                    //Calculate difference between WMS and BC
                                    WmsInvRec."Inv. Level Difference" := WmsInvRec."WMS Qty." - WmsInvRec."Calculated Inv. Level";
                                    WmsInvRec.Modify(false);
                                end else
                                    //RHE-TNA 21-04-2021 BDS-5280 BEGIN
                                    //AddWMSInvRec(Item."No.", WMSLocationSetup2."Location Code", ILE."Serial No.", ILE."Lot No.", 0, ILE."Remaining Quantity", '', '');
                                    AddWMSInvRec(Item."No.", WMSLocationSetup2."Location Code", ILE."Serial No.", ILE."Lot No.", 0, ILE."Remaining Quantity", '', '', ILE."Expiration Date");
                                //RHE-TNA 21-04-2021 BDS-5280 END
                            until ILE.Next() = 0;
                        if FilterText = '' then
                            FilterText := '<>' + WMSLocationSetup2."Location Code"
                        else
                            FilterText := FilterText + '&<>' + WMSLocationSetup2."Location Code";
                    end else
                        NextWMSLocationSetup := false;
                until (WMSLocationSetup.Next() = 0) or (NextWMSLocationSetup = false);
            until Item.Next() = 0;

        WmsInvRec.Reset();
        WmsInvRec.SetRange("Transaction Code", WmsInvRec."Transaction Code"::"Stock Level");
        //RHE-TNA 01-02-2022 BDS-5976 BEGIN
        //WmsInvRec.SetRange("Transaction Date", Today);
        //RHE-TNA 01-02-2022 BDS-5976 END
        WmsInvRec.SetRange("Inv. Level Difference", 0);
        WmsInvRec.DeleteAll();
    end;

    procedure AddWMSInvRec(ItemNo: Code[20]; Location: Code[10]; SerialNo: Code[50]; LotNo: Code[50]; QtyWMS: Decimal; QtyBC: Decimal; LockCode: Code[10]; ConditionCode: Code[10]; ExpirationDate: Date)
    var
        WMSInvRec: Record "WMS Inventory Reconciliation";
        Item: Record Item;
    begin
        WMSInvRec.Insert(true);
        WMSInvRec.Validate("Transaction Date", Today);
        WMSInvRec.Validate(Process, true);
        WMSInvRec.Validate("Item No.", ItemNo);
        //RHE-TNA 12-03-2021 BDS-5075 BEGIN
        if Item.Get(ItemNo) then
            WMSInvRec.Validate(Description, Item.Description);
        //RHE-TNA 12-03-2021 BDS-5075 END
        WMSInvRec.Validate("From Location Code", Location);
        WMSInvRec.Validate("Serial No.", SerialNo);
        WMSInvRec.Validate("Lot No.", LotNo);
        WMSInvRec.Validate("WMS Qty.", QtyWMS);
        WMSInvRec.Validate("Calculated Inv. Level", QtyBC);
        WMSInvRec.Validate("Inv. Level Difference", QtyWMS - QtyBC);
        //RHE-TNA 21-04-2021 BDS-5280 BEGIN
        //WMSInvRec.Validate("Lock Code", LockCode);
        //WMSInvRec.Validate("Condition Code", ConditionCode);
        WMSInvRec.Validate("Expiry Date", ExpirationDate);
        //RHE-TNA 21-04-2021 BDS-5280 END
        WMSInvRec.Validate("Inventory Level Run", InvLevelRun);
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        WMSInvRec.Validate("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585 END
        WMSInvRec.Modify(false);
        WMSInvRec.Validate("Reason Code", GetReasonCode());
        WMSInvRec.Modify(true);
    end;

    procedure GetReasonCode(): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
    begin
        WMSLocationSetup.Reset();
        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        //RHE-TNA 03-02-2022 BDS-5585 BEGIN
        WMSLocationSetup.FindFirst();
        exit(WMSLocationSetup."Reason Code Inv. Level");
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        InvLevelRun: Integer;
}