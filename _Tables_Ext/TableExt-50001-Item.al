tableextension 50001 "Item Extension" extends Item

//  RHE-TNA 18-11-2020 BDS-4552
//  - Added field 50003

//  RHE-TNA 18-10-2021 BDS-5678
//  - Modified field 50003

//  RHE-TNA 15-04-2022 BDS-6277
//  - Modified field 50003

//  RHE-TNA 19-04-2022 BDS-6233
//  - Added field 50004

//  RHE-TNA 25-05-2022 BDS-6364
//  - Added field 50005

//  RHE-TNA 08-06-2022 BDS-6378
//  - Added field 50006

{
    fields
    {
        field(50000; "Exported to WMS"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Ass. Gen. Prod. Posting Group"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Product Posting Group";
        }
        field(50002; "Obsolete Item"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        //RHE-TNA 18-11-2020 BDS-4552 BEGIN
        field(50003; "Export Inventory Level"; Boolean)
        {
            DataClassification = ToBeClassified;
            //RHE-TNA 18-10-2021 BDS-5678 BEGIN
            Caption = 'Include in Export of Inventory Availability.';
            //RHE-TNA 18-10-2021 BDS-5678 END

            //RHE-TNA 15-04-2022 BDS-6277 BEGIN
            trigger OnValidate()
            begin
                if Type <> Type::Inventory then
                    Error('You can only set this field when Type = Inventory.');
            end;
            //RHE-TNA 15-04-2022 BDS-6277 END
        }
        //RHE-TNA 18-11-2020 BDS-4552 END
        field(50004; "Shipping Cost Item"; Boolean)
        {

        }
        field(50005; ExclItemPrint; Boolean)
        {
            Caption = 'Exclude Item on Documents.';
        }
        field(50006; ExclItemEDI; Boolean)
        {
            Caption = 'Exclude Item on EDI.';
        }
    }
}