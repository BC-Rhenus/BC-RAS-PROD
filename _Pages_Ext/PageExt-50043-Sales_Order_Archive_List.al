pageextension 50043 "Sales Order Archive List Ext." extends "Sales Order Archives"

//  RHE-TNA 26-11-2021 BDS-5676
//  - New extension

{
    layout
    {
        addafter("Currency Code")
        {
            field("EDI Status"; "EDI Status")
            {

            }
            field("Last EDI Export Date/Time"; "Last EDI Export Date/Time")
            {

            }
        }
    }
}