page 50014 "Assortment Group"

//  RHE-TNA 19-05-2022 BDS-6111
//  - New Page

{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Rhenus Setup";
    SourceTableView = where (Type = const ("Assortment/Exception Group"));

    layout
    {
        area(Content)
        {
            repeater(group)
            {
                field(Code; Code)
                {

                }
                field(Description; Description)
                {

                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Assortment)
            {
                RunObject = page Assortment;
                RunPageLink = "Assortment Group" = field (Code);
                Image = ItemGroup;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Type := Type::"Assortment/Exception Group";
    end;
}