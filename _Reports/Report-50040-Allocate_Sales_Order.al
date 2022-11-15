//  RHE-TNA 03-03-2022 BDS-5565
//  - New Report

report 50040 "Allocate Sales Orders"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = false;
    ProcessingOnly = true;

    trigger OnPostReport()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesSetup.Get();
        if SalesSetup.AllocationMandatory then begin
            SalesLine.ReserveSalesLine();
        end;

        if GuiAllowed then
            Message('Process finished.');
    end;
}