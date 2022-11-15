page 50006 "WMS Import Record List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WMS Import Header";
    Editable = false;
    CardPageId = 50001;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    StyleExpr = StyleVar;
                }
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
        }
    }

    actions
    {
        area(Processing)
        {
            action("Import WMS Files")
            {
                Image = Import;
                trigger OnAction()
                var
                    Import: Report "Import WMS MAN & ITL";
                begin
                    Import.RunModal();
                end;
            }
            action("Process Records")
            {
                Image = Apply;
                trigger OnAction()
                var
                    Process: Report "Process WMS Import Record";
                begin
                    Process.RunModal();
                end;
            }
        }
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