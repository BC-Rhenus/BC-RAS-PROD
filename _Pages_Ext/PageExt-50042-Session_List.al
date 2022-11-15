pageextension 50042 "Session List Ext." extends "Session List"
{
    actions
    {
        addafter("Debug Next Session")
        {
            action("Stop Session")
            {
                Image = Stop;
                trigger OnAction()
                begin
                    StopSession(Rec."Session ID");
                end;
            }
        }
    }

    var
        myInt: Integer;
}