codeunit 60340 "SQL Connect"
{
    TableNo = "Import Project";
    trigger OnRun()
    var
        Setup: Record "SQL Connect Setup";
        ImportProjectData: Record "Import Project Data";
        BlobList: Record "Name/Value Buffer" temporary;
        BlobListPage: Page "SQL Connect Table Selection";
        SQLConnection: DotNet SqlConnection;
        SQLCompanyName: Text[30];
    begin
        TestField("Import Source ID");
        Setup.Get("Import Source ID");
        if not Setup.HasPassword(Setup."Connection String Key ID") then
            Error(SQLConnectionMissingErr, SQLConnectLbl);
        OpenConnection(Setup, SQLConnection);
        SQLCompanyName := SelectCompany(SQLConnection);
        if SQLCompanyName = '' then exit;
        ImportFileList(SQLConnection, SQLCompanyName, BlobList);
        CloseConnection(SQLConnection);
        while true do begin
            if BlobList.IsEmpty() then exit;
            Clear(BlobListPage);
            BlobListPage.Set(BlobList);
            BlobListPage.LookupMode(true);
            if BlobListPage.RunModal() <> Action::LookupOK then exit;
            BlobListPage.GetSelection(BlobList);
            ImportProjectData.Init();
            ImportProjectData."Project ID" := ID;
            ImportFileContent(SQLCompanyName, BlobList, ImportProjectData);
            BlobList.Reset();
        end;
    end;

    local procedure OpenConnection(Setup: Record "SQL Connect Setup"; var SQLConnection: DotNet SqlConnection)
    var
        ConnectionString: Text;
    begin
        if not IsNull(SQLConnection) then
            exit;

        ConnectionString := Setup.GetPassword(Setup."Connection String Key ID");
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
    end;

    local procedure SelectCompany(var SQLConnection: DotNet SqlConnection) SQLCompanyName: Text[30]
    var
        CompanyList: Record "Name/Value Buffer" temporary;
        CompanySelection: Page "SQL Connect Company Selection";
        SQLReader: DotNet SqlDataReader;
    begin
        if not ExecuteReader(SQLConnection, 'SELECT DISTINCT [Company] FROM Object', SQLReader) then
            Error(NoObjectsFoundErr);
        while SQLReader.Read() do
            CompanyList.AddNewEntry(SQLReader.GetString(0), '');
        SQLReader.Close();
        if CompanyList.Count() = 1 then exit(CopyStr(CompanyList.Name, 1, MaxStrLen(SQLCompanyName)));
        CompanySelection.Set(CompanyList);
        CompanySelection.Editable(false);
        CompanySelection.LookupMode(true);
        if CompanySelection.RunModal() <> Action::LookupOK then exit('');
        CompanySelection.GetSelection(CompanyList);
        SQLCompanyName := CopyStr(CompanyList.Name, 1, MaxStrLen(SQLCompanyName));
    end;

    local procedure ImportFileList(var SQLConnection: DotNet SqlConnection; SQLCompanyName: Text[30]; var BlobList: Record "Name/Value Buffer" temporary)
    var
        SQLReader: DotNet SqlDataReader;
    begin
        if not ExecuteReader(SQLConnection, StrSubstNo('SELECT [Name],[MetaData] FROM Object WHERE [Company] = ''%1''', SQLCompanyName), SQLReader) then
            Error(NoObjectsFoundErr);
        while SQLReader.Read() do
            BlobList.AddNewEntry(SQLReader.GetString(0), SQLReader.GetString(1));
        SQLReader.Close();
    end;

    local procedure ImportFileContent(SQLCompanyName: Text[30]; var BlobList: Record "Name/Value Buffer"; var ImportProjectData: Record "Import Project Data")
    var
        TempBlob: Record TempBlob;
    begin
        if BlobList.FindSet() then
            repeat
                TempBlob.WriteAsText(BlobList.GetValue(), TextEncoding::UTF8);
                ImportProjectData."File Name" := CopyStr(StrSubStNo('%1$%2', SQLCompanyName, BlobList."Name"), 1, MaxStrLen(ImportProjectData."File Name"));
                ImportProjectData."Content Length" := TempBlob.Blob.Length();
                ImportProjectData.Content := TempBlob.Blob;
                ImportProjectData.Insert(true);
                Commit();
            until BlobList.Next() = 0;
        BlobList.DeleteAll();
    end;

    local procedure CloseConnection(var SQLConnection: DotNet SqlConnection)
    begin
        if IsNull(SQLConnection) then
            exit;

        if SQLConnection.State() = 1 then
            SQLConnection.Close();
        Clear(SQLConnection);
    end;

    procedure ExecuteReader(var SQLConnection: DotNet SqlConnection; SQLQuery: Text; var SQLReader: DotNet SqlDataReader): Boolean
    var
        SQLCommand: DotNet SqlCommand;
    begin
        SQLCommand := SQLCommand.SqlCommand(SQLQuery, SQLConnection);
        SQLCommand.CommandTimeout(300);
        SQLReader := SQLCommand.ExecuteReader();
        exit(SQLReader.HasRows());
    end;

    local procedure GetImportSourceId() ImportSourceId: Guid
    begin
        Evaluate(ImportSourceId, 'f7e1afdf-8b48-45c2-99c9-d39bcd19f77e');
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
        ImportSource."Setup Page Name" := ImportSourceMgt.GetPageName(page::"SQL Connect Setup Card");
        ImportSource."Codeunit Name" := ImportSourceMgt.GetCodeunitName(codeunit::"SQL Connect");
        ImportSource.Description := SQLConnectLbl;
        ImportSource.Insert();
    end;

    var
        SQLConnectLbl: Label 'SQL Connect', MaxLength = 50;
        SQLConnectionMissingErr: Label 'Connection string for the SQL database is missing in %1', Comment = '%1 = SQLConnectLbl label';
        NoObjectsFoundErr: Label 'No tables found in the database';

}