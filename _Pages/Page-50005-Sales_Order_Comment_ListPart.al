page 50005 "Sales Order Comment ListPart"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "Sales Comment Line";
    SourceTableView = where ("Document Line No." = filter (0));
    DelayedInsert = true;
    MultipleNewLines = true;
    AutoSplitKey = true;
    LinksAllowed = false;
    Caption = 'Comments';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Date; Date)
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                }
                field("Created by"; "Created by")
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                }
            }
        }
    }

    var
        myInt: Integer;
}