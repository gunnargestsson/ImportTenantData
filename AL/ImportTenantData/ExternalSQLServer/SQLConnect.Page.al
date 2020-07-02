page 60340 "SQL Connect Setup Card"
{
    PageType = Card;
    SourceTable = "SQL Connect Setup";
    Caption = 'SQL Connect Setup Card';
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
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description for the SQL connection';
                    ShowMandatory = true;
                }
                field("Connection String Key"; ConnectionStringKey)
                {
                    ApplicationArea = All;
                    Caption = 'SQL Connection String';
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        SavePassword("Connection String Key ID", ConnectionStringKey);
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
        if HasPassword("Connection String Key ID") then
            ConnectionStringKey := GetPassword("Connection String Key ID")
        else
            ConnectionStringKey := '';
    end;

    var
        ConfigurationMissingErr: Label 'Configuration Missing';
        ConnectionStringKey: Text;
}
