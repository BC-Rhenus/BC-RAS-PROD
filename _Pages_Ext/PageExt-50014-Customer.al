pageextension 50014 "Customer Ext." extends "Customer Card"

//  RHE-TNA 06-04-2020 BDS-4033
//  - Added field "Send SSCC info in EDI Invoice"

//  RHE-TNA 16-11-2020 BDS-4551
//  - Added field "Send Ship Ready Message"

//  RHE-TNA 26-11-2021 BDS-5891
//  - Added field "Invoice No. Series"
//  - Added field "Credit Memo No. Series"

//  RHE-TNA 22-12-2021 PM-1328
//  - Added field "Customs Price Group"

//  RHE-TNA 19-05-2022 BDS-6111
//  - Added field "Assortment Group"

{
    layout
    {
        addafter(Shipping)
        {
            group(WMS)
            {
                field("WMS Freight Charges"; "WMS Freight Charges")
                {

                }
                field("WMS Hub Vat Number"; "WMS Hub Vat Number")
                {
                    ToolTip = 'This field can only be entered if field "WMS Freight Charges" has a value.';
                }
            }
        }
        addafter(GLN)
        {
            field("EDI Identifier"; "EDI Identifier")
            {
                ToolTip = 'Set how the Customer is identified in EDI messages (if GLN is not used in EDI messages).';
            }
            field("Send EDI Invoice"; "Send EDI Invoice")
            {

            }
            field("Send SSCC info in EDI Invoice"; "Send SSCC info in EDI Invoice")
            {
                Editable = "Send EDI Invoice";
            }
            field("Send Ship Ready Message"; "Send Ship Ready Message")
            {

            }
            field("Invoice No. Series"; "Invoice No. Series")
            {
                ToolTip = 'The no. series set in this field will overwrite the standard no. series used as setup in Sales & Marketing Setup.';
            }
            field("Credit Memo No. Series"; "Credit Memo No. Series")
            {
                ToolTip = 'The no. series set in this field will overwrite the standard no. series used as setup in Sales & Marketing Setup.';
            }
        }
        addafter("Customer Price Group")
        {
            field("Customs Price Group"; "Customs Price Group")
            {

            }
            field("Assortment/Exception Group"; "Assortment/Exception Group")
            {
                LookupPageId = "Assortment Group";
            }
        }
    }
}