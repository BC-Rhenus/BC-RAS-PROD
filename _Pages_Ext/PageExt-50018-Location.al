pageextension 50018 "Location Ext." extends "Location Card"

//  RHE-TNA 12-01-2022 BDS-5585
//  - Added field "WMS Interface Setup Entry No."
//  - Added field "WMS Interface Setup Entry"

{
    layout
    {
        addafter("Require Shipment")
        {
            field("Auto. Post Transfer Receipt"; "Auto. Post Transfer Receipt")
            {
                ToolTip = 'Set this field if it is allowed to post the Transfer Receipt at processing "WMS Import Records" regarding Transfer Shipment.';
            }
            field("WMS Interface Setup Entry No."; "WMS Interface Setup Entry No.")
            {
                ToolTip = 'This field determines which interface setup will be used to integrate with WMS systems.';
                BlankZero = true;
                trigger OnLookup(var Text: Text): Boolean
                var
                    IFSetup: Record "Interface Setup";
                    IFSetupList: Page "Interface Setup List";
                begin
                    IFSetup.Reset();
                    IFSetup.SetFilter(Type, '<>%1', IFSetup.Type::Customer);
                    Clear(IFSetupList);
                    IFSetupList.SetRecord(IFSetup);
                    IFSetupList.SetTableView(IFSetup);
                    IFSetupList.LookupMode(true);
                    if IFSetupList.RunModal() = Action::LookupOK then begin
                        IFSetupList.GetRecord(IFSetup);
                        "WMS Interface Setup Entry No." := IFSetup."Entry No.";
                    end;
                end;
            }
            field("WMS Interface Setup Entry"; "WMS Interface Setup Entry")
            {

            }
        }
    }
}