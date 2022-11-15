tableextension 50011 "Sales Comment Line Ext." extends "Sales Comment Line"
{
    fields
    {
        field(50000; "Created by"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
    }

    trigger OnInsert()
    begin
        Date := Today;
        "Created by" := UserId;
    end;
}