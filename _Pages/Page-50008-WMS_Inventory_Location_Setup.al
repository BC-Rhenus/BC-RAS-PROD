page 50008 "WMS Inventory Location Setup"

//  RHE-TNA 21-07-2020 BDS-4323
//  - New Page

//  RHE-TNA 31-12-2020 BDS-4324
//  - Added field "Reason Code Inv. Level"

//  RHE-TNA 02-02-2022 BDS-5585
//  - Deleted ApplicationArea (ApplicationArea = All;)
//  - Changed UsageCategory from Administration into None

{
    PageType = List;
    UsageCategory = None;
    SourceTable = "WMS Inventory Location Setup";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Interface Setup Entry No."; "Interface Setup Entry No.")
                {

                }
                field(Type; Type)
                {

                }
                field(Code; Code)
                {

                }
                field("Location Code"; "Location Code")
                {

                }
                field("Reason Code Reclass."; "Reason Code Reclass.")
                {

                }
                //RHE-TNA 31-12-2020 BDS-4324 BEGIN
                field("Reason Code Inv. Level"; "Reason Code Inv. Level")
                {
                    Editable = InvLevelReasonEditable;
                }
                //RHE-TNA 31-12-2020 BDS-4324 END
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        if Type = Type::Warehouse then
            InvLevelReasonEditable := true
        else
            InvLevelReasonEditable := false;
    end;

    //Global variables
    var
        InvLevelReasonEditable: Boolean;
}