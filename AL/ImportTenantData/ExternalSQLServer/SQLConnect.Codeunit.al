codeunit 60340 "SQL Connect"
{
    TableNo = "Import Project";
    trigger OnRun()
    var
        Setup: Record "SQL Connect Setup";
        ImportProjectData: Record "Import Project Data";
        BlobList: Record "Name/Value Buffer" temporary;
        BlobListPage: Page "SQL Connect Table Selection";
        SQLConnection: DotNet O4N_SqlConnection;
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
        while true do begin
            if BlobList.IsEmpty() then exit;
            RemoveDuplicates(Rec, SQLCompanyName, BlobList);
            Clear(BlobListPage);
            BlobListPage.Set(BlobList);
            BlobListPage.LookupMode(true);
            if BlobListPage.RunModal() <> Action::LookupOK then exit;
            BlobListPage.GetSelection(BlobList);
            ImportProjectData.Init();
            ImportProjectData."Project ID" := ID;
            ImportFileContent(SQLConnection, SQLCompanyName, BlobList, ImportProjectData);
            BlobList.Reset();
        end;
        CloseConnection(SQLConnection);        
    end;

    procedure OpenConnection(Setup: Record "SQL Connect Setup"; var SQLConnection: DotNet O4N_SqlConnection)
    var
        ConnectionString: Text;
    begin
        if not IsNull(SQLConnection) then
            exit;

        ConnectionString := Setup.GetPassword(Setup."Connection String Key ID");
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();
    end;

    procedure CloseConnection(var SQLConnection: DotNet O4N_SqlConnection)
    begin
        if IsNull(SQLConnection) then
            exit;

        if SQLConnection.State() = 1 then
            SQLConnection.Close();
        Clear(SQLConnection);
    end;

    procedure ExecuteReader(var SQLConnection: DotNet O4N_SqlConnection; SQLQuery: Text; var SQLReader: DotNet O4N_SqlDataReader): Boolean
    var
        SQLCommand: DotNet O4N_SqlCommand;
    begin
        SQLCommand := SQLCommand.SqlCommand(SQLQuery, SQLConnection);
        SQLCommand.CommandTimeout(300);
        SQLReader := SQLCommand.ExecuteReader();
        exit(SQLReader.HasRows());
    end;

    procedure GetSQLTableName(TableName: Text) SQLTableName: Text
    begin
        SQLTableName := ConvertStr(TableName, '."\/%][''', '________');
    end;


    local procedure SelectCompany(var SQLConnection: DotNet O4N_SqlConnection) SQLCompanyName: Text[30]
    var
        CompanyList: Record "Name/Value Buffer" temporary;
        CompanySelection: Page "SQL Connect Company Selection";
        SQLReader: DotNet O4N_SqlDataReader;
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

    local procedure RemoveDuplicates(Project: Record "Import Project"; SQLCompanyName: Text[30]; var BlobList: Record "Name/Value Buffer")
    var
        ImportProjectData: Record "Import Project Data";
    begin
        ImportProjectData.SetRange("Project ID", Project.ID);
        if BlobList.FindSet() then
            repeat
                ImportProjectData.SetFilter("File Name", '%1|%2', BlobList.Name, StrSubStNo('%1$%2', SQLCompanyName, BlobList.Name));
                if not ImportProjectData.IsEmpty() then
                    BlobList.Delete();
            until BlobList.Next() = 0;
    end;

    local procedure ImportFileList(var SQLConnection: DotNet O4N_SqlConnection; SQLCompanyName: Text[30]; var BlobList: Record "Name/Value Buffer" temporary)
    var
        SQLReader: DotNet O4N_SqlDataReader;
    begin
        if not ExecuteReader(SQLConnection, StrSubstNo('SELECT [Name],[MetaData] FROM Object WHERE [Company] = ''%1''', SQLCompanyName), SQLReader) then
            Error(NoObjectsFoundErr);
        while SQLReader.Read() do
            BlobList.AddNewEntry(SQLReader.GetString(0), FromBase64(SQLReader.GetString(1)));
        SQLReader.Close();
    end;

    local procedure FromBase64(Base64Text: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        Base64: Codeunit "Base64 Convert";
        OutStr: OutStream;
        InStr: Instream;
    begin
        TempBlob.CreateOutStream(OutStr);
        Base64.FromBase64(Base64Text, OutStr);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator()));
    end;

    local procedure ImportFileContent(var SQLConnection: DotNet O4N_SqlConnection; SQLCompanyName: Text[30]; var BlobList: Record "Name/Value Buffer"; var ImportProjectData: Record "Import Project Data")
    var
        OutStr: OutStream;
    begin
        if BlobList.FindSet() then
            repeat
                ImportProjectData."File Name" := GetTableName(SQLConnection, SQLCompanyName, BlobList.Name);
                Clear(ImportProjectData.Content);
                ImportProjectData.Content.CreateOutStream(OutStr, TextEncoding::UTF8);
                OutStr.WriteText(BlobList.GetValue());
                ImportProjectData."Content Length" := ImportProjectData.Content.Length();
                ImportProjectData.Insert(true);
                Commit();
            until BlobList.Next() = 0;
        BlobList.DeleteAll();
    end;

    local procedure GetTableName(var SQLConnection: DotNet O4N_SqlConnection; SQLCompanyName: Text[30]; SQLTableName: Text) TableName: Text[250]
    var
        SQLReader: DotNet O4N_SqlDataReader;
        SQLQuery: Text;
    begin
        SQLQuery := StrSubstNo('SELECT [TABLE_NAME] FROM INFORMATION_SCHEMA.TABLES WHERE [TABLE_NAME] IN (''%2'',''%1$%2'')', GetSQLTableName(SQLCompanyName), GetSQLTableName(SQLTableName));
        ExecuteReader(SQLConnection, SQLQuery, SQLReader);
        SQLReader.Read();
        TableName := CopyStr(SQLReader.GetString(0), 1, MaxStrLen(TableName));
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