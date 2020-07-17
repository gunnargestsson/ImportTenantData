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
                    ToolTip = 'Specifies the value of the ID field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Codeunit Name"; "Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Codeunit Name field';
                }
                field("Setup Page Name"; "Setup Page Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Setup Page Name field';
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
