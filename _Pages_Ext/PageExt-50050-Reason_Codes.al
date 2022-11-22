/// <summary>
/// Page PageExt-50050-Reason_Codes(ID 50050).
/// </summary>   
pageextension 50050 "Reason Codes Extension" extends "Reason Codes"
{
    //  RHE-AMKE 01-08-2022 BDS-6441
    //  - Added Exclude Field
    layout
    {
        addafter(Description)
        {

            field("ExclReasonEDI"; "ExclReasonEDI")
            {
                ToolTip = 'Set this field to exclude the Reason being send in the Shipping Confirmation.';
            }
        }
    }

}
