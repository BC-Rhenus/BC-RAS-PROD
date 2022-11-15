pageextension 50017 "Countries/Regions Ext." extends "Countries/Regions"

//  RHE-TNA 18-12-2020 BDS-4798
//  - Added field Import of Record

//  RHE-TNA 04-01-2021 BDS-4821
//  - Added field Carrier

//  RHE-TNA 28-01-2021 BDS-4908
//  - Added field EORI No.

{
    layout
    {
        addafter("ISO Code")
        {
            field("ISO3 Code"; "ISO3 Code")
            {

            }
        }
        addafter("VAT Scheme")
        {
            field("B2B Gen. Bus. Posting Group"; "B2B Gen. Bus. Posting Group")
            {

            }
            field("B2B VAT Bus. Posting Group"; "B2B VAT Bus. Posting Group")
            {

            }
            field("B2C Gen. Bus. Posting Group"; "B2C Gen. Bus. Posting Group")
            {

            }
            field("B2C VAT Bus. Posting Group"; "B2C VAT Bus. Posting Group")
            {

            }
            //RHE-TNA 18-12-2020 BDS-4798 BEGIN
            field("Importer of Record"; "Importer of Record")
            {

            }
            //RHE-TNA 18-12-2020 BDS-4798 END
            //RHE-TNA 28-01-2021 BDS-4908 BEGIN
            field("EORI No."; "EORI No.")
            {

            }
            //RHE-TNA 28-01-2021 BDS-4908 END
            //RHE-TNA 04-01-2021 BDS-4821 BEGIN
            field(Carrier; Carrier)
            {

            }
            //RHE-TNA 04-01-2021 BDS-4821 END
        }
    }
}