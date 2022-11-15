pageextension 50023 "VAT Posting Setup Ext." extends "VAT Posting Setup"
{
    layout
    {
        addafter("Tax Category")
        {
            field("DVR Transaction Code"; "DVR Transaction Code")
            {

            }
        }
    }
}