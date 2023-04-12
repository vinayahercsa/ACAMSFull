public class ACAMSInterestsPopupOnLeadController {
    @AuraEnabled
    public static List<Interest__c> getInterestsFromLead(String leadId){
        List<Interest__c> InterestList = new List<Interest__c>();
        InterestList = [select Id, name, Lead__c, Form__c, Select_To_Associate__c, Opportunity__c, Contact__c, Interest_Status__c, Product_Level_1__c, Product_Level_2__c, Lead_Status__c from Interest__c WHERE Lead__r.Id =: leadId AND (NOT(Lead_Status__c LIKE '%Closed%'))];
        //FSA-6898
        return InterestList;        
    }
    
    @AuraEnabled
    public static string updateInterestsFromLead( List<Interest__c> allRecords, List<Interest__c> InterestList){
        List<Interest__c> InterestToUpdate = new List<Interest__c>();
        system.debug('------selected---'+InterestList);
        system.debug('------all Records---'+allRecords);
        Set<Id> selectedInteresIds = new Set<Id>();
        if(!InterestList.isEmpty()){
            for(Interest__c intr: InterestList){
                selectedInteresIds.add(intr.Id);
            }
        }
        if(!allRecords.isEmpty()){
            for(Interest__c intr: allRecords){
                system.debug('---------'+intr);
                if(selectedInteresIds.contains(intr.Id)){
                    intr.Select_To_Associate__c = true;
                }else{
                    intr.Select_To_Associate__c = false;
                }
                
                InterestToUpdate.add(intr);
            }            
            if(!InterestToUpdate.isEmpty()){
                update InterestToUpdate;
            }
        }
        return '';        
    }
}