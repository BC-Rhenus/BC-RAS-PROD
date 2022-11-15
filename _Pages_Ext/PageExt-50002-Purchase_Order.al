pageextension 50002 "Purchase Order Ext" extends "Purchase Order"

//  RHE-TNA 19-05-2022 BDS-6111
//  - Modified field(Substatus)

{
    layout
    {
        addafter(Status)
        {
            field(Substatus; Substatus)
            {
                LookupPageId = "Order Substatus";
            }
        }
    }

    //Global Variables
    var
}