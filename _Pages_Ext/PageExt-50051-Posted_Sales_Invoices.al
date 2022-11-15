/// <summary>
/// Page PageExt-50051-Posted_Sales_Invoices(ID 50051).
/// </summary>   
pageextension 50051 "Posted Sales Invoices Ext." extends "Posted Sales Invoices"

//RHE-AMKE 11-08-2022 BDS-6544
//  - New Page Ext.

{

    layout
    {
        addafter("Shipping Agent Code")
        {
            field("Package Tracking No."; "Package Tracking No.")
            {

            }
        }
    }

}
