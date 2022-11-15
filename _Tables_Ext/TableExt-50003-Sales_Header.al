tableextension 50003 "Sales Header Extensions" extends "Sales Header"

//  RHE-TNA 22-12-2020 BDS-4644
//  - Added field 50006
//  - Added Key1

//  RHE-TNA 05-01-2021 BDS-4828
//  - Removed field 50001 E-mail

//  RHE-TNA 16-11-2021 BDS-5676
//  - Added fields 50008..50009

//  RHE-TNA 12-01-2022 BDS-5997
//  - Added field 50010

//  RHE-TNA 03-03-2022 BDS-5564
//  - Added field 50007
//  - Added procedure SetFullyReserved()

//  RHE-TNA 03-03-2022 BDS-5565
//  - Added field 50011
//  - Added Key2
//  - Added modify("Order Date")
//  - Added trigger OnAfterInsert()

//  RHE-TNA 20-04-2022 BDS-6277
//  - Modified procedure SetFullyAllocated()

//  RHE-TNA 19-05-2022 BDS-6111
//  - Modified TableRelation field 50004

{
    fields
    {
        field(50000; "Customer Comment Text"; text[250])
        {
            DataClassification = CustomerContent;

        }
        /*RHE-TNA 05-01-2021 BDS-4828 BEGIN
        field(50001; "E-mail"; text[80])
        {
            DataClassification = AccountData;
        }
        RHE-TNA 05-01-2021 BDS-4828 END*/
        field(50002; "Bill-to Phone No."; text[30])
        {
            DataClassification = AccountData;
        }
        field(50003; "Ship-to Phone No."; Text[30])
        {
            DataClassification = AccountData;
        }
        field(50004; Substatus; Code[10])
        {
            DataClassification = ToBeClassified;
            //TableRelation = "Order Substatus";
            TableRelation = "Rhenus Setup".Code where (Type = const ("Order Substatus"));
        }
        field(50005; "Interface Error Text"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50006; "Importer of Record"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50007; "Completely Allocated"; Boolean)
        {

        }
        field(50008; "EDI Status"; Option)
        {
            OptionMembers = " ","To Send","Sent";
        }
        field(50009; "Last EDI Export Date/Time"; DateTime)
        {

        }
        field(50010; "Print Assembly Comp."; Boolean)
        {

        }
        field(50011; "Order Date 2"; Date)
        {
            Editable = false;
        }

        modify("Order Date")
        {
            trigger OnAfterValidate()
            begin
                "Order Date 2" := "Order Date";
            end;
        }
    }

    keys
    {
        key(Key1; "Importer of Record")
        {

        }
        key(Key2; "Order Date 2")
        {
            Enabled = true;
        }
    }

    procedure SetFullyAllocated()
    var
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        Item: Record Item;
    begin
        SalesSetup.Get();
        if SalesSetup.AllocationMandatory then begin
            SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
            if SalesHdr.FindSet() then
                repeat
                    SalesLine.SetRange("Document Type", SalesHdr."Document Type");
                    SalesLine.SetRange("Document No.", SalesHdr."No.");
                    if SalesLine.FindSet() then
                        repeat
                            //RHE-TNA 20-04-2022 BDS-6277 BEGIN
                            Item.Get(SalesLine."No.");
                            if Item.Type <> Item.Type::Inventory then
                                SalesHdr."Completely Allocated" := true
                            else begin
                                //RHE-TNA 20-04-2022 BDS-6277 END
                                if SalesLine."Outstanding Qty. (Base)" = SalesLine."Allocated Qty." then
                                    SalesHdr."Completely Allocated" := true
                                else
                                    SalesHdr."Completely Allocated" := false;
                                //RHE-TNA 20-04-2022 BDS-6277 BEGIN
                            end;
                            //RHE-TNA 20-04-2022 BDS-6277 END
                        until (SalesLine.Next() = 0) or (SalesHdr."Completely Allocated" = false)
                    else
                        SalesHdr."Completely Allocated" := true;
                    SalesHdr.Modify();
                until SalesHdr.Next() = 0;
        end;
    end;
}