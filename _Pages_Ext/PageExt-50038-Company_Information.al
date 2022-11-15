pageextension 50038 "Company Information Ext." extends "Company Information"
{
    layout
    {
        addafter("VAT Registration No.")
        {
            field("Customs Permit No."; "Customs Permit No.")
            {
                ApplicationArea = All;
            }
            field("Customs Permit Date"; "Customs Permit Date")
            {
                ApplicationArea = All;
            }
        }
    }
}