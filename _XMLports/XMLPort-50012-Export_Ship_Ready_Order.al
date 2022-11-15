xmlport 50012 "Export Ship Ready Order"

//  RHE-TNA 15-10-2020 BDS-4551
//  - New XMLPort

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreXMLPort()

{
    Direction = Export;
    Format = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;

    schema
    {
        textelement(Root)
        {
            tableelement(Order; "Sales Header")
            {
                fieldelement(OrderNumber; Order."No.")
                {

                }
                fieldelement(YourReference; Order."Your Reference")
                {

                }
                fieldelement(ExternalDocNumber; Order."External Document No.")
                {

                }
                fieldelement(CustomerNumber; Order."Sell-to Customer No.")
                {

                }
                textelement(ReferenceNumber)
                {
                    trigger OnBeforePassVariable()
                    begin
                        ReferenceNumber := '';
                        ReferenceNumber2 := '';
                        IFRecParam.Reset();
                        IFRecParam.SetRange("Source Type", IFRecParam."Source Type"::Order);
                        IFRecParam.SetRange("Source No.", Order."No.");
                        if IFRecParam.FindFirst() then begin
                            ReferenceNumber := IFRecParam.Param2;
                            ReferenceNumber2 := IFRecParam.Param1;
                        end;
                    end;
                }
                textelement(ReferenceNumber2)
                {

                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        //IFSetup.Get();
        //IFSetup.TestField("Ship Ready Export Directory");
        //RHE-TNA 14-06-2021 BDS-5337 END
    end;

    //Global Variables
    var
        IFSetup: Record "Interface Setup";
        IFRecParam: Record "Interface Record Parameters";

}