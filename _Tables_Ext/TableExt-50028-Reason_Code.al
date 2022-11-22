tableextension 50028 "Reason Code Ext." extends "Reason Code"

//  RHE-AMKE 30-06-2022 BDS-6441
//  - New extension

{
    fields
    {
        field(50000; "ExclReasonEDI"; Boolean)
        {
            Caption = 'Exclude Reason on EDI.';
        }
    }
}