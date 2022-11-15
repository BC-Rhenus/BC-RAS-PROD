table 50005 "WMS Import Serial Number"

//  RHE-TNA 17-03-2020..14-05-2020 BDS-3866
//  - New Table

//  RHE-TNA 21-01-2022 BDS-5977
//  - Added Caption
//  - Added fields 8 until 11

{
    DataClassification = ToBeClassified;
    //RHE-TNA 30-12-2021 BDS-5977 BEGIN
    Caption = 'WMS Import Item Tracking Lines';
    //RHE-TNA 30-12-2021 BDS-5977 END

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "WMS Import Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Serial No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Pallet Id"; code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Tag Id"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Processed; Boolean)
        {

        }
        field(8; "Lot No."; Code[50])
        {

        }
        field(9; "Expiration Date"; Date)
        {

        }
        field(10; "WMS Import Line No."; Integer)
        {

        }
        field(11; Quantity; Decimal)
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
        WMSImportSN: Record "WMS Import Serial Number";
    begin
        if WMSImportSN.FindLast() then
            "Entry No." := WMSImportSN."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}