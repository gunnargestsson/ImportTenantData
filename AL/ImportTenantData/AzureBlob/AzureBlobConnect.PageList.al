page 60332 "Azure Blob Connect Setup List"
{

    PageType = List;
    SourceTable = "Azure Blob Connect Setup";
    Caption = 'Azure Blob Connect Setup List';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "Azure Blob Connect Setup Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Source ID"; "Source ID")
                {
                    ApplicationArea = All;
                }
                field("Account Name"; "Account Name")
                {
                    ApplicationArea = All;
                }
                field("Container Name"; "Container Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
