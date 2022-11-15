tableextension 50004 "Sales Line Extension" extends "Sales Line"

//  RHE-TNA 22-12-2021 PM-1328
//  - Added field 50002

//  RHE-TNA 04-03-2022 BDS-5565
//  - Added procedure ReserveSalesLine()
//  - Added procedure AvailableToAllocate()
//  - Added trigger OnAfterModify()
//  - Added fields 50003 and 50004

//  RHE-TNA 15-04-2022..03-06-2022 BDS-6277
//  - Modified procedure ReserveSalesLine()
//  - Added procedure CalcAvailableInventory()
//  - Added procedure CalcSalesLineAllocatedQty()
//  - Added procedure CalcAssemblyLineAllocatedQty()

{
    fields
    {
        field(50000; "Qty. Sent to WMS"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum ("Warehouse Shipment Line".Quantity where ("Source Document" = filter ("Sales Order"), "Source No." = field ("Document No."), "Source Line No." = field ("Line No."), "Exported to WMS" = const (true)));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(50001; "Obsolete Item"; Boolean)
        {
            Editable = false;
        }
        field(50002; "Customs Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
        }
        field(50003; "Allocated Qty."; Decimal)
        {

        }
        field(50004; "Allocated Manually"; Boolean)
        {

        }
    }

    trigger OnAfterModify()
    begin
        if not IsTemporary then begin
            SalesSetup.Get();
            if (SalesSetup.AllocationMandatory) and (Type = Type::Item) and (Quantity > 0) and ("Outstanding Qty. (Base)" - "Allocated Qty." <> 0) then begin
                ReserveSalesLine();
            end;
        end;
    end;

    procedure ReserveSalesLine()
    var
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        QtyToAllocate: Decimal;
        QtyAvailableToAllocate: Decimal;
        Item: Record Item;
    begin
        SalesSetup.Get();
        if SalesSetup.AllocationMandatory then begin
            //This function checks if order lines can be reserved against stock.

            //Loop through allocated lines to check if allocated qty needs to be lowered.
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            if SalesLine.FindSet() then
                repeat
                    //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                    //if SalesLine."Outstanding Qty. (Base)" < SalesLine."Allocated Qty." then begin
                    Item.Get(SalesLine."No.");
                    if (Item.Type = Item.Type::Inventory) and (SalesLine."Outstanding Qty. (Base)" < SalesLine."Allocated Qty.") then begin
                        //RHE-TNA 15-04-2022 BDS-6277 END
                        Validate("Allocated Qty.", SalesLine."Outstanding Qty. (Base)");
                        SalesLine.Modify();
                    end;
                until SalesLine.Next() = 0;

            //Reset allocated quantity on lines which are not manually set          
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetRange("Allocated Manually", false);
            SalesLine.SetFilter("Allocated Qty.", '>%1', 0);
            if SalesLine.FindSet() then
                repeat
                    //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                    Item.Get(SalesLine."No.");
                    if Item.Type = Item.Type::Inventory then begin
                        //RHE-TNA 15-04-2022 BDS-6277 END
                        SalesHdr.Get(SalesLine."Document Type", SalesLine."Document No.");
                        if SalesHdr.Status <> SalesHdr.Status::Released then begin
                            SalesLine.Validate("Allocated Qty.", 0);
                            SalesLine.Modify(false);
                        end;
                        //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                    end;
                    //RHE-TNA 15-04-2022 BDS-6277 END
                until SalesLine.Next() = 0;

            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetRange("Allocated Manually", false);
            SalesLine.SetFilter("Outstanding Qty. (Base)", '>%1', 0);
            //To make sure the first ordered order gets reserved first, always all orders are checked sorted by "Order Date 2", which equals "Order Date".
            SalesHdr.SetCurrentKey("Order Date 2");
            SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
            SalesHdr.SetRange(Status, SalesHdr.Status::Open);
            if SalesHdr.FindSet() then
                repeat
                    SalesLine.SetRange("Document No.", SalesHdr."No.");
                    if SalesLine.FindSet() then
                        repeat
                            //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                            //if SalesLine."Outstanding Qty. (Base)" < SalesLine."Allocated Qty." then begin
                            Item.Get(SalesLine."No.");
                            if Item.Type = Item.Type::Inventory then begin
                                //RHE-TNA 15-04-2022 BDS-6277 END
                                QtyToAllocate := SalesLine."Outstanding Qty. (Base)" - SalesLine."Allocated Qty.";
                                if QtyToAllocate > 0 then begin
                                    QtyAvailableToAllocate := AvailableToAllocate(SalesLine);
                                    if QtyAvailableToAllocate > 0 then begin
                                        if QtyToAllocate <= QtyAvailableToAllocate then
                                            SalesLine.Validate("Allocated Qty.", QtyToAllocate + SalesLine."Allocated Qty.")
                                        else
                                            SalesLine.Validate("Allocated Qty.", QtyAvailableToAllocate + SalesLine."Allocated Qty.");
                                        SalesLine.Modify();
                                    end;
                                end;
                                //RHE-TNA 15-04-2022 BDS-6277 BEGIN
                            end;
                            //RHE-TNA 15-04-2022 BDS-6277 END
                        until SalesLine.Next() = 0;
                until SalesHdr.Next() = 0;
            SalesHdr.SetFullyAllocated();
        end;
    end;

    procedure AvailableToAllocate(var SalesLine: Record "Sales Line"): Decimal
    var
        SalesLine2: Record "Sales Line";
        ILE: Record "Item Ledger Entry";
        QtyAvailableToAllocate: Decimal;
        Item: Record Item;
        BomComponent: Record "BOM Component";
        QtyAvailableToAllocateComp: Decimal;
        InvAvailable: Decimal;
        QtyAllocatedSales: Decimal;
        QtyAllocatedAssembly: Decimal;
    begin
        //RHE-TNA 03-06-2022 BDS-6277 BEGIN 
        /*
        //Calc inventory
        ILE.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
        ILE.SetRange("Item No.", SalesLine."No.");
        ILE.SetRange("Location Code", SalesLine."Location Code");
        ILE.SetFilter("Remaining Quantity", '>%1', 0);
        ILE.CalcSums("Remaining Quantity");
        QtyAvailableToAllocate := ILE."Remaining Quantity";
        
        //Calc allocated quantity sales order lines
        SalesLine2.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine2.SetRange(Type, SalesLine.Type::Item);
        SalesLine2.SetRange("No.", SalesLine."No.");
        SalesLine2.SetFilter("Allocated Qty.", '>%1', 0);
        SalesLine2.SetFilter("Outstanding Qty. (Base)", '>%1', 0);
        if SalesLine2.FindSet() then
            repeat
                if SalesLine2."Outstanding Qty. (Base)" - SalesLine2."Allocated Qty." < 0 then
                    //Partially shipped
                    QtyAvailableToAllocate -= (SalesLine2."Allocated Qty." - SalesLine2."Outstanding Qty. (Base)")
                else
                    QtyAvailableToAllocate -= SalesLine2."Allocated Qty.";
            until SalesLine2.Next() = 0;

        exit(QtyAvailableToAllocate);
        */

        Item.Get(SalesLine."No.");
        case Item."Replenishment System" of
            Item."Replenishment System"::Purchase:
                begin
                    InvAvailable := CalcAvailableInventory(Item."No.", SalesLine."Location Code");
                    QtyAllocatedSales := CalcSalesLineAllocatedQty(Item."No.", SalesLine."Location Code");
                    QtyAllocatedAssembly := CalcAssemblyLineAllocatedQty(Item."No.", SalesLine."Location Code");

                    QtyAvailableToAllocate := InvAvailable - QtyAllocatedSales - QtyAllocatedAssembly;
                    exit(QtyAvailableToAllocate);
                end;
            Item."Replenishment System"::Assembly:
                begin
                    if Item."Assembly Policy" = Item."Assembly Policy"::"Assemble-to-Order" then begin
                        QtyAvailableToAllocate := SalesLine.Quantity;
                        BomComponent.SetRange("Parent Item No.", Item."No.");
                        BomComponent.SetRange(Type, BomComponent.Type::Item);
                        BomComponent.SetRange("Exclude in Ass. Order Creation", false);
                        if BomComponent.FindSet() then
                            repeat
                                InvAvailable := CalcAvailableInventory(BomComponent."No.", SalesLine."Location Code");
                                QtyAllocatedSales := CalcSalesLineAllocatedQty(BomComponent."No.", SalesLine."Location Code");
                                QtyAllocatedAssembly := CalcAssemblyLineAllocatedQty(BomComponent."No.", SalesLine."Location Code");

                                QtyAvailableToAllocateComp := InvAvailable - QtyAllocatedSales - QtyAllocatedAssembly;
                                if (QtyAvailableToAllocateComp / BomComponent."Quantity per") < QtyAvailableToAllocate then
                                    QtyAvailableToAllocate := QtyAvailableToAllocateComp / BomComponent."Quantity per";
                            until BomComponent.Next() = 0;
                    end else begin
                        InvAvailable := CalcAvailableInventory(Item."No.", SalesLine."Location Code");
                        QtyAllocatedSales := CalcSalesLineAllocatedQty(Item."No.", SalesLine."Location Code");
                        QtyAllocatedAssembly := CalcAssemblyLineAllocatedQty(Item."No.", SalesLine."Location Code");

                        QtyAvailableToAllocate := InvAvailable - QtyAllocatedSales - QtyAllocatedAssembly;
                    end;

                    exit(QtyAvailableToAllocate);
                end;
        end;
        //RHE-TNA 03-06-2022 BDS-6277 END
    end;


    procedure CalcAvailableInventory(var ItemNo: Code[20]; var Location: Code[10]): Decimal
    var
        ILE: Record "Item Ledger Entry";
        QtyAvailable: Decimal;
    begin
        ILE.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
        ILE.SetRange("Item No.", ItemNo);
        ILE.SetRange("Location Code", Location);
        ILE.SetFilter("Remaining Quantity", '>%1', 0);
        ILE.CalcSums("Remaining Quantity");
        QtyAvailable := ILE."Remaining Quantity";

        exit(QtyAvailable);
    end;

    procedure CalcSalesLineAllocatedQty(var ItemNo: Code[20]; Location: Code[10]): Decimal
    var
        SalesLine: Record "Sales Line";
        QtyAllocated: Decimal;
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", ItemNo);
        SalesLine.SetRange("Location Code", Location);
        SalesLine.SetFilter("Allocated Qty.", '>%1', 0);
        SalesLine.SetFilter("Outstanding Qty. (Base)", '>%1', 0);
        if SalesLine.FindSet() then
            repeat
                if SalesLine."Outstanding Qty. (Base)" - SalesLine."Allocated Qty." < 0 then
                    //Partially shipped
                    QtyAllocated += (SalesLine."Allocated Qty." - SalesLine."Outstanding Qty. (Base)")
                else
                    QtyAllocated += SalesLine."Allocated Qty.";
            until SalesLine.Next() = 0;

        exit(QtyAllocated);
    end;

    procedure CalcAssemblyLineAllocatedQty(var ItemNo: Code[20]; Location: Code[10]): Decimal
    var
        AssemblyLine: Record "Assembly Line";
        ATOLink: Record "Assemble-to-Order Link";
        SalesLine: Record "Sales Line";
        QtyAllocatedAssembly: Decimal;
    begin
        AssemblyLine.SetRange("Document Type", AssemblyLine."Document Type"::Order);
        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        AssemblyLine.SetRange("No.", ItemNo);
        if AssemblyLine.FindSet() then
            repeat
                ATOLink.SetRange("Assembly Document Type", ATOLink."Assembly Document Type"::Order);
                ATOLink.SetRange(Type, ATOLink.Type::Sale);
                ATOLink.SetRange("Assembly Document No.", AssemblyLine."Document No.");
                ATOLink.SetRange("Document Type", ATOLink."Document Type"::Order);
                if ATOLink.FindFirst() then begin
                    SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                    SalesLine.SetRange("Document No.", ATOLink."Document No.");
                    SalesLine.SetRange("Line No.", ATOLink."Document Line No.");
                    if SalesLine.FindFirst() then
                        repeat
                            if SalesLine."Outstanding Qty. (Base)" - SalesLine."Allocated Qty." < 0 then
                                //Partially shipped
                                QtyAllocatedAssembly += ((SalesLine."Allocated Qty." - SalesLine."Outstanding Qty. (Base)") * AssemblyLine."Quantity per")
                            else
                                QtyAllocatedAssembly += (SalesLine."Allocated Qty." * AssemblyLine."Quantity per");
                        until SalesLine.Next() = 0;
                end;
            until AssemblyLine.Next() = 0;

        exit(QtyAllocatedAssembly);
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
}