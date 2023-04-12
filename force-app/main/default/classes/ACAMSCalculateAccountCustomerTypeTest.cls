@IsTest
public class ACAMSCalculateAccountCustomerTypeTest {
    @TestSetup
    static void setupData(){
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        List<Account> lstAccount = TestDataFactoryForAccount.insertPersonAccount(2,false);
        insert lstAccount;
        List<ccrz__E_Order__c> lstOrders = new List<ccrz__E_Order__c>();
        ccrz__E_Order__c order = TestDataFactoryForAccount.insertOrder();
        order.ccrz__Account__c = lstAccount[0].Id;
        lstOrders.add(order);
        ccrz__E_Order__c orderNull = TestDataFactoryForAccount.insertOrder();
        orderNull.ccrz__Account__c = lstAccount[0].Id;
        orderNull.Paid_in_Full_Date__c = Null;
        orderNull.ccrz__OrderDate__c = system.today();
        lstOrders.add(orderNull);
        insert lstOrders;
        Asset asset = TestDataFactoryForAccount.insertAsset();
        asset.AccountId = lstAccount[0].Id;
        asset.Assignee__c = lstAccount[0].personcontactid;
        insert asset;
        Opportunity oppty = TestDataFactoryForAccount.insertOppty();
        oppty.AccountId = lstAccount[0].Id;
        oppty.StageName = 'Closed Won';
        oppty.CloseDate = system.today()+365;
        insert oppty;
        
    }
    @isTest
    static void ACAMSCalculateAccountCustomerTypeTest(){
        Test.startTest();
        
        ACAMSCalculateAccountCustomerType accCustomerType = new ACAMSCalculateAccountCustomerType();
        DataBase.executeBatch(accCustomerType); 
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, accCustomerType);
        
        Test.stopTest();
    }
    
}