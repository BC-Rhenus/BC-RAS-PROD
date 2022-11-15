page 50010 "Interface Record Parameters"

//  RHE-TNA 21-08-2020 BDS-4374
//  - New Page

//  RHE-TNA 16-10-2020 BDS-4551
//  - Added field Parameter 4

//  RHE-TNA 11-06-2021 BDS-5337
// - Added field Source Line No.
// - Added field Source System Line ID

{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Interface Record Parameters";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Source Type"; "Source Type")
                {

                }
                field("Source No."; "Source No.")
                {

                }
                field("Param1"; Param1)
                {
                    Caption = 'Parameter 1';
                }
                field(Param2; Param2)
                {
                    Caption = 'Parameter 2';
                }
                field(Param3; Param3)
                {
                    Caption = 'Parameter 3';
                }
                //RHE-TNA 16-10-2020 BDS-4551 BEGIN
                field(Param4; Param4)
                {
                    Caption = 'Parameter 4';
                }
                //RHE-TNA 16-10-2020 BDS-4551 END
                //RHE-TNA 13-11-2020 BDS-4551 BEGIN
                field(Param5; Param5)
                {
                    Caption = 'Parameter 5';
                }
                //RHE-TNA 13-11-2020 BDS-4551 END
                //RHE-TNA 11-06-2021 BDS-5337 BEGIN
                field("Source Line No."; "Source Line No.")
                {

                }
                field("Source System Line ID"; "Source System Line ID")
                {

                }
                //RHE-TNA 11-06-2021 BDS-5337 END
            }
        }
    }
}