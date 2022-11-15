pageextension 50006 "Whse. Shipment Extensions" extends "Warehouse Shipment"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Exported to WMS"; "Exported to WMS")
            {
                Editable = false;
            }
            field("Shipped in WMS"; "Shipped in WMS")
            {
                Editable = false;
            }
            field("Shipped Completely"; "Shipped Completely")
            {
                Editable = false;
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
                        ExportToWMS: Report "Export WMS Whse. Shipment";
                        WhseShipmentHdr: Record "Warehouse Shipment Header";
                    begin
                        WhseShipmentHdr.SetRange("No.", "No.");
                        ExportToWMS.SetTableView(WhseShipmentHdr);
                        ExportToWMS.RunModal();
                    end;
                }
            }
        }
        addafter("Post and &Print")
        {
            action("Batch Post")
            {
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    WhseShipmentHdr: Record "Warehouse Shipment Header";
                    BatchPost: report "Whse. Shipment Batch Post";
                begin
                    WhseShipmentHdr.SetRange("No.", "No.");
                    BatchPost.SetTableView(WhseShipmentHdr);
                    BatchPost.RunModal();
                end;
            }
        }
    }

    //Global Variables
    var
}