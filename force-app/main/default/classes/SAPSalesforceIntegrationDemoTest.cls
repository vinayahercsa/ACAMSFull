@isTest
public class SAPSalesforceIntegrationDemoTest {
    
    /*@isTest(SeeAllData = true)
    public static void test1(){
        
        Test.setMock(HttpCalloutMock.class, new SAPSalesforceIntegrationMock());
        Test.startTest();
        SAPSalesforceIntegrationDemo.sendRequest();
        Test.stopTest();
    }*/
    
    @isTest(SeeAllData = true)
    public static void test2(){
        
        Test.setMock(HttpCalloutMock.class, new SAPSalesforceIntegrationMock());
        Test.startTest();
        String jobId = system.schedule('SAPIntegrationSchedule', '0 0 22 * * ? *', new SAPSalesforceIntegrationScheduler());
        Test.stopTest();
    }
}