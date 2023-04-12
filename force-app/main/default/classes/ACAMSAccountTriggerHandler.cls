public without sharing class ACAMSAccountTriggerHandler extends CCAviTriggerHandler {
    private List<Account> newList = (List<Account>) Trigger.new;
    private List<Account> oldList = (List<Account>) Trigger.old;
    private Map<Id, Account> newMap = (Map<Id, Account>) Trigger.newMap;
    private Map<Id, Account> oldMap = (Map<Id, Account>) Trigger.oldMap;

    public Set<Id> contactIds = new Set<Id>();
    public static Boolean raiseException = false;
    public class customException extends Exception {
    }
    public static Boolean isLMSUserCreated = false;
    public static User drupalIntegration = ACAMSUserDAO.getDrupalIntegrationUser();
    
    Set<String> compNameString = new Set<String>(); // added FSA-1826

   private AssignmentRule assignmentRule = [
            SELECT Id
            FROM AssignmentRule
            WHERE SobjectType = 'Lead'
            AND Active = TRUE
            LIMIT 1
    ]; 

    private List<String> accountGroupNames = new List<String>{
            ACAMSUtil.PORTAL_ACCOUNT,
            ACAMSUtil.PORTAL_ACCOUNT_GOV,
            ACAMSUtil.PORTAL_ACCOUNT_GOV_MEMBER,
            ACAMSUtil.PORTAL_ACCOUNT_MEMBER,
            ACAMSUtil.PORTAL_ACCOUNT_CHAPTER_MEMBER,
            ACAMSUtil.PORTAL_ACCOUNT_GOV_CHAPTER_MEMBER
    };

    private List<ccrz__E_AccountGroup__c> accountGroups = [
            SELECT Id, Name
            FROM ccrz__E_AccountGroup__c
            WHERE Name IN :accountGroupNames
    ];
    private Map<String, Id> accountGroupsMap = new Map<String, Id>();
    //csa-fix-added one method for querying gamMap    
     Private Map<String,Id> getgamMap(Set<String> compNameString){
        Map<string, id> gamMap = new Map<string,id>();
        for(Account_Global_Manager__c ga : [select id, name, Global_Account_Manager__c  from Account_Global_Manager__c where name =: compNameString ]){
            gamMap.put(ga.name,ga.Global_Account_Manager__c);
        }
        return gamMap;
      }

    protected override void beforeInsert() {
        validatePhoneNumbers();
        //CSA fix : WF moved to trigger
		handleCheckCamsFlagInsert(newList);
        for (ccrz__E_AccountGroup__c accountGroup : accountGroups) {
            accountGroupsMap.put(accountGroup.Name, accountGroup.Id);
        }
        
        //chandra added FSA-1826
        for (Account account : newList) {           
            if(account.Company_Name_Inactive__c != null){
                compNameString.add(account.Company_Name_Inactive__c);
            }
        }
        
        //csa fix-removed gammap query as it was repeating twice.
        Map<string, id> gamMap = getgamMap(compNameString);
        
        /*Map<string, id> gamMap = new Map<string,id>();
        for(Account_Global_Manager__c ga : [select id, name, Global_Account_Manager__c  from Account_Global_Manager__c where name =: compNameString ]){
            gamMap.put(ga.name,ga.Global_Account_Manager__c);
        }      */ 
        //added FSA-1826 close

        for (Account account : newList) {
            //csa fix : Added null check to drupal Integration user as it was giving null ptr
            if (drupalIntegration.Id != null && UserInfo.getUserId() == drupalIntegration.Id ) {
                account.PersonLeadSource = 'Direct Traffic';
                account.BillingCountry = account.PersonMailingCountry;
                account.BillingCountryCode = account.PersonMailingCountryCode;
                account.BillingState = account.PersonMailingState;
                account.BillingStateCode = account.PersonMailingStateCode;
                account.ShippingCountry = account.PersonMailingCountry;
                account.ShippingState = account.PersonMailingState;
                Lead lead = generateLead(account, assignmentRule);
                try {
                    Database.insert(lead, lead.getOptions());
                } catch (DMLException e) {
                          //csa fix added exception logger statement. 
           ACAMSUtil.reportException(null, null,'beforeInsert Method', null, e.getMessage(), null, null);
                }
            }
            if (account.PersonEmail != null && account.Work_Email__pc == null) {
                account.Work_Email__pc = account.PersonEmail;
            }
            updateUserFields();
            String email = account.PersonEmail;
            Boolean govEmail = false;
            if (account.IsPersonAccount && String.isNotBlank(email)) {
                govEmail = email.endsWith('.gov') || email.endsWith('.mil');
                if (account.Membership_Type__pc == ACAMSUtil.MEMBER_CAPS || account.Membership_Type__pc == ACAMSUtil.ENTERPRISE_CAPS) {
                    if (govEmail || (account.Industry == ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT ||
                            account.Industry == ACAMSUtil.INDUSTRY_GOV_REGULATORY)) {
                        if (account.Chapter_Member__pc && account.Chapter_Member_Expire_Date__pc >= system.today() ) {
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV_CHAPTER_MEMBER); //FSA-6808 
                        } else {
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV_MEMBER);
                        }
                    } else {
                        if (account.Chapter_Member__pc && account.Chapter_Member_Expire_Date__pc >= system.today()) { //FSA-6808 
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_CHAPTER_MEMBER);
                        } else {
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_MEMBER);
                        }
                    }
                } else if (account.Membership_Type__pc == NULL ||
                        account.Membership_Type__pc == ACAMSUtil.NON_MEMBER_CAPS) {
                    if (govEmail || (account.Industry == ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT ||
                            account.Industry == ACAMSUtil.INDUSTRY_GOV_REGULATORY)) {
                        account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV);
                    } else {
                        account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT);
                    }
                }
            } else {
                if (account.ccrz__E_AccountGroup__c == null && account.Industry != ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT &&
                        account.Industry != ACAMSUtil.INDUSTRY_GOV_REGULATORY) {
                    account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT);
                } else if (account.ccrz__E_AccountGroup__c == null && (account.Industry == ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT ||
                        account.Industry == ACAMSUtil.INDUSTRY_GOV_REGULATORY)) {
                    account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV);
                }
            }

            if (account.Billing_Country__c != null && account.Billing_Country__c.length() > 2) {
                String isoCode = ACAMSUtil.getIsoCodeFromCountryName(account.Billing_Country__c);
                account.BillingCountry = isoCode;
                account.BillingCountryCode = isoCode;
            }

            if (account.Billing_State__c != null) {
                List<String> metadata = ACAMSUtil.getMetadataFromStateName(account.Billing_State__c, account.Billing_Country__c);
                account.BillingState = metadata.get(1) != null ? metadata.get(1) : metadata.get(0);
                account.BillingStateCode = metadata.get(0);
            }
            
            //chandra added FSA-1826 
            if(account.Company_Name_Inactive__c != null && !gamMap.isEmpty()){
                if(gamMap.get(account.Company_Name_Inactive__c) != null ){
                    account.Global_Account_Manager__c = gamMap.get(account.Company_Name_Inactive__c);
                }
            }
            //chandra added FSA-1826        
        }       

        this.setFieldsFromCountrySettingsAndStateSettings(this.newList);
        coutrypopulateDU(this.newList);
    }
    
    // FSA-1033
    public void coutrypopulateDU(List<Account> accounts){
        if (UserInfo.getUserId() == drupalIntegration.Id) {
            this.setFieldsFromCountrySettingsAndStateSettings(accounts);           
        }
    }

    protected override void beforeUpdate() {
        validatePhoneNumbers();
        //CSA fix : WF moved to trigger
        handleCheckCamsFlagUpdate(newList,oldMap);
        for (ccrz__E_AccountGroup__c accountGroup : accountGroups) {
            accountGroupsMap.put(accountGroup.Name, accountGroup.Id);
        }

        updateUserFields();
        
        //chandra added FSA-1826
        for (Account account : newList) {           
            if(account.Company_Name_Inactive__c != null){
                compNameString.add(account.Company_Name_Inactive__c);
            }
        }
        
        //csa fix-removed gammap query as it was repeating twice.
        Map<string, id> gamMap = getgamMap(compNameString);
        
        /*Map<string, id> gamMap = new Map<string,id>();
        for(Account_Global_Manager__c ga : [select id, name, Global_Account_Manager__c  from Account_Global_Manager__c where name =: compNameString ]){
            gamMap.put(ga.name,ga.Global_Account_Manager__c);
        }       */
        //chandra added FSA-1826 close

        
        for (Account account : newList) {
            if (account.IsPersonAccount) {
                String oldMembershipType = oldMap.get(account.Id).Membership_Type__pc;
                String newMembershipType = newMap.get(account.Id).Membership_Type__pc;
                if (oldMembershipType != newMembershipType ||
                        account.Chapter_Member__pc != oldMap.get(account.Id).Chapter_Member__pc ||
                        account.Industry != oldMap.get(account.Id).Industry ||
                        account.PersonEmail != oldMap.get(account.Id).PersonEmail ||
                        account.Work_Email__pc != oldMap.get(account.Id).Work_Email__pc ||
                        account.Secondary_Email__pc != oldMap.get(account.Id).Secondary_Email__pc ||
                        account.Other_Email__pc != oldMap.get(account.Id).Other_Email__pc) {
                    String email = newMap.get(account.Id).PersonEmail != null ? newMap.get(account.Id).PersonEmail : '';
                    String workEmail = newMap.get(account.Id).Work_Email__pc != null ?
                            newMap.get(account.Id).Work_Email__pc : '';
                    String secEmail = newMap.get(account.Id).Secondary_Email__pc != null ?
                            newMap.get(account.Id).Secondary_Email__pc : '';
                    String othrEmail = newMap.get(account.Id).Other_Email__pc != null ?
                            newMap.get(account.Id).Other_Email__pc : '';
                    Boolean govEmail = email.endsWith('.gov') || email.endsWith('.mil') || workEmail.endsWith('.gov') ||
                            workEmail.endsWith('.mil') || secEmail.endsWith('.gov') || secEmail.endsWith('.mil') ||
                            othrEmail.endsWith('.gov') || othrEmail.endsWith('.mil');
                    if ((oldMembershipType == null || oldMembershipType == ACAMSUtil.NON_MEMBER_CAPS ||
                            oldMembershipType == ACAMSUtil.ENTERPRISE_CAPS || oldMembershipType == ACAMSUtil.MEMBER_CAPS || //FSA-6808 
                            account.Chapter_Member__pc != oldMap.get(account.Id).Chapter_Member__pc ||
                            account.Industry != oldMap.get(account.Id).Industry) &&
                            (newMembershipType == ACAMSUtil.MEMBER_CAPS || newMembershipType == ACAMSUtil.ENTERPRISE_CAPS)) {
                        // UPGRADE FROM NON-MEMBER TO MEMBER OR DOWNGRADE FROM ENTERPRISE TO MEMBER BY EMAIL
                        if (govEmail || (account.Industry == ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT ||
                                         account.Industry == ACAMSUtil.INDUSTRY_GOV_REGULATORY)) {
                            if (account.Chapter_Member__pc && account.Chapter_Member_Expire_Date__pc >= system.today()) { //FSA-6808 
                                account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV_CHAPTER_MEMBER);
                            } else {
                                account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV_MEMBER);
                            }
                        } else {
                            if (account.Chapter_Member__pc && account.Chapter_Member_Expire_Date__pc >= system.today()) {  //FSA-6808 
                                account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_CHAPTER_MEMBER);
                            } else {
                                account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_MEMBER);
                            }
                        }
                    } else if ((oldMembershipType == ACAMSUtil.ENTERPRISE_CAPS ||
                            oldMembershipType == ACAMSUtil.MEMBER_CAPS ||
                            account.Industry != oldMap.get(account.Id).Industry || account.PersonEmail != oldMap.get(account.Id).PersonEmail) && //FSA-6808 
                            (newMembershipType == null || newMembershipType == ACAMSUtil.NON_MEMBER_CAPS)) {
                        // DOWNGRADE TO NON-MEMBER BY EMAIL
                        if (govEmail || (account.Industry == ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT ||
                                account.Industry == ACAMSUtil.INDUSTRY_GOV_REGULATORY)) {
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV);
                        } else {
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT);
                        }
                    }
                }

                if (account.Billing_Country__c != oldMap.get(account.Id).Billing_Country__c &&
                        account.Billing_Country__c != null && account.Billing_Country__c.length() > 2) {
                    String isoCode = ACAMSUtil.getIsoCodeFromCountryName(account.Billing_Country__c);
                    account.BillingCountry = isoCode;
                    account.BillingCountryCode = isoCode;
                }
                if (account.Billing_State__c != oldMap.get(account.Id).Billing_State__c &&
                        account.Billing_State__c != null) {
                    List<String> metadata = ACAMSUtil.getMetadataFromStateName(
                            account.Billing_State__c, account.Billing_Country__c
                    );
                    account.BillingState = metadata.get(1) != null ? metadata.get(1) : metadata.get(0);
                    account.BillingStateCode = metadata.get(0);
                }
            }
            
            //chandra added FSA-1826
            if(account.Company_Name_Inactive__c != null && !gamMap.isEmpty()){
                if(gamMap.get(account.Company_Name_Inactive__c) != null ){
                account.Global_Account_Manager__c = gamMap.get(account.Company_Name_Inactive__c); 
                 
                } 

            }
            //chandra added FSA-1826 
            else{ //FSA-6148-IF NO COMPANY FOUND ON THE GLOBAL ACCOUNT MANAGER TABLE,GIVING ACCOUNT MANAGER VALUE AS NULL
                    account.Global_Account_Manager__c=null;
                }
        }

        this.setFieldsFromCountrySettingsAndStateSettings(
                this.getAccountsWithBillingCountryOrBillingStateChanged(this.newList, this.oldMap)
        );
        // Removed due to ACR-2523
        // parentAccountCheck();
        
        //vara added
        //FSA-2002
           // List<Account> accList = new List<Account>(); commented : acclist is not used in below scope
            Map<id,Date> accMap = new Map<id,Date>();
            for(Account c : newList){
                Date CAMSUpdateDate;
                if(c.CAMS_Expiration_Date__pc != null){                 
                    if( c.CAMS_FCI_Expiration_Date__pc != null || c.CAMSRM_Expiration_Date__pc != null || c.CAMS_Audit_Expiration_Date__pc != null || c.CKYCA_Expiration_Date__pc != null || c.CAFCA_Expiration_Date__pc != null || c.CTMA_Expiration_Date__pc != null ){
                        CAMSUpdateDate = c.CAMS_Expiration_Date__pc;
                        //system.debug('CAMSUpdateDate-->'+CAMSUpdateDate);
                        
                        if(c.CAMS_FCI_Expiration_Date__pc > CAMSUpdateDate){
                            CAMSUpdateDate = c.CAMS_FCI_Expiration_Date__pc;
                        }
                        if(c.CAMSRM_Expiration_Date__pc > CAMSUpdateDate){
                            CAMSUpdateDate = c.CAMSRM_Expiration_Date__pc;
                        }
                        if(c.CAMS_Audit_Expiration_Date__pc > CAMSUpdateDate){
                            CAMSUpdateDate = c.CAMS_Audit_Expiration_Date__pc;
                        }  //FSA-5077 Changes Start
                        if(c.CAMS_FCI__pc =true && c.CAMS_FCI_Expiration_Date__pc < CAMSUpdateDate){
                        c.CAMS_FCI_Expiration_Date__pc = CAMSUpdateDate;
                        }
                        if(c.CAMSRM__pc =true && c.CAMSRM_Expiration_Date__pc < CAMSUpdateDate){
                        c.CAMSRM_Expiration_Date__pc= CAMSUpdateDate;
                        }
                        if(c.CAMS_Audit__pc =true && c.CAMS_Audit_Expiration_Date__pc < CAMSUpdateDate){
                        c.CAMS_Audit_Expiration_Date__pc= CAMSUpdateDate;
                        } //FSA-5077 Changes End
                  /*        //FSA-4956 Changes start
                        if(c.CKYCA__pc =true && c.CKYCA_Expiration_Date__pc < CAMSUpdateDate){
                        c.CKYCA_Expiration_Date__pc = CAMSUpdateDate;
                        }
                        if(c.CAFCA__pc =true && c.CAFCA_Expiration_Date__pc < CAMSUpdateDate){
                        c.CAFCA_Expiration_Date__pc= CAMSUpdateDate;
                        }
                        if(c.CTMA__pc =true && c.CTMA_Expiration_Date__pc < CAMSUpdateDate){
                        c.CTMA_Expiration_Date__pc= CAMSUpdateDate;
                        } //FSA-4956 Changes end   */              
                    }
                }
                if(CAMSUpdateDate != null){
                    c.CAMS_Expiration_Date__pc = CAMSUpdateDate;
                    // accList.add(c); csa fix: thsi list is not used 
                }
                // FSA-2451 Added by Koti
                Date expirationDate = system.today();
                if(c.Member_Expire_Date__pc >= expirationDate){
                    c.ACAMS_Member__pc = true;
                } else{
                    c.ACAMS_Member__pc = false;
                } 
                if(c.Chapter_Member_Expire_Date__pc >= expirationDate){
                    c.Chapter_Member__pc = true;
                }else{
                    c.Chapter_Member__pc = false;
                }
                if(c.Premium_Webinar_Subscription_Expiration__pc >= expirationDate){
                    c.Premium_Webinar_Subscriber__pc = true;
                }else{
                    c.Premium_Webinar_Subscriber__pc = false;
                }
                if(c.CAMS_Expiration_Date__pc >= expirationDate){
                    c.CAMS__pc = true;
                }else{
                    c.CAMS__pc = false;
                }
                if(c.CGSS_Expiration_Date__pc >= expirationDate){
                    c.CGSS__pc = true;
                }else{
                    c.CGSS__pc = false;
                }
                if(c.CAMS_Audit_Expiration_Date__pc >= expirationDate){
                    c.CAMS_Audit__pc = true;
                }else{
                    c.CAMS_Audit__pc = false;
                }
                if(c.CAMS_FCI_Expiration_Date__pc >= expirationDate){
                    c.CAMS_FCI__pc = true;
                }
                else{
                    c.CAMS_FCI__pc = false;
                } if(c.CAMSRM_Expiration_Date__pc >= expirationDate){
                    c.CAMSRM__pc = true;
                }else{
                    c.CAMSRM__pc = false;
                }if(c.CKYCA_Expiration_Date__pc >= expirationDate){
                    c.CKYCA__pc = true;
                }else{
                    c.CKYCA__pc = false;
                } if(c.CTMA_Expiration_Date__pc >= expirationDate){
                    c.CTMA__pc = true;
                }else{
                    c.CTMA__pc = false;
                }
                if(c.CAFCA_Expiration_Date__pc >= expirationDate){
                    c.CAFCA__pc = true;
                }else{
                    c.CAFCA__pc = false;
                }
                if(c.Hong_Kong_Regime_Expiration_Date__pc >= expirationDate){
                    c.Hong_Kong_Regime__pc = true;
                }else{
                    c.Hong_Kong_Regime__pc = false;
                }
                if(c.India_Regime_Expiration_Date__pc >= expirationDate){
                    c.India_Regime__pc = true;
                }else{
                    c.India_Regime__pc = false;
                }
                if(c.Singapore_Regime_Expiration_Date__pc >= expirationDate){
                    c.Singapore_Regime__pc = true;
                }else{
                     c.Singapore_Regime__pc = false;
                }
                if(c.MLDC_Expiration_Date__pc >= expirationDate){
                    c.MLDC__pc = true;
                }else{
                     c.MLDC__pc = false;
                }
                if(c.ACAMS_Today_Expiration_Date__pc >= expirationDate){
                    c.AT_subscription__pc = true;
                }else{
                    c.AT_subscription__pc = false;
               }
               //FSA-4721 Added by chandra
               if(c.CCAS_Expiration_Date__pc >= expirationDate){
                    c.CCAS__pc = true;
                }else{
                    c.CCAS__pc = false;
                }   
            }
        //csa fix : Commented below code as there was no use of debug inside if 
            /*if(accList.size() > 0)
              //  update accList;
            system.debug('--------290------accList----------'+accList);*/
            //FSA-2002 close    
        //vara added close
    }

    //csa fix: Removed inner for loop and made use of old map.
    public override void afterUpdate() {
    
            list<Account> accList = new list<Account>();
            if (!System.isBatch() && !System.isFuture()) {
                if (!ExamResultHelper.isVUERecursiveCheckContact) {
                    for (Account newC : this.newList) {
                        if (newC.Pearson_Vue_ID__pc != null &&
                                (newC.Is_Work_Phone_Primary__pc != oldMap.get(newC.Id).Is_Work_Phone_Primary__pc ||
                                        newC.Is_Home_Phone_Primary__pc != oldMap.get(newC.Id).Is_Home_Phone_Primary__pc ||
                                        newC.Is_Mobile_Phone_Primary__pc != oldMap.get(newC.Id).Is_Mobile_Phone_Primary__pc ||
                                        newC.FirstName != oldMap.get(newC.Id).FirstName || newC.LastName != oldMap.get(newC.Id).LastName ||
                                        newC.Legal_First_Name__pc != oldMap.get(newC.Id).Legal_First_Name__pc ||
                                        newC.Legal_Last_Name__pc != oldMap.get(newC.Id).Legal_Last_Name__pc ||
                                        newC.PersonEmail != oldMap.get(newC.Id).PersonEmail ||
                                        newC.BillingStreet != oldMap.get(newC.Id).BillingStreet ||
                                        newC.BillingCountry != oldMap.get(newC.Id).BillingCountry || newC.Phone != oldMap.get(newC.Id).Phone ||
                                        newC.PersonHomePhone != oldMap.get(newC.Id).PersonHomePhone ||
                                        newC.PersonMobilePhone != oldMap.get(newC.Id).PersonMobilePhone
                                        || newC.BillingCity != oldMap.get(newC.Id).BillingCity)) {
                            contactIds.add(newC.Id);
                        }
                        if (newC.Merge_Enrollments__c != oldMap.get(newC.Id).Merge_Enrollments__c && newC.Merge_Enrollments__c == true) {
                            accList.add(newC);
                        }
                    }
                    ACAMS_MergeHelper.MergeEnrollment(accList, Label.FreeLibID);
                    ACAMS_MergeHelper.MergeEnrollment(accList, Label.EntLibID);
                    ExamResultHelper.SendContactInfo(contactIds);
                }
                if (!isLMSUserCreated) {
                    UpsertLMSUser(this.newList, this.oldMap);
                }
                if (UserInfo.getUserId() != drupalIntegration.Id) {
                    MemberUpdateOnUser(this.newList, this.oldMap);
                } 
                
                //FSA-1165
                Set<ID> conIDs = new Set<ID>();
                for(Account c : newList){
                if(c.Run_Membership_Certification_Logic__pc && !oldMap.get(c.id).Run_Membership_Certification_Logic__pc && c.IsPersonAccount){
                    conIDs.add(c.PersonContactId);
                    //c.Run_Membership_Certification_Logic__pc = false;
                }
                }
                if(conIDs.size()>0){
                    ACAMSMembershipAndCertificationsStatuses.updateMemsAndCertsStatusesByContact(conIDs,true);
                } 
                //End of FSA-1165       
                // removed logic added before update           
            }
        
    }
    
    public override void afterInsert() {
        CreatePortalUserAccount(this.newList);
    }
    public override void afterDelete() {

        List<String> MasterId = new List<String>();
        //List<String> CntId = new List<String>(); csa fix: not used in this scope
        String mid;
        String cid;
        String username;

        for (Account con : oldList) {
            MasterId.add(con.MasterRecordId);
            //CntId.add(con.Id); csa fix: not used in this scope
            mid = con.MasterRecordId;
            cid = con.Id;
            username = con.PersonEmail;

        }
        ACAMS_MergeHelper.MergeLMSUser(oldList, oldMap, mid, cid, username);

    }

    /* Removed due to ACR-2523
    private void parentAccountCheck() {
        Set<Id> parentAccountsIds = new Set<Id>();
        List<Account> resetAccounts = new List<Account>();
        for (Account account : newList) {
            if (account.IsPersonAccount) {
                if (account.Parent_Account__pc != oldMap.get(account.Id).Parent_Account__pc) {
                    if (account.Parent_Account__pc != null) {
                        parentAccountsIds.add(account.Parent_Account__pc);
                    } else {
                        resetAccounts.add(account);
                    }
                }
            }
        }
        if (!parentAccountsIds.isEmpty()) {
            Map<Id, Account> parentAccountToIdMap = new Map<Id, Account>(ACAMSAccountDAO.getAccountsFromIds(parentAccountsIds));
            for (Account account : newList) {
                Account parentAccount = parentAccountToIdMap.get(account.Parent_Account__pc);
                if (parentAccount.ccrz__E_AccountGroup__c != null) {
                    account.ccrz__E_AccountGroup__c = parentAccount.ccrz__E_AccountGroup__c;
                }
                if (parentAccount.Enterprise_Account__c == true) {
                    account.Enterprise_Account__pc = true;
                } else {
                    account.Enterprise_Account__pc = false;
                }
            }
        }
        if (!resetAccounts.isEmpty()) {
            for (Account account : resetAccounts) {
                String email = account.PersonEmail;
                Boolean govEmail = email.endsWith('.gov') || email.endsWith('.mil');
                if (account.Membership_Type__pc == ACAMSUtil.MEMBER_CAPS) {
                    if (govEmail) {
                        account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV_MEMBER);
                    } else {
                        account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_MEMBER);
                    }
                } else if (account.Membership_Type__pc == ACAMSUtil.NON_MEMBER_CAPS) {
                    if (govEmail) {
                        account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV);
                    } else {
                        account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT);
                    }
                }
                account.Enterprise_Account__pc = false;
            }
        }
    }*/

    private List<Account> getAccountsWithBillingCountryOrBillingStateChanged(List<Account> currentAccounts, Map<Id, Account> oldAccounts) {
        List<Account> accountsWithBillingChanges = new List<Account>();
        for (Account account : currentAccounts) {
            Account oldAccount = oldAccounts.get(account.Id);
            if (oldAccount.BillingCountryCode != account.BillingCountryCode) {
                accountsWithBillingChanges.add(account);
            } else if (oldAccount.BillingStateCode != account.BillingStateCode) {
                accountsWithBillingChanges.add(account);
            }
        }
        return accountsWithBillingChanges;
    }

    private void setFieldsFromCountrySettingsAndStateSettings(List<Account> accounts) {
        Set<String> countryCodes = new Set<String>();
        Set<String> stateCodes = new Set<String>();
        Map<String, String> settingsMap = new Map<String, String>();
        for (Account accountToUpdate : accounts) {
            if (!String.isBlank(accountToUpdate.BillingCountryCode)) {
                countryCodes.add(accountToUpdate.BillingCountryCode);
            }
            if (!String.isBlank(accountToUpdate.BillingStateCode)) {
                stateCodes.add(accountToUpdate.BillingStateCode);
            }
        }
        for (CountrySettings__mdt countrySetting : [
                SELECT Region__c, Continent__c, Named_Territory__c, SubTerritory__c, DeveloperName, Isocode__c, Label
                FROM CountrySettings__mdt
                WHERE DeveloperName IN :countryCodes
        ]) {
            settingsMap.put('region' + countrySetting.DeveloperName, countrySetting.Region__c);
            settingsMap.put('namedTerritory' + countrySetting.DeveloperName, countrySetting.Named_Territory__c);
            settingsMap.put('subTerritory' + countrySetting.DeveloperName, countrySetting.SubTerritory__c);
            settingsMap.put('continent' + countrySetting.DeveloperName, countrySetting.Continent__c);
            settingsMap.put('country' + countrySetting.DeveloperName, countrySetting.Label);
        }
        for (StateSettings__mdt stateSetting : [
                SELECT Label, Country__r.DeveloperName, Isocode__c
                FROM StateSettings__mdt
                WHERE Isocode__c IN :stateCodes
        ]) {
            settingsMap.put(
                    'state' + stateSetting.Country__r.DeveloperName + '-' + stateSetting.Isocode__c,
                    stateSetting.Label
            );
            
        }
        for (Account accountToUpdate : accounts) {
            accountToUpdate.Billing_Region__c = settingsMap.get('region' + accountToUpdate.BillingCountryCode);
            accountToUpdate.Billing_Named_Territory__c = settingsMap.get('namedTerritory' + accountToUpdate.BillingCountryCode);
            accountToUpdate.Billing_SubTerritory__c = settingsMap.get('subTerritory' + accountToUpdate.BillingCountryCode);
            accountToUpdate.Billing_Continent__c = settingsMap.get('continent' + accountToUpdate.BillingCountryCode);
            accountToUpdate.Billing_Country__c = settingsMap.get('country' + accountToUpdate.BillingCountryCode);
            accountToUpdate.Billing_State__c = settingsMap.get(
                    'state' + accountToUpdate.BillingCountryCode + '-' + accountToUpdate.BillingStateCode
            );
            
        }
    }

    private void updateUserFields() {
        Map<Id, String> userIdToEmailMap = new Map<Id, String>();
        Map<Id, String> userIdToFirstNameMap = new Map<Id, String>();
        Map<Id, String> userIdToLastNameMap = new Map<Id, String>();
        Map<Id, String> userIdToCompanyNameMap = new Map<Id, String>();
        for (Account account : newList) {
            if (oldMap != null) {
                Account oldAccount = oldMap.get(account.Id);
                if (!String.isBlank(account.Primary_Email__pc)) {
                    if (validityCheck(oldAccount.Primary_Email__pc, account.Primary_Email__pc) ||
                            validityCheck(oldAccount.Work_Email__pc, account.Work_Email__pc) ||
                            validityCheck(oldAccount.Secondary_Email__pc, account.Secondary_Email__pc) ||
                            validityCheck(oldAccount.Other_Email__pc, account.Other_Email__pc)) {
                        userIdToEmailMap = updatePersonEmail(account, userIdToEmailMap);
                    }
                }
                if (account.FirstName != null && !account.FirstName.equalsIgnoreCase(oldAccount.FirstName)) {
                    userIdToFirstNameMap.put(account.CommunityUser__c, account.FirstName);
                }

                if (account.LastName != null && !account.LastName.equalsIgnoreCase(oldAccount.LastName)) {
                    userIdToLastNameMap.put(account.CommunityUser__c, account.LastName);
                }

                if (account.ccrz__CompanyName__pc != null && !account.ccrz__CompanyName__pc.equalsIgnoreCase(oldAccount.ccrz__CompanyName__pc)) {
                    userIdToCompanyNameMap.put(account.CommunityUser__c, account.ccrz__CompanyName__pc);
                }
            } else {
                updatePersonEmail(account, userIdToEmailMap);
            }
        }
        if (!System.isFuture() && (!userIdToEmailMap.isEmpty() || !userIdToFirstNameMap.isEmpty() ||
                !userIdToLastNameMap.isEmpty() || !userIdToCompanyNameMap.isEmpty())) {
            syncCommunityUsers(userIdToEmailMap, userIdToFirstNameMap, userIdToLastNameMap, userIdToCompanyNameMap);
        }
    }

    private Map<Id, String> updatePersonEmail(Account account, Map<Id, String> userIdToEmailMap) {
        if (account.IsPersonAccount) {
            String accountEmail = account.PersonEmail;
            switch on account.Primary_Email__pc {
                when 'Work' {
                    if (String.isBlank(account.Work_Email__pc)) {
                        account.addError('Work Email is blank on account');
                    }
                    account.PersonEmail = account.Work_Email__pc;
                }
                when 'Personal' {
                    if (String.isBlank(account.Secondary_Email__pc)) {
                        account.addError('Secondary Email is blank on account');
                    }
                    account.PersonEmail = account.Secondary_Email__pc;
                }
                when 'Other' {
                    if (String.isBlank(account.Other_Email__pc)) {
                        account.addError('Other Email is blank on account');
                    }
                    account.PersonEmail = account.Other_Email__pc;
                }
            }
            if (account.PersonEmail != accountEmail) {
                List<User> users = [
                        SELECT Username
                        FROM User
                        WHERE Username = :account.PersonEmail
                     
                ];
                if (users.size() > 1) {
                    account.addError('This email is already a primary email for a different user.');
                } else {
                    userIdToEmailMap.put(account.CommunityUser__c, account.PersonEmail);
                }
            }
        }
        return userIdToEmailMap;
    }

    private Boolean validityCheck(String oldField, String newField) {
        if (oldField == null && newField == null) {
            return false;
        } else if (oldField == null && newField != null) {
            return true;
        } else if (!oldField.equals(newField)) {
            return true;
        }
        return false;
    }

    @Future
    private static void syncCommunityUsers(Map<Id, String> userIdToEmailMap, Map<Id, String> userIdToFirstNameMap, Map<Id, String> userIdToLastNameMap, Map<Id, String> userIdToCompanyNameMap) {
        List<User> usersToUpdate = new List<User>();
        Set<Id> consolidatedIds = new Set<Id>();
        consolidatedIds.addAll(userIdToFirstNameMap.keySet());
        consolidatedIds.addAll(userIdToLastNameMap.keySet());
        consolidatedIds.addAll(userIdToCompanyNameMap.keySet());
        consolidatedIds.addAll(userIdToEmailMap.keySet());
        Boolean isChanged = false;
        for (User user : ACAMSUserDAO.queryCommunityUsersByIdsAndProfiles(
                consolidatedIds, new Set<String>{
                        ACAMSUtil.B2B_COMMERCE_USER_PROFILE
                })
        ) {
            if (!userIdToEmailMap.isEmpty()) {
                String userEmail = userIdToEmailMap.get(user.Id);
                if (user.Email != userEmail || user.Username != userEmail) {
                    user.Email = userEmail;
                    user.Username = userEmail;
                    isChanged = true;
                }
            }
            if (!userIdToFirstNameMap.isEmpty()) {
                user.FirstName = userIdToFirstNameMap.get(user.Id) == null ? user.FirstName : userIdToFirstNameMap.get(user.Id);
                isChanged = true;
            }
            if (!userIdToLastNameMap.isEmpty()) {
                user.LastName = userIdToLastNameMap.get(user.Id) == null ? user.LastName : userIdToLastNameMap.get(user.Id);
                isChanged = true;
            }
            if (!userIdToCompanyNameMap.isEmpty()) {
                user.CompanyName = userIdToCompanyNameMap.get(user.Id) == null ? user.CompanyName : userIdToCompanyNameMap.get(user.Id);
                isChanged = true;
            }
            if (isChanged) {
                usersToUpdate.add(user);
            }
        }
        if (usersToUpdate.isEmpty()) {
            return;
        }
        try {
            update usersToUpdate;
        } catch (Exception e) {
            
            //csa fix added exception logger statement. 
           ACAMSUtil.reportException(null, null,'syncCommunityUsers Method', null, e.getMessage(), null, null);
        }
    }

    public static void UpsertLMSUser(List<Account> newContacts, Map<Id, Account> oldMapContacts) {
        try {
            if (raiseException) {
                throw new customException('Testing code');
            }
            Set<Id> contactIds = new Set<Id>();
            Map<Id, User> contactUserMap = new Map<Id, User>();
            List<LMSUtility.LMSUserRequest> lmsuserList = new List<LMSUtility.LMSUserRequest>();
            //When new Language field is added: Language should be added and LMSIntegration user update should be excluded
            if (newContacts != null && newContacts.size() > 0 && oldMapContacts != null && oldMapContacts.size() > 0) {
                for (Account c : newContacts) {
                    isLMSUserCreated = true;
                    LMSUtility.LMSUserRequest lmsuser = new LMSUtility.LMSUserRequest();
                    lmsuser.contactId = c.Id;
                    lmsuser.firstName = c.FirstName;
                    lmsuser.lastName = c.LastName;
                    if (c.Primary_Email__pc == 'Work' && c.Work_Email__pc != null) {
                        lmsuser.username = c.Work_Email__pc;
                    } else if (c.Primary_Email__pc == 'Personal' && c.Secondary_Email__pc != null) {
                        lmsuser.username = c.Secondary_Email__pc;
                    } else if (c.Primary_Email__pc == 'Other' && c.Other_Email__pc != null) {
                        lmsuser.username = c.Other_Email__pc;
                    } else {
                        lmsuser.username = c.PersonEmail;
                    }
                    lmsuser.language = '';
                    lmsuser.enabled = true;
                    if ((c.Membership_Type__pc != ACAMSUtil.MEMBER_CAPS && c.Membership_Type__pc != null) && !c.Premium_Webinar_Subscriber__pc) {//FSA-1048
                       if (c.Membership_Type__pc == 'NON-MEMBER') {
                            lmsuser.customerType = 'NON_MEMBER';
                        } else {
                            lmsuser.customerType = c.Membership_Type__pc;
                        }
                    } else {
                        lmsuser.customerType = ACAMSUtil.ENTERPRISE_CAPS;
                    }
                    lmsuserList.add(lmsuser);
                    contactIds.add(c.Id);
                }
                 if (contactIds.size() > 0) {
                    for (Account a : [
                            SELECT CommunityUser__r.AccountId,
                                    CommunityUser__r.FirstName, CommunityUser__r.Username, CommunityUser__r.LastName,
                                    CommunityUser__r.LMS_Role__c, CommunityUser__r.TimeZoneSidKey
                            FROM Account
                            WHERE Id IN :contactIds
                            FOR UPDATE
                    ]) {
                        contactUserMap.put(a.CommunityUser__r.AccountId, a.CommunityUser__r);
                    }
                    for (LMSUtility.LMSUserRequest lmsU : lmsuserList) {
                        if (contactUserMap.containsKey(lmsU.contactId)) {
                            User u = contactUserMap.get(lmsU.contactId);
                            lmsU.username = (lmsU.username == null ? u.Username : lmsU.username);
                            lmsU.firstName = (!String.isNotBlank(lmsU.firstName) ? u.FirstName : lmsU.firstName);
                            lmsU.lastName = (!String.isNotBlank(lmsU.lastName) ? u.LastName : lmsU.lastName);
                            lmsU.role = u.LMS_Role__c;
                            lmsU.timezone = ''; //lmsU.timezone = u.TimeZoneSidKey; -- Waiting for Timezone Integration
                        }
                    }
                    
                }
            }
            if (lmsuserList.size() > 0) {
                CalloutUtility.SendRequest('UserIntegration', true, LMSUtility.BuildJson(lmsuserList));
            }
        } catch (Exception ex) {
             //csa fix added exception logger statement. 
           ACAMSUtil.reportException(null, null,'MergeLMSUser Method', null, ex.getMessage(), null, null);
        }
    }
    public static void MemberUpdateOnUser(List<Account> NewContacts, Map<Id, Account> oldMapContacts) {
       // Set<Id> cntid = new Set<Id>();
        for (Account nc : NewContacts) {
            Account oldC = oldMapContacts.get(nc.Id);
            if (oldC != null && nc.Membership_Type__pc != oldC.Membership_Type__pc) {
                //cntid.add(nc.Id);
                //FSA-6834
                pushAccountMethodEvents(nc.Id,'MemberUpdateOnUser');
            }
        }
        // FSA-6834 Moved to ACAMSAccountMethodEventsTrigger
      /*  List<User> Userlist = [
                SELECT Id, Membership_Type__c, Contact_Member_Type__c
                FROM User
                WHERE AccountId IN :cntid
        ];
        for (User usr : Userlist) {
            usr.Membership_Type__c = usr.Contact_Member_Type__c;
        }
        update Userlist;
*/
    }
    public static void CreatePortalUserAccount(List<Account> acc) {
        List<User> lstuser = new List<User>();
        User objuser;
        if (UserInfo.getUserId() != drupalIntegration.Id) {
            for (Account objAccount : acc) {
                //System.debug('ownerId:' + objAccount.OwnerId);
                if (objAccount.IsPersonAccount) {
                    if (objAccount.PersonEmail != null) {
                        objuser = new User();
                        objuser.ContactId = objAccount.PersonContactId;
                        objuser.LastName = objAccount.LastName;
                        if (objAccount.FirstName != null) {
                            String firstNameSub = objAccount.FirstName.length() > 2 ?
                                    objAccount.FirstName.substring(0, 2) : objAccount.FirstName;
                            String lastNameSub = objAccount.LastName.length() > 3 ?
                                    objAccount.LastName.substring(0, 3) : objAccount.LastName;
                            objuser.FirstName = objAccount.FirstName;
                            objuser.Alias = firstNameSub + lastNameSub;
                            objuser.CommunityNickname = firstNameSub + lastNameSub + '_' + Math.random();
                        } else {
                            String lastNameSub = objAccount.LastName.length() > 5 ?
                                    objAccount.LastName.substring(0, 5) : objAccount.LastName;
                            objuser.Alias = lastNameSub;
                            objuser.CommunityNickname = lastNameSub + '_' + Math.random();
                        }
                        objuser.Email = objAccount.PersonEmail;
                        objuser.Username = objAccount.PersonEmail;
                        objuser.ProfileId = ACAMSUserDAO.getB2BProfile().Id;
                        objuser.isMigrated__c = true;
                        objuser.IsActive = true;
                        objuser.TimeZoneSidKey = 'America/New_York';
                        objuser.LocaleSidKey = 'en_US';
                        objuser.EmailEncodingKey = 'ISO-8859-1';
                        objuser.LanguageLocaleKey = 'en_US';
                        //ACR - 2796
                        if (!String.isBlank(objAccount.Language_Preference__c)) {
                            objuser.LocaleSidKey = objAccount.Language_Preference__c;
                            objuser.LanguageLocaleKey = objAccount.Language_Preference__c;
                        }
                        objuser.ccrz__CC_CurrencyCode__c = 'USD';
                        objuser.Member_Number_Text__c = objAccount.Member_Number__c;
                        objuser.Account_Id__c=objAccount.id;
                        lstuser.add(objuser);
                        
                    }
                }
            }
            if (lstuser.size() > 0 && !Test.isRunningTest()) {
                try{
                    insert lstuser;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'CreatePortalUserAccount Method', null, ex.getMessage(), null, null);
                }
                  
            }
            //FSA-477
            if(userinfo.getUserId() != label.Guest_User_Id) {
             Set<Id> pwduserIds = new Set<Id>();
            for(user u: lstuser) {pwduserIds.add(u.Id);}
            setPwdOnPersonAccCreation(pwduserIds);
            }
            /*if (!Test.isRunningTest()) {
                for (User objUs : lstuser) {
                    System.debug('Passworset:  ' + 'Acams' + '!' + objuser.Member_Number_Text__c);
                    if (objuser.Member_Number_Text__c != null) {
                        System.setPassword(objUs.Id, 'Acams' + '!' + objuser.Member_Number_Text__c);
                    }
                }
            }*/
            //FSA-477
        }
    }
  //FSA-477
  @future
    public static void setPwdOnPersonAccCreation(Set<Id> uIds) {
        List<User> userToUpdate = new List<User>();
        List<User> pwdUsers = [select Id, Reset_Password__c from User where id in: uIds];
        for (User objUs : pwdUsers) {
           objUs.Reset_Password__c = true;
            userToUpdate.add(objUs); 
        }
        if (userToUpdate.size() > 0 && !Test.isRunningTest()) {
            	try{
                    update userToUpdate;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'setPwdOnPersonAccCreation Method', null, ex.getMessage(), null, null);
                }
                
        }
    }
    //FSA-477
    private void validatePhoneNumbers() {
        if (!ACAMSUtil.bypassPhoneValidation && !System.isFuture() &&
                UserInfo.getUserEmail() != 'marketingautomation@adtalem.com') {
            for (Account account : newList) {
                if (account.IsPersonAccount) {
                    if (oldList != null && account.HL_Mod_Date__pc != oldMap.get(account.Id).HL_Mod_Date__pc) {
                        continue;
                    }
                    Pattern phonePattern = ACAMSUtil.getPhoneFormattingPattern();
                    String phone = account.Phone;
                    String homePhone = account.PersonHomePhone;
                    String mobilePhone = account.PersonMobilePhone;
                    if ((oldList == null || oldMap.get(account.Id).Phone != phone) && phone != null &&
                            !phonePattern.matcher(phone).matches()) {
                        account.Phone.addError(ACAMSUtil.PHONE_NUMBER_FORMAT_ERROR);
                    }
                    if ((oldList == null || oldMap.get(account.Id).PersonHomePhone != homePhone) && homePhone != null &&
                            !phonePattern.matcher(homePhone).matches()) {
                        account.PersonHomePhone.addError(ACAMSUtil.PHONE_NUMBER_FORMAT_ERROR);
                    }
                    if ((oldList == null || oldMap.get(account.Id).PersonMobilePhone != mobilePhone) &&
                            mobilePhone != null && !phonePattern.matcher(mobilePhone).matches()) {
                        account.PersonMobilePhone.addError(ACAMSUtil.PHONE_NUMBER_FORMAT_ERROR);
                    }
                }
            }
        }
        ACAMSUtil.bypassPhoneValidation = false;
    }

    private Lead generateLead(Account a, AssignmentRule assignmentRule) {
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;

        Lead lead = new Lead(
                LastName = a.LastName,
                FirstName = a.FirstName,
                Company_Name__c = a.ccrz__CompanyName__pc,
                Industry = a.Industry,
                Country = a.BillingCountry,
                CountryCode = a.BillingCountryCode,
                State = a.BillingState,
                StateCode = a.BillingStateCode,
                Email = a.PersonEmail,
                Phone = a.Phone
        );

        dmlOpts.DuplicateRuleHeader.AllowSave = true;
        lead.setOptions(dmlOpts);
        return lead;
    }
    //FSA-6834
     public static void pushAccountMethodEvents(ID recordId, String methodName){
        List<Account_method__e> accountMethodEvents = new List<Account_method__e>();
        accountMethodEvents.add(new Account_method__e(Record_ID__c=recordId,Method_Name__c=methodName));
        
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(accountMethodEvents);
        
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
    //csa fix implemented workflow rule logic here
    public static void handleCheckCamsFlagInsert(list<Account> accounts){
        String profileName;
        if(userinfo.getName()!='Automated Process'){
        	profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        }
        for(Account acc : accounts){
            if((acc.ACAMS_Cert__c == true || acc.Member_Flag__c == true)
              && profileName !='Data Migration'){
				acc.CAMS__c = true;
                acc.CAMS_Expiration_Date__c = (acc.Member_Flag__c == true && acc.ACAMS_Cert__c == true) ? acc.Cert_Expiration_Date__c : null;
            }
        }
    }
    //csa fix implemented workflow rule logic here
    public static void handleCheckCamsFlagUpdate(list<Account> accounts,map<Id,Account> oldMap){
        String profileName;
        if(userinfo.getName()!='Automated Process'){
        	profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        }
        for(Account acc : accounts){
            if((oldMap.get(acc.Id).ACAMS_Cert__c != acc.ACAMS_Cert__c || oldMap.get(acc.Id).Member_Flag__c != acc.Member_Flag__c)
              && profileName !='Data Migration'){
				acc.CAMS__c = true;
                acc.CAMS_Expiration_Date__c = (acc.Member_Flag__c == true && acc.ACAMS_Cert__c == true) ? acc.Cert_Expiration_Date__c : null;
            }
        }
    }

}