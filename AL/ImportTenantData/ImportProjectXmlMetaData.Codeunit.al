codeunit 60306 "Import Project Xml MetaData"
{
    TableNo = "Import Project Data";

    trigger OnRun()
    var
        DataInfo: Record "Import Project Data Info";
    begin
        LoadXmlFromImportData(Rec);
        LoadTableInfo(Rec, DataInfo);
        LoadTableFields(Rec, DataInfo);
    end;

    local procedure LoadXmlFromImportData(ImportData: Record "Import Project Data")
    begin
        if not ImportData.Content.HasValue() then
            error(NoDataFoundErr);
        ImportData.GetXml(Xml);
    end;

    local procedure LoadTableInfo(ImportData: Record "Import Project Data"; var DataInfo: Record "Import Project Data Info")
    var
        TableNode: XmlNode;
    begin
        DataInfo.DeleteInfo(ImportData.ID);
        if not Xml.SelectSingleNode(NodeMgt.GetNodeXPath('Table'), TableNode) then exit;
        DataInfo.Init();
        DataInfo.ID := ImportData.ID;
        DataInfo.Name := NodeMgt.FindAttributeTextValue(TableNode, 'Name');
        DataInfo."Table ID" := NodeMgt.FindAttributeDecimalValue(TableNode, 'ID');
        DataInfo."Table Type" := NodeMgt.FindAttributeTextValue(TableNode, 'TableType');
        DataInfo."Data Per Company" := NodeMgt.FindAttributeDecimalValue(TableNode, 'DataPerCompany') = 1;
        DataInfo.Caption := GetCaptionValue(NodeMgt.FindAttributeTextValue(TableNode, 'CaptionML'));
        DataInfo.Insert();
    end;

    local procedure LoadTableFields(ImportData: Record "Import Project Data"; DataInfo: Record "Import Project Data Info")
    var
        DataField: Record "Import Project Data Field";
        FieldNodeList: XmlNodeList;
        FieldNode: XmlNode;
    begin
        DataField.DeleteFields(ImportData.ID);
        if IsNullGuid(DataInfo.ID) then exit;
        if DataInfo."Table ID" = 0 then exit;
        if not Xml.SelectNodes(NodeMgt.GetNodeXPath('Field'), FieldNodeList) then exit;
        foreach FieldNode in FieldNodeList do begin
            DataField.Init();
            DataField.ID := ImportData.ID;
            DataField."Table Name" := DataInfo.Name;
            DataField."Field ID" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'ID');
            DataField."Field Name" := NodeMgt.FindAttributeTextValue(FieldNode, 'Name');
            DataField."Not Blank" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'NotBlank') = 1;
            DataField.Numeric := NodeMgt.FindAttributeDecimalValue(FieldNode, 'Numeric') = 1;
            DataField."Option String" := NodeMgt.FindAttributeTextValue(FieldNode, 'OptionString');
            DataField."Sign Displacement" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'SignDisplacement') = 1;
            DataField."SQL Timestamp" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'SQL_Timestamp') = 1;
            DataField."Test Table Relation" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'TestTableRelation') = 1;
            DataField."Validate Table Relation" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'ValidateTableRelation') = 1;
            DataField."Option Caption" := GetCaptionValue(NodeMgt.FindAttributeTextValue(FieldNode, 'OptionCaptionML'));
            DataField."Field Caption" := GetCaptionValue(NodeMgt.FindAttributeTextValue(FieldNode, 'CaptionML'));
            DataField."Closing Dates" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'ClosingDates') = 1;
            DataField."Data Length" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'DataLength');
            DataField."Data Type" := NodeMgt.FindAttributeTextValue(FieldNode, 'Datatype');
            DataField."Date Formula" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'DateFormula') = 1;
            DataField.Editable := NodeMgt.FindAttributeDecimalValue(FieldNode, 'Editable') = 1;
            DataField.Enabled := NodeMgt.FindAttributeDecimalValue(FieldNode, 'Enabled') = 1;
            DataField."Extended Data Type" := NodeMgt.FindAttributeTextValue(FieldNode, 'ExtendedDataType');
            DataField."External Access" := NodeMgt.FindAttributeTextValue(FieldNode, 'ExternalAccess');
            DataField."Access By Object ID" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'AccessByObjectID');
            DataField."Access By Object Type" := NodeMgt.FindAttributeTextValue(FieldNode, 'AccessByObjectType');
            DataField."Access By Permission Mask" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'AccessByPermissionMask');
            DataField."Auto Increment" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'AutoIncrement') = 1;
            DataField."Blank Numbers" := NodeMgt.FindAttributeTextValue(FieldNode, 'BlankNumbers');
            DataField."Blank Zero" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'BlankZero') = 1;
            DataField.Insert();
        end;
    end;

    local procedure GetCaptionValue(CaptionAttributeValue: Text) LocalCaption: Text[50];
    var
        Language: Record Language;
        Captions: List of [Text];
    begin
        if CaptionAttributeValue = '' then exit('');
        Language.SETRANGE("Windows Language ID", GlobalLanguage);
        if not Language.FindFirst() then exit('');
        Captions := CaptionAttributeValue.Split(';');
        foreach LocalCaption in Captions do begin
            if StrPos(LocalCaption, Language."Code") = 1 then begin
                exit(DelChr(DelChr(CopyStr(LocalCaption, 5), '>', '"'), '<', '"'));
            end;
        end;
        exit('');
    end;

    var
        NodeMgt: Codeunit "Import Project Node Mgt.";
        Xml: XmlDocument;
        NoDataFoundErr: Label 'No Xml data found';

}