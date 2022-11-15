table 50003 "Interface Mapping"

//  RHE-TNA 08-02-2022 BDS-6102
//  - Renamed table from Carrier into "Interface Mapping"
//  - Renamed field 1 from Carrier into "Interface Value"
//  - Change PK from Carrier into Type, "Interface Value"
//  - Added field 7, 8 & 9

{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Interface Value"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Shipping Agent Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent";
        }
        field(4; "Ship Agent Service Code Dom."; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent Services".Code where ("Shipping Agent Code" = field ("Shipping Agent Code"));
        }
        field(5; "Ship Agent Service Code EU"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent Services".Code where ("Shipping Agent Code" = field ("Shipping Agent Code"));
        }
        field(6; "Ship Agent Service Code Export"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent Services".Code where ("Shipping Agent Code" = field ("Shipping Agent Code"));
        }
        field(7; Type; Option)
        {
            OptionMembers = Carrier,Currency;
        }
        field(8; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(9; "LCY Code"; Boolean)
        {

        }
    }

    keys
    {
        key(PK; Type, "Interface Value")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}