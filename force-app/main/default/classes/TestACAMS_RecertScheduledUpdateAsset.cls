@isTest
private class TestACAMS_RecertScheduledUpdateAsset {

    static testMethod void testExecute() {
        test.startTest();
        ACAMS_RecertScheduledUpdateAsset sh1 = new ACAMS_RecertScheduledUpdateAsset();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test ScheduledRecertUpdateAsset', sch, sh1); 
        Test.stopTest();
    }
}