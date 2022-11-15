report 50011 "Change Posting Date Setup"

//  RHE-TNA 21-01-2022 BDS-6037
//  - Changed diverse TextConst into Label

{
    UsageCategory = Tasks;
    ApplicationArea = All;
    UseRequestPage = true;
    ProcessingOnly = true;

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("Update General Ledger Setup"; ChangeGLSetup)
                    {
                        ApplicationArea = All;

                    }
                    field("Update User Setup"; ChangeUserSetup)
                    {
                        ApplicationArea = All;

                    }
                    field("New 'Allow Posting From' Date"; NewAllowPostingFromDate)
                    {
                        ApplicationArea = All;

                    }
                    field("New 'Allow Posting To' Date"; NewAllowPostingToDate)
                    {
                        ApplicationArea = All;

                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        GLSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        UpdateDateFrom: Boolean;
        UpdateDateTo: Boolean;
        Company: Record Company;
        AccessControl: Record "Access Control";
        Permission: Record Permission;
        Permission_GL_OK: Boolean;
        Permission_User_OK: Boolean;
        Permission_Total_OK: Boolean;
        CompanyNotUpdatedText: Text;

        //Text constants
        //RHE-TNA 21-01-2022 BDS-6037 BEGIN
        /*
        DialogText001: TextConst
            ENU = '"Allow Posting From" is empty, do you want to use this value?\(choose "No" to keep current value in settings)';
        DialogText002: TextConst
            ENU = '"Allow Posting To" is empty, do you want to use this value?\(choose "No" to keep current value in settings)';
        DialogText003: TextConst
            ENU = 'The following companies (setup) are not updated:';
        DialogText004: TextConst
            ENU = 'All companies are updated';
        ErrorText001: TextConst
            ENU = '"Update General Ledger Setup" and/or "Update User Setup" should be choosen.';
        ErrorText002: TextConst
            ENU = '"Allow Posting To" (%1) cannot be earlier than "Allow Posting From" (%2).';
        */
        DialogText001: Label '"Allow Posting From" is empty, do you want to use this value?\(choose "No" to keep current value in settings)';
        DialogText002: Label '"Allow Posting To" is empty, do you want to use this value?\(choose "No" to keep current value in settings)';
        DialogText003: Label 'The following companies (setup) are not updated:';
        DialogText004: Label 'All companies are updated';
        ErrorText001: Label '"Update General Ledger Setup" and/or "Update User Setup" should be choosen.';
        ErrorText002: Label '"Allow Posting To" (%1) cannot be earlier than "Allow Posting From" (%2).';
        //RHE-TNA 21-01-2022 BDS-6037 END

    begin
        if (ChangeGLSetup = false) and (ChangeUserSetup = false) then
            Error(ErrorText001);
        if ((NewAllowPostingFromDate <> 0D) and (NewAllowPostingToDate <> 0D) and (NewAllowPostingToDate < NewAllowPostingFromDate)) then
            Error(ErrorText002, NewAllowPostingToDate, NewAllowPostingFromDate);

        UpdateDateFrom := true;
        UpdateDateTo := true;
        if NewAllowPostingFromDate = 0D then
            UpdateDateFrom := Confirm(DialogText001, false);
        if NewAllowPostingToDate = 0D then
            UpdateDateTo := Confirm(DialogText002, false);

        CompanyNotUpdatedText := DialogText003;
        Company.FindSet();
        repeat
            //Check if user has correct permissions to update setup
            Permission_GL_OK := false;
            Permission_User_OK := false;
            Permission_Total_OK := false;
            AccessControl.SetFilter("Company Name", '%1|%2', Company.Name, '');
            AccessControl.SetRange("User Security ID", UserSecurityId());
            if AccessControl.FindSet() then begin
                Permission.ChangeCompany(Company.Name);
                repeat
                    Permission.SetRange("Role ID", AccessControl."Role ID");
                    Permission.SetRange("Object Type", Permission."Object Type"::"Table Data");
                    if ChangeGLSetup then begin
                        Permission.SetFilter("Object ID", '%1|%2', 0, 98);
                        Permission.SetRange("Modify Permission", Permission."Modify Permission"::Yes);
                        if Permission.FindFirst() then
                            Permission_GL_OK := true;
                    end else
                        //If General Ledger Setup does not need to be changed, this boolean can be set to True
                        Permission_GL_OK := true;

                    if ChangeUserSetup then begin
                        Permission.SetFilter("Object ID", '%1|%2', 0, 91);
                        Permission.SetRange("Modify Permission", Permission."Modify Permission"::Yes);
                        if Permission.FindFirst() then
                            Permission_User_OK := true;
                    end else
                        //If User Setup does not need to be changed, this boolean can be set to True
                        Permission_User_OK := true;

                    if (Permission_GL_OK) and (Permission_User_OK) then
                        Permission_Total_OK := true;
                until (AccessControl.Next() = 0) or (Permission_Total_OK = true);
            end;

            //Change General Ledger Setup
            if (ChangeGLSetup) and (Permission_Total_OK) then begin
                GLSetup.ChangeCompany(Company.Name);
                GLSetup.Get();
                if UpdateDateFrom then
                    GLSetup."Allow Posting From" := NewAllowPostingFromDate;
                if UpdateDateTo then
                    GLSetup."Allow Posting To" := NewAllowPostingToDate;
                GLSetup.Modify();
            end else
                CompanyNotUpdatedText := CompanyNotUpdatedText + '\ - ' + Company.Name + ' (General Ledger Setup)';

            //Change User Setup
            if (ChangeUserSetup) and (Permission_Total_OK) then begin
                UserSetup.ChangeCompany(Company.Name);
                if UserSetup.FindSet() then
                    repeat
                        if UpdateDateFrom then
                            UserSetup."Allow Posting From" := NewAllowPostingFromDate;
                        if UpdateDateTo then
                            UserSetup."Allow Posting To" := NewAllowPostingToDate;
                        UserSetup.Modify();
                    until UserSetup.Next() = 0;
            end else
                CompanyNotUpdatedText := CompanyNotUpdatedText + '\ - ' + Company.Name + ' (User Setup)';
        until Company.Next() = 0;

        if CompanyNotUpdatedText <> DialogText003 then
            Message(CompanyNotUpdatedText)
        else
            Message(DialogText004);
    end;

    //Global variables
    var
        ChangeGLSetup: Boolean;
        ChangeUserSetup: Boolean;
        NewAllowPostingFromDate: Date;
        NewAllowPostingToDate: Date;
}