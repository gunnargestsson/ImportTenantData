page 60303 "Import Project Data Part"
{

    PageType = ListPart;
    SourceTable = "Import Project Data";
    Caption = 'Import Project Data Part';
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Modified"; "Last Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Content Length"; "Content Length")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Export)
            {
                ApplicationArea = All;
                Caption = 'Export';
                ToolTip = 'Exports the data for the selected table to a file';
                Image = ExportFile;

                trigger OnAction()
                begin
                    ExportData();
                end;
            }
            action(ReadXml)
            {
                ApplicationArea = All;
                Caption = 'Read Xml';
                ToolTip = 'Reads the Meta Data information from the Xml file';
                Image = XMLSetup;

                trigger OnAction()
                begin
                    PopulateFactboxes();
                end;
            }
        }
    }

}
