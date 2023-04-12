@isTest
public class BatchEduCreditStatusUpdateTest {
    static testmethod void testBatchrun(){
        Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con;
        
        Educational_Credit_Unit_Legacy__c eduCreditUnit = new Educational_Credit_Unit_Legacy__c();
        eduCreditUnit.Credit_End_Date__c = Date.Today().addDays(-1);
        eduCreditUnit.Status__c = 'Active';
        eduCreditUnit.Contact__c = con.id;
        insert eduCreditUnit;
        Test.startTest();
        BatchEduCreditStatusUpdate batchable = new BatchEduCreditStatusUpdate();
        schedularBatchEduCreditStatusUpdate batch = new schedularBatchEduCreditStatusUpdate();
    Database.executeBatch(batchable,100);
        String sch = '0 0 23 * * ?'; 
        system.schedule('Batch EduCredit Status', sch, batch);
        Test.stopTest();
    }
}