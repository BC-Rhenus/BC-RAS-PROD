pageextension 50040 "Posted Assembly Orders Ext." extends "Posted Assembly Orders"
{
    layout
    {
        addafter("Unit Cost")
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