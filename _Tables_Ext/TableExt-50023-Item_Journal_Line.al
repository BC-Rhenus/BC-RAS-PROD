tableextension 50023 "Item Journal Line Ext." extends "Item Journal Line"

//RHE-TNA 06-05-2020..18-05-2020 BDS-4134
//  - New Table Ext.

//  RHE-TNA 21-07-2020 BDS-4323
//  - Added field 50000 - HideDialog

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

{
    fields
    {
        //RHE-TNA 21-07-2020 BDS-4323 BEGIN
        field(50000; HideDialog; Boolean)
        {

        }
        //RHE-TNA 21-07-2020 BDS-4323 END
    }

    procedure CheckReasonCode(var Rec: Record "Item Journal Line")
    var
        ItemJnlLine: Record "Item Journal Line";
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Reason Code must have a value, Line No.: %1, Item No.: %2.';
        ErrorText001: Label 'Reason Code must have a value, Line No.: %1, Item No.: %2.';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        ItemJnlLine.SetFilter("Entry Type", '%1|%2|%3', ItemJnlLine."Entry Type"::"Negative Adjmt.", ItemJnlLine."Entry Type"::"Positive Adjmt.", ItemJnlLine."Entry Type"::Transfer);
        ItemJnlLine.SetRange("Reason Code", '');
        if ItemJnlLine.FindFirst() then
            Error(ErrorText001, ItemJnlLine."Line No.", ItemJnlLine."Item No.");
    end;
}