xmlport 50022 "Import 3PL Inventory Level"

//  RHE-TNA 04-01-2022 BDS-5976
//  - New XMLPort

{
    Direction = Import;
    Format = Xml;
    FormatEvaluate = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            textelement(DataHeader)
            {
                textelement(ClientId)
                {

                }
                textelement(Date)
                {

                }
                textelement(DataLines)
                {
                    textelement(DataLine)
                    {
                        textelement(ItemNo)
                        {

                        }
                        textelement(Quantity)
                        {

                        }
                        textelement(ConditionCode)
                        {

                        }
                        textelement(LockCode)
                        {

                        }
                        textelement(ItemTrackingLines)
                        {
                            tableelement(ItemTrackingLine; Integer)
                            {
                                textelement(TrackingQuantity)
                                {
                                    MinOccurs = Zero;
                                }
                                textelement(SerialNo)
                                {
                                    MinOccurs = Zero;
                                }
                                textelement(LotNo)
                                {
                                    MinOccurs = Zero;
                                }
                                textelement(ExpiryDate)
                                {
                                    MinOccurs = Zero;
                                }
                                trigger OnBeforeInsertRecord()
                                var
                                    WmsInvRec: Record "WMS Inventory Reconciliation";
                                    QtyOnHandDec: Decimal;
                                    Item: Record Item;
                                    ItemTrackingCode: Record "Item Tracking Code";
                                    Day: Integer;
                                    Month: Integer;
                                    Year: Integer;
                                    ExpirationDate: Date;
                                begin
                                    if not DecimalSignIsComma then begin
                                        if TrackingQuantity <> '' then begin
                                            if StrPos(TrackingQuantity, ',') <> 0 then
                                                TrackingQuantity := DelChr(TrackingQuantity, '=', ',')
                                            else begin
                                                if StrPos(TrackingQuantity, ',') <> 0 then
                                                    TrackingQuantity := ConvertStr(TrackingQuantity, ',', '.');
                                            end;
                                        end;
                                        if StrPos(Quantity, ',') <> 0 then
                                            Quantity := DelChr(Quantity, '=', ',')
                                        else begin
                                            if StrPos(Quantity, ',') <> 0 then
                                                Quantity := ConvertStr(Quantity, ',', '.');
                                        end;
                                    end;

                                    //Check if item is setup to store serial numbers in inventory, if not continue without serial number.
                                    if SerialNo <> '' then begin
                                        if (Item.Get(ItemNo)) and (Item."Item Tracking Code" <> '') and
                                            (ItemTrackingCode.Get(Item."Item Tracking Code")) and
                                            (ItemTrackingCode."SN Purchase Inbound Tracking" or ItemTrackingCode."SN Assembly Inbound Tracking") then
                                            Evaluate(QtyOnHandDec, TrackingQuantity)
                                        else begin
                                            Evaluate(QtyOnHandDec, Quantity);
                                            SerialNo := ''; //Clear SerialNo value to not be used later on in process
                                        end;
                                    end else
                                        if TrackingQuantity <> '' then //Inventory with Lot number
                                            Evaluate(QtyOnHandDec, TrackingQuantity)
                                        else
                                            Evaluate(QtyOnHandDec, Quantity);

                                    ExpirationDate := 0D;
                                    if ExpiryDate <> '' then begin
                                        Evaluate(Day, CopyStr(ExpiryDate, 9, 2));
                                        Evaluate(Month, CopyStr(ExpiryDate, 6, 2));
                                        Evaluate(Year, CopyStr(ExpiryDate, 1, 4));
                                        ExpirationDate := DMY2Date(Day, Month, Year);
                                    end;

                                    WmsInvRec.Reset();
                                    //If a serial number is present a new record needs to be created as inventory with serial numbers is always 1
                                    if SerialNo <> '' then
                                        AddWMSInvRec(ItemNo, GetFromLocation(), SerialNo, LotNo, QtyOnHandDec, 0, LockCode, ConditionCode, ExpirationDate)
                                    else begin
                                        //check if record is already created during processing of xml file.
                                        WmsInvRec.SetRange("Item No.", ItemNo);
                                        WmsInvRec.SetRange("From Location Code", GetFromLocation());
                                        WmsInvRec.SetRange("Inventory Level Run", InvLevelRun);
                                        WmsInvRec.SetRange("Serial No.", '');
                                        WmsInvRec.SetRange("Lot No.", LotNo);
                                        if WmsInvRec.FindFirst() then begin
                                            WmsInvRec.Validate("WMS Qty.", WmsInvRec."WMS Qty." + QtyOnHandDec);
                                            WmsInvRec.Validate("Inv. Level Difference", WmsInvRec."Inv. Level Difference" + QtyOnHandDec);
                                            WmsInvRec.Modify(true);
                                        end else
                                            AddWMSInvRec(ItemNo, GetFromLocation(), SerialNo, LotNo, QtyOnHandDec, 0, LockCode, ConditionCode, ExpirationDate)
                                    end;

                                    //Do not actually import into Integer table
                                    currXMLport.Skip();
                                end;
                            }
                            trigger OnAfterAssignVariable()
                            begin
                                ConditionCode := '';
                                LockCode := '';
                                LotNo := '';
                                SerialNo := '';
                                ExpiryDate := '';
                                TrackingQuantity := '';
                            end;
                        }
                    }
                }
            }
        }
    }

    trigger OnPreXmlPort()
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
        WMSInvLevelRec: Record "WMS Inventory Reconciliation";
    begin
        //Check WMS Location setup is present, if not present stop processing
        WMSLocationSetup.FindFirst();

        DecimalSignIsComma := IFSetup.DecimalSignIsComma();

        InvLevelRun := 1;
        WMSInvLevelRec.SetRange("Transaction Code", WMSInvLevelRec."Transaction Code"::"Stock Level");
        if WMSInvLevelRec.FindLast() then
            InvLevelRun := WMSInvLevelRec."Inventory Level Run" + 1;

        WmsInvLevelRec.Reset();
        WmsInvLevelRec.SetRange("Transaction Code", WmsInvLevelRec."Transaction Code"::"Stock Level");
        WmsInvLevelRec.SetFilter("Inventory Level Run", '<>%1', InvLevelRun);
        WMSInvLevelRec.SetRange(Process, true);
        if WmsInvLevelRec.FindSet() then
            repeat
                if (WMSInvLevelRec."Processed Date" = 0D) or (WMSInvLevelRec.Error) then begin
                    WMSInvLevelRec.Approved := false;
                    WMSInvLevelRec.Disapproved := true;
                    WMSInvLevelRec."Approved / Disapproved by User" := 'Interface';
                    WMSInvLevelRec.Process := false;
                    WMSInvLevelRec.Modify();
                end;
            until WMSInvLevelRec.Next() = 0;
    end;

    procedure SetFileName(FileName: Text[250]; IFSetupEntryNo: Integer)
    begin
        currXMLport.Filename := FileName;
        IFSetup.Get(IFSetupEntryNo);
    end;

    procedure GetFromLocation(): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
        PrevCode: Code[10];
        FromLocation: Code[10];
        i: Integer;
        TempText: Text[10];
    begin
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
        WMSLocationSetup.FindFirst();
        FromLocation := WMSLocationSetup."Location Code";

        //Check if inventory has a lock code
        if LockCode <> '' then begin
            WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
            WMSLocationSetup.SetRange(Code, LockCode);
            if WMSLocationSetup.FindFirst() then
                exit(WMSLocationSetup."Location Code")
            else
                exit('Unknown');
        end else begin
            //Check if inventory has a condition code
            if ConditionCode <> '' then begin
                WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                WMSLocationSetup.SetRange(Code, ConditionCode);
                if WMSLocationSetup.FindFirst() then
                    exit(WMSLocationSetup."Location Code")
                else
                    exit('Unknown');
            end else
                //If no previous lock code and no condition, use base warehouse
                exit(FromLocation);
        end;
    end;

    procedure GetReasonCode(): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
    begin
        WMSLocationSetup.Reset();
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
        WMSLocationSetup.FindFirst();
        exit(WMSLocationSetup."Reason Code Inv. Level");
    end;

    procedure AddWMSInvRec(ItemNo: Code[20]; Location: Code[10]; SerialNo: Code[50]; LotNo: Code[50]; QtyWMS: Decimal; QtyBC: Decimal; LockCode: Code[10]; ConditionCode: Code[10]; ExpirationDate: Date)
    var
        WMSInvRec: Record "WMS Inventory Reconciliation";
        Item: Record Item;
        ErrorText: Text[250];
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin
        Evaluate(Day, CopyStr(Date, 9, 2));
        Evaluate(Month, CopyStr(Date, 6, 2));
        Evaluate(Year, CopyStr(Date, 1, 4));

        WMSInvRec.Insert(true);
        WMSInvRec.Validate("Transaction Date", DMY2Date(Day, Month, Year));
        WMSInvRec.Validate(Process, true);
        WMSInvRec.Validate("Item No.", ItemNo);
        if Item.Get(ItemNo) then
            WMSInvRec.Validate(Description, Item.Description);
        WMSInvRec."From Location Code" := Location;
        WMSInvRec.Validate("Serial No.", SerialNo);
        WMSInvRec.Validate("Lot No.", LotNo);
        WMSInvRec.Validate("WMS Qty.", QtyWMS);
        WMSInvRec.Validate("Calculated Inv. Level", QtyBC);
        WMSInvRec.Validate("Inv. Level Difference", QtyWMS - QtyBC);
        WMSInvRec.Validate("Expiry Date", ExpirationDate);
        WMSInvRec.Validate("Reason Code", GetReasonCode());
        WMSInvRec.Validate("Inventory Level Run", InvLevelRun);
        if Location = 'UNKNOWN' then begin
            if LockCode <> '' then
                ErrorText := 'No From Location setup found in "WMS Inventory Location Setup" for (at least) Condition or Lock Code ' + LockCode
            else
                ErrorText := 'No From Location setup found in "WMS Inventory Location Setup" for (at least) Condition or Lock Code ' + ConditionCode;
            WMSInvRec.validate("Error Text", ErrorText);
        end;
        WMSInvRec.Modify(true);
    end;

    //Global variables
    var
        IFSetup: Record "Interface Setup";
        DecimalSignIsComma: Boolean;
        InvLevelRun: Decimal;
}