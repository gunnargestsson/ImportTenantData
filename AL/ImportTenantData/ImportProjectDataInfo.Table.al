table 60304 "Import Project Data Info"
{
    DataClassification = SystemMetadata;
    Caption = 'Import Project Data Info';

    fields
    {
        field(1; ID; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
            NotBlank = true;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(3; Name; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Name';
        }
        field(4; Caption; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Caption';
        }
        field(5; "Data Per Company"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Data Per Company';
        }
        field(6; "Table Type"; Text[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Table Type';
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

    procedure DeleteInfo(DataID: Guid)
    begin
        SetRange(ID, DataID);
        if not IsEmpty() then
            DeleteAll();
    end;
}