page 60303 "Import Project Data Part"
{

    PageType = ListPart;
    SourceTable = "Import Project Data";
    SourceTableView = sorting("File Name");
    Caption = 'Import Project Data Part';
    InsertAllowed = false;

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
                field("Missing Record Handling"; "Missing Record Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the action to apply if destination record is not found';
                }
                field("Commit Interval"; "Commit Interval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Commit Data during data transer according to this interval';
                }
                field("Job Queue Status"; GetJobQueueEntryStatus())
                {
                    Caption = 'Job Queue Status';
                    Editable = false;
                    ToolTip = 'Displays the Job Queue Entry Status, if the data import has been scheduled and is not completed.';

                    trigger OnDrillDown()
                    begin
                        JobQueueEntryDrillDown();
                    end;
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
            action("Fields")
            {
                ApplicationArea = All;
                Image = Table;
                Caption = 'Fields';
                ToolTip = 'View list of fields for this Xml file';
                RunObject = page "Import Project Data Field List";
                RunPageLink = ID = field(ID);

                trigger OnAction()
                begin

                end;
            }
            action(DestinationMapping)
            {
                ApplicationArea = All;
                Image = MapSetup;
                Caption = 'Destination Mapping';
                ToolTip = 'Configure the data mapping for the import data';
                RunObject = page "Import Project Table Mappings";
                RunPageLink = "Project Table ID" = field(ID);
                RunPageMode = Edit;

                trigger OnAction()
                begin

                end;
            }
            action("ExecuteDataImport")
            {
                ApplicationArea = All;
                Caption = 'Execute Data Import';
                Image = DataEntry;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Page;
                ToolTip = 'Executed the selected data import method for the selected tables.';

                trigger OnAction()
                var
                    ImportProject: Record "Import Project";
                    ImportProjectData: Record "Import Project Data";
                begin
                    CurrPage.SetSelectionFilter(ImportProjectData);
                    ImportProject.StartDataTransfer(ImportProjectData, false);
                end;
            }
            action("ResumeDataImport")
            {
                ApplicationArea = All;
                Caption = 'Resume Data Import';
                Image = DataEntry;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Page;
                ToolTip = 'Executed the selected data import method for the selected tables from the last committed record.';

                trigger OnAction()
                var
                    ImportProject: Record "Import Project";
                    ImportProjectData: Record "Import Project Data";
                begin
                    CurrPage.SetSelectionFilter(ImportProjectData);
                    ImportProject.StartDataTransfer(ImportProjectData, true);
                end;
            }
            action("SceduleDataImport")
            {
                ApplicationArea = All;
                Caption = 'Schedule Data Import';
                Image = Timesheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Page;
                ToolTip = 'Schedule the selected data import method for the selected tables to be executed by the Job Queue.';

                trigger OnAction()
                var
                    ImportProjectData: Record "Import Project Data";
                    ImportProjScheduler: Codeunit "Import Project Data Scheduler";
                begin
                    CurrPage.SetSelectionFilter(ImportProjectData);
                    ImportProjScheduler.ScheduleDataTransfer(ImportProjectData, 10);
                end;
            }
            action("ShowListPage")
            {
                ApplicationArea = All;
                Caption = 'Show Records';
                Image = ListPage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Repeater";
                ToolTip = 'Show the default list page for the data table.';

                trigger OnAction()
                var
                    ImportDataTableInfo: Record "Import Project Data Info";
                    PageMgt: Codeunit "Page Management";
                    RecRef: RecordRef;
                begin
                    if ImportDataTableInfo.Get(ID) then begin
                        RecRef.Open(ImportDataTableInfo."Table ID");
                        PageMgt.PageRun(RecRef);
                    end;
                end;
            }

        }
    }

}
