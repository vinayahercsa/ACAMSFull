public class ACAMSBeckerLMSTriggerHandler extends CCAviTriggerHandler {

    private List<BeckerLMS_Enrollment__c> newList;
   private List<BeckerLMS_Enrollment__c> oldList;
   private Map<Id, BeckerLMS_Enrollment__c> newMap;
   private Map<Id, BeckerLMS_Enrollment__c> oldMap;
   
   public static Boolean raiseException = false;
   public class customException extends Exception {}
   private static Boolean alreadyProcessedCreateLMSEnrollment = false;
   private static Boolean alreadyProcessedUpsertAssetEnrollments = false;
    @TestVisible
    private static Boolean alreadyProcessedInsertAssetEnrollments = false;
    private static Boolean alreadyProcessedUpdateAssetEnrollments = false;
    public static User drupalIntegration = ACAMSUserDAO.getDrupalIntegrationUser(); //FSA-2464

   public static Boolean isLMSEnrollmentUpdated = false;
   public static Boolean isEnterpriseLMSEnrollmentExecutedInsert = false;
   public static Boolean isEnterpriseLMSEnrollmentExecutedUpdate = false;
   public static Boolean isAssetEnrollmentCreated = false;
   public static Boolean isAssetEnrollmentUpdated = false;
   public static Boolean isAttendeeEnrollmentCreated = false;
   public static Boolean isAttendeeEnrollmentUpdated = false;
   public static Boolean isCEUCreated = false;
   public static Boolean isdcCEUCreated = false;

     public ACAMSBeckerLMSTriggerHandler() {
       super();
       this.newList = (List<BeckerLMS_Enrollment__c>) Trigger.new;
       this.oldList = (List<BeckerLMS_Enrollment__c>) Trigger.old;
       this.newMap = (Map<Id, BeckerLMS_Enrollment__c>) Trigger.newMap;
       this.oldMap = (Map<Id, BeckerLMS_Enrollment__c>) Trigger.oldMap;
     }
   
  public override void beforeInsert(){//FSA-950
      for(BeckerLMS_Enrollment__c blms : newList){
            blms.Created_LMS__c = true;
        }    
   }//FSA-950
   public override void afterInsert() {
    //  CreateLMSEnrollment(this.newList);
   }
   public override void beforeUpdate(){ //FSA-2464
       for(BeckerLMS_Enrollment__c blms : newList){
            if((blms.Created_LMS__c == oldMap.get(blms.id).Created_LMS__c) &&
              (blms.Updated_LMS__c == oldMap.get(blms.id).Updated_LMS__c) &&
               blms.Created_LMS__c == false &&
               blms.Response_status__c == oldMap.get(blms.id).Response_status__c &&
               blms.Status_code__c == oldMap.get(blms.id).Status_code__c &&
               blms.Time_stamp__c  == oldMap.get(blms.id).Time_stamp__c &&
               (blms.End_Date__c != oldMap.get(blms.id).End_Date__c ||
               (blms.Status__c != oldMap.get(blms.id).Status__c && (new Set<String>{'Enrolled', 'Cancelled'}).contains(blms.Status__c)) ||
                blms.Purchase_Date__c != oldMap.get(blms.id).Purchase_Date__c ||
                blms.Start_Date__c != oldMap.get(blms.id).Start_Date__c)
               ){
                blms.Updated_LMS__c = true;
            }
        }     
   }//FSA-2464
   public override void afterUpdate() {
       List<BeckerLMS_Enrollment__c> lmsToCreate = new List<BeckerLMS_Enrollment__c>();
       List<BeckerLMS_Enrollment__c> lmsToUpdate = new List<BeckerLMS_Enrollment__c>();
       Map<ID, BeckerLMS_Enrollment__c> oldMapBlms = new Map<ID, BeckerLMS_Enrollment__c>();  
       
       for(BeckerLMS_Enrollment__c blms : newList ){
         if(!blms.Created_LMS__c && oldMap.get(blms.id).Created_LMS__c){
           lmsToCreate.add(blms);  
         } else if(!blms.Updated_LMS__c && oldMap.get(blms.id).Updated_LMS__c){
           lmsToUpdate.add(blms);
           oldMapBlms.put(blms.id, oldMap.get(blms.id));
         }
       }
       if(lmsToCreate.size()>0){
         CreateLMSEnrollment(lmsToCreate);
       }
       if(lmsToUpdate.size()>0){
         UpdateLMSEnrollment(lmsToUpdate, oldMapBlms);  
       }
      
   }

   public static void CreateLMSEnrollment(List<BeckerLMS_Enrollment__c> newEnrollments) {
       if (!alreadyProcessedCreateLMSEnrollment) {
           alreadyProcessedCreateLMSEnrollment = true;
           try {
               if (raiseException) throw new customException('Testing code');
               List<LMSUtility.LMSCreateEnrollmentRequest> lmsEnrollmentList = new List<LMSUtility.LMSCreateEnrollmentRequest>();
               String username = Global_Variable__c.getValues('LMS.Username').Value__c;
               User lmsUser = [SELECT Id FROM User WHERE Username = :username];
               if (newEnrollments != NULL && newEnrollments.size() > 0) {
                   for (BeckerLMS_Enrollment__c e : newEnrollments) {
                       if (e.CreatedById != lmsUser.Id) {
                           LMSUtility.LMSCreateEnrollmentRequest lmse = new LMSUtility.LMSCreateEnrollmentRequest();
                           lmse.id = e.Id;
                           lmse.enrolleeId = e.Account__c;
                           lmse.lmsCourseId = e.LMS_Course_ID__c;
                           lmse.name = e.Name;
                           lmse.startDate = (e.Start_Date__c == NULL ? NULL : (datetime.newInstance(e.Start_Date__c.year(), e.Start_Date__c.month(), e.Start_Date__c.day())).format('YYYY-MM-dd'));
                           lmse.endDate = (e.End_Date__c == NULL ? NULL : string.valueof(e.End_Date__c));
                           lmse.purchaseDate = (e.Purchase_Date__c == NULL ? NULL : string.valueof(e.Purchase_Date__c));
                           lmsEnrollmentList.add(lmse);
                       }
                   }
               }
                if (lmsEnrollmentList.size() > 0)
                   CalloutUtility.SendRequest('CreateEnrollmentIntegration', true, LMSUtility.BuildJson(lmsEnrollmentList));
           } catch (Exception ex) {
               //csa fix added exception logger statement. 
               ACAMSUtil.reportException(null, null,'CreateLMSEnrollment Method', null, ex.getMessage(), null, null);
           }
        }
   }

   public static void UpdateLMSEnrollment(List<BeckerLMS_Enrollment__c> newEnrollments, Map<Id, BeckerLMS_Enrollment__c> oldMapEnrollments) {
           try{
           if (raiseException) throw new customException('Testing code');

           List<LMSUtility.LMSUpdateEnrollmentRequest> lmsEnrollmentList = new List<LMSUtility.LMSUpdateEnrollmentRequest>();
           String username = Global_Variable__c.getValues('LMS.Username').Value__c;
           User lmsUser = [SELECT Id FROM User WHERE Username = :username];
          // String batchusername  = Global_Variable__c.getValues('LMS.Batch').Value__c;
          //  User batchUser = [SELECT Id FROM User WHERE Username = :username];
            if (newEnrollments != NULL && newEnrollments.size() > 0 && oldMapEnrollments != NULL && oldMapEnrollments.size() > 0){
               for(BeckerLMS_Enrollment__c e : newEnrollments){
                   BeckerLMS_Enrollment__c oldE = oldMapEnrollments.get(e.Id);
                   if (oldE != NULL && ( e.LastModifiedById != lmsUser.Id && e.LastModifiedById != drupalIntegration.Id && e.CreatedById != system.label.ACAMS_API_User && e.LastModifiedById != system.label.ACAMS_API_User)  //FSA-2464  
         
                       ){ 
                          
                       isLMSEnrollmentUpdated = true;
                       LMSUtility.LMSUpdateEnrollmentRequest lmse = new LMSUtility.LMSUpdateEnrollmentRequest();
                       lmse.id = e.Id;
                       lmse.endDate = (e.End_Date__c == NULL ? NULL : string.valueof(e.End_Date__c));
                       lmse.status = e.Status__c;
                       lmse.purchaseDate = (e.Purchase_Date__c == NULL ? NULL : string.valueof(e.Purchase_Date__c)); //FSA-2464
                       lmse.startDate    = (e.Start_Date__c == NULL ? NULL : string.valueof(e.Start_Date__c)); //FSA-2464
                       lmsEnrollmentList.add(lmse);
                   }
               }
           }
            if (lmsEnrollmentList.size() > 0)
               CalloutUtility.SendRequest('UpdateEnrollmentIntegration', true, LMSUtility.BuildJson(lmsEnrollmentList));
       }
       catch(Exception ex){
                          //csa fix added exception logger statement.  
           ACAMSUtil.reportException(null, null,'UpdateLMSEnrollment Method', null, ex.getMessage(), null, null);
       }
    }

   public static void UpsertAssetEnrollments(Set<Id> newAssetIds, Map<Id, Asset> oldAssetsMap,Boolean isInsert, Boolean isUpdate) {
    if (!alreadyProcessedInsertAssetEnrollments && isInsert) {
           if(isInsert && !isUpdate){
               alreadyProcessedInsertAssetEnrollments = true;
                  }
          
          // alreadyProcessedUpsertAssetEnrollments = true;
            try {
               if (raiseException) throw new customException('Testing code');
               List<BeckerLMS_Enrollment__c> lmsEnrollmentsToInsert = new List<BeckerLMS_Enrollment__c>();
               List<BeckerLMS_Enrollment__c> lmsEnrollmentsToUpdate = new List<BeckerLMS_Enrollment__c>();
               Map<Id, BeckerLMS_Enrollment__c> assetIdLMSEnrollmentMap = new Map<Id, BeckerLMS_Enrollment__c>();
                if (newAssetIds != NULL && newAssetIds.size() > 0) {
                   for (BeckerLMS_Enrollment__c e : [SELECT Id, Asset__c, End_Date__c, Status__c FROM BeckerLMS_Enrollment__c WHERE Asset__c IN :newAssetIds])
                       assetIdLMSEnrollmentMap.put(e.Asset__c, e);
                    for (Asset a : [
                           SELECT Id, Name, Status__c, Assignee__c,Assignee__r.name,Assignee__r.accountid, account.name, Accountid, CC_Product__r.ProductCategory__c,Effective_Date__c,CC_Product__r.Level_1__c, Paid_Cert__c, PurchaseDate, InstallDate,CurrentExpirationDate__c , LMS_Access_Exp_Date__c, CancelDate__c, CC_Product__r.LMS_Course__c, CC_Product__r.ccrz__SKU__c, CreatedDate
                           FROM Asset
                           WHERE Id IN :newAssetIds
                           AND Assignee__c != NULL AND (Payment_Status__c =: 'Completed' OR Payment_Status__c =: 'Authorized') AND RecordType.Name != 'Registrant']) {
                            Asset oldAsset = ((oldAssetsMap != NULL && oldAssetsMap.containsKey(a.Id)) ? oldAssetsMap.get(a.Id) : NULL);
                       if (a.CC_Product__r.LMS_Course__c != NULL && a.CC_Product__r.ccrz__SKU__c != NULL) {
                           if (!assetIdLMSEnrollmentMap.containsKey(a.Id)  && a.LMS_Access_Exp_Date__c != null &&  (a.CC_Product__r.Level_1__c != 'Enterprise Bundle' )) {
                               isAssetEnrollmentCreated = true;
                               BeckerLMS_Enrollment__c lmsEnrollment = new BeckerLMS_Enrollment__c();
                               lmsEnrollment.Asset__c = a.Id;
                               lmsEnrollment.Contact__c = a.Assignee__c;
                               if(a.Assignee__r.name != null && a.account.name != null && a.Assignee__r.name != a.account.name  ){
                                   lmsEnrollment.Account__c = a.Assignee__r.accountid;
                                   
                               } else{
                                   lmsEnrollment.Account__c = a.Accountid;
                               }
                               Date startDate = (a.Effective_Date__c != NULL ? a.Effective_Date__c : System.today());
                               lmsEnrollment.Purchase_Date__c = startDate;
                               lmsEnrollment.Start_Date__c = startDate;
                               lmsEnrollment.End_Date__c = a.LMS_Access_Exp_Date__c;
                               lmsEnrollment.LMS_Course__c = a.CC_Product__r.LMS_Course__c;
                               lmsEnrollment.GenerateCEU__c = GenerateCEU(a.CC_Product__r.ccrz__SKU__c);
                               lmsEnrollmentsToInsert.add(lmsEnrollment);
                           } else if (oldAsset != NULL) {
                               isAssetEnrollmentUpdated = true;
                               BeckerLMS_Enrollment__c lmsEnrollment = ((assetIdLMSEnrollmentMap != NULL && assetIdLMSEnrollmentMap.containsKey(a.Id)) ? assetIdLMSEnrollmentMap.get(a.Id) : NULL);
                               if (lmsEnrollment != NULL) {
                                   Date endDate = (a.CC_Product__r.Level_1__c == 'Certification' ? a.LMS_Access_Exp_Date__c : a.CurrentExpirationDate__c);
                                   lmsEnrollment.End_Date__c = (a.Status__c == 'Inactive' ? (a.CancelDate__c != null ? a.CancelDate__c : endDate ) : endDate);
                                   /*The below statement is replaced by a new if else condition which will not update the enrollment record status to cancelled when it is completed and its asset turns inactive
                               * Date: 05/16/2018
                               * Developer: Ram
                                lmsEnrollment.Status__c = (a.Status__c == 'Inactive' ? 'Cancelled' : lmsEnrollment.Status__c);
                               */
                                   if (lmsEnrollment.Status__c == 'Completed') {
                                       lmsEnrollment.Status__c = lmsEnrollment.Status__c;
                                   } else {
                                       if (a.CancelDate__c != null)
                                           lmsEnrollment.Status__c = 'Cancelled' ; else
                                               lmsEnrollment.Status__c = lmsEnrollment.Status__c ;
                                   }
                                   lmsEnrollmentsToUpdate.add(lmsEnrollment);
                               }
                           }
                       }
                   }
               }
               if (lmsEnrollmentsToInsert != NULL && lmsEnrollmentsToInsert.size() > 0) {
                   DMLUtility.InsertSObjects(lmsEnrollmentsToInsert);
               }
               if (lmsEnrollmentsToUpdate != NULL && lmsEnrollmentsToUpdate.size() > 0) {
                   DMLUtility.UpdateSObjects(lmsEnrollmentsToUpdate);
               }
           } catch (Exception ex) {
                               //csa fix added exception logger statement. 
				ACAMSUtil.reportException(null, null,'UpsertAssetEnrollments Method', null, ex.getMessage(), null, null);
           }
               }
             if (!alreadyProcessedUpdateAssetEnrollments && isUpdate) {
         
       /*    if(!isInsert && isUpdate){
               alreadyProcessedUpdateAssetEnrollments = true;
               system.debug('debug--alreadyProcessedUpdateAssetEnrollments'+alreadyProcessedUpdateAssetEnrollments);
           }*/
          // alreadyProcessedUpsertAssetEnrollments = true;
            try {
               if (raiseException) throw new customException('Testing code');
               List<BeckerLMS_Enrollment__c> lmsEnrollmentsToInsert = new List<BeckerLMS_Enrollment__c>();
               List<BeckerLMS_Enrollment__c> lmsEnrollmentsToUpdate = new List<BeckerLMS_Enrollment__c>();
               Map<Id, BeckerLMS_Enrollment__c> assetIdLMSEnrollmentMap = new Map<Id, BeckerLMS_Enrollment__c>();
               if (newAssetIds != NULL && newAssetIds.size() > 0) {
                   for (BeckerLMS_Enrollment__c e : [SELECT Id, Asset__c, End_Date__c, Status__c FROM BeckerLMS_Enrollment__c WHERE Asset__c IN :newAssetIds])
                       assetIdLMSEnrollmentMap.put(e.Asset__c, e);
                   for (Asset a : [
                           SELECT Id, Name, Status__c, Assignee__c, Assignee__r.name,Assignee__r.accountid, account.name, Accountid, CC_Product__r.ProductCategory__c,Effective_Date__c,CC_Product__r.Level_1__c, Paid_Cert__c, PurchaseDate, InstallDate,CurrentExpirationDate__c , LMS_Access_Exp_Date__c, CancelDate__c, CC_Product__r.LMS_Course__c, CC_Product__r.ccrz__SKU__c, CreatedDate
                           FROM Asset
                           WHERE Id IN :newAssetIds
                           AND Assignee__c != NULL AND (Payment_Status__c =: 'Completed' OR Payment_Status__c =: 'Authorized') AND RecordType.Name != 'Registrant'
                   ]) {
                       Asset oldAsset = ((oldAssetsMap != NULL && oldAssetsMap.containsKey(a.Id)) ? oldAssetsMap.get(a.Id) : NULL);
                       if (a.CC_Product__r.LMS_Course__c != NULL && a.CC_Product__r.ccrz__SKU__c != NULL) {
                          // if (!assetIdLMSEnrollmentMap.containsKey(a.Id) && a.LMS_Access_Exp_Date__c != null  &&  (a.CC_Product__r.Level_1__c != 'Enterprise Bundle')){
                                if (!assetIdLMSEnrollmentMap.containsKey(a.Id) && a.LMS_Access_Exp_Date__c != null ){ // FSA-6324 Enterprise Bundle releated changes removed
                               isAssetEnrollmentCreated = true;
                               BeckerLMS_Enrollment__c lmsEnrollment = new BeckerLMS_Enrollment__c();
                               lmsEnrollment.Asset__c = a.Id;
                               lmsEnrollment.Contact__c = a.Assignee__c;
                                if(a.Assignee__r.name != null && a.account.name != null && a.Assignee__r.name != a.account.name  ){
                                   lmsEnrollment.Account__c = a.Assignee__r.accountid;
                                   
                               } else{
                                   lmsEnrollment.Account__c = a.Accountid;
                               }
                               Date startDate = (a.Effective_Date__c != NULL ? a.Effective_Date__c : System.today());
                               lmsEnrollment.Purchase_Date__c = startDate;
                               lmsEnrollment.Start_Date__c = startDate;
                               lmsEnrollment.End_Date__c = a.LMS_Access_Exp_Date__c;
                              lmsEnrollment.LMS_Course__c = a.CC_Product__r.LMS_Course__c;
                              lmsEnrollment.GenerateCEU__c = GenerateCEU(a.CC_Product__r.ccrz__SKU__c);
                               alreadyProcessedUpdateAssetEnrollments = true;
                               lmsEnrollmentsToInsert.add(lmsEnrollment);
                           } else if (oldAsset != NULL) {
                               isAssetEnrollmentUpdated = true;
                               BeckerLMS_Enrollment__c lmsEnrollment = ((assetIdLMSEnrollmentMap != NULL && assetIdLMSEnrollmentMap.containsKey(a.Id)) ? assetIdLMSEnrollmentMap.get(a.Id) : NULL);
                               if (lmsEnrollment != NULL) {
                                   Date endDate = (a.CC_Product__r.Level_1__c == 'Certification' ? a.LMS_Access_Exp_Date__c : a.CurrentExpirationDate__c);
                                   lmsEnrollment.End_Date__c = (a.Status__c == 'Inactive' ? (a.CancelDate__c != null ? a.CancelDate__c : endDate ) : endDate);
                                   /*The below statement is replaced by a new if else condition which will not update the enrollment record status to cancelled when it is completed and its asset turns inactive
                               * Date: 05/16/2018
                               * Developer: Ram
                                lmsEnrollment.Status__c = (a.Status__c == 'Inactive' ? 'Cancelled' : lmsEnrollment.Status__c);
                               */
                                   if (lmsEnrollment.Status__c == 'Completed') {
                                       lmsEnrollment.Status__c = lmsEnrollment.Status__c;
                                   } else {
                                       if (a.CancelDate__c != null)
                                           lmsEnrollment.Status__c = 'Cancelled' ; else
                                               lmsEnrollment.Status__c = lmsEnrollment.Status__c ;
                                   }
                                   lmsEnrollmentsToUpdate.add(lmsEnrollment);
                               }
                           }
                       }
                   }
               }
                             if (lmsEnrollmentsToInsert != NULL && lmsEnrollmentsToInsert.size() > 0) {
                   DMLUtility.InsertSObjects(lmsEnrollmentsToInsert);
               }
               if (lmsEnrollmentsToUpdate != NULL && lmsEnrollmentsToUpdate.size() > 0) {
                   DMLUtility.UpdateSObjects(lmsEnrollmentsToUpdate);
               }
           } catch (Exception ex) {
                           //csa fix added exception logger statement. 
               ACAMSUtil.reportException(null, null,'UpsertAssetEnrollments Method', null, ex.getMessage(), null, null);
           }
       }
   }

   public static void UpsertAttendeeEnrollments(Set<Id> newAttendeeIds, Map<Id, Asset> oldAttendeesMap) {
       try{
           if (raiseException) throw new customException('Testing code');
     String ProductCodeType;
           List<BeckerLMS_Enrollment__c> lmsEnrollmentsToInsert = new List<BeckerLMS_Enrollment__c>();
           List<BeckerLMS_Enrollment__c> lmsEnrollmentsToUpdate = new List<BeckerLMS_Enrollment__c>();
           Map<Id, BeckerLMS_Enrollment__c> attendeeIdLMSEnrollmentMap = new Map<Id, BeckerLMS_Enrollment__c>();
           List<Asset> attendees = new List<Asset>();
           Set<String> productCodes = new Set<String>();
           Map<String, Id> courseIdsByProductCodeMap = new Map<String, Id>();
	  if (newAttendeeIds != NULL && newAttendeeIds.size() > 0){
               for(BeckerLMS_Enrollment__c e : [SELECT Id, Asset__c, End_Date__c, Status__c FROM BeckerLMS_Enrollment__c WHERE Asset__c IN :newAttendeeIds])
                   attendeeIdLMSEnrollmentMap.put(e.Asset__c, e);

               for(Asset a : [ SELECT Id, Name, Status__c,Payment_Status__c, Assignee__r.name,Assignee__r.accountid, account.name, RecordType.Name, Accountid,Assignee__c,Effective_Date__c, CC_Product__r.ProductCategory__c, Paid_Cert__c, PurchaseDate, InstallDate,CurrentExpirationDate__c , LMS_Access_Exp_Date__c, CancelDate__c, CC_Product__r.LMS_Course__c, CC_Product__r.ccrz__SKU__c, CreatedDate
                           FROM Asset
                           WHERE Id IN :newAttendeeIds
                           AND Assignee__c != NULL AND (Payment_Status__c =: 'Completed' OR Payment_Status__c =: 'Authorized') AND RecordType.Name =:'Registrant']){
                   if (String.isNotBlank(a.CC_Product__r.ccrz__SKU__c)){
                       productCodes.add(a.CC_Product__r.ccrz__SKU__c);
                       attendees.add(a);
                   }
               }
   		for(ccrz__E_Product__c p : [SELECT Id, ccrz__SKU__c, LMS_Course__c  FROM ccrz__E_Product__c WHERE ccrz__SKU__c IN :productCodes]){
                   courseIdsByProductCodeMap.put(p.ccrz__SKU__c, p.LMS_Course__c);
               }

                     for(Asset a : attendees){
                  	Asset oldAttendee = ((oldAttendeesMap != NULL && oldAttendeesMap.containsKey(a.Id)) ? oldAttendeesMap.get(a.Id) : NULL);
                   if (String.isNotBlank(a.CC_Product__r.ccrz__SKU__c) && courseIdsByProductCodeMap.containsKey(a.CC_Product__r.ccrz__SKU__c)){
                         if(!attendeeIdLMSEnrollmentMap.containsKey(a.Id) && a.CC_Product__r.LMS_Course__c != NULL  && ((a.Payment_Status__c == 'Completed') || (a.Payment_Status__c == 'Authorized')) && ( a.CurrentExpirationDate__c != NULL || a.LMS_Access_Exp_Date__c != NULL)){
                           isAttendeeEnrollmentCreated = true;
                           BeckerLMS_Enrollment__c lmsEnrollment = new BeckerLMS_Enrollment__c();
                           lmsEnrollment.Asset__c = a.Id;
                           lmsEnrollment.Contact__c = a.Assignee__c;
                            if(a.Assignee__r.name != null && a.account.name != null && a.Assignee__r.name != a.account.name  ){
                                   lmsEnrollment.Account__c = a.Assignee__r.accountid;
                                   
                               } else{
                                   lmsEnrollment.Account__c = a.Accountid;
                               }
                           lmsEnrollment.LMS_Course__c = courseIdsByProductCodeMap.get(a.CC_Product__r.ccrz__SKU__c);
                           Date startDate = (a.Effective_Date__c != NULL ? a.Effective_Date__c : System.today());
                           lmsEnrollment.Purchase_Date__c = startDate;
                           Date eventStartDate = startDate;
                           Date todayDate = System.Today();
                           lmsEnrollment.Start_Date__c = (eventStartDate >= todayDate ? eventStartDate : todayDate);
                           if(a.LMS_Access_Exp_Date__c != null && a.CurrentExpirationDate__c != null){
                               lmsEnrollment.End_Date__c = a.CurrentExpirationDate__c;
                           }
                           else if(a.LMS_Access_Exp_Date__c != null && a.CurrentExpirationDate__c == null){
                               lmsEnrollment.End_Date__c = a.LMS_Access_Exp_Date__c;
                           }
                           else{
                                lmsEnrollment.End_Date__c = a.CurrentExpirationDate__c;
                           }

                           lmsEnrollmentsToInsert.add(lmsEnrollment);
                       } else if (oldAttendee != NULL && (oldAttendee.CurrentExpirationDate__c != a.CurrentExpirationDate__c || a.Paid_Cert__c == false || a.CancelDate__c != NULL )) {
                           isAttendeeEnrollmentUpdated = true;
                           BeckerLMS_Enrollment__c lmsEnrollment = ((attendeeIdLMSEnrollmentMap != NULL && attendeeIdLMSEnrollmentMap.containsKey(a.Id)) ? attendeeIdLMSEnrollmentMap.get(a.Id) : NULL);
                           if (lmsEnrollment != NULL){
                               lmsEnrollment.End_Date__c = (a.CancelDate__c != NULL ? (a.CancelDate__c == NULL ? System.today() : a.CancelDate__c) : a.CurrentExpirationDate__c);
                               lmsEnrollment.Status__c = (a.CancelDate__c != NULL ? 'Cancelled' : lmsEnrollment.Status__c);
                               lmsEnrollmentsToUpdate.add(lmsEnrollment);
                           }
                       }
                   }
               }
           }
		 if (lmsEnrollmentsToInsert != NULL && lmsEnrollmentsToInsert.size() > 0){
               DMLUtility.InsertSObjects(lmsEnrollmentsToInsert);
           }
           if (lmsEnrollmentsToUpdate != NULL && lmsEnrollmentsToUpdate.size() > 0){
               DMLUtility.UpdateSObjects(lmsEnrollmentsToUpdate);
           }
       }
       catch(Exception ex){
                           //csa fix added exception logger statement. 
			ACAMSUtil.reportException(null, null,'UpsertAttendeeEnrollments Method', null, ex.getMessage(), null, null);
       }
   }


   public static Boolean GenerateCEU(String productCode){
       return !(productCode.startsWith('ENTPRIV') || productCode.startsWith('GLODWT'));
   }
    //@future  ------------- CSA Fix (commented @future annotation)
    public static void asyncUpsertEnterpriseMembershipEnrollments(Set<Id> newAssetIdsmem, Set<Id> newAssetIds){
        ACAMSBeckerLMSTriggerHandler.UpsertEnterpriseMembershipEnrollments(newAssetIdsmem, newAssetIds );
    }
    
   
    public static void UpsertEnterpriseMembershipEnrollments(Set<Id> newAssetIdsmem, Set<Id> newAssetIds) {
            set<id> AccntId = new set<id>();
            Date tdy = system.today();
            List<BeckerLMS_Enrollment__c> lmsEnrollmentsToInsert = new List<BeckerLMS_Enrollment__c>();
            List<BeckerLMS_Enrollment__c> lmsEnrollmentsToUpdate = new List<BeckerLMS_Enrollment__c>();
            // FSA-468
            List<BeckerLMS_Enrollment__c> existingBeckLMS = new List<BeckerLMS_Enrollment__c>();
            Set<Id> personalAcctIds = new Set<Id>();  

            Map<Id, BeckerLMS_Enrollment__c> assetIdLMSEnrollmentMap = new Map<Id, BeckerLMS_Enrollment__c>();
            Map<Id, Asset> accountToAssetEnterpiseMap = new Map<Id, Asset>();
            Map<Id, BeckerLMS_Enrollment__c> accountToEnrollmentEnterpiseMap = new Map<Id, BeckerLMS_Enrollment__c>();
            //csa fix: removed the below for loop . added fields in this query and handled the code.
            for(Asset astEnrollments :  [
                            SELECT Id, Name, Status__c, Assignee__c, Assignee__r.name,Assignee__r.accountid, account.name, Accountid, CC_Product__r.ProductCategory__c,Effective_Date__c,CC_Product__r.Level_1__c, Paid_Cert__c, PurchaseDate, InstallDate,CurrentExpirationDate__c , LMS_Access_Exp_Date__c, CancelDate__c, CC_Product__r.LMS_Course__c, CC_Product__r.ccrz__SKU__c,Payment_Status__c, CreatedDate
                            FROM Asset
                            WHERE Id IN :newAssetIdsmem
                            AND Assignee__c != NULL
                    ]){
                    if(astEnrollments.CC_Product__r.Level_1__c == 'Enterprise Bundle'){
                    accountToAssetEnterpiseMap.put(astEnrollments.AccountId, astEnrollments);
                    // FSA-468
                    personalAcctIds.add(astEnrollments.Assignee__r.accountid);
                
                }
                    //below code handled
                    if((astEnrollments.Payment_Status__c == 'Authorized' || astEnrollments.Payment_Status__c == 'Completed') && (!assetIdLMSEnrollmentMap.containsKey(astEnrollments.Id))){
                    if(accountToEnrollmentEnterpiseMap.containskey(astEnrollments.AccountId)){
                    //update existing enrollment
                    BeckerLMS_Enrollment__c lmsEnrollment = accountToEnrollmentEnterpiseMap.get(astEnrollments.AccountId);
                    lmsEnrollment.End_Date__c= astEnrollments.CurrentExpirationDate__c;
                    lmsEnrollment.Asset__c = astEnrollments.id;
                    lmsEnrollmentsToUpdate.add(lmsEnrollment);
                    
                }
                    
                else if(astEnrollments.CC_Product__r.Level_1__c == 'Enterprise Bundle'){
                    // FSA-468
                    if(existingBeckLMS != null && existingBeckLMS.size() > 0){
                        for(BeckerLMS_Enrollment__c lms : existingBeckLMS){
                            if(String.valueOf(lms.LMS_Course__c).equals(String.valueOf(astEnrollments.CC_Product__r.LMS_Course__c))){
                                lms.End_Date__c = astEnrollments.CurrentExpirationDate__c;
                                lms.Asset__c = astEnrollments.Id;
                                lmsEnrollmentsToUpdate.add(lms);
                                break;
                            }
                        }
                    }
                    
                    else{
                        BeckerLMS_Enrollment__c lmsEnrollment = new BeckerLMS_Enrollment__c();
                        lmsEnrollment.Asset__c = astEnrollments.Id;
                        lmsEnrollment.Contact__c = astEnrollments.Assignee__c;
                        //CSA-fix wherein OwnerId is explicitly set to drupaIntegration Id due to calling from Platform event
                        lmsEnrollment.OwnerId = drupalIntegration.Id;
                        if(astEnrollments.Assignee__r.name != null && astEnrollments.account.name != null && astEnrollments.Assignee__r.name != astEnrollments.account.name  ){
                            lmsEnrollment.Account__c = astEnrollments.Assignee__r.accountid;                                            
                        } 
                        else{
                            lmsEnrollment.Account__c = astEnrollments.Accountid;
                        }

                        Date startDate = (astEnrollments.Effective_Date__c != NULL ? astEnrollments.Effective_Date__c : System.today());
                        lmsEnrollment.Purchase_Date__c = startDate;
                        lmsEnrollment.Start_Date__c = startDate;
                        lmsEnrollment.End_Date__c = astEnrollments.CurrentExpirationDate__c;
                        lmsEnrollment.LMS_Course__c = astEnrollments.CC_Product__r.LMS_Course__c;
                        lmsEnrollment.GenerateCEU__c = GenerateCEU(astEnrollments.CC_Product__r.ccrz__SKU__c);
                        lmsEnrollmentsToInsert.add(lmsEnrollment);
                    }
                }
            }
            
            }
        // for(BeckerLMS_Enrollment__c blms : [select id, Account__c, LMS_Course__c from BeckerLMS_Enrollment__c where Account__c IN: accountToAssetEnterpiseMap.keyset() AND LMS_Course__c =:Label.EntLibId ] ){
            for(BeckerLMS_Enrollment__c blms : [select id, Account__c, LMS_Course__c from BeckerLMS_Enrollment__c where Account__c IN: accountToAssetEnterpiseMap.keyset() AND LMS_Course__c =:Label.EntLibId ] ){
                accountToEnrollmentEnterpiseMap.put(blms.Account__c,blms);
                }
            // FSA-468
            existingBeckLMS = [select id, Account__c, LMS_Course__c,LMS_Course__r.Name,Status__c from BeckerLMS_Enrollment__c where Account__c IN: personalAcctIds AND LMS_Course__r.Name LIKE 'Enterprise Webinar Subscription' AND Status__c != 'Cancelled' ORDER BY CreatedDate DESC];
            for (BeckerLMS_Enrollment__c e : [SELECT Id, Asset__c, End_Date__c, Status__c FROM BeckerLMS_Enrollment__c WHERE Asset__c IN :newAssetIds]){
            
                assetIdLMSEnrollmentMap.put(e.Asset__c, e);
            }
                
            /*for(Asset astEnrollments :  [
                            SELECT Id, Name, Status__c, Assignee__c, Assignee__r.name,Assignee__r.accountid, account.name, Accountid, CC_Product__r.ProductCategory__c, Effective_Date__c, CC_Product__r.Level_1__c, Paid_Cert__c, PurchaseDate, InstallDate,CurrentExpirationDate__c , LMS_Access_Exp_Date__c, CancelDate__c, CC_Product__r.LMS_Course__c, CC_Product__r.ccrz__SKU__c,Payment_Status__c, CreatedDate
                            FROM Asset
                            WHERE Id IN :newAssetIdsmem
                            AND Assignee__c != NULL 
                    ] ){
                        
                // FSA-468
                //if(astEnrollments.Paid_Cert__c == true && (!assetIdLMSEnrollmentMap.containsKey(astEnrollments.Id))){
                if((astEnrollments.Payment_Status__c == 'Authorized' || astEnrollments.Payment_Status__c == 'Completed') && (!assetIdLMSEnrollmentMap.containsKey(astEnrollments.Id))){
                    
                    if(accountToEnrollmentEnterpiseMap.containskey(astEnrollments.AccountId)){
                    
                    //update existing enrollment
                    BeckerLMS_Enrollment__c lmsEnrollment = accountToEnrollmentEnterpiseMap.get(astEnrollments.AccountId);
                    lmsEnrollment.End_Date__c= astEnrollments.CurrentExpirationDate__c;
                    lmsEnrollment.Asset__c = astEnrollments.id;
                    lmsEnrollmentsToUpdate.add(lmsEnrollment);
                    
                }
                    
                else if(astEnrollments.CC_Product__r.Level_1__c == 'Enterprise Bundle'){
                    // FSA-468
                    if(existingBeckLMS != null && existingBeckLMS.size() > 0){
                        for(BeckerLMS_Enrollment__c lms : existingBeckLMS){
                            if(String.valueOf(lms.LMS_Course__c).equals(String.valueOf(astEnrollments.CC_Product__r.LMS_Course__c))){
                                lms.End_Date__c = astEnrollments.CurrentExpirationDate__c;
                                lms.Asset__c = astEnrollments.Id;
                                lmsEnrollmentsToUpdate.add(lms);
                                break;
                            }
                        }
                    }
                    
                    else{
                        BeckerLMS_Enrollment__c lmsEnrollment = new BeckerLMS_Enrollment__c();
                        lmsEnrollment.Asset__c = astEnrollments.Id;
                        lmsEnrollment.Contact__c = astEnrollments.Assignee__c;
                        //CSA-fix wherein OwnerId is explicitly set to drupaIntegration Id due to calling from Platform event
                        lmsEnrollment.OwnerId = drupalIntegration.Id;
                        if(astEnrollments.Assignee__r.name != null && astEnrollments.account.name != null && astEnrollments.Assignee__r.name != astEnrollments.account.name  ){
                            lmsEnrollment.Account__c = astEnrollments.Assignee__r.accountid;                                            
                        } 
                        else{
                            lmsEnrollment.Account__c = astEnrollments.Accountid;
                        }

                        Date startDate = (astEnrollments.Effective_Date__c != NULL ? astEnrollments.Effective_Date__c : System.today());
                        lmsEnrollment.Purchase_Date__c = startDate;
                        lmsEnrollment.Start_Date__c = startDate;
                        lmsEnrollment.End_Date__c = astEnrollments.CurrentExpirationDate__c;
                        lmsEnrollment.LMS_Course__c = astEnrollments.CC_Product__r.LMS_Course__c;
                        lmsEnrollment.GenerateCEU__c = GenerateCEU(astEnrollments.CC_Product__r.ccrz__SKU__c);
                        lmsEnrollmentsToInsert.add(lmsEnrollment);
                    }
                }
            }
            }*/
            //csa fix: Implemented Platform Event to handle insert/update sobjects
            if (lmsEnrollmentsToInsert != NULL && lmsEnrollmentsToInsert.size() > 0) {
                    isEnterpriseLMSEnrollmentExecutedInsert =true;
                    List<Asset_EM_Enrollment_Event__e> assetPlatformEvents = new List<Asset_EM_Enrollment_Event__e>();
                    for(BeckerLMS_Enrollment__c beckLMS : lmsEnrollmentsToInsert){
                        assetPlatformEvents.add(new Asset_EM_Enrollment_Event__e(Asset_ID__c=beckLMS.Id,isInsertLMS__c = true));
                        
                    }
                    List<Database.SaveResult> results = EventBus.publish(assetPlatformEvents);
            
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
                    //DMLUtility.InsertSObjects(lmsEnrollmentsToInsert);
                    
            }

            // FSA-468
            if(lmsEnrollmentsToUpdate != null && lmsEnrollmentsToUpdate.size() > 0){
            isEnterpriseLMSEnrollmentExecutedUpdate = true;
            List<Asset_EM_Enrollment_Event__e> assetPlatformEvents = new List<Asset_EM_Enrollment_Event__e>();
                    for(BeckerLMS_Enrollment__c beckLMS : lmsEnrollmentsToInsert){
                        assetPlatformEvents.add(new Asset_EM_Enrollment_Event__e(Asset_ID__c=beckLMS.Id,isUpdateLMS__c = true));
                    
                    }
                    List<Database.SaveResult> results = EventBus.publish(assetPlatformEvents);
            
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
            //DMLUtility.UpdateSObjects(lmsEnrollmentsToUpdate);
            }
        

    }

}
//endtest///