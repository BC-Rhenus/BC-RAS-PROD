tableextension 50026 "Transfer Hdr Ext." extends "Transfer Header"

//  RHE-TNA 11-06-2021 BDS-5385
//  - New extension

{
    fields
    {
        field(50000; "Currency Code"; code[10])
        {
            TableRelation = Currency;
            trigger OnValidate()
            begin
                if Status <> Status::Open then
                    Error('Status must be equal to "Open" in Transfer Header: No. = ' + "No." + '. current value is "' + format(Status) + '".');
            end;
        }
    }
}