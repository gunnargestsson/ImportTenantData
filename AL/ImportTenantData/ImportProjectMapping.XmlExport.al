xmlport 60310 "Export Project Mapping XmlPort"
{
    Caption = 'Export Project Mapping XmlPort';
    DefaultNamespace = 'http://navision.guru';
    Encoding = UTF8;
    Format = Xml;
    Direction = Export;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ImportProjectMapping)
        {
            tableelement(ImportProjectData; "Import Project Data")
            {
                SourceTableView = sorting ("File Name");

                fieldelement(FileName; ImportProjectData."File Name")
                {
                }
                fieldelement(TableID; ImportProjectData."Table ID")
                {
                }
                fieldelement(TableName; ImportProjectData."Table Name")
                {
                }

                tableelement(ImportProjectTableMapping; "Import Project Table Mapping")
                {
                    LinkTable = ImportProjectData;
                    LinkFields = "Project Table ID" = field (ID);

                    fieldelement(DestinationTableID; ImportProjectTableMapping."Destination Table ID")
                    {
                    }
                    fieldelement(DestinationTableName; ImportProjectTableMapping."Destination Table Name")
                    {
                    }
                    tableelement(ImportProjectFieldMapping; "Import Project Field Mapping")
                    {
                        LinkTable = ImportProjectTableMapping;
                        LinkFields = "Project Table ID" = field ("Project Table ID"), "Destination Table ID" = field ("Destination Table ID");

                        fieldelement(ProjectFieldID; ImportProjectFieldMapping."Project Field ID")
                        {
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
                trigger OnPreXmlItem()
                begin
                    ImportProjectData.CalcFields("Table ID", "Table Name");
                end;

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
}
