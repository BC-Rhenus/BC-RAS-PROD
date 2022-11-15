/// <summary>
/// Page PageExt-50048-Transfer_Orders (ID 50048).
/// </summary>
pageextension 50048 "Transfer Orders Ext." extends "Transfer Orders"

//  RHE-AMKE 15-06-2022 BDS-6406
//  - New Field Transfer-to Name

{
    layout
    {
        addbefore("status")
        {
            field("Transfer to-Name"; "Transfer-to Name")
            {
                toolTip = 'Specifies the name of the recipient at the location that the items are transferred to.';
            }
        }
    }

}