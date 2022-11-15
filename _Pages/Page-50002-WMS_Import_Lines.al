page 50002 "WMS Import Lines"

//  RHE-TNA 17-03-2020..26-05-2020 BDS-3866
//  - Added fields WMS Pallet Id and tag Id
//  - Added action Serial Numbers

//  RHE-TNA 13-05-2020..28-05-2020 BDS-4147
//  - Added field Assembly Parent Item --> 28-05-2020: Removed field due to not using Kitting functionality in WMS

//  RHE-TNA 02-04-2022 BDS-5977
//  - Renamed action("Serial Numbers") into action("Item Tracking Lines")
//  - Modified action("Item Tracking Lines")

{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "WMS Import Line";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Line No."; "Line No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Whse. Document No."; "Whse. Document No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Source No."; "Source No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Source Line No."; "Source Line No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Location Code"; "Location Code")
                {
                    StyleExpr = StyleVar;
                }
                field("Item No."; "Item No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Qty. Shipped / Received"; "Qty. Shipped / Received")
                {
                    DecimalPlaces = 0 : 5;
                    StyleExpr = StyleVar;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    StyleExpr = StyleVar;
                }
                field("Serial/Lot"; "Serial/Lot")
                {
                    StyleExpr = StyleVar;
                }
                field("Batch Id"; "Batch Id")
                {
                    StyleExpr = StyleVar;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    StyleExpr = StyleVar;
                }
                field("Assembly Line"; "Assembly Line")
                {
                    StyleExpr = StyleVar;
                }
                field("Assembly Order No."; "Assembly Order No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Assembly Line No."; "Assembly Line No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Assembly Item No."; "Assembly Item No.")
                {
                    StyleExpr = StyleVar;
                }
                field(Error; Error)
                {
                    StyleExpr = StyleVar;
                }
                field("Error Text"; "Error Text")
                {
                    StyleExpr = StyleVar;
                }
                //RHE-TNA 17-03-2020..14-05-2020 BDS-3866 BEGIN
                field("WMS Pallet Id"; "WMS Pallet Id")
                {
                    StyleExpr = StyleVar;
                }
                field("Tag Id"; "Tag Id")
                {
                    StyleExpr = StyleVar;
                }
                field("WMS Line Id"; "WMS Line Id")
                {

                }
                //RHE-TNA 17-03-2020..14-05-2020 BDS-3866 END
            }
        }
    }

    //RHE-TNA 17-03-2020..26-05-2020 BDS-3866 BEGIN
    actions
    {
        area(Processing)
        {
            action("Item Tracking Lines")
            {
                RunObject = page "WMS Serial Numbers";
                //RHE-TNA 02-04-2022 BDS-5977 BEGIN
                //RunPageLink = "WMS Import Entry No." = field ("Entry No."), "Item No." = field ("Item No.");
                //Image = SerialNo;
                RunPageLink = "WMS Import Entry No." = field ("Entry No."), "Item No." = field ("Item No."), "WMS Import Line No." = field ("Line No.");
                Image = ItemTrackingLines;
                //RHE-TNA 02-04-2022 BDS-5977 END
            }
        }
    }
    //RHE-TNA 17-03-2020..26-05-2020 BDS-3866 END

    trigger OnAfterGetRecord()
    begin
        StyleVar := '';
        if Error then
            StyleVar := 'Unfavorable';
    end;

    //Global variables
    var
        StyleVar: Text;
}