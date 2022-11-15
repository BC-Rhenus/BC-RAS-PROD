pageextension 50024 "Shipping Agent Services Ext." extends "Shipping Agent Services"

//  RHE-TNA 15-05-2020 BDS-3866
//  - Added field WMS Dispatch Method

//  RHE-TNA 30-04-2021 BDS-5304
//  - Added field WMS Carrier
//  - Added field WMS Service Level

//  RHE-TNA 15-10-2021 BDS-5679
//  - Added field Service Incl. Tracking No.

{
    layout
    {
        addafter("Shipping Time")
        {
            field(Hub; Hub)
            {

            }
            field("WMS Dispatch Method"; "WMS Dispatch Method")
            {

            }
            field("WMS Carrier"; "WMS Carrier")
            {

            }
            field("WMS Service Level"; "WMS Service Level")
            {

            }
            field("Service Incl. Tracking No."; "Service Incl. Tracking No.")
            {
                ToolTip = 'This field determines if the Tracking Number of a Sales Invoice is exported, to the customer, in the Invoice XML. If this field is set to false/off, no Tracking Number is exported.';
            }
        }
    }
}