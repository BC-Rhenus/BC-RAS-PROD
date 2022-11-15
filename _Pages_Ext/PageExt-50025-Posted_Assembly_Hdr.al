pageextension 50025 "Posted Assembly Hdr. Ext." extends "Posted Assembly Order"
{
    layout
    {
        addafter("Assemble to Order")
        {
            field("Sales Order No."; "Sales Order No.")
            {
                Editable = false;
            }
            field("Customer Name"; "Customer Name")
            {
                Editable = false;
            }
        }
    }
}