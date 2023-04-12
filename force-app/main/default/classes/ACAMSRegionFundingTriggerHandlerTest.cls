@IsTest
public with sharing class ACAMSRegionFundingTriggerHandlerTest {
    @IsTest
    public static void createRegionFundingWithUpdate(){
        List<Regional_Funding__c> rfList = new List<Regional_Funding__c>{
            new Regional_Funding__c(Passed_AML_Regime_Exam_Date__c=System.today(), Passed_CAMS_Exam_Date__c=System.today(),
            Funding_Application_Submitted_to_IBF_by__c=true)
        };

        insert rfList;

        for(Regional_Funding__c rf : rfList){
            rf.Funding_Application_Submitted_to_IBF_by__c = true;
        }
        update rfList;
        //System.assertEquals('Funding Application Submitted to IBF', rfList[0].Status__c);

        for(Regional_Funding__c rf : rfList){
            rf.Funding_Application_Submitted_to_IBF_by__c = false;
        }
        update rfList;
        System.assertEquals(null, rfList[0].ACAMS_Submission_Date__c);

        for(Regional_Funding__c rf : rfList){
            rf.Check_Received_by_ACAMS__c = true;
        }
        update rfList;
        System.assertEquals(null, rfList[0].Check_Received_Date__c);

        for(Regional_Funding__c rf : rfList){
            rf.Check_Received_by_ACAMS__c = false;
        }
        update rfList;
        
    }
}