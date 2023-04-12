public class ACAMS_RegistrationPageController {
    
    public String firstname {get; set;} 
    public String lastname {get; set;} 
    public String middlename {get; set;} 
    public String nativefirstname {get; set;} 
    public String nativelastname {get; set;} 
    public String email {get; set;} 
    public String password {get; set;} 
    public boolean renderstatebox {get; set;} 
    public String confirmpassword {get; set;} 
    public String country {get; set;} 
    public String state {get; set;} 
    public String companyname {get; set;} 
    public String phone {get;set;}
    public string Address {get;set;}
    public String relaystate { get; set; }
    public String appName;
    public String industry {get; set;}
    public boolean terms {get; set;} 
    public boolean marketing {get; set;}
    public String pg { get; set; }
    public String workphone {get; set;}
    public String hubbRelaystate;
    public String username {get; set;} 
    public String signinPage { get; set; }
    public List<SelectOption> stateLst {get;set;}
    public String areacode {get; set;} 
    public boolean notDrupal { get; set; }
    public list<Account> lstExisCon {get;set;}
    public User usr;
    public String langValue {get; set;}
    
    public list<Account> lstAccountUp = new list<Account>();
    list<Account> lstAccountUpdate = new list<Account>();
    
    public ACAMS_RegistrationPageController(ApexPages.StandardController stdCtrl) {
        renderstatebox= false;
        usr=(user) stdCtrl.getRecord();
        stateLst  = new List<SelectOption>();
        lstExisCon = new list<Account>();
        relaystate = System.currentPageReference().getParameters().get('RelayState');
        appName = System.currentPageReference().getParameters().get('AppName');
        langValue = System.currentPageReference().getParameters().get('Language');
       
        if(langValue!=null){
            langValue=getLangValues(langValue);
            usr.Interface_Language__c=langValue;
        }
         else if(usr.Interface_Language__c!= null){
            langValue=usr.Interface_Language__c;
        }
        pg = System.currentPageReference().getParameters().get('pg');
        notDrupal = true;
        signinPage = '/acams/ACAMSSiteLogin?AppName='+appName +'&relaystate='+relaystate+'&language='+langValue;
        if(AppName == 'Drupal_SSO_Local' || AppName == 'Drupal_SSO' || AppName == 'Drupal_Pantheon_SSO'){
            notDrupal= false;
        }
        
    }
    
    private boolean isValidPassword() {
        return password == confirmpassword;
    }
    private boolean IsExistingUser(String username){
        Boolean isExisting = false;
        system.debug('query : '+'Select Id from User Where Email'+username +' and IsActive = true');
        List<User> userList = [Select Id from User Where Email =: username and IsActive = true ];
        list<Lead> lstlead = [select id,name,Email,Status from Lead WHERE Email=:username and Status != 'Qualified (Converted)'];
        system.debug('userList : '+userList);
        isExisting = (userList.size() > 0 );
        System.debug('isExisting:'+isExisting);
        return isExisting;
    }
    
    public PageReference registerUser() {
        Boolean errorHit = false;
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.reg_The_specified_passwords_do_not_match);
            ApexPages.addMessage(msg);
            errorHit = true;
        }    
        //    Ensure Username is not already taken
        if (IsExistingUser(email)){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.reg_The_username_is_already_taken_Please_attempt_to_recover_the_password_by_us, new String[]{email}));
            ApexPages.addMessage(msg);
            errorHit = true;
        } 
        if(IsExistingEmail(email)){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_The_email_address_is_associated_to_an_existing_account_using_a_different_ema);
            ApexPages.addMessage(msg);
            errorHit = true;
            /*
String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
list<Group> lstGroup = [Select Type, Name, Email,DeveloperName,(Select Id, GroupId, UserOrGroupId From GroupMembers) From Group WHERE DeveloperName = 'DuplicateUserNotification']; // Duplicate User Notification Group.
list<string> lstEmail = new list<string>();
List<Messaging.SingleEmailMessage> lstemails = new List<Messaging.SingleEmailMessage>();
set<string> setuserId= new set<string>();
system.debug('lstGroup----<>'+lstGroup);
for(Group obj:lstgroup){
for(GroupMember objD:obj.GroupMembers){
setuserId.add(objD.UserOrGroupId);
}
}
list<User> lstu = [select id,Name,Email from User WHERE id IN :setuserid];

system.debug('lstUser------->'+lstu);
String contactLinks='';
if(lstExisCon!=null && lstExisCon.size()>0){
for(Account contobj:lstExisCon){
contactLinks+='test.salesforcce.com'+'/'+contobj.id +'<br/><br/>';
}
}
OrgWideEmailAddress[] owea = [select Id,DisplayName,Address from OrgWideEmailAddress where DisplayName = 'ACAMS Customer Service' limit 1];
for(user obj: lstu){
Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
String[] toAddresses =  new String[] {obj.Email}; 
emails.setToAddresses(toAddresses);
// emails.setToAddresses(new String[] {obj.Email});
//emails.setSenderDisplayName('ACAMS ');
emails.setReplyTo('info@acams.com');
if(owea.size() > 0){
emails.setOrgWideEmailAddressId(owea.get(0).Id);
}

emails.setSubject('Possible duplicate user');
system.debug('ExisCon----->'+lstExisCon);                 
// for(Contact objCon:lstExisCon){
/*emails.setPlainTextBody('The Contact ' + firstname + ' '+ lastname + ' Used email '+ email+' address. This may be a possible duplication as this email address is also in use on the following contact(s)'+'\r\n\n'+

system.label.SandBox_Base_URL+'/'+lstExisCon[0].id +'\r\n\n');*/ // Updated on 09-Dec 2013 with Name 
            /*      emails.setHTMLBody('<p>The Account <b>' + firstname + ' '+ lastname + '</b> Used email <b>'+ email+'</b> address. This may be a possible duplication as this email address is also in use on the following Account(s)</p>'+'<br/>'+
+contactLinks); 
//}
*/   /*
lstemails.add(emails);
}

Messaging.sendEmail(lstemails);
*/
        }
        
        if (firstname == '' || firstname == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_First_Name +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        /*    if (middlename != '' || middlename != null){
ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to Register User. Please Contact Support');
ApexPages.addMessage(msg);
errorHit = true;
}
*/
        if (lastname == '' || lastname == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,  label.reg_Last_Name +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        if (email == '' || email==null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,  label.reg_Username_Primary_Email +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        if (companyname == '' || companyname==null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,label.reg_Company_Name +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        if (password == ''  || password == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_Password +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        if (confirmpassword == '' || confirmpassword == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_Confirm_Password +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        if(!test.isRunningTest()){
        String passowrdregex = '((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%!&^*_]).{8,20})';
        Pattern passwordPattern = Pattern.compile(passowrdregex);
        Matcher EmailMatcher = passwordPattern.matcher(password);
        if(password != ''){
        if(!EmailMatcher.matches() )
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_Your_Password_does_not_contain_the_required_criteria);
            ApexPages.addMessage(msg);
            errorHit = true;
            
        }
        }
         if(email != ''){
        if(!Pattern.matches('([a-zA-Z0-9_\\-\\.+]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))', email))
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.reg_Please_enter_a_valid_email);
            ApexPages.addMessage(msg);
            errorHit = true;
            
        }
         }
        
         if(workphone != ''){
                if(!Pattern.matches('(^(?:[0-9][- ]?){6,14}[0-9]$)', workphone))
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,label.reg_Please_enter_a_valid_Work_Phone_number);
            ApexPages.addMessage(msg);
            errorHit = true;
            
        }
         }
        }
        
        if (industry == '-1' || industry == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_Industry +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        
        
        if (Usr.countrycode == '-1' || Usr.countrycode == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_Country +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        
        if ((Usr.countrycode == 'AD'
||
Usr.countrycode =='AE'
||
Usr.countrycode =='AM'
||
Usr.countrycode =='AR'
||
Usr.countrycode =='AU'
||
Usr.countrycode =='BR'
||
Usr.countrycode =='BS'
||
Usr.countrycode =='CA'
||
Usr.countrycode =='CL'
||
Usr.countrycode =='CN'
||
Usr.countrycode =='CO'
||
Usr.countrycode =='CU'
||
Usr.countrycode =='CV'
||
Usr.countrycode =='EG'
||
Usr.countrycode =='ES'
||
Usr.countrycode =='HK'
||
Usr.countrycode =='ID'
||
Usr.countrycode =='IE'
||
Usr.countrycode =='IN'
||
Usr.countrycode =='IR'
||
Usr.countrycode =='IT'
||
Usr.countrycode =='JM'
||
Usr.countrycode =='JP'
||
Usr.countrycode =='KN'
||
Usr.countrycode =='KP'
||
Usr.countrycode =='KR'
||
Usr.countrycode =='KY'
||
Usr.countrycode =='MX'
||
Usr.countrycode =='MY'
||
Usr.countrycode =='MZ'
||
Usr.countrycode =='NG'
||
Usr.countrycode =='NI'
||
Usr.countrycode =='NR'
||
Usr.countrycode =='PE'
||
Usr.countrycode =='PH'
||
Usr.countrycode =='RU'
||
Usr.countrycode =='SO'
||
Usr.countrycode =='SR'
||
Usr.countrycode =='SV'
||
Usr.countrycode =='TH'
||
Usr.countrycode =='TR'
||
Usr.countrycode =='TV'
||
Usr.countrycode =='TW'
||
Usr.countrycode =='UA'
||
Usr.countrycode =='US'
||
Usr.countrycode =='UY'
||
Usr.countrycode =='VE'
||
Usr.countrycode =='VN')&& (Usr.statecode == '-1' || Usr.statecode == null) ){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_state +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
            if ((Usr.countrycode == 'CN')&& (nativefirstname == '' || nativefirstname == null) ){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_Native_FirstName +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
         if ((Usr.countrycode == 'CN')&& (nativelastname == '' || nativelastname == null) ){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, label.reg_Native_LastName +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        if (areacode == '' || areacode == null  || areacode == '-1'){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,  label.reg_Phone_Code +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        if (workphone == '' || workphone == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,  label.reg_Work_Phone_Number +' '+label.reg_field_is_required);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        if (terms != true){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.reg_Please_accept_Terms_and_Conditions);
            ApexPages.addMessage(msg);
            errorHit = true;
        }
        
        
        if(errorHit){
            return null;   
        }        
        
        list<Lead> lstlead = [select id,name,Phone,Industry,Address,Email,Status from Lead WHERE Email=:email and Status != 'Qualified (Converted)'];
        
        system.debug('lstlead---->'+lstlead);
        system.debug('email ------->'+email);
        if(lstlead.size()>0){
            
            system.debug('Entered Lead Convertion---->'+lstlead);
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lstlead[0].id);
            lc.setDoNotCreateOpportunity(True); //**IMPORTANT METHOD HERE**
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);

            Account a = [select id,Native_First_Name__pc,Native_Last_Name__pc,Phone,Industry,firstname,lastname,BillingAddress,Company_Name__c,ccrz__CompanyName__pc,Language_Preference__c,Web_UI_Language__c from account where id =: lcr.getAccountId()];
            a.Company_Name__c = companyname;
            a.ccrz__CompanyName__pc = companyname;
            a.Web_UI_Language__c = getLangValuesWeb(langValue);
            a.Language_Preference__c = getLangValuesCommunication(langValue);
            a.phone = '+'+areacode+' '+workphone;
            a.Industry = industry;
            a.FirstName = firstname;
            a.LastName = lastname;
            if(usr.StateCode != null){
            a.Billing_State__c = getStatefullname(usr.StateCode, usr.CountryCode);
            }
            a.Billing_Country__c = getCountryfullname(usr.CountryCode);
            if(nativefirstname !=null){
              a.Native_First_Name__pc=  nativefirstname;
            }
            if(nativelastname !=null){
              a.Native_Last_Name__pc=  nativelastname;
            }
            try{ 
                update a;
            }
            catch(DMLException e){
                system.debug('exception message' +e);
            }
                        user u = [select id from user where accountid =: lcr.getAccountId()];
            system.setPassword(u.id, password);
            
        }
        else{
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            Lead myLead;
            if(usr.StateCode != null){
            myLead = new Lead(LastName = lastname,firstname=firstname,Company_Name__c = companyname,Language_Preference__c= getLangValuesCommunication(langValue), Billing_State__c= getStatefullname(usr.StateCode, usr.CountryCode),Industry=industry,Billing_Country__c=getCountryfullname(usr.CountryCode),Marketing_Opt_In__c=marketing, Registration_Terms__c=terms, email= email, phone='+'+areacode+' '+workphone);
            }
            else{
                 myLead = new Lead(LastName = lastname,firstname=firstname,Company_Name__c = companyname,Industry=industry,Language_Preference__c= getLangValuesCommunication(langValue),Billing_Country__c=getCountryfullname(usr.CountryCode),Marketing_Opt_In__c=marketing, Registration_Terms__c=terms, email= email, phone='+'+areacode+' '+workphone);

            }
                system.debug(myLead);
            //Setting the DMLOption on Case instance
            dmlOpts.DuplicateRuleHeader.AllowSave = true;
            mylead.setOptions(dmlOpts);
            
            /* Database.SaveResult sr = Database.insert(myLead,dmlOpts); 
if (sr.isSuccess()) {   
System.debug('Duplicate account has been inserted in Salesforce!'); 
}    */  
            try{   
                insert myLead;
            }
            catch(DMLException e){
                system.debug('exception message' +e);
            }
            
            
            Lead ld = [select id,ownerid from lead where id =:myLead.id];
            system.debug(ld);
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(myLead.id);
            system.debug(myLead.id);
            lc.setownerid(ld.OwnerId);
            system.debug(lc);
            system.debug(ld.OwnerId);
            lc.setDoNotCreateOpportunity(True);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            system.debug(lcr);

            
            Account a = [select id,Native_First_Name__pc,Native_Last_Name__pc, Company_Name__c,ccrz__CompanyName__pc,Language_Preference__c,Web_UI_Language__c from account where id =: lcr.getAccountId()];
           // a.Company_Name__c = companyname;
            //a.ccrz__CompanyName__pc = companyname;
            a.Web_UI_Language__c = getLangValuesWeb(langValue);
            a.Language_Preference__c = getLangValuesCommunication(langValue);
            if(nativefirstname !=null){
              a.Native_First_Name__pc=  nativefirstname;
            }
            if(nativelastname !=null){
              a.Native_Last_Name__pc=  nativelastname;
            }
            try{ update a;
               }
            catch(DMLException e){
                system.debug('exception message' +e);
            }
                        user u = [select id from user where accountid =: lcr.getAccountId()];
            
            system.setPassword(u.id, password);
        }
        
        ACAMSUserLogin.LoginResponse loginResponse;
        String rUrl = getRelayUrl();
        system.debug(rUrl);
        String startUrl = System.currentPageReference().getParameters().get('startUrl');
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String domain = isSandbox ? 'test' : 'login';
       // loginResponse = ACAMSUserLogin.login(email, password, domain);
        
        if ((String.isBlank(startUrl) || !String.isBlank(rUrl)) && pg == null) {
            if (appName != null ){
                startUrl = rUrl;
                
            }else{
                startUrl = '/idp/login?app=' + label.Drupal_SSO;
            }
        }else if (String.isBlank(startUrl) && pg != null) {
            startUrl = '/' + pg;
        }
        //  Redirect if User Already Logged in
        PageReference pageRef;
        if (UserInfo.getUserType() == 'Guest') {
            pageRef = Site.login(email, password, startUrl);
        } else {
            pageRef = new PageReference(startUrl);
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
    private boolean IsExistingEmail(String username){
        Boolean isExistingEmail = false;
        //if(!IsExistingUser(username)){
        if(username!=''){
        list<Account> lstContact = [select id,name,personEmail,Work_Email__pc,Secondary_Email__pc from account WHERE (Work_Email__pc=:username OR Secondary_Email__pc=:username OR Other_Email__pc=:username) AND personemail !=: username limit 4500 ];
        system.debug('Email exist in contact---------->'+lstContact);
        isExistingEmail = (lstContact.size() > 0 );
        }
        //lstExisCon = lstContact;
        System.debug('isExisting:'+isExistingEmail);
        return isExistingEmail;
        // }
        // return null;
    }
    public List<SelectOption> getIndustries()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Lead.Industry.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption( '-1','--None--'));
        options.add(new SelectOption( 'Accounting Firm',label.reg_Accounting_Firm));
        options.add(new SelectOption( 'Brokerage Firm, Securities & Investments',label.Brokerage_Firm_Securities_Investments));  // https://acamsprd--acamsdev.sandbox.my.salesforce.com/1018B000000BpcG          
        options.add(new SelectOption( 'Casino/Gaming',label.reg_Casino_Gaming));
        options.add(new SelectOption( 'Consulting Firm',label.reg_Consultant));
        options.add(new SelectOption( 'Credit Union',label.reg_Credit_Union));
        options.add(new SelectOption( 'Cryptoasset Service Provider',label.reg_Cryptoasset_Service_Provider)); // https://acamsprd--acamsdev.sandbox.my.salesforce.com/1018B000000BpcL
    options.add(new SelectOption( 'Financial Institution – Banking',label.reg_Banking));
    options.add(new SelectOption( 'FinTech',label.reg_FinTech)); // https://acamsprd--acamsdev.sandbox.my.salesforce.com/1018B000000BpcQ
        options.add(new SelectOption( 'Government - Enforcement',label.reg_Government_Enforcement));
        options.add(new SelectOption( 'Government - Regulatory',label.reg_Government_Regulatory));
        options.add(new SelectOption( 'Import/Export',label.reg_Import_Export)); // https://acamsprd--acamsdev.sandbox.my.salesforce.com/1018B000000BpcV
        options.add(new SelectOption( 'Insurance Firm',label.reg_Insurance));
        options.add(new SelectOption( 'Law Firm',label.reg_Law_Firm));
        options.add(new SelectOption( 'Luxury Retail',label.reg_Luxury_Retail));
        options.add(new SelectOption( 'Money Services Business (MSB)',label.reg_MSB));
        options.add(new SelectOption( 'Non-Bank Financial Institutions',label.reg_Non_Bank_Financial_Institutions)); //https://acamsprd--acamsdev.sandbox.my.salesforce.com/1018B000000Bpcf 
    options.add(new SelectOption( 'Payment Providers',label.reg_Payment_Providers)); // https://acamsprd--acamsdev.sandbox.my.salesforce.com/1018B000000BpdR
    options.add(new SelectOption( 'Real Estate',label.reg_Real_Estate)); // https://acamsprd--acamsdev.sandbox.my.salesforce.com/1018B000000BpdW
        options.add(new SelectOption( 'Technology - Software & Services',label.reg_Software_Technology));
        options.add(new SelectOption( 'Trust',label.reg_Trust)); // https://acamsprd--acamsdev.sandbox.my.salesforce.com/1018B000000Bpdb
        options.add(new SelectOption( 'Other',label.reg_Other));
        
        return options;
    } 
    
    
    
 /*   public List<SelectOption> getCountries()
    {
        List<CountrySettings__mdt> countryList=[Select MasterLabel,DeveloperName From CountrySettings__mdt  order by MasterLabel ASC];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '-1','Country/Region*'));
        if(countryList!=null){
            for(CountrySettings__mdt country : countryList ){
                options.add(new SelectOption(country.MasterLabel,country.MasterLabel));
            }
        }
        return options;
    } 
    public List<SelectOption> getStates()
    {
        List<StateSettings__mdt> countryList=[Select MasterLabel,DeveloperName From StateSettings__mdt where Country__r.MasterLabel=:country order by MasterLabel ASC];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '-1','Select One:'));
        if(countryList!=null){
            for(StateSettings__mdt country : countryList ){
                options.add(new SelectOption(country.DeveloperName,country.MasterLabel));
            }
        }
        return options;
    } 
    
    public void renderState(){
        
        stateLst = new List<selectOption>();
        
        
        List<StateSettings__mdt> lstState = new List<StateSettings__mdt>();
        lstState = [Select MasterLabel,DeveloperName,Country__r.DeveloperName,IsoCode__c From StateSettings__mdt where Country__r.MasterLabel =: country  order by MasterLabel ASC];
        if(lstState.size() > 0){
            renderstatebox = true;
        }
        system.debug(country);
        stateLst.add(new SelectOption('','State*'));
        for(StateSettings__mdt  state : lstState ){
            stateLst.add(new SelectOption(state.MasterLabel,state.MasterLabel));
        }
        
    }
*/
   /* public List<SelectOption> getareacodes()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = User.Area_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
             options.add(new SelectOption(pickListVal.getValue().substringBetween('+', ')'),pickListVal.getLabel()));
        }     
         return options;
    }
*/
    
      public List<SelectOption> getareacodes()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Lead.Industry.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption( '-1','--None--'));
        options.add(new SelectOption( '1',label.United_States_1));
        options.add(new SelectOption( '93',label.area_Afghanistan_93));
        options.add(new SelectOption( '355',label.area_Albania_355));
        options.add(new SelectOption( '213',label.Algeria_213));
        options.add(new SelectOption( '1 684',label.American_Samoa_1_684));
        options.add(new SelectOption( '376',label.Andorra_376));
        options.add(new SelectOption( '244',label.Angola_244));
        options.add(new SelectOption( '1 264',label.Anguilla_1_264));
        options.add(new SelectOption( '672',label.Antarctica_672));
        options.add(new SelectOption( '1 268',label.Antigua_Barbuda_1_268));
        options.add(new SelectOption( '54',label.Argentina_54));
        options.add(new SelectOption( '374',label.Armenia_374));
        options.add(new SelectOption( '297',label.Aruba_297));
        options.add(new SelectOption( '247',label.Ascension_Island_247));
        options.add(new SelectOption( '61',label.Australia_61));
        options.add(new SelectOption( '43',label.Austria_43));
        options.add(new SelectOption( '994',label.Azerbaijan_994));
        options.add(new SelectOption( '1 242',label.Bahamas_1_242));
        options.add(new SelectOption( '973',label.Bahrain_973));
        options.add(new SelectOption( '880',label.Bangladesh_880));
        options.add(new SelectOption( '1 246',label.Barbados_1_246));
        options.add(new SelectOption( '375',label.Belarus_375));
        options.add(new SelectOption( '32',label.Belgium_32));
        options.add(new SelectOption( '501',label.Belize_501));
        options.add(new SelectOption( '229',label.Benin_229));
        options.add(new SelectOption( '1 441',label.Bermuda_1_441));
        options.add(new SelectOption( '975',label.Bhutan_975));
        options.add(new SelectOption( '591',label.Bolivia_591));
        options.add(new SelectOption( '387',label.Bosnia_Herzegovina_387));
        options.add(new SelectOption( '267',label.Botswana_267));
        options.add(new SelectOption( '47',label.Bouvet_Island_47));
        options.add(new SelectOption( '55',label.Brazil_55));
        options.add(new SelectOption( '246',label.British_Indian_Ocean_Territory_246));
        options.add(new SelectOption( '1 284',label.British_Virgin_Islands_1_284));
        options.add(new SelectOption( '673',label.Brunei_673));
        options.add(new SelectOption( '359',label.Bulgaria_359));
        options.add(new SelectOption( '226',label.Burkina_Faso_226));
        options.add(new SelectOption( '257',label.Burundi_257));
        options.add(new SelectOption( '855',label.Cambodia_855));
        options.add(new SelectOption( '237',label.Cameroon_237));
        options.add(new SelectOption( '1',label.Canada_1));
        options.add(new SelectOption( '34',label.Canary_Islands_34));
        options.add(new SelectOption( '238',label.Cape_Verde_238));
        options.add(new SelectOption( '599',label.Caribbean_Netherlands_599));
        options.add(new SelectOption( '1 345',label.Cayman_Islands_1_345));
        options.add(new SelectOption( '236',label.Central_African_Republic_236));
        options.add(new SelectOption( '34',label.Ceuta_Melilla_34));
        options.add(new SelectOption( '235',label.Chad_235));
        options.add(new SelectOption( '56',label.Chile_56));
        options.add(new SelectOption( '86',label.China_86));
        options.add(new SelectOption( '61',label.Christmas_Island_61));
        options.add(new SelectOption( '33',label.Clipperton_Island_33));
        options.add(new SelectOption( '61',label.Cocos_Keeling_Islands_61));
        options.add(new SelectOption( '57',label.Colombia_57));
        options.add(new SelectOption( '269',label.Comoros_269));
        options.add(new SelectOption( '242',label.Congo_Brazzaville_242));
        options.add(new SelectOption( '243',label.Congo_Kinshasa_243));
        options.add(new SelectOption( '682',label.Cook_Islands_682));
        options.add(new SelectOption( '506',label.Costa_Rica_506));
        options.add(new SelectOption( '385',label.Croatia_385));
        options.add(new SelectOption( '53',label.Cuba_53));
        options.add(new SelectOption( '599',label.Cura_ao_599));
        options.add(new SelectOption( '357',label.Cyprus_357));
        options.add(new SelectOption( '420',label.Czechia_420));
        options.add(new SelectOption( '225',label.C_te_d_Ivoire_225));
        options.add(new SelectOption( '45',label.Denmark_45));
        options.add(new SelectOption( '246',label.Diego_Garcia_246));
        options.add(new SelectOption( '253',label.Djibouti_253));
        options.add(new SelectOption( '1 809',label.Dominican_Republic_1_809));
        options.add(new SelectOption( '1 767',label.Dominica_1_767));
        options.add(new SelectOption( '593',label.Ecuador_593));
        options.add(new SelectOption( '20',label.Egypt_20));
        options.add(new SelectOption( '503',label.El_Salvador_503));
        options.add(new SelectOption( '240',label.Equatorial_Guinea_240));
        options.add(new SelectOption( '291',label.Eritrea_291));
        options.add(new SelectOption( '372',label.Estonia_372));
        options.add(new SelectOption( '268',label.Eswatini_268));
        options.add(new SelectOption( '251',label.Ethiopia_251));
        options.add(new SelectOption( '500',label.Falkland_Islands_500));
        options.add(new SelectOption( '298',label.Faroe_Islands_298));
        options.add(new SelectOption( '679',label.Fiji_679));
        options.add(new SelectOption( '358',label.Finland_358));
        options.add(new SelectOption( '33',label.France_33));
        options.add(new SelectOption( '594',label.French_Guiana_594));
        options.add(new SelectOption( '689',label.French_Polynesia_689));
        options.add(new SelectOption( '672',label.French_Southern_Territories_672));
        options.add(new SelectOption( '241',label.Gabon_241));
        options.add(new SelectOption( '220',label.Gambia_220));
        options.add(new SelectOption( '995',label.Georgia_995));
        options.add(new SelectOption( '49',label.Germany_49));
        options.add(new SelectOption( '233',label.Ghana_233));
        options.add(new SelectOption( '350',label.Gibraltar_350));
        options.add(new SelectOption( '30',label.Greece_30));
        options.add(new SelectOption( '299',label.Greenland_299));
        options.add(new SelectOption( '1 473',label.Grenada_1_473));
        options.add(new SelectOption( '590',label.Guadeloupe_590));
        options.add(new SelectOption( '1 671',label.Guam_1_671));
        options.add(new SelectOption( '502',label.Guatemala_502));
        options.add(new SelectOption( '44',label.Guernsey_44));
        options.add(new SelectOption( '224',label.Guinea_224));
        options.add(new SelectOption( '245',label.Guinea_Bissau_245));
        options.add(new SelectOption( '592',label.Guyana_592));
        options.add(new SelectOption( '509',label.Haiti_509));
        options.add(new SelectOption( '672',label.Heard_McDonald_Islands_672));
        options.add(new SelectOption( '504',label.Honduras_504));
        options.add(new SelectOption( '852',label.Hong_Kong_852));
        options.add(new SelectOption( '36',label.Hungary_36));
        options.add(new SelectOption( '354',label.Iceland_354));
        options.add(new SelectOption( '91',label.India_91));
        options.add(new SelectOption( '62',label.Indonesia_62));
        options.add(new SelectOption( '98',label.Iran_98));
        options.add(new SelectOption( '964',label.Iraq_964));
        options.add(new SelectOption( '353',label.Ireland_353));
        options.add(new SelectOption( '44',label.Isle_of_Man_44));
        options.add(new SelectOption( '972',label.Israel_972));
        options.add(new SelectOption( '39',label.Italy_39));
        options.add(new SelectOption( '1 876',label.Jamaica_1_876));
        options.add(new SelectOption( '81',label.Japan_81));
        options.add(new SelectOption( '44',label.Jersey_44));
        options.add(new SelectOption( '962',label.Jordan_962));
        options.add(new SelectOption( '7',label.Kazakhstan_7));
        options.add(new SelectOption( '254',label.Kenya_254));
        options.add(new SelectOption( '686',label.Kiribati_686));
        options.add(new SelectOption( '383',label.Kosovo_383));
        options.add(new SelectOption( '965',label.Kuwait_965));
        options.add(new SelectOption( '996',label.Kyrgyzstan_996));
        options.add(new SelectOption( '856',label.Laos_856));
        options.add(new SelectOption( '371',label.Latvia_371));
        options.add(new SelectOption( '961',label.Lebanon_961));
        options.add(new SelectOption( '266',label.Lesotho_266));
        options.add(new SelectOption( '231',label.Liberia_231));
        options.add(new SelectOption( '218',label.Libya_218));
        options.add(new SelectOption( '423',label.Liechtenstein_423));
        options.add(new SelectOption( '370',label.Lithuania_370));
        options.add(new SelectOption( '352',label.Luxembourg_352));
        options.add(new SelectOption( '853',label.Macau_853));
        options.add(new SelectOption( '261',label.Madagascar_261));
        options.add(new SelectOption( '265',label.Malawi_265));
        options.add(new SelectOption( '60',label.Malaysia_60));
        options.add(new SelectOption( '960',label.Maldives_960));
        options.add(new SelectOption( '223',label.Mali_223));
        options.add(new SelectOption( '356',label.Malta_356));
        options.add(new SelectOption( '692',label.Marshall_Islands_692));
        options.add(new SelectOption( '596',label.Martinique_596));
        options.add(new SelectOption( '222',label.Mauritania_222));
        options.add(new SelectOption( '230',label.Mauritius_230));
        options.add(new SelectOption( '262',label.Mayotte_262));
        options.add(new SelectOption( '52',label.Mexico_52));
        options.add(new SelectOption( '691',label.Micronesia_691));
        options.add(new SelectOption( '373',label.Moldova_373));
        options.add(new SelectOption( '377',label.Monaco_377));
        options.add(new SelectOption( '976',label.Mongolia_976));
        options.add(new SelectOption( '382',label.Montenegro_382));
        options.add(new SelectOption( '1 664',label.Montserrat_1_664));
        options.add(new SelectOption( '212',label.Morocco_212));
        options.add(new SelectOption( '258',label.Mozambique_258));
        options.add(new SelectOption( '95',label.Myanmar_Burma_95));
        options.add(new SelectOption( '264',label.Namibia_264));
        options.add(new SelectOption( '674',label.Nauru_674));
        options.add(new SelectOption( '977',label.Nepal_977));
        options.add(new SelectOption( '31',label.Netherlands_31));
        options.add(new SelectOption( '687',label.New_Caledonia_687));
        options.add(new SelectOption( '64',label.New_Zealand_64));
        options.add(new SelectOption( '505',label.Nicaragua_505));
        options.add(new SelectOption( '234',label.Nigeria_234));
        options.add(new SelectOption( '227',label.Niger_227));
        options.add(new SelectOption( '683',label.Niue_683));
        options.add(new SelectOption( '672',label.Norfolk_Island_672));
        options.add(new SelectOption( '1 670',label.Northern_Mariana_Islands_1_670));
        options.add(new SelectOption( '850',label.North_Korea_850));
        options.add(new SelectOption( '389',label.North_Macedonia_389));
        options.add(new SelectOption( '47',label.Norway_47));
        options.add(new SelectOption( '968',label.Oman_968));
        options.add(new SelectOption( '92',label.Pakistan_92));
        options.add(new SelectOption( '680',label.Palau_680));
        options.add(new SelectOption( '970',label.Palestinian_Territories_970));
        options.add(new SelectOption( '507',label.Panama_507));
        options.add(new SelectOption( '675',label.Papua_New_Guinea_675));
        options.add(new SelectOption( '595',label.Paraguay_595));
        options.add(new SelectOption( '51',label.Peru_51));
        options.add(new SelectOption( '63',label.Philippines_63));
        options.add(new SelectOption( '870',label.Pitcairn_Islands_870));
        options.add(new SelectOption( '48',label.Poland_48));
        options.add(new SelectOption( '351',label.Portugal_351));
        options.add(new SelectOption( '1',label.Puerto_Rico_1));
        options.add(new SelectOption( '974',label.Qatar_974));
        options.add(new SelectOption( '40',label.Romania_40));
        options.add(new SelectOption( '7',label.Russia_7));
        options.add(new SelectOption( '250',label.Rwanda_250));
        options.add(new SelectOption( '262',label.R_union_262));
        options.add(new SelectOption( '685',label.Samoa_685));
        options.add(new SelectOption( '378',label.San_Marino_378));
        options.add(new SelectOption( '966',label.Saudi_Arabia_966));
        options.add(new SelectOption( '221',label.Senegal_221));
        options.add(new SelectOption( '381',label.Serbia_381));
        options.add(new SelectOption( '248',label.Seychelles_248));
        options.add(new SelectOption( '232',label.Sierra_Leone_232));
        options.add(new SelectOption( '65',label.Singapore_65));
        options.add(new SelectOption( '599',label.Sint_Maarten_599));
        options.add(new SelectOption( '421',label.Slovakia_421));
        options.add(new SelectOption( '386',label.Slovenia_386));
        options.add(new SelectOption( '677',label.Solomon_Islands_677));
        options.add(new SelectOption( '252',label.Somalia_252));
        options.add(new SelectOption( '27',label.South_Africa_27));
        options.add(new SelectOption( '500',label.South_Georgia_Sandwich_islands_500));
        options.add(new SelectOption( '82',label.South_Korea_82));
        options.add(new SelectOption( '211',label.South_Sudan_211));
        options.add(new SelectOption( '34',label.Spain_34));
        options.add(new SelectOption( '94',label.Sri_Lanka_94));
        options.add(new SelectOption( '590',label.St_Barth_lemy_590));
        options.add(new SelectOption( '290',label.St_Helena_290));
        options.add(new SelectOption( '1 869',label.St_Kitts_Nevis_1_869));
        options.add(new SelectOption( '1 758',label.St_Lucia_1_758));
        options.add(new SelectOption( '590',label.St_Martin_590));
        options.add(new SelectOption( '508',label.St_Pierre_Miquelon_508));
        options.add(new SelectOption( '1 784',label.St_Vincent_Grenadines_1_784));
        options.add(new SelectOption( '249',label.Sudan_249));
        options.add(new SelectOption( '597',label.Suriname_597));
        options.add(new SelectOption( '47',label.Svalbard_Jan_Mayen_47));
        options.add(new SelectOption( '46',label.Sweden_46));
        options.add(new SelectOption( '41',label.Switzerland_41));
        options.add(new SelectOption( '963',label.Syria_963));
        options.add(new SelectOption( '239',label.S_o_Tom_Pr_ncipe_239));
        options.add(new SelectOption( '886',label.Taiwan_886));
        options.add(new SelectOption( '992',label.Tajikistan_992));
        options.add(new SelectOption( '255',label.Tanzania_255));
        options.add(new SelectOption( '66',label.Thailand_66));
        options.add(new SelectOption( '670',label.Timor_Leste_670));
        options.add(new SelectOption( '228',label.Togo_228));
        options.add(new SelectOption( '690',label.Tokelau_690));
        options.add(new SelectOption( '676',label.Tonga_676));
        options.add(new SelectOption( '1 868',label.Trinidad_Tobago_1_868));
        options.add(new SelectOption( '590',label.Tristan_da_Cunha_590));
        options.add(new SelectOption( '216',label.Tunisia_216));
        options.add(new SelectOption( '90',label.Turkey_90));
        options.add(new SelectOption( '993',label.Turkmenistan_993));
        options.add(new SelectOption( '1 649',label.Turks_Caicos_Islands_1_649));
        options.add(new SelectOption( '688',label.Tuvalu_688));
        options.add(new SelectOption( '256',label.Uganda_256));
        options.add(new SelectOption( '380',label.Ukraine_380));
        options.add(new SelectOption( '971',label.United_Arab_Emirates_971));
        options.add(new SelectOption( '44',label.United_Kingdom_44));
        options.add(new SelectOption( '598',label.Uruguay_598));
        options.add(new SelectOption( '998',label.Uzbekistan_998));
        options.add(new SelectOption( '246',label.U_S_Outlying_Islands_246));
        options.add(new SelectOption( '1',label.U_S_Virgin_Islands_1));
        options.add(new SelectOption( '678',label.Vanuatu_678));
        options.add(new SelectOption( '379',label.Vatican_City_379));
        options.add(new SelectOption( '58',label.Venezuela_58));
        options.add(new SelectOption( '84',label.Vietnam_84));
        options.add(new SelectOption( '681',label.Wallis_Futuna_681));
        options.add(new SelectOption( '212',label.Western_Sahara_212));
        options.add(new SelectOption( '967',label.Yemen_967));
        options.add(new SelectOption( '260',label.Zambia_260));
        options.add(new SelectOption( '263',label.Zimbabwe_263));
        options.add(new SelectOption( '358',label.land_Islands_358));
        
        return options;
    } 
     
     public static String getCountryfullname(String countrycode) {
        CountrySettings__mdt metaData = [
                SELECT
                        Id,
                        MasterLabel
                FROM
                        CountrySettings__mdt
                WHERE
                        Isocode__c = :countrycode limit 1
        ];

        return metaData.MasterLabel;
    }
     public static String getStatefullname(String statecode, String countrycode) {
        StateSettings__mdt metaData = [
                SELECT
                        Id,
                        MasterLabel
                FROM
                        StateSettings__mdt
                WHERE
                        Isocode__c = :statecode 
             AND
                    (Country__r.MasterLabel = :countrycode
                    OR
                    Country__r.Isocode__c = :countrycode)
            LIMIT 1
        ];

        return metaData.MasterLabel;
    }
       public static String getLangValues(String langValue) {
        String Langval;
           if(langValue=='en' || langValue=='en_US' ){
               Langval='en_US';
           }
           else if(langValue=='zh-hans' || langValue=='zh_CN'){
               Langval='zh_CN';
           }
            else if(langValue=='zh-hant' || langValue=='zh_TW'){
               Langval='zh_TW';
           }
            else if(langValue=='fr'){
               Langval='fr';
           }
            else if(langValue=='de' || langValue=='nl_NL'){
               Langval='nl_NL';
           }
           else if(langValue=='ja'){
               Langval='ja';
           }
            else if(langValue=='pl'){
               Langval='pl';
           }
            else if(langValue=='pt-br' || langValue=='pt_BR'){
               Langval='pt_BR';
           }
           else if(langValue=='es' || langValue=='es_MX'){
               Langval='es_MX';
           }
       

        return Langval;
    }
     public static String getLangValuesCommunication(String langValue) {
        String Langvalcomm;
           if(langValue=='en' || langValue=='en_US' ){
               Langvalcomm='en_US';
           }
           else if(langValue=='zh-hans' || langValue=='zh_CN'){
               Langvalcomm='zh_CN';
           }
            else if(langValue=='zh-hant' || langValue=='zh_TW'){
               Langvalcomm='zh_TW';
           }
            else if(langValue=='fr'){
               Langvalcomm='fr';
           }
            else if(langValue=='de' || langValue=='nl_NL'){
               Langvalcomm='de';
           }
           else if(langValue=='ja'){
               Langvalcomm='ja';
           }
            else if(langValue=='pl'){
               Langvalcomm='pl';
           }
            else if(langValue=='pt-br' || langValue=='pt_BR'){
               Langvalcomm='pt_BR';
           }
           else if(langValue=='es' || langValue=='es_MX'){
               Langvalcomm='es';
           }
         else{
              Langvalcomm='en_US';
         }
       

        return Langvalcomm;
    }
    public static String getLangValuesWeb(String langValue) {
        String Langvalweb;
           if(langValue=='en' || langValue=='en_US' ){
               Langvalweb='en_US';
           }
           else if(langValue=='zh-hans' || langValue=='zh_CN'){
               Langvalweb='zh_CN';
           }
            else if(langValue=='zh-hant' || langValue=='zh_TW'){
               Langvalweb='zh_TW';
           }
            else if(langValue=='fr'){
               Langvalweb='fr';
           }
            else if(langValue=='de' || langValue=='nl_NL'){
               Langvalweb='de';
           }
           else if(langValue=='ja'){
               Langvalweb='ja';
           }
            else if(langValue=='pl'){
               Langvalweb='pl';
           }
            else if(langValue=='pt-br' || langValue=='pt_BR'){
               Langvalweb='pt_BR';
           }
           else if(langValue=='es' || langValue=='es_MX'){
               Langvalweb='es';
           }
        else{
             Langvalweb='en_US';
        }
       

        return Langvalweb;
    }
     public static String getLangValuesPwd(String langValue) {
        String Langvalweb;
           if(langValue=='en' || langValue=='en_US' ){
               Langvalweb='en';
           }
           else if(langValue=='zh-hans' || langValue=='zh_CN'){
               Langvalweb='zh-hans';
           }
            else if(langValue=='zh-hant' || langValue=='zh_TW'){
               Langvalweb='zh-hant';
           }
            else if(langValue=='fr'){
               Langvalweb='fr';
           }
            else if(langValue=='de' || langValue=='nl_NL'){
               Langvalweb='de';
           }
           else if(langValue=='ja'){
               Langvalweb='ja';
           }
            else if(langValue=='pl'){
               Langvalweb='pl';
           }
            else if(langValue=='pt-br' || langValue=='pt_BR'){
               Langvalweb='pt-br';
           }
           else if(langValue=='es' || langValue=='es_MX'){
               Langvalweb='es';
           }
         else{
             Langvalweb='en';
         }
       

        return Langvalweb;
    }
    public PageReference refreshPage() {
           if(usr.Interface_Language__c!= null){
            langValue=usr.Interface_Language__c;
        }


         signinPage = '/acams/ACAMSSiteLogin?AppName='+appName +'&relaystate='+relaystate+'&language='+langValue;
        return null;
    }

}