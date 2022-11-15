pageextension 50000 "Sales & Receivables Setup Ext." extends "Sales & Receivables Setup"

//  RHE-TNA 21-05-2021 BDS-5323
//  - Added field AllowInvPostingGL

//  RHE-TNA 03-03-2022 BDS-5564
//  - Added group Release
//  - Added field AllocationMandatory

//  RHE-TNA 19-05-2022 BDS-6111
//  - Change group Release into Order
//  - Added field Order Item Check

{
    layout
    {
        addafter("Dynamics 365 for Sales")
        {
            group("Custom functionality")
            {
                group(Posting)
                {
                    field(AutoPostWhseShipment; AutoPostWhseShipment)
                    {
                        ToolTip = 'Allow Whse. Shipment to be posted at processing WMS Shipments.';
                    }
                    field(AllowInvPosting; AllowInvPosting)
                    {
                        ToolTip = 'Allow Invoice/Credit Memo to be posted automatically with the shipment.';
                    }
                    field(AllowInvPostingGL; AllowInvPostingGL)
                    {
                        ToolTip = 'Allow Invoice/Credit Memo to be posted automatically with the shipment when a line of type G/L Account is present in the order.';
                        Editable = AllowInvPosting;
                    }
                }
                group(Order)
                {
                    field(AllocationMandatory; AllocationMandatory)
                    {
                        ToolTip = 'When an Order Line is created for type = Item, stock is automatically allocated. When changing order status to Released a check is done if the Order is completely allocated against stock .';
                    }
                    field("Order Item Check"; "Order Item Check")
                    {
                        ToolTip = 'When set to "Item in Exception List Allowed" a check will be done if the item entered in the Sales Order Line is setup in the Customer Assortment/Exception List. When set to "Item in Exception List Not Allowed" a check will be done if the item entered in the Sales Order Line is not setup in the Customer Assortment/Exception List.';
                    }
                }
                group(PDF)
                {
                    field("PDF S. Order Conf. Directory"; "PDF S. Order Conf. Directory")
                    {
                        ToolTip = 'Set the directory name where Business Central will save the PDF file when saving the Sales Order to PDF. Make sure to set full directory name and end with \.';
                    }
                    field("PDF S. Prep. Invoice Directory"; "PDF S. Prep. Invoice Directory")
                    {
                        ToolTip = 'Set the directory name where Business Central will save the PDF file when saving the Sales Prepayment Invoice to PDF. Make sure to set full directory name and end with \.';
                    }
                    field("PDF S. Proforma Directory"; "PDF S. Proforma Directory")
                    {
                        ToolTip = 'Set the directory name where Business Central will save the PDF file when saving the Sales Proforma Invoice to PDF. Make sure to set full directory name and end with \.';
                    }
                    field("PDF S. Customs Directory"; "PDF S. Customs Directory")
                    {
                        ToolTip = 'Set the directory name where Business Central will save the PDF file when saving the Sales Customs Invoice to PDF. Make sure to set full directory name and end with \.';
                    }
                    field("PDF S. Invoice Directory"; "PDF S. Invoice Directory")
                    {
                        ToolTip = 'Set the directory name where Business Central will save the PDF file when saving the Sales Invoice to PDF. Make sure to set full directory name and end with \.';
                    }
                    field("PDF S. Credit Memo Directory"; "PDF S. Credit Memo Directory")
                    {
                        ToolTip = 'Set the directory name where Business Central will save the PDF file when saving the Sales Credit Memo to PDF. Make sure to set full directory name and end with \.';
                    }
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    //Global Variables
    var
}