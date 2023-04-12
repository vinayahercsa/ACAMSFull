public class ACAMSExamResultTriggerHandler extends CCAviTriggerHandler {

    private List<Exam_Results__c> newList;
    private List<Exam_Results__c> oldList;
    private Map<Id, Exam_Results__c> newMap;
    private Map<Id, Exam_Results__c> oldMap;
    public Set<Id> contactIds = new Set<Id>();
    public Set<Id> eadIds = new Set<Id>();
    public Set<Id> extnsnIds = new Set<Id>();
    Public boolean exec = false;
    Public boolean isPearsonVUE = false;
    Public string type;
    Public static boolean examResultPass = false; //fsa-831
  
    
    
    PearsonVueIntegration__c pv = PearsonVueIntegration__c.getOrgDefaults();

    public ACAMSExamResultTriggerHandler() {
        super();
        this.newList = (List<Exam_Results__c>) Trigger.new;
        this.oldList = (List<Exam_Results__c>) Trigger.old;
        this.newMap = (Map<Id, Exam_Results__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Exam_Results__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {

        ExamResultHelper.UpdateCertResult(this.newList);
      //  ExamResultHelper.UpdateExamType(this.newList);
        ExamResultHelper.UpdatePVDates(this.newList);
         
    }

    public override void beforeUpdate() {
        ExamResultHelper.UpdateCertResult(this.newList);
     //   ExamResultHelper.UpdateExamType(this.newList);
        ExamResultHelper.UpdatePVDates(this.newList);
       
        
    }
    public override void afterInsert() {
        for (Exam_Results__c e : this.newList) {
            if (e.PearsonVUE__c != true) {
                ExamResultHelper.UpsertExamResultOnAsset(this.newList);
            }
        }
        for (Exam_Results__c e : this.newList) {
            if (e.PearsonVUE__c == true) {
                isPearsonVUE = true;
            }
            if (e.Extension__c == true) {
                type = 'extension';
            } else if (e.Retake__c == true) {
                type = 'retake';
            } else if (e.Original_EAD__c == true) {
                type = 'original';
            }
            if (e.Original_EAD__c == true) {
                contactIds.add(e.Account__c);
                eadIds.add(e.id);

                exec = true;
            } else if (e.Original_EAD__c == false) {

                eadIds.add(e.id);
            }
        }
        //FSA-498 - Kiran
        if (isPearsonVUE && !System.isFuture() && !System.isBatch() ) {
            if (exec == true) {
                if (!ExamResultHelper.isVUERecursiveCheck)
                    ExamResultHelper.SendContactInfo(contactIds);
                if (!ExamResultHelper.isVUERecursiveEADCheck)
                    ExamResultHelper.SendEADInfo(eadIds, pv.AddTransaction__c, type);
            } else {
                if (!ExamResultHelper.isVUERecursiveEADCheck)
                    ExamResultHelper.SendEADInfo(eadIds, pv.AddTransaction__c, type);

            }
        }

        /**
         *  ACR-2255, set certification asset expiration date after insert.
         *  @ Jun 11, 2020, Ray
         */
        this.setupCertificationAssetExpirationDateAfterPassExam(newList,oldMap);
       
       
    }

    public override void afterUpdate() {
        
       
        for (Exam_Results__c e : this.newList) {
            if (e.PearsonVUE__c != true) {
                ExamResultHelper.UpsertExamResultOnAsset(this.newList);
            }
        }
        for (Exam_Results__c e : this.newList) {
            for (Exam_Results__c o : this.oldList) {
                if (e.Extension__c == true) {
                    type = 'extension';
                } else if (e.Retake__c == true) {
                    type = 'retake';
                }

                if (e.PearsonVUE__c == true && ((o.Extension__c != e.Extension__c && e.Extension__c == true) || o.eligibilityApptDateFirst__c != e.eligibilityApptDateFirst__c || o.eligibilityApptDateLast__c != e.eligibilityApptDateLast__c || o.examSeriesCode__c != e.examSeriesCode__c)) {
                    extnsnIds.add(e.id);
                }
            }
        }
        //FSA-498 - Kiran
        if (!ExamResultHelper.isVUERecursiveEADCheck && !System.isFuture() && !System.isBatch()) {
            ExamResultHelper.SendEADInfo(extnsnIds, pv.UpdateTransaction__c, type);
            
        }

    /**
     *  ACR-2255, set certification asset expiration date after udpate.
     *  @ Jun 11, 2020, Ray
     */
        this.setupCertificationAssetExpirationDateAfterPassExam(newList,oldMap);
      
        if(!examResultPass){
         ExamResultHelper.UpdateCertResultToPass(newList,oldMap);//FSA-831
         examResultPass = true;
       }
        
    }
     /**
     *  ACR-2255, set certification asset expiration date per ceritifcation type after memebership pass the exam.
     *  @ Jun 11, 2020, Ray
     */

    public void setupCertificationAssetExpirationDateAfterPassExam(List<Exam_Results__c> newList, Map<Id, Exam_Results__c> oldMap){
        Set<Id> examResultIds = new Set<Id>();
        List<Asset> assetList = new List<Asset>();
        
        if(newList != null && newList.size() > 0){
            for(Exam_Results__c er : newList){
                if(Trigger.isUpdate && oldMap.get(er.Id) != null && oldMap.get(er.Id).Result__c != er.Result__c && er.Result__c == 'Pass' && er.Test_Date__c != null){
                    examResultIds.add(er.Id);
                }
                else if(Trigger.isInsert && er.Result__c == 'Pass' && er.Test_Date__c != null){
                    examResultIds.add(er.Id);
                }
            }


            assetList = [SELECT Id,Exam_Pass_Date__c,CurrentExpirationDate__c,CC_Product__r.Level_2__c,ExamResult__c 
                        FROM Asset
                        WHERE ExamResult__c IN: examResultIds];


            /**
             * update asset expiration data
             */
            for(Asset a : assetList){
                if(a.CC_Product__r.Level_2__c != null && String.valueOf(a.CC_Product__r.Level_2__c).contains('CAMS')){
                    // +3 years
                    if(a.Exam_Pass_Date__c != null){
                        a.CurrentExpirationDate__c = a.Exam_Pass_Date__c.addYears(3);
                    }
                }
                else if(String.valueOf(a.CC_Product__r.Level_2__c).equals('CGSS')){
                    if(a.Exam_Pass_Date__c != null){
                        a.CurrentExpirationDate__c = a.Exam_Pass_Date__c.addYears(3);
                    }
                }

                else if(String.valueOf(a.CC_Product__r.Level_2__c).equals('CKYCA')){
                    if(a.Exam_Pass_Date__c != null){
                        a.CurrentExpirationDate__c = a.Exam_Pass_Date__c.addYears(1);
                    }
                }
                
            }
        }
        
        if(assetList != null && assetList.size() > 0){
            update assetList;
        }
        return;
    }
}