pageextension 50032 "Sales Order Ext" extends "Sales Order List"

//  RHE-TNA 28-12-2020 BDS-4644
//  - added actions addafter("Pick Instruction")

//  RHE-TNA 16-11-2021 BDS-5676
//  - Added field "EDI status"
//  - Added field "Last EDI Export Date/Time"

//  RHE-TNA 24-02-2022 BDS-6140
//  - Added actions addafter("Delete Invoiced")

//  RHE-TNA 03-03-2022 BDS-5564
//  - Added field "Completely Reserved"
//  - Added trigger OnOpenPage()

{
    layout
    {
        addafter(Status)
        {
            field(Substatus; Substatus)
            {

            }
            field("Your Reference"; "Your Reference")
            {

            }
            field("Order Date"; "Order Date")
            {

            }
            //RHE-TNA 16-11-2021 BDS-5676 BEGIN
            field("EDI status"; "EDI status")
            {

            }
            field("Last EDI Export Date/Time"; "Last EDI Export Date/Time")
            {

            }
            field("Completely Allocated"; "Completely Allocated")
            {

            }
        }
    }

    actions
    {
        addafter(Release)
        {
            action("Batch Release & Create Whse. Shipment")
            {
                Image = ExecuteBatch;
                Ellipsis = true;

                trigger OnAction();
                var
                    BatchRelease: Report "Release SO & Create Whse. Ship";
                    SalesHdr: Record "Sales Header";
                begin
                    SalesHdr.SetRange("Document Type", rec."Document Type");
                    SalesHdr.SetRange("No.", rec."No.");
                    BatchRelease.SetTableView(SalesHdr);
                    BatchRelease.RunModal;
                    Clear(BatchRelease);
                end;
            }
        }
        //RHE-TNA 28-12-2020 BDS-4644 BEGIN
        addafter("Pick Instruction")
        {
            action("Consolidated Customs Invoice")
            {
                Image = Print;
                Ellipsis = true;
                trigger OnAction()
                var
                    ConsCustomsInvoice: Report "Consolidated Customs Invoice";
                begin
                    ConsCustomsInvoice.Run();
                end;
            }
        }
        //RHE-TNA 28-12-2020 BDS-4644 END
        //RHE-TNA 24-02-2022 BDS-6140 BEGIN
        addafter("Delete Invoiced")
        {
            action("Upload Orders From Excel")
            {
                Image = Import;
                Ellipsis = true;
                trigger OnAction()
                var
                    UploadReport: Report "Upload Sales Order";
                begin
                    UploadReport.Run();
                end;
            }
        }
        //RHE-TNA 24-02-2022 BDS-6140 END
    }

    trigger OnOpenPage()
    begin
        Rec.SetFullyAllocated();
    end;
}