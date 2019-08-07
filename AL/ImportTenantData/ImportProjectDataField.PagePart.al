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
                field("Field ID"; "Field ID")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
