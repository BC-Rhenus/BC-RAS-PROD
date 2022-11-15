tableextension 50002 "Purch. Header Extension" extends "Purchase Header"

//  RHE-TNA 19-05-2022 BDS-6111
//  - Modified TableRelation field 50000

{
    fields
    {
        field(50000; Substatus; Code[10])
        {
            DataClassification = ToBeClassified;
            //TableRelation = "Order Substatus";
            TableRelation = "Rhenus Setup".Code where (Type = const ("Order Substatus"));
        }
    }
}