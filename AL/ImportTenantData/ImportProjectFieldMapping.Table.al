table 60311 "Import Project Field Mapping"
{
    DataClassification = SystemMetadata;
    Caption = 'Import Project Field Mapping';
    DataCaptionFields = "Destination Field Name";

    fields
    {
        field(2; "Project Table ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Project Table ID';
            TableRelation = "Import Project Data".ID;
        }
        field(3; "Project Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Project Field ID';
            trigger OnValidate()
            begin
                CalcFields("Project Field Name", "Project Field Caption");
            end;
        }
        field(4; "Destination Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Destination Table ID';
            TableRelation = AllObjWithCaption."Object ID" where ("Object Type" = const ("Table"));
            NotBlank = true;
            trigger OnValidate()
            begin

            end;
        }
        field(5; "Destination Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Destination Field ID';
            TableRelation = Field."No." where (TableNo = field ("Destination Table ID"));
            BlankZero = true;

            trigger OnValidate()
            begin
                CalcFields("Destination Field Name");
            end;
        }
        field(6; "Destination Field Name"; Text[30])
        {
            Caption = 'Destination Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup (Field.FieldName where (TableNo = field ("Destination Table ID"), "No." = field ("Destination Field ID")));
            Editable = false;
        }
        field(10; "Project Field Name"; Text[30])
        {
            Caption = 'Project Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup ("Import Project Data Field"."Field Name" where ("Field ID" = field ("Project Field ID"), ID = field ("Project Table ID")));
            Editable = false;
        }
        field(11; "Project Field Caption"; Text[50])
        {
            Caption = 'Project Field Caption';
            FieldClass = FlowField;
            CalcFormula = lookup ("Import Project Data Field"."Field Caption" where ("Field ID" = field ("Project Field ID"), ID = field ("Project Table ID")));
            Editable = false;
        }
        field(20; "Transformation Rule"; Code[20])
        {
            Caption = 'Transformation Rule';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Transformation Rule";
        }

    }

    keys
    {
        key(PK; "Project Table ID", "Project Field ID", "Destination Table ID")
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

    procedure DeleteFieldMapping(DataID: Guid)
    begin
        SetRange("Project Table ID", DataID);
        if not IsEmpty() then
            DeleteAll();
    end;

    procedure GetWarning(): Text
    var
        ImportProjectDataInfo: Record "Import Project Data Info";
        ImportProjectDataField: Record "Import Project Data Field";
        DestinationFld: Record Field;
    begin
        if not ImportProjectDataInfo.Get("Project Table ID") then exit(SourceTableMissingErr);
        if "Destination Field ID" = 0 then exit(FieldIgnoredMsg);
        ImportProjectDataField.Get("Project Table ID", "Project Field ID");
        if GetIsPrimaryKeyField("Destination Field ID") then exit;
        if not DestinationFld.Get("Destination Table ID", "Destination Field ID") then
            exit(FieldNotFoundMsg);
        if DestinationFld.Enabled <> ImportProjectDataField.Enabled then exit(StrSubstNo(FieldDefMismatchMsg, DestinationFld.FieldCaption(Enabled)));
        if DestinationFld.Class <> DestinationFld.Class::Normal then exit(StrSubstNo(FieldDefMismatchMsg, DestinationFld.FieldCaption(Class)));
        if "Transformation Rule" <> '' then exit;
        if DestinationFld.Len < ImportProjectDataField."Data Length" then exit(StrSubstNo(FieldMismatchMsg, DestinationFld.FieldCaption(Len)));
        if format(DestinationFld.Type) <> ImportProjectDataField."Data Type" then begin
            if (format(DestinationFld.Type) in ['Text', 'Code']) and (ImportProjectDataField."Data Type" in ['Text', 'Code', 'Guid']) then exit;
            if (format(DestinationFld.Type) in ['Date', 'Time', 'DateTime']) and (ImportProjectDataField."Data Type" in ['Date', 'Time', 'DateTime']) then exit;
            if (format(DestinationFld.Type) in ['Integer', 'Option', 'Enum']) and (ImportProjectDataField."Data Type" in ['Integer', 'Option']) then exit;
            exit(StrSubstNo(FieldMismatchMsg, DestinationFld.FieldCaption(Type)));
        end;
    end;

    procedure GetIsPrimaryKeyField(DestinationFieldID: Integer): Boolean
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        PrimaryKeyRef: KeyRef;
        FieldIndex: Integer;
    begin
        RecRef.Open("Destination Table ID");
        PrimaryKeyRef := RecRef.KeyIndex(1);
        for FieldIndex := 1 to PrimaryKeyRef.FieldCount() do begin
            FldRef := PrimaryKeyRef.FieldIndex(FieldIndex);
            if FldRef.Number() = DestinationFieldID then exit(true);
        end;
    end;



    var
        FieldMismatchMsg: Label 'Field Type Mismatch: %1';
        FieldDefMismatchMsg: Label 'Field Definition Mismatch: %1';
        FieldIgnoredMsg: Label 'Field Data will be ignored';
        ExternalFieldMsg: Label 'Field not part of this Application';
        FieldNotFoundMsg: Label 'Field not found';
        SourceTableMissingErr: Label 'Source Table not found in Xml data';


}