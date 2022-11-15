pageextension 50028 "Item Reclass. Journal Ext." extends "Item Reclass. Journal"

//RHE-TNA 18-05-2020 BDS-4134
//  - New Page Ext.

{
    actions
    {
        modify(Post)
        {
            trigger OnBeforeAction()
            begin
                CheckReasonCode(Rec);
            end;
        }
        modify("Post and &Print")
        {
            trigger OnBeforeAction()
            begin
                CheckReasonCode(Rec);
            end;
        }
    }
}