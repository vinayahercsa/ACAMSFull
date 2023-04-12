@IsTest
public with sharing class ACAMSBatchToExpireLeadsTest {

    private static Map<String, Object> initData = new Map<String, Object>();
    
        @TestSetup
    static void initData() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        initData = testUtil.initData();
    }
     @IsTest
    static void testLeadsExpired() {
        Test.startTest();
  

        Database.executeBatch(new ACAMSBatchToExpireLeads());
        Test.stopTest();

   
    }
    
     @IsTest
    static void enrollmentExpiredLeadsScheduled() {
        Test.startTest();
        Id jobId = System.schedule('Expire Leads older than 90 days', '0 0 23 * * ?', new ACAMSBatchToExpireLeads());
        Test.stopTest();
        CronTrigger job = [
                SELECT TimesTriggered
                FROM CronTrigger
                WHERE Id = :jobId
        ];
        System.assertNotEquals(null, job);
    }


}