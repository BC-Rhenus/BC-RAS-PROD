page 50011 "Interface Log"

//  RHE-TNA 23-11-2020 BDS-4705
//  - New Page

{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Interface Log";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Source; Source)
                {
                    StyleExpr = StyleVar;

                }
                field(Direction; Direction)
                {
                    StyleExpr = StyleVar;

                }
                field(Date; Date)
                {
                    StyleExpr = StyleVar;

                }
                field(Time; Time)
                {
                    StyleExpr = StyleVar;

                }
                field(Filename; Filename)
                {
                    StyleExpr = StyleVar;

                }
                field("Filename Short"; "Filename Short")
                {
                    StyleExpr = StyleVar;
                }
                field(Reference; Reference)
                {
                    StyleExpr = StyleVar;

                }
                field(Error; Error)
                {
                    StyleExpr = StyleVar;

                }
                field("Error Text"; "Error Text")
                {
                    StyleExpr = StyleVar;

                }
                field("Acknowledged By User"; "Acknowledged By User")
                {
                    StyleExpr = StyleVar;

                }
                field("Acknowledged Date/Time"; "Acknowledged Date/Time")
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
            action("Acknowledge Error")
            {
                Image = Approve;
                trigger OnAction()
                var
                    IFLogRec: Record "Interface Log";
                begin
                    CurrPage.SetSelectionFilter(IFLogRec);
                    IFLogRec.ModifyAll("Acknowledged By User", UserId);
                    IFLogRec.ModifyAll("Acknowledged Date/Time", CurrentDateTime);
                end;
            }
        }
        area(Navigation)
        {
            action("Open File")
            {
                Image = ViewDocumentLine;
                trigger OnAction()
                var
                    ToFile: Text;
                begin
                    ToFile := Rec."Filename Short";
                    Download(Rec.Filename, '', '', '', ToFile);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleVar := '';
        if (Error) and ("Acknowledged By User" = '') then
            StyleVar := 'Unfavorable';
    end;

    //Global variables
    var
        StyleVar: Text;
}