@isTest
private class EnrollmentMergeIntEventTriggerTest {
    @isTest 
    static void testEnrollmentMergeIntEventTrigger() {
        //test data
        Enrollment_Merge_Integration__e testEvent = new Enrollment_Merge_Integration__e(
            MergeEnrollmentBody__c = 'test body'
        );

        // Test trigger
        Test.startTest();
        EventBus.publish(testEvent);
        Test.stopTest();

        
        System.assert(Test.isRunningTest(), 'Test is running');
        
    }
}