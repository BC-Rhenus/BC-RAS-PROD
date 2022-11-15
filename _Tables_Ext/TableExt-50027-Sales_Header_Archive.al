tableextension 50027 "S.-Hdr Arch. Ext." extends "Sales Header Archive"

//  RHE-TNA 16-11-2021 BDS-5676
//  - New extension

{
    fields
    {
        field(50008; "EDI Status"; Option)
        {
            OptionMembers = " ","To Send","Sent";
        }
        field(50009; "Last EDI Export Date/Time"; DateTime)
        {
            Editable = false;
        }
        field(50090; "Interface Setup Entry No."; Integer)
        {

        }
        field(50091; "Order Deleted/Invoiced"; Boolean)
        {

        }
    }
}