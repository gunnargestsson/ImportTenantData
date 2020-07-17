codeunit 60400 "Import Tenant Data Tests"
{
    Subtype = Test;
    [Test]
    procedure "ImportSource_OpenPage_VerifySourcesExists"()
    var
        ImportSourceList: TestPage "Import Data Sources";
    begin
        // [GIVEN] Import Source 

        // [WHEN] Open Page 
        ImportSourceList.OpenView();

        // [THEN] Verify Sources Exists 
        Assert.IsTrue(ImportSourceList.First(), 'No import source found');
    end;

    var
        Assert: Codeunit "Library Assert";
}