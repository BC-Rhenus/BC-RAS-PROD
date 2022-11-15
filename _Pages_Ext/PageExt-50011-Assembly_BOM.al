pageextension 50011 "Assembly BOM Ext." extends "Assembly BOM"
{
    layout
    {
        addafter("Unit of Measure Code")
        {
            field("Basis for BOM Item Tracking"; "Basis for BOM Item Tracking")
            {
                ToolTip = 'On processing WMS Import Records, with Type = Shipment, this field is used to determine which serial or lot numbers are to be added to the Warehouse Shipment.';
            }
            field("Exclude in Ass. Order Creation"; "Exclude in Ass. Order Creation")
            {

            }
        }
    }
}