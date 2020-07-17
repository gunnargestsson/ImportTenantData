page 60310 "Import Project Table Mappings"
{

    PageType = ListPlus;
    SourceTable = "Import Project Table Mapping";
    Caption = 'Import Project Table Mappings';
    ShowFilter = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Destination Table ID"; "Destination Table ID")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "All Objects with Caption";
                    ToolTip = 'Specifies the value of the Destination Table ID field';
                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("Destination Table Name"; "Destination Table Name")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Destination Table Name field';

                }
                field("Destination Table Caption"; "Destination Table Caption")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Destination Table Caption field';
                }
                field("Destination Table Record Count"; "Destination Table Record Count")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Destination Table Record Count field';
                }
                field("No. of Imported Records"; "No. of Imported Records")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. of Imported Records field';
                }
                field("No. of Records"; "No. of Records")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. of Records field';
                }
                field(TemplateRecord; Format("Template Record"))
                {
                    ApplicationArea = All;
                    Caption = 'Template Record';
                    Editable = false;
                    ToolTip = 'Specify Record Filters that will be applied as default data';
                    trigger OnAssistEdit()
                    begin
                        SelectTemplateRecord(CurrPage.Editable());
                    end;
                }
            }
            part(FieldMapping; "Import Project Field Map. Part")
            {
                ApplicationArea = All;
                Caption = 'Fields';
                SubPageLink = "Project Table ID" = field("Project Table ID"), "Destination Table ID" = field("Destination Table ID");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SelectTemplate)
            {
                ApplicationArea = All;
                Image = Select;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Select Template Record';
                ToolTip = 'Specify Record Filters that will be applied as default data';

                trigger OnAction()
                begin
                    SelectTemplateRecord(CurrPage.Editable());
                end;
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
