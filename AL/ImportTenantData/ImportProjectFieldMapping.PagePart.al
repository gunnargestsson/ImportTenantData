page 60311 "Import Project Field Map. Part"
{

    PageType = ListPart;
    SourceTable = "Import Project Field Mapping";
    Caption = 'Import Project Field Mapping Part';
    InsertAllowed = false;
    DeleteAllowed = false;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Project Field ID"; "Project Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Project Field ID field';
                }
                field("Project Field Name"; "Project Field Name")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Project Field Name field';
                }
                field("Destination Field ID"; "Destination Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Destination Field ID field';
                }
                field("Destination Field Name"; "Destination Field Name")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    DrillDownPageId = "Page Fields Selection List";
                    ToolTip = 'Specifies the value of the Destination Field Name field';
                }
                field("Transformation Rule"; "Transformation Rule")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Transformation Rule field';
                }

                field(ShowWarning; GetWarning("Destination Field ID"))
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Transformation Warning';
                    ToolTip = 'Shows warning if the data transformation will not be possible';
                }
            }
        }
    }

}
