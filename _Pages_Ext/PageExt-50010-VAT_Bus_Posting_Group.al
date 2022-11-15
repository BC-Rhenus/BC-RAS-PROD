pageextension 50010 "VAT Bus. Posting Group Ext" extends "VAT Business Posting Groups"
{
    layout
    {
        addafter(Description)
        {
            field("Order Confirmation Totals Text"; "Order Confirmation Totals Text")
            {
                ToolTip = 'This text is printed on the Order Confirmation at the totals segment.';
            }
            field("Order Confirmation Footer Text"; "Order Confirmation Footer Text")
            {
                ToolTip = 'This text is printed on the Order Confirmation at the footer segment.';
            }
        }
    }

    var
}