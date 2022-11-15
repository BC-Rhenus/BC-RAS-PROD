tableextension 50020 "Shipping Agent Service Ext." extends "Shipping Agent Services"

//  RHE-TNA 14-04-2020..14-05-2020 BDS-3866
//  - Added field 50001

//  RHE-TNA 30-04-2021 BDS-5304
//  - Added fields 50002 and 50003

//  RHE-TNA 15-10-2021 BDS-5679
//  - Added field 50004

{
    fields
    {
        field(50000; Hub; Boolean)
        {

        }
        field(50001; "WMS Dispatch Method"; Code[40])
        {

        }
        field(50002; "WMS Carrier"; Code[25])
        {

        }
        field(50003; "WMS Service Level"; Code[40])
        {

        }
        field(50004; "Service Incl. Tracking No."; Boolean)
        {

        }
    }
}