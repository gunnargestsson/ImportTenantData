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
                SubPageLink = "Project ID" = field(ID);
            }


        }
        area(FactBoxes)
        {
            part(TableInfo; "Import Project Data Info Part")
            {
                ApplicationArea = All;
                Caption = 'Table Details';
                Provider = FileList;
                SubPageLink = ID = field(ID);
            }
            part(FieldInfo; "Import Project Data Field Part")
            {
                ApplicationArea = All;
                Caption = 'Field Details';
                Provider = FileList;
                SubPageLink = ID = field(ID);
            }
            part(MappingInfo; "Import Project Data Map. Part")
            {
                ApplicationArea = All;
                Caption = 'Mapping Details';
                Provider = FileList;
                SubPageLink = "Project ID" = field("Project ID"), ID = field(ID);
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
            action("ExportXml")
            {
                ApplicationArea = All;
                Caption = 'Export Mapping Xml';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Repeater";
                ToolTip = 'Export the selected upgrade project mapping configuration to Xml file.';

                trigger OnAction()
                var
                    ImportProjectData: Record "Import Project Data";
                    TempBlob: Record TempBlob;
                    FileMgt: Codeunit "File Management";
                    Xml: XmlPort "Export Project Mapping XmlPort";
                    OutStr: OutStream;
                begin
                    TempBlob.Blob.CreateOutStream(OutStr);
                    ImportProjectData.SetRange("Project ID", ID);
                    Xml.SetTableView(ImportProjectData);
                    xml.SetDestination(OutStr);
                    Xml.Export();
                    FileMgt.BLOBExport(TempBlob, FileMgt.GetSafeFileName(StrSubstNo(DefaultFileNameTxt, Description)), true);
                end;
            }
            action("ImportXml")
            {
                ApplicationArea = All;
                Caption = 'Import Mapping Xml';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Page";
                ToolTip = 'Import an import project mapping configuration from an Xml file.';

                trigger OnAction()
                var
                    ImportProjectData: Record "Import Project Data";
                    TempBlob: Record TempBlob;
                    FileMgt: Codeunit "File Management";
                    Xml: XmlPort "Import Project Mapping XmlPort";
                    InStr: InStream;
                begin
                    FileMgt.BLOBImport(TempBlob, FileMgt.GetSafeFileName(StrSubstNo(DefaultFileNameTxt, Description)));
                    TempBlob.Blob.CreateInStream(InStr);
                    Xml.SetSource(InStr);
                    Xml.SetProjectID(ID);
                    Xml.Import();
                end;
            }
            action(AutoMap)
            {
                ApplicationArea = All;
                Caption = 'Create Destination Mapping';
                Image = MapAccounts;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Page";
                ToolTip = 'Creates the destination mapping for matching tables in the destination company';

                trigger OnAction()
                var
                    ImportProjectData: Record "Import Project Data";
                    ImportProjectTableMapping: Record "Import Project Table Mapping";
                    ImportProjectDataInfo: Record "Import Project Data Info";
                    AllObj: Record AllObj;
                begin
                    ImportProjectData.SetRange("Project ID", ID);
                    if ImportProjectData.FindSet(true) then
                        repeat
                            ImportProjectTableMapping.SetRange("Project Table ID", ImportProjectData.ID);
                            if ImportProjectTableMapping.IsEmpty() then
                                if ImportProjectDataInfo.Get(ImportProjectData.ID) then
                                    if AllObj.Get(AllObj."Object Type"::Table, ImportProjectDataInfo."Table ID") then begin
                                        ImportProjectTableMapping.Init();
                                        ImportProjectTableMapping.Validate("Project Table ID", ImportProjectData.ID);
                                        ImportProjectTableMapping.Validate("Destination Table ID", ImportProjectDataInfo."Table ID");
                                        ImportProjectTableMapping.Insert();
                                        if ImportProjectTableMapping."No. of Records" = 0 then
                                            ImportProjectData."Missing Record Handling" := ImportProjectData."Missing Record Handling"::Create;
                                        ImportProjectData."Commit Interval" := ImportProjectData."Commit Interval"::"Every 1.000 records";
                                        ImportProjectData.Modify();
                                    end;
                        until ImportProjectData.Next() = 0;
                end;
            }

        }
    }
    var
        DefaultFileNameTxt: Label '%1-MappingConfiguration.xml';
}
