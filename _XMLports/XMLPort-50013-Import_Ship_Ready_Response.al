xmlport 50013 "Import Ship Ready Response"

//  RHE-TNA 16-10-2020..13-11-2020 BDS-4551
//  - New XMLPort

//RHE-TNA 23-11-2020 BDS-4705 
//  - Modified trigger OnBeforeInsertRecord()

{
    Direction = Import;
    Format = Xml;
    FormatEvaluate = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(Order; Integer)
            {
                textelement(Order_Id)
                {

                }
                textelement(ReferenceNumber)
                {

                }
                textelement(ReferenceNumber2)
                {

                }
                trigger OnBeforeInsertRecord()
                var
                    IFRecordParam: Record "Interface Record Parameters";
                    SalesHdr: Record "Sales Header";
                begin
                    IFRecordParam.Reset();
                    IFRecordParam.SetRange("Source Type", IFRecordParam."Source Type"::Order);
                    IFRecordParam.SetRange(Param5, Order_Id);
                    IFRecordParam.SetRange(Param1, ReferenceNumber2);
                    if IFRecordParam.FindSet() then
                        repeat
                            IFRecordParam.Param4 := ReferenceNumber;
                            //RHE-TNA 20-11-2020 BDS-4705 BEGIN
                            //Set Assigned Source No. to store import object ID (will be removed by Report 50032)
                            IFRecordParam."Source No." := 'R50032-' + IFRecordParam."Source No.";
                            //RHE-TNA 20-11-2020 BDS-4705 END
                            IFRecordParam.Modify();
                        until IFRecordParam.Next() = 0
                    else begin
                        IFRecordParam.Insert(true);
                        IFRecordParam."Source Type" := IFRecordParam."Source Type"::Order;
                        IFRecordParam.Param5 := Order_Id;
                        IFRecordParam.Param1 := ReferenceNumber2;
                        IFRecordParam.Param4 := ReferenceNumber;
                        //RHE-TNA 20-11-2020 BDS-4705 BEGIN
                        //Set Assigned Source No. to store import object ID (will be removed by Report 50032)
                        IFRecordParam."Source No." := 'R50032-';
                        //RHE-TNA 20-11-2020 BDS-4705 END
                        IFRecordParam.Modify();
                    end;

                    //Do not actually import into Integer table
                    currXMLport.Skip();
                end;
            }
        }
    }

    procedure SetFileName(FileName: Text[250])
    begin
        currXMLport.Filename := FileName;
    end;

    //Global variables
    var
}