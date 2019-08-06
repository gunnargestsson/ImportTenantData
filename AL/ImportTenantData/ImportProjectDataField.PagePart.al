page 60307 "Import Project Data Field Part"
{

    PageType = ListPart;
    SourceTable = "Import Project Data Field";
    Caption = 'Import Project Data Field Part';
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Xml Field ID"; "Xml Field ID")
                {
                    ApplicationArea = All;
                }
                field("Xml Field Name"; "Xml Field Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
