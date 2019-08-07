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
}