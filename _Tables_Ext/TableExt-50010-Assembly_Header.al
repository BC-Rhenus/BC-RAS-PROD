tableextension 50010 "Assembly Header Ext." extends "Assembly Header"
{
    fields
    {
        field(50000; "Sales Order No."; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("Assemble-to-Order Link"."Document No." where ("Assembly Document Type" = field ("Document Type"), "Assembly Document No." = field ("No."), Type = const (Sale)));
        }
    }
}