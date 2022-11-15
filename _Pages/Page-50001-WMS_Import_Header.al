page 50001 "WMS Import Record"

//  RHE-TNA 30-04-2021 BDS-5304
//  - Added field Carrier
//  - Added field Service Level

{
    PageType = Document;
    UsageCategory = None;
    SourceTable = "WMS Import Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Type; Type)
                {
                    StyleExpr = StyleVar;
                }
                field("Whse. Document No."; "Whse. Document No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Source No."; "Source No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    StyleExpr = StyleVar;
                }
                field("Receipt Date"; "Receipt Date")
                {
                    StyleExpr = StyleVar;
                }
                //RHE-TNA 30-04-2021 BDS-5304 BEGIN
                field(Carrier; Carrier)
                {
                    StyleExpr = StyleVar;
                }
                field("Service Level"; "Service Level")
                {
                    StyleExpr = StyleVar;
                }
                //RHE-TNA 30-04-2021 BDS-5304 END
                field("Bill Of Lading No."; "Bill Of Lading No.")
                {
                    StyleExpr = StyleVar;
                }
                field("Import Date"; "Import Date")
                {
                    StyleExpr = StyleVar;
                }
                field(Process; Process)
                {
                    StyleExpr = StyleVar;
                }
                field("Processed Date"; "Processed Date")
                {
                    StyleExpr = StyleVar;
                    Editable = false;
                }
                field("Processed by User"; "Processed by User")
                {
                    StyleExpr = StyleVar;
                    Editable = false;
                }
                field(Error; Error)
                {
                    StyleExpr = StyleVar;
                }
                field("Error Text"; "Error Text")
                {
                    StyleExpr = StyleVar;
                }
            }
            part(Lines; "WMS Import Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No." = field ("Entry No.");
            }
        }
    }

    actions
    {

    }

    trigger OnAfterGetRecord()
    begin
        StyleVar := '';
        if Error then
            StyleVar := 'Unfavorable';
        if (Error = false) and (Process = false) then
            StyleVar := 'Favorable';
    end;

    //Global variables
    var
        StyleVar: Text;
}