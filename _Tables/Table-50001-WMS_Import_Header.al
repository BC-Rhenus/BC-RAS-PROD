table 50001 "WMS Import Header"

//  RHE-TNA 30-04-2021 BDS-5304
//  - Added fields 14 and 15

{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; Type; Option)
        {
            OptionMembers = Shipment,Receipt;
        }
        field(3; "Whse. Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Source No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Bill Of Lading No."; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Import Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Process; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Processed Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; Error; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Error Text"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Processed by User"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(13; "Receipt Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 30-04-2021 BDS-5304 BEGIN
        field(14; "Carrier"; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Service Level"; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 30-04-2021 BDS-5304 EMD
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
        WMSImportHdr: Record "WMS Import Header";
    begin
        if WMSImportHdr.FindLast() then
            "Entry No." := WMSImportHdr."Entry No." + 1
        else
            "Entry No." := 1;
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        WMSImportLines: Record "WMS Import Line";
    begin
        WMSImportLines.SetRange("Entry No.", "Entry No.");
        WMSImportLines.DeleteAll(true);
    end;

    trigger OnRename()
    begin

    end;

}