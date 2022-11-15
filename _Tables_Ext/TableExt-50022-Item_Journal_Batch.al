tableextension 50022 "Item Journal Batch Ext." extends "Item Journal Batch"

//  RHE-TNA 21-07-2020 BDS-4323
//  - Mew extension

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

{
    fields
    {
        field(50000; "Use for WMS Inventory Reclass."; Boolean)
        {
            trigger OnValidate()
            var
                ItemJnlBatch: Record "Item Journal Batch";
                //RHE-TNA 21-01-2022 BDS-6037 BEGIN
                //ErrorText001: TextConst
                //    ENU = 'You can only set 1 Batch with this value';
                ErrorText001: Label 'You can only set 1 Batch with this value';
                //RHE-TNA 21-01-2022 BDS-6037 END
            begin
                if Rec."Use for WMS Inventory Reclass." then begin
                    ItemJnlBatch.SetRange("Use for WMS Inventory Reclass.", true);
                    if ItemJnlBatch.FindFirst() then
                        Error(ErrorText001);
                end;
            end;
        }
        field(50001; "Use for WMS Inventory Adj."; Boolean)
        {
            trigger OnValidate()
            var
                ItemJnlBatch: Record "Item Journal Batch";
                //RHE-TNA 21-01-2022 BDS-6037 BEGIN
                //ErrorText001: TextConst
                //    ENU = 'You can only set 1 Batch with this value';
                ErrorText001: Label 'You can only set 1 Batch with this value';
                //RHE-TNA 21-01-2022 BDS-6037 END
            begin
                if Rec."Use for WMS Inventory Adj." then begin
                    ItemJnlBatch.SetRange("Use for WMS Inventory Adj.", true);
                    if ItemJnlBatch.FindFirst() then
                        Error(ErrorText001);
                end;
            end;
        }
    }
}