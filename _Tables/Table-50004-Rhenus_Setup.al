table 50004 "Rhenus Setup"

//  RHE-TNA 15-02-2022 BDS-6111
//  - Renamed Table from Order Substatus into Rhenus Setup
//  - Added field 3
//  - Modified PK

{
    DataClassification = ToBeClassified;
    //LookupPageId = "Order Substatus";

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = ToBeClassified;

        }
        field(2; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Type; Option)
        {
            OptionMembers = "Order Substatus","Assortment/Exception Group";
        }
    }

    keys
    {
        //key(PK; Code)
        key(PK; Code, Type)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Description)
        {

        }
    }

    //Global Variables
    var

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