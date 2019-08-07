page 60310 "Import Project Table Mappings"
{

    PageType = Card;
    SourceTable = "Import Project Table Mapping";
    Caption = 'Import Project Table Mappings';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Destination Table ID"; "Destination Table ID")
                {
                    ApplicationArea = All;
                }
                field("Destination Table Name"; "Destination Table Name")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Destination Table Caption"; "Destination Table Caption")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Destination Table Record Count"; "Destination Table Record Count")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field(TemplateRecord; Format("Template Record"))
                {
                    ApplicationArea = All;
                    Caption = 'Template Record';
                    Editable = false;
                    ToolTip = 'Specify Record Filters that will be applied as default data';
                    trigger OnAssistEdit()
                    var
                        PageMgt: Codeunit "Page Management";
                        DataTypeMgt: Codeunit "Data Type Management";
                        RecRef: RecordRef;
                        RecRelatedVariant: Variant;
                        PageID: Integer;
                    begin
                        if not CurrPage.Editable() then exit;
                        RecRef.Open("Destination Table ID");
                        RecRelatedVariant := RecRef;
                        PageID := PageMgt.GetDefaultLookupPageIDByVar(RecRelatedVariant);
                        if PageID > 0 then
                            if Page.RunModal(PageID, RecRelatedVariant) = Action::LookupOK then
                                if DataTypeMgt.GetRecordRef(RecRelatedVariant, RecRef) then
                                    "Template Record" := RecRef.RecordId();
                    end;
                }
            }
            part(FieldMapping; "Import Project Field Map. Part")
            {
                ApplicationArea = All;
                SubPageLink = "Project Table ID" = field ("Project Table ID"), "Destination Table ID" = field ("Destination Table ID");
            }
        }
    }
    trigger OnOpenPage()
    var
        ImportProjectDataInfo: Record "Import Project Data Info";
        AllObj: Record AllObj;
    begin
        if IsEmpty() then
            if ImportProjectDataInfo.Get("Project Table ID") then
                if AllObj.Get(AllObj."Object Type"::Table, ImportProjectDataInfo."Table ID") then begin
                    Validate("Destination Table ID", ImportProjectDataInfo."Table ID");
                    Insert();
                end;
    end;

}
