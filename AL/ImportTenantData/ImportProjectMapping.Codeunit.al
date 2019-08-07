codeunit 60310 "Import Project Apply Mapping"
{
    trigger OnRun()
    begin

    end;

    procedure ApplyImportedMapping(var ProjectData: Record "Import Project Data"; var ProjectDataInfo: Record "Import Project Data Info"; var TableMapping: Record "Import Project Table Mapping"; var FieldMapping: Record "Import Project Field Mapping")
    var
        ImportProject: Record "Import Project";
        ProjectTableID: Guid;
    begin
        if not ProjectData.FindFirst() then exit;
        ImportProject.Get(ProjectData."Project ID");
        if ProjectDataInfo.FindSet() then
            repeat
                ProjectTableID := FindMatchingTable(ProjectDataInfo);
                if not IsNullGuid(ProjectTableID) then begin
                    AddTableMapping(ProjectTableID, ProjectDataInfo.ID, TableMapping, FieldMapping);
                end;
            until ProjectDataInfo.Next() = 0;
    end;

    local procedure FindMatchingTable(TempProjectDataInfo: Record "Import Project Data Info"): Guid
    var
        ProjectDataInfo: Record "Import Project Data Info";
    begin
        ProjectDataInfo.SetRange("Table ID", TempProjectDataInfo."Table ID");
        if ProjectDataInfo.FindFirst() then
            exit(ProjectDataInfo.ID);
    end;

    local procedure AddTableMapping(ProjectTableID: Guid; ImportTableID: Guid; var TempTableMapping: Record "Import Project Table Mapping"; var TempFieldMapping: Record "Import Project Field Mapping")
    var
        TableMapping: Record "Import Project Table Mapping";
    begin
        TempTableMapping.SetRange("Project Table ID", ImportTableID);
        TempFieldMapping.SetRange("Project Table ID", ImportTableID);
        if TempTableMapping.FindSet() then
            repeat
                TempFieldMapping.SetRange("Destination Table ID", TempTableMapping."Destination Table ID");
                if not TableMapping.Get(ProjectTableID, TempTableMapping."Destination Table ID") then begin
                    TableMapping.Init();
                    TableMapping."Project Table ID" := ProjectTableID;
                    TableMapping.Validate("Destination Table ID", TempTableMapping."Destination Table ID");
                    TableMapping.Insert(true);
                end;
                AddFieldMapping(TableMapping, TempFieldMapping);
            until TempTableMapping.Next() = 0;
    end;

    local procedure AddFieldMapping(TableMapping: Record "Import Project Table Mapping"; var TempFieldMapping: Record "Import Project Field Mapping")
    var
        FieldMapping: Record "Import Project Field Mapping";
    begin
        if TempFieldMapping.FindSet() then
            repeat
                if not FieldMapping.Get(TableMapping."Project Table ID", TempFieldMapping."Project Field ID", TableMapping."Destination Table ID") then begin
                    FieldMapping.Init();
                    FieldMapping."Project Table ID" := TableMapping."Project Table ID";
                    FieldMapping."Destination Table ID" := TableMapping."Destination Table ID";
                    FieldMapping."Project Field ID" := TempFieldMapping."Project Field ID";
                    FieldMapping.Validate("Destination Field ID", TempFieldMapping."Destination Field ID");
                    FieldMapping."Transformation Rule" := TempFieldMapping."Transformation Rule";
                    FieldMapping.Insert(true);
                end else begin
                    FieldMapping.Validate("Destination Field ID", TempFieldMapping."Destination Field ID");
                    FieldMapping."Transformation Rule" := TempFieldMapping."Transformation Rule";
                    FieldMapping.Modify(true);
                end;
            until TempFieldMapping.Next() = 0;

    end;

}