public class ACAMS_ChangePasswordController {
  public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}  
     public String langValue {get; set;}
     public boolean notDrupal { get; set; }
      public String appName;
    public User usr;
    
     public ACAMS_ChangePasswordController(ApexPages.StandardController stdCtrl) {
          usr=(user) stdCtrl.getRecord();
         appName = System.currentPageReference().getParameters().get('AppName');
             notDrupal = true;
        if(AppName == 'Drupal_SSO_Local' || AppName == 'Drupal_SSO'){
            notDrupal= false;
        }
      
      if(langValue!=null){
            langValue=ACAMS_RegistrationPageController.getLangValues(langValue);
            usr.Interface_Language__c=langValue;
        }
            else if(usr.Interface_Language__c!= null){
            langValue=usr.Interface_Language__c;
        }
        
    }
    public PageReference changePassword() {
          Boolean errorHit = false;
           if (newPassword == '' || newPassword == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.changepwd_New_Password +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
    if (verifyNewPassword == '' || verifyNewPassword == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.changepwd_Confirm_Password +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        String passowrdregex = '((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%!&^*_]).{8,20})';
        Pattern passwordPattern = Pattern.compile(passowrdregex);
        Matcher PwdMatcher = passwordPattern.matcher(verifyNewPassword);
         if(!PwdMatcher.matches() )
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_Your_Password_does_not_contain_the_required_criteria);
            ApexPages.addMessage(msg);
            errorHit = true; 
             
        }
      if(errorHit){
            return null;   
        }    
         langValue = System.currentPageReference().getParameters().get('Language');
        if(langValue!=null){
            langValue=ACAMS_RegistrationPageController.getLangValues(langValue);
        }
       Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
         
      pagereference ref =new pagereference(label.SF_Base_URL);//Paste your vfpage name
          ref.setredirect(true);
          return ref;
        /*  
        return Site.Login(Userinfo.getUsername(), newPassword, '/idp/login?app=' + label.Drupal_SSO);
        */
        
    }  
       public PageReference refreshPage() {
           if(usr.Interface_Language__c!= null){
            langValue=usr.Interface_Language__c;
        }
        return null;
    }
    

}