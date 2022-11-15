tableextension 50018 "Ship-to Address Ext." extends "Ship-to Address"

//  RHE-TNA 19-05-2022 BDS-6111
//  - Added field 50001

{
    fields
    {
        field(50000; "EDI Identifier"; Code[50])
        {

        }
        field(50001; "Assortment/Exception Group"; Code[10])
        {
            TableRelation = "Rhenus Setup".Code where (Type = const ("Assortment/Exception Group"));
            trigger OnValidate()
            begin
                if not Confirm('Are you sure you want to change the value for Assortment/Exception Group?') then
                    Error('Process canceled.');
            end;
        }
    }
}