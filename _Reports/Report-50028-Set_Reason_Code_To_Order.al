report 50028 "Set Reason Code To Order"

//RHE-TNA 18-05-2020 BDS-4135
//  - New Report

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("Reason Code"; ReasonCode)
                    {
                        ApplicationArea = All;
                        TableRelation = "Reason Code";
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        //ErrorText001: TextConst
        //    ENU = 'Reason Code must have a value.';
        ErrorText001: Label 'Reason Code must have a value.';
        //RHE-TNA 21-01-2022 BDS-6037 END
    begin
        if ReasonCode = '' then
            Error(ErrorText001);
    end;

    trigger OnPostReport()
    var
        SalesHdr: Record "Sales Header";
    begin
        SalesHdr.Get(SalesHdr."Document Type"::Order, CurrSalesOrderNo);
        SalesHdr.Validate("Reason Code", ReasonCode);
        SalesHdr.Modify(true);
    end;

    procedure SetParameters(Var SalesOrderNo: code[20])
    begin
        CurrSalesOrderNo := SalesOrderNo;
    end;

    var
        ReasonCode: Code[10];
        CurrSalesOrderNo: code[20];
}