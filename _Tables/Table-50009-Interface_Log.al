table 50009 "Interface Log"

//  RHE-TNA 23-11-2020 BDS-4705
//  - New Table

//  RHE-TNA 14-06-2021 BDS-5337
//  - Added field 13

//  RHE-TNA 16-11-2021 BDS-5676
//  - Added procedure CheckEDIOrder()

{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; Source; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Direction; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "From Customer","To Customer";
        }
        field(4; Date; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Time; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Filename; text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Reference; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Error; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Error Text"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Acknowledged By User"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Acknowledged Date/Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Filename Short"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        field(13; "Interface Prefix"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 14-06-2021 BDS-5337 END
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
        IFLogRec: Record "Interface Log";
    begin
        if IFLogRec.FindLast() then
            "Entry No." := IFLogRec."Entry No." + 1
        else
            "Entry No." := 1;
    end;

    //RHE-TNA 16-11-2021 BDS-5676 BEGIN
    procedure CheckEDIOrder(var OrderNo: Code[20]): Boolean
    begin
        //Check if order is created manually or via interface
        Rec.SetRange(Reference, OrderNo);
        Rec.SetRange(Direction, Rec.Direction::"From Customer");
        if Rec.FindLast() then
            exit(true)
        else
            exit(false);
    end;
    //RHE-TNA 16-11-2021 BDS-5676 END
}