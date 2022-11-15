pageextension 50026 "Transfer Order Line Ext." extends "Transfer Order Subform"

//  RHE-TNA 10-06-2021 BDS-5385
//  - New extension

{
    layout
    {
        addafter("Unit of Measure Code")
        {
            field("Unit Price"; "Unit Price")
            {

            }
            field("Line Amount"; "Line Amount")
            {

            }
        }
    }

}