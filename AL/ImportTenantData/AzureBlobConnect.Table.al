table 60330 "Azure Blob Connect Setup"
{
    DataClassification = SystemMetadata;
    Permissions = TableData "Service Password" = rimd;
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
        field(4; "Private Key ID"; guid)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Service Password".Key;
            Caption = 'Private Key ID';
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
        DeletePassword("Private Key ID");
    end;

    trigger OnRename()
    begin

    end;

    procedure VerifySetup()
    begin
        TestField("Account Name");
        TestField("Container Name");
        if not HasPassword("Private Key ID") then
            error(PrivateKeyMissingErr);
    end;

    procedure SavePassword(var PasswordKey: Guid; PasswordText: Text)
    var
        ServicePassword: Record "Service Password";
    begin
        if IsNullGuid(PasswordKey) or not ServicePassword.Get(PasswordKey) then begin
            ServicePassword.SavePassword(PasswordText);
            ServicePassword.Insert(true);
            PasswordKey := ServicePassword.Key;
            Modify;
        end else begin
            ServicePassword.SavePassword(PasswordText);
            ServicePassword.Modify;
        end;
        Commit;
    end;

    procedure GetPassword(PasswordKey: Guid): Text
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.Get(PasswordKey);
        exit(ServicePassword.GetPassword);
    end;

    local procedure DeletePassword(PasswordKey: Guid)
    var
        ServicePassword: Record "Service Password";
    begin
        if ServicePassword.Get(PasswordKey) then
            ServicePassword.Delete;
    end;

    procedure HasPassword(PasswordKey: Guid): Boolean
    var
        ServicePassword: Record "Service Password";
    begin
        if not ServicePassword.Get(PasswordKey) then
            exit(false);
        exit(ServicePassword.GetPassword <> '');
    end;

    var
        PrivateKeyMissingErr: Label 'Private Key is missing';

}