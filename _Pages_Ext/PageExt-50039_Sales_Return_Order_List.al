pageextension 50039 "Sales Return Order List Ext." extends "Sales Return Order List"
{
    layout
    {
        addafter("Document Date")
        {
            field(Invoice; Invoice)
            {

            }
        }
    }
}