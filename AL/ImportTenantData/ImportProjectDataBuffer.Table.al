table 60306 "Import Project Data Buffer"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(10; "Date Type"; Date)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date Type';
        }
        field(20; "Time Type"; Time)
        {
            DataClassification = SystemMetadata;
            Caption = 'Time Type';
        }
        field(30; "Date Time Type"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date Time Type';
        }
        field(40; "Blob Type"; Blob)
        {
            DataClassification = SystemMetadata;
            Caption = 'Blob Type';
        }
        field(50; "Image Type"; Media)
        {
            DataClassification = SystemMetadata;
            Caption = 'Image Type';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ID := CreateGuid();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure GetFieldAsFieldRef(FldNo: Integer; var FldRef: FieldRef)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        FldRef := RecRef.Field(FldNo);
    end;

    procedure CopyBlobValueToImage(DataBufferFldRef: FieldRef): Guid
    var
        InStr: Instream;
    begin
        "Blob Type" := DataBufferFldRef.Value();
        if "Blob Type".HasValue() then begin
            "Blob Type".CreateInStream(InStr);
            exit("Image Type".ImportStream(InStr, ''));
        end;
    end;
}