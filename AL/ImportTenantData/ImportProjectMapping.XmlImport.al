xmlport 60311 "Import Project Mapping XmlPort"
{
    Caption = 'Import Project Mapping XmlPort';
    DefaultNamespace = 'http://navision.guru';
    Encoding = UTF8;
    Format = Xml;
    Direction = Import;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ImportProjectMapping)
        {
            tableelement(ImportProjectData; "Import Project Data")
            {
                UseTemporary = true;

                fieldelement(FileName; ImportProjectData."File Name")
                {
                    trigger OnAfterAssignField()
                    begin
                        ImportProjectData."Project ID" := ProjectID;
                        ImportProjectData.ID := CreateGuid();
                    end;
                }
                textelement(TableID)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        ImportProjectDataInfo.ID := ImportProjectData.ID;
                        evaluate(ImportProjectDataInfo."Table ID", TableID, 9);
                        ImportProjectDataInfo.Insert();
                    end;
                }
                textelement(TableName)
                {
                }

                tableelement(ImportProjectTableMapping; "Import Project Table Mapping")
                {
                    UseTemporary = true;

                    fieldelement(DestinationTableID; ImportProjectTableMapping."Destination Table ID")
                    {
                        trigger OnAfterAssignField()
                        begin
                            ImportProjectTableMapping."Project Table ID" := ImportProjectData.ID;
                        end;
                    }
                    fieldelement(DestinationTableName; ImportProjectTableMapping."Destination Table Name")
                    {
                    }
                    tableelement(ImportProjectFieldMapping; "Import Project Field Mapping")
                    {
                        UseTemporary = true;

                        fieldelement(ProjectFieldID; ImportProjectFieldMapping."Project Field ID")
                        {
                            trigger OnAfterAssignField()
                            begin
                                ImportProjectFieldMapping."Project Table ID" := ImportProjectData.ID;
                                ImportProjectFieldMapping."Destination Table ID" := ImportProjectTableMapping."Destination Table ID";
                            end;
                        }
                        fieldelement(DestinationTableID; ImportProjectFieldMapping."Destination Table ID")
                        {
                        }
                        fieldelement(DestinationFieldID; ImportProjectFieldMapping."Destination Field ID")
                        {
                        }
                        fieldelement(DestinationFieldName; ImportProjectFieldMapping."Destination Field Name")
                        {
                        }
                        fieldelement(ProjectFieldName; ImportProjectFieldMapping."Project Field Name")
                        {
                        }
                        fieldelement(TransformationRule; ImportProjectFieldMapping."Transformation Rule")
                        {
                        }
                    }
                }
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    trigger OnPostXmlPort()
    var
        ApplyImport: Codeunit "Import Project Apply Mapping";
    begin
        ApplyImport.ApplyImportedMapping(ImportProjectData, ImportProjectDataInfo, ImportProjectTableMapping, ImportProjectFieldMapping);
    end;

    procedure SetProjectID(ImportToProjectID: Guid)
    begin
        ProjectID := ImportToProjectID;
    end;

    var
        ImportProjectDataInfo: Record "Import Project Data Info" temporary;
        ProjectID: Guid;

}
