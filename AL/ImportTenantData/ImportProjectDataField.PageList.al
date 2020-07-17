page 60308 "Import Project Data Field List"
{

    PageType = List;
    SourceTable = "Import Project Data Field";
    Caption = 'Import Project Data Field List';
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
                field("Field ID"; "Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field ID field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field("Data Length"; "Data Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Length field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field(Caption; "Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Caption field';
                }
                field("Blank Numbers"; "Blank Numbers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blank Numbers field';
                }
                field("Blank Zero"; "Blank Zero")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blank Zero field';
                }
                field("Sign Displacement"; "Sign Displacement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sign Displacement field';
                }
                field(Editable; Editable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Editable field';
                }
                field("Not Blank"; "Not Blank")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Not Blank field';
                }
                field(Numeric; Numeric)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Numeric field';
                }
                field("Date Formula"; "Date Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Formula field';
                }
                field("Closing Dates"; "Closing Dates")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Dates field';
                }
                field("Auto Increment"; "Auto Increment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Increment field';
                }
                field("SQL Timestamp"; "SQL Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SQL Timestamp field';
                }
                field("Validate Table Relation"; "Validate Table Relation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Table Relation field';
                }
                field("Test Table Relation"; "Test Table Relation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Test Table Relation field';
                }
                field("Extended Data Type"; "Extended Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Extended Data Type field';
                }
                field("External Access"; "External Access")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Access field';
                }
                field("Access By Object Type"; "Access By Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Access By Object Type field';
                }
                field("Access By Object ID"; "Access By Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Access By Object ID field';
                }
                field("Access By Permission Mask"; "Access By Permission Mask")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Access By Permission Mask field';
                }
                field("Option String"; "Option String")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Option String field';
                }
                field("Option Caption"; "Option Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Option Caption field';
                }
            }
        }
    }

}
