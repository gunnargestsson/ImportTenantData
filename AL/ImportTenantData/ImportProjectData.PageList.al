page 60302 "Import Project Data List"
{

    PageType = List;
    SourceTable = "Import Project Data";
    Caption = 'Import Project Data List';
    ApplicationArea = All;
    UsageCategory = Lists;
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
                }
                field("Project ID"; "Project ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                }
                field("Last Modified"; "Last Modified")
                {
                    ApplicationArea = All;
                }
                field("Content Length"; "Content Length")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
