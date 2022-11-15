pageextension 50004 "Sales Order Line Extension" extends "Sales Order Subform"

//  RHE-TNA 22-12-2021 PM-1328
//  - Added field "Customs Price"

//  RHE-TNA 25-01-2022 BDS-6057
//  - Added procedure SetDefaultDescription()
//  - Added field "Default Description"

//  RHE-TNA 03-03-2022 BDS-5565
//  - Added field "Allocated Qty."
//  - Added field "Allocated Manually"

//  RHE-TNA 15-04-2022 BDS-6277
//  - Modified action("Allocate Inventory")

{
    layout
    {
        addafter("Qty. to Ship")
        {
            field("Qty. Sent to WMS"; "Qty. Sent to WMS")
            {

            }
            field("Obsolete Item"; "Obsolete Item")
            {

            }
        }
        addafter(Description)
        {
            field("Description 2"; "Description 2")
            {

            }
            field("Default Description"; SetDefaultDescription)
            {

            }
        }
        addafter("Line Discount %")
        {
            field("Customs Price"; "Customs Price")
            {

            }
        }
        addafter("VAT Prod. Posting Group")
        {
            field("Allocated Qty."; "Allocated Qty.")
            {
                DecimalPlaces = 0 : 5;
                Editable = false;
            }
            field("Allocated Manually"; "Allocated Manually")
            {
                Editable = false;
            }
        }
        modify(Type)
        {
            StyleExpr = StyleFav;
        }
        modify("No.")
        {
            StyleExpr = StyleFav;
        }
        modify(Description)
        {
            StyleExpr = StyleFav;
        }
    }

    actions
    {
        addafter("Select Nonstoc&k Items")
        {
            action("Allocate Inventory")
            {
                Image = Allocate;

                trigger OnAction()
                var
                    TempRec: Record "Sales Line" temporary;
                    SalesLine: Record "Sales Line";
                    Item: Record Item;
                begin
                    //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                    if Type <> Type::Item then
                        Error('You can only use this functionality for lines of Type = Item.');
                    Item.Get("No.");
                    if Item.Type <> Item.Type::Inventory then
                        Error('You can only use this functionality for Inventory Items (Item Type = Inventory).');
                    //RHE-TNA 15-04-2022 BDS-6277 END
                    TempRec.Init();
                    TempRec.Copy(Rec);
                    TempRec.Insert();
                    if Page.RunModal(Page::"Allocate Sales Line", TempRec) = Action::LookupOK then begin
                        SalesLine.Get("Document Type", "Document No.", "Line No.");
                        SalesLine.Validate("Allocated Qty.", TempRec."Allocated Qty.");
                        if TempRec."Allocated Qty." > 0 then
                            SalesLine.Validate("Allocated Manually", true)
                        else
                            SalesLine.Validate("Allocated Manually", false);
                        SalesLine.Modify();
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleFav := 'Standard';
        if Rec."Obsolete Item" then
            StyleFav := 'Unfavorable';
    end;

    procedure SetDefaultDescription(): Text[100]
    var
        Item: Record Item;
        GLAccount: Record "G/L Account";
    begin
        case Type of
            Type::Item:
                begin
                    if Item.Get("No.") then
                        exit(Item.Description);
                end;
            Type::"G/L Account":
                begin
                    if GLAccount.Get("No.") then
                        exit(GLAccount.Name);
                end;
        end;
    end;

    //Global Variables
    var
        StyleFav: Code[20];
}