codeunit 60324 "Import Source Server Update"
{

    TableNo = "Import Project Data";
    trigger OnRun()
    begin
        ImportFileContent(Rec);
    end;

    local procedure ImportFileContent(var ImportProjectData: Record "Import Project Data")
    var
        RecRef: RecordRef;
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
    begin
        if not FileMgt.ServerFileExists(ImportProjectData."File Name") then exit;
        FileMgt.BLOBImportFromServerFile(TempBlob, ImportProjectData."File Name");
        ImportProjectData."Content Length" := TempBlob.Length();
        RecRef.GetTable(ImportProjectData);
        TempBlob.ToRecordRef(RecRef, ImportProjectData.FieldNo(Content));
        RecRef.Modify(true);
        Commit();
        RecRef.SetTable(ImportProjectData);
    end;

}