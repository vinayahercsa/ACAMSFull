/*
 Controller for ScheduleExam Page 
* Has all the data from Exam Result to facilitate single sign on process with PearsonVue
*/ 
public class ScheduleExamController {
    
     public String clientCode{get;set;}
     public String clientCandidateId{get;set;}
     public String vueCandidateId{get;set;}
     public String logoutURL{get;set;}
     public String returnURL{get;set;}
    public String errorURL{get;set;}
     public String conct{get;set;}
    public String examseriescode{get;set;}
     public String privateAccessCode{get;set;}
     private User loggedInUser = new User();
    public String ts{get;set;}
    public String exam{get;set;}
    public String locale{get;set;}
    public static Integer timeout{get;set;} 
    public Blob targetBlob{get;set;}
    public Blob hash{get;set;} 
    public Date today;
      private List<Exam_Results__c> IsCAMSExamResults = new List<Exam_Results__c>();
    private Exam_Results__c IsCAMSExamResult = new Exam_Results__c();
      private List<Exam_Results__c> IsCGSSExamResults = new List<Exam_Results__c>();
    private Exam_Results__c IsCGSSExamResult = new Exam_Results__c();
    private List<Exam_Results__c> IsRegimeExamResults = new List<Exam_Results__c>();
    private Exam_Results__c IsRegimeExamResult = new Exam_Results__c();
    private List<Exam_Results__c> IsSGAMLExamResults = new List<Exam_Results__c>();
    private Exam_Results__c IsSGAMLExamResult = new Exam_Results__c();
    private List<Exam_Results__c> PVExamResults = new List<Exam_Results__c>();
    private Exam_Results__c PVExamResult = new Exam_Results__c();
    public PearsonVueIntegration__c pv = PearsonVueIntegration__c.getOrgDefaults();
    public  String hmac{get;set;} 
    public ScheduleExamController(){
        today = system.today();
        if(ApexPages.currentPage().getParameters().containsKey('exam'))    {
            if(ApexPages.currentPage().getParameters().get('exam') != null && ApexPages.currentPage().getParameters().get('exam') != '')    {
                exam = ApexPages.currentPage().getParameters().get('exam');
            }
         }
        loggedInUser = [select id, ContactId,AccountId, account.Pearson_Vue_ID__pc,account.Locale_for_PearsonVUE__pc from User where id = :UserInfo.getUserId()];
        IsCAMSexamresults = [SELECT Id, Test_Date__c,Result__c,Private_access_code__c,examSeriesCode__c FROM Exam_Results__c WHERE Contact__c = :loggedInUser.AccountId AND examSeriesCode__c !='SG_AML' AND Product_level_2__c != 'CGSS' AND PearsonVUE__c =: true ORDER BY CreatedDate desc LIMIT 1];
        IsCAMSexamresult = (IsCAMSexamresults != NULL &&  IsCAMSexamresults.size()>0 ?  IsCAMSexamresults[0] : NULL);
        
        IsSGAMLexamresults = [SELECT Id, Test_Date__c,Result__c,Private_access_code__c,examSeriesCode__c FROM Exam_Results__c WHERE  Contact__c = :loggedInUser.AccountId AND examSeriesCode__c =:'SG_AML'AND PearsonVUE__c =: true ORDER BY CreatedDate desc LIMIT 1];
        IsSGAMLexamresult = (IsSGAMLexamresults != NULL &&  IsSGAMLexamresults.size()>0 ?  IsSGAMLexamresults[0] : NULL);
        
           IsRegimeExamResults = [SELECT Id, Test_Date__c,Result__c,Private_access_code__c,examSeriesCode__c FROM Exam_Results__c WHERE  Contact__c = :loggedInUser.AccountId AND examSeriesCode__c =:'IN_AML'AND PearsonVUE__c =: true ORDER BY CreatedDate desc LIMIT 1];
        IsRegimeExamResult = (IsRegimeExamResults != NULL &&  IsRegimeExamResults.size()>0 ?  IsRegimeExamResults[0] : NULL);
        
        
         IsCGSSexamresults = [SELECT Id, Test_Date__c,Result__c,Private_access_code__c,examSeriesCode__c FROM Exam_Results__c WHERE  Contact__c = :loggedInUser.AccountId  AND Product_level_2__c =: 'CGSS' AND PearsonVUE__c =: true ORDER BY CreatedDate desc LIMIT 1];
        IsCGSSexamresult = (IsCGSSexamresults != NULL &&  IsCGSSexamresults.size()>0 ?  IsCGSSexamresults[0] : NULL);
         if(exam =='cams'){
            examseriescode = IsCAMSexamresult.examSeriesCode__c;
             privateAccessCode = IsCAMSexamresult.Private_access_code__c;
        }   
        else if(exam =='sgaml'){
            examseriescode = IsSGAMLexamresult.examSeriesCode__c;
            privateAccessCode = IsSGAMLexamresult.Private_access_code__c;
        }
         else if(exam =='cgss'){
             if(IsCGSSexamresult.examSeriesCode__c!=null)
            examseriescode = IsCGSSexamresult.examSeriesCode__c;
             if(IsCGSSexamresult.Private_access_code__c!=null)
            privateAccessCode = IsCGSSexamresult.Private_access_code__c;
        }
         else if(exam =='inaml'){
             if(IsRegimeExamResult.examSeriesCode__c!=null)
            examseriescode = IsRegimeExamResult.examSeriesCode__c;
             if(IsRegimeExamResult.Private_access_code__c!=null)
            privateAccessCode = IsRegimeExamResult.Private_access_code__c;
        }

      /*      PVExamResults = [SELECT Id, Test_Date__c,Result__c,Private_access_code__c,examSeriesCode__c FROM Exam_Results__c WHERE Contact__c = :loggedInUser.ContactId AND PearsonVUE__c =: true  ORDER BY CreatedDate desc LIMIT 1];
        PVExamResult = (PVExamResults != NULL &&  PVExamResults.size()>0 ?  PVExamResults[0] : NULL);
      privateAccessCode = PVExamResult.Private_access_code__c;
*/
       timeout = 600;
        ts = String.Valueof((dateTime.now().getTime())/1000);
        locale = loggedInUser.Account.Locale_for_PearsonVUE__pc;
        clientCandidateId = loggedInUser.AccountId;
        clientCode = pv.Client_Code__c;
        logoutURL = pv.Logout_URL__c;
        returnURL = pv.Return_URL__c;
        errorURL = pv.Error_URL__c;
        //vueCandidateId = loggedInUser.Contact.Pearson_Vue_ID__c;
        conct = pv.SSO_Password__c + pv.Client_Code__c + ts + timeout + clientCandidateId ;
        system.debug(conct);
        targetBlob = Blob.valueOf(conct);
   
        hash = Crypto.generateDigest('SHA-256', targetBlob);
      //hmac = EncodingUtil.urlEncode(EncodingUtil.convertToHex(hash), 'UTF-8').replaceAll('\\r\\n', '');
      hmac = EncodingUtil.convertToHex(hash);
        system.debug(hmac);
       
        
       
    }

}