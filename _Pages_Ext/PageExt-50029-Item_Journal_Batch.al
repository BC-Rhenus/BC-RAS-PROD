pageextension 50029 "Item Journal Batch Ext." extends "Item Journal Batches"

//  RHE-TNA 29-07-2020 BDS-4323
//  - Mew extension

{
    layout
    {
        addafter("Reason Code")
        {
            field("Use for WMS Inventory Adj."; "Use for WMS Inventory Adj.")
            {

            }
            field("Use for WMS Inventory Reclass."; "Use for WMS Inventory Reclass.")
            {

            }
        }
    }
}