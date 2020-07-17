page 60323 "Import Source Server List"
{
    PageType = List;
    SourceTable = "Import Source Server File";
    Caption = 'Server File Connect Setup List';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "Server File Connect Setup Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Source ID"; "Source ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source ID field';
                }
                field("File Path"; "File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Path field';
                }
            }
        }
    }
}