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
        ImportData.LoadXml(Xml);
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
        DataInfo."Table Id" := NodeMgt.FindAttributeDecimalValue(TableNode, 'ID');
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
        if DataInfo."Table Id" = 0 then exit;
        if not Xml.SelectNodes(NodeMgt.GetNodeXPath('Field'), FieldNodeList) then exit;
        foreach FieldNode in FieldNodeList do begin
            DataField.Init();
            DataField.ID := ImportData.ID;
            DataField."Xml Table Id" := DataInfo."Table Id";
            DataField."Xml Table Name" := DataInfo.Name;
            DataField."Xml Field ID" := NodeMgt.FindAttributeDecimalValue(FieldNode, 'ID');
            DataField."Xml Field Name" := NodeMgt.FindAttributeTextValue(FieldNode, 'Name');
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
                exit(CopyStr(LocalCaption, 5));
            end;
        end;
        exit('');
    end;

    var
        NodeMgt: Codeunit "Import Project Node Mgt.";
        Xml: XmlDocument;
        NoDataFoundErr: Label 'No Xml data found';

}