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
        field(20; "No. of Table Mappings"; Integer)
        {
            Caption = 'No. of Table Mappings';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count ("Import Project Table Mapping" where("Project Table ID" = field(ID)));
        }
        field(21; "No. of Field Mappings"; Integer)
        {
            Caption = 'No. of Field Mappings';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count ("Import Project Field Mapping" where("Project Table ID" = field(ID), "Destination Field ID" = filter('>0')));
        }
        field(30; "Missing Record Handling"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Missing Record Handling';
            OptionMembers = Create,Skip;
            OptionCaption = 'Create,Skip';
            InitValue = Skip;
        }
        field(31; "Commit Interval"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Commit Interval';
            OptionMembers = None,"Every record","Every 100 records","Every 1.000 records","Every 10.000 records";
            OptionCaption = 'None,Every record,Every 100 records,Every 1.000 records,Every 10.000 records';
        }
        field(42; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup ("Import Project Data Info"."Table ID" where(ID = field(ID)));
        }
        field(43; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup ("Import Project Data Info".Name where(ID = field(ID)));
        }
        field(44; "Table Caption"; Text[50])
        {
            Caption = 'Caption';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup ("Import Project Data Info".Caption where(ID = field(ID)));
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
        DataTableMapping: Record "Import Project Table Mapping";
        DataFieldMapping: Record "Import Project Field Mapping";
    begin
        DataInfo.DeleteInfo(ID);
        DataField.DeleteFields(ID);
        DataTableMapping.DeleteTableMapping(ID);
        DataFieldMapping.DeleteFieldMapping(ID);
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

    procedure GetXml(var Xml: XmlDocument)
    var
        OuterXml: Text;
    begin
        CalcFields(Content);
        if ReadXml(Xml) then exit;
        OuterXml := ConvertDateFormula();
        XmlDocument.ReadFrom(OuterXml, Xml);
    end;

    [TryFunction]
    local procedure ReadXml(var Xml: XmlDocument)
    var
        InStr: InStream;
    begin
        Content.CreateInStream(InStr);
        XmlDocument.ReadFrom(InStr, Xml);
    end;

    local procedure ConvertDateFormula() Xml: Text
    var
        TempBlob: Record TempBlob;
    begin
        TempBlob.Blob := Content;
        Xml := TempBlob.ReadAsTextWithCRLFLineSeparator();
        Xml := Xml.Replace('&#x1;', '&lt;C&gt;').Replace('&#x2;', '&lt;D&gt;').Replace('&#x3;', '&lt;WD&gt;').Replace('&#x4;', '&lt;W&gt;').Replace('&#x5;', '&lt;M&gt;').Replace('&#x6;', '&lt;Q&gt;').Replace('&#x7;', '&lt;Y&gt;');
    end;

    procedure PopulateFactboxes()
    var
        XmlMetadata: Codeunit "Import Project Xml MetaData";
    begin
        XmlMetadata.Run(Rec);
        "Fact Boxes Populated" := true;
        Modify();
    end;

    procedure GetJobQueueEntryStatus(): Text
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Record ID to Process", RecordId());
        if JobQueueEntry.FindFirst() then
            exit(Format(JobQueueEntry.Status));
    end;

    procedure JobQueueEntryDrillDown()
    var
        JobQueueEntry: Record "Job Queue Entry";
        PageMgt: Codeunit "Page Management";
    begin
        JobQueueEntry.SetRange("Record ID to Process", RecordId());
        if JobQueueEntry.FindFirst() then
            Page.Run(PageMgt.GetDefaultCardPageID(Database::"Job Queue Entry"), JobQueueEntry);
    end;

    procedure ClearContent()
    begin
        if FindSet(true) then
            repeat
                Clear(Content);
                "Content Length" := 0;
                Modify();
            until Next() = 0;
    end;

    procedure LoadContent()
    var
        ImportSource: Record "Import Data Source";
        ImportProject: Record "Import Project";
        ImportSourceMgt: Codeunit "Import Source Mgt.";
    begin
        if FindSet(true) then
            repeat
                ImportProject.Get("Project ID");
                ImportProject.TestField("Import Source ID");
                ImportSource.Get(ImportProject."Import Source ID");
                Codeunit.Run(ImportSourceMgt.GetCodeunitID(ImportSource."Content Codeunit Name"), Rec);
            until Next() = 0;
    end;
}