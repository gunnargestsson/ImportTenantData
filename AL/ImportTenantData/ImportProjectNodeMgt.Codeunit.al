codeunit 60305 "Import Project Node Mgt."
{
    procedure SetFieldValue(var RecRef: RecordRef; FldNo: Integer; XmlSearchNode: XmlNode; NodeName: Text): Boolean
    var
        TempBlob: Record TempBlob;
        FldRef: FieldRef;
    begin
        FldRef := RecRef.Field(FldNo);
        case FldRef.Type() of
            FieldType::Blob:
                begin
                    TempBlob.WriteAsText(FindNodeTextValue(XmlSearchNode, NodeName), TextEncoding::Windows);
                    FldRef.Value(TempBlob.Blob);
                end;
            FieldType::Text, FieldType::Code:
                FldRef.Value(CopyStr(FindNodeTextValue(XmlSearchNode, NodeName), 1, FldRef.Length()));
            FieldType::Decimal, FieldType::Integer:
                FldRef.Value(FindNodeDecimalValue(XmlSearchNode, NodeName));
            FieldType::DateTime:
                FldRef.Value(FindNodeDateTimeValue(XmlSearchNode, NodeName));
            FieldType::Date:
                FldRef.Value(FindNodeDateValue(XmlSearchNode, NodeName));
            FieldType::Guid, FieldType::Media, FieldType::MediaSet:
                FldRef.Value(FindNodeGuidValue(XmlSearchNode, NodeName));
            else
                error(UnsupportedDataTypeErr, Format(FldRef.Type()));
        end;

    end;

    procedure FindNodeTextValue(XmlSearchNode: XmlNode; NodeName: Text) NodeValue: Text
    var
        FoundNode: XmlNode;
    begin
        if not XmlSearchNode.SelectSingleNode(GetChildNodeXPath(NodeName), FoundNode) then exit('');
        NodeValue := FoundNode.AsXmlElement().InnerText();
    end;

    procedure FindNodeDecimalValue(XmlSearchNode: XmlNode; NodeName: Text) NodeValue: Decimal
    begin
        if not Evaluate(NodeValue, FindNodeTextValue(XmlSearchNode, NodeName), 9) then exit(0);
    end;

    procedure FindNodeDateTimeValue(XmlSearchNode: XmlNode; NodeName: Text) NodeValue: DateTime
    var
        Fieldvalue: Text;
    begin
        Fieldvalue := FindNodeTextValue(XmlSearchNode, NodeName);
        if Fieldvalue in ['', '1753-01-01T00:00:00'] then exit(0DT);
        if not Evaluate(NodeValue, Fieldvalue, 9) then exit(0DT);
    end;

    procedure FindNodeDateValue(XmlSearchNode: XmlNode; NodeName: Text) NodeValue: Date
    var
        Fieldvalue: Text;
    begin
        Fieldvalue := FindNodeTextValue(XmlSearchNode, NodeName);
        if FieldValue = '1753-01-01T00:00:00' then
            exit(0D);
        evaluate(NodeValue, CopyStr(FieldValue, 1, 10), 9);
        if CopyStr(FieldValue, 12, 8) = '23:59:59' then
            NodeValue := ClosingDate(NodeValue);
    end;

    procedure FindNodeTimeValue(XmlSearchNode: XmlNode; NodeName: Text; var NodeValue: Time) TimeValueFound: Boolean
    var
        Fieldvalue: Text;
    begin
        Fieldvalue := FindNodeTextValue(XmlSearchNode, NodeName);
        if FieldValue = '1753-01-01T00:00:00' then
            exit(false);
        FieldValue := CopyStr(FieldValue, 12);
        evaluate(NodeValue, FieldValue);
        exit(true);
    end;

    procedure FindNodeGuidValue(XmlSearchNode: XmlNode; NodeName: Text) NodeValue: Guid
    begin
        if not evaluate(NodeValue, FindNodeTextValue(XmlSearchNode, NodeName)) then
            clear(NodeValue);
    end;

    procedure FindAttributeTextValue(XmlSearchNode: XmlNode; AttributeName: Text) AttributeValue: Text
    var
        XmlSearchAttribute: XmlAttribute;
    begin
        foreach XmlSearchAttribute in XmlSearchNode.AsXmlElement().Attributes() do
            if XmlSearchAttribute.LocalName() = AttributeName then exit(XmlSearchAttribute.Value());
    end;

    procedure FindAttributeDecimalValue(XmlSearchNode: XmlNode; AttributeName: Text) AttributeValue: Decimal
    begin
        if not Evaluate(AttributeValue, FindAttributeTextValue(XmlSearchNode, AttributeName), 9) then exit(0);
    end;

    procedure GetNodeXPath(NodeName: Text): Text
    begin
        exit(StrSubstNo('//*[local-name()="%1"]', NodeName))
    end;

    procedure GetChildNodeXPath(NodeName: Text): Text
    begin
        exit(StrSubstNo('./*[local-name()="%1"]', NodeName))
    end;

    var
        UnsupportedDataTypeErr: Label 'Unsupported data type: %1';
}