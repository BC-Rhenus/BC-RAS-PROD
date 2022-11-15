tableextension 50000 "Sales & Receivables Setup Ext." extends "Sales & Receivables Setup"

//  RHE-TNA 21-05-2021 BDS-5323
//  - Added field 50008

//  RHE-TNA 03-03-2022 BDS-5564
//  - Added field 50009

//  RHE-TNA 19-05-2022 BDS-6111
//  - Added field 50010

{
    fields
    {
        field(50000; AllowInvPosting; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allow Batch Invoice Posting from Shipment.';
        }
        field(50001; AutoPostWhseShipment; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allow Auto. Posting Whse. Shipment.';
        }
        field(50002; "PDF S. Order Conf. Directory"; text[150])
        {
            DataClassification = ToBeClassified;
            Caption = 'PDF Sales Order Confirmation Directory';
        }
        field(50003; "PDF S. Invoice Directory"; text[150])
        {
            DataClassification = ToBeClassified;
            Caption = 'PDF Sales Invoice Directory';
        }
        field(50004; "PDF S. Prep. Invoice Directory"; text[150])
        {
            DataClassification = ToBeClassified;
            Caption = 'PDF Sales Prepayment Invoice Directory';
        }
        field(50005; "PDF S. Proforma Directory"; text[150])
        {
            DataClassification = ToBeClassified;
            Caption = 'PDF Sales Proforma Invoice Directory';
        }
        field(50006; "PDF S. Credit Memo Directory"; text[150])
        {
            DataClassification = ToBeClassified;
            Caption = 'PDF Sales Credit Memo Directory';
        }
        field(50007; "PDF S. Customs Directory"; text[150])
        {
            DataClassification = ToBeClassified;
            Caption = 'PDF Sales Customs Invoice Directory';
        }
        //RHE-TNA 21-05-2021 BDS-5323 BEGIN
        field(50008; AllowInvPostingGL; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allow Batch Invoice Posting from Shipment incl. G/L Account';
        }
        //RHE-TNA 21-05-2021 BDS-5323 END
        field(50009; AllocationMandatory; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Order Allocation Mandatory';
        }
        field(50010; "Order Item Check"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Item in Assortment/Exception List Not Allowed","Item in Assortment/Exception List Allowed";
        }
    }

    //Global Variables
    var
}