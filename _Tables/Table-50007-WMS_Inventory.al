table 50007 "WMS Inventory Reconciliation"

//  RHE-TNA 21-07-2020..01-12-2020 BDS-4323
//  - New Table

//  RHE-TNA 25-01-2021 BDS-4324
//  - Added field 24 - Calculated Inv. Level
//  - Added field 25 - Inv. Level Difference
//  - Added field 26 - Inventory Level Run

//  RHE-TNA 02-02-2022 BDS-5585
//  - Added field 27

{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {

        }
        field(2; "Transaction Date"; Date)
        {

        }
        field(3; Process; Boolean)
        {

        }
        field(4; "Processed Date"; Date)
        {

        }
        field(5; Approved; Boolean)
        {
            trigger OnValidate()
            begin
                if Approved then
                    Validate("Approved / Disapproved by User", UserId)
                else
                    Validate("Approved / Disapproved by User", '');
            end;
        }
        field(6; "Approved / Disapproved by User"; code[50])
        {

        }
        field(7; "Transaction Code"; Option)
        {
            OptionMembers = "Stock Level","Cond Update","Adjustment","Inventory Lock","Inventory Unlock";
        }
        field(8; "Item No."; Code[20])
        {

        }
        field(9; Description; Text[100])
        {

        }
        field(10; "WMS Qty."; Decimal)
        {

        }
        field(11; "Condition Code"; Code[10])
        {

        }
        field(12; "Lock Code"; Code[10])
        {

        }
        field(13; "Lot No."; Code[50])
        {

        }
        field(14; "Serial No."; Code[50])
        {

        }
        field(15; Error; Boolean)
        {

        }
        field(16; "Error Text"; Text[250])
        {

        }
        field(17; "Processed by User"; Text[50])
        {

        }
        field(18; "WMS Notes"; Text[250])
        {

        }
        field(19; "From Location Code"; Code[10])
        {
            TableRelation = Location;
        }
        field(20; "To Location Code"; Code[10])
        {
            TableRelation = Location;
        }
        field(21; "Reason Code"; Code[10])
        {
            TableRelation = "Reason Code";
        }
        field(22; "Expiry Date"; Date)
        {

        }
        field(23; Disapproved; Boolean)
        {
            trigger OnValidate()
            begin
                if Disapproved then
                    Validate("Approved / Disapproved by User", UserId)
                else
                    Validate("Approved / Disapproved by User", '');
            end;
        }
        field(24; "Calculated Inv. Level"; Decimal)
        {

        }
        field(25; "Inv. Level Difference"; Decimal)
        {

        }
        field(26; "Inventory Level Run"; Integer)
        {

        }
        field(27; "Interface Setup Entry No."; Integer)
        {

        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        WMSInventory: Record "WMS Inventory Reconciliation";
    begin
        if WMSInventory.FindLast() then
            "Entry No." := WMSInventory."Entry No." + 1
        else
            "Entry No." := 1;
        WMSInventory.Process := true;
    end;
}