page 50013 "Allocate Sales Line"

//  RHE-TNA 04-03-2022 BDS-5565
//  - New Report

{
    PageType = StandardDialog;
    UsageCategory = None;
    SourceTable = "Sales Line";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Outstanding Qty. (Base)"; "Outstanding Qty. (Base)")
                {
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                }
                field("Available to Allocate"; AvailableToAlloc)
                {
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                }
                field("Current Allocated Qty."; CurrentLineAlloc)
                {
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                }
                field("Allocated Qty."; "Allocated Qty.")
                {
                    DecimalPlaces = 0 : 5;
                    Caption = 'Qty. to Allocate';

                    trigger OnValidate()
                    begin
                        if "Allocated Qty." > (AvailableToAlloc + CurrentLineAlloc) then
                            Error('You cannot allocate more than Available to Allocate.');
                        if "Allocated Qty." > "Outstanding Qty. (Base)" then
                            Error('You cannot allocate more than Outstanding Qty. (Base) in Sales Order Line.');
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        AvailableToAlloc := AvailableToAllocate(Rec);
        CurrentLineAlloc := "Allocated Qty.";
    end;

    var
        AvailableToAlloc: Decimal;
        CurrentLineAlloc: Decimal;
}