page 50007 "WMS Serial Numbers"

//  RHE-TNA 17-03-2020..14-05-2020 BDS-3866
//  - New Page

//  RHE-TNA 22-03-2022 BDS-5977
//  - Added Caption
//  - Added field "Lot No."
//  - Added field "Expiration Date"
//  - Added field Quantity
//  - Added field "Source Line No."

{
    PageType = List;
    UsageCategory = None;
    SourceTable = "WMS Import Serial Number";
    Caption = 'WMS Import Item Tracking Lines';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("WMS Import Entry No."; "WMS Import Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                }
                field("Lot No."; "Lot No.")
                {

                }
                field("Expiration Date"; "Expiration Date")
                {

                }
                field(Quantity; Quantity)
                {
                    DecimalPlaces = 0 : 5;
                }
                field("Pallet Id"; "Pallet Id")
                {
                    ApplicationArea = All;
                }
                field("Tag Id"; "Tag Id")
                {
                    ApplicationArea = All;
                }
                field(Processed; Processed)
                {
                    ApplicationArea = All;
                }
                field("WMS Import Line No."; "WMS Import Line No.")
                {

                }
            }
        }
    }
}