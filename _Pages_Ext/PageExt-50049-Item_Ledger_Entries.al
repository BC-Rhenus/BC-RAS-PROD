/// <summary>
/// Page PageExt-50049-Item_Ledger_entries(ID 50049).
/// </summary>   
pageextension 50049 "Item Ledger Entries Ext." extends "Item Ledger Entries"
//  RHE-AMKE 15-06-2022 BDS-6407
//  - Added procedure GetLocName()

{

    layout
    {
        addafter("Location Code")
        {

            field("Location Name"; GetLocName("Location Code"))
            {

            }
        }
    }

    procedure GetLocName(var "Location Code": code[10]) LocName: Text[100]

    begin

        if Location.Get("Location Code") then
            exit(Location."Name");

    end;

    var
        Location: record Location;
}