codeunit 60330 "Azure Blob JSON Connect"
{
    TableNo = "Import Project";
    trigger OnRun()
    var
        Setup: Record "Azure Blob Connect Setup";
        ImportProjectData: Record "Import Project Data";
        BlobList: Record "Azure Blob Connect List" temporary;
        BlobListPage: Page "Azure Blob Connect List";
    begin
        TestField("Import Source ID");
        Setup.Get("Import Source ID");
        ImportFileList(Setup, BlobList);
        while true do begin
            RemoveDuplicates(Rec, BlobList);
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

    procedure GetAzureBlobJSONInterfaceCodeunitName(): Text
    begin
        exit('Azure Blob JSON Interface');
    end;

    local procedure ImportFileList(Setup: Record "Azure Blob Connect Setup"; var BlobList: Record "Azure Blob Connect List" temporary)
    var
        Tempblob: Record TempBlob;
        ImportSourceMgt: Codeunit "Import Source Mgt.";
        JObject: JsonObject;
        JSON: Text;
    begin
        Setup.VerifySetup();
        if ImportSourceMgt.GetCodeunitID(GetAzureBlobJSONInterfaceCodeunitName()) = 0 then
            error(AzureBlobJSONInterfaceErr);

        SetConfiguration(Setup."Account Name", Setup."Container Name", Setup.GetPassword(Setup."Private Key ID"), JObject);
        JObject.Add('Method', 'ListBlob');
        JObject.WriteTo(JSON);
        Tempblob.WriteAsText(JSON, TextEncoding::UTF8);
        Codeunit.Run(ImportSourceMgt.GetCodeunitID(GetAzureBlobJSONInterfaceCodeunitName()), Tempblob);
        JObject.ReadFrom(Tempblob.ReadAsTextWithCRLFLineSeparator());
        BlobList.ReadFromJSON(JObject);
    end;

    local procedure RemoveDuplicates(Project: Record "Import Project"; var BlobList: Record "Azure Blob Connect List" temporary)
    var
        ImportProjectData: Record "Import Project Data";
    begin
        ImportProjectData.SetRange("Project ID", Project.ID);
        if ImportProjectData.FindSet() then
            repeat
                BlobList.SetRange("File Name", ImportProjectData."File Name");
                BlobList.DeleteAll();
            until ImportProjectData.Next() = 0;
        BlobList.Reset();
    end;

    local procedure ImportFileContent(Setup: Record "Azure Blob Connect Setup"; var BlobList: Record "Azure Blob Connect List"; var ImportProjectData: Record "Import Project Data")
    var
        TempBlob: Record TempBlob;
    begin
        if BlobList.FindSet() then
            repeat
                ImportProjectData."File Name" := BlobList."File Name";
                ImportProjectData."Last Modified" := CreateDateTime(BlobList."Modified Date", BlobList."Modified Time");
                ImportProjectData."Content Length" := BlobList."Content Length";
                GetBlob(Setup, BlobList."File Name", TempBlob);
                ImportProjectData.Content := TempBlob.Blob;
                ImportProjectData.Insert(true);
                Commit();
            until BlobList.Next() = 0;
    end;

    local procedure GetBlob(Setup: Record "Azure Blob Connect Setup"; FileName: Text; var TempBlob: Record Tempblob)
    var
        ImportSourceMgt: Codeunit "Import Source Mgt.";
        JObject: JsonObject;
        JToken: JsonToken;
        JSON: Text;
    begin
        SetConfiguration(Setup."Account Name", Setup."Container Name", Setup.GetPassword(Setup."Private Key ID"), JObject);
        JObject.Add('Method', 'GetBlob');
        JObject.Add('Url', 'https://' + Setup."Account Name" + '.blob.core.windows.net/' + Setup."Container Name" + '/' + FileName);
        JObject.WriteTo(JSON);
        Tempblob.WriteAsText(JSON, TextEncoding::UTF8);
        Codeunit.Run(ImportSourceMgt.GetCodeunitID(GetAzureBlobJSONInterfaceCodeunitName()), Tempblob);
        JObject.ReadFrom(Tempblob.ReadAsTextWithCRLFLineSeparator());
        JObject.Get('Content', JToken);
        Tempblob.Init();
        Tempblob.FromBase64String(JToken.AsValue().AsText());
    end;

    local procedure SetConfiguration(AccountName: Text; AccountContainer: Text; AccountPrivateKey: Text; var JObject: JsonObject)
    begin
        Clear(JObject);
        JObject.Add('Name', AccountName);
        JObject.Add('Container', AccountContainer);
        JObject.Add('PrivateKey', AccountPrivateKey);
    end;

    local procedure GetImportSourceId() ImportSourceId: Guid
    begin
        Evaluate(ImportSourceId, '2192cb70-dbba-4c99-acf6-e482dbdf2794');
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
        ImportSource."Setup Page Name" := ImportSourceMgt.GetPageName(page::"Azure Blob Connect Setup Card");
        ImportSource."Codeunit Name" := ImportSourceMgt.GetCodeunitName(codeunit::"Azure Blob JSON Connect");
        ImportSource.Description := AzureBlobConnect;
        ImportSource.Insert();
    end;

    var
        Window: Dialog;
        ImportMsg: Label 'Importing File';
        AzureBlobJSONInterfaceErr: Label 'Azure Blob JSON interface not found';
        AzureBlobConnect: Label 'Azure Blob Connect', MaxLength = 50;

}