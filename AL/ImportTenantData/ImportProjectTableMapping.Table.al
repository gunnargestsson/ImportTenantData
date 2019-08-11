table 60310 "Import Project Table Mapping"
{
    DataClassification = SystemMetadata;
    Caption = 'Import Project Table Mapping';
    DataCaptionFields = "Destination Table Caption";

    fields
    {
        field(2; "Project Table ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Project Table ID';
            TableRelation = "Import Project Data".ID;
        }
        field(3; "Destination Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Destination Table ID';
            TableRelation = AllObjWithCaption."Object ID" where ("Object Type" = const ("Table"));
            NotBlank = true;

            trigger OnValidate()
            begin
                CalculateDestinationTableRecordCount();
                UpdateFieldMapping();
                CalcFields("Destination Table Name", "Destination Table Caption");
            end;
        }
        field(4; "Destination Table Name"; Text[30])
        {
            Caption = 'Destination Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup (AllObjWithCaption."Object Name" where ("Object Type" = const (table), "Object ID" = field ("Destination Table ID")));
            Editable = false;
        }
        field(5; "Destination Table Caption"; Text[50])
        {
            Caption = 'Destination Table Caption';
            FieldClass = FlowField;
            CalcFormula = lookup (AllObjWithCaption."Object Caption" where ("Object Type" = const (table), "Object ID" = field ("Destination Table ID")));
            Editable = false;
        }
        field(6; "Destination Table Record Count"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Destination Table Record Count';
            Editable = false;
        }
        field(30; "Template Record"; RecordId)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Template Record';
        }
        field(40; "No. of Records"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'No. of Records';
        }
        field(41; "No. of Imported Records"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'No. of Imported Records';
        }
    }

    keys
    {
        key(PK; "Project Table ID", "Destination Table ID")
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
        DeleteFieldMapping();
    end;

    trigger OnRename()
    begin

    end;

    procedure DeleteTableMapping(DataID: Guid)
    begin
        SetRange("Project Table ID", DataID);
        if not IsEmpty() then
            DeleteAll();
    end;

    local procedure DeleteFieldMapping()
    var
        DataFieldMapping: Record "Import Project Field Mapping";
    begin
        DataFieldMapping.SetRange("Project Table ID", "Project Table ID");
        DataFieldMapping.SetRange("Destination Table ID", "Destination Table ID");
        if not DataFieldMapping.IsEmpty() then
            DataFieldMapping.DeleteAll();
    end;

    local procedure CalculateDestinationTableRecordCount()
    var
        RecRef: RecordRef;
    begin
        if "Destination Table ID" = 0 then
            "Destination Table Record Count" := 0
        else begin
            RecRef.Open("Destination Table ID");
            "Destination Table Record Count" := RecRef.Count();
        end;
    end;

    local procedure UpdateFieldMapping()
    var
        DataFieldMapping: Record "Import Project Field Mapping";
        ImportDataField: Record "Import Project Data Field";
    begin
        DeleteFieldMapping();
        ImportDataField.SetRange(ID, "Project Table ID");
        if ImportDataField.FindSet() then
            repeat
                DataFieldMapping.Init();
                DataFieldMapping."Project Table ID" := "Project Table ID";
                DataFieldMapping."Destination Table ID" := "Destination Table ID";
                DataFieldMapping."Project Field ID" := ImportDataField."Field ID";
                if DataFieldMapping.GetIsPrimaryKeyField(ImportDataField."Field ID") then
                    DataFieldMapping."Destination Field ID" := ImportDataField."Field ID";
                DataFieldMapping.Insert();
            until ImportDataField.Next() = 0;
    end;


}