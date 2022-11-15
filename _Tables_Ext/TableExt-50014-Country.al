tableextension 50014 "Country/Region Ext." extends "Country/Region"

//  RHE-TNA 18-12-2020 BDS-4798
//  - Added field 50005

//  RHE-TNA 04-01-2021 BDS-4821
//  - Added field 50006

//  RHE-TNA 28-01-2021 BDS-4908
//  - Added field 50007

//  RHE-TNA 08-02-2022 BDS-6102
//  - Modified field 50006

{
    fields
    {
        field(50000; "ISO3 Code"; Code[3])
        {

        }
        field(50001; "B2B Gen. Bus. Posting Group"; Code[20])
        {
            TableRelation = "Gen. Business Posting Group";
        }
        field(50002; "B2C Gen. Bus. Posting Group"; Code[20])
        {
            TableRelation = "Gen. Business Posting Group";
        }
        field(50003; "B2B VAT Bus. Posting Group"; Code[20])
        {
            TableRelation = "VAT Business Posting Group";
        }
        field(50004; "B2C VAT Bus. Posting Group"; Code[20])
        {
            TableRelation = "VAT Business Posting Group";
        }
        field(50005; "Importer of Record"; Code[20])
        {
            TableRelation = Customer;
        }
        field(50006; Carrier; Code[30])
        {
            //RHE-TNA 08-02-2022 BDS-6102 BEGIN
            //TableRelation = Carrier;
            TableRelation = "Interface Mapping"."Interface Value" where (Type = const (Carrier));
            //RHE-TNA 08-02-2022 BDS-6102 END
        }
        field(50007; "EORI No."; Text[20])
        {

        }

    }

    procedure GetCountryCode(CodeToCheck: Code[10]): code[10]
    begin
        if CodeToCheck <> '' then begin
            //Check ISO code
            Rec.SetRange("ISO Code", CodeToCheck);
            if Rec.FindFirst() then
                exit(Rec.Code)
            else begin
                //Check ISO3 code
                Rec.Reset();
                Rec.SetRange("ISO3 Code", CodeToCheck);
                if Rec.FindFirst() then
                    exit(Rec.Code)
                else begin
                    //Check ISO numeric code
                    Rec.Reset();
                    Rec.SetRange("ISO Numeric Code", CodeToCheck);
                    if Rec.FindFirst() then
                        exit(Rec.Code)
                    else begin
                        //Check Code
                        Rec.Reset();
                        Rec.SetRange(Code, CodeToCheck);
                        if Rec.FindFirst() then
                            exit(Rec.Code)
                        else
                            exit('');
                    end;
                end;
            end;
        end;
    end;
}