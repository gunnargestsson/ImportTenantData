codeunit 60325 "Import Source Server Events"
{
    var
        ImportSourceServerSetup: Record "Import Source Server File";

    [EventSubscriber(ObjectType::Table, Database::"Import Project", 'OnStartDataTransfer', '', false, false)]
    local procedure OnStartDataTransfer(ImportProject: Record "Import Project"; var ImportProjectData: Record "Import Project Data"; ResumeTransfer: Boolean)
    var
        XmlDataTransfer: Codeunit "Import Project Data Transfer";
    begin
        if not ImportSourceServerSetup.Get(ImportProject."Import Source ID") then exit;
        if ResumeTransfer then
            XmlDataTransfer.ResumeDataTransfer(ImportProjectData)
        else
            XmlDataTransfer.ExecuteDataTransfer(ImportProjectData);
    end;

}