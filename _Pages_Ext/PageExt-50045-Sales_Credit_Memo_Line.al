pageextension 50045 "Sales Cr. Memo Line Ext." extends "Sales Cr. Memo Subform"

//  RHE-TNA 25-01-2022 BDS-6057
//  - New extension

{
    layout
    {
        addafter(Description)
        {
            field("Default Description"; SetDefaultDescription)
            {

            }
        }
    }

    procedure SetDefaultDescription(): Text[100]
    var
        Item: Record Item;
        GLAccount: Record "G/L Account";
    begin
        case Type of
            Type::Item:
                begin
                    if Item.Get("No.") then
                        exit(Item.Description);
                end;
            Type::"G/L Account":
                begin
                    if GLAccount.Get("No.") then
                        exit(GLAccount.Name);
                end;
        end;
    end;
}