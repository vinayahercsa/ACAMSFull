@IsTest
public class ACAMSAssetTermRecalculationSchedulerTest {

    @TestSetup
    static void initData() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        Account testAccount = new Account(
            Name = 'test'
        );
        insert testAccount;
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>{
                testUtil.createProduct('Test 1', 'TEST1', 'Membership'),
                testUtil.createProduct('Test 2', 'TEST2', 'Membership')
        };
        insert products;
        Asset testAsset = new Asset(
                Name = 'Membership',
                AccountId = testAccount.Id,
                Status__c = 'Active',
                CC_Product__c = products[0].Id,
                Assignee__c = testAccount.PersonContactId,
                Paid_Cert__c = true,
                Effective_Date__c = Date.today().addDays(-1).addYears(-1),
                CurrentExpirationDate__c = Date.today().addDays(-1)
        );
        insert testAsset;
        Asset testAsset2 = new Asset(
                Name = 'Membership',
                AccountId = testAccount.Id,
                Status__c = 'Active',
                CC_Product__c = products[1].Id,
                Assignee__c = testAccount.PersonContactId,
                Paid_Cert__c = true,
                Effective_Date__c = Date.today(),
                CurrentExpirationDate__c = Date.today().addYears(1),
                ParentId = testAsset.Id
        );
        insert testAsset2;
    }

    @IsTest
    static void updateAssetInBatch() {
        Test.startTest();
        Database.executeBatch(new ACAMSAssetTermRecalculationScheduler());
        Test.stopTest();
        List<Asset> testAssets = [
            SELECT Status__c, CC_Product__r.Name
            FROM Asset
            WHERE Status__c = 'Active'
        ];
       // System.assertEquals(1, testAssets.size());
        //System.assertEquals('Test 1', testAssets[0].CC_Product__r.Name);
    }

    @IsTest
    static void updateAssetInSchedule() {
        Test.startTest();
        Id jobId = System.schedule('Test', '0 0 23 * * ?', new ACAMSAssetTermRecalculationScheduler());
        Test.stopTest();
        CronTrigger job = [
            SELECT TimesTriggered
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertNotEquals(null, job);
    }

}