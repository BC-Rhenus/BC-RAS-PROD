pageextension 50031 "Purchase Order List Ext" extends "Purchase Order List"
{
    layout
    {
        addafter(Status)
        {
            field(Substatus; Substatus)
            {

            }
            field(Invoice; Invoice)
            {

            }
        }
    }

    actions
    {
        addafter("Delete Invoiced")
        {
            action("Import ASN")
            {
                image = ImportExcel;
                Ellipsis = true;
                ToolTip = 'Import an ASN file in Excel format.';

                trigger OnAction()
                var
                    Import: Report "Import ASN";
                begin
                    Import.RunModal();
                end;
            }
        }
    }

    //Global Variables
    var
}