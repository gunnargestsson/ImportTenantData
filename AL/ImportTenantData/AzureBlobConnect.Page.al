page 60330 "Azure Blob Connect Setup Card"
{

    PageType = Card;
    SourceTable = "Azure Blob Connect Setup";
    Caption = 'Azure Blob Connect Setup Card';
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Source ID"; "Source ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Account Name"; "Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Account Name for the Azure Storage Account';
                    ShowMandatory = true;
                }
                field("Container Name"; "Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Container Name for the selected Azure Storage Account';
                    ShowMandatory = true;
                }
                field("Access Key"; PrivateKey)
                {
                    ApplicationArea = All;
                    Caption = 'Access Key';
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        SavePassword("Access Key ID", PrivateKey);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ImportSourceMgt: Codeunit "Import Source Mgt.";
        ImportSourceID: Text;
    begin
        if not IsolatedStorage.Contains(ImportSourceMgt.GetIsolationStorageSourceId(), DataScope::User) then
            error(ConfigurationMissingErr);
        IsolatedStorage.Get(ImportSourceMgt.GetIsolationStorageSourceId(), DataScope::User, ImportSourceID);
        Evaluate("Source ID", ImportSourceID);
        if not Find() then Insert();
        FilterGroup(2);
        SetRecFilter();
        FilterGroup(0);
    end;

    trigger OnAfterGetRecord()
    begin
        if HasPassword("Access Key ID") then
            PrivateKey := GetPassword("Access Key ID")
        else
            PrivateKey := '';
    end;

    var
        ConfigurationMissingErr: Label 'Configuration Missing';
        PrivateKey: Text;
}
