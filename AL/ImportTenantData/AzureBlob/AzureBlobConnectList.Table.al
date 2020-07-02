table 60331 "Azure Blob Connect List"
{
    DataClassification = SystemMetadata;
    Caption = 'Azure Blob Connect List';
    DataCaptionFields = "File Name";
    LookupPageId = "Azure Blob Connect List";
    DrillDownPageId = "Azure Blob Connect List";


    fields
    {
        field(1; "File Path"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'File Path';
        }
        field(2; "File Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'File Name';
        }
        field(3; "Modified Date"; Date)
        {
            DataClassification = SystemMetadata;
            Caption = 'Modified Date';
        }
        field(4; "Modified Time"; Time)
        {
            DataClassification = SystemMetadata;
            Caption = 'Modified Time';
        }
        field(5; "Content Length"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Content Length';
        }
    }

    keys
    {
        key(PK; "File Path")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure ReadFromJSON(JObject: JsonObject)
    var
        JArray: JsonArray;
        JFile: JsonObject;
        JToken: JsonToken;
        Index: Integer;
    begin
        JObject.Get('List', JToken);
        JArray := JToken.AsArray();
        for Index := 0 to JArray.Count - 1 do begin
            Init();
            JArray.Get(Index, JToken);
            JFile := JToken.AsObject();
            JFile.Get('Path', JToken);
            "File Path" := JToken.AsValue().AsText();
            JFile.Get('Name', JToken);
            "File Name" := JToken.AsValue().AsText();
            JFile.Get('Size', JToken);
            "Content Length" := JToken.AsValue().AsInteger();
            JFile.Get('Date', JToken);
            evaluate("Modified Date", JToken.AsValue().AsText(), 9);
            JFile.Get('Time', JToken);
            evaluate("Modified Time", JToken.AsValue().AsText());
            Insert();
        end;
    end;
}