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
                }
                field("Field ID"; "Field ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                }
                field("Data Length"; "Data Length")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field(Caption; "Field Caption")
                {
                    ApplicationArea = All;
                }
                field("Blank Numbers"; "Blank Numbers")
                {
                    ApplicationArea = All;
                }
                field("Blank Zero"; "Blank Zero")
                {
                    ApplicationArea = All;
                }
                field("Sign Displacement"; "Sign Displacement")
                {
                    ApplicationArea = All;
                }
                field(Editable; Editable)
                {
                    ApplicationArea = All;
                }
                field("Not Blank"; "Not Blank")
                {
                    ApplicationArea = All;
                }
                field(Numeric; Numeric)
                {
                    ApplicationArea = All;
                }
                field("Date Formula"; "Date Formula")
                {
                    ApplicationArea = All;
                }
                field("Closing Dates"; "Closing Dates")
                {
                    ApplicationArea = All;
                }
                field("Auto Increment"; "Auto Increment")
                {
                    ApplicationArea = All;
                }
                field("SQL Timestamp"; "SQL Timestamp")
                {
                    ApplicationArea = All;
                }
                field("Validate Table Relation"; "Validate Table Relation")
                {
                    ApplicationArea = All;
                }
                field("Test Table Relation"; "Test Table Relation")
                {
                    ApplicationArea = All;
                }
                field("Extended Data Type"; "Extended Data Type")
                {
                    ApplicationArea = All;
                }
                field("External Access"; "External Access")
                {
                    ApplicationArea = All;
                }
                field("Access By Object Type"; "Access By Object Type")
                {
                    ApplicationArea = All;
                }
                field("Access By Object ID"; "Access By Object ID")
                {
                    ApplicationArea = All;
                }
                field("Access By Permission Mask"; "Access By Permission Mask")
                {
                    ApplicationArea = All;
                }
                field("Option String"; "Option String")
                {
                    ApplicationArea = All;
                }
                field("Option Caption"; "Option Caption")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
