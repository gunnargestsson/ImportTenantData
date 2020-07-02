codeunit 60321 "Import Project Data Transfer"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        ImportProject: Record "Import Project";
        ImportProjectData: Record "Import Project Data";
    begin
        ImportProjectData.Get("Record ID to Process");
        ImportProjectData.SetRecFilter();
        ImportProject.StartDataTransfer(ImportProjectData, false);
    end;

}