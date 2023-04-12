public class ACAMS_MergeHelper {

     public static void MergeLMSUser(List<Account> oldContacts, Map<Id, Account> oldMapContacts,String masterIDmerge, String cntIDmerge, String usernamemerge) {

         try{
         Set<Id> conmap=new Set<Id>();
         for(Account con:oldContacts){
            if(con.MasterRecordId != null )
        conmap.add(con.MasterRecordId);       
         }
          List<Account> contactlist=[SELECT Id,firstname,lastname,personemail FROM Account WHERE Id IN:conmap];
          string json_string;
          List<LMSUtility.LMSMergeRequest> lmsusermergeList = new List<LMSUtility.LMSMergeRequest>();
          LMSUtility.LMSMergeRequestList lmsusermergecontactList = new LMSUtility.LMSMergeRequestList();   
                    
            if (oldContacts != NULL && oldContacts.size() > 0 && oldMapContacts != NULL && oldMapContacts.size() > 0 ){
              for(Account cwon :contactlist)
                for(Account c : oldContacts){
                    Account oldC = oldMapContacts.get(c.Id);
                    if (oldC != NULL  && c.MasterRecordId != null){
                       
                        LMSUtility.LMSMergeRequest lmsmergeuserfailed = new LMSUtility.LMSMergeRequest();
                        String cntId = c.Id;
                        lmsmergeuserfailed.contactId = cntId.capitalize();
                        lmsmergeuserfailed.firstName = c.FirstName;
                        lmsmergeuserfailed.lastName = c.LastName;
                        lmsmergeuserfailed.username = c.personemail;
                        lmsmergeuserfailed.master = false;
                        
                        LMSUtility.LMSMergeRequest lmsmergeuserwon = new LMSUtility.LMSMergeRequest();
                        String MasterId =c.MasterRecordId;
                        lmsmergeuserwon.contactId = MasterId.capitalize();
                        lmsmergeuserwon.firstName = cwon.FirstName;
                        lmsmergeuserwon.lastName = cwon.LastName;
                        lmsmergeuserwon.username = cwon.personemail;
                        lmsmergeuserwon.master = true;
                        
                       
                        lmsusermergeList.add(lmsmergeuserfailed);
                        lmsusermergeList.add(lmsmergeuserwon);
						lmsusermergecontactList.MergeAccounts = lmsusermergeList;
                        json_string = JSON.serialize(lmsusermergecontactList);
                       
                        system.debug(lmsusermergeList);
                        system.debug(lmsusermergecontactList);
                        system.debug(json_string);

                 	if (lmsusermergecontactList != null)
		                CalloutUtility.SendRequestMerge('AccountMergeIntegration', true, json_string, masterIDmerge,cntIDmerge,usernamemerge);
                    
                }
            }
                 
        }
          
         }
           catch(Exception ex){
                           //csa fix added exception logger statement. 
               ACAMSUtil.reportException(null, null,'MergeLMSUser Method', null, ex.getMessage(), null, null);
            }
         
     }
  
      //CSA-fx - method parameters changed, reduced queries and bulkified code
       public static void MergeEnrollment(list<Account> accountList,String LibID) {
    
        List<BeckerLMS_Enrollment__c> enrollmentsToUpdate = new List<BeckerLMS_Enrollment__c>();
        String masterenrId;
        set<Id> accountIds = new set<Id>();
        map<String,list<BeckerLMS_Enrollment__c>> accVsBeckMap = new map<String,list<BeckerLMS_Enrollment__c>>();
        map<String,BeckerLMS_Enrollment__c> masterMap = new map<String,BeckerLMS_Enrollment__c>();            
        map<String,BeckerLMS_Enrollment__c> mapBeckIdvsBeck = new map<String,BeckerLMS_Enrollment__c>();
            try {
            for(Account acct : accountList){
              accountIds.add(acct.Id);
            }
            List<BeckerLMS_Enrollment__c> enrollments = [SELECT Id, LMS_Course__c,Account__c,Account__r.Old_Contact_Id__c,Account__r.Old_Contact_Username__c,Purchase_Date__c, LMS_Course_ID__c, Score__c, LastModifiedDate, Username__c, Status__c 
                                                          FROM BeckerLMS_Enrollment__c 
                                                          WHERE Account__c IN :accountIds AND LMS_Course__c = :LibID 
                                                          ORDER BY LastModifiedDate ASC];
            
            if (enrollments.size() > 0) {
                for (BeckerLMS_Enrollment__c beck : enrollments) {
                    if(accVsBeckMap.containsKey(beck.Account__c)) {
                      accVsBeckMap.get(beck.Account__c).add(beck);
                    }
                    else{
                      accVsBeckMap.put(beck.Account__c,new List<BeckerLMS_Enrollment__c>{beck});
                    }
                    mapBeckIdvsBeck.put(beck.Id,beck);
                }
            }
            
            for(String accId : accVsBeckMap.keySet()){
                    masterenrId = accVsBeckMap.get(accId)[0].Id;
                    masterMap.put(accId,accVsBeckMap.get(accId)[0]);
                    for (Integer i = 1; i < accVsBeckMap.get(accId).size(); i++) {
                        BeckerLMS_Enrollment__c enrollment = accVsBeckMap.get(accId)[i];
                        enrollmentsToUpdate.add(new BeckerLMS_Enrollment__c(Id = enrollment.Id, BeckerLMS_Enrollment__c = masterenrId,Purchase_Date__c = enrollment.Purchase_Date__c));
                    }
                    
            }
            if(!enrollmentsToUpdate.isEmpty()){
              update enrollmentsToUpdate;
            }

            List<LMSUtility.EnrollmentMergeRequest> lmsenrollmentmergeList = new List<LMSUtility.EnrollmentMergeRequest>();
            LMSUtility.EnrollmentMergeRequestList lmsenrollmentmergecontactList = new LMSUtility.EnrollmentMergeRequestList(); 
            list<String> JsonStringList = new list<String>();
              for(BeckerLMS_Enrollment__c beckLms : enrollmentsToUpdate){
                LMSUtility.EnrollmentMergeRequest lmsmergeenrollmentfailed = new LMSUtility.EnrollmentMergeRequest();
                Date failedtoConvert =  mapBeckIdvsBeck.get(beckLms.Id).Purchase_Date__c ;    	
                String faileddate = datetime.newInstance(failedtoConvert.year(), failedtoConvert.month(), failedtoConvert.day()).format('YYYY-MM-dd');
                lmsmergeenrollmentfailed.contactId =  mapBeckIdvsBeck.get(beckLms.Id).Account__r.Old_Contact_Id__c.capitalize();
                lmsmergeenrollmentfailed.username =  mapBeckIdvsBeck.get(beckLms.Id).Account__r.Old_Contact_Username__c;
                lmsmergeenrollmentfailed.subscriptionId = beckLms.id;
                lmsmergeenrollmentfailed.purchaseDate = faileddate;
                lmsmergeenrollmentfailed.master = false;
                lmsenrollmentmergeList.add(lmsmergeenrollmentfailed);
              }
              for(Account acct : accountList){
                BeckerLMS_Enrollment__c masterbeckLms =  masterMap.get(acct.Id);
                LMSUtility.EnrollmentMergeRequest lmsmergeenrollmentwon = new LMSUtility.EnrollmentMergeRequest();
                Date wontoConvert =  masterbeckLms.Purchase_Date__c;
                String wondate = datetime.newInstance(wontoConvert.year(), wontoConvert.month(), wontoConvert.day()).format('YYYY-MM-dd');
                lmsmergeenrollmentwon.contactId = String.valueOf(masterbeckLms.Account__c).capitalize();
                lmsmergeenrollmentwon.username = masterbeckLms.Username__c;
                lmsmergeenrollmentwon.subscriptionId = masterbeckLms.id;
                lmsmergeenrollmentwon.purchaseDate = wondate;
                lmsmergeenrollmentwon.master = true;
        
                string json_string;
            
                lmsenrollmentmergeList.add(lmsmergeenrollmentwon);
                lmsenrollmentmergecontactList.MergeSubscriptionEnrollmentProgress = lmsenrollmentmergeList;
                json_string = JSON.serialize(lmsenrollmentmergecontactList);
                JsonStringList.add(json_string);
              }
              
                for(String calloutString : JsonStringList){
                  //CalloutUtility.SendRequest('EnrollmentMergeIntegration', true, calloutString);
                  List<Enrollment_Merge_Integration__e> mergeEnrollPEEvents = new List<Enrollment_Merge_Integration__e>();
                  mergeEnrollPEEvents.add(new Enrollment_Merge_Integration__e(MergeEnrollmentBody__c=calloutString));
                  
                  List<Database.SaveResult> results = EventBus.publish(mergeEnrollPEEvents);
            
                    // Inspect publishing result for each event
                    for (Database.SaveResult sr : results) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully published event.');
                        } else {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Error returned: ' +
                                            err.getStatusCode() +
                                            ' - ' +
                                            err.getMessage());
                            }
                        }       
                    }
                }
           }
            catch(Exception ex){
                             //csa fix added exception logger statement. 
            ACAMSUtil.reportException(null, null,'MergeEnrollment Method', null, ex.getMessage(), null, null);
            }
           
      
         
     }
 
}