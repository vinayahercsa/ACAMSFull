public class ACAMS_ForgotPasswordController {
  public String username {get; set;}   
    Public boolean renderconfirm {get; set;}
    public boolean DisplayPopup {get; set;} 
    public String relaystate { get; set; }
    public String appName;
    public String signinPage { get; set; }
    public String langValue {get; set;}
     public boolean notDrupal { get; set; }
    public User usr;
    
    
    public ACAMS_ForgotPasswordController(ApexPages.StandardController stdCtrl) {
         usr=(user) stdCtrl.getRecord();
        relaystate = System.currentPageReference().getParameters().get('RelayState');
        appName = System.currentPageReference().getParameters().get('AppName');
         langValue = System.currentPageReference().getParameters().get('Language');
       if(langValue!=null){
            langValue=ACAMS_RegistrationPageController.getLangValues(langValue);
            usr.Interface_Language__c=langValue;
        }
            else if(usr.Interface_Language__c!= null){
            langValue=usr.Interface_Language__c;
        }
                   notDrupal = true;
        if(AppName == 'Drupal_SSO_Local' || AppName == 'Drupal_SSO' || AppName == 'Drupal_Pantheon_SSO'){
            notDrupal= false;
        }
        
        signinPage = '/acams/ACAMSSiteLogin?AppName='+appName +'&relaystate='+relaystate+'&language='+langValue;
    }
    
    public PageReference forgotPassword() {
        if(username == null || username == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,Label.forgotpwd_The_email_address_is_not_valid));
            
        }
        else if(username != null || username != '') {
            
            
            List<User> usr = New List<User>();
            system.debug(username);
            usr = [select username,email from user where email =: username  limit 1];
            if(usr.size() == 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,Label.forgotpwd_The_email_address_is_not_valid));
                
            }
            else{
                renderconfirm = Site.forgotPassword(username);
                
                
            }
        }
        
        return null;
    }
    public void ClosePopup() {       
        DisplayPopup = false;   
    }
    
    public void ShowPopup() {       
        DisplayPopup = true;   
    }
       public PageReference refreshPage() {
           if(usr.Interface_Language__c!= null){
            langValue=usr.Interface_Language__c;
        }
           signinPage = '/acams/ACAMSSiteLogin?AppName='+appName +'&relaystate='+relaystate+'&language='+langValue;
        return null;
    }
}