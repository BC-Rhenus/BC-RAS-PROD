tableextension 50012 "Customer Ext." extends Customer

//  RHE-TNA 06-04-2020 BDS-4033
//  - Added field 50004

//  RHE-TNA 16-11-2020 BDS-4551
//  - Added field 50005

//  RHE-TNA 26-11-2021 BDS-5891
//  - Added fields 50006 and 50007

//  RHE-TNA 22-12-2021 PM-1328
//  - Added field 50008

//  RHE-TNA 19-05-2022 BDS-6111
//  - Added field 50009

{
    fields
    {
        field(50000; "WMS Freight Charges"; Option)
        {
            OptionMembers = " ",Prepaid,Collect,"3rd Party";
            trigger OnValidate()
            begin
                if "WMS Freight Charges" = "WMS Freight Charges"::" " then
                    Validate("WMS Hub Vat Number", '');
            end;
        }
        field(50001; "WMS Hub Vat Number"; Text[20])
        {
            trigger OnValidate()
            begin
                if ("WMS Freight Charges" = "WMS Freight Charges"::" ") and ("WMS Hub Vat Number" <> '') then
                    Error('Field "WMS Freight Charges" cannot be empty.');
            end;
        }
        field(50002; "EDI Identifier"; Code[50])
        {

        }
        field(50003; "Send EDI Invoice"; Boolean)
        {

        }
        field(50004; "Send SSCC info in EDI Invoice"; Boolean)
        {

        }
        field(50005; "Send Ship Ready Message"; Boolean)
        {

        }
        field(50006; "Invoice No. Series"; Code[20])
        {
            TableRelation = "No. Series";
            trigger OnValidate()
            begin
                if not Confirm('Are you sure you want to change the value for Invoice No. Series?') then
                    Error('Process canceled.');
            end;
        }
        field(50007; "Credit Memo No. Series"; Code[20])
        {
            TableRelation = "No. Series";
            trigger OnValidate()
            begin
                if not Confirm('Are you sure you want to change the value for Invoice No. Series?') then
                    Error('Process canceled.');
            end;
        }
        field(50008; "Customs Price Group"; Code[10])
        {
            TableRelation = "Customer Price Group";
        }
        field(50009; "Assortment/Exception Group"; Code[10])
        {
            TableRelation = "Rhenus Setup".Code where (Type = const ("Assortment/Exception Group"));
            trigger OnValidate()
            begin
                if not Confirm('Are you sure you want to change the value for Assortment/Exception Group?') then
                    Error('Process canceled.');
            end;
        }
    }
}