pageextension 50033 "Warehouse Receipts Extension" extends "Warehouse Receipts"
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
        modify("Posting Date")
        {
            StyleExpr = StyleFav;
        }
        modify("Assigned User ID")
        {
            StyleExpr = StyleFav;
        }
        modify("Assignment Date")
        {
            StyleExpr = StyleFav;
        }
        modify("Bin Code")
        {
            StyleExpr = StyleFav;
        }
        modify("Document Status")
        {
            StyleExpr = StyleFav;
        }
        modify("Sorting Method")
        {
            StyleExpr = StyleFav;
        }
        modify("Zone Code")
        {
            StyleExpr = StyleFav;
        }

        addafter("Assignment Date")
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
                StyleExpr = StyleFav;
            }
            field("Received in WMS"; "Received in WMS")
            {
                StyleExpr = StyleFav;
            }
            field("Received Completely"; "Received Completely")
            {
                StyleExpr = StyleFav;
            }
            field("Auto. Posting Error"; "Auto. Posting Error")
            {
                StyleExpr = StyleFav;
            }
            field("Auto. Posting Error Text"; "Auto. Posting Error Text")
            {
                StyleExpr = StyleFav;
            }
        }
    }

    actions
    {
        addafter("&Receipt")
        {
            group(WMS)
            {
                action("Send to WMS")
                {
                    Image = Change;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        WhseReceiptHdr: Record "Warehouse Receipt Header";
                        ExportToWMS: Report "Export Whse. Receipt to WMS";
                    begin
                        WhseReceiptHdr.SetRange("No.", "No.");
                        ExportToWMS.SetTableView(WhseReceiptHdr);
                        ExportToWMS.RunModal();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleFav := 'Standard';
        if (Rec."Exported to WMS") and (Rec."Received in WMS") and (Rec."Received Completely") then
            StyleFav := 'Favorable';
        if Rec."Auto. Posting Error" then
            StyleFav := 'Unfavorable';
    end;

    //Global Variables
    var
        StyleFav: Code[20];
}