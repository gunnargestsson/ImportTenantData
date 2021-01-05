page 60302 "Import Project Data List"
{

    PageType = List;
    SourceTable = "Import Project Data";
    Caption = 'Import Project Data List';
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; ID)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the ID field';
                }
                field("Project ID"; "Project ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Project ID field';
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Name field';
                }
                field("Last Modified"; "Last Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Modified field';
                }
                field("Content Length"; "Content Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Content Length field';
                }
            }
        }
    }

}
