page 60331 "Azure Blob Connect Selection"
{
    PageType = List;
    Caption = 'Blob Selection';
    SourceTable = "Azure Blob Connect List";
    SourceTableTemporary = true;
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
                    ToolTip = 'Specifies the value of the File Path field';
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Name field';
                }
                field("Modified Date"; "Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modified Date field';
                }
                field("Modified Time"; "Modified Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modified Time field';
                }
                field("Content Length"; "Content Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Content Length field';
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
