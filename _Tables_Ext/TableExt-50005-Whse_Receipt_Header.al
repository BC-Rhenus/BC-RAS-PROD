tableextension 50005 "Whse. Receipt Hdr. Extension" extends "Warehouse Receipt Header"
{
    fields
    {
        field(50000; "Exported to WMS"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Source Document"; Option)
        {
            OptionMembers = ,"Sales Order",,,"Sales Return order","Purchase Order",,,"Purchase Return Order","Inbound Transfer";
            OptionCaption = ' ,Sales Order,,,Sales Return order,Purchase Order,,,Purchase Return Order,Inbound Transfer';
            FieldClass = FlowField;
            CalcFormula = lookup ("Warehouse Receipt Line"."Source Document" where ("No." = field ("No.")));
            Editable = false;
        }
        field(50002; "Source No."; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("Warehouse Receipt Line"."Source No." where ("No." = field ("No.")));
            Editable = false;
        }
        field(50003; "Received in WMS"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "Received Completely"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50005; "Auto. Posting Error"; Boolean)
        {

        }
        field(50006; "Auto. Posting Error Text"; Text[250])
        {

        }
    }
}