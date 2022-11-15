pageextension 50052 "Purchase Order Line Extension" extends "Purchase Order Subform"

//  RHE-AMKE 22-08-2022 BDS-6558
// Craete EXT&Added field "manuf_dstamp"
{
    layout
    {
        addafter("Location Code")
        {
            field("Manufacture Date"; "Manufacture Date")
            {

            }

        }
    }
}