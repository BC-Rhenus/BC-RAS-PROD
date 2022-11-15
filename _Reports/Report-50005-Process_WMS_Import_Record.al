report 50005 "Process WMS Import Record"

//RHE-TNA 17-03-2020.26-05-2020 BDS-3866
//  - Modified function OnPostReport()

//RHE-TNA 03-06-2020 BDS-4206
//  - Modified procedure PostWhseShipment()

//RHE-TNA 15-06-2020 BDS-4244
//  - Modified procedure PostWhseReceipt()

//RHE-TNA 30-11-2020 BDS-4742
//  - Modified procedure PostWhseReceipt()

//RHE-TNA 22-02-2021 BDS-5017
//  - Modified procedure PostWhseReceipt()

//RHE-TNA 30-04-2021 BDS-5304
//  - Modified procedure ProcessWhseShipmentLine()

//RHE-TNA 21-05-2021 BDS-5323
//  - Modified trigger OnPostReport()
//  - Added procedure PostSalesInvoice()

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreReport()

//  RHE-TNA 10-11-2021 BDS-5717
//  - procedure ProcessWhseShipmentLine(): Text[250]

//  RHE-TNA 21-02-2022 BDS-6109
//  - Modified procedure PostSalesInvoice()

//  RHE-TNA 17-02-2022..24-03-2022 BDS-5977
//  - REDESIGN

//  RHE-TNA 20-04-2022 BDS-6277
//  - Modified procedure PostWhseShipment()
//  - Modified procedure PostSalesInvoice()

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    trigger OnPreReport()
    begin

        SalesSetup.Get();
        PurchSetup.Get();
        if GuiAllowed then
            if not Dialog.Confirm('Are you sure you want to process the Warehouse Shipments/Receipts?') then
                Error('Process canceled');
    end;

    trigger OnPostReport()
    var
        WMSImportHdr2: Record "WMS Import Header";
        AssemblyLine: Record "Assembly Line";
        WMSSerialNo: Record "WMS Import Serial Number";
    begin
        WMSImportHdr2.SetRange(Process, true);
        if WMSImportHdr2.FindSet() then
            repeat
                //Reset errors
                WMSImportHdr.SetRange("Entry No.", WMSImportHdr2."Entry No.");
                WMSImportHdr.FindFirst();
                WMSImportHdr."Error Text" := '';
                WMSImportHdr.Error := false;

                WMSSerialNo.SetRange("WMS Import Entry No.", WMSImportHdr2."Entry No.");
                if WMSSerialNo.FindSet() then
                    WMSSerialNo.ModifyAll(Processed, false);

                case WMSImportHdr.Type of
                    WMSImportHdr.Type::Shipment:
                        begin
                            WMSImportHdr."Error Text" := ProcessWhseShipmentLine();
                            if WMSImportHdr."Error Text" = '' then
                                UpdateWhseShipment();
                        end;
                    WMSImportHdr.Type::Receipt:
                        begin
                            WMSImportHdr."Error Text" := ProcessWhseReceiptLine();
                            if WmsImportHdr."Error Text" = '' then
                                UpdateWhseReceipt();
                        end;
                end;

                //Update Import Record
                if WMSImportHdr."Error Text" <> '' then
                    WMSImportHdr.Error := true;
                WMSImportHdr.Process := false;
                WMSImportHdr."Processed by User" := UserId;
                WMSImportHdr."Processed Date" := Today;
                WMSImportHdr.Modify(false);
            until WMSImportHdr2.Next() = 0;
        Commit();
        PostWhseShipment();
        PostWhseReceipt();

        PostSalesInvoice();
    end;

    procedure ProcessWhseShipmentLine(): Text[250]
    var
        WMSImportLine: Record "WMS Import Line";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        ErrorFound: Boolean;
        ErrorText: Text;
    begin
        ErrorText := '';
        WhseShipmentLine.SetRange("No.", WMSImportHdr."Whse. Document No.");
        //Set general data for shipment and delete existing Reservation entries
        if WhseShipmentLine.FindSet() then begin
            ErrorText := UpdateSourceOrderOutbound(WhseShipmentLine."No.");
            if ErrorText <> '' then
                exit(ErrorText);
        end else
            exit('No Warehouse Shipment found.');

        //Update Warehouse Shipment Lines
        ErrorFound := false;
        WMSImportLine.SetCurrentKey("Entry No.", "Assembly Line", "Assembly Order No.", "Assembly Line No.");
        WMSImportLine.SetRange("Entry No.", WMSImportHdr."Entry No.");
        if WMSImportLine.FindSet() then begin
            repeat
                if not CheckWMSImportLineOutbound(WMSImportLine) then
                    ErrorFound := true
                else
                    ProcessWMSImportLineOutbound(WMSImportLine);
            until WMSImportLine.Next() = 0;
            if ErrorFound then
                exit('See Lines for error details.')
        end else
            exit('No WMS Import Lines found.')
    end;

    procedure ProcessWhseReceiptLine(): Text[250]
    var
        WMSImportLine: Record "WMS Import Line";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        ErrorFound: Boolean;
        ErrorText: Text;
    begin
        ErrorText := '';
        WhseReceiptLine.SetRange("No.", WMSImportHdr."Whse. Document No.");
        if WhseReceiptLine.FindSet() then begin
            ErrorText := UpdateSourceOrderInbound(WhseReceiptLine."No.");
            if ErrorText <> '' then
                exit(ErrorText);
        end else
            exit('No Warehouse Receipt found.');

        //Update Warehouse Shipment Lines
        ErrorFound := false;
        WMSImportLine.SetRange("Entry No.", WMSImportHdr."Entry No.");
        if WMSImportLine.FindSet() then begin
            repeat
                if not CheckWMSImportLineInbound(WMSImportLine) then
                    ErrorFound := true
                else
                    ProcessWMSImportLineInbound(WMSImportLine);
            until WMSImportLine.Next() = 0;
            if ErrorFound then
                exit('See Lines for error details.')
        end else
            exit('No WMS Import Lines found.')
    end;

    procedure UpdateSourceOrderOutbound(WhseShipmentNo: Code[20]): Text
    var
        WhseShipmentHdr: Record "Warehouse Shipment Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        ShippingAgentService: Record "Shipping Agent Services";
        SalesOrder: Record "Sales Header";
        PurchReturnOrder: Record "Purchase Header";
        TransferOrder: Record "Transfer Header";
    begin
        ShippingAgentService.SetRange("WMS Carrier", WMSImportHdr.Carrier);
        ShippingAgentService.SetRange("WMS Service Level", WMSImportHdr."Service Level");
        if not ShippingAgentService.FindFirst() then
            exit('No Shipping Agent Service Code setup for the combination of Carrier: ' + WMSImportHdr.Carrier + ', Service Level: ' + WMSImportHdr."Service Level" + '.');

        WhseShipmentHdr.Get(WhseShipmentNo);
        WhseShipmentHdr.Validate("Posting Date", WMSImportHdr."Shipment Date");
        WhseShipmentHdr.Validate("Shipped in WMS", true);
        WhseShipmentHdr.Validate("Auto. Posting Error", false);
        WhseShipmentHdr.Validate("Auto. Posting Error Text", '');
        WhseShipmentHdr.Modify(true);

        WhseShipmentLine.SetRange("No.", WhseShipmentHdr."No.");
        WhseShipmentLine.FindSet();
        WhseShipmentLine.ModifyAll("Qty. to Ship", 0);

        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order" then
            if SalesOrder.Get(SalesOrder."Document Type"::Order, WhseShipmentLine."Source No.") then begin
                SalesOrder."Package Tracking No." := WMSImportHdr."Bill Of Lading No.";
                SalesOrder."Posting Date" := WMSImportHdr."Shipment Date";
                if SalesOrder."Shipping Agent Code" <> ShippingAgentService."Shipping Agent Code" then
                    SalesOrder."Shipping Agent Code" := ShippingAgentService."Shipping Agent Code";
                if SalesOrder."Shipping Agent Service Code" <> ShippingAgentService.Code then
                    SalesOrder."Shipping Agent Service Code" := ShippingAgentService.Code;
                SalesOrder.Modify(true);
            end;
        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Purchase Return Order" then
            if PurchReturnOrder.get(PurchReturnOrder."Document Type"::"Return Order", WhseShipmentLine."Source No.") then begin
                PurchReturnOrder."Posting Date" := WMSImportHdr."Shipment Date";
                PurchReturnOrder.Modify(true);
            end;
        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Outbound Transfer" then
            if TransferOrder.Get(WhseShipmentLine."Source No.") then begin
                TransferOrder."Posting Date" := WMSImportHdr."Shipment Date";
                if TransferOrder."Shipping Agent Code" <> ShippingAgentService."Shipping Agent Code" then
                    TransferOrder."Shipping Agent Code" := ShippingAgentService."Shipping Agent Code";
                if TransferOrder."Shipping Agent Service Code" <> ShippingAgentService.Code then
                    TransferOrder."Shipping Agent Service Code" := ShippingAgentService.Code;
                TransferOrder.Modify();
            end;

        //Delete Reservation entries warehouse shipment               
        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order" then
            DeleteReservationEntry(WhseShipmentLine."Source No.", 37, 1);
        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Purchase Return Order" then
            DeleteReservationEntry(WhseShipmentLine."Source No.", 39, 5);
        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Outbound Transfer" then
            DeleteReservationEntry(WhseShipmentLine."Source No.", 5741, 0);
    end;

    procedure CheckWMSImportLineOutbound(WMSImportLine: Record "WMS Import Line"): Boolean
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        OutboundTrackingRequired: Boolean;
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        InventoryCheckOK: Boolean;
        WMSTrackingLine: Record "WMS Import Serial Number";
        TrackedQty: Decimal;
    begin
        WMSImportLine.Validate(Error, false);
        WMSImportLine.Validate("Error Text", '');
        WMSImportLine.Modify(false);

        OutboundTrackingRequired := false;
        WhseShipmentLine.SetRange("No.", WMSImportLine."Whse. Document No.");
        WhseShipmentLine.SetRange("Source Line No.", WMSImportLine."Source Line No.");
        if WMSImportLine."Assembly Line" = false then
            WhseShipmentLine.SetRange("Item No.", WMSImportLine."Item No.")
        else
            WhseShipmentLine.SetRange("Item No.", WMSImportLine."Assembly Item No.");
        if WhseShipmentLine.FindFirst() then begin
            if Item.Get(WMSImportLine."Item No.") then
                //Check if item needs Outbound Item Tracking                       
                if (Item."Item Tracking Code" <> '') and ItemTrackingCode.Get(item."Item Tracking Code") then begin
                    if (WhseShipmentLine."Source Type" = 37) and (ItemTrackingCode."SN Sales Outbound Tracking" OR ItemTrackingCode."Lot Sales Outbound Tracking") then
                        OutboundTrackingRequired := true;
                    if (WhseShipmentLine."Source Type" = 39) and (ItemTrackingCode."SN Purchase Outbound Tracking" OR ItemTrackingCode."Lot Purchase Outbound Tracking") then
                        OutboundTrackingRequired := true;
                    if (WhseShipmentLine."Source Type" = 5741) and (ItemTrackingCode."SN Transfer Tracking" OR ItemTrackingCode."Lot Transfer Tracking") then
                        OutboundTrackingRequired := true;
                end;

            //Check if serial or lot number quantity matches import line quantity
            if OutboundTrackingRequired then begin
                TrackedQty := 0;
                WMSTrackingLine.Reset();
                WMSTrackingLine.SetRange("WMS Import Entry No.", WMSImportLine."Entry No.");
                WMSTrackingLine.SetRange("WMS Import Line No.", WMSImportLine."Line No.");
                WMSTrackingLine.SetRange("Item No.", WMSImportLine."Item No.");
                if WMSTrackingLine.FindSet() then
                    repeat
                        TrackedQty += WMSTrackingLine.Quantity;
                    until WMSTrackingLine.Next() = 0;
                if TrackedQty < WMSImportLine."Qty. Shipped / Received" then begin
                    WMSImportLine.Validate(Error, true);
                    WMSImportLine.Validate("Error Text", 'Quantity in Tracking Lines is not sufficient: ' + format(TrackedQty) + '/' + format(WMSImportLine."Qty. Shipped / Received") + '.');
                    WMSImportLine.Modify(false);
                    exit(false);
                end;
            end;

            //Check Inventory
            if OutboundTrackingRequired = false then begin
                if WMSImportLine."Assembly Line" = false then
                    InventoryCheckOK := CheckInventory(WhseShipmentLine."Item No.", WhseShipmentLine."Location Code", WMSImportLine."Qty. Shipped / Received", '', '');
                if WMSImportLine."Assembly Line" = true then
                    //Check inventory with assembly component item
                    InventoryCheckOK := CheckInventory(WMSImportLine."Item No.", WhseShipmentLine."Location Code", WMSImportLine."Qty. Shipped / Received", '', '');
                if not InventoryCheckOK then begin
                    WMSImportLine.Validate(Error, true);
                    WMSImportLine.Validate("Error Text", 'Not enough inventory to process line.');
                    WMSImportLine.Modify(false);
                    exit(false);
                end;
            end else begin
                //Check if Lot and/or serial numbers are present
                WMSTrackingLine.Reset();
                WMSTrackingLine.SetRange("WMS Import Entry No.", WMSImportLine."Entry No.");
                WMSTrackingLine.SetRange("WMS Import Line No.", WMSImportLine."Line No.");
                WMSTrackingLine.SetRange("Item No.", WMSImportLine."Item No.");
                if ItemTrackingCode."SN Sales Outbound Tracking" then
                    WMSTrackingLine.SetFilter("Serial No.", '<>%1', '');
                if ItemTrackingCode."Lot Sales Outbound Tracking" then
                    WMSTrackingLine.SetFilter("Lot No.", '<>%1', '');
                if WMSTrackingLine.FindSet() then
                    repeat
                        //Check Inventory
                        if WMSImportLine."Assembly Line" = false then
                            if WMSTrackingLine."Serial No." <> '' then begin //Check serial number
                                InventoryCheckOK := CheckInventory(WhseShipmentLine."Item No.", WhseShipmentLine."Location Code", WMSTrackingLine.Quantity, '', WMSTrackingLine."Serial No.");
                                if (InventoryCheckOK) and (WMSTrackingLine."Lot No." <> '') then //Check also lot number in case both serial and lot number are present
                                    InventoryCheckOK := CheckInventory(WhseShipmentLine."Item No.", WhseShipmentLine."Location Code", WMSTrackingLine.Quantity, WMSTrackingLine."Lot No.", '');
                            end else //Check lot number
                                InventoryCheckOK := CheckInventory(WhseShipmentLine."Item No.", WhseShipmentLine."Location Code", WMSTrackingLine.Quantity, WMSTrackingLine."Lot No.", '');
                        if WMSImportLine."Assembly Line" = true then
                            //Check inventory with assembly component item
                            if WMSTrackingLine."Serial No." <> '' then begin //Check serial number
                                InventoryCheckOK := CheckInventory(WMSImportLine."Item No.", WhseShipmentLine."Location Code", WMSTrackingLine.Quantity, '', WMSTrackingLine."Serial No.");
                                if (InventoryCheckOK) and (WMSTrackingLine."Lot No." <> '') then //Check also lot number in case both serial and lot number are present
                                    InventoryCheckOK := CheckInventory(WMSImportLine."Item No.", WhseShipmentLine."Location Code", WMSTrackingLine.Quantity, WMSTrackingLine."Lot No.", '');
                            end else //Check lot number
                                InventoryCheckOK := CheckInventory(WMSImportLine."Item No.", WhseShipmentLine."Location Code", WMSTrackingLine.Quantity, WMSTrackingLine."Lot No.", '');
                        if not InventoryCheckOK then begin
                            WMSImportLine.Validate(Error, true);
                            WMSImportLine.Validate("Error Text", 'Not enough inventory to process line.');
                            WMSImportLine.Modify(false);
                            exit(false);
                        end;
                    until WMSTrackingLine.Next() = 0
                else begin
                    WMSImportLine.Validate(Error, true);
                    WMSImportLine.Validate("Error Text", 'No serial and/or lot numbers found.');
                    WMSImportLine.Modify(false);
                    exit(false);
                end;
            end;
        end else begin //No warehouse shipment line found
            WMSImportLine.Validate(Error, true);
            if WMSImportLine."Assembly Item No." <> '' then
                WMSImportLine.Validate("Error Text", 'No Warehouse Shipment Line found.')
            else
                WMSImportLine.Validate("Error Text", 'Assembly Item cannot be empty.');
            WMSImportLine.Modify(false);
            exit(false);
        end;
        exit(true);
    end;

    procedure ProcessWMSImportLineOutbound(WMSImportLine: Record "WMS Import Line")
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        OutboundTrackingRequired: Boolean;
        WMSTrackingLine: Record "WMS Import Serial Number";
        QtyToShip: Decimal;
        TransferOrder: Record "Transfer Header";
        AssemblyHdr: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        BOMComponent: Record "BOM Component";
        WMSImportLine2: Record "WMS Import Line";
    begin
        //Update Warehouse Shipment Line with Quantity to Ship
        WhseShipmentLine.SetRange("No.", WMSImportLine."Whse. Document No.");
        WhseShipmentLine.SetRange("Source Line No.", WMSImportLine."Source Line No.");
        if WMSImportLine."Assembly Line" = false then
            WhseShipmentLine.SetRange("Item No.", WMSImportLine."Item No.")
        else
            WhseShipmentLine.SetRange("Item No.", WMSImportLine."Assembly Item No.");
        WhseShipmentLine.FindFirst();

        if Item.Get(WMSImportLine."Item No.") then
            //Check if item needs Outbound Item Tracking                       
            if (Item."Item Tracking Code" <> '') and ItemTrackingCode.Get(item."Item Tracking Code") then begin
                if (WhseShipmentLine."Source Type" = 37) and (ItemTrackingCode."SN Sales Outbound Tracking" OR ItemTrackingCode."Lot Sales Outbound Tracking") then
                    OutboundTrackingRequired := true;
                if (WhseShipmentLine."Source Type" = 39) and (ItemTrackingCode."SN Purchase Outbound Tracking" OR ItemTrackingCode."Lot Purchase Outbound Tracking") then
                    OutboundTrackingRequired := true;
                if (WhseShipmentLine."Source Type" = 5741) and (ItemTrackingCode."SN Transfer Tracking" OR ItemTrackingCode."Lot Transfer Tracking") then
                    OutboundTrackingRequired := true;
            end;

        QtyToShip := 0;
        if not WMSImportLine."Assembly Line" then begin
            if OutboundTrackingRequired then begin
                WMSTrackingLine.Reset();
                WMSTrackingLine.SetRange("WMS Import Entry No.", WMSImportLine."Entry No.");
                WMSTrackingLine.SetRange("WMS Import Line No.", WMSImportLine."Line No.");
                WMSTrackingLine.SetRange("Item No.", WMSImportLine."Item No.");
                WMSTrackingLine.FindSet();
                repeat
                    QtyToShip += WMSTrackingLine.Quantity;
                until WMSTrackingLine.Next() = 0;
            end else
                QtyToShip := WMSImportLine."Qty. Shipped / Received";

            if (WhseShipmentLine."Qty. to Ship" + QtyToShip) <= WhseShipmentLine.Quantity then begin
                WhseShipmentLine.Validate("Qty. to Ship", WhseShipmentLine."Qty. to Ship" + QtyToShip);
                WhseShipmentLine.Modify(true);
                if OutboundTrackingRequired then begin
                    //Create Reservation entries
                    WMSTrackingLine.FindSet();
                    repeat
                        case WhseShipmentLine."Source Document" of
                            WhseShipmentLine."Source Document"::"Sales Order":
                                begin
                                    CreateReservationEntry(WhseShipmentLine."Item No.", WhseShipmentLine."Location Code", -WMSTrackingLine.Quantity, 37, 1, WhseShipmentLine."Source No.", WhseShipmentLine."Source Line No.", WhseShipmentLine."Due Date", WMSTrackingLine."Serial No.", WMSTrackingLine."Lot No.", WMSTrackingLine."Expiration Date", false, 0D);
                                end;
                            WhseShipmentLine."Source Document"::"Purchase Return Order":
                                begin
                                    CreateReservationEntry(WhseShipmentLine."Item No.", WhseShipmentLine."Location Code", -WMSTrackingLine.Quantity, 39, 5, WhseShipmentLine."Source No.", WhseShipmentLine."Source Line No.", WhseShipmentLine."Due Date", WMSTrackingLine."Serial No.", WMSTrackingLine."Lot No.", WMSTrackingLine."Expiration Date", false, 0D);
                                end;
                            WhseShipmentLine."Source Document"::"Outbound Transfer":
                                begin
                                    TransferOrder.Get(WhseShipmentLine."Source No.");
                                    //Create outbound entry
                                    CreateReservationEntry(WhseShipmentLine."Item No.", WhseShipmentLine."Location Code", -WMSTrackingLine.Quantity, 5741, 0, WhseShipmentLine."Source No.", WhseShipmentLine."Source Line No.", WhseShipmentLine."Due Date", WMSTrackingLine."Serial No.", WMSTrackingLine."Lot No.", WMSTrackingLine."Expiration Date", false, 0D);
                                    //Create inbound entry
                                    CreateReservationEntry(WhseShipmentLine."Item No.", TransferOrder."Transfer-to Code", WMSTrackingLine.Quantity, 5741, 1, WhseShipmentLine."Source No.", WhseShipmentLine."Source Line No.", 0D, WMSTrackingLine."Serial No.", WMSTrackingLine."Lot No.", WMSTrackingLine."Expiration Date", true, TransferOrder."Receipt Date");
                                end;
                        end;
                        WMSTrackingLine.Processed := true;
                        WMSTrackingLine.Modify(true);
                    until WMSTrackingLine.Next() = 0;
                end;
            end else begin
                WhseShipmentLine.Validate("Qty. to Ship", 0);
                WhseShipmentLine.Modify(true);
                WMSImportLine.Validate(Error, true);
                WMSImportLine.Validate("Error Text", 'Quantity to Ship (' + Format(QtyToShip) + ') cannot be more than Quantity (' + Format(WhseShipmentLine.Quantity) + ').');
                WMSImportLine.Modify(false);
            end;
        end else begin
            //Update Assembly Header
            if PrevAssemblyNo <> WMSImportLine."Assembly Order No." then begin
                //Only update warehouse shipment line once
                if AssemblyHdr.Get(AssemblyHdr."Document Type"::Order, WMSImportLine."Assembly Order No.") then begin
                    AssemblyHdr.Validate("Posting Date", WMSImportLine."Shipment Date");
                    AssemblyHdr.Modify(true);
                end;
                PrevAssemblyNo := WMSImportLine."Assembly Order No.";

                BOMComponent.SetRange("Parent Item No.", WhseShipmentLine."Item No.");
                BOMComponent.SetRange("No.", WMSImportLine."Item No.");
                if BOMComponent.FindFirst() then
                    WhseShipmentLine.Validate("Qty. to Ship", WMSImportLine."Qty. Shipped / Received" / BOMComponent."Quantity per")
                else
                    WhseShipmentLine.Validate("Qty. to Ship", 0);
                WhseShipmentLine.Modify(true);

                BOMComponent.Reset();
                BOMComponent.SetRange("Parent Item No.", WhseShipmentLine."Item No.");
                BOMComponent.SetRange("Basis for BOM Item Tracking", true);
                if BOMComponent.FindFirst() then begin
                    //Create Reservation entries for whse. shipment line which contains an Assembly order.
                    //Because of Assemble-To-Order Link create Reservation entries for the Assembly order.
                    WMSImportLine2.SetRange("Entry No.", WMSImportLine."Entry No.");
                    WMSImportLine2.SetRange("Item No.", BOMComponent."No.");
                    WMSImportLine2.SetRange("Assembly Order No.", WMSImportLine."Assembly Order No.");
                    if WMSImportLine2.FindSet() then
                        repeat
                            WMSTrackingLine.Reset();
                            WMSTrackingLine.SetRange("WMS Import Entry No.", WMSImportLine2."Entry No.");
                            WMSTrackingLine.SetRange("WMS Import Line No.", WMSImportLine2."Line No.");
                            WMSTrackingLine.SetRange("Item No.", WMSImportLine2."Item No.");
                            if WMSTrackingLine.FindSet() then
                                repeat
                                    UpdateATOReservationEntry(WhseShipmentLine."Item No.", AssemblyHdr."No.", WMSTrackingLine.Quantity, WMSTrackingLine."Serial No.", WMSTrackingLine."Lot No.", WMSTrackingLine."Expiration Date")
                                until WMSTrackingLine.Next() = 0;
                        until WMSImportLine2.Next() = 0;
                end;
            end;

            //Update Assembly Line
            //No need to update Assembly Component lines with Quantity to Consume as this is already done by validating Whse. shipment field Qty. to Ship. Only create Reservation entries.
            AssemblyLine.SetRange("Document Type", AssemblyLine."Document Type"::Order);
            AssemblyLine.SetRange("Document No.", WMSImportLine."Assembly Order No.");
            AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
            AssemblyLine.SetRange("Line No.", WMSImportLine."Assembly Line No.");
            AssemblyLine.SetRange("No.", WMSImportLine."Item No.");
            if AssemblyLine.FindFirst() then begin
                //Create Reservation entries
                WMSTrackingLine.Reset();
                WMSTrackingLine.SetRange("WMS Import Entry No.", WMSImportLine."Entry No.");
                WMSTrackingLine.SetRange("WMS Import Line No.", WMSImportLine."Line No.");
                WMSTrackingLine.SetRange("Item No.", WMSImportLine."Item No.");
                if WMSTrackingLine.FindSet() then
                    repeat
                        CreateReservationEntry(AssemblyLine."No.", AssemblyLine."Location Code", -WMSTrackingLine.Quantity, 901, 1, AssemblyLine."Document No.", AssemblyLine."Line No.", AssemblyLine."Due Date", WMSTrackingLine."Serial No.", WMSTrackingLine."Lot No.", WMSTrackingLine."Expiration Date", false, 0D);
                        WMSTrackingLine.Processed := true;
                        WMSTrackingLine.Modify(true);
                    until WMSTrackingLine.Next() = 0;
            end else begin
                //If no assembly line found reset Qty. to ship of Warehouse Shipment Line
                WhseShipmentLine.Validate("Qty. to Ship", 0);
                WhseShipmentLine.Modify(true);
                WMSImportLine.Validate(Error, true);
                WMSImportLine.Validate("Error Text", 'No Assembly Line found.');
                WMSImportLine.Modify(false);
            end;
        end;

        //check if all item tracking is processed
        if not WMSImportLine.Error then begin
            WMSTrackingLine.Reset();
            WMSTrackingLine.SetRange("WMS Import Entry No.", WMSImportLine."Entry No.");
            WMSTrackingLine.SetRange("WMS Import Line No.", WMSImportLine."Line No.");
            WMSTrackingLine.SetRange("Item No.", WMSImportLine."Item No.");
            WMSTrackingLine.SetRange(Processed, false);
            if WMSTrackingLine.FindFirst() then begin
                WMSImportLine.Validate("Error Text", 'One or more unprocessed Serial and/or Lot Numbers from WMS are present.');
                WMSImportLine.Modify(false);
            end;
        end;
    end;

    procedure CheckInventory(Item: code[20];
            Location: code[20];
            Qty: Decimal;
            LotNo: code[50];
            SerialNo: code[50]): Boolean
    //Local Variables
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", Item);
        ItemLedgerEntry.SetRange("Location Code", Location);
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
        ItemLedgerEntry.SetFilter("Lot No.", '%1|%2', LotNo, ' ');
        ItemLedgerEntry.SetFilter("Serial No.", '%1|%2', SerialNo, ' ');
        ItemLedgerEntry.CalcSums("Remaining Quantity");
        if ItemLedgerEntry."Remaining Quantity" < Qty then
            exit(false)
        else
            exit(true);
    end;

    procedure UpdateSourceOrderInbound(WhseReceiptNo: Code[20]): Text
    var
        WhseReceiptHdr: Record "Warehouse Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        PurchOrder: Record "Purchase Header";
        SalesReturnOrder: Record "Sales Header";
        TransferOrder: Record "Transfer Header";
    begin
        //Set general data for receipt and delete existing Reservation entries
        WhseReceiptLine.SetRange("No.", WhseReceiptNo);
        if WhseReceiptLine.FindSet() then begin
            if WhseReceiptHdr.Get(WhseReceiptLine."No.") then begin
                WhseReceiptHdr.Validate("Posting Date", WMSImportHdr."Receipt Date");
                WhseReceiptHdr.Validate("Received in WMS", true);
                WhseReceiptHdr.Validate("Auto. Posting Error", false);
                WhseReceiptHdr.Validate("Auto. Posting Error Text", '');
                WhseReceiptHdr.Modify(true);
            end;
            WhseReceiptLine.ModifyAll("Qty. to Receive", 0);
            if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Purchase Order" then
                if PurchOrder.Get(PurchOrder."Document Type"::Order, WhseReceiptLine."Source No.") then begin
                    PurchOrder."Posting Date" := WMSImportHdr."Receipt Date";
                    PurchOrder.Modify(true);
                end;
            if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Sales Return Order" then
                if SalesReturnOrder.get(SalesReturnOrder."Document Type"::"Return Order", WhseReceiptLine."Source No.") then begin
                    SalesReturnOrder."Posting Date" := WMSImportHdr."Receipt Date";
                    SalesReturnOrder.Modify(true);
                end;
            if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Inbound Transfer" then
                if TransferOrder.Get(WhseReceiptLine."Source No.") then begin
                    TransferOrder."Posting Date" := WMSImportHdr."Receipt Date";
                    TransferOrder.Modify();
                end;
            //Delete Reservation entries warehouse receipt              
            if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Purchase Order" then
                DeleteReservationEntry(WhseReceiptLine."Source No.", 39, 1);
            if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Sales Return Order" then
                DeleteReservationEntry(WhseReceiptLine."Source No.", 37, 5);
        end else
            exit('No Warehouse Receipt found.');
    end;

    procedure CheckWMSImportLineInbound(WMSImportLine: Record "WMS Import Line"): Boolean
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
        InboundTrackingRequired: Boolean;
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        InventoryCheckOK: Boolean;
        WMSTrackingLine: Record "WMS Import Serial Number";
        TrackedQty: Decimal;
    begin
        WMSImportLine.Validate(Error, false);
        WMSImportLine.Validate("Error Text", '');
        WMSImportLine.Modify(false);

        //Check if item needs Inbound Item Tracking           
        InboundTrackingRequired := false;
        WhseReceiptLine.SetRange("No.", WMSImportLine."Whse. Document No.");
        WhseReceiptLine.SetRange("Source Line No.", WMSImportLine."Source Line No.");
        WhseReceiptLine.SetRange("Item No.", WMSImportLine."Item No.");
        if WhseReceiptLine.FindFirst() then begin
            If Item.Get(WMSImportLine."Item No.") then begin
                if (Item."Item Tracking Code" <> '') and ItemTrackingCode.Get(item."Item Tracking Code") then begin
                    if (WhseReceiptLine."Source Type" = 39) and (ItemTrackingCode."SN Purchase Inbound Tracking" OR ItemTrackingCode."Lot Purchase Inbound Tracking") then
                        InboundTrackingRequired := true;
                    if (WhseReceiptLine."Source Type" = 37) and (ItemTrackingCode."SN Sales Inbound Tracking" OR ItemTrackingCode."Lot Sales Inbound Tracking") then
                        InboundTrackingRequired := true;
                    if (WhseReceiptLine."Source Type" = 5741) and (ItemTrackingCode."SN Transfer Tracking" OR ItemTrackingCode."Lot Transfer Tracking") then
                        InboundTrackingRequired := true;
                end;

                //Check if serial or lot number quantity matches import line quantity
                if InboundTrackingRequired then begin
                    TrackedQty := 0;
                    WMSTrackingLine.Reset();
                    WMSTrackingLine.SetRange("WMS Import Entry No.", WMSImportLine."Entry No.");
                    WMSTrackingLine.SetRange("WMS Import Line No.", WMSImportLine."Line No.");
                    WMSTrackingLine.SetRange("Item No.", WMSImportLine."Item No.");
                    if WMSTrackingLine.FindSet() then
                        repeat
                            TrackedQty += WMSTrackingLine.Quantity;
                        until WMSTrackingLine.Next() = 0;
                    if TrackedQty < WMSImportLine."Qty. Shipped / Received" then begin
                        WMSImportLine.Validate(Error, true);
                        WMSImportLine.Validate("Error Text", 'Quantity in Tracking Lines is not sufficient: ' + format(TrackedQty) + '/' + format(WMSImportLine."Qty. Shipped / Received") + '.');
                        WMSImportLine.Modify(false);
                        exit(false);
                    end;
                end;
            end;
        end else begin
            WMSImportLine.Validate(Error, true);
            WMSImportLine.Validate("Error Text", 'No Warehouse Receipt Line found.');
            WMSImportLine.Modify(false);
            exit(false);
        end;
        exit(true);
    end;

    procedure ProcessWMSImportLineInbound(WMSImportLine: Record "WMS Import Line")
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        InboundTrackingRequired: Boolean;
        WMSTrackingLine: Record "WMS Import Serial Number";
        QtyToReceive: Decimal;
        TransferOrder: Record "Transfer Header";
        AssemblyHdr: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        BOMComponent: Record "BOM Component";
        WMSImportLine2: Record "WMS Import Line";
    begin
        //Update Warehouse Receipt Line with Quantity to Receive
        WhseReceiptLine.SetRange("No.", WMSImportLine."Whse. Document No.");
        WhseReceiptLine.SetRange("Source Line No.", WMSImportLine."Source Line No.");
        WhseReceiptLine.SetRange("Item No.", WMSImportLine."Item No.");
        WhseReceiptLine.FindFirst();

        if Item.Get(WMSImportLine."Item No.") then
            //Check if item needs Outbound Item Tracking                       
            if (Item."Item Tracking Code" <> '') and ItemTrackingCode.Get(item."Item Tracking Code") then begin
                if (WhseReceiptLine."Source Type" = 39) and (ItemTrackingCode."SN Purchase Inbound Tracking" OR ItemTrackingCode."Lot Purchase Inbound Tracking") then
                    InboundTrackingRequired := true;
                if (WhseReceiptLine."Source Type" = 37) and (ItemTrackingCode."SN Sales Inbound Tracking" OR ItemTrackingCode."Lot Sales Inbound Tracking") then
                    InboundTrackingRequired := true;
                if (WhseReceiptLine."Source Type" = 5741) and (ItemTrackingCode."SN Transfer Tracking" OR ItemTrackingCode."Lot Transfer Tracking") then
                    InboundTrackingRequired := true;
            end;

        QtyToReceive := 0;
        if InboundTrackingRequired then begin
            WMSTrackingLine.Reset();
            WMSTrackingLine.SetRange("WMS Import Entry No.", WMSImportLine."Entry No.");
            WMSTrackingLine.SetRange("WMS Import Line No.", WMSImportLine."Line No.");
            WMSTrackingLine.SetRange("Item No.", WMSImportLine."Item No.");
            WMSTrackingLine.FindSet();
            repeat
                QtyToReceive += WMSTrackingLine.Quantity;
            until WMSTrackingLine.Next() = 0;
        end else
            QtyToReceive := WMSImportLine."Qty. Shipped / Received";

        if (WhseReceiptLine."Qty. to Receive" + QtyToReceive) <= WhseReceiptLine.Quantity then begin
            WhseReceiptLine.Validate("Qty. to Receive", WhseReceiptLine."Qty. to Receive" + QtyToReceive);
            WhseReceiptLine.Modify(true);
            if InboundTrackingRequired then begin
                //Create Reservation entries
                WMSTrackingLine.FindSet();
                repeat
                    case WhseReceiptLine."Source Document" of
                        WhseReceiptLine."Source Document"::"Purchase Order":
                            begin
                                CreateReservationEntry(WhseReceiptLine."Item No.", WhseReceiptLine."Location Code", WMSTrackingLine.Quantity, 39, 1, WhseReceiptLine."Source No.", WhseReceiptLine."Source Line No.", 0D, WMSTrackingLine."Serial No.", WMSTrackingLine."Lot No.", WMSTrackingLine."Expiration Date", true, WhseReceiptLine."Due Date");
                            end;
                        WhseReceiptLine."Source Document"::"Sales Return Order":
                            begin
                                CreateReservationEntry(WhseReceiptLine."Item No.", WhseReceiptLine."Location Code", WMSTrackingLine.Quantity, 37, 5, WhseReceiptLine."Source No.", WhseReceiptLine."Source Line No.", 0D, WMSTrackingLine."Serial No.", WMSTrackingLine."Lot No.", WMSTrackingLine."Expiration Date", true, WhseReceiptLine."Due Date");
                            end;
                        WhseReceiptLine."Source Document"::"Inbound Transfer":
                            begin
                                //Check if serial no. and/or lot no. was shipped in this transfer order
                                if CheckReservationEntryPresent(WhseReceiptLine."Item No.", WhseReceiptLine."Location Code", WMSTrackingLine.Quantity, 5741, 1, WhseReceiptLine."Source No.", WhseReceiptLine."Source Line No.", WMSTrackingLine."Serial No.", WMSTrackingLine."Lot No.") = false then begin
                                    WMSImportLine.Validate(Error, true);
                                    WMSImportLine.Validate("Error Text", 'One or more Serial and/or Lot Numbers are not found as a shipped Serial/Lot Number.');
                                    WMSImportLine.Modify(false);
                                end;
                            end;
                    end;
                    WMSTrackingLine.Processed := true;
                    WMSTrackingLine.Modify(true);
                until WMSTrackingLine.Next() = 0;
            end;
        end else begin
            WhseReceiptLine.Validate("Qty. to Receive", 0);
            WhseReceiptLine.Modify(true);
            WMSImportLine.Validate(Error, true);
            WMSImportLine.Validate("Error Text", 'Quantity to Receive (' + Format(QtyToReceive) + ') cannot be more than Quantity (' + Format(WhseReceiptLine.Quantity) + ').');
            WMSImportLine.Modify(false);
        end;

        //check if all item tracking is processed
        if not WMSImportLine.Error then begin
            WMSTrackingLine.Reset();
            WMSTrackingLine.SetRange("WMS Import Entry No.", WMSImportLine."Entry No.");
            WMSTrackingLine.SetRange("WMS Import Line No.", WMSImportLine."Line No.");
            WMSTrackingLine.SetRange("Item No.", WMSImportLine."Item No.");
            WMSTrackingLine.SetRange(Processed, false);
            if WMSTrackingLine.FindFirst() then begin
                WMSImportLine.Validate("Error Text", 'One or more unprocessed Serial and/or Lot Numbers from WMS are present.');
                WMSImportLine.Modify(false);
            end;
        end;
    end;

    procedure DeleteReservationEntry(SourceNo: code[20]; SourceType: Integer; SourceSubType: Integer)
    //Local Variables
    var
        ResEntry: Record "Reservation Entry";
        AssemblyHdr: Record "Assembly Header";
        AssembleToOrderLink: Record "Assemble-to-Order Link";
    begin
        ResEntry.Reset();
        ResEntry.SetRange("Source ID", SourceNo);
        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
        ResEntry.SetRange("Source Type", SourceType);
        ResEntry.SetRange("Source Subtype", SourceSubType);
        ResEntry.DeleteAll(true);
        //Delete Reservation entries Assembly Order(s) related to the sales order
        if SourceType = 37 then begin
            ResEntry.Reset();
            ResEntry.SetRange("Source Type", 901);
            ResEntry.SetRange("Source Subtype", 1);
            //Get Assembly No.
            AssembleToOrderLink.SetRange("Document Type", AssembleToOrderLink."Document Type"::Order);
            AssembleToOrderLink.SetRange(Type, AssembleToOrderLink.Type::Sale);
            AssembleToOrderLink.SetRange("Document No.", SourceNo);
            if AssembleToOrderLink.FindSet() then
                repeat
                    AssemblyHdr.SetRange("Document Type", AssembleToOrderLink."Assembly Document Type");
                    AssemblyHdr.SetRange("No.", AssembleToOrderLink."Assembly Document No.");
                    if AssemblyHdr.FindSet() then
                        repeat
                            ResEntry.SetRange("Source ID", AssemblyHdr."No.");
                            ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Surplus);
                            ResEntry.DeleteAll(true);
                        until AssemblyHdr.Next() = 0;
                until AssembleToOrderLink.Next() = 0;
        end;
    end;

    procedure CreateReservationEntry(ItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal; SourceType: Integer; SourceSubType: Integer; SourceID: code[20]; SourceRefNo: Integer; DueDate: Date; SerialNo: Code[50]; LotNo: Code[50]; ExpDate: Date; PositiveYesNo: Boolean; ReceiptDate: Date)
    //Local Variables
    var
        ResEntry: Record "Reservation Entry";
        LastResEntryNo: Integer;
    begin
        if ResEntry.FindLast() then
            LastResEntryNo := ResEntry."Entry No.";
        ResEntry.Init();
        ResEntry."Entry No." := LastResEntryNo + 1;
        ResEntry.Positive := PositiveYesNo;
        ResEntry."Item No." := ItemNo;
        ResEntry."Location Code" := LocationCode;
        ResEntry.VALIDATE("Quantity (Base)", Quantity);
        ResEntry."Reservation Status" := ResEntry."Reservation Status"::Surplus;
        ResEntry."Creation Date" := WORKDATE;
        ResEntry."Source Type" := SourceType;
        ResEntry."Source Subtype" := SourceSubType;
        ResEntry."Source ID" := SourceID;
        ResEntry."Source Ref. No." := SourceRefNo;
        ResEntry."Shipment Date" := DueDate;
        ResEntry."Expected Receipt Date" := ReceiptDate;
        if SerialNo <> '' then begin
            ResEntry."Serial No." := SerialNo;
            ResEntry."Item Tracking" := ResEntry."Item Tracking"::"Serial No.";
        end;
        if LotNo <> '' then begin
            ResEntry."Lot No." := LotNo;
            if ResEntry."Item Tracking" = ResEntry."Item Tracking"::None then
                ResEntry."Item Tracking" := ResEntry."Item Tracking"::"Lot No."
            else
                ResEntry."Item Tracking" := ResEntry."Item Tracking"::"Lot and Serial No.";
        end;
        ResEntry."Created By" := USERID;
        ResEntry."Expiration Date" := ExpDate;
        ResEntry.Insert(true);
    end;

    procedure CheckReservationEntryPresent(ItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal; SourceType: Integer; SourceSubType: Integer; SourceID: code[20]; SourceRefNo: Integer; SerialNo: Code[50]; LotNo: Code[50]): Boolean
    var
        ResEntry: Record "Reservation Entry";
    begin
        ResEntry.SetRange("Item No.", ItemNo);
        ResEntry.SetRange("Location Code", LocationCode);
        ResEntry.SetRange("Source Type", SourceType);
        ResEntry.SetRange("Source Subtype", SourceSubType);
        ResEntry.SetRange("Source ID", SourceID);
        if SourceType = 39 then
            ResEntry.SetRange("Source Ref. No.", SourceRefNo);
        if SourceType = 5741 then
            ResEntry.SetRange("Source Prod. Order Line", SourceRefNo);
        if SerialNo <> '' then
            ResEntry.SetRange("Serial No.", SerialNo);
        if LotNo <> '' then
            ResEntry.SetRange("Lot No.", LotNo);

        if ResEntry.FindFirst() then begin
            exit(true);
        end else begin
            exit(false);
        end;
    end;

    procedure UpdateATOReservationEntry(ItemNo: Code[20]; SourceID: Code[20]; Quantity: Decimal; SerialNo: Code[20]; LotNo: Code[20]; ExpDate: Date)
    //Local variables
    var
        ResEntry: Record "Reservation Entry";
        NextResEntryNo: Integer;
        ResEntry2: Record "Reservation Entry";
        ResEntryDuplicate: Record "Reservation Entry";
    begin
        if ResEntry.FindLast() then
            NextResEntryNo := ResEntry."Entry No." + 1;
        ResEntry.SetRange("Source Type", 900);
        ResEntry.SetRange("Source Subtype", 1);
        ResEntry.SetRange("Item No.", ItemNo);
        ResEntry.SetRange("Source ID", SourceID);
        ResEntry.SetRange("Serial No.", '');
        ResEntry.SetRange("Lot No.", '');
        if ResEntry.FindFirst() then begin
            ResEntry2.SetRange("Entry No.", ResEntry."Entry No.");
            if ResEntry.Quantity > Quantity then begin
                //When multiple serial/lot numbers to assign, duplicate reservation entries  
                if ResEntry2.FindSet() then
                    repeat
                        ResEntryDuplicate.init;
                        ResEntryDuplicate.Copy(ResEntry2);
                        ResEntryDuplicate."Entry No." := NextResEntryNo;
                        if ResEntryDuplicate.Quantity < 0 then
                            ResEntryDuplicate.Quantity := -Quantity
                        else
                            ResEntryDuplicate.Quantity := Quantity;
                        ResEntryDuplicate."Quantity (Base)" := ResEntryDuplicate.Quantity;
                        ResEntryDuplicate."Qty. to Handle (Base)" := ResEntryDuplicate.Quantity;
                        ResEntryDuplicate."Qty. to Invoice (Base)" := ResEntryDuplicate.Quantity;
                        if SerialNo <> '' then begin
                            ResEntryDuplicate."Serial No." := SerialNo;
                            ResEntryDuplicate."Item Tracking" := ResEntryDuplicate."Item Tracking"::"Serial No.";
                        end;
                        if LotNo <> '' then begin
                            ResEntryDuplicate."Lot No." := LotNo;
                            if ResEntryDuplicate."Item Tracking" = ResEntryDuplicate."Item Tracking"::None then
                                ResEntryDuplicate."Item Tracking" := ResEntryDuplicate."Item Tracking"::"Lot No."
                            else
                                ResEntryDuplicate."Item Tracking" := ResEntryDuplicate."Item Tracking"::"Lot and Serial No.";
                        end;
                        ResEntryDuplicate."Created By" := USERID;
                        ResEntryDuplicate."Expiration Date" := ExpDate;
                        ResEntryDuplicate.Insert(true);

                        if ResEntry2.Quantity < 0 then
                            ResEntry2.Quantity := ResEntry2.Quantity + Quantity
                        else
                            ResEntry2.Quantity := ResEntry2.Quantity - Quantity;
                        ResEntry2."Quantity (Base)" := ResEntry2.Quantity;
                        ResEntry2."Qty. to Handle (Base)" := ResEntry2.Quantity;
                        ResEntry2."Qty. to Invoice (Base)" := ResEntry2.Quantity;
                        ResEntry2.Modify(true);
                    until ResEntry2.Next() = 0;
            end else begin
                ;
                if ResEntry2.FindSet() then
                    repeat
                        if ResEntry2.Quantity < 0 then
                            ResEntry2.Validate(Quantity, -Quantity)
                        else
                            ResEntry2.Validate(Quantity, Quantity);
                        if SerialNo <> '' then begin
                            ResEntry2."Serial No." := SerialNo;
                            ResEntry2."Item Tracking" := ResEntry2."Item Tracking"::"Serial No.";
                        end;
                        if LotNo <> '' then begin
                            ResEntry2."Lot No." := LotNo;
                            if ResEntry2."Item Tracking" = ResEntry2."Item Tracking"::None then
                                ResEntry2."Item Tracking" := ResEntry2."Item Tracking"::"Lot No."
                            else
                                ResEntry2."Item Tracking" := ResEntry2."Item Tracking"::"Lot and Serial No.";
                        end;
                        ResEntry2."Expiration Date" := ExpDate;
                        ResEntry2.Modify(true);
                    until ResEntry2.Next() = 0;
            end;
        end;
    end;

    procedure UpdateWhseShipment()
    var
        WhseShipmentHdr: Record "Warehouse Shipment Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        //Set Warehouse shipment header with Shipped completely
        if WhseShipmentHdr.Get(WMSImportHdr."Whse. Document No.") then begin
            WhseShipmentLine.SetRange("No.", WhseShipmentHdr."No.");
            if WhseShipmentLine.FindSet() then
                repeat
                    if WhseShipmentLine."Qty. to Ship" = WhseShipmentLine.Quantity then begin
                        if not WhseShipmentHdr."Shipped Completely" then begin
                            WhseShipmentHdr.Validate("Shipped Completely", true);
                            WhseShipmentHdr.Modify(false);
                        end;
                    end else begin
                        if WhseShipmentHdr."Shipped Completely" then begin
                            WhseShipmentHdr.Validate("Shipped Completely", false);
                            WhseShipmentHdr.Modify(false);
                        end;
                    end;
                until (WhseShipmentLine.Next() = 0) or (WhseShipmentHdr."Shipped Completely" = false);
        end;
    end;

    procedure UpdateWhseReceipt()
    var
        WhseReceiptHdr: Record "Warehouse Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        //Set Warehouse receipt header with Shipped completely
        if WhseReceiptHdr.Get(WMSImportHdr."Whse. Document No.") then begin
            WhseReceiptLine.SetRange("No.", WhseReceiptHdr."No.");
            if WhseReceiptLine.FindSet() then
                repeat
                    if WhseReceiptLine."Qty. to Receive" = WhseReceiptLine.Quantity then begin
                        if not WhseReceiptHdr."Received Completely" then begin
                            WhseReceiptHdr.Validate("Received Completely", true);
                            WhseReceiptHdr.Modify(false);
                        end;
                    end else begin
                        if WhseReceiptHdr."Received Completely" then begin
                            WhseReceiptHdr.Validate("Received Completely", false);
                            WhseReceiptHdr.Modify(false);
                        end;
                    end;
                until (WhseReceiptLine.Next() = 0) or (WhseReceiptHdr."Received Completely" = false);
        end;
    end;

    procedure PostWhseShipment()
    //Local Variables
    var
        OKToPost: Boolean;
        GLAccountPresent: Boolean;
        WhseShipmentHdr: Record "Warehouse Shipment Header";
        WhseSHipmentLine: Record "Warehouse Shipment Line";
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchHdr: Record "Purchase Header";
        TransferHdr: Record "Transfer Header";
        PostWhseShip: Codeunit "Whse.-Post Shipment";
        TransferReceiptToPost: Boolean;
        PostTransferOrderReceipt: Codeunit "TransferOrder-Post Receipt";
        Location: record Location;
        WhseShipmentHdr2: Record "Warehouse Shipment Header";
        Item: Record Item;
    begin
        OKToPost := false;

        if SalesSetup.AutoPostWhseShipment then begin
            WhseShipmentHdr.Reset();
            WhseShipmentHdr.SetRange("Shipped in WMS", true);
            WhseShipmentHdr.SetRange("Shipped Completely", true);
            if WhseShipmentHdr.FindSet() then
                repeat
                    TransferReceiptToPost := false;
                    WhseShipmentLine.SetRange("No.", WhseShipmentHdr."No.");
                    IF WhseShipmentLine.FindSet() then begin
                        //Only 1 source document per warehouse shipment
                        //Check if the Sales Order contains lines of Type = G/L account and if so do not post an invoice
                        GLAccountPresent := false;
                        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order" then begin
                            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                            SalesLine.SetRange("Document No.", WhseShipmentLine."Source No.");
                            SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                            //RHE-TNA 21-02-2022 BDS-6109 BEGIN
                            //SalesLine.SetFilter("Qty. to Invoice", '<>%1', 0);
                            //RHE-TNA 21-02-2022 BDS-6109 END
                            IF SalesLine.FindFirst() THEN
                                GLAccountPresent := true;

                            //RHE-TNA 20-04-2022 BDS-6277 BEGIN
                            //Check if item is present which is not of type = Inventory
                            SalesLine.SetRange(Type, SalesLine.Type::Item);
                            if SalesLine.FindSet() then
                                repeat
                                    Item.Get(SalesLine."No.");
                                    if Item.Type <> Item.Type::Inventory then
                                        GLAccountPresent := true;
                                until SalesLine.Next() = 0;
                            //RHE-TNA 20-04-2022 BDS-6277 END
                        END;
                        //Check if source document is released
                        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Sales Order" then begin
                            if (SalesHdr.Get(SalesHdr."Document Type"::Order, WhseSHipmentLine."Source No.")) and (SalesHdr.Status = SalesHdr.Status::Released) then
                                OKToPost := true
                            else
                                OKToPost := false;
                        end;
                        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Purchase Return Order" then begin
                            if (PurchHdr.Get(PurchHdr."Document Type"::"Return Order", WhseSHipmentLine."Source No.")) and (PurchHdr.Status = PurchHdr.Status::Released) then
                                OKToPost := true
                            else
                                OKToPost := false;
                        end;
                        if WhseShipmentLine."Source Document" = WhseShipmentLine."Source Document"::"Outbound Transfer" then begin
                            if (TransferHdr.Get(WhseSHipmentLine."Source No.")) and (TransferHdr.Status = TransferHdr.Status::Released) then begin
                                OKToPost := true;
                                if (Location.Get(TransferHdr."Transfer-to Code") and (Location."Require Receive" = false) and (Location."Require Put-away" = false) and (Location."Auto. Post Transfer Receipt")) then
                                    TransferReceiptToPost := true;
                            end else
                                OKToPost := false;
                        end;

                        //Check if lines are present with Qty. to ship <> Quantity
                        repeat
                            if WhseShipmentLine."Qty. to Ship" = WhseShipmentLine.Quantity then
                                OKToPost := true
                            else
                                OKToPost := false;
                        until WhseShipmentLine.Next() = 0;

                        if OKToPost = true then begin
                            if GLAccountPresent = false then
                                PostWhseShip.SetPostingSettings(SalesSetup.AllowInvPosting)
                            else
                                PostWhseShip.SetPostingSettings(false);
                            PostWhseShip.SetPrint(false);
                            if not PostWhseShip.Run(WhseSHipmentLine) then begin
                                Clear(PostWhseShip);
                                //RHE-TNA 03-06-2020 BDS-4206 BEGIN
                                //WhseShipmentHdr.Validate("Auto. Posting Error", true);
                                //WhseShipmentHdr.Validate("Auto. Posting Error Text", GetLastErrorText);
                                //WhseShipmentHdr.Modify(false);
                                WhseShipmentHdr2.Get(WhseShipmentHdr."No.");
                                WhseShipmentHdr2.Validate("Auto. Posting Error", true);
                                WhseShipmentHdr2.Validate("Auto. Posting Error Text", GetLastErrorText);
                                WhseShipmentHdr2.Modify(false);
                                //RHE-TNA 03-06-2020 BDS-4206 END
                                ClearLastError();
                                Commit();
                            end;
                            Clear(PostWhseShip);
                            Commit();
                            if TransferReceiptToPost then begin
                                TransferHdr.Get(TransferHdr."No.");
                                PostTransferOrderReceipt.Run(TransferHdr);
                                Clear(PostTransferOrderReceipt);
                                Commit();
                            end;
                        end;
                    end;
                until WhseShipmentHdr.Next() = 0;
        end;
    end;

    procedure PostWhseReceipt()
    //Local Variables
    var
        OKToPost: Boolean;
        WhseReceiptHdr: Record "Warehouse Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        SalesHdr: Record "Sales Header";
        PurchHdr: Record "Purchase Header";
        TransferHdr: Record "Transfer Header";
        PostWhseReceipt: Codeunit "Whse.-Post Receipt";
        Source: Option " ",Purchase,"Sales Return";
        WhseReceiptHdr2: Record "Warehouse Receipt Header";
    begin
        OKToPost := false;

        if PurchSetup.AutoPostWhseReceipt then begin
            WhseReceiptHdr.Reset();
            WhseReceiptHdr.SetRange("Received in WMS", true);
            //RHE-TNA 15-06-2020 BDS-4244 BEGIN
            //WhseReceiptHdr.SetRange("Received Completely", true);
            //RHE-TNA 15-06-2020 BDS-4244 END
            if WhseReceiptHdr.FindSet() then
                repeat
                    WhseReceiptLine.SetRange("No.", WhseReceiptHdr."No.");
                    IF WhseReceiptLine.FindSet() then begin
                        Source := Source::" ";
                        //Only 1 source document per warehouse receipt
                        //Check if source document is released
                        if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Purchase Order" then begin
                            Source := Source::Purchase;
                            if (PurchHdr.Get(PurchHdr."Document Type"::Order, WhseReceiptLine."Source No.")) and (PurchHdr.Status = PurchHdr.Status::Released) then
                                OKToPost := true
                            else
                                OKToPost := false;
                        end;
                        if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Sales Return Order" then begin
                            Source := Source::"Sales Return";
                            if (SalesHdr.Get(SalesHdr."Document Type"::"Return Order", WhseReceiptLine."Source No.")) and (SalesHdr.Status = SalesHdr.Status::Released) then
                                OKToPost := true
                            else
                                OKToPost := false;
                        end;
                        if WhseReceiptLine."Source Document" = WhseReceiptLine."Source Document"::"Inbound Transfer" then begin
                            if (TransferHdr.Get(WhseReceiptLine."Source No.")) and (TransferHdr.Status = TransferHdr.Status::Released) then begin
                                OKToPost := true;
                            end else
                                OKToPost := false;
                        end;

                        //RHE-TNA 15-06-2020 BDS-4244 BEGIN
                        ////Check if lines are present with Qty. to receive <> Quantity
                        //repeat
                        //    if WhseReceiptLine."Qty. to Receive" = WhseReceiptLine.Quantity then
                        //        OKToPost := true
                        //    else
                        //        OKToPost := false;
                        //until WhseReceiptLine.Next() = 0;
                        //RHE-TNA 15-06-2020 BDS-4244 END

                        if OKToPost = true then begin
                            if not PostWhseReceipt.Run(WhseReceiptLine) then begin
                                Clear(PostWhseReceipt);
                                //RHE-TNA 30-11-2020 BDS-4742 BEGIN                              
                                //WhseReceiptHdr.Validate("Auto. Posting Error", true);
                                //WhseReceiptHdr.Validate("Auto. Posting Error Text", GetLastErrorText);
                                //WhseReceiptHdr.Modify(false);
                                WhseReceiptHdr2.Get(WhseReceiptHdr."No.");
                                WhseReceiptHdr2.Validate("Auto. Posting Error", true);
                                WhseReceiptHdr2.Validate("Auto. Posting Error Text", GetLastErrorText);
                                WhseReceiptHdr2.Modify(false);
                                //RHE-TNA 30-11-2020 BDS-4742 END
                                ClearLastError();
                                Commit();
                            end else begin
                                Clear(PostWhseReceipt);
                                Commit();
                                if Source = Source::Purchase then begin
                                    PurchHdr.Get(PurchHdr."Document Type", PurchHdr."No.");
                                    PurchHdr.Validate(Invoice, true);
                                    PurchHdr.Modify();
                                    Commit();
                                end;
                                if Source = Source::"Sales Return" then begin
                                    SalesHdr.Get(SalesHdr."Document Type", SalesHdr."No.");
                                    SalesHdr.Validate(Invoice, true);
                                    SalesHdr.Modify();
                                    Commit();
                                end;
                                //RHE-TNA 22-02-2021 BDS-5017 BEGIN
                                if WhseReceiptHdr2.Get(WhseReceiptHdr."No.") then begin
                                    WhseReceiptHdr2.Validate("Received in WMS", false);
                                    WhseReceiptHdr2.Modify();
                                    Commit();
                                end;
                                //RHE-TNA 22-02-2021 BDS-5017 END
                            end;
                        end;
                    end;
                until WhseReceiptHdr.Next() = 0;
        end;
    end;

    //RHE-TNA 21-05-2021 BDS-5323 BEGIN
    procedure PostSalesInvoice()
    var
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CompletelyShipped: Boolean;
        SalesHdrMod: Boolean;
        SalesLineMod: Boolean;
        PostCU: Codeunit "Sales-Post";
        Ship: Boolean;
        Invoice: Boolean;
        Item: Record Item;
        NoZeroAmountLine: Boolean;
    begin
        IF SalesSetup.AllowInvPostingGL then begin
            SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
            SalesHdr.SetRange(Status, SalesHdr.Status::Released);
            if SalesHdr.FindSet() then
                repeat
                    //RHE-TNA 21-02-2022 BDS-6109 BEGIN
                    //Check if no GL Account lines are present without an amount, otherwise do not post invoice
                    SalesLine.SetRange("Document Type", SalesHdr."Document Type");
                    SalesLine.SetRange("Document No.", SalesHdr."No.");
                    SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                    SalesLine.SetRange(Amount, 0);
                    if not SalesLine.FindFirst() then begin
                        SalesLine.Reset();
                        //RHE-TNA 21-02-2022 BDS-6109 END
                        CompletelyShipped := false;
                        SalesLine.SetRange("Document Type", SalesHdr."Document Type");
                        SalesLine.SetRange("Document No.", SalesHdr."No.");
                        SalesLine.SetRange(Type, SalesLine.Type::Item);
                        if SalesLine.FindSet() then
                            repeat
                                //RHE-TNA 20-04-2022 BDS-6277 BEGIN
                                /*
                                if SalesLine.Quantity = SalesLine."Quantity Shipped" then
                                    CompletelyShipped := true
                                else
                                    CompletelyShipped := false;
                                    */
                                NoZeroAmountLine := true;
                                Item.Get(SalesLine."No.");
                                if Item.Type = Item.Type::Inventory then begin
                                    if SalesLine.Quantity = SalesLine."Quantity Shipped" then
                                        CompletelyShipped := true
                                    else
                                        CompletelyShipped := false;
                                end else begin
                                    CompletelyShipped := true;
                                    //Check if no Sales lines with Item type <> Inventory without an amount exist, otherwise do not post invoice
                                    if SalesLine.Amount = 0 then
                                        NoZeroAmountLine := false
                                    else begin
                                        //Set Sales lines with Item type <> Inventory with Qty. to ship to make sure the lines are posted
                                        if SalesLine."Quantity (Base)" - SalesLine."Qty. Shipped (Base)" <> SalesLine."Qty. to Ship (Base)" then begin
                                            SalesLine.Validate("Qty. to Ship", SalesLine.Quantity - SalesLine."Quantity Shipped");
                                            SalesLine.Modify(true);
                                            SalesLineMod := true;
                                        end;
                                    end;
                                end;
                                //RHE-TNA 20-04-2022 BDS-6277 END
                            until SalesLine.Next() = 0;

                        //Only continue when order is completely shipped
                        //RHE-TNA 20-04-2022 BDS-6277 BEGIN
                        //if CompletelyShipped then begin
                        if (CompletelyShipped) and (NoZeroAmountLine) then begin
                            //RHE-TNA 20-04-2022 BDS-6277 END
                            Ship := SalesHdr.Ship;
                            Invoice := SalesHdr.Invoice;

                            if not SalesHdr.Ship then begin
                                SalesHdr.Validate(Ship, true);
                                SalesHdrMod := true;
                            end;
                            if not SalesHdr.Invoice then begin
                                SalesHdr.Validate(Invoice, true);
                                SalesHdrMod := true;
                            end;
                            if SalesHdrMod then
                                SalesHdr.Modify(true);

                            //Set sales lines with type = GL account with Qty. to ship to make sure the lines are posted
                            SalesLineMod := false;
                            SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
                            if SalesLine.FindSet() then
                                repeat
                                    if SalesLine."Quantity (Base)" - SalesLine."Qty. Shipped (Base)" <> SalesLine."Qty. to Ship (Base)" then begin
                                        SalesLine.Validate("Qty. to Ship", SalesLine.Quantity - SalesLine."Quantity Shipped");
                                        SalesLine.Modify(true);
                                        SalesLineMod := true;
                                    end;
                                until SalesLine.Next() = 0;

                            if SalesHdrMod or SalesLineMod then
                                Commit();

                            if PostCU.Run(SalesHdr) then begin
                                Clear(PostCU);
                                Commit();
                            end else begin
                                Clear(PostCU);
                                //Return order to original state
                                SalesHdrMod := false;
                                if SalesHdr.Ship <> Ship then begin
                                    SalesHdr.Validate(Ship, Ship);
                                    SalesHdrMod := true;
                                end;
                                if SalesHdr.Invoice <> Invoice then begin
                                    SalesHdr.Validate(Invoice, Invoice);
                                    SalesHdrMod := true;
                                end;
                                if SalesHdrMod then begin
                                    SalesHdr.Modify(true);
                                    Commit();
                                end;
                            end;
                        end;
                        //RHE-TNA 21-02-2022 BDS-6109 BEGIN
                    end;
                    //RHE-TNA 21-02-2022 BDS-6109 END
                until SalesHdr.Next() = 0;
        end;
    end;
    //RHE-TNA 21-05-2021 BDS-5323 END

    //Global Variables
    var
        WMSImportHdr: Record "WMS Import Header";
        PrevAssemblyNo: Code[20];
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
}