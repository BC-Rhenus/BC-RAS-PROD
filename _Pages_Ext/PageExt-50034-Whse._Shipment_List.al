pageextension 50034 "Whse. Shipment List Ext." extends "Warehouse Shipment List"
{
    layout
    {
        modify("No.")
        {
            StyleExpr = StyleFav;
        }
        modify("Location Code")
        {
            StyleExpr = StyleFav;
        }
        modify(Status)
        {
            StyleExpr = StyleFav;
        }
        modify("Posting Date")
        {
            StyleExpr = StyleFav;
        }
        modify("Shipment Date")
        {
            StyleExpr = StyleFav;
        }
        modify("Shipping Agent Code")
        {
            StyleExpr = StyleFav;
        }
        modify("Shipping Agent Service Code")
        {
            StyleExpr = StyleFav;
        }
        modify("Shipment Method Code")
        {
            StyleExpr = StyleFav;
        }

        addafter(Status)
        {
            field("Source Document"; "Source Document")
            {
                StyleExpr = StyleFav;
            }
            field("Source No."; "Source No.")
            {
                StyleExpr = StyleFav;
            }
            field("Exported to WMS"; "Exported to WMS")
            {

            }
            field("Shipped in WMS"; "Shipped in WMS")
            {

            }
            field("Shipped Completely"; "Shipped Completely")
            {

            }
            field("Auto. Posting Error"; "Auto. Posting Error")
            {

            }
            field("Auto. Posting Error Text"; "Auto. Posting Error Text")
            {
                StyleExpr = StyleFav;
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
                        WhseShipmentHdr: Record "Warehouse Shipment Header";
                        ExportToWMS: Report "Export WMS Whse. Shipment";
                    begin
                        WhseShipmentHdr.SetRange("No.", "No.");
                        ExportToWMS.SetTableView(WhseShipmentHdr);
                        ExportToWMS.RunModal();
                    end;
                }
            }

            group(Posting)
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
    }

    trigger OnAfterGetRecord()
    begin
        StyleFav := 'Standard';
        if (Rec."Exported to WMS") and (Rec."Shipped in WMS") and (Rec."Shipped Completely") then
            StyleFav := 'Favorable';
        if Rec."Auto. Posting Error" then
            StyleFav := 'Unfavorable';
    end;

    //Global Variables
    var
        StyleFav: Code[20];

}