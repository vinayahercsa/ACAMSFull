@IsTest
public class FSIT_ACAMSRecertBatchUpdateAssetTest {
    public FSIT_ACAMSRecertBatchUpdateAssetTest() {

    }

    static testMethod void testExcecute() {
        List<Recertification_Application__c> recerApplicationList = FSIT_CalloutUtilityTestDataFactory.createRecApplications(1,'Approved');
        List<Asset> assetList = FSIT_CalloutUtilityTestDataFactory.createAssetList(1,'Recertifications');
        List<Contact> contList = FSIT_CalloutUtilityTestDataFactory.createContactRecord();

        Database.SaveResult[] contactInsert = Database.Insert(contList, false);
        for(Asset a : assetList){
            a.Assignee__c = contList[0].Id;
        }
        for(Recertification_Application__c recer : recerApplicationList){
            recer.Contact__c = contList[0].Id;
        }
        Database.SaveResult[] assetInsert = Database.Insert(assetList, false);
        Database.SaveResult[] recerInsert = Database.Insert(recerApplicationList, false);
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?';
        ACAMS_RecertBatchUpdateAsset job = new ACAMS_RecertBatchUpdateAsset();
        Database.executeBatch(job);
        Test.stopTest();

        }
}