tableextension 50015 "Location Ext." extends Location

//  RHE-TNA 12-01-2022 BDS-5585
//  - Added field 50001 - WMS Interface Setup Entry No.
//  - Added field 50002 - WMS Interface Setup Entry

{
    fields
    {
        field(50000; "Auto. Post Transfer Receipt"; Boolean)
        {
            trigger OnValidate()
            begin
                if (Rec."Auto. Post Transfer Receipt") and ((Rec."Require Receive") or (Rec."Require Put-away")) then
                    Error('You cannot set this field to true if "Require Receive" and/or "Require Put-away" is/are set to true.');
            end;
        }
        field(50001; "WMS Interface Setup Entry No."; Integer)
        {
            TableRelation = "Interface Setup";
        }
        field(50002; "WMS Interface Setup Entry"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("Interface Setup".Description where ("Entry No." = field ("WMS Interface Setup Entry No.")));
            Editable = false;
        }
    }
}