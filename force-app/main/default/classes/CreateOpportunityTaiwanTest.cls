@isTest
public class CreateOpportunityTaiwanTest {
    @isTest
    public static void CreateOpportunityTest(){
        ccrz__E_Order__c ord = new ccrz__E_Order__c();
        insert ord;
        list<Id> OrdIds = new list<Id>();
        OrdIds.add(ord.Id);
        CreateOpportunityTaiwan.CreateOpportunity(OrdIds);
    }
}