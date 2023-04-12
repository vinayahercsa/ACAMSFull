/***
 * @Description, handler business logic for Lead Trigger
 * @Date, May 6,2020
 * @Ray
 */
public class ACAMSLeadTriggerHandler extends CCAviTriggerHandler{
    private List<Lead> newList = (List<Lead>) Trigger.new;
    private Map<Id, Lead> oldMap = (Map<Id, Lead>) Trigger.oldMap;

    /***
     * constructor
     * **/
    public ACAMSLeadTriggerHandler() {

    }
    /***
     *  method execute before insert
    */
    
    protected override void beforeInsert(){
        updateReassignFlagBeforeinsert();
    }
    
    private void updateReassignFlagBeforeinsert(){
        for(lead ld : newList){
            if(ld.risk_assessment__c == True || ld.sponsorship__c == True){
                ld.reassign__c = True;
            }
        }
    }
    
    
  /***
     *  method execute before update
     */
   protected override void beforeUpdate() {
       updateReassignFlag();  
     
    }
    
  /***
     *  method execute afterInsert
     */
    
    protected override void afterInsert() {
         system.debug('afterInsert CALLED->');
         reassignLeadBeforeinsert();
    }
    
    /***
     *  method execute after update
     */
    protected override void afterUpdate() {
        reassignLeadAfterUpdate();
        associateIntrestsOnOpportunityAccount(); //FSA-6582
    }
    
    //FSA-6582 method for lead related intrest records, get associate with account and opportunity get crating 
    private void associateIntrestsOnOpportunityAccount(){
        
        Map<Id,Lead> leadConverted = new Map<Id,Lead>();
        for (Lead l : newList) {
            if (l.IsConverted) {
                leadConverted.put(l.Id,l);
            }
        }

        if(leadConverted.size() > 0 && !leadConverted.isEmpty()) {
            List<Interest__c> lstIntrests = [select Id, Lead__c, Select_To_Associate__c, Opportunity__c, Contact__c, Lead_Status__c from Interest__c WHERE Lead__r.Id IN :leadConverted.keySet()];
            if(!lstIntrests.isEmpty()){
                for(Interest__c intst : lstIntrests){                    
                    if(intst.Select_To_Associate__c == true){
                        //intst.Lead_Status__c = leadConverted.get(intst.Lead__c).Status;
                        intst.Lead_Status__c = 'Qualified';
                        If(leadConverted.get(intst.Lead__c).ConvertedOpportunityId != null)
                        intst.Opportunity__c = leadConverted.get(intst.Lead__c).ConvertedOpportunityId;
                        intst.Contact__c = leadConverted.get(intst.Lead__c).ConvertedContactId;
                    } else {
                        //FSA-6898
                        if(intst.Lead_Status__c =='Not Contacted' || intst.Lead_Status__c =='Attempting Contact'){
                            intst.Lead_Status__c='Closed – Not Qualified';
                        }                                              
                        intst.Contact__c = leadConverted.get(intst.Lead__c).ConvertedContactId; //ConvertedAccountId 
                    }
                }
                update lstIntrests;
            }
        }       
    } // method close FSA-6582
    
  
    private void updateReassignFlag(){
        List<lead> leadSetIdsToReassign = new List<lead>();
        User usr = [select id, profile.Name from user where id = :UserInfo.getUserId()];
        for (Lead l : newList) {
            system.debug('old Company_Name__c '+oldMap.get(l.Id).Company_Name__c);
            system.debug('l.Company_Name__c '+l.Company_Name__c);
            system.debug('old Country '+ oldMap.get(l.Id).Billing_Country__c);
            system.debug('l.Billing_Country__c '+l.Billing_Country__c);
            system.debug('Old Industry '+oldMap.get(l.Id).Industry);
            system.debug('Industry '+l.Industry);
            system.debug('Old State '+oldMap.get(l.Id).Billing_State__c);
            system.debug('l.Billing_State__c '+l.Billing_State__c);
            system.debug('Old Risk_Assessment__c'+OldMap.get(l.Id).Risk_Assessment__c);
            system.debug('l.Risk_Assessment'+l.Risk_Assessment__c);
            system.debug('Old Sponsorship__c'+OldMap.get(l.Id).Sponsorship__c);
            system.debug('l.Sponsorship__c'+l.Sponsorship__c);
            if (((oldMap.get(l.Id).Company_Name__c != l.Company_Name__c && l.Company_Name__c != null)||
                (oldMap.get(l.Id).Industry != l.Industry && l.Industry != null)||
                (oldMap.get(l.Id).Billing_Country__c != l.Billing_Country__c && l.Billing_Country__c != null)||
                (oldMap.get(l.Id).Billing_State__c != l.Billing_State__c && l.Billing_State__c != null)||
                (oldMap.get(l.Id).Risk_Assessment__c != l.Risk_Assessment__c)||
                (oldMap.get(l.Id).Sponsorship__c != l.Sponsorship__c))
                 && l.Exclude_from_lead_assignment__c == false  && usr.profile.Name != 'Data Migration'){            
                  leadSetIdsToReassign.add(l);
            }
        }

        if (leadSetIdsToReassign != null && leadSetIdsToReassign.size() > 0) {
            system.debug('leadSetIdsToReassign'+leadSetIdsToReassign);
            List<lead> updateLeads = new List<lead>();
            for(lead ld : leadSetIdsToReassign){
                ld.Reassign__c = true;
                system.debug('ld.Reassign__c '+ld.Reassign__c);
            }
        }
    }
    
     /***
     * @Description: invoke reassignLeads method, execute this method before insert trigger.
     */ 

    private void reassignLeadBeforeinsert(){
        Set<Id> leadSetIdsToReassign = new Set<Id>();
        for (Lead l : newList) {
            if (l.Reassign__c) {
                leadSetIdsToReassign.add(l.Id);
            }
        }

        if (leadSetIdsToReassign != null && leadSetIdsToReassign.size() > 0) {
            reassignLeads(leadSetIdsToReassign);
        }
     }
    
    /***
     * @Description: invoke reassignLeads method, execute this method after trigger udpate.
     */
    
    private void reassignLeadAfterUpdate(){
        Set<Id> leadSetIdsToReassign = new Set<Id>();
        for (Lead l : newList) {
            if (oldMap.get(l.Id).Reassign__c != l.Reassign__c && l.Reassign__c) {
                leadSetIdsToReassign.add(l.Id);
            }
        }

        if (leadSetIdsToReassign != null && leadSetIdsToReassign.size() > 0) {
            reassignLeads(leadSetIdsToReassign);
        }
    }

    /**
     *  @Description: ReassignLeads,assign owner to legacy leads records. 
     */
    private void reassignLeads(Set<Id> leadsToReassignSetIds) {
        Map<Id, lead> leadsToUpdateMap = new Map<Id, lead>();
        Map<Id, Lead> leadsToProcessMap = new Map<Id, Lead>();

        if (leadsToReassignSetIds != null && leadsToReassignSetIds.size() > 0) {
            for (Lead lead : [SELECT Id,Reassign__c FROM Lead WHERE Id IN:leadsToReassignSetIds]) {
                leadsToProcessMap.put(lead.Id, lead);
            }
        }

        List<AssignmentRule> arList = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
        if(arList != null && arList.size() > 0){
            for (Lead lead : leadsToProcessMap.values()) {
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.assignmentRuleId = arList[0].id;
                if (lead.Reassign__c = true) {
                    Lead newLead = new Lead(Id = lead.Id);
                    newLead.setOptions(dmo);
                    newLead.Reassign__c = false;
                    leadsToUpdateMap.put(newLead.Id, newLead);
                    system.debug('leadsToUpdateMap 123'+leadsToUpdateMap);
                }
            }

            try {
                if (leadsToUpdateMap.values().size() > 0) {
                    Database.SaveResult [] srList = Database.update(leadsToUpdateMap.values(), false);
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            System.debug(sr.getId() + ' IS THE VALUE OF sr.getId()  ');
                        } else {
                            for (Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
            } catch (exception e) {
                System.debug(e.getMessage() + 'e.getMessage()');
                throw e;
            }
        }

    }

}