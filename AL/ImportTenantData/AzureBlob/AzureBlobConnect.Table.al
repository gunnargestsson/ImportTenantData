table 60330 "Azure Blob Connect Setup"
{
    DataClassification = SystemMetadata;
    Caption = 'Azure Blob Connect Setup';
    DataCaptionFields = "Account Name";
    DrillDownPageId = "Azure Blob Connect Setup List";

    fields
    {
        field(1; "Source ID"; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Source ID';
            NotBlank = true;
        }
        field(2; "Account Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Account Name';
            NotBlank = true;
        }
        field(3; "Container Name"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Container Name';
            NotBlank = true;
        }
        field(4; "Access Key ID"; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Access Key ID';
        }
    }

    keys
    {
        key(PK; "Source ID")
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        DeletePassword("Access Key ID");
    end;

    trigger OnRename()
    begin

    end;

    procedure VerifySetup()
    begin
        TestField("Account Name");
        TestField("Container Name");
        if not HasPassword("Access Key ID") then
            error(AccessKeyMissingErr);
    end;

    procedure SavePassword(var PasswordKey: Guid; PasswordText: Text)
    begin
        if IsNullGuid(PasswordKey) then
            PasswordKey := CreateGuid();
        DeletePassword(PasswordKey);
        IsolatedStorage.Set(PasswordKey, PasswordText);
        Modify;
        Commit;
    end;

    procedure GetPassword(PasswordKey: Guid) PasswordText: Text
    begin
        if HasPassword(PasswordKey) then
            IsolatedStorage.Get(PasswordKey, PasswordText);
    end;

    local procedure DeletePassword(PasswordKey: Guid)
    begin
        if HasPassword(PasswordKey) then
            IsolatedStorage.Delete(PasswordKey);
    end;

    procedure HasPassword(PasswordKey: Guid): Boolean
    begin
        exit(IsolatedStorage.Contains(PasswordKey));
    end;

    var
        AccessKeyMissingErr: Label 'Access Key is missing';

}