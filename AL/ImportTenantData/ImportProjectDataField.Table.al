table 60305 "Import Project Data Field"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; ID; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
            NotBlank = true;
        }
        field(2; "Xml Table Id"; Integer)
        {
            Caption = 'Xml Table Id';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(3; "Xml Field ID"; Integer)
        {
            Caption = 'Xml Field ID';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(7; "Xml Table Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Xml Table Name';
        }
        field(8; "Xml Field Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Xml Field Name';
        }
    }

    keys
    {
        key(PK; ID, "Xml Table Id", "Xml Field ID")
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

    procedure DeleteFields(DataID: Guid)
    begin
        SetRange(ID, DataID);
        if not IsEmpty() then
            DeleteAll();
    end;
}