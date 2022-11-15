tableextension 50017 "Purch. & Payables Setup Ext." extends "Purchases & Payables Setup"
{
    fields
    {
        field(50000; AutoPostWhseReceipt; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allow Auto. Posting Whse. Receipt.';
        }
    }
}