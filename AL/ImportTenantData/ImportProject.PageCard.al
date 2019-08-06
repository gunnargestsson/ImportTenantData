page 60301 "Import Project Card"
{

    PageType = Card;
    SourceTable = "Import Project";
    Caption = 'Import Project Card';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description for this import project';
                }
                field("Import Source Description"; "Import Source Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Data Source for the Xml files that are to be imported';
                    trigger OnAssistEdit()
                    var
                        ImportSource: Record "Import Data Source";
                    begin
                        if CurrPage.Editable then
                            if page.RunModal(page::"Import Data Sources", ImportSource) = Action::LookupOK then
                                validate("Import Source ID", ImportSource.ID)
                    end;
                }

            }

            part(FileList; "Import Project Data Part")
            {
                Caption = 'Files';
                ShowFilter = false;
                ApplicationArea = All;
                SubPageLink = "Project ID" = field (ID);
            }


        }
        area(FactBoxes)
        {
            part(TableInfo; "Import Project Data Info Part")
            {
                ApplicationArea = All;
                Caption = 'Table Details';
                Provider = FileList;
                SubPageLink = ID = field (ID);
            }
            part(FieldInfo; "Import Project Data Field Part")
            {
                ApplicationArea = All;
                Caption = 'Field Details';
                Provider = FileList;
                SubPageLink = ID = field (ID);
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Import)
            {
                ApplicationArea = All;
                Caption = 'Import';
                ToolTip = 'Import the file selection from the import source to import the file data';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Import();
                    PopulateFactboxes();
                end;
            }
        }
    }
}
