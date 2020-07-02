page 60346 "SQL Connect Table Selection"
{
    PageType = List;
    Caption = 'Table Selection';
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("Name"; "Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    procedure Set(var BlobList: Record "Name/Value Buffer")
    begin
        Copy(BlobList, true);
    end;

    procedure GetSelection(var BlobList: Record "Name/Value Buffer")
    begin
        CurrPage.SetSelectionFilter(Rec);
        BlobList.Copy(Rec, true);
    end;
}