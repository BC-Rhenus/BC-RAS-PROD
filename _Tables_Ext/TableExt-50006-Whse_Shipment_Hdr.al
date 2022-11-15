tableextension 50006 "Whse. Shipment Hdr Extension" extends "Warehouse Shipment Header"
{
    fields
    {
        field(50000; "Exported to WMS"; Boolean)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            //Local Variables
            var
                WhseShipmentLine: Record "Warehouse Shipment Line";
            begin
                WhseShipmentLine.SetRange("No.", "No.");
                WhseShipmentLine.ModifyAll("Exported to WMS", "Exported to WMS");
            end;
        }
        field(50001; "Source Document"; Option)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup ("Warehouse Shipment Line"."Source Document" WHERE ("No." = FIELD ("No.")));
            OptionMembers = ,"Sales Order",,,"Sales Return Order","Purchase Order",,,"Purchase Return Order",,"Outbound Transfer",,,,,,,,"Service Order";
            OptionCaption = ',Sales Order,,,Sales Return Order,Purchase Order,,,Purchase Return Order,,Outbound Transfer,,,,,,,,Service Order';
            Editable = false;
        }
        field(50002; "Source No."; code[20])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup ("Warehouse Shipment Line"."Source No." WHERE ("No." = FIELD ("No.")));
            Editable = false;
        }
        field(50003; "Shipped in WMS"; Boolean)
        {

        }
        field(50004; "Shipped Completely"; Boolean)
        {

        }
        field(50005; "Auto. Posting Error"; Boolean)
        {

        }
        field(50006; "Auto. Posting Error Text"; Text[250])
        {

        }
    }
}