codeunit 60330 "Azure Blob JSON Connect"
{
    TableNo = "Import Project";
    trigger OnRun()
    var
        Setup: Record "Azure Blob Connect Setup";
        ImportProjectData: Record "Import Project Data";
        BlobList: Record "Azure Blob Connect List" temporary;
        BlobListPage: Page "Azure Blob Connect Selection";
    begin
        TestField("Import Source ID");
        Setup.Get("Import Source ID");
        if (Setup."Account Name" = '') or (Setup."Container Name" = '') or not Setup.HasPassword(Setup."Access Key ID") then
            Error(AuthenticationForAzureBlobContainerMissingErr, AzureBlobConnectLbl);
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
            ImportBlobs(Setup, BlobList, ImportProjectData);
            BlobList.Reset();
        end;
    end;

    procedure GetAzureBlobJSONInterfaceCodeunitName(): Text[30]
    begin
        exit('Azure Blob JSON Interface');
    end;

    local procedure ImportFileList(Setup: Record "Azure Blob Connect Setup"; var BlobList: Record "Azure Blob Connect List" temporary)
    var
        Buffer: Record "Name/Value Buffer" temporary;
        ImportSourceMgt: Codeunit "Import Source Mgt.";
        JObject: JsonObject;
        JSON: Text;
    begin
        Setup.VerifySetup();
        if ImportSourceMgt.GetCodeunitID(GetAzureBlobJSONInterfaceCodeunitName()) = 0 then
            error(AzureBlobJSONInterfaceErr);

        SetConfiguration(Setup."Account Name", Setup."Container Name", Setup.GetPassword(Setup."Access Key ID"), JObject);
        JObject.Add('Method', 'ListBlob');
        JObject.WriteTo(JSON);
        Buffer.AddNewEntry('', JSON);
        Codeunit.Run(ImportSourceMgt.GetCodeunitID(GetAzureBlobJSONInterfaceCodeunitName()), Buffer);
        JObject.ReadFrom(Buffer.GetValue());
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

    local procedure ImportBlobs(Setup: Record "Azure Blob Connect Setup"; var BlobList: Record "Azure Blob Connect List"; var ImportProjectData: Record "Import Project Data")
    begin
        Window.Open(ImportMsg + '\\#1###################################');
        if BlobList.FindSet() then
            repeat
                Window.Update(1, BlobList."File Name");
                ImportProjectData."File Name" := BlobList."File Name";
                ImportProjectData."Last Modified" := CreateDateTime(BlobList."Modified Date", BlobList."Modified Time");
                ImportProjectData."Content Length" := BlobList."Content Length";
                ImportBlobContent(Setup, BlobList, ImportProjectData);
            until BlobList.Next() = 0;
        Window.Close();
    end;

    local procedure ImportBlobContent(Setup: Record "Azure Blob Connect Setup"; var BlobList: Record "Azure Blob Connect List"; var ImportProjectData: Record "Import Project Data")
    var
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
    begin
        GetBlob(Setup, BlobList."File Name", TempBlob);
        RecRef.GetTable(ImportProjectData);
        TempBlob.ToRecordRef(RecRef, ImportProjectData.FieldNo(Content));
        RecRef.Insert(true);
        Commit();
    end;

    local procedure GetBlob(Setup: Record "Azure Blob Connect Setup"; FileName: Text; var TempBlob: Codeunit "Temp Blob")
    var
        Buffer: Record "Name/Value Buffer" temporary;
        ImportSourceMgt: Codeunit "Import Source Mgt.";
        Base64: Codeunit "Base64 Convert";
        JObject: JsonObject;
        JToken: JsonToken;
        OutStr: OutStream;
        JSON: Text;
    begin
        SetConfiguration(Setup."Account Name", Setup."Container Name", Setup.GetPassword(Setup."Access Key ID"), JObject);
        JObject.Add('Method', 'GetBlob');
        JObject.Add('Url', 'https://' + Setup."Account Name" + '.blob.core.windows.net/' + Setup."Container Name" + '/' + FileName);
        JObject.WriteTo(JSON);
        Buffer.AddNewEntry('', JSON);
        Codeunit.Run(ImportSourceMgt.GetCodeunitID(GetAzureBlobJSONInterfaceCodeunitName()), Buffer);
        JObject.ReadFrom(Buffer.GetValue());
        JObject.Get('Content', JToken);
        TempBlob.CreateOutStream(OutStr);
        Base64.FromBase64(JToken.AsValue().AsText(), OutStr);
    end;

    local procedure SetConfiguration(AccountName: Text; AccountContainer: Text; AccountAccessKey: Text; var JObject: JsonObject)
    begin
        Clear(JObject);
        JObject.Add('Name', AccountName);
        JObject.Add('Container', AccountContainer);
        JObject.Add('AccessKey', AccountAccessKey);
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
        ImportSource.Description := AzureBlobConnectLbl;
        ImportSource.Insert();
    end;

    var
        Window: Dialog;
        ImportMsg: Label 'Importing File';
        AzureBlobJSONInterfaceErr: Label 'Azure Blob JSON interface not found';
        AzureBlobConnectLbl: Label 'Azure Blob Connect', MaxLength = 50;
        AuthenticationForAzureBlobContainerMissingErr: Label 'Authentication for Azure Blob container is missing in %1', Comment = '%1 = AzureBlobConnectLbl label';

}