pageextension 50015 "SO Processor Activities Ext." extends "SO Processor Activities"

//RHE-TNA 09-06-2020 BDS-4220
//  - Added field "Whse. Shipment Shipped in WMS"

//  RHE-TNA 22-07-2020 BDS-4323
//  - Added cuegroup "WMS Inventory"
//  - Added field "WMS Inv. Updates to Approve"
//  - Added field "WMS Inv. Updates in Error"

//  RHE-TNA 23-11-2020 BDS-4705
//  - Added cuegroup "Customer Interface Log"
//  - Added field "Interface Files in Error"

{
    layout
    {
        addafter(Returns)
        {
            cuegroup("WMS Interface")
            {
                field("WMS Files to Process"; "WMS Files to Process")
                {
                    DrillDownPageId = "WMS Import Record List";
                }
                field("WMS Files in Error"; "WMS Files in Error")
                {
                    DrillDownPageId = "WMS Import Record List";
                }
            }
            cuegroup("Sales Orders Shipped Not Invoiced")
            {
                field("Shipped Not Invoiced"; "Shipped Not Invoiced")
                {
                    DrillDownPageId = "Sales Order List";
                }
                //RHE-TNA 09-06-2020 BDS-4220 BEGIN
                field("Whse. Shipment Shipped in WMS"; "Whse. Shipment Shipped in WMS")
                {
                    DrillDownPageId = "Warehouse Shipment List";
                }
                //RHE-TNA 09-06-2020 BDS-4220 END
            }
            //RHE-TNA 22-07-2020 BDS-4323 BEGIN
            cuegroup("WMS Inventory")
            {
                field("WMS Inv. Updates to Approve"; "WMS Inv. Updates to Approve")
                {
                    DrillDownPageId = "WMS Inventory Reconciliation";
                }
                field("WMS Inv. Updates in Error"; "WMS Inv. Updates in Error")
                {
                    DrillDownPageId = "WMS Inventory Reconciliation";
                }
            }
            //RHE-TNA 22-07-2020 BDS-4323 END
            //RHE-TNA 23-11-2020 BDS-4705 BEGIN
            cuegroup("Customer Interface Log")
            {
                field("Interface Files in Error"; "Interface Files in Error")
                {
                    DrillDownPageId = "Interface Log";
                }
            }
            //RHE-TNA 23-11-2020 BDS-4705 END
        }
    }
}