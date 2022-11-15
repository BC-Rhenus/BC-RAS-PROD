codeunit 50000 "Events"

//RHE-TNA 06-05-2020..02-06-2020 BDS-4135
//  - Added EventSubScriber to Page 42
//    --> local procedure CheckReasonCode()

//  RHE-TNA 21-07-2020 BDS-4323
//  - Added EventSubscriber to Codeunit, Codeunit::"Item Jnl.-Post"
//    --> local procedure SetHideDialog(

//  RHE-TNA 21-06-2021 BDS-5385
//  - Added EventSubScriber to Table 5741
//    --> local procedure UpdateLineAmount()

//  RHE-TNA 17-11-2021..27-12-2021 BDS-5676 
//  - Added EventSubscribers to Codeunit, Codeunit::"Release Sales Document"
//    --> local procedure BeforeManualReleaseUpdate()
//    --> local procedure AfterManualReleaseUpdate()

//  RHE-TNA 29-11-2021 BDS-5891
//  - Added EventSubScribers to Table 36
//    --> local procedure SetInvoiceNoSeries()
//    --> local procedure SetInvoiceNoSeries2()

//  RHE-TNA 22-12-2021..24-12-2021 PM-1328
//  - Added Procedure SetCustomsPrice
//  - Changed EventSubscriber(ObjectType::Table, 37)

//  RHE-TNA 17-01-2022 BDS-5565
//  - Restructured Codeunit
//  - Added EventSubScriber to Table 36
//    --> local procedure SetAdditionalFields()

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

//  RHE-TNA 15-02-2022 BDS-6149
//  - Modified local procedure BeforeManualReleaseUpdate()
//  - Modified local procedure AfterManualReleaseUpdate()

//  RHE-TNA 03-03-2022 BDS-5564
//  - Added EventSubScriber to Codeunit, Codeunit::"Release Sales Document" 
//    --> local procedure CheckCompletelyReserved()

//  RHE-TNA 19-05-2022 BDS-6111
//  - Added EventSubscriber to Tabel 37
//    --> procedure CheckExceptionList()

{
    //Item Events
    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, true)]
    procedure "Update Item Blocked Status"(var Rec: Record Item)
    begin
        if not Rec.IsTemporary then
            if Rec.Blocked = false then begin
                Rec.Validate(Blocked, true);
                Rec.Validate("Sales Blocked", true);
                Rec.Validate("Purchasing Blocked", true);
                Rec.Validate("Block Reason", 'Automatically Blocked at creation.');
                Rec.Modify(true);
            end;
    end;

    //Assembly Order Events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly Line Management", 'OnBeforeUpdateAssemblyLines', '', true, true)]
    procedure UpdateAssemblyHdr(var AsmHeader: Record "Assembly Header")
    var
        Item: Record Item;
    begin
        //Set Gen. Prod. Posting Group on Header level
        Item.Get(AsmHeader."Item No.");
        Item.TestField("Ass. Gen. Prod. Posting Group");
        if AsmHeader."Gen. Prod. Posting Group" <> Item."Ass. Gen. Prod. Posting Group" then
            AsmHeader.Validate("Gen. Prod. Posting Group", Item."Ass. Gen. Prod. Posting Group");
    end;

    [EventSubscriber(ObjectType::Table, 904, 'OnAfterUpdateAsm', '', true, true)]
    procedure UpdateAssemblyLine(AsmHeader: Record "Assembly Header")
    var
        Item: Record Item;
        AssemblyLine: Record "Assembly Line";
        BomComponent: Record "BOM Component";
    begin
        //Set Gen. Prod. Posting Group on Line level
        AssemblyLine.SetRange("Document Type", AssemblyLine."Document Type"::Order);
        AssemblyLine.SetRange("Document No.", AsmHeader."No.");
        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        if AssemblyLine.FindSet() then
            repeat
                BomComponent.SetRange("Parent Item No.", AsmHeader."Item No.");
                BomComponent.SetRange(Type, BomComponent.Type::Item);
                BomComponent.SetRange("No.", AssemblyLine."No.");
                if (BomComponent.FindFirst()) and (BomComponent."Exclude in Ass. Order Creation") then
                    AssemblyLine.Delete(true)
                else begin
                    Item.Get(AssemblyLine."No.");
                    Item.TestField("Ass. Gen. Prod. Posting Group");
                    if AssemblyLine."Gen. Prod. Posting Group" <> item."Ass. Gen. Prod. Posting Group" then begin
                        AssemblyLine.Validate("Gen. Prod. Posting Group", Item."Ass. Gen. Prod. Posting Group");
                        AssemblyLine.Modify(true);
                    end;
                end;
            until AssemblyLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnAfterPostedAssemblyHeaderModify', '', true, true)]
    procedure SetCustomerName(var PostedAssemblyHeader: Record "Posted Assembly Header")
    var
        PostedATOLink: Record "Posted Assemble-to-Order Link";
        SalesShipmentHdr: Record "Sales Shipment Header";
    begin
        if PostedATOLink.Get(PostedATOLink."Assembly Document Type"::Assembly, PostedAssemblyHeader."No.") then begin
            if SalesShipmentHdr.Get(PostedATOLink."Document No.") then begin
                PostedAssemblyHeader."Sales Order No." := PostedATOLink."Order No.";
                PostedAssemblyHeader."Customer Name" := SalesShipmentHdr."Sell-to Customer Name";
                PostedAssemblyHeader.Modify(false);
            end;
        end;
    end;

    //Sales Line Events
    [EventSubscriber(ObjectType::Table, 37, 'OnValidateNoOnAfterUpdateUnitPrice', '', true, true)]
    procedure SalesLineEvent(var SalesLine: Record "Sales Line")
    begin
        CheckObsoleteItem(SalesLine);
        SetCustomsPrice(SalesLine);
    end;

    procedure CheckObsoleteItem(var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //MessageText001: TextConst
        //    ENU = 'Item %1 is marked as obsolete. Check if a Substition is available.';
        MessageText001: Label 'Item %1 is marked as obsolete. Check if a Substition is available.';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        if SalesLine.Type = SalesLine.Type::Item then begin
            if (Item.Get(SalesLine."No.")) and (Item."Obsolete Item") then begin
                SalesLine.Validate("Obsolete Item", true);
                if GuiAllowed then
                    Message(MessageText001, SalesLine."No.");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterUpdateUnitPrice', '', true, true)]
    procedure SetCustomsPrice(var SalesLine: Record "Sales Line")
    var
        Customer: Record Customer;
        SalesPrice: Record "Sales Price";
    begin
        if SalesLine.Type = SalesLine.Type::Item then begin
            if (Customer.Get(SalesLine."Sell-to Customer No.")) and (Customer."Customs Price Group" <> '') then begin
                SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
                SalesPrice.SetRange("Sales Code", Customer."Customs Price Group");
                SalesPrice.SetRange("Item No.", SalesLine."No.");
                SalesPrice.SetRange("Currency Code", SalesLine."Currency Code");
                SalesPrice.SetRange("Unit of Measure Code", SalesLine."Unit of Measure Code");
                SalesPrice.SetFilter("Starting Date", '%1|<=%2', 0D, Today);
                SalesPrice.SetFilter("Ending Date", '%1|>%2', 0D, Today);
                SalesPrice.SetFilter("Minimum Quantity", '<=%1', SalesLine.Quantity);
                if SalesPrice.FindLast() then begin
                    if not SalesPrice."Price Includes VAT" then
                        SalesLine.Validate("Customs Price", SalesPrice."Unit Price")
                    else
                        SalesLine.Validate("Customs Price", SalesPrice."Unit Price" / (100 + SalesLine."VAT %") * 100);
                end else
                    SalesLine.Validate("Customs Price", 0);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnValidateNoOnBeforeInitRec', '', true, true)]
    procedure CheckExceptionList(var SalesLine: Record "Sales Line")
    var
        ShipToAddress: Record "Ship-to Address";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
        AssortmentCheckLevel: Option Customer,"Ship-to Address";
        Assortment: Record Assortment;
        ErrorLbl1: Label 'Item %1 cannot be ordered by Ship-to Code %2.';
        ErrorLbl2: Label 'Item %1 cannot be ordered by Sell-to Customer No. %2.';
    begin
        if SalesLine.Type = SalesLine.Type::Item then begin
            SalesSetup.Get();
            SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
            if (SalesHeader."Ship-to Code" <> '') and (ShipToAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code")) and (ShipToAddress."Assortment/Exception Group" <> '') then
                AssortmentCheckLevel := AssortmentCheckLevel::"Ship-to Address"
            else
                AssortmentCheckLevel := AssortmentCheckLevel::Customer;

            Assortment.SetRange("Item No.", SalesLine."No.");
            Assortment.SetFilter("Starting Date", '%1|<=%2', 0D, Today);
            Assortment.SetFilter("Ending Date", '%1|>%2', 0D, Today);
            case AssortmentCheckLevel of
                AssortmentCheckLevel::"Ship-to Address":
                    begin
                        Assortment.SetRange("Assortment Group", ShipToAddress."Assortment/Exception Group");
                        //Items in list cannot be ordered
                        if (SalesSetup."Order Item Check" = SalesSetup."Order Item Check"::"Item in Assortment/Exception List Not Allowed") and (Assortment.FindFirst()) then
                            Error(ErrorLbl1, SalesLine."No.", SalesHeader."Ship-to Code");
                        //Only Items in list can be ordered
                        if (SalesSetup."Order Item Check" = SalesSetup."Order Item Check"::"Item in Assortment/Exception List Allowed") and (not Assortment.FindFirst()) then
                            Error(ErrorLbl1, SalesLine."No.", SalesHeader."Ship-to Code");
                    end;
                AssortmentCheckLevel::Customer:
                    begin
                        Customer.Get(SalesHeader."Sell-to Customer No.");
                        Assortment.SetRange("Assortment Group", Customer."Assortment/Exception Group");
                        //Items in list cannot be ordered
                        if (SalesSetup."Order Item Check" = SalesSetup."Order Item Check"::"Item in Assortment/Exception List Not Allowed") and (Assortment.FindFirst()) then
                            Error(ErrorLbl2, SalesLine."No.", SalesHeader."Sell-to Customer No.");
                        //Only Items in list can be ordered
                        if (SalesSetup."Order Item Check" = SalesSetup."Order Item Check"::"Item in Assortment/Exception List Allowed") and (not Assortment.FindFirst()) then
                            Error(ErrorLbl2, SalesLine."No.", SalesHeader."Sell-to Customer No.");
                    end;
            end;
        end;
    end;

    //Warehouse Shipment Events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment (Yes/No)", 'OnBeforeConfirmWhseShipmentPost', '', true, true)]
    procedure CheckWMSShipment(var WhseShptLine: Record "Warehouse Shipment Line")
    var
        WhseShptHdr: Record "Warehouse Shipment Header";
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //MessageText001: TextConst
        //    ENU = 'Warehouse Shipment %1 is not sent to WMS, are you sure you want to Post this shipment?';
        MessageText001: Label 'Warehouse Shipment %1 is not sent to WMS, are you sure you want to Post this shipment?';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        WhseShptHdr.Get(WhseShptLine."No.");
        if not WhseShptHdr."Exported to WMS" then
            if GuiAllowed then
                if not Dialog.Confirm(MessageText001, false, WhseShptHdr."No.") then
                    Error('Process canceled.');
    end;

    //Sales Header Events
    [EventSubscriber(ObjectType::Page, 42, 'OnDeleteRecordEvent', '', true, true)]
    local procedure CheckReasonCode(var Rec: Record "Sales Header")
    var
        SalesSetup: Record "Sales & Receivables Setup";
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Reason Code must have a value.';
        ErrorText001: Label 'Reason Code must have a value.';
        //RHE-TNA 21-01-2022 BDS-6037 END
        UpdateOrder: Report "Set Reason Code To Order";
        Rec2: Record "Sales Header";
    begin
        SalesSetup.Get();
        if SalesSetup."Archive Orders" then begin
            Rec2 := Rec;
            Rec.Validate("Reason Code", '');
            Rec.Modify(true);
            Commit();
            UpdateOrder.SetParameters(Rec."No.");
            UpdateOrder.RunModal();
            Rec.Get(rec."Document Type"::Order, Rec2."No.");
            if Rec."Reason Code" = '' then
                Error(ErrorText001);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeManualReleaseSalesDoc', '', true, true)]
    local procedure CheckCompletelyReserved(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHdr: Record "Sales Header";
    begin
        SalesSetup.Get();
        if (not PreviewMode) and (SalesSetup.AllocationMandatory) then begin
            SalesHeader.SetFullyAllocated();
            SalesHdr.Get(SalesHeader."Document Type", SalesHeader."No.");
            if not SalesHdr."Completely Allocated" then
                Error('Order ' + SalesHdr."No." + ' is not completely allocated against stock.');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeManualReleaseSalesDoc', '', true, true)]
    local procedure BeforeManualReleaseUpdate(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        IFSetup: Record "Interface Setup";
        SalesHdrArchive: Record "Sales Header Archive";
        ArchiveMgt: Codeunit ArchiveManagement;
        IFLog: Record "Interface Log";
        SendOrder: Boolean;
    begin
        //Check whether order should be exported and check if EDI status is set accordingly
        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) and (SalesHeader.SalesLinesExist()) then
            if (IFSetup.Get(IFSetup.GetIFSetupRecforDocNo(SalesHeader."No."))) and (IFSetup."Send Sales Order Message") then begin
                //RHE-TNA 01-03-2022 BDS-6149 BEGIN
                SendOrder := true;
                //Do not send orders which are received via interface when they do not need to be send back to the customer
                IFLog.SetRange(Direction, IFLog.Direction::"From Customer");
                IFLog.SetRange(Reference, SalesHeader."No.");
                if IFLog.FindFirst() then
                    if not IFSetup."Send IF Received Orders" then
                        SendOrder := false;

                if SendOrder then begin
                    //RHE-TNA 01-03-2022 BDS-6149 END
                    if (SalesHeader."EDI status" = SalesHeader."EDI status"::" ") then
                        if not Confirm('By releasing the order, the EDI status will be set with "To Send". \Are you sure you want to continue?') then
                            Error('Release process cancelled.')
                        else begin
                            SalesHeader."EDI Status" := SalesHeader."EDI Status"::"To Send";
                            SalesHeader.Modify();
                        end;

                    //Update sales order archive to not send an old version via EDI
                    SalesHdrArchive.SetRange("Document Type", SalesHeader."Document Type");
                    SalesHdrArchive.SetRange("No.", SalesHeader."No.");
                    SalesHdrArchive.SetRange("EDI Status", SalesHdrArchive."EDI Status"::"To Send");
                    SalesHdrArchive.ModifyAll("EDI Status", SalesHdrArchive."EDI Status"::" ");

                    //Create new archived version and reset EDI fields
                    if SalesHeader.Status <> SalesHeader.Status::Released then begin
                        ArchiveMgt.StoreSalesDocument(SalesHeader, false);
                        SalesHdrArchive.Reset();
                        SalesHdrArchive.SetRange("Document Type", SalesHeader."Document Type");
                        SalesHdrArchive.SetRange("No.", SalesHeader."No.");
                        SalesHdrArchive.FindLast();
                        SalesHdrArchive."EDI Status" := SalesHdrArchive."EDI Status"::"To Send";
                        SalesHdrArchive."Last EDI Export Date/Time" := 0DT;
                        SalesHdrArchive.Modify();
                    end;
                    //RHE-TNA 01-03-2022 BDS-6149 BEGIN
                end;
                //RHE-TNA 01-03-2022 BDS-6149 END
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterManualReleaseSalesDoc', '', true, true)]
    local procedure AfterManualReleaseUpdate(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        IFSetup: Record "Interface Setup";
        ArchiveMgt: Codeunit ArchiveManagement;
        SalesHdrArchive: Record "Sales Header Archive";
        IFLog: Record "Interface Log";
        SendOrder: Boolean;
    begin
        //Check whether order should be exported and create new archived version
        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) and (SalesHeader.SalesLinesExist()) then
            if (IFSetup.Get(IFSetup.GetIFSetupRecforDocNo(SalesHeader."No."))) and (IFSetup."Send Sales Order Message") then begin
                //RHE-TNA 01-03-2022 BDS-6149 BEGIN
                SendOrder := true;
                //Do not send orders which are received via interface when they do not need to be send back to the customer
                IFLog.SetRange(Direction, IFLog.Direction::"From Customer");
                IFLog.SetRange(Reference, SalesHeader."No.");
                if IFLog.FindFirst() then
                    if not IFSetup."Send IF Received Orders" then
                        SendOrder := false;

                if SendOrder then begin
                    //RHE-TNA 01-03-2022 BDS-6149 END
                    ArchiveMgt.StoreSalesDocument(SalesHeader, false);
                    SalesHdrArchive.SetRange("Document Type", SalesHeader."Document Type");
                    SalesHdrArchive.SetRange("No.", SalesHeader."No.");
                    SalesHdrArchive.FindLast();
                    SalesHdrArchive."EDI Status" := SalesHdrArchive."EDI Status"::"To Send";
                    SalesHdrArchive."Last EDI Export Date/Time" := 0DT;
                    SalesHdrArchive.Modify();
                    //RHE-TNA 01-03-2022 BDS-6149 BEGIN
                end;
                //RHE-TNA 01-03-2022 BDS-6149 END
            end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCheckSellToCust', '', true, true)]
    local procedure SetInvoiceNoSeries(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    if (Customer."Invoice No. Series" <> '') and (Customer."Invoice No. Series" <> SalesHeader."Posting No. Series") then
                        SalesHeader."Posting No. Series" := Customer."Invoice No. Series";
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    if (Customer."Credit Memo No. Series" <> '') and (Customer."Credit Memo No. Series" <> SalesHeader."Posting No. Series") then
                        SalesHeader."Posting No. Series" := Customer."Credit Memo No. Series";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCheckBillToCust', '', true, true)]
    local procedure SetInvoiceNoSeries2(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        //Perform procedure as no. series are updated in the order once the Bill-to customer is validated
        SetInvoiceNoSeries(SalesHeader, Customer);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInsertEvent', '', true, true)]
    local procedure SetAdditionalFields(var Rec: Record "Sales Header")
    begin
        Rec."Order Date 2" := Rec."Order Date";
        Rec.Modify(false);
    end;


    //Item Journal Events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', true, true)]
    local procedure SetHideDialog(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean)
    begin
        if ItemJournalLine.HideDialog then
            HideDialog := true;
    end;

    //Transfer Line Events
    [EventSubscriber(ObjectType::Table, 5741, 'OnValidateQuantityOnBeforeTransLineVerifyChange', '', true, true)]
    local procedure UpdateLineAmount(var TransferLine: Record "Transfer Line")
    begin
        Transferline.Validate("Line Amount", TransferLine.Quantity * TransferLine."Unit Price")
    end;
}