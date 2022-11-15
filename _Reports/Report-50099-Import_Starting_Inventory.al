report 50099 "Import Starting Inventory"
{
    UsageCategory = Tasks;
    UseRequestPage = true;
    ProcessingOnly = true;

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field("Sheet Name to Import"; SheetName)
                    {
                        ApplicationArea = all;
                        ToolTip = 'Set the Excel Sheet Name to import.';
                    }
                    field("Number of Excel Header Line(s)"; NoOfExcelHdrLine)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Set the number of header lines in Excel. The import function will ignore these lines at importing.';
                    }
                    field("Item Journal Template"; ItemJournalTemplate)
                    {

                    }
                    field("Item Journal Batch"; ItemJournalBatch)
                    {

                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if SheetName = '' then
            Error('Sheet Name to Import cannot be empty.');
        if ItemJournalTemplate = '' then
            error('Item Journal Template cannot be empty.');
        if ItemJournalBatch = '' then
            Error('Item Journal Batch cannot be empty.');
        FirstLine := true;
    end;

    trigger OnPostReport()
    var

    begin
        if UploadIntoStream('Select File', 'C:', 'Excel files(*.xlsx)|*.xlsx|Excel File (*.xls)|*.xls', FileName, InStream) then begin
            ExcelBuffer.OpenBookStream(InStream, SheetName);
            ExcelBuffer.ReadSheet();
            ProcessExcelBuffer();
            Message('File imported.');
        end;
    end;

    procedure ProcessExcelBuffer()
    var
        LineNo: Integer;
        PostingDate: Date;
        DocNo: Code[20];
        ItemNo: Code[20];
        Location: Code[10];
        Qty: Decimal;
        UnitPrice: Decimal;
        LotNo: Code[50];
        SerialNo: Code[50];
        ExpirationDate: Date;
    begin
        If ExcelBuffer.FindSet() then begin
            repeat
                if ExcelBuffer."Row No." > NoOfExcelHdrLine then begin
                    //Line No
                    if ExcelBuffer."Column No." = 1 then begin
                        if not FirstLine then begin
                            //Finalize previous line
                            CreateItemJnlLine(LineNo, PostingDate, DocNo, ItemNo, Location, Qty, UnitPrice);
                            if (LotNo <> '') or (SerialNo <> '') then
                                CreateReservationEntry(ItemNo, Location, Qty, LineNo, LotNo, SerialNo, ExpirationDate);
                        end else
                            FirstLine := false;
                        //Reset values
                        LineNo := 0;
                        PostingDate := Today;
                        DocNo := '';
                        ItemNo := '';
                        Location := '';
                        Qty := 0;
                        UnitPrice := 0;
                        LotNo := '';
                        SerialNo := '';
                        ExpirationDate := 0D;

                        Evaluate(LineNo, ExcelBuffer."Cell Value as Text");
                    end;

                    //Item No
                    if ExcelBuffer."Column No." = 2 then begin
                        Evaluate(ItemNo, ExcelBuffer."Cell Value as Text");
                    end;

                    //Location
                    if ExcelBuffer."Column No." = 3 then begin
                        Evaluate(Location, ExcelBuffer."Cell Value as Text");
                    end;

                    //Posting Date
                    if ExcelBuffer."Column No." = 4 then begin
                        Evaluate(PostingDate, ExcelBuffer."Cell Value as Text");
                    end;

                    //Document No.
                    if ExcelBuffer."Column No." = 5 then begin
                        Evaluate(DocNo, ExcelBuffer."Cell Value as Text");
                    end;

                    //Quantity
                    if ExcelBuffer."Column No." = 6 then begin
                        Evaluate(Qty, ExcelBuffer."Cell Value as Text");
                    end;

                    //Unit Price
                    if ExcelBuffer."Column No." = 7 then begin
                        Evaluate(UnitPrice, ExcelBuffer."Cell Value as Text");
                    end;

                    //Serial No.
                    if ExcelBuffer."Column No." = 8 then begin
                        Evaluate(SerialNo, ExcelBuffer."Cell Value as Text");
                    end;

                    //Lot No.
                    if ExcelBuffer."Column No." = 9 then begin
                        Evaluate(LotNo, ExcelBuffer."Cell Value as Text");
                    end;

                    //Expiration Date
                    if ExcelBuffer."Column No." = 10 then begin
                        Evaluate(ExpirationDate, ExcelBuffer."Cell Value as Text");
                    end;

                end;
            until ExcelBuffer.Next() = 0;
            //Finalize last line
            CreateItemJnlLine(LineNo, PostingDate, DocNo, ItemNo, Location, Qty, UnitPrice);
            if (LotNo <> '') or (SerialNo <> '') then
                CreateReservationEntry(ItemNo, Location, Qty, LineNo, LotNo, SerialNo, ExpirationDate);

            ExcelBuffer.DeleteAll();
        end else
            Message('No Excel lines found.');
    end;

    procedure CreateItemJnlLine(LineNo: Integer; PostingDate: Date; DocNo: Code[20]; Item: Code[20]; Location: Code[10]; Qty: Decimal; UnitPrice: Decimal)
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        ItemJnlLine.Init();
        ItemJnlLine."Journal Template Name" := ItemJournalTemplate;
        ItemJnlLine."Journal Batch Name" := ItemJournalBatch;
        ItemJnlLine."Line No." := LineNo;
        ItemJnlLine.Insert(true);
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
        ItemJnlLine.Validate("Document No.", DocNo);
        ItemJnlLine.Validate("Item No.", Item);
        ItemJnlLine.Validate("Location Code", Location);
        ItemJnlLine.Validate(Quantity, Qty);
        ItemJnlLine.Validate("Unit Amount", UnitPrice);
        ItemJnlLine.Modify(true);
    end;

    procedure CreateReservationEntry(Item: Code[20]; Location: code[10]; Qty: Decimal; SourceLineNo: Integer; LotNo: Code[50]; SerialNo: Code[50]; ExpirationDate: Date)
    var
        ResEntry: Record "Reservation Entry";
        EntryNo: Integer;
    begin
        ResEntry.Reset();
        IF ResEntry.FindLast() THEN
            EntryNo := ResEntry."Entry No." + 1
        ELSE
            EntryNo := 1;

        ResEntry.Init();
        ResEntry."Entry No." := EntryNo;
        ResEntry.Validate("Item No.", Item);
        ResEntry.Validate("Location Code", Location);
        ResEntry.Validate(Quantity, Qty);
        ResEntry.Validate("Reservation Status", ResEntry."Reservation Status"::Prospect);
        ResEntry.Validate("Creation Date", Today);
        ResEntry.Validate("Created By", UserId);
        ResEntry.Validate("Source Type", 83);
        ResEntry.Validate("Source Subtype", 2);
        ResEntry.Validate("Source ID", ItemJournalTemplate);
        ResEntry.Validate("Source Batch Name", ItemJournalBatch);
        ResEntry.Validate("Source Ref. No.", SourceLineNo);
        ResEntry.Validate("Expected Receipt Date", Today);
        if SerialNo <> '' then begin
            ResEntry.Validate("Serial No.", SerialNo);
            ResEntry.Validate("Item Tracking", ResEntry."Item Tracking"::"Serial No.");
        end;
        if LotNo <> '' then begin
            ResEntry.Validate("Lot No.", LotNo);
            if ResEntry."Item Tracking" = ResEntry."Item Tracking"::"Serial No." then
                ResEntry.Validate("Item Tracking", ResEntry."Item Tracking"::"Lot and Serial No.")
            else
                ResEntry.Validate("Item Tracking", ResEntry."Item Tracking"::"Lot No.");
        end;
        ResEntry.Validate(Positive, true);
        ResEntry.Validate("Quantity (Base)", ResEntry.Quantity);
        if ExpirationDate <> 0D then
            ResEntry.Validate("Expiration Date", ExpirationDate);
        ResEntry.Insert(true);
    end;

    //Global variables
    var
        ExcelBuffer: Record "Excel Buffer";
        InStream: InStream;
        FileName: Text;
        SheetName: Text[31];
        NoOfExcelHdrLine: Integer;
        LineType: Text[3];
        ItemJournalTemplate: Text[10];
        ItemJournalBatch: Text[10];
        ItemJnlLine: Record "Item Journal Line";
        FirstLine: Boolean;

}