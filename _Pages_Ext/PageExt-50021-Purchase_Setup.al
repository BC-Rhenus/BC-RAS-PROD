pageextension 50021 "Purch. & Payables Setup Ext." extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Default Accounts")
        {
            group("Custom functionality")
            {
                group(Posting)
                {
                    field(AutoPostWhseReceipt; AutoPostWhseReceipt)
                    {
                        ToolTip = 'Allow Whse. Receipt to be posted at processing WMS Receipts.';
                    }
                }
            }
        }
    }
}