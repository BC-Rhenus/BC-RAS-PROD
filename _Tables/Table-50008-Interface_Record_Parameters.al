table 50008 "Interface Record Parameters"

//  RHE-TNA 21-08-2020 BDS-4374
//  - New Table

//  RHE-TNA 16-10-2020..16-11-2020 BDS-4551
//  - Added field 7 - Param4
//  - Added optionmember Location to field 2

//  RHE-TNA 11-06-2021 BDS-5337 
//  - Added field 9 - Source System Line ID
//  - Added field 10 - Source Line No.

{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {

        }
        field(2; "Source Type"; Option)
        {
            OptionMembers = Item,Order,Location;
        }
        field(3; "Source No."; Code[20])
        {
            TableRelation = if ("Source Type" = CONST (Item)) Item else
            "Sales Header" where ("Document Type" = CONST (Order));
        }
        field(4; Param1; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Param2; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Param3; text[50])
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 16-10-2020 BDS-4551 BEGIN
        field(7; Param4; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 16-10-2020 BDS-4551 END
        //RHE-TNA 13-11-2020 BDS-4551 BEGIN
        field(8; Param5; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 13-11-2020 BDS-4551 END
        //RHE-TNA 11-06-2021 BDS-5337 BEGIN
        field(9; "Source System Line ID"; text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Source Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 11-06-2021 BDS-5337 END
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
        IFRecordParam: Record "Interface Record Parameters";
    begin
        if IFRecordParam.FindLast() then
            "Entry No." := IFRecordParam."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}