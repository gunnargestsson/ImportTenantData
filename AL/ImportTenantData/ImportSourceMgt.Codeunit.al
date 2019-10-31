codeunit 60320 "Import Source Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure GetIsolationStorageSourceId(): Text
    begin
        exit('ImportSourceID');
    end;

    procedure GetCodeunitID(CodeunitName: Text[30]) CodeunitID: Integer
    var
        AllObj: Record AllObj;
    begin
        exit(GetObjectID(CodeunitName, AllObj."Object Type"::Codeunit));
    end;

    procedure GetCodeunitName(CodeunitID: Integer) CodeunitName: Text[30]
    var
        AllObj: Record AllObj;
    begin
        exit(GetObjectName(CodeunitID, AllObj."Object Type"::Codeunit));
    end;

    procedure GetPageID(PageName: Text[30]) PageID: Integer
    var
        AllObj: Record AllObj;
    begin
        exit(GetObjectID(PageName, AllObj."Object Type"::Page);
    end;

    procedure GetPageName(PageID: Integer) PageName: Text[30]
    var
        AllObj: Record AllObj;
    begin
        exit(GetObjectName(PageID, AllObj."Object Type"::Page));
    end;

    local procedure GetObjectID(ObjectName: Text[30]; "ObjectType": Option) ObjectID: Integer
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", "ObjectType");
        AllObj.SetRange("Object Name", ObjectName);
        if AllObj.FindFirst() then
            exit(AllObj."Object ID");
    end;

    local procedure GetObjectName(ObjectID: Integer; "ObjectType": Option) ObjectName: Text[30]
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", "ObjectType");
        AllObj.SetRange("Object ID", ObjectID);
        if AllObj.FindFirst() then
            exit(AllObj."Object Name");
    end;
}