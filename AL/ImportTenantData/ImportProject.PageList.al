page 60300 "Import Project List"
{

    PageType = List;
    SourceTable = "Import Project";
    Caption = 'Import Project List';
    CardPageId = "Import Project Card";
    Editable = false;
    ApplicationArea = All;
    UsageCategory = Lists;

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
                field("Import Source ID"; "Import Source ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Import Source Description"; "Import Source Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
