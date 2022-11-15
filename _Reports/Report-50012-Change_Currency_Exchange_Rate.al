report 50012 "Change Currency Exchange Rate"

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = true;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("From Currency Code"; FromCurrencyCode)
                    {
                        ApplicationArea = All;
                    }
                    field("To Currency Code"; ToCurrencyCode)
                    {
                        ApplicationArea = All;

                    }
                    field("Starting Date"; StartingDate)
                    {
                        ApplicationArea = All;

                    }
                    field("New Exchange Rate"; NewExchRate)
                    {
                        ApplicationArea = All;
                        DecimalPlaces = 2 : 6;
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        ExchangeRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
        Company: Record Company;
        ProcessReport: Boolean;
        AccessControl: Record "Access Control";
        Permission: Record Permission;
        Permission_OK: Boolean;
        Currency: Record Currency;
        CompanyNotUpdatedText: Text;
        CompanyCount: Integer;
        CompanyUpdateCount: Integer;

        //Text constants
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        /*
        DialogText001: TextConst
            ENU = 'You are going to update Exchange Rates in all companies. Are you sure you want to proceed?';
        DialogText002: TextConst
            ENU = 'Exchange Rate with Starting Date %1 allready exists in Company %2.';
        DialogText003: TextConst
            ENU = 'The following companies are not updated:';
        DialogText004: TextConst
            ENU = '%1 of %2 companies are updated';
        DialogText005: TextConst
            ENU = 'Currency Code %1 does not exist in Company %2.';
        ErrorText001: TextConst
            ENU = 'From Currency Code, To Currency Code, Starting Date and New Exchange Rate Amount should have a value.';
        ErrorText002: TextConst
            ENU = 'Process canceled.';
        */
        DialogText001: Label 'You are going to update Exchange Rates in all companies. Are you sure you want to proceed?';
        DialogText002: Label 'Exchange Rate with Starting Date %1 allready exists in Company %2.';
        DialogText003: Label 'The following companies are not updated:';
        DialogText004: Label '%1 of %2 companies are updated';
        DialogText005: Label 'Currency Code %1 does not exist in Company %2.';
        ErrorText001: Label 'From Currency Code, To Currency Code, Starting Date and New Exchange Rate Amount should have a value.';
        ErrorText002: Label 'Process canceled.';
        //RHE-TNA 21-01-2022 BDS-6037 END

    begin
        if (FromCurrencyCode = '') or (ToCurrencyCode = '') or (StartingDate = 0D) or (NewExchRate = 0) then
            Error(ErrorText001);

        ProcessReport := Confirm(DialogText001, false);
        if ProcessReport = false then
            Error(ErrorText002);

        CompanyNotUpdatedText := DialogText003;
        Company.FindSet();
        repeat
            CompanyCount := CompanyCount + 1;
            //Check if user has correct permissions to update setup
            Permission_OK := false;
            AccessControl.SetFilter("Company Name", '%1|%2', Company.Name, '');
            AccessControl.SetRange("User Security ID", UserSecurityId());
            if AccessControl.findset then begin
                Permission.ChangeCompany(Company.Name);
                repeat
                    Permission.SetRange("Role ID", AccessControl."Role ID");
                    Permission.SetRange("Object Type", Permission."Object Type"::"Table Data");
                    Permission.SetFilter("Object ID", '%1|%2', 0, 330);
                    Permission.SetRange("Modify Permission", Permission."Modify Permission"::Yes);
                    if Permission.FindFirst() then
                        Permission_OK := true;
                until (AccessControl.Next() = 0) or (Permission_OK);

                //Change setup
                If Permission_OK then begin
                    //Check if currency entered by user is not equal to standard currency of company
                    GLSetup.ChangeCompany(Company.Name);
                    GLSetup.Get();
                    if (GLSetup."LCY Code" = FromCurrencyCode) and (GLSetup."LCY Code" <> ToCurrencyCode) then begin
                        Currency.ChangeCompany(Company.Name);
                        Currency.SetRange(code, ToCurrencyCode);
                        if Currency.FindFirst() then begin
                            ExchangeRate.ChangeCompany(Company.Name);
                            ExchangeRate.SetRange("Currency Code", ToCurrencyCode);
                            ExchangeRate.SetRange("Starting Date", StartingDate);
                            if not ExchangeRate.FindFirst() then begin
                                ExchangeRate.Init();
                                ExchangeRate."Currency Code" := ToCurrencyCode;
                                ExchangeRate."Starting Date" := StartingDate;
                                ExchangeRate."Exchange Rate Amount" := NewExchRate;
                                ExchangeRate."Adjustment Exch. Rate Amount" := NewExchRate;
                                ExchangeRate."Fix Exchange Rate Amount" := ExchangeRate."Fix Exchange Rate Amount"::"Relational Currency";
                                ExchangeRate."Relational Exch. Rate Amount" := 1;
                                ExchangeRate."Relational Adjmt Exch Rate Amt" := 1;
                                ExchangeRate.Insert();
                                CompanyUpdateCount := CompanyUpdateCount + 1;
                            end else
                                Message(DialogText002, StartingDate, Company.Name);
                        end else
                            Message(DialogText005, ToCurrencyCode, Company.Name);
                    end;
                end else
                    CompanyNotUpdatedText := CompanyNotUpdatedText + '\ - ' + Company.Name;
            end;
        until Company.Next() = 0;

        if CompanyNotUpdatedText <> DialogText003 then
            Message(CompanyNotUpdatedText)
        else
            Message(DialogText004, Format(CompanyUpdateCount), Format(CompanyCount));
    end;

    //Global variables
    var
        ToCurrencyCode: Code[10];
        StartingDate: date;
        NewExchRate: Decimal;
        FromCurrencyCode: Code[10];

}