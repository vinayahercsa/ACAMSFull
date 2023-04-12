public class ACAMSAssetTriggerHandler extends CCAviTriggerHandler {
    
    private List<Asset> newList;
    private List<Asset> oldList;
    private Map<Id, Asset> newMap;
    private Map<Id, Asset> oldMap;
    private Boolean isInsert;
    private Boolean isUpdate;
    public static Boolean isLMSUserCreated = false;
    private static boolean isRecursiveChapterCheck = false;
    private static boolean isRecursiveBeforeUpdate = false;
    private static boolean isRecursiveAfterUpdate = false;
    public static Boolean isHLContactUpdated = false;
    public static Boolean isWhitepaperUpdated = false;
    public static Boolean isauthorizedStatusUpdated = false;
    public static Boolean isrecertExpDateUpdated = false;
    public static Boolean isexamAuthorized = false;
    
    //FSA-347
    public static List<String> validEnterpriseProductHL = new List<String>{'IN-AML-Regime','SG-AML-Regime'};
        public static List<String> validProductLevel2 = new List<String>{'CTMA','CKYCA','CAFCA'};
            public static String profileName;
    //FSA-347
    
    public static set<Id> assetIds=new set<Id>();
    
    
    public ACAMSAssetTriggerHandler() {
        super();
        this.newList = (List<Asset>) Trigger.new;
        this.oldList = (List<Asset>) Trigger.old;
        this.newMap = (Map<Id, Asset>) Trigger.newMap;
        this.oldMap = (Map<Id, Asset>) Trigger.oldMap;
        this.isInsert =  Trigger.isInsert;
        this.isUpdate =  Trigger.isUpdate;
        //FSA-347
        if(userinfo.getName()!='Automated Process'){
        profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        }
        //FSA-347
    }
    
    /**
        ** @description: added logic for 2. Certification Asset: Populate the LMS access expiration Date upon
        *the payment.
        * @Date: July 2, 2020 - Rui
        * @source: issue/Defect UAT LOG Row 301 "Layout" -
        * https://app.smartsheet.com/sheets/CQ2rPHChHxfRvwPQ4m38fwVVcx4V6xCMmgf2pHw1?view=grid
        */
    public override void beforeInsert() {
        updateLMSExpirationDate(this.newList, null);
        //FSA-347
      //  updateCurrentExpirationDate(this.newList);
       // updateCertificationExpirationDate(this.newList);
        //FSA-347
    }
    
    public override void beforeUpdate(){
        if(!isexamAuthorized){
            updateLMSExpirationDate(this.newList, this.oldMap);
            //   beforeUpdateAsset(this.newMap,this.newList);
            //FSA-347
            //updateCurrentExpirationDate(this.newList);
          //  updateCertificationExpirationDate(this.newList);
            updateCancelDate(this.newList, this.oldMap, this.newMap);
            //FSA-347
                      
        }
    }
    /**  ended  */
    public override void afterInsert() {
        //insertMLDCRecords(this.newList);
        if(!ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentCreated){
            if (!isLMSUserCreated ){
                UpsertLMSUser(this.newList);
            }
            if(!system.isBatch()){
                
                ACAMSBeckerLMSTriggerHandler.UpsertAssetEnrollments(this.newMap.KeySet(), NULL,this.isInsert,this.isUpdate);
            }
        }
        if(!system.isFuture() && !system.isBatch()){
            System.debug('Check the boolean value :'+ACAMSBeckerLMSTriggerHandler.isEnterpriseLMSEnrollmentExecutedInsert);
            if(!ACAMSBeckerLMSTriggerHandler.isEnterpriseLMSEnrollmentExecutedInsert){
                ACAMSBeckerLMSTriggerHandler.asyncUpsertEnterpriseMembershipEnrollments(this.newMap.KeySet(), this.newMap.KeySet());
            }
        }
        if(!system.isBatch()){
        if (!ACAMSBeckerLMSTriggerHandler.isAttendeeEnrollmentCreated ) {
            ACAMSBeckerLMSTriggerHandler.UpsertAttendeeEnrollments(this.newMap.KeySet(), NULL); 
        }
        }
        if (!isHLContactUpdated ) {
            updateHLGrouponContact(this.newList,null);
        }
        //  CreateExamAuthorization(this.newList);
        
        recertificationApplicationUpdate(this.newList,this.oldMap); //fsa-262
        recertExpDate(this.newList,this.oldMap);//fsa-262
    }
    public override void afterUpdate() {
        if(!isexamAuthorized){
            insertMLDCRecords(this.newList);
            //Trigger for PB chinnamanaidu Neerasa, FSA
            if(!system.isBatch()){
            UpsertLMSEnrollment(this.newList,this.oldMap);
            }
            if(!ACAMSOrderTriggerHandler.SkipOrderRefundAssetAfterUpdate){
                if(!System.isBatch()){
                    if(!System.isFuture()){
                      //  InsertUserToHubb(this.newList,this.oldMap);
                    }
                }
                if((!ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentUpdated || !ACAMSBeckerLMSTriggerHandler.isAssetEnrollmentCreated)){
                    if (!isLMSUserCreated){
                        UpsertLMSUser(this.newList);
                        
                    }
                    if(!system.isBatch()){
                      
                        ACAMSBeckerLMSTriggerHandler.UpsertAssetEnrollments(this.newMap.KeySet(), this.oldMap,this.isInsert ,this.isUpdate);
                    }
                }
                AcamsHelperMethod(this.newList,this.oldList);
                if(!system.isFuture() && !system.isBatch()){
                    if(!ACAMSBeckerLMSTriggerHandler.isEnterpriseLMSEnrollmentExecutedUpdate){
                        ACAMSBeckerLMSTriggerHandler.asyncUpsertEnterpriseMembershipEnrollments(this.newMap.KeySet(), this.newMap.KeySet());
                    }
                }
                if(!Test.isRunningTest()){
                    if(!system.isBatch()){
                        if (!ACAMSBeckerLMSTriggerHandler.isAttendeeEnrollmentUpdated || !ACAMSBeckerLMSTriggerHandler.isAttendeeEnrollmentCreated){
                            ACAMSBeckerLMSTriggerHandler.UpsertAttendeeEnrollments(this.newMap.KeySet(), this.oldMap);
                        }
                    }
                }
            }
            if (!isHLContactUpdated ) {
                updateHLGrouponContact(this.newList, this.oldList);
            }
            if(!system.isBatch()){
            deactivateHLGrouponContact(this.newList,this.oldMap);
            
            if(!ACAMSAssetTriggerHandler.isWhitepaperUpdated){
                whitePaperUpdate(this.newMap,this.oldMap);
            }
            }
            if(!test.isRunningTest()){
                if(!ACAMSAssetTriggerHandler.isauthorizedStatusUpdated){
                    authorizedStatus(this.newList,this.oldMap);
                }
                
                if(!ACAMSAssetTriggerHandler.isrecertExpDateUpdated){
                    recertExpDate(this.newList,this.oldMap);
                }
                AssetAccountUpdate(this.newList);
                // CreateExamAuthorization(this.newList);
                createExamAuthorization(this.newmap);
            }
        }
    }
    
    /**
    * @FSA-75
    */
  /*  public static void InsertUserToHubb(List<Asset> newAssets, Map<Id,Asset> oldMap){
        Set<Id> cIds = new Set<Id>();
        Set<Id> hubbAccountIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        List<Asset> assetLst = new List<Asset>();
        
        Set<Id> deleteHubbUserAsset = new Set<Id>();
        
        for(Asset asst : newAssets){
            if(asst.Hubb_Status__c != null && asst.Hubb_Status__c == 'Sent to Hubb' && asst.Hubb_Status__c != oldMap.get(asst.id).Hubb_Status__c){
                //  cIds.add(asst.Assignee__c);
                assetIds.add(asst.Id);
            }
            // FSA-142
            else if(asst.Hubb_Status__c != null && asst.Hubb_Status__c == 'Cancelled' && asst.Hubb_Status__c != oldMap.get(asst.id).Hubb_Status__c){
                deleteHubbUserAsset.add(asst.Id);
            }
            
        }
        system.debug(assetIds);
        if(assetIds.size()>0){
            List<Asset>assetRecord = new List<Asset>();
            assetRecord = [select id, name , assignee__r.Accountid from Asset where id in: assetIds];
            for(Asset aRec : assetRecord){
                assetLst.add(aRec);
                system.debug(assetLst);
            }
            
        }
        
        for(Asset ast : assetLst){
            hubbAccountIds.add(ast.assignee__r.Accountid);
        }
        
        system.debug(hubbAccountIds);
        if(hubbAccountIds.size() > 0){
            ACAMSHubbCallout.RESTInsertRecords(hubbAccountIds, newAssets.get(0).Id);
        }
        
        // FSA-142
        else if(deleteHubbUserAsset != null && deleteHubbUserAsset.size() > 0){
            ACAMSHubbCallout.RESTFutureDeleteRecords(deleteHubbUserAsset);
        }
        
    }*/
    //Moving Process Builder to Trigger Case # 41120501- Added by Chinnamanaidu Neerasa Update Expiration Date 
    public static void UpsertLMSEnrollment(List<Asset> newAssets,Map<Id,Asset> oldMap){
        
        Map<Id,Asset> mapAssets = new Map<Id,Asset>();
        Map<Id,Asset> mapStatusAssets = new Map<Id,Asset>();
        List<BeckerLMS_Enrollment__c> liststatusbeckers = new List<BeckerLMS_Enrollment__c>();
        List<BeckerLMS_Enrollment__c> listbeckers = new List<BeckerLMS_Enrollment__c>();
        
        if(newAssets.size() > 0){ 
            for(Asset newAssetLMS : newAssets){   
                if(((newAssetLMS.LMS_Access_Exp_Date__c != oldMap.get(newAssetLMS.id).LMS_Access_Exp_Date__c) ) && profileName != 'Data Migration' ){    
                    mapAssets.put(newAssetLMS.id,newAssetLMS);   
                    
                }
                if((newAssetLMS.CancelDate__c != oldMap.get(newAssetLMS.id).CancelDate__c)  && (newAssetLMS.CancelDate__c != NULL) && profileName != 'Data Migration' ){
                    mapStatusAssets.put(newAssetLMS.id,newAssetLMS);
                }
            }
            if(!mapAssets.isEmpty()){
                listbeckers = [select id,Status__c,End_Date__c,Asset__r.LMS_Access_Exp_Date__c from BeckerLMS_Enrollment__c where Status__c != 'Cancelled' and Asset__c IN : mapAssets.keySet()];
                if(listbeckers.size() > 0){
                    for(BeckerLMS_Enrollment__c bLMS : listbeckers){
                        bLMS.End_Date__c = mapAssets.get(bLMS.Asset__c).LMS_Access_Exp_Date__c;
                    }
                    try{
                        Update listbeckers;
                    }catch(Exception ex){
                        ACAMSUtil.reportException(null, null,'UpsertLMSEnrollment Method', null, ex.getMessage(), null, null);
                    }
                    
                }
            }
            if(mapStatusAssets.size() > 0){
                liststatusbeckers = [select id,Status__c from BeckerLMS_Enrollment__c where Status__c != 'Completed' and Asset__c IN : mapStatusAssets.keySet()];
                if(liststatusbeckers.size() > 0){
                    for(BeckerLMS_Enrollment__c bsLMS : liststatusbeckers){
                        bsLMS.Status__c = 'Cancelled';
                    }
                    try{
                        Update liststatusbeckers;
                    }catch(Exception ex){
                        ACAMSUtil.reportException(null, null,'UpsertLMSEnrollment Method', null, ex.getMessage(), null, null);
                    }
                }
            }
        }
    }
    
    //Regional Funding Registraction PB Chinna
    public static void AssetAccountUpdate(List<Asset> newAssets){
        
        list<Asset> assetsops = newAssets;
       // list<Id> accIdList = new list<id>();
        for(Asset asst: assetsops){
            if(asst.AccountId != null && asst.Enterprise_Product_HL__c == 'SG-AML-Regime' && asst.Paid_Cert__c == true ){
               // accIdList.add(asst.accountId);
                 //FSA-6834
                pushAssetMethodEvents(asst.accountId,'AssetAccountUpdate');
            }
        }
        //FSA-6834 Moved to ACAMSAssetMethodEventsTrigger
      /*  if(accIdList.size() > 0){
            list<account> acc = [SELECT id,Registration_Application_Submitted__c from Account WHERE Id =: accIdList];
            for(Account a: acc){
                a.Registration_Application_Submitted__c = true;
            }
            update acc;
        }*/
    }
    
    
    //CreateExam Authorization Process Builder Chinna
    /*public static void CreateExamAuthorization(List<Asset> newAssets){

if(isexamAuthorized == false){
isexamAuthorized = true;

Map<id,Asset> assetMap = new Map<id,Asset>();
List<Exam_Results__c> result = new List<Exam_Results__c>();

Map<id,Asset> assetMapnocode = new Map<id,Asset>();
List<Exam_Results__c> resultmap = new List<Exam_Results__c>();

Map<id,Asset> assetMapnopcode = new Map<id,Asset>();
List<Exam_Results__c> resultmapnp = new List<Exam_Results__c>();

Map<id,Asset> assetMapcode = new Map<id,Asset>();
List<Exam_Results__c> resultmapsing = new List<Exam_Results__c>();

Map<id,Asset> assetMapexcode = new Map<id,Asset>();
List<Exam_Results__c> resultmapex = new List<Exam_Results__c>();

System.debug('Asset records data'+newAssets);

for(Asset assetExam : newAssets){
if(assetExam.Certification_Approved_Application__c == True && (assetExam.Membership_Type__c == 'MEMBER' || assetExam.Membership_Type__c =='ENTERPRISE') && assetExam.Paid_Cert__c == true && assetExam.Product_level_1__c == 'Certification' 
&& assetExam.EAD_created__c == False && assetExam.Retake__c == False && (assetExam.Enterprise_Product_HL__c != 'IN-AML-Regime' || assetExam.Enterprise_Product_HL__c != 'SG-AML-Regime') && assetExam.Product_level_3__c == 'New' && assetExam.Status__c == 'Active' && profileName != 'Data Migration'
&& assetExam.Product_level_2__c == 'CAMS' && assetExam.Product_level_2__c != 'Advanced CAMS - FCI'  && assetExam.Product_level_2__c != 'Advanced CAMS - Audit' && assetExam.Exam_Code__c == 'CAMS6_PTBFEB' && assetExam.Recert__c == False){

assetMap.put(assetExam.id,assetExam);

}
if(assetExam.Certification_Approved_Application__c == True && (assetExam.Membership_Type__c == 'MEMBER' || assetExam.Membership_Type__c =='ENTERPRISE') && assetExam.Paid_Cert__c == true && assetExam.Product_level_1__c == 'Certification' 
&& assetExam.EAD_created__c == False && assetExam.Retake__c == False && (assetExam.Enterprise_Product_HL__c != 'IN-AML-Regime' || assetExam.Enterprise_Product_HL__c != 'SG-AML-Regime')  && assetExam.Product_level_3__c == 'New' && assetExam.Status__c == 'Active' && profileName != 'Data Migration'
&& assetExam.Product_level_2__c != 'Advanced CAMS - FCI' && (assetExam.Product_level_2__c == 'Advanced CAMS - Audit' || assetExam.Product_level_2__c == 'CGSS' || assetExam.Product_level_2__c == 'Advanced CAMS - Risk Management' || assetExam.Product_level_2__c == 'CKYCA' || assetExam.Product_level_2__c == 'CTMA' || assetExam.Product_level_2__c == 'CAFCA')
&& assetExam.Recert__c == False){
assetMapnocode.put(assetExam.id,assetExam);
}
if(assetExam.Certification_Approved_Application__c == True && (assetExam.Membership_Type__c == 'MEMBER' || assetExam.Membership_Type__c =='ENTERPRISE') && assetExam.Paid_Cert__c == true && assetExam.Product_level_1__c == 'Certification' 
&& assetExam.EAD_created__c == False && assetExam.Retake__c == False && (assetExam.Enterprise_Product_HL__c != 'IN-AML-Regime' || assetExam.Enterprise_Product_HL__c != 'SG-AML-Regime')  && assetExam.Product_level_3__c == 'New' && assetExam.Status__c == 'Active' && profileName != 'Data Migration'
&& assetExam.Product_level_2__c == 'CAMS' && assetExam.Product_level_2__c != 'Advanced CAMS - FCI' && assetExam.Product_level_2__c != 'Advanced CAMS - Audit' && assetExam.Recert__c == False && assetExam.Exam_Code__c != 'CAMS6_PTBFEB'){
assetMapnopcode.put(assetExam.id,assetExam);
}

if(assetExam.Name != NULL && (assetExam.Membership_Type__c == 'MEMBER' || assetExam.Membership_Type__c =='ENTERPRISE') && assetExam.Paid_Cert__c == true && assetExam.Product_level_1__c == 'Certification' 
&& assetExam.EAD_created__c == False && assetExam.Retake__c == False && (assetExam.Enterprise_Product_HL__c == 'IN-AML-Regime' || assetExam.Enterprise_Product_HL__c == 'SG-AML-Regime' || assetExam.Product_level_2__c == 'India Regime' 
|| assetExam.Product_level_2__c == 'Singapore Regime')  && assetExam.Product_level_3__c == 'New' && assetExam.Status__c == 'Active' && profileName != 'Data Migration'
&& assetExam.Recert__c == False && assetExam.SG_AML_REGIME_Exam_Application_Approved__c == True){
assetMapcode.put(assetExam.id,assetExam);
}

if(assetExam.Name != NULL && (assetExam.Certification_Approved_Application__c == True || assetExam.SG_AML_REGIME_Exam_Application_Approved__c == True) && (assetExam.Membership_Type__c == 'MEMBER' || assetExam.Membership_Type__c =='ENTERPRISE') && assetExam.Paid_Cert__c == true && 
assetExam.EAD_created__c == True && assetExam.Recert__c == False && assetExam.Retake__c == True && assetExam.Status__c == 'Active' && profileName != 'Data Migration' ){
assetMapexcode.put(assetExam.id,assetExam);
}
}  
if(!assetMap.isEmpty()){
for(String eachMapfromId : assetMap.keyset()){
if(assetMap.containsKey(eachMapfromId) ){
Date AppDate = assetMap.get(eachMapfromId).Application_Date__c;
Integer daystoExpire = Integer.valueOf(assetMap.get(eachMapfromId).Product_Exam_Date_to_Expire__c );
Date ApptDate = AppDate.addDays(daystoExpire);
Exam_Results__c exResult = new Exam_Results__c();
exResult.Exam_Type__c = 'CAMSFebraban';
exResult.Account__c = assetMap.get(eachMapfromId).accountid;
exResult.Asset__c = assetMap.get(eachMapfromId).id;
exResult.Contact__c = assetMap.get(eachMapfromId).Assignee__c;
exResult.Original_EAD__c = True;
exResult.PearsonVUE__c = True ;
exResult.clientCandidateID__c = assetMap.get(eachMapfromId).accountid;
exResult.eligibilityApptDateFirst__c = System.today();
exResult.eligibilityApptDateLast__c  = ApptDate;
exResult.examSeriesCode__c = assetMap.get(eachMapfromId).Exam_Code__c;
result.add(exResult);
}
}
}
try{
insert result;
}
catch(system.Dmlexception e) {
system.debug (e);                
}
List<Asset> asstupd = new List<Asset>();
if(!assetMap.isEmpty()){
for(Asset astm : [select id,EAD_created__c from asset where id in: assetMap.keyset()]){
asstupd.add(new asset(id = astm.id,EAD_created__c = True));
}
}
update asstupd;


if(!assetMapnocode.isEmpty()){
for(String eachmapofcams : assetMapnocode.keyset()){
if(assetMapnocode.containsKey(eachmapofcams)){
Date AppDates = assetMapnocode.get(eachmapofcams).Application_Date__c;
Integer daystoExpires = Integer.valueOf(assetMapnocode.get(eachmapofcams).Product_Exam_Date_to_Expire__c);
System.debug('rrrr'+daystoExpires);
String ExamTypeCode;
if(assetMapnocode.get(eachmapofcams).Product_level_2__c == 'CGSS'){ ExamTypeCode = 'CGSS'; }
if(assetMapnocode.get(eachmapofcams).Product_level_2__c == 'Advanced CAMS - Risk Management'){ ExamTypeCode = 'CAMSRM'; }
if(assetMapnocode.get(eachmapofcams).Product_level_2__c == 'Advanced CAMS - Audit'){ ExamTypeCode = 'CAMS-Audit'; }
if(assetMapnocode.get(eachmapofcams).Product_level_2__c == 'CKYCA'){ ExamTypeCode = 'CKYCA'; }
if(assetMapnocode.get(eachmapofcams).Product_level_2__c == 'CTMA'){ ExamTypeCode = 'CTMA'; }
if(assetMapnocode.get(eachmapofcams).Product_level_2__c == 'CAFCA'){ ExamTypeCode = 'CAFCA'; }
Date ApptDates = AppDates.addDays(daystoExpires);
Exam_Results__c exResult1 = new Exam_Results__c();
exResult1.Exam_Type__c = ExamTypeCode;
exResult1.Account__c = assetMapnocode.get(eachmapofcams).accountid;
exResult1.Asset__c = assetMapnocode.get(eachmapofcams).id;
exResult1.Contact__c = assetMapnocode.get(eachmapofcams).Assignee__c;
exResult1.Original_EAD__c = True;
exResult1.PearsonVUE__c = True ;
exResult1.clientCandidateID__c = assetMapnocode.get(eachmapofcams).AccountId;
exResult1.eligibilityApptDateFirst__c = System.today();
exResult1.eligibilityApptDateLast__c  = ApptDates ;
exResult1.examSeriesCode__c = assetMapnocode.get(eachmapofcams).Exam_Code__c;
resultmap.add(exResult1);
}
}
}
try{
insert resultmap;
}
catch(system.Dmlexception e) {
system.debug (e);                
}
List<Asset> asstupd1 = new List<Asset>();
if(!assetMapnocode.isEmpty()){
for(Asset astms : [select id,EAD_created__c from asset where id in: assetMapnocode.keyset()]){
asstupd1.add(new asset(id = astms.id,EAD_created__c = True));
}
}
update asstupd1;

System.debug('yter'+assetMapnopcode);
if(!assetMapnopcode.isEmpty()){
System.debug('testr'+assetMapnopcode);
for(String eachmapofca : assetMapnopcode.keyset()){
if(assetMapnopcode.containsKey(eachmapofca)){
Date AppDatesc = assetMapnopcode.get(eachmapofca).Application_Date__c;
Integer daystoExpiresc =  Integer.valueOf(assetMapnopcode.get(eachmapofca).Product_Exam_Date_to_Expire__c);
Date ApptDatesc = AppDatesc.addDays(daystoExpiresc);
System.debug('debug'+ApptDatesc);
Exam_Results__c exResultnop = new Exam_Results__c();
exResultnop.Exam_Type__c = 'CAMS';
exResultnop.Account__c = assetMapnopcode.get(eachmapofca).accountid;
exResultnop.Asset__c = assetMapnopcode.get(eachmapofca).id;
exResultnop.Contact__c = assetMapnopcode.get(eachmapofca).Assignee__c;
exResultnop.Original_EAD__c = True;
exResultnop.PearsonVUE__c = True ;
exResultnop.clientCandidateID__c = assetMapnopcode.get(eachmapofca).AccountId;
exResultnop.eligibilityApptDateFirst__c = System.today();
exResultnop.eligibilityApptDateLast__c  = ApptDatesc;
exResultnop.examSeriesCode__c = assetMapnopcode.get(eachmapofca).Exam_Code__c;
resultmapnp.add(exResultnop);
System.debug('test'+resultmapnp);
}
}
}
try{
insert resultmapnp;
}
catch(system.Dmlexception e) {
system.debug (e);                
}
List<Asset> asstupd2 = new List<Asset>();
if(!assetMapnopcode.isEmpty()){
for(Asset astmss : [select id,EAD_created__c from asset where id in: assetMapnopcode.keyset()]){
asstupd2.add(new asset(id = astmss.id,EAD_created__c = True));
}
}
update asstupd2;

if(!assetMapcode.isEmpty()){
for(String eachexammapcode : assetMapcode.keyset()){
if(assetMapcode.containsKey(eachexammapcode)){
Date AppDatesp = assetMapcode.get(eachexammapcode).Application_Date__c;
Integer daystoExpiresp =  Integer.valueOf(assetMapcode.get(eachexammapcode).Product_Exam_Date_to_Expire__c);
Date ApptDatesp = AppDatesp.addDays(daystoExpiresp);
Exam_Results__c exResultsp = new Exam_Results__c();
exResultsp.Exam_Type__c = 'Singapore AML Regime Exam';
exResultsp.Account__c = assetMapcode.get(eachexammapcode).accountid;
exResultsp.Asset__c = assetMapcode.get(eachexammapcode).id;
exResultsp.Contact__c = assetMapcode.get(eachexammapcode).Assignee__c;
exResultsp.Original_EAD__c = True;
exResultsp.PearsonVUE__c = True ;
exResultsp.clientCandidateID__c = assetMapcode.get(eachexammapcode).AccountId;
exResultsp.eligibilityApptDateFirst__c = System.today();
exResultsp.eligibilityApptDateLast__c  = ApptDatesp ;
exResultsp.examSeriesCode__c = assetMapcode.get(eachexammapcode).Exam_Code__c;
resultmapsing.add(exResultsp);
}
}
}
try{
insert resultmapsing;
}
catch(system.Dmlexception e) {
system.debug (e);                
}
List<Asset> asstupd3 = new List<Asset>();
if(!assetMapcode.isEmpty()){
for(Asset astmsp : [select id,EAD_created__c from asset where id in: assetMapcode.keyset()]){
asstupd3.add(new asset(id = astmsp.id,EAD_created__c = True));
}
}
update asstupd3;

if(!assetMapexcode.isEmpty()){
List<asset> asst = [select id,CC_Product__c,CC_Product__r.Exam_Date_to_Expire__c from asset where id in:assetMapexcode.keySet()];
if(asst != NULL && asst.size() >0){
Decimal mydecval = asst[0].CC_Product__r.Exam_Date_to_Expire__c;
Integer daysexam = mydecval.intValue();
for(String eachexamtestmapcode : assetMapexcode.keyset()){
if(assetMapexcode.containsKey(eachexamtestmapcode)){
Date eligfirst = assetMapexcode.get(eachexamtestmapcode).Exam_Schedule_Date__c.addDays(30);
Date eliglast  = assetMapexcode.get(eachexamtestmapcode).Exam_Schedule_Date__c.addDays(30).addDays(daysexam);
String ExamTypeCode;
if(assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'CGSS'){ ExamTypeCode = 'CGSS'; }
if(assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'Advanced CAMS - Risk Management'){ ExamTypeCode = 'CAMSRM'; }
if(assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'Advanced CAMS - Audit'){ ExamTypeCode = 'CAMS-Audit'; }
if(assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'CKYCA'){ ExamTypeCode = 'CKYCA'; }
if(assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'CTMA'){ ExamTypeCode = 'CTMA'; }
if(assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'CAFCA'){ ExamTypeCode = 'CAFCA'; }
if(assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'CAMS' && assetMapexcode.get(eachexamtestmapcode).Exam_Code__c != 'CAMS6_PTBFEB'){ ExamTypeCode = 'CAMS'; }
if(assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'CAMS' && assetMapexcode.get(eachexamtestmapcode).Exam_Code__c == 'CAMS6_PTBFEB') { ExamTypeCode = 'CAMSFebraban'; }
if((assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'India Regime')||(assetMapexcode.get(eachexamtestmapcode).Product_level_2__c == 'Singapore Regime')){ ExamTypeCode = 'Singapore AML Regime Exam'; }
Exam_Results__c exResultnp = new Exam_Results__c();
exResultnp.Exam_Type__c = ExamTypeCode;
exResultnp.Account__c = assetMapexcode.get(eachexamtestmapcode).accountid;
exResultnp.Asset__c = assetMapexcode.get(eachexamtestmapcode).id;
exResultnp.Contact__c = assetMapexcode.get(eachexamtestmapcode).Assignee__c;
exResultnp.Original_Exam_Result__c = assetMapexcode.get(eachexamtestmapcode).ExamResult__c;
exResultnp.PearsonVUE__c = True ;
exResultnp.Retake__c = True ;
exResultnp.clientCandidateID__c = assetMapexcode.get(eachexamtestmapcode).AccountId;
exResultnp.eligibilityApptDateFirst__c = eligfirst;
exResultnp.eligibilityApptDateLast__c  = eliglast;
exResultnp.examSeriesCode__c = assetMapexcode.get(eachexamtestmapcode).Exam_Code__c;
resultmapex.add(exResultnp);
}
}
}
}
try{
insert resultmapex;
}catch (system.Dmlexception e) {
system.debug (e);
}
List<Asset> asstupd4 = new List<Asset>();
if(!assetMapexcode.isEmpty()){
for(Asset astmsper : [select id,Latest_Retake_request_made_on__c,Retake__c from asset where id in: assetMapexcode.keyset()]){
asstupd4.add(new asset(id = astmsper.id,Retake__c = False,Latest_Retake_request_made_on__c = System.now()));
}
}
update asstupd4;

}
} 
//End of Process builder
//*/
    public static void UpsertLMSUser(List<Asset> newAssets) {
        if(isRecursiveChapterCheck == false){
            isRecursiveChapterCheck = true;
            try{
                Set<Id> contactIds = new Set<Id>();
                Map<Id, User> contactUserMap = new Map<Id, User>();
                List<LMSUtility.LMSUserRequest> lmsuserList = new List<LMSUtility.LMSUserRequest>();
                                
                if (newAssets != NULL && newAssets.size() > 0){
                    for(Asset newA : newAssets){
                        if (newA.AccountId != NULL){
                            isLMSUserCreated = true;
                            contactIds.add(newA.AccountId);
                        }
                    }
                    
                    if (contactIds.size() > 0){
                        for(Account c : [SELECT Id, FirstName,personemail,CommunityUser__r.Username,CommunityUser__r.LMS_Role__c, LastName FROM Account WHERE Id IN: contactIds]){
                            
                            LMSUtility.LMSUserRequest lmsuser = new LMSUtility.LMSUserRequest();
                            lmsuser.contactId = c.Id;
                            lmsuser.firstName = c.FirstName;
                            lmsuser.lastName = c.LastName;
                            lmsuser.language = '';
                            lmsuser.enabled = true;
                            lmsuser.username = c.CommunityUser__r.Username;
                            lmsuser.role = c.CommunityUser__r.LMS_Role__c;
                            lmsuserList.add(lmsuser);
                        }
                    }
                    
                    if (contactIds.size() > 0){
                        for(User u : [SELECT Id,ContactId,AccountId, Username, LMS_Role__c, TimeZoneSidKey  FROM User WHERE AccountId IN: contactIds]){
                            contactUserMap.put(u.AccountId, u);
                        }
                        for(LMSUtility.LMSUserRequest lmsU : lmsuserList){
                            if (contactUserMap.containsKey(lmsU.contactId)){
                                User u = contactUserMap.get(lmsU.contactId);
                                lmsU.username = u.Username;
                                lmsU.role = u.LMS_Role__c;
                                lmsU.timezone = ''; //lmsU.timezone = u.TimeZoneSidKey; -- Waiting for Timezone Integration
                            }
                        }
                    }
                }
                
                if (lmsuserList.size() > 0)
                    CalloutUtility.SendRequest('UserIntegration', true, LMSUtility.BuildJson(lmsuserList));
            }
            catch(Exception ex){
                               //csa fix added exception logger statement. 
				ACAMSUtil.reportException(null, null,'UpsertLMSUser Method', null, ex.getMessage(), null, null);
            }
            
        }
    }
    public static void AcamsHelperMethod(list<asset> newids,list<asset> oldids){
        if(isRecursiveBeforeUpdate == false){
            isRecursiveBeforeUpdate = true ;
            for(asset astn: newids){
                for(asset asto:oldids){
                  if(astn.status__c != asto.status__c){
                        if(astn.status__c == 'Inactive' && (astn.Enterprise_Product_HL__c =='ENTLATAM-S' || astn.Enterprise_Product_HL__c =='ENTLATAM-P')){
                            assetIds.add(astn.id);
                        }
                    }
                }
            }
            //csa fix: query optimise
            //List<BeckerLMS_Enrollment__c> BlmsList = new List<BeckerLMS_Enrollment__c>();
            List<BeckerLMS_Enrollment__c> UpdateBlmsList = new List<BeckerLMS_Enrollment__c>();
            //BlmsList=[select id, name, asset__c from BeckerLMS_Enrollment__c where status__c !='Completed' AND asset__c IN:assetIds ];
            try{
                for(BeckerLMS_Enrollment__c b:[select id, name, asset__c from BeckerLMS_Enrollment__c where status__c !='Completed' AND asset__c IN:assetIds ]){
                b.status__c = 'Cancelled';
                UpdateBlmsList.add(b);
            }
                if(UpdateBlmsList.size()>0){
                    update UpdateBlmsList;
                }
               }
            catch(DmlException e) {
                               //csa fix added exception logger statement. 
				ACAMSUtil.reportException(null, null,'AcamsHelperMethod Method', null, e.getMessage(), null, null);
            }
        }
    }
    
    
    /**
** @description: added logic for 2. Certification Asset: Populate the LMS access expiration Date upon
*the payment.
* @Date: July 2, 2020 - Rui
* @source: issue/Defect UAT LOG Row 301 "Layout" -
* https://app.smartsheet.com/sheets/CQ2rPHChHxfRvwPQ4m38fwVVcx4V6xCMmgf2pHw1?view=grid
*/
    
    /**
public static void updateLMSExpirationDate(List<Asset> newAssets, Map<Id,Asset> oldMap) {
if(newAssets != null && newAssets.size() > 0){
for(Asset a : newAssets){
if(a.Product_level_1__c == 'Certification' && a.Exam_Pass_Date__c != null && oldMap == null){
if(a.CC_Product__c != null){
Integer daysToExpire = a.CC_Product__r.Days_to_Expire__c != null ?
Integer.valueOf(a.CC_Product__r.Days_to_Expire__c) : 365;
a.LMS_Access_Exp_Date__c = a.Exam_Pass_Date__c.addDays(daysToExpire);

}
}

else if(a.Product_level_1__c == 'Certification' && a.Exam_Pass_Date__c != null && oldMap != null){
if(a.CC_Product__c != null && a.Exam_Pass_Date__c != null && oldMap.get(a.Id).Exam_Pass_Date__c != a.Exam_Pass_Date__c){
Integer daysToExpire = a.CC_Product__r.Days_to_Expire__c != null ?
Integer.valueOf(a.CC_Product__r.Days_to_Expire__c) : 365;
a.LMS_Access_Exp_Date__c = a.Exam_Pass_Date__c.addDays(daysToExpire);

}
}
}
}
}
*/
    
    /**
* @Description: added updated logic for 2. for all assets: Populate the LMS access expiration date upon the payment (asset install date)
* @Date: July 23, 2020, Rui.
* @Source: Adtalem Email : Thu 7/23/2020 4:19 PM , subject "LMS enrollment Logic"
* @ RQ changed on Aug 21,2020. ACAMS Email : Fri 8/21/2020 8:17 AM
*/
    
public static void updateLMSExpirationDate(List<Asset> newAssets, Map<Id,Asset> oldMap) {
        List<ccrz__E_Product__c> ccProdList = new List<ccrz__E_Product__c>();
        if(newAssets != null && newAssets.size() > 0){
           
 //@ in before trigger, parent reference objectAPI__r.field__c will be null and not working

            Map<Id,Decimal> daysToExpireMap = new Map<Id,Decimal>();
            Map<Id,String> expirationDateLogicMap = new Map<Id,String>();
            Map<Id,String> lmsCourseMap = new Map<Id,String>();
            
            Set<String> ccProductIds = new Set<String>();
            
            for(Asset a : newAssets){
                if(!String.isBlank(a.CC_Product__c)){
                    ccProductIds.add(a.CC_Product__c);
                }
            }
            if(ccProductIds.size()>0){
                List<ccrz__E_Product__c> prodList = new List<ccrz__E_Product__c>();
                prodList = [SELECT Id, LMS_Course__c, Expiration_Date_Logic__c, Days_to_Expire__c FROM ccrz__E_Product__c WHERE Id IN: ccProductIds AND LMS_Course__c != null];
                if(prodList.size()>0){
                    for(ccrz__E_Product__c prodLst : prodList ){
                        ccProdList.add(prodLst);
                    }
                }
                
            }
            //added 1774 by chinna
            //Reverted 29 june 2021,back to original as there is a fail in UAT of 1774
            for(ccrz__E_Product__c pd : ccProdList){
                if(pd.Days_to_Expire__c !=  null ){
                    daysToExpireMap.put(pd.Id,(pd.Days_to_Expire__c +1));
                }
                expirationDateLogicMap.put(pd.Id,pd.Expiration_Date_Logic__c);
                lmsCourseMap.put(pd.Id,pd.LMS_Course__c);
            }
            
            for(Asset a : newAssets){
                
                if(a.CC_Product__c != null && 
                   !String.isBlank(lmsCourseMap.get(a.CC_Product__c)) && daysToExpireMap.get(a.CC_Product__c) != null && expirationDateLogicMap.get(a.CC_Product__c) != null){
                   
// add LMS expire date equals to null in condition, per requirement changed in Email: Fri 8/21/2020 8:17 AM

                       if(a.LMS_Access_Exp_Date__c == null && String.valueOf(expirationDateLogicMap.get(a.CC_Product__c)).equals('Event Date') && a.Event_Date__c != null){
                           a.LMS_Access_Exp_Date__c = a.Event_Date__c.addDays(Integer.valueOf(daysToExpireMap.get(a.CC_Product__c)));
                       }
                       else if(a.LMS_Access_Exp_Date__c == null && String.valueOf(expirationDateLogicMap.get(a.CC_Product__c)).equals('Payment') && a.CreatedDate  != null && (a.Payment_Status__c == 'Authorized' || a.Payment_Status__c == 'Completed') && a.Status__c == 'Active'){
                           a.LMS_Access_Exp_Date__c = Date.newInstance((a.CreatedDate).year(),(a.CreatedDate).month(),(a.CreatedDate).day()).addDays(Integer.valueOf(daysToExpireMap.get(a.CC_Product__c)));
                       }
                   }
            }
        }
        
        
    } 
    public static void updateHLGrouponContact(List<Asset> newAssets,List<Asset> oldAssets) {
        
        Set<String> ccProductIds = new Set<String>();
        Map<Id,String> hlGroupMap = new Map<Id,String>();
        Map<Id,String> hlCommMap = new Map<Id,String>();
        Map<Id,String> hlSecMap = new Map<Id,String>();
        List<Contact> hlCommContactlst = new List<Contact>();
        List<Contact> hlSecContactlst = new List<Contact>();
        List<Contact> hlCommContactupdatelst = new List<Contact>();
        List<Contact> hlSecContactupdatelst = new List<Contact>();
        
        for(Asset a : newAssets){
            if(oldAssets == null){
                if(!String.isBlank(a.CC_Product__c) && a.Paid_Cert__c == true){
                    ccProductIds.add(a.CC_Product__c);
                }
            }
            else{
                for(Asset aold : oldAssets){
                    if(!String.isBlank(a.CC_Product__c) && a.Paid_Cert__c == true && a.Paid_Cert__c != aold.Paid_Cert__c){
                        ccProductIds.add(a.CC_Product__c);
                    }
                } 
            }
        }
        if(ccProductIds.size()>0){
            List<ccrz__E_Product__c> ccProdList = [SELECT Id, HigherLogic_Group__c FROM ccrz__E_Product__c WHERE Id IN: ccProductIds AND HigherLogic_Group__c!= null];
            for(ccrz__E_Product__c pd : ccProdList){
                hlGroupMap.put(pd.Id,pd.HigherLogic_Group__c);
                
            }
            for(Asset a : newAssets){
                if(a.ContactId != null){
                    if(hlGroupMap.size()>0 && hlGroupMap.get(a.CC_Product__c) != null ){
                        if(String.valueOf(hlGroupMap.get(a.CC_Product__c)).contains('HL Community')){
                            hlCommMap.put(a.ContactId,a.Group_Key__c);
                        }
                        //csa fix- was using same if loop twice
                      if(String.valueOf(hlGroupMap.get(a.CC_Product__c)).contains('HL Security Group')){
                            hlSecMap.put(a.ContactId,a.Group_Key__c);
                        }
                    }
                    //csa fix : Same if condition was repeated twice
                    /*if(hlGroupMap.size()>0 && hlGroupMap.get(a.CC_Product__c) != null){
                        if(String.valueOf(hlGroupMap.get(a.CC_Product__c)).contains('HL Security Group')){
                            hlSecMap.put(a.ContactId,a.Group_Key__c);
                        }
                    }*/
                }
            }

            hlCommContactlst = [select id, HL_Communities__c,Is_Active__c from contact where id in: hlCommMap.keyset() ];
            for(Contact c : hlCommContactlst){
                If(c.HL_Communities__c == null){
                    c.HL_Communities__c = String.valueOf(hlCommMap.get(c.id));
                    c.Is_Active__c =true;
                }
                else{
                    String Comm;
                    comm = c.HL_Communities__c ;
                    comm= comm + ';' + String.valueOf(hlCommMap.get(c.id));
                    c.HL_Communities__c = comm;
                    c.Is_Active__c =true;
                }
                hlCommContactupdatelst.add(c);
            }
            try{    
                if(hlCommContactupdatelst.size()>0){
                    Update hlCommContactupdatelst; 
                }
            } catch(DmlException e) {
                           ACAMSUtil.reportException(null, null,'updateHLGrouponContact Method', null, e.getMessage(), null, null);

            }    
            hlSecContactlst = [select id, HL_Security_Groups__c,Is_Active__c from contact where id in: hlSecMap.keyset() ];
            for(Contact c : hlSecContactlst){
                If(c.HL_Security_Groups__c == null){
                    c.HL_Security_Groups__c = String.valueOf(hlSecMap.get(c.id));
                    c.Is_Active__c =true;
                }
                else{
                    String Comm;
                    comm = c.HL_Security_Groups__c ;
                    comm= comm + ';' + String.valueOf(hlSecMap.get(c.id));
                    c.HL_Security_Groups__c = comm;
                    c.Is_Active__c =true;
                }
                hlSecContactupdatelst.add(c);
            }
            try{
                if(hlSecContactupdatelst.size()>0){
                    Update hlSecContactupdatelst;  
                }
            }
            catch(DmlException e) {
                               //csa fix added exception logger statement. 
				ACAMSUtil.reportException(null, null,'updateHLGrouponContact Method', null, e.getMessage(), null, null);
            }  
            
            isHLContactUpdated = true;
        }
    }
    public static void deactivateHLGrouponContact(List<Asset> newAssets,Map<Id, Asset> oldAssets) {
        Map<Id,String> assetIdHlMap = new Map<Id,String>();
        List<contact> cntLst = new List<contact>();
        List<contact> cntUpdateLst = new List<contact>();
        
        for(Asset a: newAssets){
            if(a.Status__c != oldAssets.get(a.id).Status__c && a.Status__c == 'Inactive' && a.HigherLogic_Group__c != null){
                assetIdHlMap.put(a.ContactId, a.Group_Key__c);
                
            }
        }
        //csa fix : moving query to for loop
        /*if(assetIdHlMap.size()>0){
            cntLst = [select id, HL_Communities__c, HL_Security_Groups__c from contact where id in:assetIdHlMap.keyset()];
        }*/
        for(contact c : [select id, HL_Communities__c, HL_Security_Groups__c from contact where id in:assetIdHlMap.keyset()] ){
            if(assetIdHlMap.size()>0 && c.HL_Communities__c != null && assetIdHlMap.get(c.id) != null){
                if(String.valueOf(c.HL_Communities__c).contains(String.valueOf(assetIdHlMap.get(c.id)))){
                    String Comm;
                    comm = c.HL_Communities__c ;
                    comm= comm.remove(String.valueOf(assetIdHlMap.get(c.id)));
                    c.HL_Communities__c = comm;
                }
            }
            if(assetIdHlMap.size()>0 && c.HL_Security_Groups__c != null && assetIdHlMap.get(c.id) != null){ 
                if(String.valueOf(c.HL_Security_Groups__c).contains(String.valueOf(assetIdHlMap.get(c.id)))){
                    String secGrp;
                    secGrp = c.HL_Security_Groups__c ;
                    secGrp= secGrp.remove(String.valueOf(assetIdHlMap.get(c.id)));
                    c.HL_Security_Groups__c = secGrp;
                }
            }
            cntUpdateLst.add(c);
            
        }
        try{
            if(cntUpdateLst.size()>0){
                Update cntUpdateLst;  
            }
        }
        catch(DmlException e) {
                          //csa fix added exception logger statement. 
 			ACAMSUtil.reportException(null, null,'deactivateHLGrouponContact Method', null, e.getMessage(), null, null);
        }  
        
        
    }
    public static void whitePaperUpdate( Map<Id,Asset> newMap, Map<Id,Asset> oldMap) {
        ACAMSAssetTriggerHandler.isWhitepaperUpdated =true;
        //List<Asset> assetLst = new List<Asset>();
        List<Asset> assetUpdate = new List<Asset>();
       // assetLst = [select id, White_Paper_Assignment_Approved__c, White_Paper_Approved_Date__c from Asset where id IN:newMap.keyset() ];
        for(Asset a : [select id, White_Paper_Assignment_Approved__c, White_Paper_Approved_Date__c from Asset where id IN:newMap.keyset()]){
            
            if(a.White_Paper_Assignment_Approved__c != oldMap.get(a.id).White_Paper_Assignment_Approved__c && a.White_Paper_Assignment_Approved__c  && a.White_Paper_Approved_Date__c != null){
                a.CurrentExpirationDate__c = Date.newInstance(a.White_Paper_Approved_Date__c.addYears(3).year(), 12, 15);
                assetUpdate.add(a);
            }
        }
        try{
            if(assetUpdate.size()>0){
                
                Update assetUpdate;  
            }
        }
        catch(DmlException e) {
                           //csa fix added exception logger statement. 
			ACAMSUtil.reportException(null, null,'whitePaperUpdate Method', null, e.getMessage(), null, null);
        }  
    }
    public static void authorizedStatus(List<Asset> newAssets, Map<Id,Asset> oldMap) {
        ACAMSAssetTriggerHandler.isauthorizedStatusUpdated = true;
        Set<Id> contactIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        //csa fix: moved query 
        //List<Asset> assetlst = new List<Asset>();
        List<Asset> assetUpdate = new List<Asset>();
        for (Asset asset : newAssets) {
            if (asset.Assignee__c != null && asset.Payment_Status__c != oldMap.get(asset.id).Payment_Status__c && asset.Payment_Status__c == 'Authorized') {
                contactIds.add(asset.Assignee__c);
                assetIds.add(asset.id);
            }
        }
        /*assetlst = [SELECT
                    AccountId,
                    Assignee__c,
                    Assignee__r.CAMS_Audit_Expiration_Date__c,
                    Assignee__r.CAMS_Expiration_Date__c,
                    Assignee__r.CAMS_FCI_Expiration_Date__c,
                    Assignee__r.CAMSRM_Expiration_Date__c,
                    Assignee__r.CGSS_Expiration_Date__c,
                    Assignee__r.CKYCA_Expiration_Date__c,
                    CC_Order_Item__c,
                    CC_Product__c,
                    CC_Product__r.Days_to_Expire__c,
                    CC_Product__r.Event_Date__c,
                    CC_Product__r.Expiration_Date_Logic__c,
                    CC_Product__r.Level_1__c,
                    CC_Product__r.Level_2__c,
                    CC_Product__r.Level_3__c,
                    CC_Product__r.LMS_Course__c,
                    CC_Product__r.Certification_Level__c,
                    CreatedDate,
                    CurrentExpirationDate__c,
                    Effective_Date__c,
                    Exam_Pass_Date__c,
                    Id,
                    LMS_Access_Exp_Date__c,
                    Name,
                    Paid_Cert__c,
                    Payment_Status__c,
                    RecordTypeId,
                    Status__c,
                    Subscription_Term__c,
                    ExamResultResult__c,
                    InstallDate
                    FROM
                    Asset where id in: assetIds ];*/
        Map<Id, Contact> idToContactMap = new Map<Id, Contact>(ACAMSAccountDAO.getContactsByContactIds(contactIds));
        for(Asset asset : [SELECT AccountId, Assignee__c, Assignee__r.CAMS_Audit_Expiration_Date__c, Assignee__r.CAMS_Expiration_Date__c, Assignee__r.CAMS_FCI_Expiration_Date__c, Assignee__r.CAMSRM_Expiration_Date__c, Assignee__r.CGSS_Expiration_Date__c, Assignee__r.CKYCA_Expiration_Date__c, CC_Order_Item__c, CC_Product__c, CC_Product__r.Days_to_Expire__c, CC_Product__r.Event_Date__c, CC_Product__r.Expiration_Date_Logic__c, CC_Product__r.Level_1__c, CC_Product__r.Level_2__c, CC_Product__r.Level_3__c, CC_Product__r.LMS_Course__c, CC_Product__r.Certification_Level__c, CreatedDate, CurrentExpirationDate__c, Effective_Date__c, Exam_Pass_Date__c, Id, LMS_Access_Exp_Date__c, Name, Paid_Cert__c, Payment_Status__c, RecordTypeId, Status__c, Subscription_Term__c, ExamResultResult__c, InstallDate FROM Asset WHERE id in: assetIds]){
            if(asset.Payment_Status__c != oldMap.get(asset.id).Payment_Status__c && asset.Payment_Status__c == 'Authorized'){
                asset.Status__c = 'Active';
                // FSA-843
                if(asset.InstallDate == null){
                asset.InstallDate = Date.today();
                }
                Integer term = asset.Subscription_Term__c != null ? Integer.valueOf(asset.Subscription_Term__c) : 12;
              
                  if (asset.Name == ACAMSUtil.MEMBERSHIP) {
                    if (idToContactMap.get(asset.Assignee__c) != null &&
                        idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c != NULL &&
                        idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c >= Date.today()) {
                            if(asset.Effective_Date__c == null){
                            asset.Effective_Date__c = idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c;
                            }
                            if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c =
                                idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c.addMonths(term);
                            }
                            if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c =  idToContactMap.get(asset.Assignee__c).Member_Expire_Date__c.addMonths(term);
                            }
                            
                        } else {
                             if(asset.Effective_Date__c == null){
                            asset.Effective_Date__c = Date.today();
                             }  if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c = Date.today().addMonths(term);
                             }
                                  if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = Date.today().addMonths(term);
                            }
                        }
                } 
                else if (asset.Name == ACAMSUtil.CHAPTER + ' ' + ACAMSUtil.MEMBERSHIP) {
                    if (idToContactMap.get(asset.Assignee__c) != NULL &&
                        idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c != NULL &&
                        idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c >= Date.today()) {
                             if(asset.Effective_Date__c == null){
                            asset.Effective_Date__c = idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c;
                             }
                              if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c =
                                idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c.addMonths(term);
                              }
                              if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c =   idToContactMap.get(asset.Assignee__c).Chapter_Member_Expire_Date__c.addMonths(term);
                            }
                        } else {
                             if(asset.Effective_Date__c == null){
                            asset.Effective_Date__c = Date.today();
                             }
                              if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c = Date.today().addMonths(term);
                              }
                              if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = Date.today().addMonths(term);
                            }
                        }
                } 
                else if (asset.Name == ACAMSUtil.MONEYLAUNDERINGDOTCOM) {
                    if (idToContactMap.get(asset.Assignee__c) != NULL &&
                        idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c != NULL &&
                        idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c >= Date.today()) {
                             if(asset.Effective_Date__c == null){
                            asset.Effective_Date__c = idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c;
                             }
                              if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c =
                                idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c.addMonths(term);
                              }
                              if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = idToContactMap.get(asset.Assignee__c).MLDC_Expiration_Date__c.addMonths(term);
                            }
                        } else {
                             if(asset.Effective_Date__c == null){
                            asset.Effective_Date__c = Date.today();
                             }
                              if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c = Date.today().addMonths(term);
                              }
                              if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = Date.today().addMonths(term);
                            }
                        }
                } 
                else if (asset.Name == ACAMSUtil.ACAMS_TODAY + ' ' + ACAMSUtil.PRINTED_SUBSCRIPTION) {
                    if (idToContactMap.get(asset.Assignee__c) != NULL &&
                        idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c != NULL &&
                        idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c >= Date.today()) {
                             if(asset.Effective_Date__c == null){
                            asset.Effective_Date__c = idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c;
                             }
                              if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c =
                                idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c.addMonths(term);
                              }
                               if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = idToContactMap.get(asset.Assignee__c).ACAMS_Today_Expiration_Date__c.addMonths(term);
                            }
                        } else {
                             if(asset.Effective_Date__c == null){
                            asset.Effective_Date__c = Date.today();
                             }
                              if(asset.CurrentExpirationDate__c == null){
                            asset.CurrentExpirationDate__c = Date.today().addMonths(term);
                              }
                               if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = Date.today().addMonths(term);
                            }
                        }
                } 
                else {
                    if (asset.CC_Product__r.Level_1__c != ACAMSUtil.CERTIFICATION) {
                         if(asset.Effective_Date__c == null){
                        asset.Effective_Date__c = Date.today();
                         }
                        Integer daysToExpire = asset.CC_Product__r.Days_to_Expire__c != null ?
                            Integer.valueOf(asset.CC_Product__r.Days_to_Expire__c) : 5;
                         Integer monthsToExpire = (daysToExpire == 5 && asset.Subscription_Term__c != null)? Integer.valueOf(asset.Subscription_Term__c) : 0;
                        if (asset.CC_Product__r.Expiration_Date_Logic__c != null &&
                            asset.CC_Product__r.Expiration_Date_Logic__c == ACAMSUtil.PAYMENT) {
                                if(monthsToExpire != 0){
                                      if(asset.CurrentExpirationDate__c == null){
                                     asset.CurrentExpirationDate__c = Date.today().addMonths(monthsToExpire);
                                      }
                                   if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c =  Date.today().addMonths(monthsToExpire);
                                
                                   }
                                }
                                else{
                                      if(asset.CurrentExpirationDate__c == null){
                                asset.CurrentExpirationDate__c = Date.today().addDays(daysToExpire);
                                      }
                                   if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c =  Date.today().addDays(daysToExpire);
                            }
                                
                                }
                            } else {
                                Date eventDate = asset.CC_Product__r.Event_Date__c != null &&
                                    asset.CC_Product__r.Event_Date__c >= Date.today() ? asset.CC_Product__r.Event_Date__c :
                                Date.today();
                                if(monthsToExpire != 0){
                                      if(asset.CurrentExpirationDate__c == null){
                                      asset.CurrentExpirationDate__c = eventDate.addMonths(monthsToExpire);
                                      }
                                   if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = eventDate.addMonths(monthsToExpire);
                                   }
                                }
                                else{
                                      if(asset.CurrentExpirationDate__c == null){
                                asset.CurrentExpirationDate__c = eventDate.addDays(daysToExpire);
                                      }
                                   if(asset.CC_Product__r.LMS_Course__c != null && asset.LMS_Access_Exp_Date__c == null){
                               asset.LMS_Access_Exp_Date__c = eventDate.addDays(daysToExpire);
                                   }
                            }
                            }
                    }
                    
                    if(asset.CC_Product__r.Level_1__c == ACAMSUtil.CERTIFICATION && asset.CC_Product__r.Level_3__c == 'Retake/Extension' ){
                         if(asset.Effective_Date__c == null){
                        asset.Effective_Date__c = Date.today();
                         }
                    }
                    
                }
                assetUpdate.add(asset);
            }
            
            
        }
        try{
            if(assetUpdate.size()>0){
                
                Update assetUpdate;  
            }
        }
        catch(DmlException e) {
                           //csa fix added exception logger statement. 
			ACAMSUtil.reportException(null, null,'authorizedStatus Method', null, e.getMessage(), null, null);
        } 
    }
    public static void recertExpDate(List<Asset> newAssets, Map<Id,Asset> oldMap) {
        ACAMSAssetTriggerHandler.isrecertExpDateUpdated =true;
        
        /**
* @description:Recertifications: expiration dates are automatically populated to upon
* purchase/creation to December 15, 3 years after the latest certification/recertification
* expiration date.
* @Date: July 6, 2020 - Rui
* @Source: https://app.smartsheet.com/sheets/PmRwr2pvMQC65M3XQQGhq6HMrjr3hcVHqHC5rFm1?view=grid&filterId=792913769719684   item 14

*/          
        Set<Id> aSetIDs = new Set<Id>();
        for(Asset newasset : newAssets){
            if(newasset.id != null)
                aSetIDs.add(newasset.id);
        }
        
        //List<Asset> assetlst = new List<Asset>();
        Set<Id> assetIds = new Set<Id>();
        List<Asset> assetUpdate = new List<Asset>();
        
        Map<Id,Asset> recertapp = new Map<Id,Asset>( [SELECT id,Payment_Status__c,Paid_Cert__c,Status__c,Certification_Approved_Application__c,(SELECT id,Status__c,Asset__c from Recertification_Applications__r where Status__c != null AND Asset__c != null ) from  Asset where CurrentExpirationDate__c = null AND Effective_Date__c = null and id in : aSetIDs]);
        
        for(Asset asset : recertapp.values()){
           for(Recertification_Application__c recert : asset.Recertification_Applications__r ){
                if(((asset.Payment_Status__c == 'Completed' && asset.Paid_Cert__c == true && asset.Certification_Approved_Application__c == true)||
                    (asset.Payment_Status__c == 'Authorized' && asset.Paid_Cert__c == false && recert.Status__c == 'Approved')) && asset.Status__c == 'Active'){
                        assetIds.add(asset.id);
                        //  assetIds.add(recert.Asset__c);
                        
                    }
                
                
            }          
            /* if(((asset.Payment_Status__c != oldMap.get(asset.id).Payment_Status__c && asset.Payment_Status__c == 'Completed' && (asset.Paid_Cert__c || asset.Certification_Approved_Application__c)) || (asset.Certification_Approved_Application__c != oldMap.get(asset.id).Certification_Approved_Application__c && asset.Certification_Approved_Application__c && asset.Payment_Status__c == 'Completed' ))){
assetIds.add(asset.id);
}*/
            //system.debug('AssetIds..'+assetIds);
        }
       /* assetlst = [SELECT
                    AccountId,
                    Assignee__c,
                    Assignee__r.CAMS_Audit_Expiration_Date__c,
                    Assignee__r.CAMS_Expiration_Date__c,
                    Assignee__r.CAMS_FCI_Expiration_Date__c,
                    Assignee__r.CAMSRM_Expiration_Date__c,
                    Assignee__r.CTMA_Expiration_Date__c,
                    Assignee__r.CAFCA_Expiration_Date__c,
                    Assignee__r.CGSS_Expiration_Date__c,
                    Assignee__r.CKYCA_Expiration_Date__c,
                    Assignee__r.CCAS_Expiration_Date__c,
                    CC_Order_Item__c,
                    CC_Product__c,
                    CC_Product__r.Days_to_Expire__c,
                    CC_Product__r.Event_Date__c,
                    CC_Product__r.Expiration_Date_Logic__c,
                    CC_Product__r.Level_1__c,
                    CC_Product__r.Level_2__c,
                    CC_Product__r.Level_3__c,
                    CC_Product__r.LMS_Course__c,
                    CC_Product__r.Certification_Level__c,
                    CreatedDate,
                    CurrentExpirationDate__c,
                    Effective_Date__c,
                    Exam_Pass_Date__c,
                    Application_Date__c, //FSA-4721
                    Id,
                    LMS_Access_Exp_Date__c,
                    Name,
                    Paid_Cert__c,
                    Payment_Status__c,
                    RecordTypeId,
                    Status__c,
                    Subscription_Term__c,
                    ExamResultResult__c
                    FROM
                    Asset where id in: assetIds ];*/
         List<Recertificate_Expiration_Date_Mapping__mdt> RecMapLst = Recertificate_Expiration_Date_Mapping__mdt.getAll().values();
        Map<String, String>  RecMapMap = new Map<String, String>();
        for(Recertificate_Expiration_Date_Mapping__mdt rec:RecMapLst){
            RecMapMap.put(rec.MasterLabel, rec.API_Name__c);
        }
       for(Asset asset : [SELECT AccountId, Assignee__c, Assignee__r.CAMS_Audit_Expiration_Date__c,Assignee__r.CAMS_Expiration_Date__c,Assignee__r.CAMS_FCI_Expiration_Date__c,Assignee__r.CAMSRM_Expiration_Date__c,Assignee__r.CTMA_Expiration_Date__c,Assignee__r.CAFCA_Expiration_Date__c,Assignee__r.CGSS_Expiration_Date__c,Assignee__r.CKYCA_Expiration_Date__c,Assignee__r.CCAS_Expiration_Date__c,CC_Order_Item__c,CC_Product__c,CC_Product__r.Days_to_Expire__c,CC_Product__r.Event_Date__c,CC_Product__r.Expiration_Date_Logic__c,CC_Product__r.Level_1__c,CC_Product__r.Level_2__c,CC_Product__r.Level_3__c,CC_Product__r.LMS_Course__c,CC_Product__r.Certification_Level__c,CreatedDate,CurrentExpirationDate__c,Effective_Date__c,Exam_Pass_Date__c,Application_Date__c,Id,LMS_Access_Exp_Date__c,Name,Paid_Cert__c,Payment_Status__c,RecordTypeId,Status__c,Subscription_Term__c,ExamResultResult__c FROM Asset where id in: assetIds]){
            if (asset.CC_Product__c != null && asset.CC_Product__r.Level_3__c == 'Recertification') {
                if(asset.CC_Product__r.Certification_Level__c =='Associate' && RecMapMap.get(asset.CC_Product__r.Level_2__c) != null){
                    if(asset.Effective_Date__c == null){
                   asset.Effective_Date__c  = (date) asset.getsobject('Assignee__r').get(RecMapMap.get(asset.CC_Product__r.Level_2__c)); 
                    }
                      if(asset.CurrentExpirationDate__c == null){
                   asset.CurrentExpirationDate__c = asset.Effective_Date__c.addYears(1);
                      }
             
                }
                  else if(asset.CC_Product__r.Certification_Level__c !='Associate' && RecMapMap.get(asset.CC_Product__r.Level_2__c) != null){
                      if(asset.Effective_Date__c == null){
                   asset.Effective_Date__c  = (date) asset.getsobject('Assignee__r').get(RecMapMap.get(asset.CC_Product__r.Level_2__c)); 
                      }
                        if(asset.CurrentExpirationDate__c == null){
                   asset.CurrentExpirationDate__c =  Date.newInstance(
                                 asset.Effective_Date__c.year() + 3, 12, 15
                             );
                        
                 
                        }
                }
                  
            }
            
            assetUpdate.add(asset);
        }
        try{
            
            if(assetUpdate.size()>0){
                Update assetUpdate;  
            }
        }
        catch(DmlException e) {
                           //csa fix added exception logger statement. 
			ACAMSUtil.reportException(null, null,'recertExpDate Method', null, e.getMessage(), null, null);
        } 
    }
    //FSA-347
   /* public static void updateCurrentExpirationDate(List<Asset> newAssets) {
        for(Asset a : newAssets) {
            if(validEnterpriseProductHL.contains(a.Enterprise_Product_HL__c) && a.Exam_Result_for_Exp_date__c == 'Pass') {
                a.CurrentExpirationDate__c = Date.valueOf('2099-12-15');// Date as given in existing WFR
                system.debug('enter==>'+ a.CurrentExpirationDate__c);
            }
        }
    }
*/
 /*   public static void updateCertificationExpirationDate(List<Asset> newAssets) {
        List<Id> assetIds = new List<Id>();
        for(Asset a : newAssets) { assetIds.add(a.Id);}
        
        List<Asset> assetsList = [Select Id, Certification_Exam_Passed__c, ExamResultResult__c, Exam_Result_for_Exp_date__c, Enterprise_Product_HL__c,
                                  Product_Level_1__c, Product_level_2__c, Product_level_3__c,ExamResult__r.Test_Date__c, Effective_Date__c, Exam_Pass_Date__c,CurrentExpirationDate__c  from Asset where Id in: assetIds  ];
        
        Map<Id, Date> ExamResultTestDate = new Map<Id, Date>();
        for(Asset a : assetsList) {ExamResultTestDate.put(a.Id, a.ExamResult__r.Test_Date__c); }
        
        for(Asset a : newAssets) {
            system.debug('a.CurrentExpirationDate__ctest::'+a.CurrentExpirationDate__c); 
            system.debug('a.Certification_Exam_Passed__ctesting'+ a.Certification_Exam_Passed__c);
            system.debug('a.ExamResultResult__ctest' + (a.ExamResultResult__c == 'Pass'));
            system.debug('a.Exam_Result_for_Exp_date__ctest'+ (a.Exam_Result_for_Exp_date__c == 'Pass'));
            if((a.Certification_Exam_Passed__c || a.ExamResultResult__c == 'Pass' || a.Exam_Result_for_Exp_date__c == 'Pass')
               && profileName != 'Data Migration' && (a.Enterprise_Product_HL__c != 'IN-AML-Regime' || a.Enterprise_Product_HL__c != 'SG-AML-Regime') && a.Product_Level_1__c == 'Certification' && !validProductLevel2.contains(a.Product_level_2__c)) { //FSA-3127
                   system.debug('inside logic line 1464'); 
                   if(ExamResultTestDate.get(a.Id) != null){
                       a.CurrentExpirationDate__c = Date.newInstance(ExamResultTestDate.get(a.Id).year() + 3, 12, 15);
                       system.debug('enter==>'+ a.CurrentExpirationDate__c);
                   }
                   system.debug('a.CurrentExpirationDate__c::'+a.CurrentExpirationDate__c);
                   
                   system.debug('a.Exam_Pass_Date__cbefore::'+a.Exam_Pass_Date__c);
                   a.Effective_Date__c = a.Exam_Pass_Date__c;
                   system.debug('enter==>'+ a.Effective_Date__c);
                   
               }
        }
    }
*/
    public static void updateCancelDate(List<Asset> newAssets, Map<Id, Asset> oldMap, Map<Id, Asset> newMap) {
        for(Asset a: newAssets) {
            if(oldMap.get(a.Id).CancelDate__c != newMap.get(a.Id).CancelDate__c && a.CancelDate__c != null && a.CancelDate__c == system.today() && profileName != 'Data Migration') {
                a.Status__c = 'Inactive';
            }
        }
    }
    //FSA-347
    public static void insertMLDCRecords(List<Asset> newAssets) {
        Set<Id> AssigneeIds = new Set<Id>();
       // Set<Id> mldccontactIds = new Set<Id>();
       // List<MLDC_Data__c> insertMLDCRecords = new List<MLDC_Data__c>();
        for(Asset a: newAssets){
            if((a.Product_level_1__c == 'Enterprise Bundle' || a.Product_level_2__c == 'Moneylaundering.com') && a.CurrentExpirationDate__c > Date.Today() && a.Assignee__c != null && a.LastModifiedBy.Profile.Name != 'Data Migration'){
               // AssigneeIds.add(a.Assignee__c);
               // system.debug('AssigneeIds '+AssigneeIds);
               // FSA-6834
                 pushAssetMethodEvents(a.Assignee__c,'insertMLDCRecords');
            }
        }
            //FSA-6834 Moved to ACAMSAssetMethodEventsTrigger
    /*    List<MLDC_Data__c> MLDCRecords = [select id, Contact__c, Name, Content_Alerts__c, Weekly_Newsletter__c from MLDC_Data__c where Contact__c IN: AssigneeIds];
        if(!MLDCRecords.isEmpty()){
            for(MLDC_Data__c mldc : MLDCRecords){
                if(!AssigneeIds.contains(mldc.Contact__c)){
                    mldccontactIds.add(mldc.Contact__c);
                    system.debug('mldccontactIds '+mldccontactIds);
                }
            }
        }else{
            mldccontactIds.addAll(AssigneeIds);
        }
       if(!mldccontactIds.isEmpty()){
            for(Id ids : mldccontactIds){
                MLDC_Data__c mldcRecord = new MLDC_Data__c();
                mldcRecord.Contact__c = ids;
                mldcRecord.Content_Alerts__c = true;
                mldcRecord.Weekly_Newsletter__c = true;
                insertMLDCRecords.add(mldcRecord);
                system.debug('insertMLDCRecords '+insertMLDCRecords);
            }
        }
        if(!insertMLDCRecords.isEmpty()){
            system.debug('insertMLDCRecords 11 '+insertMLDCRecords);
            Database.insert(insertMLDCRecords);
        } */
    }
    public static void createExamAuthorization(Map<Id,Asset> newMap) { 
        List<Exam_Code_to_Exam_Type_Mapping__mdt> examMapLst = Exam_Code_to_Exam_Type_Mapping__mdt.getAll().values();
        Map<String, String>  examMapMap = new Map<String, String>();
        for(Exam_Code_to_Exam_Type_Mapping__mdt emp:examMapLst){
            examMapMap.put(emp.Exam_Code__c, emp.Exam_Type__c);
        }
        List<Pearson_Vue_Exam_Security_Country_Code__mdt> PVCMapLst = Pearson_Vue_Exam_Security_Country_Code__mdt.getAll().values();
        Map<String, String>  PVCMapMap = new Map<String, String>();
        for(Pearson_Vue_Exam_Security_Country_Code__mdt pvc:PVCMapLst){
            PVCMapMap.put(pvc.MasterLabel, pvc.Exam_Series_Code__c);
        }
        List<Asset> assetLst = new List<Asset>();
        List<Asset> assetLstRetake = new List<Asset>();
        List<Exam_Results__c> examResultInsert = new List<Exam_Results__c>();
    
        assetLst =[select id,Certification_Approved_Application__c,SG_AML_REGIME_Exam_Application_Approved__c,Membership_Type__c,Paid_Cert__c, Product_level_1__c,EAD_created__c,Recert__c,Retake__c,Billing_Country__c,Enterprise_Product_HL__c,Status__c, Product_level_2__c,Product_level_3__c,Assignee__r.Accountid,Assignee__c,Accountid,Exam_Code__c,Latest_Retake_request_made_on__c, Application_Date__c,CC_Product__r.Exam_Date_to_Expire__c,ExamResult__c,ExamResult__r.Test_Date__c from Asset where id in: newMap.keyset() AND Paid_Cert__c = true  AND (Membership_Type__c ='MEMBER' OR Membership_Type__c ='ENTERPRISE')    AND Recert__c=false AND (Certification_Approved_Application__c = true OR SG_AML_REGIME_Exam_Application_Approved__c = true) AND Status__c='Active'AND EAD_created__c = false AND Exam_Code__c!=null ];
        
        assetLstRetake =[select id,Certification_Approved_Application__c,SG_AML_REGIME_Exam_Application_Approved__c,Membership_Type__c,Paid_Cert__c,Product_level_1__c,EAD_created__c,Recert__c,Retake__c,Billing_Country__c,Enterprise_Product_HL__c,Status__c, Product_level_2__c,Product_level_3__c,Assignee__r.Accountid,Assignee__c,Accountid,Exam_Code__c,Latest_Retake_request_made_on__c, Application_Date__c,CC_Product__r.Exam_Date_to_Expire__c,ExamResult__c,ExamResult__r.Test_Date__c from Asset where id in: newMap.keyset() AND (Membership_Type__c ='MEMBER' OR Membership_Type__c ='ENTERPRISE')   AND Paid_Cert__c = true AND Recert__c=false AND (Certification_Approved_Application__c = true OR SG_AML_REGIME_Exam_Application_Approved__c = true )  AND Status__c='Active' AND  Retake__c = true ];
        
        if(assetLst.size()>0){
            for(Asset a : assetLst){
                Date AppFirstDate = a.Application_Date__c;
                Integer daystoExpire = 0;
                if(a.CC_Product__r.Exam_Date_to_Expire__c != null || a.CC_Product__r.Exam_Date_to_Expire__c > 0) 
                    daystoExpire = Integer.valueOf(a.CC_Product__r.Exam_Date_to_Expire__c);
                Date AppLastDate = AppFirstDate.addDays(daystoExpire);
                Exam_Results__c examResult = new Exam_Results__c();
                examResult.Exam_Type__c = examMapMap.get(a.Exam_Code__c);
                examResult.Account__c = a.Assignee__r.Accountid;
                examResult.Asset__c = a.id;
                examResult.Contact__c = a.Assignee__c;
                examResult.Original_EAD__c = true;
                examResult.PearsonVUE__c = True ;  
                examResult.Retake__c=false;
                examResult.clientCandidateID__c = a.Assignee__r.Accountid;
                examResult.eligibilityApptDateFirst__c = System.today();
                examResult.eligibilityApptDateLast__c  = AppLastDate;
                if(PVCMapMap.get(a.Billing_Country__c+a.Exam_Code__c) != null){
                    examResult.examSeriesCode__c = PVCMapMap.get(a.Billing_Country__c+a.Exam_Code__c);
                }
                else{
                    examResult.examSeriesCode__c = a.Exam_Code__c;
                }
                examResultInsert.add(examResult);
                
            }
            try{
                if(examResultInsert.size()>0){
                    insert examResultInsert;
                    isexamAuthorized=true;
                }
            }
            catch(system.Dmlexception e) {
                               //csa fix added exception logger statement. 
				ACAMSUtil.reportException(null, null,'createExamAuthorization Method', null, e.getMessage(), null, null);
            }
            List<Asset> astUpdate = new List<Asset>();
            
            for(Asset ast : assetLst){
                ast.EAD_created__c = true;
                astUpdate.add(ast);
            }
            if(astUpdate.size()>0){
                try{
                    update astUpdate;
                }
                catch(system.Dmlexception e) {
                    ACAMSUtil.reportException(null, null,'createExamAuthorization Method', null, e.getMessage(), null, null);
                }
            }
        }
        
        if(assetLstRetake.size()>0){
            for(Asset a : assetLstRetake){
                Date AppFirstDate = a.Application_Date__c;
                Integer daystoExpire = Integer.valueOf(a.CC_Product__r.Exam_Date_to_Expire__c);
                Date AppLastDate = AppFirstDate.addDays(daystoExpire);
                Exam_Results__c examResult = new Exam_Results__c();
                examResult.Exam_Type__c = examMapMap.get(a.Exam_Code__c);
                examResult.Account__c = a.Assignee__r.Accountid;
                examResult.Asset__c = a.id;
                examResult.Contact__c = a.Assignee__c;
                examResult.Original_EAD__c = false;
                examResult.PearsonVUE__c = True ;
                examResult.Retake__c=true;
                examResult.Original_Exam_Result__c=a.ExamResult__c;
                examResult.clientCandidateID__c = a.Assignee__r.Accountid;
                if(a.ExamResult__c != null){
                    examResult.eligibilityApptDateFirst__c =a.ExamResult__r.Test_Date__c+60;
                    examResult.eligibilityApptDateLast__c  = a.ExamResult__r.Test_Date__c+240;
                }
                if(PVCMapMap.get(a.Billing_Country__c+a.Exam_Code__c) != null){
                    examResult.examSeriesCode__c = PVCMapMap.get(a.Billing_Country__c+a.Exam_Code__c);
                }
                else{
                    examResult.examSeriesCode__c = a.Exam_Code__c;
                }
                examResultInsert.add(examResult);
                
            }
            try{
                if(examResultInsert.size()>0){
                    insert examResultInsert;
                    isexamAuthorized=true;
                }
            }
            catch(system.Dmlexception e) {
                               //csa fix added exception logger statement. 
				ACAMSUtil.reportException(null, null,'createExamAuthorization Method', null, e.getMessage(), null, null);
            }
            List<Asset> astUpdate = new List<Asset>();
            
            for(Asset ast : assetLstRetake){
                ast.Retake__c =false;
                ast.Latest_Retake_request_made_on__c =system.now();
                astUpdate.add(ast);
            }
            if(astUpdate.size()>0){
                try{
                    update astUpdate;
                }
                catch(system.Dmlexception e) {
                                   //csa fix added exception logger statement. 
					ACAMSUtil.reportException(null, null,'createExamAuthorization Method', null, e.getMessage(), null, null);
                }
            } 
        }       
    }
    //FSA-262 related changes Start
   public static void recertificationApplicationUpdate(List<Asset> newList, Map<Id,Asset> oldMap){
     // list<Recertification_Application__c> lstRec = new list<Recertification_Application__c>();
      // string mydate =string.valueOf(system.today());
      // String myString = mydate.left(4);
       
       set<Id> AssId= new set<Id>();
       map<id,Recertification_Application__c> mapRecrtApp = new map<id,Recertification_Application__c>();
       for(Asset ass: newList){
           if(ass.Payment_Status__c == 'Completed' && ass.Status__c == 'Active' && ass.CC_Order__c == null){
       AssId.add(ass.id);
               //FSA-6834
                pushAssetMethodEvents(ass.id,'recertificationApplicationUpdate');
                
               }
           }
           //FSA-6834 Moved to ACAMSAssetMethodEventsTrigger
     /*  for(Recertification_Application__c recerApp : [select id,Asset__c,Status__c,Recertification_Year__c from Recertification_Application__c where Asset__c In:AssId]){
       mapRecrtApp.put(recerApp.Asset__c,recerApp);
           } */
       
   /*    for(Recertification_Application__c  recAP : [select id,Asset__c,Status__c,Recertification_Year__c from Recertification_Application__c where Asset__c In:AssId]){
           If(recAP.Status__c == 'Started' && recAP.Recertification_Year__c == null){
              recAP.Status__c = 'Approved';
              recAP.Recertification_Year__c = myString;
              lstRec.add(recAP);
           }
       }
      database.update(lstRec);
            */ 
   }
     //FSA-262 related changes End
     
    //FSA-6834
    public static void pushAssetMethodEvents(ID recordId, String methodName){
        List<Asset_Method__e> assetMethodEvents = new List<Asset_Method__e>();
        assetMethodEvents.add(new Asset_Method__e(Record_ID__c=recordId,Method_Name__c=methodName));
        
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(assetMethodEvents);
        
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