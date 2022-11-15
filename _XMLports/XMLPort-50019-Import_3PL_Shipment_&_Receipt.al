xmlport 50019 "Import 3PL Shipment & Receipt"

//  RHE-TNA 04-02-2022 BDS-5972
//  - New XMLPort

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
            tableelement(DataHeader; "WMS Import Header")
            {
                textelement(ClientId)
                {

                }
                textelement("Type")
                {

                }
                textelement(WhseRefNo)
                {
                    //Whse shipment or Whse receipt no.
                }
                textelement(OrderNo)
                {

                }
                textelement("Date")
                {
                    //Shipment or Receipt date
                }
                textelement(Carrier)
                {
                    MinOccurs = Zero;
                }
                textelement(ServiceLevel)
                {
                    MinOccurs = Zero;
                }
                textelement(BillOfLading)
                {
                    MinOccurs = Zero;
                }
                textelement(DataLines)
                {
                    tableelement(DataLine; "WMS Import Line")
                    {
                        LinkTable = DataHeader;
                        LinkFields = "Entry No." = field ("Entry No.");

                        textelement(LineNo)
                        {

                        }
                        textelement(ItemNo)
                        {

                        }
                        textelement(Quantity)
                        {

                        }
                        textelement(ParentItemNo)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(OrderLineNo)
                        {

                        }
                        textelement(ItemTrackingLines)
                        {
                            MinOccurs = Zero;
                            tableelement(ItemTrackingLine; "WMS Import Serial Number")
                            {
                                LinkTable = DataLine;
                                LinkFields = "WMS Import Entry No." = field ("Entry No.");
                                MinOccurs = Zero;
                                textelement(TrackingQuantity)
                                {
                                    MinOccurs = Zero;
                                }
                                textelement(SerialNo)
                                {
                                    MinOccurs = Zero;
                                }
                                textelement(LotNo)
                                {
                                    MinOccurs = Zero;
                                }
                                textelement(ExpiryDate)
                                {
                                    MinOccurs = Zero;
                                }

                                trigger OnBeforeInsertRecord()
                                var
                                    Day: Integer;
                                    Month: Integer;
                                    Year: Integer;
                                begin
                                    if (LotNo <> '') or (SerialNo <> '') then begin
                                        ItemTrackingLine."WMS Import Entry No." := DataLine."Entry No.";
                                        ItemTrackingLine."Item No." := DataLine."Item No.";
                                        ItemTrackingLine."Serial No." := SerialNo;
                                        ItemTrackingLine."Lot No." := LotNo;
                                        if TrackingQuantity <> '' then
                                            Evaluate(ItemTrackingLine.Quantity, TrackingQuantity);
                                        if ExpiryDate <> '' then begin
                                            Evaluate(Day, CopyStr(ExpiryDate, 9, 2));
                                            Evaluate(Month, CopyStr(ExpiryDate, 6, 2));
                                            Evaluate(Year, CopyStr(ExpiryDate, 1, 4));
                                            ItemTrackingLine."Expiration Date" := DMY2Date(Day, Month, Year);
                                        end;
                                        ItemTrackingLine."WMS Import Line No." := DataLine."Line No.";
                                    end else
                                        currXMLport.Skip();
                                end;

                                trigger OnAfterInsertRecord()
                                begin
                                    //Clear all values
                                    TrackingQuantity := '';
                                    SerialNo := '';
                                    LotNo := '';
                                    ExpiryDate := '';
                                end;
                            }
                        }

                        trigger OnBeforeInsertRecord()
                        var
                            ATOLink: Record "Assemble-to-Order Link";
                            AssHdr: Record "Assembly Header";
                            AssLine: Record "Assembly Line";
                            WhseShipmentLine: Record "Warehouse Shipment Line";
                            WhseReceiptLine: Record "Warehouse Receipt Line";
                        begin
                            DataLine."Whse. Document No." := DataHeader."Whse. Document No.";
                            DataLine."Source No." := DataHeader."Source No.";
                            Evaluate(DataLine."Source Line No.", OrderLineNo);
                            DataLine."Item No." := ItemNo;
                            Evaluate(DataLine."Qty. shipped / Received", Quantity);
                            if Type = 'Shipment' then begin
                                WhseShipmentLine.SetRange("No.", DataLine."Whse. Document No.");
                                if WhseShipmentLine.FindFirst() then
                                    DataLine."Location Code" := WhseShipmentLine."Location Code";
                            end else begin
                                WhseReceiptLine.SetRange("No.", DataLine."Whse. Document No.");
                                if WhseReceiptLine.FindFirst() then
                                    DataLine."Location Code" := WhseReceiptLine."Location Code";
                            end;
                            if ParentItemNo <> '' then begin
                                DataLine."Assembly Line" := true;
                                DataLine."Assembly Item No." := ParentItemNo;

                                ATOLink.SetRange(Type, ATOLink.Type::Sale);
                                ATOLink.SetRange("Assembly Document Type", ATOLink."Assembly Document Type"::Order);
                                ATOLink.SetRange("Document Type", ATOLink."Document Type"::Order);
                                ATOLink.SetRange("Document No.", DataLine."Source No.");
                                ATOLink.SetRange("Document Line No.", DataLine."Source Line No.");
                                if ATOLink.FindFirst() then begin
                                    if AssHdr.Get(AssHdr."Document Type"::Order, ATOLink."Assembly Document No.") then begin
                                        AssLine.SetRange("Document No.", AssHdr."No.");
                                        AssLine.SetRange(Type, AssLine.Type::Item);
                                        AssLine.SetRange("No.", DataLine."Item No.");
                                        if AssLine.FindFirst() then
                                            DataLine."Assembly Line No." := AssLine."Line No.";
                                        DataLine."Assembly Order No." := AssHdr."No.";
                                    end;
                                end;
                            end;
                        end;
                    }
                }

                trigger OnBeforeInsertRecord()
                var
                    Day: Integer;
                    Month: Integer;
                    Year: Integer;
                begin
                    if Type = 'Shipment' then
                        DataHeader.Validate(Type, DataHeader.Type::Shipment)
                    else
                        DataHeader.Validate(Type, DataHeader.Type::Receipt);
                    DataHeader.Validate("Whse. Document No.", WhseRefNo);
                    DataHeader.Validate("Source No.", OrderNo);

                    Evaluate(Day, CopyStr(Date, 9, 2));
                    Evaluate(Month, CopyStr(Date, 6, 2));
                    Evaluate(Year, CopyStr(Date, 1, 4));
                    if DataHeader.Type = DataHeader.Type::Shipment then
                        DataHeader.Validate("Shipment Date", DMY2Date(Day, Month, Year))
                    else
                        DataHeader.Validate("Receipt Date", DMY2Date(Day, Month, Year));

                    DataHeader.Validate(Carrier, Carrier);
                    DataHeader.Validate("Service Level", ServiceLevel);
                    DataHeader.Validate("Bill Of Lading No.", BillOfLading);
                    DataHeader.Validate("Import Date", Today);
                    DataHeader.Validate(Process, true);
                end;
            }
        }
    }

    procedure SetFileName(FileName: Text[250])
    begin
        currXMLport.Filename := FileName;
    end;
}