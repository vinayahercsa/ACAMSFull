@isTest
public class TestschBatchAssetStatusUpdation {
static testMethod void testExcecute() {
    List<Asset> assetList = FSIT_CalloutUtilityTestDataFactory.createAssetList(2,'Memberships');
        Database.SaveResult[] srList = Database.Insert(assetList, false);
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?';
        schBatchAssetStatusUpdation sch = new schBatchAssetStatusUpdation();
        system.schedule('Contact opt', CRON_EXP, sch);
        Test.stopTest();
    }
}