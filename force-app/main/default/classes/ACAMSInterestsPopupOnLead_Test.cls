@IsTest
public class ACAMSInterestsPopupOnLead_Test {
    @IsTest
    public static  void ACAMSInterestsPopupTest1(){
        List<Lead> leadList = new List<Lead>{
            new Lead(Status='New',LastName='TestLast',FirstName='TestFirstName',Company='test company',Reassign__c=false,Country='US', State='IL',Phone='+85223456789',MobilePhone='+45223456789')
        };
        insert leadList;
        
        for(Lead l : leadList){
            l.Reassign__c = true;
        }
        update leadList;
        System.assertEquals(true, leadList[0].Reassign__c);
    
    
    List<Interest__c> InterestList = new List<Interest__c>();
    Interest__c intr = new Interest__c();
    intr.name = 'test';
    intr.Lead__c = leadList.get(0).id;
    intr.Form__c = 'abc';
    intr.Select_To_Associate__c = true;
    InterestList.add(intr);
    insert InterestList;

    ACAMSInterestsPopupOnLeadController.getInterestsFromLead(string.valueof(leadList.get(0).id));
    ACAMSInterestsPopupOnLeadController.updateInterestsFromLead(InterestList,InterestList);
    }
}