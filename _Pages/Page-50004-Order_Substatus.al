page 50004 "Order Substatus"

//  RHE-TNA 19-05-2022 BDS-6111
//  - Added trigger OnInsertRecord()
//  - Added SourceTableView

{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Rhenus Setup";
    SourceTableView = where (Type = const ("Order Substatus"));

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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Type := Type::"Order Substatus";
    end;
}