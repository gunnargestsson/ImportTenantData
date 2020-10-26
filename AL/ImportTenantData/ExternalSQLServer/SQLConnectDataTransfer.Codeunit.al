codeunit 60342 "SQL Connect Data Transfer"
{
    [EventSubscriber(ObjectType::Table, Database::"Import Project", 'OnStartDataTransfer', '', false, false)]
    local procedure OnStartDataTransfer(ImportProject: Record "Import Project"; var ImportProjectData: Record "Import Project Data"; ResumeTransfer: Boolean)
    var
        Setup: Record "SQL Connect Setup";
    begin
        if not Setup.Get(ImportProject."Import Source ID") then exit;
        SQLConnect.OpenConnection(Setup, SQLConnection);
        StartDataTransfer(ImportProjectData, ResumeTransfer);
        SQLConnect.CloseConnection(SQLConnection);
    end;

    local procedure StartDataTransfer(var ImportProjectData: Record "Import Project Data"; ResumeTransfer: Boolean)
    var
        StartTime: DateTime;
        Total: Integer;
        Counter: Integer;
    begin
        StartTime := RoundDateTime(CurrentDateTime());
        Window.Open(DialogMsg);
        with ImportProjectData do begin
            SetCurrentKey("File Name");
            Total := Count();
            SetAutoCalcFields("Table Name");
            FindSet();
            repeat
                Counter += 1;
                Window.Update(1, "Table Name");
                Window.Update(2, StrSubStNo('%1 / %2', Counter, Total));
                Window.Update(3, 0);
                ExecuteDataTransferForTable(ImportProjectData, ResumeTransfer);
            until Next() = 0;
        end;
        Window.Close();
        Message(DataImportFinishedMsg, (RoundDateTime(CurrentDateTime()) - StartTime));
    end;

    local procedure ExecuteDataTransferForTable(ImportProjectData: Record "Import Project Data"; ResumeTransfer: Boolean)
    var
        ImportProjectTableMapping: Record "Import Project Table Mapping";
        TemplateRecRef: RecordRef;
        HasTemplateRecRef: Boolean;
    begin
        with ImportProjectTableMapping do begin
            SetRange("Project Table ID", ImportProjectData.ID);
            SetFilter("Destination Table ID", '>%1', 0);
            if FindSet() then
                repeat
                    HasTemplateRecRef := TemplateRecRef.Get("Template Record");
                    CopyData(ImportProjectData, ImportProjectTableMapping, HasTemplateRecRef, TemplateRecRef, ResumeTransfer);
                until Next() = 0;
        end;
    end;

    local procedure CopyData(ImportProjectData: Record "Import Project Data"; ImportProjectTableMapping: Record "Import Project Table Mapping"; HasTemplateRecRef: Boolean; TemplateRecRef: RecordRef; ResumeTransfer: Boolean)
    var
        DestRecRef: RecordRef;
        InitDestRecRef: RecordRef;
        SQLReader: DotNet O4N_SqlDataReader;
        Total: Integer;
        Counter: Integer;
        UpdateRow: Boolean;
    begin
        Total := InitializeReferences(ImportProjectData, ImportProjectTableMapping, SQLReader, InitDestRecRef);
        if Total = 0 then exit;
        OnBeforeTableProcess(ImportProjectTableMapping, SQLConnection);
        while SQLReader.Read() do begin
            Counter += 1;
            if (Counter >= ImportProjectTableMapping."No. of Imported Records") or not ResumeTransfer then begin
                DestRecRef := InitDestRecRef.Duplicate();
                OnBeforeRecordProcess(ImportProjectTableMapping, SQLConnection, SQLReader, DestRecRef);
                DestRecRef.LockTable(true);
                PopulatePrimaryKey(ImportProjectData.ID, SQLReader, DestRecRef);
                UpdateRow := DestRecRef.Find();
                if not UpdateRow then
                    DestRecRef.Init();
                OnBeforeCopyFields(ImportProjectTableMapping, SQLReader, DestRecRef);
                CopyFields(ImportProjectTableMapping, SQLReader, DestRecRef);
                OnAfterCopyFields(ImportProjectTableMapping, SQLReader, DestRecRef);
                if HasTemplateRecRef then
                    ApplyTemplateRecord(TemplateRecRef, DestRecRef);
                OnAfterRecordProcess(ImportProjectTableMapping, SQLConnection, SQLReader, DestRecRef);
                if UpdateRow then begin
                    OnBeforeModify(ImportProjectTableMapping, SQLReader, DestRecRef);
                    DestRecRef.Modify();
                end else
                    if ImportProjectData."Missing Record Handling" = ImportProjectData."Missing Record Handling"::Create then begin
                        OnBeforeInsert(ImportProjectTableMapping, SQLReader, DestRecRef);
                        if DestRecRef.Insert() then;
                    end;
                UpdateImportedRecords(ImportProjectData, ImportProjectTableMapping, Counter, Total);
            end;
            if Counter MOD 100 = 0 then
                Window.Update(3, StrSubStNo('%1 / %2', Counter, Total));
        end;
        OnAfterTableProcess(ImportProjectTableMapping, SQLConnection);
        ImportProjectTableMapping.Modify();
    end;

    local procedure UpdateImportedRecords(ImportProjectData: Record "Import Project Data"; var ImportProjectTableMapping: Record "Import Project Table Mapping"; Counter: Integer; Total: Integer)
    begin
        ImportProjectTableMapping."No. of Records" := Total;
        ImportProjectTableMapping."No. of Imported Records" := Counter;

        case ImportProjectData."Commit Interval" of
            ImportProjectData."Commit Interval"::"Every record":
                begin
                    ImportProjectTableMapping.Modify();
                    Commit();
                end;

            ImportProjectData."Commit Interval"::"Every 100 records":
                if Counter MOD 100 = 0 then begin
                    ImportProjectTableMapping.Modify();
                    Commit();
                end;
            ImportProjectData."Commit Interval"::"Every 1.000 records":
                if Counter MOD 1000 = 0 then begin
                    ImportProjectTableMapping.Modify();
                    Commit();
                end;
            ImportProjectData."Commit Interval"::"Every 10.000 records":
                if Counter MOD 10000 = 0 then begin
                    ImportProjectTableMapping.Modify();
                    Commit();
                end;
        end;
        ImportProjectTableMapping.LockTable(true);
    end;

    local procedure InitializeReferences(ImportProjectData: Record "Import Project Data"; ImportProjectTableMapping: Record "Import Project Table Mapping"; var SQLReader: DotNet O4N_SqlDataReader; var DestRecRef: RecordRef) RowCount: Integer
    var
        ImportProjectField: Record "Import Project Data Field";
        FieldList: TextBuilder;
    begin
        if not SQLConnect.ExecuteReader(SQLConnection, StrSubstNo('SELECT COUNT(*) FROM [%1]', SQLConnect.GetSQLTableName(ImportProjectData."File Name")), SQLReader) then exit(0);
        DestRecRef.Open(ImportProjectTableMapping."Destination Table Id");
        if SQLReader.Read() then
            RowCount := SQLReader.GetInt32(0);
        SQLReader.Close();
        ImportProjectField.GetFieldList(ImportProjectData.ID, FieldList);
        SQLConnect.ExecuteReader(SQLConnection, StrSubstNo('SELECT %1 FROM [%2]', FieldList.ToText(), SQLConnect.GetSQLTableName(ImportProjectData."File Name")), SQLReader);
    end;

    local procedure CopyFields(ImportProjectTableMapping: Record "Import Project Table Mapping"; SQLReader: DotNet O4N_SqlDataReader; var DestRecRef: RecordRef)
    var
        ImportProjectFieldMapping: Record "Import Project Field Mapping";
        ImportProjectField: Record "Import Project Data Field";
        DestFldRef: FieldRef;
    begin
        FilterFields(ImportProjectTableMapping, ImportProjectFieldMapping);
        with ImportProjectFieldMapping do
            if FindSet() then
                repeat
                    if not GetIsPrimaryKeyField("Destination Field ID") then begin
                        ImportProjectField.Get("Project Table ID", "Project Field ID");
                        DestFldRef := DestRecRef.Field("Destination Field ID");
                        CopyValue(ImportProjectField, "Destination Table Id", SQLReader, ImportProjectField.GetFieldIndex(), DestFldRef);
                    end;
                until Next() = 0;
    end;

    local procedure ApplyTemplateRecord(TemplateRecRef: RecordRef; var DestRecRef: RecordRef)
    var
        CleanRecRef: RecordRef;
        CleanFldRef: FieldRef;
        TemplateFldRef: FieldRef;
        DstFldRef: FieldRef;
        FieldIndex: Integer;
    begin
        CleanRecRef.Open(DestRecRef.Number());
        CleanRecRef.Init();
        for FieldIndex := 1 to CleanRecRef.FieldCount() do begin
            CleanFldRef := CleanRecRef.FieldIndex(FieldIndex);
            if (CleanFldRef.Class() = FieldClass::Normal) and
                CleanFldRef.Active() and not
                (CleanFldRef.Type() IN [FieldType::Blob, FieldType::Media, FieldType::MediaSet])
            then begin
                TemplateFldRef := TemplateRecRef.FieldIndex(FieldIndex);
                DstFldRef := DestRecRef.FieldIndex(FieldIndex);
                if format(DstFldRef.Value()) = format(CleanFldRef.Value()) then
                    DstFldRef.Value(TemplateFldRef.Value());
            end;
        end;
    end;

    local procedure FilterFields(ImportProjectTableMapping: Record "Import Project Table Mapping"; var ImportProjectFieldMapping: Record "Import Project Field Mapping")
    begin
        ImportProjectFieldMapping.SetRange("Project Table ID", ImportProjectTableMapping."Project Table ID");
        ImportProjectFieldMapping.SetRange("Destination Table ID", ImportProjectTableMapping."Destination Table ID");
        ImportProjectFieldMapping.SetFilter("Destination Field ID", '>%1', 0);
    end;

    local procedure PopulatePrimaryKey(ProjectTableId: Guid; SQLReader: DotNet O4N_SqlDataReader; var DestRecRef: RecordRef)
    var
        ImportProjectField: Record "Import Project Data Field";
        ImportProjectFieldMapping: Record "Import Project Field Mapping";
        EmptyDestRecRef: RecordRef;
        DestFldRef: FieldRef;
        EmptyDestFldRef: FieldRef;
        PrimaryKeyRef: KeyRef;
        FieldIndex: Integer;
    begin
        EmptyDestRecRef.Open(DestRecRef.Number());
        EmptyDestRecRef.Init();
        PrimaryKeyRef := DestRecRef.KeyIndex(1);
        for FieldIndex := 1 to PrimaryKeyRef.FieldCount() do begin
            DestFldRef := PrimaryKeyRef.FieldIndex(FieldIndex);
            EmptyDestFldRef := EmptyDestRecRef.Field(DestFldRef.Number());
            DestFldRef.Value(EmptyDestFldRef.Value());
            ImportProjectFieldMapping.SetRange("Project Table ID", ProjectTableId);
            ImportProjectFieldMapping.SetRange("Destination Table ID", DestRecRef.Number());
            ImportProjectFieldMapping.SetRange("Destination Field ID", DestFldRef.Number());
            if ImportProjectFieldMapping.FindFirst() then
                if ImportProjectField.Get(ProjectTableId, ImportProjectFieldMapping."Project Field ID") then
                    CopyValue(ImportProjectField, DestRecRef.Number(), SQLReader, ImportProjectField.GetFieldIndex(), DestFldRef);
        end;
        OnAfterPopulatePrimaryKey(ProjectTableId, SQLReader, DestRecRef);
    end;

    local procedure CopyValue(ImportProjectField: Record "Import Project Data Field"; DestinationTableId: Integer; SQLReader: DotNet O4N_SqlDataReader; FieldIndex: Integer; var DestFldRef: FieldRef)
    var
        ImportProjectFieldMapping: Record "Import Project Field Mapping";
        ImportProjectDataBuffer: Record "Import Project Data Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        DataBufferFldRef: FieldRef;
        SrcFldValueAsText: Text;
        Handled: Boolean;
    begin
        OnBeforeCopyValue(ImportProjectFieldMapping, FieldIndex, DestFldRef, Handled);
        if Handled then exit;
        ImportProjectDataBuffer.Insert(true);
        with ImportProjectFieldMapping do begin
            Get(ImportProjectField.ID, ImportProjectField."Field ID", DestinationTableId);
            if GetWarning("Destination Field ID") <> '' then exit;
            if "Transformation Rule" <> '' then begin
                SrcFldValueAsText := SQLReader.GetString(FieldIndex);
                ApplyTransformationRule("Transformation Rule", SrcFldValueAsText);
                EvaluateFieldValue(ImportProjectField."Data Type", SQLReader, FieldIndex, DestFldRef);
            end else
                case true of
                    (DestFldRef.Type() in [FieldType::Media, FieldType::BLOB]) and (ImportProjectField."Data Type" in ['BLOB']):
                        begin
                            ImportProjectDataBuffer.GetFieldAsFieldRef(ImportProjectDataBuffer.FieldNo("Blob Type"), DataBufferFldRef);
                            GetBlobValue(SQLReader, FieldIndex, ImportProjectField.Compressed, TempBlob);
                            TempBlob.ToFieldRef(DataBufferFldRef);
                            if DestFldRef.Type() = FieldType::BLOB then
                                DestFldRef.Value(DataBufferFldRef.Value)
                            else
                                DestFldRef.Value(ImportProjectDataBuffer.CopyBlobValueToImage(DataBufferFldRef));
                        end;
                    Format(DestFldRef.Type()) = ImportProjectField."Data Type":
                        EvaluateFieldValue(ImportProjectField."Data Type", SQLReader, FieldIndex, DestFldRef);
                    (DestFldRef.Type() = FieldType::Date) and (ImportProjectField."Data Type" = 'DateTime'):
                        begin
                            ImportProjectDataBuffer.GetFieldAsFieldRef(ImportProjectDataBuffer.FieldNo("Date Time Type"), DataBufferFldRef);
                            EvaluateFieldValue(ImportProjectField."Data Type", SQLReader, FieldIndex, DataBufferFldRef);
                            ImportProjectDataBuffer."Date Time Type" := DataBufferFldRef.Value();
                            DestFldRef.Value(DT2Date(ImportProjectDataBuffer."Date Time Type"));
                        end;
                    (DestFldRef.Type() = FieldType::Time) and (ImportProjectField."Data Type" = 'DateTime'):
                        begin
                            ImportProjectDataBuffer.GetFieldAsFieldRef(ImportProjectDataBuffer.FieldNo("Date Time Type"), DataBufferFldRef);
                            EvaluateFieldValue(ImportProjectField."Data Type", SQLReader, FieldIndex, DataBufferFldRef);
                            ImportProjectDataBuffer."Date Time Type" := DataBufferFldRef.Value();
                            DestFldRef.Value(DT2Time(ImportProjectDataBuffer."Date Time Type"));
                        end;
                    (DestFldRef.Type() = FieldType::DateTime) and (ImportProjectField."Data Type" = 'Date'):
                        begin
                            ImportProjectDataBuffer.GetFieldAsFieldRef(ImportProjectDataBuffer.FieldNo("Date Type"), DataBufferFldRef);
                            EvaluateFieldValue(ImportProjectField."Data Type", SQLReader, FieldIndex, DataBufferFldRef);
                            ImportProjectDataBuffer."Date Type" := DataBufferFldRef.Value();
                            ImportProjectDataBuffer."Time Type" := DT2Time(DestFldRef.Value());
                            DestFldRef.Value(CreateDateTime(ImportProjectDataBuffer."Date Type", ImportProjectDataBuffer."Time Type"));
                        end;
                    (DestFldRef.Type() = FieldType::DateTime) and (ImportProjectField."Data Type" = 'Time'):
                        begin
                            ImportProjectDataBuffer.GetFieldAsFieldRef(ImportProjectDataBuffer.FieldNo("Time Type"), DataBufferFldRef);
                            EvaluateFieldValue(ImportProjectField."Data Type", SQLReader, FieldIndex, DataBufferFldRef);
                            ImportProjectDataBuffer."Time Type" := DataBufferFldRef.Value();
                            ImportProjectDataBuffer."Date Type" := DT2Date(DestFldRef.Value());
                            DestFldRef.Value(CreateDateTime(ImportProjectDataBuffer."Date Type", ImportProjectDataBuffer."Time Type"));
                        end;
                    (DestFldRef.Type() in [FieldType::Text, FieldType::Code]) and (ImportProjectField."Data Type" in ['Text', 'Code', 'Guid']):
                        EvaluateFieldValue(ImportProjectField."Data Type", SQLReader, FieldIndex, DestFldRef);
                    (DestFldRef.Type() in [FieldType::Integer, FieldType::Option]) and (ImportProjectField."Data Type" in ['Integer', 'Option']):
                        EvaluateFieldValue(ImportProjectField."Data Type", SQLReader, FieldIndex, DestFldRef);
                    (Format(DestFldRef.Type()) = 'Enum') and (ImportProjectField."Data Type" in ['Integer', 'Option']):
                        EvaluateFieldValue(ImportProjectField."Data Type", SQLReader, FieldIndex, DestFldRef);
                    else
                        error(FieldTypeTransformationNotSupportedErr, DestFldRef.Type(), ImportProjectField."Data Type");
                end;
        end;
        OnAfterCopyValue(ImportProjectFieldMapping, FieldIndex, DestFldRef);
    end;

    local procedure ApplyTransformationRule(TransformationRuleCode: Code[20]; var FieldValue: Text)
    var
        TransformationRule: Record "Transformation Rule";
    begin
        TransformationRule.Get(TransformationRuleCode);
        FieldValue := TransformationRule.TransformText(FieldValue);
    end;

    local procedure EvaluateFieldValue(ImportFieldType: Text; SQLReader: DotNet O4N_SqlDataReader; FieldIndex: Integer; var DestFldRef: FieldRef)
    var
        DateformulaType: DateFormula;
        DecimalType: Decimal;
        IntType: Integer;
    begin
        if ImportFieldType in ['DateTime', 'Date', 'Time'] then
            if DT2Date(SQLReader.GetDateTime(FieldIndex)) = DMY2Date(01, 01, 1753) then exit;

        case DestFldRef.Type() of
            FieldType::Text, FieldType::Code:
                DestFldRef.Value := CopyStr(SQLReader.GetString(FieldIndex), 1, DestFldRef.Length());
            FieldType::DateTime:
                DestFldRef.Value := SQLReader.GetDateTime(FieldIndex);
            FieldType::DATE:
                if DT2Time(SQLReader.GetDateTime(FieldIndex)) = 235959T then
                    DestFldRef.Value := ClosingDate(DT2Date(SQLReader.GetDateTime(FieldIndex)))
                else
                    DestFldRef.Value := NormalDate(DT2Date(SQLReader.GetDateTime(FieldIndex)));
            FieldType::TIME:
                DestFldRef.Value := DT2Time(SQLReader.GetDateTime(FieldIndex));
            FieldType::DATEFORMULA:
                begin
                    if not Evaluate(DateformulaType, SQLReader.GetString(FieldIndex).Replace('><', ''), 9) then
                        Clear(DateformulaType);
                    DestFldRef.Value := DateformulaType;
                end;
            FieldType::DECIMAL:
                begin
                    DecimalType := SQLReader.GetValue(FieldIndex);
                    DestFldRef.Value := DecimalType;
                end;
            FieldType::BOOLEAN:
                begin
                    IntType := SQLReader.GetValue(FieldIndex);
                    DestFldRef.Value := IntType = 1;
                end;
            FieldType::OPTION:
                begin
                    IntType := SQLReader.GetValue(FieldIndex);
                    DestFldRef.Value := IntType;
                end;
            FieldType::INTEGER:
                DestFldRef.Value := SQLReader.GetInt32(FieldIndex);
            FieldType::BIGINTEGER:
                DestFldRef.Value := SQLReader.GetInt64(FieldIndex);
            FieldType::GUID:
                DestFldRef.Value := SQLReader.GetGuid(FieldIndex);
            FieldType::RECORDID:
                ; // Ignored
            else
                Error(FieldTypeNotSupportedErr, UpperCase(Format(DestFldRef.Type())));

        end;
    end;

    local procedure GetBlobValue(SQLReader: DotNet O4N_SqlDataReader; FieldIndex: Integer; Compressed: Boolean; var TempBlob: Codeunit "Temp Blob")
    var
        MemoryStream: Dotnet O4N_MemoryStream;
        DeflateStream: DotNet O4N_DeflateStream;
        StreamReader: DotNet O4N_StreamReader;
        CompressionMode: DotNet O4N_CompressionMode;
        OutStr: OutStream;
    begin
        if SQLReader.IsDBNull(FieldIndex) then exit;
        MemoryStream := MemoryStream.MemoryStream(SQLReader.GetSqlBytes(FieldIndex).Value());
        if MemoryStream.Length() = 0 then exit;
        TempBlob.CreateOutStream(OutStr);
        if Compressed then begin
            DeflateStream := DeflateStream.DeflateStream(MemoryStream, CompressionMode.Decompress);
            StreamReader := StreamReader.StreamReader(DeflateStream);
            StreamReader.BaseStream.CopyTo(OutStr);
        end else
            CopyStream(OutStr, MemoryStream);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(ImportProjectTableMapping: Record "Import Project Table Mapping"; SQLReader: DotNet O4N_SqlDataReader;

    var
        DestRecRef: RecordRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsert(ImportProjectTableMapping: Record "Import Project Table Mapping"; SQLReader: DotNet O4N_SqlDataReader;

    var
        DestRecRef: RecordRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyValue(ImportProjectFieldMapping: Record "Import Project Field Mapping"; FieldIndex: Integer; var DestFldRef: FieldRef; var Handled: Boolean)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyValue(ImportProjectFieldMapping: Record "Import Project Field Mapping"; FieldIndex: Integer; var DestFldRef: FieldRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyFields(ImportProjectTableMapping: Record "Import Project Table Mapping"; SQLReader: DotNet O4N_SqlDataReader; var DestRecRef: RecordRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFields(ImportProjectTableMapping: Record "Import Project Table Mapping"; SQLReader: DotNet O4N_SqlDataReader; var DestRecRef: RecordRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRecordProcess(ImportProjectTableMapping: Record "Import Project Table Mapping"; SQLConnection: DotNet O4N_SqlConnection; SQLReader: DotNet O4N_SqlDataReader; var DestRecRef: RecordRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRecordProcess(ImportProjectTableMapping: Record "Import Project Table Mapping"; SQLConnection: DotNet O4N_SqlConnection; SQLReader: DotNet O4N_SqlDataReader; var DestRecRef: RecordRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTableProcess(ImportProjectTableMapping: Record "Import Project Table Mapping"; SQLConnection: DotNet O4N_SqlConnection)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTableProcess(ImportProjectTableMapping: Record "Import Project Table Mapping"; SQLConnection: DotNet O4N_SqlConnection)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulatePrimaryKey(ProjectTableId: Guid; SQLReader: DotNet O4N_SqlDataReader;

    var
        DestRecRef: RecordRef)
    begin

    end;

    var
        SQLConnect: Codeunit "SQL Connect";
        SQLConnection: DotNet O4N_SqlConnection;
        DialogMsg: Label 'Executing Data Import for table: #1##############################\Total: #2##############################\Process: #3##############################';
        FieldTypeNotSupportedErr: Label 'Field Type %1 not supported!';
        FieldTypeTransformationNotSupportedErr: Label 'Field value transformation from type %1 to %2 not supported!';
        DataImportFinishedMsg: Label 'Data Import Completed. Duration %1';
        UnableToDeflateB64StringErr: Label 'Unable to deflate base 64 string';
        Window: Dialog;

}