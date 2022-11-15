tableextension 50025 "Transfer Line Ext." extends "Transfer Line"

//  RHE-TNA 10-06-2021 BDS-5385
//  - New extension

{
    fields
    {
        field(50000; "Unit Price"; Decimal)
        {
            trigger OnValidate()
            begin
                if Status <> Status::Open then
                    Error('Status must be equal to "Open" in Transfer Header: No. = ' + "Document No." + '. current value is "' + format(Status) + '".');
                Validate("Line Amount", Quantity * "Unit Price");
            end;
        }
        field(50001; "Line Amount"; Decimal)
        {
            Editable = false;
        }
    }
}