table 50002 "WMS Import Line"

//  RHE-TNA 19-03-2020..26-05-2020 BDS-3866
//  - Added fields 19, 20 & 21
//  - Modified trigger OnDelete

//  RHE-TNA 14-05-2020..28-05-2020 BDS-4147
//  - Added field 22 --> 28-05-2020: Removed field due to not using Kitting functionality in WMS

//  RHE-TNA 31-12-2021 BDS-5977
//  - Added Key1

{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Whse. Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Source No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Source Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Location Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Qty. Shipped / Received"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Batch Id"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Expiration Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Assembly Line"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Assembly Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Assembly Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Assembly Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Serial/Lot"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Serial,Lot;
        }
        field(17; Error; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Error Text"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 17-03-2020..11-05-2020 BDS-3946 BEGIN
        field(19; "WMS Line Id"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "WMS Pallet Id"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Tag Id"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 17-03-2020..11-05-2020 BDS-3946 END
    }

    keys
    {
        key(PK; "Entry No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key1; "Entry No.", "Assembly Line", "Assembly Order No.", "Assembly Line No.")
        {

        }
    }

    trigger OnInsert()
    var
        WMSImportLine: Record "WMS Import Line";
    begin
        WMSImportLine.SetRange("Entry No.", "Entry No.");
        if WMSImportLine.FindLast() then
            "Line No." := WMSImportLine."Line No." + 1
        else
            "Line No." := 1;
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        WMSSerialNo: Record "WMS Import Serial Number";
    begin
        //RHE-TNA 19-03-2020..26-05-2020 BDS-3946 BEGIN
        WMSSerialNo.SetRange("WMS Import Entry No.", "Entry No.");
        WMSSerialNo.SetRange("Item No.", "Item No.");
        WMSSerialNo.DeleteAll(true);
        //RHE-TNA 19-03-2020..26-05-2020 BDS-3946 END
    end;

    trigger OnRename()
    begin

    end;

}