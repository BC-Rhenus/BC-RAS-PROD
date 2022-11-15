xmlport 50009 "Export WMS Serial No."

//RHE-TNA 17-03-2020..14-05-2020 BDS-3866
//  - New XML port

//  RHE-TNA 14-06-2021 BDS-5337
//  - Modified trigger OnPreXMLPort()

//  RHE-TNA 16-02-2022..25-03-2022 BDS-5585
//  - Modified trigger OnPreXMLPort()

{
    Direction = Export;
    Format = Xml;
    Encoding = UTF8;
    XmlVersionNo = V10;

    schema
    {
        textelement(dcsmergedata)
        {
            textelement(dataheaders)
            {
                tableelement(dataheader; "Reservation Entry")
                {
                    textattribute(transaction)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            transaction := 'add';
                        end;
                    }
                    textelement(record_type)
                    {

                    }
                    textelement(client_id)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            //RHE-TNA 25-03-2022 BDS-5585 BEGIN
                            IFSetup.GetWMSIFSetupEntryNo(dataheader."Location Code");
                            //RHE-TNA 25-03-2022 BDS-5585 END
                            client_id := IFSetup."WMS Client ID";
                        end;
                    }
                    fieldelement(receipt_id; dataheader."Source ID")
                    {

                    }
                    fieldelement(serial_number; dataheader."Serial No.")
                    {

                    }
                    fieldelement(sku_id; dataheader."Item No.")
                    {

                    }
                    textelement(status)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            status := 'D';
                        end;
                    }
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        //RHE-TNA 16-02-2022 BDS-5585 BEGIN
        //IFSetup.Get();
        //RHE-TNA 14-06-2021 BDS-5337 BEGIN
        /*
        IFSetup.SetRange(Type, IFSetup.Type::WMS);
        IFSetup.SetRange(Active, true);
        if not IFSetup.FindFirst() then
            Error('No (active) Interface Setup record exists with Type = WMS.');
        */
        //RHE-TNA 14-06-2021 BDS-5337 END
        //RHE-TNA 16-02-2022 BDS-5585 END
        //RHE-TNA 25-03-2022 BDS-5585 BEGIN
        /*
        IFSetup.TestField("WMS Client ID");
        IFSetup.TestField("WMS Site ID");
        */
        //RHE-TNA 25-03-2022 BDS-5585 END
    end;

    var
        IFSetup: Record "Interface Setup";
}