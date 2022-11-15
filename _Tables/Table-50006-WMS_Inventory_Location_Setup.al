table 50006 "WMS Inventory Location Setup"

//  RHE-TNA 21-07-2020 BDS-4323
//  - New Table

//  RHE-TNA 11-12-2020 BDS-4324
//  - Added field 5 - "Reason Code Inv. Level"

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

//  RHE-TNA 01-02-2022 BDS-5976
//  - Added field 6
//  - Added field 6 to PK

{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Type; Option)
        {
            OptionMembers = Condition,Lock,Warehouse;
            trigger OnValidate()
            var
                Rec: Record "WMS Inventory Location Setup";
                //RHE-TNA 21-01-2022 BDS-6037 BEGIN
                //ErrorText001: TextConst
                //    ENU = 'Type Warehouse can only be set once.';
                ErrorText001: Label 'Type Warehouse can only be set once.';
                //RHE-TNA 21-01-2022 BDS-6037 END
            begin
                if Type = Type::Warehouse then begin
                    Rec.SetRange(Type, Rec.Type::Warehouse);
                    //RHE-TNA 01-02-2022 BDS-5976 BEGIN
                    Rec.SetRange("Interface Setup Entry No.", Rec."Interface Setup Entry No.");
                    //RHE-TNA 01-02-2022 BDS-5976 END
                    if Rec.FindFirst() then
                        Error(ErrorText001);
                end;
            end;
        }
        field(2; Code; Code[20])
        {

        }
        field(3; "Location Code"; Code[10])
        {
            TableRelation = Location;
        }
        field(4; "Reason Code Reclass."; Code[10])
        {
            TableRelation = "Reason Code";
        }
        field(5; "Reason Code Inv. Level"; Code[10])
        {
            TableRelation = "Reason Code";
        }
        field(6; "Interface Setup Entry No."; Integer)
        {
            TableRelation = "Interface Setup";
        }
    }

    keys
    {
        key(PK; Type, Code, "Interface Setup Entry No.")
        {
            Clustered = true;
        }
    }
}