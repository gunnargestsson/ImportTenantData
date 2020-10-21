page 60304 "Fields Selection List"
{
    Caption = 'Select Field';
    Editable = false;
    PageType = List;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(FieldName; FieldName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the primary name associated with the field.';
                }
            }
        }
    }

    actions
    {
    }
}
