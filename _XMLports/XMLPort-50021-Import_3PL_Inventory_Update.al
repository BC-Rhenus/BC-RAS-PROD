xmlport 50021 "Import 3PL Inv. Update"

//  RHE-TNA 03-02-2022 BDS-5975
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
                textelement(DataLines)
                {
                    textelement(DataLine)
                    {
                        textelement(TransactionDate)
                        {

                        }
                        textelement(Type)
                        {
                            //Condition or (Un)Lock or Adjustment
                        }
                        textelement(ItemNo)
                        {

                        }
                        textelement(Quantity)
                        {

                        }
                        textelement(ConditionCode)
                        {

                        }
                        textelement(OldConditionCode)
                        {

                        }
                        textelement(LockCode)
                        {

                        }
                        textelement(OldLockCode)
                        {

                        }
                        textelement(ReasonCode)
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
                                    WMSInvRecon: Record "WMS Inventory Reconciliation";
                                    Day: Integer;
                                    Month: Integer;
                                    Year: Integer;
                                    Item: Record Item;
                                begin
                                    WMSInvRecon.Insert(true);
                                    if TransactionDate <> '' then begin
                                        Evaluate(Day, CopyStr(TransactionDate, 9, 2));
                                        Evaluate(Month, CopyStr(TransactionDate, 6, 2));
                                        Evaluate(Year, CopyStr(TransactionDate, 1, 4));
                                        WMSInvRecon.Validate("Transaction Date", DMY2Date(Day, Month, Year));
                                    end;
                                    WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::"Stock Level");
                                    case Type of
                                        'Adjustment':
                                            begin
                                                WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::Adjustment);
                                                WMSInvRecon.Validate(Process, true);
                                                WMSInvRecon."Reason Code" := ReasonCode;
                                            end;
                                        'Cond Update':
                                            begin
                                                WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::"Cond Update");
                                                WMSInvRecon.Validate(Process, true);
                                                WMSInvRecon."Reason Code" := ReasonCode;
                                            end;
                                        'Inv Lock':
                                            begin
                                                WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::"Inventory Lock");
                                                WMSInvRecon.Validate(Process, true);
                                                WMSInvRecon."Reason Code" := ReasonCode;
                                            end;
                                        'Inv UnLock':
                                            begin
                                                WMSInvRecon.Validate("Transaction Code", WMSInvRecon."Transaction Code"::"Inventory Unlock");
                                                WMSInvRecon.Validate(Process, true);
                                                WMSInvRecon."Reason Code" := ReasonCode;
                                            end;
                                    end;
                                    WMSInvRecon.Validate("Item No.", ItemNo);
                                    if Item.Get(ItemNo) then
                                        WMSInvRecon.Validate(Description, Item.Description);

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

                                    if TrackingQuantity <> '' then
                                        Evaluate(WMSInvRecon."WMS Qty.", TrackingQuantity)
                                    else
                                        Evaluate(WMSInvRecon."WMS Qty.", Quantity);

                                    WMSInvRecon.Validate("Condition Code", ConditionCode);
                                    WMSInvRecon.Validate("Lock Code", LockCode);
                                    if (WMSInvRecon."Transaction Code" = WMSInvRecon."Transaction Code"::"Cond Update") and (OldConditionCode <> '') then
                                        WMSInvRecon.Validate("WMS Notes", 'Previous Condition Code: ' + OldConditionCode);
                                    if ((WMSInvRecon."Transaction Code" = WMSInvRecon."Transaction Code"::"Inventory Lock") or (WMSInvRecon."Transaction Code" = WMSInvRecon."Transaction Code"::"Inventory Unlock")) and (OldLockCode <> '') then
                                        WMSInvRecon.Validate("WMS Notes", 'Previous Lock Code: ' + OldLockCode);

                                    WMSInvRecon.Validate("Lot No.", LotNo);
                                    WMSInvRecon.Validate("Serial No.", SerialNo);
                                    if ExpiryDate <> '' then begin
                                        Evaluate(Day, CopyStr(ExpiryDate, 9, 2));
                                        Evaluate(Month, CopyStr(ExpiryDate, 6, 2));
                                        Evaluate(Year, CopyStr(ExpiryDate, 1, 4));
                                        WMSInvRecon.Validate("Expiry Date", DMY2Date(Day, Month, Year));
                                    end;
                                    WMSInvRecon."From Location Code" := GetFromLocation(WMSInvRecon);
                                    if not (WMSInvRecon."Transaction Code" = WMSInvRecon."Transaction Code"::Adjustment) then begin
                                        WMSInvRecon."To Location Code" := GetToLocation(WMSInvRecon);
                                        WMSInvRecon.Validate("Reason Code", GetReasonCode(WMSInvRecon));
                                    end;
                                    WMSInvRecon.Modify(true);

                                    if WMSInvRecon."From Location Code" = WMSInvRecon."To Location Code" then begin
                                        WMSInvRecon.Process := false;
                                        WMSInvRecon."Processed Date" := Today;
                                        WMSInvRecon."Processed by User" := 'INTERFACE';
                                        WMSInvRecon.Approved := true;
                                        WMSInvRecon."Approved / Disapproved by User" := 'INTERFACE';
                                        WMSInvRecon.Modify(true);
                                    end;

                                    //Do not actually import into Integer table
                                    currXMLport.Skip();
                                end;
                            }
                        }
                        trigger OnAfterAssignVariable()
                        begin
                            ConditionCode := '';
                            OldConditionCode := '';
                            LockCode := '';
                            OldLockCode := '';
                            ReasonCode := '';
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

    trigger OnPreXmlPort()
    begin
        DecimalSignIsComma := IFSetup.DecimalSignIsComma();
    end;

    procedure SetFileName(FileName: Text[250]; IFSetupEntryNo: Integer)
    begin
        currXMLport.Filename := FileName;
        IFSetup.Get(IFSetupEntryNo);
    end;

    procedure GetFromLocation(Rec: Record "WMS Inventory Reconciliation"): Code[10]
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

        //Determine previous Lock or Condition code
        case Rec."Transaction Code" of
            Rec."Transaction Code"::Adjustment:
                begin
                    //Check if inventory has a lock code
                    if Rec."Lock Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                        WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else begin
                        //Check if inventory has a condition code
                        if Rec."Condition Code" <> '' then begin
                            WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                            WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                            if WMSLocationSetup.FindFirst() then
                                exit(WMSLocationSetup."Location Code")
                            else
                                exit('Unknown');
                        end else
                            //If no previous lock code and no condition, use base warehouse
                            exit(FromLocation);
                    end;
                end;
            Rec."Transaction Code"::"Cond Update":
                begin
                    //When inventory is locked, do not move inventory
                    if Rec."Lock Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                        WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end;

                    //When PrevCode is not empty, check location setup based upon previous condition (stated in WMS notes)
                    //Example of WMS Notes = Previous Condition Code: LOROC
                    i := StrPos(Rec."WMS Notes", 'Previous Condition Code: ');
                    if i > 0 then
                        PrevCode := CopyStr(Rec."WMS Notes", 26);

                    if PrevCode <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                        WMSLocationSetup.SetRange(Code, PrevCode);
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else
                        //If not locked and no previous condition, use base warehouse
                        exit(FromLocation);
                end;
            Rec."Transaction Code"::"Inventory Lock":
                begin
                    //When PrevCode is not empty, check location setup based upon previous lock code (stated in WMS notes)
                    //Example of WMS Notes = Previous Lock Code: LOCKED
                    TempText := CopyStr(Rec."WMS Notes", 1, 6);
                    i := StrPos(Rec."WMS Notes", 'Previous Lock Code: ');
                    if i > 0 then
                        PrevCode := CopyStr(Rec."WMS Notes", 21);

                    if PrevCode <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                        WMSLocationSetup.SetRange(Code, PrevCode);
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else begin
                        //Check if inventory has a condition code
                        if Rec."Condition Code" <> '' then begin
                            WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                            WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                            if WMSLocationSetup.FindFirst() then
                                exit(WMSLocationSetup."Location Code")
                            else
                                exit('Unknown');
                        end else
                            //If no previous lock code and no condition, use base warehouse
                            exit(FromLocation);
                    end;
                end;
            Rec."Transaction Code"::"Inventory Unlock":
                begin
                    //Example of WMS Notes = Previous Lock Code: LOCKED
                    TempText := CopyStr(Rec."WMS Notes", 1, 6);
                    i := StrPos(Rec."WMS Notes", 'Previous Lock Code: ');
                    if i > 0 then
                        PrevCode := CopyStr(Rec."WMS Notes", 21);

                    if PrevCode <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                        WMSLocationSetup.SetRange(Code, PrevCode);
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else
                        exit('Unknown');
                end;
        end;
    end;

    procedure GetToLocation(Rec: Record "WMS Inventory Reconciliation"): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
    begin
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        case Rec."Transaction Code" of
            Rec."Transaction Code"::"Cond Update":
                begin
                    //When inventory is locked, do not move inventory
                    if Rec."Lock Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                        WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end;

                    if Rec."Condition Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                        WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
                        WMSLocationSetup.FindFirst();
                        exit(WMSLocationSetup."Location Code");
                    end;
                end;
            Rec."Transaction Code"::"Inventory Lock":
                begin
                    WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                    WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                    if WMSLocationSetup.FindFirst() then
                        exit(WMSLocationSetup."Location Code")
                    else
                        exit('Unknown');
                end;
            Rec."Transaction Code"::"Inventory Unlock":
                begin
                    //If inventory has a condition code use this location
                    if Rec."Condition Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                        WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                        if WMSLocationSetup.FindFirst() then
                            exit(WMSLocationSetup."Location Code")
                        else
                            exit('Unknown');
                    end else begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
                        WMSLocationSetup.FindFirst();
                        exit(WMSLocationSetup."Location Code");
                    end;
                end;
        end;
    end;

    procedure GetReasonCode(Rec: Record "WMS Inventory Reconciliation"): Code[10]
    var
        WMSLocationSetup: Record "WMS Inventory Location Setup";
    begin
        WMSLocationSetup.SetRange("Interface Setup Entry No.", IFSetup."Entry No.");
        case Rec."Transaction Code" of
            Rec."Transaction Code"::"Cond Update":
                begin
                    if Rec."Condition Code" <> '' then begin
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Condition);
                        WMSLocationSetup.SetRange(Code, Rec."Condition Code");
                    end else
                        WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
                    if WMSLocationSetup.FindFirst() then
                        exit(WMSLocationSetup."Reason Code Reclass.");
                end;
            Rec."Transaction Code"::"Inventory Lock":
                begin
                    WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Lock);
                    WMSLocationSetup.SetRange(Code, Rec."Lock Code");
                    if WMSLocationSetup.FindFirst() then
                        exit(WMSLocationSetup."Reason Code Reclass.");
                end;
            Rec."Transaction Code"::"Inventory Unlock":
                begin
                    WMSLocationSetup.SetRange(Type, WMSLocationSetup.Type::Warehouse);
                    WMSLocationSetup.FindFirst();
                    exit(WMSLocationSetup."Reason Code Reclass.");
                end;
        end;
    end;

    //Global variable
    var
        IFSetup: Record "Interface Setup";
        DecimalSignIsComma: Boolean;
}