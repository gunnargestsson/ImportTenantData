table 60320 "Import Data Source"
{
    DataClassification = SystemMetadata;
    Caption = 'Import Data Source';
    DataCaptionFields = Description;
    LookupPageId = "Import Data Sources";
    DrillDownPageId = "Import Data Sources";

    fields
    {
        field(1; ID; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Description';
        }
        field(3; "Codeunit Name"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Codeunit Name';
        }
        field(4; "Setup Page Name"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Setup Page Name';
        }
        field(5; "Content Codeunit Name"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Content Update Codeunit Name';
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
    begin
        ID := CreateGuid();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure OpenSetupPage()
    var
        ImportSourceMgt: Codeunit "Import Source Mgt.";
    begin
        TestField("Setup Page Name");
        IsolatedStorage.Set(ImportSourceMgt.GetIsolationStorageSourceId(), Format(ID), DataScope::User);
        Commit();
        Page.RunModal(ImportSourceMgt.GetPageID("Setup Page Name"));
        IsolatedStorage.Delete(ImportSourceMgt.GetIsolationStorageSourceId(), DataScope::User);
    end;

    [IntegrationEvent(false, false)]
    procedure RegisterImportSource()
    begin

    end;
}