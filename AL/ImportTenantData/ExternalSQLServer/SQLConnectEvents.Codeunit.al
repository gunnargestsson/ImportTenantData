codeunit 60341 "SQL Connect Events"
{

    var
        SQLConnectSetup: Record "SQL Connect Setup";

    [EventSubscriber(ObjectType::Table, Database::"Import Project", 'OnStartDataTransfer', '', false, false)]
    local procedure OnStartDataTransfer(ImportProject: Record "Import Project"; var ImportProjectData: Record "Import Project Data"; ResumeTransfer: Boolean)
    begin
        if not SQLConnectSetup.Get(ImportProject."Import Source ID") then exit;
        StartDataTransfer(ImportProjectData, ResumeTransfer);
    end;


    local procedure StartDataTransfer(var ImportProjectData: Record "Import Project Data"; ResumeTransfer: Boolean)
    begin

    end;
}