pageextension 50041 "Transfer Order Hdr Ext." extends "Transfer Order"

//  RHE-TNA 11-06-2021 BDS-5385
//  - New extension

//  RHE-TNA 03-02-2022 BDS-6093
//  - Added field "External Document No."

{
    layout
    {
        addafter("In-Transit Code")
        {
            field("External Document No."; "External Document No.")
            {
                Editable = (Status = Status::Open);
            }
            field("Currency Code"; "Currency Code")
            {
                Editable = (Status = Status::Open);
            }
        }
    }

}