@IsTest
public with sharing class ACAMSAccountAssetRecalculationBatchTest {
    @TestSetup
    static void initData() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        Account testAccount = new Account(
                Name = 'test',
                Assets_Assigned__c = 2
        );
        insert testAccount;
        Contact testContact = new Contact(
                LastName = 'Test',
                AccountId = testAccount.Id
        );
        insert testContact;
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>{
                testUtil.createProduct('Test 1', 'TEST1', 'Membership'),
                testUtil.createProduct('Test 2', 'TEST2', 'Membership')
        };
        insert products;
        List<Asset> testAssets = new List<Asset>{
                new Asset(
                        Name = 'test1',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        CC_Product__c = products[0].Id
                ),
                new Asset(
                        Name = 'test2',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        CC_Product__c = products[1].Id
                ),
                new Asset(
                        Name = 'test3',
                        AccountId = testAccount.Id,
                        CC_Product__c = products[0].Id
                )
        };
        insert testAssets;
    }

    @IsTest
    static void recalculateAccountSummary() {
        Test.startTest();
        Database.executeBatch(new ACAMSAccountAssetRecalculationBatch(Datetime.now().addHours(-1)));
        Test.stopTest();
        Account testAccount = [
                SELECT Assets_Assigned__c, Assets_Unassigned__c
                FROM Account
                LIMIT 1
        ];
        System.assertEquals(2, testAccount.Assets_Assigned__c);
        System.assertEquals(1, testAccount.Assets_Unassigned__c);
    }

    @IsTest
    static void recalculateScheduledAccountSummary() {
        Test.startTest();
        Id jobId = System.schedule('test account asset', '0 0 23 * * ?', new ACAMSAccountAssetRecalculationBatch());
        Test.stopTest();
        CronTrigger job = [
                SELECT TimesTriggered
                FROM CronTrigger
                WHERE Id = :jobId
        ];
        System.assertNotEquals(null, job);
    }
}