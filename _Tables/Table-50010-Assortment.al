table 50010 Assortment

//  RHE-TNA 19-05-2022 BDS-6111
//  - New Table

{
    DataClassification = ToBeClassified;
    Caption = 'Assortment / Exception List';

    fields
    {
        field(1; "Assortment Group"; Code[10])
        {
            TableRelation = "Rhenus Setup".Code where (Type = const ("Assortment/Exception Group"));
        }
        field(2; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(3; "Starting Date"; Date)
        {
            trigger OnValidate()
            begin
                if ("Ending Date" <> 0D) and ("Starting Date" > "Ending Date") then
                    Error('Starting Date cannot be later than Ending Date');
            end;
        }
        field(4; "Ending Date"; Date)
        {
            trigger OnValidate()
            begin
                if "Ending Date" < "Starting Date" then
                    Error('Ending Date cannot be earlier than Starting Date');
            end;
        }
    }

    keys
    {
        key(PK; "Assortment Group", "Item No.", "Starting Date")
        {
            Clustered = true;
        }
    }
}