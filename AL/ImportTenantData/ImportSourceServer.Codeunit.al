codeunit 60323 "Import Source Server File"
{

    TableNo = "Import Project";
    trigger OnRun()
    var
        Setup: Record "Import Source Server File";
        ImportProjectData: Record "Import Project Data";
        BlobList: Record "Name/Value Buffer" temporary;
        BlobListPage: Page "Server File List";
    begin
        TestField("Import Source ID");
        Setup.Get("Import Source ID");
        ImportFileList(Setup, BlobList);
        while true do begin
            if BlobList.IsEmpty() then exit;
            Clear(BlobListPage);
            BlobListPage.Set(BlobList);
            BlobListPage.LookupMode(true);
            if BlobListPage.RunModal() <> Action::LookupOK then exit;
            BlobListPage.GetSelection(BlobList);
            ImportProjectData.Init();
            ImportProjectData."Project ID" := ID;
            ImportFileContent(Setup, BlobList, ImportProjectData);
            BlobList.Reset();
        end;
    end;

    local procedure ImportFileList(Setup: Record "Import Source Server File"; var BlobList: Record "Name/Value Buffer" temporary)
    var
        FileMgt: Codeunit "File Management";
    begin
        FileMgt.GetServerDirectoryFilesList(BlobList, Setup."File Path");
    end;

    local procedure ImportFileContent(Setup: Record "Import Source Server File"; var BlobList: Record "Name/Value Buffer"; var ImportProjectData: Record "Import Project Data")
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        Window.Open(ImportMsg + '\\#1###################################');
        if BlobList.FindSet() then
            repeat
                Window.Update(1, BlobList."Name");
                FileMgt.BLOBImportFromServerFile(TempBlob, BlobList.Name);
                ImportProjectData."File Name" := BlobList."Name";
                ImportProjectData."Content Length" := TempBlob.Blob.Length();
                ImportProjectData.Content := TempBlob.Blob;
                ImportProjectData.Insert(true);
                Commit();
            until BlobList.Next() = 0;
        Window.Close();
    end;

    local procedure GetImportSourceId() ImportSourceId: Guid
    begin
        Evaluate(ImportSourceId, '9ff82698-ab2d-46bb-9aaa-f2b825a74a0e');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Import Data Source", 'RegisterImportSource', '', false, false)]
    local procedure RegisterImportSource()
    var
        ImportSource: Record "Import Data Source";
        ImportSourceMgt: Codeunit "Import Source Mgt.";
    begin
        if ImportSource.Get(GetImportSourceId()) then exit;
        ImportSource.Init();
        ImportSource.ID := GetImportSourceId();
        ImportSource."Setup Page Name" := ImportSourceMgt.GetPageName(page::"Server File Connect Setup Card");
        ImportSource."Codeunit Name" := ImportSourceMgt.GetCodeunitName(codeunit::"Import Source Server File");
        ImportSource."Content Codeunit Name" := ImportSourceMgt.GetCodeunitName(Codeunit::"Import Source Server Update");
        ImportSource.Description := ServerFileConnectLbl;
        ImportSource.Insert();
    end;

    var
        Window: Dialog;
        ImportMsg: Label 'Importing File';
        ServerFileConnectLbl: Label 'Server File Connect', MaxLength = 50;
}