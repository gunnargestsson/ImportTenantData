codeunit 60331 "Azure Blob Connect Events"
{

    var
        AzureBlobConnectSetup: Record "Azure Blob Connect Setup";

    [EventSubscriber(ObjectType::Table, Database::"Import Project", 'OnStartDataTransfer', '', false, false)]
    local procedure OnStartDataTransfer(ImportProject: Record "Import Project"; var ImportProjectData: Record "Import Project Data"; ResumeTransfer: Boolean)
    var
        XmlDataTransfer: Codeunit "Xml File Data Transfer";
    begin
        if not AzureBlobConnectSetup.Get(ImportProject."Import Source ID") then exit;
        if ResumeTransfer then
            XmlDataTransfer.ResumeDataTransfer(ImportProjectData)
        else
            XmlDataTransfer.ExecuteDataTransfer(ImportProjectData);
    end;

}