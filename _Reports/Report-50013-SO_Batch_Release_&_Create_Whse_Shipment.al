report 50013 "Release SO & Create Whse. Ship"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = true;
    ProcessingOnly = true;
    Caption = 'Sales Order Batch Release & Create Warehouse Shipment';

    dataset
    {
        dataitem(SalesHdr; "Sales Header")
        {
            DataItemTableView = sorting ("Document Type", "No.") where ("document type" = const (Order));
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                ReleaseSalesDoc: Codeunit "Release Sales Document";
                GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
            begin
                If SalesHdr.Status <> SalesHdr.Status::Released then begin
                    ReleaseSalesDoc.PerformManualRelease(SalesHdr);
                    ReleasedOrderCount := ReleasedOrderCount + 1;
                end;
                if CreateWhseShipment = true then begin
                    CreateFromSalesOrderBatch(SalesHdr);
                end;
            end;
        }


    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("Create Warehouse Shipments"; CreateWhseShipment)
                    {

                    }
                }
            }
        }
    }

    procedure CreateFromSalesOrderBatch(var SalesHdr: Record "Sales Header")
    var
        WhseRqst: Record "Warehouse Request";
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
        Location: Record Location;
        LocationCode: Text;
    begin
        //This code is copied from CU 5752 Get Source Doc. Outbound, modified to be able to run as a batch
        if (SalesHdr.Status = SalesHdr.Status::Released) and (not SalesHdr.WhseShpmntConflict(SalesHdr."Document Type", SalesHdr."No.", SalesHdr."Shipping Advice")) then begin
            GetSourceDocOutbound.CheckSalesHeader(SalesHdr, false);
            WhseRqst.SetRange(Type, WhseRqst.Type::Outbound);
            WhseRqst.SetRange("Source Type", Database::"Sales Line");
            WhseRqst.SetRange("Source Subtype", SalesHdr."Document Type");
            WhseRqst.SetRange("Source No.", SalesHdr."No.");
            WhseRqst.SetRange("Document Status", WhseRqst."Document Status"::Released);
            IF WhseRqst.FindSet then begin
                repeat
                    if Location.RequireShipment(WhseRqst."Location Code") then
                        LocationCode += WhseRqst."Location Code" + '|';
                until WhseRqst.Next = 0;
                if LocationCode <> '' then
                    LocationCode := CopyStr(LocationCode, 1, StrLen(LocationCode) - 1);
                WhseRqst.SetFilter("Location Code", LocationCode);
            end;
            CreateWarehouseShipmentBatch(WhseRqst);
        end;
    end;

    procedure CreateWarehouseShipmentBatch(var WarehouseRequest: Record "Warehouse Request")
    var
        WarehouseShipmentHdr: Record "Warehouse Shipment Header";
        GetSourceDocuments: Report "Get Source Documents";
    begin
        //This code is copied from CU 5752 Get Source Doc. Outbound, modified to be able to run as a batch
        if WarehouseRequest.FindFirst then begin
            GetSourceDocuments.UseRequestPage(false);
            GetSourceDocuments.SetTableView(WarehouseRequest);
            GetSourceDocuments.SetHideDialog(true);
            GetSourceDocuments.RunModal();
            ShipmentCreatedCount := ShipmentCreatedCount + 1;
        end;
    end;

    procedure SetParameters(var CreateWhseShip: Boolean)
    begin
        CreateWhseShipment := CreateWhseShip;
    end;

    trigger OnPostReport()
    begin
        Message(Format(ReleasedOrderCount) + ' Order(s) released. ' + Format(ShipmentCreatedCount) + ' Warehouse Shipment(s) created.');
    end;

    //Global Variables
    var
        CreateWhseShipment: Boolean;
        ReleasedOrderCount: Integer;
        ShipmentCreatedCount: Integer;

}