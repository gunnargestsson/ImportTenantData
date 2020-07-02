table 60300 "Import Project"
{
    DataClassification = EndUserIdentifiableInformation;
    Caption = 'Import Project';
    DataCaptionFields = Description;

    fields
    {
        field(1; ID; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(2; "Import Source ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Import Source ID';
            TableRelation = "Import Data Source".ID;
            trigger OnValidate()
            begin
                CalcFields("Import Source Description");
            end;
        }
        field(3; Description; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Description';
        }
        field(4; "Import Source Description"; Text[50])
        {
            Caption = 'Import Source Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup ("Import Data Source".Description where(ID = field("Import Source ID")));
        }

    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ImportSource: Record "Import Data Source";
    begin
        ID := CreateGuid();
        if IsNullGuid("Import Source ID") then
            if ImportSource.Count = 1 then begin
                ImportSource.FindFirst();
                "Import Source ID" := ImportSource.ID;
            end;
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        ImportData: Record "Import Project Data";
    begin
        ImportData.SetRange("Project ID", ID);
        if not ImportData.IsEmpty() then
            ImportData.DeleteAll();
    end;

    trigger OnRename()
    begin

    end;

    procedure Import()
    var
        ImportSource: Record "Import Data Source";
        ImportSourceMgt: Codeunit "Import Source Mgt.";
    begin
        TestField("Import Source ID");
        ImportSource.Get("Import Source ID");
        ImportSource.TestField("Codeunit Name");
        Codeunit.Run(ImportSourceMgt.GetCodeunitID(ImportSource."Codeunit Name"), Rec);
    end;

    procedure PopulateFactboxes()
    var
        ImportData: Record "Import Project Data";
        Window: Dialog;
        WorkingMsg: Label 'Reading Xml...';
    begin
        window.Open(WorkingMsg);
        ImportData.SetRange("Project ID", ID);
        ImportData.SetRange("Fact Boxes Populated", false);
        if ImportData.FindSet() then
            repeat
                ImportData.PopulateFactboxes();
            until ImportData.Next() = 0;
        Window.Close();
    end;

    procedure StartDataTransfer(var ImportProjectData: Record "Import Project Data"; ResumeTransfer: Boolean)
    begin
        ImportProjectData.FindFirst();
        Get(ImportProjectData."Project ID");
        TestField("Import Source ID");
        OnStartDataTransfer(Rec, ImportProjectData, ResumeTransfer);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStartDataTransfer(ImportProject: Record "Import Project"; var ImportProjectData: Record "Import Project Data"; ResumeTransfer: Boolean)
    begin

    end;

}