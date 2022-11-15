xmlport 50010 "Import WMS Serial No."

//  RHE-TNA 17-03-2020..14-05-2020 BDS-3866
//  - New XMLport

//  RHE-TNA 06-08-2020 BDS-4371 
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 02-04-2022 BDS-5977
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 25-03-2022 BDS-6219
//  - Modified trigger OnBeforeInsertRecord()

//  RHE-TNA 16-05-2022 BDS-6332
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
            tableelement(Serial_Number; Integer)
            {
                textelement(Record_Type)
                {

                }
                textelement(Serial_No)
                {

                }
                textelement(Item_No)
                {

                }
                textelement(Order_Id)
                {

                }
                textelement(Tag_Id)
                {

                }
                textelement(Receipt_Id)
                {

                }
                textelement(Pallet_Id)
                {

                }
                trigger OnBeforeInsertRecord()
                var
                    WMSSerialNo: Record "WMS Import Serial Number";
                    WMSSerialNo2: Record "WMS Import Serial Number";
                    WMSImportHdr: Record "WMS Import Header";
                    WMSImportLine: Record "WMS Import Line";
                    WMSImportLine2: Record "WMS Import Line";
                    i: Integer;
                    Assigned: Boolean;
                begin
                    if UpperCase(Record_Type) = 'ITL' then begin
                        //RHE-TNA 06-08-2020 BDS-4371 BEGIN
                        //WMSImportHdr.SetRange(Type, WMSImportHdr.Type::Receipt);
                        //WMSImportHdr.SetRange("Source No.", Receipt_Id);
                        //if not WMSImportHdr.FindFirst() then
                        //Error('No Import Record found.');
                        WMSImportLine.SetRange("Source No.", Receipt_Id);
                        WMSImportLine.SetRange("Item No.", Item_No);
                        WMSImportLine.SetRange("Tag Id", Tag_Id);
                        if not WMSImportLine.FindFirst() then
                            currXMLport.Skip()
                        else
                            WMSImportHdr.Get(WMSImportLine."Entry No.");
                        //RHE-TNA 06-08-2020 BDS-4371 END
                    end;
                    if UpperCase(Record_Type) = 'MAN' then begin
                        //RHE-TNA 02-04-2022 BDS-5977 BEGIN
                        /*
                        WMSImportHdr.SetRange(Type, WMSImportHdr.Type::Shipment);
                        WMSImportHdr.SetRange("Whse. Document No.", Order_Id);
                        if not WMSImportHdr.FindFirst() then
                            Error('No Import Record found.');
                        */
                        WMSImportLine.SetRange("Whse. Document No.", Order_Id);
                        WMSImportLine.SetRange("Item No.", Item_No);
                        WMSImportLine.SetRange("Tag Id", Tag_Id);
                        if not WMSImportLine.FindFirst() then begin
                            WMSImportHdr.SetRange(Type, WMSImportHdr.Type::Shipment);
                            WMSImportHdr.SetRange("Whse. Document No.", Order_Id);
                            if not WMSImportHdr.FindFirst() then
                                Error('No Import Record found.');
                        end else
                            WMSImportHdr.Get(WMSImportLine."Entry No.")
                        //RHE-TNA 02-04-2022 BDS-5977 END
                    end;
                    WMSSerialNo.SetRange("WMS Import Entry No.", WMSImportHdr."Entry No.");
                    WMSSerialNo.SetRange("Item No.", Item_No);
                    WMSSerialNo.SetRange("Serial No.", Serial_No);
                    WMSSerialNo.SetRange("Pallet Id", Pallet_Id);
                    WMSSerialNo.SetRange("Tag Id", Tag_Id);
                    if WMSSerialNo.FindFirst() then
                        currXMLport.Skip();

                    WMSSerialNo.Init();
                    WMSSerialNo."WMS Import Entry No." := WMSImportHdr."Entry No.";
                    WMSSerialNo."Item No." := Item_No;
                    WMSSerialNo."Serial No." := Serial_No;
                    WMSSerialNo."Pallet Id" := Pallet_Id;
                    WMSSerialNo."Tag Id" := Tag_Id;
                    //RHE-TNA 16-05-2022 BDS-6332 BEGIN
                    WMSSerialNo."Expiration Date" := WMSImportLine."Expiration Date";
                    //RHE-TNA 16-05-2022 BDS-6332 END
                    //RHE-TNA 02-04-2022 BDS-5977 BEGIN
                    WMSSerialNo.Quantity := 1;
                    //RHE-TNA 25-03-2022 BDS-6219 BEGIN
                    //WMSSerialNo."WMS Import Line No." := WMSImportLine."Line No.";

                    //Check if current WMS Import Line already has sufficient serial numbers and continue with next line.
                    WMSImportLine2.SetRange("Entry No.", WMSImportLine."Entry No.");
                    WMSImportLine2.SetRange("Item No.", WMSImportLine."Item No.");
                    WMSImportLine2.SetRange("Tag Id", WMSImportLine."Tag Id");
                    WMSImportLine2.SetRange("WMS Pallet Id", WMSImportLine."WMS Pallet Id");
                    WMSImportLine2.FindSet();
                    repeat
                        i := 0;
                        Assigned := false;
                        WMSSerialNo2.Reset();
                        WMSSerialNo2.SetRange("WMS Import Entry No.", WMSImportLine2."Entry No.");
                        WMSSerialNo2.SetRange("WMS Import Line No.", WMSImportLine2."Line No.");
                        WMSSerialNo2.SetRange("Item No.", WMSImportLine2."Item No.");
                        WMSSerialNo2.SetRange("Pallet Id", WMSImportLine2."WMS Pallet Id");
                        WMSSerialNo2.SetRange("Tag Id", WMSImportLine2."Tag Id");
                        if WMSSerialNo2.FindSet() then
                            repeat
                                i += 1;
                            until WMSSerialNo2.Next() = 0;
                        if i < WMSImportLine2."Qty. Shipped / Received" then begin
                            WMSSerialNo."WMS Import Line No." := WMSImportLine2."Line No.";
                            Assigned := true;
                        end;
                    until (WMSImportLine2.Next() = 0) or (Assigned);
                    //RHE-TNA 25-03-2022 BDS-6219 END
                    //RHE-TNA 02-04-2022 BDS-5977 END
                    WMSSerialNo.Insert(true);

                    //Do not actually insert into Integer table
                    currXMLport.Skip();
                end;
            }
        }
    }
    procedure SetFileName(FileName: Text[250])
    begin
        currXMLport.Filename := FileName;
    end;
}