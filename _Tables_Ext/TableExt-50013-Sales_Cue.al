tableextension 50013 "Sales Cue Ext." extends "Sales Cue"

//RHE-TNA 09-06-2020 BDS-4220
//  - Added field 50003

//  RHE-TNA 22-07-2020..01-12-2020 BDS-4323
//  - Added fields 50004 and 50005

//  RHE-TNA 23-11-2020 BDS-4705
//  - Added field 50006

//  RHE-TNA 28-04-2021 BDS-5302
//  - Modified field 50005

{
    fields
    {
        field(50000; "WMS Files to Process"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count ("WMS Import Header" where (Process = filter (true)));
        }
        field(50001; "WMS Files in Error"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count ("WMS Import Header" where (Error = filter (true)));
        }
        field(50002; "Shipped Not Invoiced"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count ("Sales Header" where ("Shipped Not Invoiced" = filter (true)));
        }
        //RHE-TNA 09-06-2020 BDS-4220 BEGIN
        field(50003; "Whse. Shipment Shipped in WMS"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count ("Warehouse Shipment Header" where ("Shipped in WMS" = filter (true)));
        }
        //RHE-TNA 09-06-2020 BDS-4220 END
        //RHE-TNA 22-07-2020..01-12-2020 BDS-4323 BEGIN
        field(50004; "WMS Inv. Updates to Approve"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count ("WMS Inventory Reconciliation" where (Approved = filter (false), Disapproved = filter (false)));
        }
        field(50005; "WMS Inv. Updates in Error"; Integer)
        {
            FieldClass = FlowField;
            //RHE-TNA 28-04-2021 BDS-5302 BEGIN
            //CalcFormula = count ("WMS Inventory Reconciliation" where (Error = filter (true)));
            CalcFormula = count ("WMS Inventory Reconciliation" where (Error = filter (true), Disapproved = filter (false)));
            //RHE-TNA 28-04-2021 BDS-5302 END
        }
        //RHE-TNA 22-07-2020..01-12-2020 BDS-4323 END
        //RHE-TNA 23-11-2020 BDS-4705 BEGIN
        field(50006; "Interface Files in Error"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count ("Interface Log" where (Error = filter (true), "Acknowledged By User" = filter (' ')));
        }
        //RHE-TNA 23-11-2020 BDS-4705 END
    }
}