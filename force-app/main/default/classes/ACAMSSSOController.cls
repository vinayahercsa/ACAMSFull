global without sharing class ACAMSSSOController {
    global String username { get; set; }
    global String password { get; set; }
    public String relaystate { get; set; }
    public String url { get; set; }
    public String decodedUrl { get; set; }
    public String appName;
    public String hubbRelaystate;
    public String pgtype { get; set; }
    public String pg { get; set; }
    public Boolean isLoginFailed { get; set; }
    public String registerPage { get; set; }
    public String passwordresetPage { get; set; }
    public boolean notDrupal { get; set; }
    public boolean errorHit{ get; set; }
    public boolean errorHitEP{ get; set; }
    public boolean errorHitInv{ get; set; }
    public String langValue {get; set;}
    public User usr;
    public User usrlst;
    
    public String drupalUrl = '';
    public String drupalRegisterUrl = '';
    
    
    global ACAMSSSOController(ApexPages.StandardController stdCtrl) {
         usr=(user) stdCtrl.getRecord();
        isLoginFailed = false;
        notDrupal = true;
        pgtype = '';
        errorHit = false;
        errorHitEP=false;
        errorHitInv=false;
        url = System.currentPageReference().getUrl();
        decodedUrl =  EncodingUtil.urlDecode(url, 'UTF-8'); 
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
        pgtype = System.currentPageReference().getParameters().get('page');
        pg = System.currentPageReference().getParameters().get('pg');
        if(AppName == 'Drupal_SSO_Local' || AppName == 'Drupal_SSO' || AppName == 'Drupal_Pantheon_SSO'){
            notDrupal= false;
        }
        
        registerPage = '/acams/ACAMS_RegistrationPage?AppName='+appName +'&relaystate='+relaystate+'&language='+langValue;
        passwordresetPage = '/acams/ACAMS_ForgotPassword?AppName='+appName +'&relaystate='+relaystate+'&language='+langValue;
        /*   // if (appName == null && pg == null) {
// appName = 'Hubb_SSO';      //  default app name
//  hubbRelaystate =decodedUrl.substringAfter('RelayState=');
//   system.debug(hubbRelaystate);
//  } else
if (appName == 'lms') {
registerPage += '?page=lms';
}
getDrupalInfo();
}
*/
        /*       if (appName == null && pg == null) {
appName = 'Hubb_SSO';      //  default app name
hubbRelaystate =decodedUrl.substringAfter('RelayState=');
system.debug(hubbRelaystate);
} else if (appName == 'lms') {
registerPage += '?page=lms';
}
*/
        getDrupalInfo();
    }
    global PageReference redirect() {
        if (UserInfo.getUserType() != 'Guest') {
            return login();
        }
        return null;
    }
    
    global PageReference login() {
           

    
        ACAMSUserLogin.LoginResponse loginResponse;
        String rUrl = getRelayUrl();
        system.debug(rUrl);
        String startUrl = System.currentPageReference().getParameters().get('startUrl');
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String domain = isSandbox ? 'test' : 'login';
      //  loginResponse = ACAMSUserLogin.login(username, password, domain);
 
        /*
if ((String.isBlank(startUrl) || !String.isBlank(rUrl)) && pg == null) {
startUrl = '/CommunitiesLanding';
} else if (String.isBlank(startUrl) && pg != null) {
startUrl = '/' + pg;
}
*/
        if ((String.isBlank(startUrl) || !String.isBlank(rUrl)) && pg == null) {
            if (appName != null ){
                startUrl = rUrl;
                
            }else{
                startUrl = '/idp/login?app=' + label.Drupal_SSO;
            }
        } else if (String.isBlank(startUrl) && pg != null) {
            startUrl = '/' + pg;
        } 
        //  Redirect if User Already Logged in
        PageReference pageRef;
        if (UserInfo.getUserType() == 'Guest') {
                      if (username == '' || username == null){

            errorHit = true;
        }
            else{
               errorHit = false; 
            }
    if (password == '' || password == null){

            errorHit = true;
        }
            else{
                errorHit = false;
            }
                                     if(username != ''){
        if(!Pattern.matches('([a-zA-Z0-9_\\-\\.+]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))', username))
        {
            
            errorHitInv = true;
            
        }
                        
         }
                 else{
                                 errorHitInv = false;
                             }
            if(username!='' && password !=''){
                         if(username != ''){
        if(!Pattern.matches('([a-zA-Z0-9_\\-\\.+]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))', username))
        {
            
            errorHitInv = true;
            
        }
                          
         }
                   else{
                                 errorHitInv = false;
                             }   
            pageRef = Site.login(username, password, startUrl);
                
                if(pageRef == null){
            errorHitEP = true;
                }
                else{
                    errorHitEP = false;
                }
                
            }
        } else {
            pageRef = new PageReference(startUrl);
        }

                 if(errorHit){
            return null;   
        }  
        return pageRef;
    }
    public String getRelayUrl() {
        String relaySubstr;
        String relayString = '';
        
        try {
            IDP_App_ID__mdt[] IDP_App_IDs = [
                SELECT
                MasterLabel,
                External_ACAMS_IDPAppID_ID__c,
                ID__c,
                Long_Name__c,
                Source_IDP_App_ID_ID__c
                FROM IDP_App_ID__mdt
                WHERE MasterLabel = :appName
                LIMIT 1
            ];
            String idpID = '';
            if (!IDP_App_IDs.isEmpty()) {
                idpID = IDP_App_IDs[0].ID__c;
            }
            String idpStart = '/idp/login?app=' + idpID; // IdP initiated URL provided by SFDC
            if(hubbRelaystate != null){
                relaySubstr = '&RelayState=' + hubbRelaystate;
            }
            else{
                relaySubstr = '&RelayState=' + relaystate;
            }
            if (relaySubstr != '&RelayState=null') {
                relayString = idpStart + relaySubstr; // add the relay state
            } else {
                relayString = idpStart;
            }
        } catch (Exception x) {
            System.debug('Error: ' + x.getMessage());
        }
        
        return relayString;
    }
    /*  public String getRelayUrl() {
String relaySubstr;
String relayString = '';

try {
IDP_App_ID__mdt[] IDP_App_IDs = [
SELECT
MasterLabel,
External_ACAMS_IDPAppID_ID__c,
ID__c,
Long_Name__c,
Source_IDP_App_ID_ID__c
FROM IDP_App_ID__mdt
WHERE MasterLabel = :appName
LIMIT 1
];
String idpID = '';
if (!IDP_App_IDs.isEmpty()) {
idpID = IDP_App_IDs[0].ID__c;
}
String idpStart = '/idp/login?app=' + idpID; // IdP initiated URL provided by SFDC
if(hubbRelaystate != null){
relaySubstr = '&RelayState=' + hubbRelaystate;
}
else{
relaySubstr = '&RelayState=' + relaystate;
}
if (relaySubstr != '&RelayState=null') {
relayString = idpStart + relaySubstr; // add the relay state
} else {
relayString = idpStart;
}
} catch (Exception x) {
System.debug('Error: ' + x.getMessage());
}

return relayString;
} */
    
    public void getDrupalInfo() {
        try {
            Drupal_URLs__mdt[] drupalUrls = [
                SELECT
                MasterLabel,
                Drupal_URL__c,
                Drupal_URL_Register__c
                FROM
                Drupal_URLs__mdt
                LIMIT
                1
            ];
            
            if (!drupalUrls.isEmpty()) {
                drupalUrl = drupalUrls[0].Drupal_URL__c;
                drupalRegisterUrl = drupalUrls[0].Drupal_URL_Register__c;
            }
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    public String getDrupalUrl() {
        return drupalUrl;
    }
    
    public String getDrupalRegisterUrl() {
        return drupalRegisterUrl;
    }
       public PageReference refreshPage() {
               if(usr.Interface_Language__c!= null){
            langValue=usr.Interface_Language__c;
        }
  
             registerPage = '/acams/ACAMS_RegistrationPage?AppName='+appName +'&relaystate='+relaystate+'&language='+langValue;
        passwordresetPage = '/acams/ACAMS_ForgotPassword?AppName='+appName +'&relaystate='+relaystate+'&language='+langValue;
         
      
        return null;
    }
}