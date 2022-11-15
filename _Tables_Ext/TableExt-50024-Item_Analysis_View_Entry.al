tableextension 50024 "Item Analysis View Entry Ext." extends "Item Analysis View Entry"

//  RHE-TNA 08-01-2021 BDS-4835
//  - New table extension

//  RHE-TNA 10-01-2022 BDS-5994
//  - Added field 50014

{
    fields
    {
        field(50000; "Reporting Entry No."; Integer)
        {

        }
        field(50001; Company; Text[30])
        {

        }
        field(50002; Name; Text[100])
        {

        }
        field(50003; "Shipping Agent"; Code[10])
        {

        }
        field(50004; "Ship-to Country"; Code[10])
        {

        }
        field(50005; Status; text[10])
        {

        }
        field(50006; Return; Text[3])
        {

        }
        field(50007; "Document No."; Code[20])
        {

        }
        field(50008; "B2B/B2C"; Text[3])
        {

        }
        field(50009; "Last Updated"; DateTime)
        {

        }
        field(50010; "Reason Code"; Code[10])
        {

        }
        field(50011; "Buy-from Country"; Code[10])
        {

        }
        field(50012; "Qty."; Decimal)
        {

        }
        field(50013; "Total Cost"; Decimal)
        {

        }
        field(50014; "Source Document No."; Code[20])
        {

        }
    }

    keys
    {
        key(key1; "Reporting Entry No.")
        {

        }
    }
}