table 60340 "SQL Connect Setup"
{
    DataClassification = SystemMetadata;
    Caption = 'SQL Connect Setup';
    DataCaptionFields = Description;
    DrillDownPageId = "SQL Connect Setup List";

    fields
    {
        field(1; "Source ID"; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Source ID';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(4; "Connection String Key ID"; guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Connection String Key ID';
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
        DeletePassword("Connection String Key ID");
    end;

    trigger OnRename()
    begin

    end;

    procedure VerifySetup()
    begin
        if not HasPassword("Connection String Key ID") then
            error(ConnectionStringMissingErr);
    end;

    procedure SavePassword(var PasswordKey: Guid; PasswordText: Text)
    begin
        if IsNullGuid(PasswordKey) then
            PasswordKey := CreateGuid();
        DeletePassword(PasswordKey);
        IsolatedStorage.Set(PasswordKey, PasswordText);
        Modify();
        Commit();
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
        ConnectionStringMissingErr: Label 'SQL Connection String is missing';

}