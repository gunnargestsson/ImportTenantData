table 60305 "Import Project Data Field"
{
    DataClassification = SystemMetadata;
    Caption = 'Import Project Data Field';
    LookupPageId = "Import Project Data Field List";
    DrillDownPageId = "Import Project Data Field List";

    fields
    {
        field(1; ID; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
            NotBlank = true;
        }
        field(3; "Field ID"; Integer)
        {
            Caption = 'Field ID';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(7; "Table Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Table Name';
        }
        field(8; "Field Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Field Name';
        }
        field(9; "Data Type"; Text[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Data Type';
        }
        field(10; "Data Length"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Data Length';
            BlankZero = true;
        }
        field(11; Enabled; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Enabled';
        }
        field(12; "Field Caption"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Field Caption';
        }
        field(13; "Blank Numbers"; Text[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Blank Numbers';
        }
        field(14; "Blank Zero"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Blank Zero';
        }
        field(15; "Sign Displacement"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Sign Displacement';
        }
        field(16; "Editable"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Editable';
        }
        field(17; "Not Blank"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Not Blank';
        }
        field(18; Numeric; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Numeric';
        }
        field(19; "Date Formula"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date Formula';
        }
        field(20; "Closing Dates"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Closing Dates';
        }
        field(21; "Auto Increment"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Auto Increment';
        }
        field(22; "SQL Timestamp"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'SQL Timestamp';
        }
        field(23; "Validate Table Relation"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Validate Table Relation';
        }
        field(24; "Test Table Relation"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Test Table Relation';
        }
        field(25; "Extended Data Type"; Text[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Extended Data Type';
        }
        field(26; "External Access"; Text[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'External Access';
        }
        field(27; "Access By Object Type"; Text[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Access By Object Type';
        }
        field(28; "Access By Object ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Access By Object ID';
        }
        field(29; "Access By Permission Mask"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Access By Permission Mask';
            BlankZero = true;
        }
        field(30; "Option String"; Text[1024])
        {
            DataClassification = SystemMetadata;
            Caption = 'Option String';
        }
        field(31; "Option Caption"; Text[1024])
        {
            DataClassification = SystemMetadata;
            Caption = 'Option Caption';
        }
        field(32; "Sub Type"; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Sub Type';
        }
        field(33; Compressed; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Compressed';
            InitValue = true;
        }

    }

    keys
    {
        key(PK; ID, "Field ID")
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

    procedure GetFieldValueAsText(Row: XmlNode): Text
    var
        NodeMgt: Codeunit "Import Project Node Mgt.";
    begin
        exit(NodeMgt.FindNodeTextValue(Row, StrSubstNo('Field%1', "Field ID")));
    end;
}