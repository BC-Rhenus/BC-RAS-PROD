pageextension 50027 "Item Journal Ext." extends "Item Journal"

//RHE-TNA 06-05-2020 BDS-4134
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