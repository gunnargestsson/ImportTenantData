table 60302 "Import Project Data"
{
    DataClassification = EndUserIdentifiableInformation;
    Caption = 'Import Project Data';
    DataCaptionFields = "File Name";
    LookupPageId = "Import Project Data List";
    DrillDownPageId = "Import Project Data List";

    fields
    {
        field(1; ID; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(2; "Project ID"; guid)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Import Project".ID;
            Caption = 'Project ID';
        }

        field(12; "File Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'File Name';
        }
        field(13; "Last Modified"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Modified';
        }
        field(14; "Content Length"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Content Length';
        }
        field(15; "Content"; Blob)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Content';
        }
        field(16; "Fact Boxes Populated"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Fact Boxes Populated';
        }
    }

    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }
        key(Project; "Project ID", "File Name")
        {

        }

    }

    trigger OnInsert()
    begin
        ID := CreateGuid();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        DataInfo: Record "Import Project Data Info";
        DataField: Record "Import Project Data Field";
    begin
        DataInfo.DeleteInfo(ID);
        DataField.DeleteFields(ID);
    end;

    trigger OnRename()
    begin

    end;

    procedure ExportData()
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        CalcFields(Content);
        TempBlob.Blob := Content;
        FileMgt.BLOBExport(TempBlob, "File Name", true);
    end;

    procedure LoadXml(var Xml: XmlDocument)
    var
        InStr: InStream;
    begin
        CalcFields(Content);
        Content.CreateInStream(InStr);
        XmlDocument.ReadFrom(InStr, Xml);
    end;

    procedure PopulateFactboxes()
    var
        XmlMetadata: Codeunit "Import Project Xml MetaData";
    begin
        XmlMetadata.Run(Rec);
        "Fact Boxes Populated" := true;
        Modify();
    end;
}