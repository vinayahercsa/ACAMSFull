public class ACAMSRegionFundingTriggerHandler extends CCAviTriggerHandler{
    private List<Regional_Funding__c> newList = (List<Regional_Funding__c>) Trigger.new;
    /**
     * constructor
     */
    public ACAMSRegionFundingTriggerHandler() {

    }

    /***
     * @description before insert
     * @ May 18, 2020 Ray
     */
    public override void beforeInsert(){
        updateRegionFundingStatus();
    }


    /**
     * @description before update
     */
     public override void beforeUpdate(){
        updateRegionFundingStatus();
     }

     /**
      * @description after update
      */
      public override void afterUpdate(){
        updateRelatedAssets();
      }

      /***
       * @description after insert
       */
       public override void afterInsert(){
        updateRelatedAssets();
       }


       /**
        * @ update related asset.SG_AML_REGIME_Exam_Application_Approved__c when Region funding
        * status is 'Exam App Approved'
        */
        private void updateRelatedAssets(){
            /***
             * asset records Id - asset need to update
             */
            Set<Id> rgfContactIds = new Set<Id>();

            for(Regional_Funding__c r : newList){
                if(r.Status__c == 'Exam App Approved'){
                    rgfContactIds.add(r.Contact__c);
                }
            }

            List<Asset> assetList = [SELECT id, Assignee__c,SG_AML_REGIME_Exam_Application_Approved__c from Asset where Assignee__c in : rgfContactIds and Paid_Cert__c = true and Status__c = 'Active' and Name =: 'Certifications' and Enterprise_Product_HL__c  =: 'SG-AML-Regime' ORDER BY CreatedDate desc LIMIT 1];
            for(asset a : assetList){
                a.SG_AML_REGIME_Exam_Application_Approved__c = true;
            }

            if(assetList != null && assetList.size() > 0){
                update assetList;
            }

        }

         /***
         * @Description before udpate regtion funding status field
         */
        private void updateRegionFundingStatus(){
            List<Regional_Funding__c> Reg=New List<Regional_Funding__c>();
            Regional_Funding__c regFnd = newList[0];
            if(regFnd.Passed_AML_Regime_Exam_Date__c!=null && regFnd.Passed_CAMS_Exam_Date__c!=null && regFnd.Status__c == null) {
                regFnd.Status__c = 'Both Exam Passed';
            }

            if(regFnd.Funding_Application_Submitted_to_IBF_by__c==true) {
                regFnd.Status__c = 'Funding Application Submitted to IBF';
                regFnd.ACAMS_Submission_Date__c=system.today();
            }else if(regFnd.Funding_Application_Submitted_to_IBF_by__c==false){
                regFnd.ACAMS_Submission_Date__c=null;
            }
            
            if(regFnd.Check_Received_by_ACAMS__c==true){
                regFnd.Status__c = 'Cheque Received by ACAMS';
                regFnd.Check_Received_Date__c=system.today();
            }else if(regFnd.Check_Collected_by_Candidate__c==false){
                regFnd.Cheque_Collected_by_Candidate_Date__c=null;
           }
        }
}