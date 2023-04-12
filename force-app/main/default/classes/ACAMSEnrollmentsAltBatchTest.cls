@IsTest
public with sharing class ACAMSEnrollmentsAltBatchTest {

    private static Map<String, Object> initData = new Map<String, Object>();

    @TestSetup
    static void initData() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        initData = testUtil.initData();
    }

    @IsTest
    static void testEnrollmentGeneration() {
        Test.startTest();
      
        Database.executeBatch(new ACAMSEnrollmentsAltBatch());
        Test.stopTest();

   
    }

    @IsTest
    static void enrollmentGenerationScheduled() {
        Test.startTest();
        Id jobId = System.schedule('Enrollment Regeneration', '0 0 22 * * ?', new ACAMSEnrollmentsAltBatch());
        Test.stopTest();
        CronTrigger job = [
                SELECT TimesTriggered
                FROM CronTrigger
                WHERE Id = :jobId
        ];
        System.assertNotEquals(null, job);
    }
}