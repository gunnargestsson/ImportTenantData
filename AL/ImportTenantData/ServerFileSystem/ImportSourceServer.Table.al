table 60323 "Import Source Server File"
{
    DataClassification = SystemMetadata;
    LookupPageId = "Import Source Server List";

    fields
    {
        field(1; "Source ID"; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Source ID';
            NotBlank = true;
        }
        field(2; "File Path"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'File Path';
        }
    }

    keys
    {
        key(PK; "Source ID")
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

}