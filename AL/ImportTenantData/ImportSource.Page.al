page 60320 "Import Data Sources"
{

    PageType = List;
    SourceTable = "Import Data Source";
    Caption = 'Import Data Sources';
    ApplicationArea = All;
    UsageCategory = Lists;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Editable = false;
                field(ID; ID)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Codeunit Name"; "Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Setup Page Name"; "Setup Page Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Setup)
            {
                ApplicationArea = All;
                Image = Setup;
                Caption = 'Setup';
                ToolTip = 'Opens the Setup Page for the current import source';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    OpenSetupPage();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        RegisterImportSource();
    end;
}
