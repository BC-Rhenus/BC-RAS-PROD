page 50003 "Interface Mapping"

//  RHE-TNA 08-02-2022 BDS-6102
//  - Renamed Page from Carriers into "Interface Mapping"
//  - Renamed field from Carrier into "Interface Value"
//  - Added fields Type & "Currency Code"
//  - Added property Editable on several fields

{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Interface Mapping";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {

                }
                field("Interface Value"; "Interface Value")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("LCY Code"; "LCY Code")
                {
                    Editable = (Type = Type::Currency);
                    ToolTip = 'Set this field if the Interface Value equals the LCY Code in General Ledger Setup.';
                }
                field("Currency Code"; "Currency Code")
                {
                    Editable = (Type = Type::Currency);
                    ToolTip = 'When the Interface Value equals the LCY Code in General Ledger Setup, do not set a value in this field.';
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Editable = (Type = Type::Carrier);
                }
                field("Ship Agent Service Code Dom."; "Ship Agent Service Code Dom.")
                {
                    ApplicationArea = All;
                    Editable = (Type = Type::Carrier);
                }
                field("Ship Agent Service Code EU"; "Ship Agent Service Code EU")
                {
                    ApplicationArea = All;
                    Editable = (Type = Type::Carrier);
                }
                field("Ship Agent Service Code Export"; "Ship Agent Service Code Export")
                {
                    ApplicationArea = All;
                    Editable = (Type = Type::Carrier);
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}