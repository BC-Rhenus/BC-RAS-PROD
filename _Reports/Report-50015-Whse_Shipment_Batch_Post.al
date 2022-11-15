report 50015 "Whse. Shipment Batch Post"

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreReport()

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                WhseShipmentLine: Record "Warehouse Shipment Line";
                WhseShipmentPost: Codeunit "Whse.-Post Shipment";
            begin
                //First check if shipment lines are present with Qty. to ship = 0 and ask user to confirm posting of shipment
                WhseShipmentLine.Reset();
                WhseShipmentLine.SetRange("No.", "Warehouse Shipment Header"."No.");
                WhseShipmentLine.SetRange("Qty. to Ship", 0);
                if WhseShipmentLine.FindFirst() then
                    if not Dialog.Confirm('Shipment lines with Qty. to Ship = 0 are present, do you still want to post this shipment?') then
                        CurrReport.Skip();

                //Post shipment and invoice if allowed
                WhseShipmentLine.Reset();
                WhseShipmentLine.SetRange("No.", "Warehouse Shipment Header"."No.");
                if WhseShipmentLine.FindFirst() then begin
                    WhseShipmentPost.SetPostingSettings(SalesSetup.AllowInvPosting);
                    WhseShipmentPost.SetPrint(false);
                    WhseShipmentPost.Run(WhseShipmentLine);
                    Clear(WhseShipmentPost);
                end;
                PostedShipmentsCount := PostedShipmentsCount + 1;
            end;

            trigger OnPostDataItem()
            var
                //RHE-TNA 21-01-2022 BDS-6037 BEGIN
                //CountMessage: TextConst ENU = '%1 shipments are posted.';
                CountMessage: Label '%1 shipments are posted.';
                //RHE-TNA 21-01-2022 BDS-6037 END
            begin
                Message(CountMessage, PostedShipmentsCount);
            end;
        }
    }

    trigger OnPreReport()
    begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        //RHE-TNA 14-06-2021 BDS-5337 END
        SalesSetup.Get();
    end;

    //Global Variables
    var
        IFSetup: Record "Interface Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        PostedShipmentsCount: Integer;
}