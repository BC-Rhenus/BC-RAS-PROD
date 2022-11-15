pageextension 50001 Item_Card_Extensions extends "Item Card"

//  RHE-TNA 18-11-2020 BDS-4552
//  - Added field "Export Inventory Level"

//  RHE-TNA 18-10-2021 BDS-5678
//  - Modified Tooltip of field "Export Inventory Level"

//  RHE-TNA 15-04-2022 BDS-6277
//  - Modified action("Unblock Item")
//  - Modified field("Export Inventory Level")

//  RHE-TNA 19-04-2022 BDS-6233
//  - Added addafter(Type)

//  RHE-TNA 25-05-2022 BDS-6364
//  - Added field ExclItemPrint

//  RHE-TNA 08-06-2022 BDS-6378
//  - Added field ExclItemEDI

{
    layout
    {
        addafter(Description)
        {
            field("Description 2"; "Description 2")
            {

            }
        }
        addafter(Blocked)
        {
            field("Block Reason"; "Block Reason")
            {
                Editable = Blocked;
            }
            field("Exported to WMS"; "Exported to WMS")
            {
                Editable = false;
            }
        }
        addafter("Inventory Posting Group")
        {
            field("Ass. Gen. Prod. Posting Group"; "Ass. Gen. Prod. Posting Group")
            {
                Caption = 'Assembly Gen. Prod. Posting Group';
                ToolTip = 'This posting group is used to determine the "Inventory Adjmt. Account" to use when posting assembly orders. If this field is left blank, the posting group as setup in field "Gen. Product Posting Group" is used.';
            }
        }
        addafter("Automatic Ext. Texts")
        {
            field("Obsolete Item"; "Obsolete Item")
            {

            }
        }
        //RHE-TNA 18-11-2020 BDS-4552 BEGIN
        addafter("Unit Volume")
        {
            field("Export Inventory Level"; "Export Inventory Level")
            {
                ToolTip = 'Set this field to include this Item in the Inventory Availability export file.';
                //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                Editable = (Type = Type::Inventory);
                //RHE-TNA 15-04-2022 BDS-6277 END
            }
        }
        //RHE-TNA 18-11-2020 BDS-4552 END
        //RHE-TNA 19-04-2022 BDS-6233 BEGIN
        addafter(Type)
        {
            field("Shipping Cost Item"; "Shipping Cost Item")
            {
                Editable = (Type <> Type::Inventory);
            }
            field(ExclItemPrint; ExclItemPrint)
            {
                ToolTip = 'Set this field to exclude the Item being printed on Order Confirmation, Sales Invoice and Customs Invoice. Note that the item will be printed if an amount is entered in the Order Line.';
            }
            field(ExclItemEDI; ExclItemEDI)
            {
                ToolTip = 'Set this field to exclude the Item being send in the Order Confirmation, Shipment Confirmation, Inventory Update and Inventory Level EDI. Note that the item will be send if an amount is entered in the Order Line.';
            }
        }
        //RHE-TNA 19-04-2022 BDS-6233 END
        modify(Blocked)
        {
            Editable = false;
        }
    }

    actions
    {
        addafter("Item Reclassification Journal")
        {
            group("Block/Unblock Item")
            {
                action("Block Item")
                {
                    Image = Lock;
                    Enabled = Blocked = false;

                    trigger OnAction();
                    begin
                        IF Confirm('Are you sure you want to Block this item?') then begin
                            rec.Validate(Blocked, true);
                            rec.Validate("Sales Blocked", true);
                            Rec.Validate("Purchasing Blocked", true);
                            rec.Modify(true);
                        end else begin
                            Message('Process canceled.');
                        end;
                    end;
                }
                action("Unblock Item")
                {
                    Image = Approve;
                    Enabled = Blocked;

                    trigger OnAction();
                    begin
                        Inventory_Setup.Get();
                        if Dialog.Confirm('Are you sure you want to Unblock this item?') then begin
                            if rec."Base Unit of Measure" = '' then
                                Error('Base Unit of Measure cannot be empty.');
                            if rec."Gen. Prod. Posting Group" = '' then
                                Error('Gen. Prod. Posting Group cannot be empty.');
                            if rec."VAT Prod. Posting Group" = '' then
                                Error('VAT Prod. Posting Group cannot be empty.');
                            //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                            //if rec."Inventory Posting Group" = '' then
                            if (Rec.Type = Rec.Type::Inventory) and (Rec."Inventory Posting Group" = '') then
                                //RHE-TNA 15-04-2022 BDS-6277 END
                                Error('Inventory Posting Group cannot be empty.');
                            if (Rec."Replenishment System" = Rec."Replenishment System"::Assembly) and (Rec."Ass. Gen. Prod. Posting Group" = '') then
                                Error('Ass. Gen. Pord. Posting Group cannot be empty.');
                            if rec."Costing Method" <> Inventory_Setup."Default Costing Method" then begin
                                if not Dialog.Confirm('Costing Method of item (' + Format(rec."Costing Method") + ') is different from Defaul Costing Method ('
                                + Format(Inventory_Setup."Default Costing Method") + '). Do you want to continue?') then
                                    exit;
                            end;
                            if (rec."Costing Method" = "Costing Method"::Standard) and (rec."Standard Cost" = 0) then
                                if not Dialog.Confirm('Standard Cost of item is 0. Do you want to continue?') then
                                    exit;
                            //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                            //if rec."Item Tracking Code" = '' then
                            if (Rec.Type = Rec.Type::Inventory) and (Rec."Item Tracking Code" = '') then
                                //RHE-TNA 15-04-2022 BDS-6277 END
                                if not Dialog.Confirm('Item Tracking Code is empty. Do you want to continue?') then
                                    exit;
                            rec.Validate(Blocked, false);
                            rec.Validate("Sales Blocked", false);
                            Rec.Validate("Purchasing Blocked", false);
                            rec.Modify();
                        end;
                    end;
                }
            }
            group(WMS)
            {
                action("Send to WMS")
                {
                    Image = Change;

                    trigger OnAction()
                    var
                        Export: Report "Export SKU Master to WMS";
                    begin
                        if "Exported to WMS" = true then begin
                            if not Dialog.Confirm('This item was sent to WMS already, do you want to send it again?') then
                                Error('Process canceled.');
                        end else
                            if not Dialog.Confirm('Are you sure you want to send this item to WMS?') then
                                Error('Process canceled.');
                        Clear(Export);
                        Export.SetRecFilter("No.");
                        Export.Run();
                    end;
                }
            }

        }
    }

    var
        Inventory_Setup: Record "Inventory Setup";
}