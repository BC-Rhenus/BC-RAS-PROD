page 50009 "WMS Inventory Reconciliation"

//  RHE-TNA 29-07-2020 BDS-4323
//  - New Page

//  RHE-TNA 25-01-2021.01-02-2021 BDS-4324
//  - Added field Calculated Inv. Level
//  - Added field Inv. Level Difference
//  - Added field Note
//  - Added action("Recalculate Inv. Level")
//  - Modified action("Import WMS Files")
//  - Modified trigger OnAfterGetRecord()

//  RHE-TNA 05-03-2021 BDS-5075
//  - Modified action("Set Approved & Process to True")

//  RHE-TNA 22-04-2021 BDS-5280
//  - Modified fields "Expiry Date" and "Inv. Level Difference"

//  RHE-TNA 28-04-2021 BDS-5302
//  - Modified trigger OnAfterGetRecord()

{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WMS Inventory Reconciliation";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Transaction Date"; "Transaction Date")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field(Process; Process)
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Processed Date"; "Processed Date")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Processed by User"; "Processed by User")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field(Approved; Approved)
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field(Disapproved; Disapproved)
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Approved / Disapproved by User"; "Approved / Disapproved by User")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Transaction Code"; "Transaction Code")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Item No."; "Item No.")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field(Description; Description)
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("WMS Qty."; "WMS Qty.")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                //RHE-TNA 25-01-2021 BDS-4324 BEGIN
                field("Calculated Inv. Level"; "Calculated Inv. Level")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Inv. Level Difference"; "Inv. Level Difference")
                {
                    //RHE-TNA 22-04-2021 BDS-5280 BEGIN
                    //Editable = false;
                    //RHE-TNA 22-04-2021 BDS-5280 END
                    StyleExpr = StyleVar;
                }
                //RHE-TNA 25-01-2021 BDS-4324 END
                field("Condition Code"; "Condition Code")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Lock Code"; "Lock Code")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Lot No."; "Lot No.")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Serial No."; "Serial No.")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Expiry Date"; "Expiry Date")
                {
                    //RHE-TNA 22-04-2021 BDS-5280 BEGIN
                    //Editable = false;
                    //RHE-TNA 22-04-2021 BDS-5280 END
                    StyleExpr = StyleVar;
                }
                field("WMS Notes"; "WMS Notes")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("From Location Code"; "From Location Code")
                {
                    StyleExpr = StyleVar;
                }
                field("To Location Code"; "To Location Code")
                {
                    StyleExpr = StyleVar;
                }
                field("Reason Code"; "Reason Code")
                {
                    StyleExpr = StyleVar;
                }
                field(Error; Error)
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
                field("Error Text"; "Error Text")
                {
                    Editable = false;
                    StyleExpr = StyleVar;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Import WMS Files")
            {
                Image = Import;
                trigger OnAction()
                var
                    Import: Report "Import WMS Inventory";
                    ImportLevel: Report "Import WMS Inventory Level";
                begin
                    //RHE-TNA 25-01-2021 BDS-4324 BEGIN
                    //Import.RunModal();
                    if Dialog.Confirm('Do you want to import Inventory Updates?') then
                        Import.RunModal();
                    if Dialog.Confirm('Do you want to import Inventory Levels?') then
                        ImportLevel.RunModal();
                    //RHE-TNA 25-01-2021 BDS-4324 END
                end;
            }
            //RHE-TNA 01-02-2021 BDS-4324 BEGIN
            action("Recalculate Inv. Level")
            {
                Image = Recalculate;
                trigger OnAction()
                var
                    WMSInvRec: Record "WMS Inventory Reconciliation";
                    ILE: Record "Item Ledger Entry";
                begin
                    CurrPage.SetSelectionFilter(WMSInvRec);
                    WMSInvRec.ModifyAll("Calculated Inv. Level", 0);
                    WMSInvRec.FindSet();
                    repeat
                        ILE.SetRange("Item No.", WMSInvRec."Item No.");
                        ILE.SetRange("Serial No.", WMSInvRec."Serial No.");
                        ILE.SetRange("Lot No.", WMSInvRec."Lot No.");
                        ILE.SetRange("Location Code", WMSInvRec."From Location Code");
                        ILE.SetFilter("Remaining Quantity", '>0');
                        if ILE.FindSet() then
                            repeat
                                WMSInvRec."Calculated Inv. Level" += ILE."Remaining Quantity";
                            until ILE.Next() = 0
                        else
                            WMSInvRec."Calculated Inv. Level" := 0;
                        WMSInvRec."Inv. Level Difference" := WMSInvRec."WMS Qty." - WMSInvRec."Calculated Inv. Level";
                        WMSInvRec.Modify(false);
                    until WMSInvRec.Next() = 0;
                end;
            }
            //RHE-TNA 01-02-2021 BDS-4324 END
            action("Set Approved & Process to True")
            {
                Image = Approve;
                trigger OnAction()
                var
                    WMSInvRec: Record "WMS Inventory Reconciliation";
                    Process: Report "Process WMS Inventory";
                begin
                    CurrPage.SetSelectionFilter(WMSInvRec);
                    WMSInvRec.ModifyAll(Approved, true);
                    WMSInvRec.ModifyAll("Approved / Disapproved by User", UserId);
                    WMSInvRec.ModifyAll(Process, true);
                    //RHE-TNA 05-03-2021 BDS-5075 BEGIN
                    WMSInvRec.ModifyAll(Disapproved, false);
                    if Dialog.Confirm('Records are set to Approved and Process, do you want to process the Inventory differences?') then
                        Process.RunModal();
                    //RHE-TNA 05-03-2021 BDS-5075 END
                end;
            }
            action("Set Approved & Process to False")
            {
                Image = Approve;
                trigger OnAction()
                var
                    WMSInvRec: Record "WMS Inventory Reconciliation";
                begin
                    CurrPage.SetSelectionFilter(WMSInvRec);
                    WMSInvRec.ModifyAll(Approved, false);
                    WMSInvRec.ModifyAll(Disapproved, true);
                    WMSInvRec.ModifyAll("Approved / Disapproved by User", UserId);
                    WMSInvRec.ModifyAll(Process, false);
                end;
            }
            action("Process Records")
            {
                Image = Apply;
                trigger OnAction()
                var
                    Process: Report "Process WMS Inventory";
                begin
                    Process.RunModal();
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        StyleVar := '';
        if Error then
            StyleVar := 'Unfavorable';
        //RHE-TNA 28-04-2021 BDS-5302 BEGIN
        //if not Error and ("Processed Date" <> 0D) then
        if not Error and ("Processed Date" <> 0D) and (Disapproved = false) then
            //RHE-TNA 28-04-2021 BDS-5302 END
            StyleVar := 'Favorable';
    end;

    //Global variables
    var
        myInt: Integer;
        StyleVar: Text;
}