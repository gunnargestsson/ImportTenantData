page 60331 "Azure Blob Connect List"
{
    PageType = List;
    SourceTable = "Azure Blob Connect List";
    SourceTableTemporary = true;
    Caption = 'Azure Blob Connect List';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("File Path"; "File Path")
                {
                    ApplicationArea = All;
                    Visible = False;
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                }
                field("Modified Date"; "Modified Date")
                {
                    ApplicationArea = All;
                }
                field("Modified Time"; "Modified Time")
                {
                    ApplicationArea = All;
                }
                field("Content Length"; "Content Length")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    procedure Set(var BlobList: Record "Azure Blob Connect List")
    begin
        Copy(BlobList, true);
    end;

    procedure GetSelection(var BlobList: Record "Azure Blob Connect List")
    begin
        CurrPage.SetSelectionFilter(Rec);
        BlobList.Copy(Rec, true);
    end;

}
