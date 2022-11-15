table 50000 "Interface Setup"

//  RHE-TNA 17-03-2020..14-05-2020 BDS-3866
//  - Added field 24 - WMS Version
//  - Removed field 6: WMS uses Serial Number Table

//  RHE-TNA 06-04-2020 BDS-4033
//  - Disable field 21

//  RHE-TNA 21-08-2020 BDS-4374
//  - Added field 25 - Use Webshop Customer ID

//  RHE-TNA 15-10-2020..19-10-2020 BDS-4551
//  - Added field 26 - Send Ship Ready Message
//  - Added field 27 - Ship Ready Export Directory
//  - Added field 28 - Ship Ready Import Directory
//  - Added field 29 - Ship Ready Dir. Processed

//  RHE-TNA 14-06-2021..29-03-2022 BDS-5337
//  - Redesign table

//  RHE-TNA 18-10-2021 BDS-5677
//  - Added field 41 - Last ILE No. Exported

//  RHE-TNA 18-10-2021 BDS-5678
//  - Change Caption field 22
//  - Added field 42 - "Export Inventory Level"
//  - Added field 43 - "Export Inventory Update"
//  - Added field 44 - "Export Inventory Availability"

//  RHE-TNA 16-11-2021..25-02-2022 BDS-5676
//  - Added field 37 - Send Sales Order Message
//  - Added field 38 - Sales Order Export Directory
//  - Added field 39 - Send New Sales Orders Only
//  - Added field 40 - Qty. of Orders per XML
//  - Added field 45 - Add Line Type
//  - Added field 46 - Add Ship-to/Bill-to Country
//  - Added field 47 - Add Payment Information
//  - Added field 48 - Send IF Received Orders
//  - Modified procedure GetIFSetupRecforDocNo()

//  RHE-TNA 29-11-2021 BDS-5891
//  - Modified field 18: Code[10] > Code[20]

//  RHE-TNA 19-01-2022 BDS-5585
//  - Modifield field 30 - Type
//  - Added procedure GetWMSIFSetupEntryNo()

//  RHE-TNA 31-03-2022..19-04-2022 BDS-6233
//  - Added fields 49 & 51

//  RHE-TNA 14-04-2022 BDS-6269
//  - Added field 50
//  - Disabled fields 45, 46 & 47

//  RHE-TNA 27-05-2022 BDS-6366
//  - Deleted fields 100 until 106

//  RHE-TNA 20-06-2022 BDS-6438
//  - Modified field 50

//  RHE-TNA 21-06-2022 BDS-6440
//  - Modified field 50

{
    DataClassification = ToBeClassified;
    Permissions = tabledata 405 = ri; //405 = Change Log Entry

    fields
    {
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //field(1; "Primary Key"; Code[10])
        field(1; "Entry No."; Integer)
        //RHE-TNA 14-06-2021 BDS-5337 END
        {
            DataClassification = ToBeClassified;
        }
        field(2; "WMS Client ID"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "WMS Site ID"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "WMS Upload Directory"; text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "WMS Download Directory"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "WMS Download Dir. Processed"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Order Import Cust. No. B2C"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer;
        }
        field(11; "Order Import Cust. No. B2B"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer;
        }
        field(12; "Order Import Discount Account"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(13; "Order Import Ship Cost Account"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
            Caption = 'Order Import Shipping Cost Account';
        }
        field(14; "Order Import Directory"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Order Import Dir. Processed"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Order Import Dir. Error"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Order Import Order ID Usage"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Order No.","External Document No.";
        }
        field(18; "Order Import Order Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(19; "Order Import Doc. Cost Account"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
            Caption = 'Order Import Document Cost Account';
        }
        field(20; "Ship Confirmation Directory"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipment Confirmation Directory';
        }
        /*RHE-TNA 06-04-2020 BDS-4033 BEGIN
        field(21; "Send SSCC info. with Invoice"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Send SSCC info. with Shipment Confirmation file';
        }
        RHE-TNA 06-04-2020 BDS-4033 END*/
        field(22; "Inv. Export Loc. Filter"; Text[250])
        {
            DataClassification = ToBeClassified;
            //RHE-TNA 18-10-2021 BDS-5678 BEGIN
            //Caption = 'Inventory Export Location Filter';
            Caption = 'Available Inventory Location Filter';
            //RHE-TNA 18-10-2021 BDS-5678 END
        }
        field(23; "Inv. Export Directory"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Inventory Export Directory';
        }
        field(24; "WMS Version"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = WMS2016,WMS2009;
        }
        field(25; "Disable Webshop Customer ID"; Boolean)
        {

        }
        field(26; "Send Ship Ready Message"; Boolean)
        {

        }
        field(27; "Ship Ready Export Directory"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Ship Ready Import Directory"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Ship Ready Dir. Processed"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        field(30; Type; Option)
        {
            //RHE-TNA 19-01-2022 BDS-5585 BEGIN
            /*OptionMembers = Customer,WMS;           
            trigger OnValidate()
            var
                IFSetup: Record "Interface Setup";
            begin
                //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                if Rec.Type = Rec.Type::WMS then begin
                    //RHE-TNA 19-01-2022 BDS-5585 END
                    IFSetup.SetRange(Type, IFSetup.Type::WMS);
                    if IFSetup.FindFirst() then
                        Error('A record with Type = WMS already exists.');
                    //RHE-TNA 19-01-2022 BDS-5585 BEGIN
                end;
                //RHE-TNA 19-01-2022 BDS-5585 END
            end;*/
            OptionMembers = Customer,"Blue Yonder WMS","External WMS";
            //RHE-TNA 19-01-2022 BDS-5585 END
        }
        field(31; Description; Text[100])
        {

        }
        field(32; Active; Boolean)
        {

        }
        field(33; "Interface Identifier"; Code[10])
        {

        }
        field(34; "Add Error Text"; Boolean)
        {

        }
        field(35; "Manually Created S.-Orders"; Boolean)
        {
            trigger OnValidate()
            var
                IFSetup: Record "Interface Setup";
            begin
                IFSetup.SetRange(Type, IFSetup.Type::Customer);
                IFSetup.SetRange("Manually Created S.-Orders", true);
                if IFSetup.FindFirst() then
                    Error('A record with this setting already exists.');
            end;
        }
        field(36; "In Progress"; Boolean)
        {

        }
        //RHE-TNA 14-06-2021 BDS-5337 END
        field(37; "Send Sales Order Message"; Boolean)
        {

        }
        field(38; "Sales Order Export Directory"; Text[100])
        {

        }
        field(39; "Send New Sales Orders Only"; Boolean)
        {

        }
        field(40; "Qty. of Orders per XML"; Option)
        {
            OptionMembers = "One","Multiple";
        }
        field(41; "Last ILE No. Exported"; Integer)
        {

        }
        field(42; "Export Inventory Level"; Boolean)
        {

        }
        field(43; "Export Inventory Update"; Boolean)
        {

        }
        field(44; "Export Inventory Availability"; Boolean)
        {

        }
        /*
        field(45; "Add Line Type"; Boolean)
        {

        }        
        field(46; "Add Ship-to/Bill-to Country"; Boolean)
        {

        }        
        field(47; "Add Payment Information"; Boolean)
        {

        }
        */
        field(48; "Send IF Received Orders"; Boolean)
        {
            Caption = 'Send Orders Received Via Interface';
        }
        field(49; "Order Status to Send"; Option)
        {
            OptionMembers = Open,"Open & Released",Released;
        }
        field(50; "Shipment Confirmation Version"; Option)
        {
            OptionMembers = "1.0","2.0","3.0","4.0","5.0";
        }
        field(51; "Order Version"; Option)
        {
            OptionMembers = "1.0","2.0";
        }
    }

    keys
    {
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //key(PK; "Primary Key")
        key(PK; "Entry No.")
        //RHE-TNA 14-06-2021 BDS-5337 END
        {
            Clustered = true;
        }
    }

    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
    trigger OnInsert()
    var
        IFSetup: Record "Interface Setup";
    begin
        if IFSetup.FindLast() then
            "Entry No." := IFSetup."Entry No." + 1
        else
            "Entry No." := 1;

        //RHE-TNA 19-01-2022 BDS-5585 BEGIN
        /*
        if Type = Type::WMS then begin
            IFSetup.SetRange(Type, IFSetup.Type::WMS);
            if IFSetup.FindFirst() then
                Error('Setup with Type = WMS already exists.');
        end;
        */
        //RHE-TNA 19-01-2022 BDS-5585 END
    end;

    trigger OnDelete()
    begin
        if Active then
            Error('Not allowed to delete an active entry.');
    end;
    //RHE-TNA 14-06-2021 BDS-5337 END

    procedure DecimalSignIsComma(): Boolean;
    //Local Variables
    var
        CheckAmount: Decimal;
        CheckString: Text[10];
    begin
        CheckAmount := 1.2;
        CheckString := Format(CheckAmount);
        if StrPos(CheckString, ',') > 0 then
            exit(true)
        else
            exit(false);
    end;

    procedure CheckChangeLog(TableNo: Integer; PrimaryKeyField1Value: Text[50]; User: code[50]): Boolean
    var
        ChangeLogEntry: Record "Change Log Entry";
    begin
        ChangeLogEntry.SetCurrentKey("Table No.", "Primary Key Field 1 Value");
        ChangeLogEntry.SetRange("Table No.", TableNo);
        ChangeLogEntry.SetRange("Primary Key Field 1 Value", PrimaryKeyField1Value);
        ChangeLogEntry.SetRange("User ID", User);
        if ChangeLogEntry.FindFirst() then
            exit(true)
        else
            exit(false);
    end;

    procedure InsertChangeLog(TableNo: Integer; PrimaryKeyField1Value: Text[50]; User: code[50])
    var
        ChangeLogEntry: Record "Change Log Entry";
        EntryNo: Integer;
    begin
        ChangeLogEntry.Reset();
        EntryNo := 1;
        if ChangeLogEntry.FindLast() then
            EntryNo := ChangeLogEntry."Entry No." + 1;

        ChangeLogEntry.Init();
        ChangeLogEntry."Entry No." := EntryNo;
        ChangeLogEntry."Date and Time" := CurrentDateTime;
        ChangeLogEntry.Time := Time;
        ChangeLogEntry."User ID" := User;
        ChangeLogEntry."Table No." := TableNo;
        ChangeLogEntry."Primary Key Field 1 Value" := PrimaryKeyField1Value;
        ChangeLogEntry.Insert(true);
    end;

    procedure SwitchPointComma(var ConvString: Text[100])
    begin
        if StrPos(ConvString, '.') <> 0 then
            ConvString := ConvertStr(ConvString, '.', '#');
        if StrPos(ConvString, ',') <> 0 then
            ConvString := ConvertStr(ConvString, ',', '.');
        if StrPos(ConvString, '#') <> 0 then
            ConvString := ConvertStr(ConvString, '#', ',');
    end;

    //RHE-TNA 14-06-2021 BDS-5337 BEGIN
    procedure GetIFSetupRecforDocNo(DocNo: Code[20]): Integer
    var
        IFLog: Record "Interface Log";
    begin
        //RHE-TNA 16-11-2021..29-03-2022 BDS-5676 BEGIN
        Rec.Reset();
        IFLog.SetRange(Direction, IFLog.Direction::"From Customer");
        //RHE-TNA 16-11-2021 BDS-5676 END
        Rec.SetRange(Type, Rec.Type::Customer);
        Rec.SetRange(Active, true);
        IFLog.SetRange(Reference, DocNo);
        IFLog.SetRange(Error, false);
        if IFLog.FindLast() then begin
            Rec.SetRange("Interface Identifier", IFLog."Interface Prefix");
            if Rec.FindFirst() then
                exit(Rec."Entry No.")
            else begin
                Rec.SetRange("Interface Identifier", '');
                Rec.FindFirst();
                exit(Rec."Entry No.");
            end;
        end else begin
            //These are orders which where created manually
            Rec.SetRange("Manually Created S.-Orders", true);
            if Rec.FindFirst() then
                exit(Rec."Entry No.");
            /*RHE-TNA 16-11-2021 BDS-5676 BEGIN
            else
            Error('No setup found to export this document type for manually created orders.');
            RHE-TNA 16-11-2021 BDS-5676 END*/
        end;
    end;
    //RHE-TNA 14-06-2021..29-03-2022 BDS-5337 END

    //RHE-TNA 19-01-2022 BDS-5585 BEGIN
    procedure GetWMSIFSetupEntryNo(var LocationCode: Code[10]): Integer
    var
        Location: Record Location;
    begin
        Location.Get(LocationCode);
        if Location."WMS Interface Setup Entry No." = 0 then
            Error('No interface setup found for Location Code ' + LocationCode + '.')
        else begin
            Rec.Get(Location."WMS Interface Setup Entry No.");
            if (Rec.Type <> Rec.Type::"Blue Yonder WMS") and (Rec.Type <> Rec.Type::"External WMS") then
                Error('Interface setup for Location Code ' + LocationCode + ' is not setup for integration with WMS.');
            if Rec.Active = false then
                Error('Interface setup for Location Code ' + LocationCode + ' is not activated.');
            exit(Rec."Entry No.");
        end;
    end;
    //RHE-TNA 19-01-2022 BDS-5585 END   
}