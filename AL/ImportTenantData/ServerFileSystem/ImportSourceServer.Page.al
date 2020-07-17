page 60324 "Server File Connect Setup Card"
{
    PageType = Card;
    SourceTable = "Import Source Server File";
    Caption = 'Server File Connect Setup Card';
    DataCaptionExpression = '';
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
                    ToolTip = 'Specifies the value of the Source ID field';
                }
                field("File Path"; "File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Server File Path';
                    ShowMandatory = true;
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

    var
        ConfigurationMissingErr: Label 'Configuration Missing';
}