page 50012 "Interface Setup List"

//  RHE-TNA 14-06-2021 BDS-5337
//  - New Page

//  RHE-TNA 02-02-2022 BDS-5585
//  - Added actions

{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Interface Setup";
    Editable = false;
    CardPageId = 50000;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    StyleExpr = StyleVar;
                }
                field(Description; Description)
                {
                    StyleExpr = StyleVar;
                }
                field(Active; Active)
                {
                    StyleExpr = StyleVar;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Condition & Lock Code Setup")
            {
                ToolTip = 'Setup relationships between Locations and WMS Condition & Lock Codes.';
                Image = Change;
                RunObject = page "WMS Inventory Location Setup";
                RunPageLink = "Interface Setup Entry No." = field ("Entry No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleVar := '';
        if Active then
            StyleVar := 'Favorable';
    end;

    //Global variables
    var
        StyleVar: Text;
}