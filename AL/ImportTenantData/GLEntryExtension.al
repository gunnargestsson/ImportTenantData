tableextension 60300 "G/L Entry Extension" extends "G/L Entry"
{
    fields
    {
        field(60300; ChangedDateTime; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Change Date Time';
        }
    }
}
pageextension 60300 "G/L Entry Extension" extends "General Ledger Entries"
{
    layout
    {
        addafter("Posting Date")
        {
            field(ChangedDateTime; ChangedDateTime)
            {
                ApplicationArea = All;
            }
        }

    }

    actions
    {

    }
}

