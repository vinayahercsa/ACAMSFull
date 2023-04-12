@isTest
public with sharing class FSIT_BatchWebinarsUpsertTest {
    static testMethod void testExcecute() {
        List<Global_Variable__c> globalValues = FSIT_CalloutUtilityTestDataFactory.createGlobalVariable();
        List<BeckerLMS_Enrollment__c> lmsCourse = FSIT_CalloutUtilityTestDataFactory.createBeckLMSEnrollmentRecords(2);
        Database.SaveResult[] lmsCourseList = Database.Insert(lmsCourse, false);
        Database.SaveResult[] globalValuesInsertResult = Database.Insert(globalValues, false);
        Test.startTest();
        BatchWebinarsUpsert job = new BatchWebinarsUpsert();
        Database.executeBatch(job);
        Test.stopTest();
    }
}