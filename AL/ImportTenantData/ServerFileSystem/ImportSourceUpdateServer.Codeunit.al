codeunit 60324 "Import Source Server Update"
{

    TableNo = "Import Project Data";
    trigger OnRun()
    begin
        ImportFileContent(Rec);
    end;

    local procedure ImportFileContent(var ImportProjectData: Record "Import Project Data")
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        if not FileMgt.ServerFileExists(ImportProjectData."File Name") then exit;
        FileMgt.BLOBImportFromServerFile(TempBlob, ImportProjectData."File Name");
        ImportProjectData."Content Length" := TempBlob.Blob.Length();
        ImportProjectData.Content := TempBlob.Blob;
        ImportProjectData.Modify(true);
        Commit();
    end;

}