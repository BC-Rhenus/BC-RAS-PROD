pageextension 50022 "Ship-to Address Etx." extends "Ship-to Address"

//  RHE-TNA 19-05-2022 BDS-6111
//  - Added field("Assortment/Exception Group")

{
    layout
    {
        addafter(GLN)
        {
            field("EDI Identifier"; "EDI Identifier")
            {
                ToolTip = 'Set how the Ship-to Address is identified in EDI messages (if GLN is not used in EDI messages).';
            }
        }
        addafter("Shipping Agent Service Code")
        {
            field("Assortment/Exception Group"; "Assortment/Exception Group")
            {
                LookupPageId = "Assortment Group";
            }
        }
    }
}