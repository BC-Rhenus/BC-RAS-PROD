pageextension 50009 "Sales Return Order Extensions" extends "Sales Return Order"
{
    layout
    {
        addafter(Status)
        {
            field(Substatus; Substatus)
            {

            }
            field("Customer Comment Text"; "Customer Comment Text")
            {

            }
        }
        addafter(SalesLines)
        {
            part(Comments; "Sales Order Comment ListPart")
            {
                Enabled = "No." <> '';
                SubPageLink = "Document Type" = field ("Document Type"), "No." = field ("No.");
            }
        }
    }
}