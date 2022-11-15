pageextension 50013 "Sales Order Archive Ext." extends "Sales Order Archive"

//  RHE-TNA 26-11-2021 BDS-5676
//  - Added field "EDI Status"
//  - Added field "Last EDI Export Date/Time"

{
    layout
    {
        addafter(Status)
        {
            field("Reason Code"; "Reason Code")
            {

            }
            field("EDI Status"; "EDI Status")
            {

            }
            field("Last EDI Export Date/Time"; "Last EDI Export Date/Time")
            {

            }
        }
    }
}