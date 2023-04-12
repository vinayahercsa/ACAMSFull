@IsTest
public with sharing class ACAMSOrderAssetGenerateBatchTest {

    private static Map<String, Object> initData = new Map<String, Object>();

    @TestSetup
    static void initData() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        initData = testUtil.initData();
    }

    @IsTest
    static void testAssetGeneration() {
        Test.startTest();
        ccrz__E_Order__c order = [
                SELECT Id, Assets_Assigned__c, Assets_Unassigned__c, (SELECT Id FROM Assets__r)
                FROM ccrz__E_Order__c
                LIMIT 1
        ];
        System.assertEquals(order.Assets_Assigned__c, null);
        System.assertEquals(order.Assets_Unassigned__c, null);
        System.assertEquals(order.Assets__r.size(), 0);
        Database.executeBatch(new ACAMSOrderAssetGenerateBatch());
        Test.stopTest();

        order = [
                SELECT Id, Assets_Assigned__c, Assets_Unassigned__c, (SELECT Id FROM Assets__r)
                FROM ccrz__E_Order__c
                LIMIT 1
        ];

        System.assertEquals(order.Assets__r.size(), 2);
    }

    @IsTest
    static void assetGenerationScheduled() {
        Test.startTest();
        Id jobId = System.schedule('Asset Regeneration', '0 0 23 * * ?', new ACAMSOrderAssetGenerateBatch());
        Test.stopTest();
        CronTrigger job = [
                SELECT TimesTriggered
                FROM CronTrigger
                WHERE Id = :jobId
        ];
        System.assertNotEquals(null, job);
    }
}