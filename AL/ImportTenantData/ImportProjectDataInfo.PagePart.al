page 60306 "Import Project Data Info Part"
{

    PageType = CardPart;
    SourceTable = "Import Project Data Info";
    Caption = 'Import Project Data Info Part';

    layout
    {
        area(content)
        {
            field("Table ID"; "Table ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Table ID field';
            }
            field(Name; Name)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Name field';
            }
            field(Caption; Caption)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Caption field';
            }
            field("Data Per Company"; "Data Per Company")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Data Per Company field';
            }
            field("Table Type"; "Table Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Table Type field';
            }

        }
    }

}
