tableextension 50009 "Assembly BOM Component Ext." extends "BOM Component"

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

{
    fields
    {
        field(50000; "Basis for BOM Item Tracking"; Boolean)
        {
            trigger OnValidate()
            var
                Component: Record "BOM Component";
                ParentItem: Record Item;
                ItemTrackingCode: Record "Item Tracking Code";
                //RHE-TNA 21-01-2022 BDS-6037 BEGIN
                /*
                ErrorText001: TextConst
                    ENU = 'You can only set this value if the Parent Item, Item ';
                ErrorText002: TextConst
                    ENU = ', is setup with Item Tracking.';
                */
                ErrorText001: Label 'You can only set this value if the Parent Item, Item ';
                ErrorText002: Label ', is setup with Item Tracking.';
                //RHE-TNA 21-01-2022 BDS-6037 END
            begin
                if Rec."Basis for BOM Item Tracking" = true then begin
                    if Rec.Type <> Rec.Type::Item then
                        Error('You can only set this value for line with Type = Item.');
                    ParentItem.SetRange("No.", Rec."Parent Item No.");
                    if ParentItem.FindFirst() then begin
                        if ParentItem."Item Tracking Code" <> '' then begin
                            if ItemTrackingCode.Get(ParentItem."Item Tracking Code") then begin
                                if not ((ItemTrackingCode."Lot Sales Outbound Tracking") or (ItemTrackingCode."SN Sales Outbound Tracking")) then
                                    Error(ErrorText001 + Rec."Parent Item No." + ErrorText002);
                            end else
                                Error(ErrorText001 + Rec."Parent Item No." + ErrorText002);
                        end else
                            Error(ErrorText001 + Rec."Parent Item No." + ErrorText002);
                    end else
                        Error('Item ' + Rec."Parent Item No." + ' (Parent Item) does not exist.');
                end;
            end;
        }
        field(50001; "Exclude in Ass. Order Creation"; Boolean)
        {

        }
    }
}