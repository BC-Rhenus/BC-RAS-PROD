pageextension 50005 "Whse. Receipt Extensions" extends "Warehouse Receipt"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Exported to WMS"; "Exported to WMS")
            {

            }
            field("Received in WMS"; "Received in WMS")
            {

            }
            field("Received Completely"; "Received Completely")
            {

            }
            field("Auto. Posting Error"; "Auto. Posting Error")
            {
                Editable = false;
            }
            field("Auto. Posting Error Text"; "Auto. Posting Error Text")
            {
                Editable = false;
            }
        }
    }

    actions
    {
        addafter("F&unctions")
        {
            group(Process)
            {
                action("Send to WMS")
                {
                    Image = Change;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ExportToWMS: Report "Export Whse. Receipt to WMS";
                        WhseReceiptHdr: Record "Warehouse Receipt Header";
                    begin
                        WhseReceiptHdr.SetRange("No.", "No.");
                        ExportToWMS.SetTableView(WhseReceiptHdr);
                        ExportToWMS.RunModal();
                    end;
                }
            }
        }
    }

    //Global variables
    var
}