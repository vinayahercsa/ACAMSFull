public without sharing class ACAMSUserTriggerHandler extends CCAviTriggerHandler {
    private List<User> newUsers;
    private Map<Id, User> newMap;
    private Map<Id, User> oldMap;
    public class customException extends Exception {
    }
    public static Boolean raiseException = false;
    public static Boolean isLMSUserCreated = false;
    public static Boolean isLMSUserUpdated = false;

    private static AssignmentRule assignmentRule = [
            SELECT Id
            FROM AssignmentRule
            WHERE SobjectType = 'Lead'
            AND Active = TRUE
            LIMIT 1
    ];

    public ACAMSUserTriggerHandler() {
        this.newUsers = (List<User>) Trigger.new;
        this.newMap = (Map<Id, User>) Trigger.newMap;
        this.oldMap = (Map<Id, User>) Trigger.oldMap;
    }

    public override void afterInsert() {
        Id b2bCommerceUserId;

        Profile profile = ACAMSUserDAO.getB2BProfile();
        b2bCommerceUserId = profile != null ? profile.Id : null;
        ccrz__E_AccountGroup__c portalAccount = ACAMSUserDAO.getAccountGroupByName(ACAMSUtil.PORTAL_ACCOUNT);
        ccrz__E_AccountGroup__c govMilPortalAccount =
                ACAMSUserDAO.getAccountGroupByName(ACAMSUtil.PORTAL_ACCOUNT_GOV);

        Set<Id> accountIds = new Set<Id>();

        if (b2bCommerceUserId != null) {
            for (User u : this.newUsers) {
                if (u.ProfileId == b2bCommerceUserId) {
                    accountIds.add(u.AccountId);
                }
            }

            Set<Id> userIds = new Set<Id>();
            for (Id userId : newMap.keySet()) {
                if (newMap.get(userId).ContactId != null) {
                    userIds.add(userId);
                }
            }

            Map<Id, Id> accountIdToCommunityIdMap = new Map<Id, Id>();
            Map<Id, User> usersMap = new Map<Id, User>(
                    ACAMSUserDAO.queryContactAccountsByIds(userIds)
            );

            for (Id userId : userIds) {
                try {
                    Id accountId = usersMap.get(userId).Contact.AccountId;
                    Id communityId = usersMap.get(userId).Contact.Account.CommunityUser__c;
                    if (communityId != userId) {
                        accountIdToCommunityIdMap.put(accountId, userId);
                    }
                } catch (Exception ex) {
                    System.debug(ex.getMessage() + '\n' + ex.getStackTraceString());
                }
            }
            List<Account> accounts = ACAMSAccountDAO.getPersonAccountsFromIds(accountIds);
            for (Account account : accounts) {
                if (account.PersonEmail.endsWith('.gov') || account.PersonEmail.endsWith('.mil') || (account.Industry == ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT ||
                        account.Industry == ACAMSUtil.INDUSTRY_GOV_REGULATORY)) {
                    account.ccrz__E_AccountGroup__c = govMilPortalAccount.Id;
                } else {
                    account.ccrz__E_AccountGroup__c = portalAccount.Id;
                }
                account.Type = ' '; //FSA-465
                Id communityId = accountIdToCommunityIdMap.get(account.Id);
                account.CommunityUser__c = communityId;
            }
            convertLeads(accountIds);

            if (Test.isRunningTest()) {
                update accounts;
            } else if (!System.isFuture() && !accounts.isEmpty()) {
                System.enqueueJob(new ACAMSUtil.UpdateObject(accounts));
            }
        }
    }

    public override void beforeUpdate() {
        syncUsernameAndEmail();
        ResetPassword(this.newUsers, this.oldMap);
    }

    public override void afterUpdate() {

        if (!isLMSUserUpdated) {
            UpsertLMSUser(this.newUsers, this.oldMap);
        }
        //ResetPassword(this.newUsers, this.oldMap);
        syncCommunityUsers();
    }

    public static void UpsertLMSUser(List<User> newUsers, Map<Id, User> oldMapUsers) {
        try {
            if (raiseException) throw new customException('Testing code');

            Set<Id> contactIds = new Set<Id>();
            Map<Id, Contact> contactsMap = new Map<Id, Contact>();
            List<LMSUtility.LMSUserRequest> lmsuserList = new List<LMSUtility.LMSUserRequest>();

            System.debug('*****UserHelper.UpsertLMSUser.newUsers: ' + newUsers);
            System.debug('*****UserHelper.UpsertLMSUser.oldMapUsers: ' + oldMapUsers);

            if (newUsers != null && newUsers.size() > 0) {
                System.debug('pass 1');
                for (User u : newUsers) {
                    User oldU = (oldMapUsers != null && oldMapUsers.size() > 0 ? oldMapUsers.get(u.Id) : null);
                    //When LMS to SF sync in place: LMSIntegration user update should be excluded
                    if (u.ContactId != null && ((oldU == null && u.LMS_Role__c != 'STUDENT') || (oldU != null && (u.LMS_Role__c != oldU.LMS_Role__c || u.TimeZoneSidKey != oldU.TimeZoneSidKey || u.Membership_Type__c != oldU.Membership_Type__c)))) {
                        System.debug('pass 2');
                        isLMSUserCreated = (oldMapUsers != null && oldMapUsers.size() > 0);
                        isLMSUserUpdated = !isLMSUserCreated;
                        LMSUtility.LMSUserRequest lmsuser = new LMSUtility.LMSUserRequest();
                        lmsuser.contactId = u.AccountId;
                        lmsuser.username = u.Username;
                        lmsuser.firstName = u.FirstName;
                        System.debug('New user fname' + u.FirstName);
                        lmsuser.lastName = u.LastName;
                        lmsuser.role = u.LMS_Role__c;
                        lmsuser.timezone = ''; //--lmsuser.timezone = u.TimeZoneSidKey;
                        lmsuser.enabled = true;
                       if (u.Contact_Member_Type__c != 'MEMBER' && u.Contact_Member_Type__c != null) {
                            if (u.Contact_Member_Type__c == 'NON-MEMBER') {
                                lmsuser.customerType = 'NON_MEMBER';
                            } else {
                                lmsuser.customerType = u.Contact_Member_Type__c;
                            }
                        } else {
                            lmsuser.customerType = 'ENTERPRISE';
                        }

                        lmsuserList.add(lmsuser);

                        contactIds.add(u.ContactId);
                    }
                }
                System.debug('*****UserHelper.UpsertLMSUser.contactIds: ' + contactIds);

                if (contactIds.size() > 0) {
                    //When new Language field is added: Language should be added
                    for (Contact c : [SELECT Id, FirstName, LastName FROM Contact WHERE Id IN:contactIds]) {
                        contactsMap.put(c.Id, c);
                    }
                    for (LMSUtility.LMSUserRequest lmsU : lmsuserList) {
                        if (contactsMap.containsKey(lmsU.contactId)) {
                            Contact c = contactsMap.get(lmsU.contactId);
                            lmsU.firstName = (String.isNotBlank(c.FirstName) && c.FirstName != lmsU.firstName ? c.FirstName : lmsU.firstName);
                            lmsU.lastName = (String.isNotBlank(c.LastName) && c.LastName != lmsU.lastName ? c.LastName : lmsU.lastName);
                            lmsU.language = '';
                        }
                    }
                    System.debug('*****UserHelper.UpsertLMSUser.contactsMap: ' + contactsMap);
                }
            }
            System.debug('*****UserHelper.UpsertLMSUser.lmsuserList: ' + lmsuserList);

            if (lmsuserList.size() > 0) {
                CalloutUtility.SendRequest('UserIntegration', true, LMSUtility.BuildJson(lmsuserList));
            }
        } catch (Exception ex) {

        }
    }

    public static void ResetPassword(List<User> nUser, Map<Id, User> oUser) {
        for (User uobj : nUser) {
            if (uobj.Reset_Password__c == TRUE) {
                User oldUser = oUser.get(uobj.Id);
              //  if (oldUser.Reset_Password__c != uobj.Reset_Password__c) {
                    //Only update User password to Member Number if the Reset Password field was just changed from false to true
                    String userId = uobj.id;
                    String membnum = randomSixCharacterGenerator(6) + randomNineDigitGenerator(); // FSA-533
                    system.debug(membnum);
                    system.setPassword(uobj.id, membnum);
                    uobj.Reset_Password__c = false;
                    uobj.Generated_Password__c = membnum;
                    uobj.Default_Password_Generated_On__c = DateTime.now();
              //  }
            }
        }
    }
    private static Integer randomNineDigitGenerator(){
        return Math.round((Math.random() * (899999999) + 100000000));// FSA-533
    }
    //FSA-533
    private static String randomSixCharacterGenerator(Integer length){
    	List<String> randomString = new List<String>();
    	String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	    String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
	    String specialChars = '!#$%@&*';
	    
	    boolean nextIsUppercase = false;
	    boolean nextIsLowercase = false;
	    boolean nextIsSpecial = true;	    
	    
	    for (integer i = 0; i < length; i++) {

	        if (nextIsSpecial) {
	        	Integer pointer = Math.mod(Math.abs(Crypto.getRandomInteger()), specialChars.length());
	            randomString.add(specialChars.subString(pointer,pointer+1));
	            nextIsUppercase = true;
	            nextIsSpecial = false;
	            continue;
	        }
	
	        if (nextIsUppercase) {
	        	Integer pointer = Math.mod(Math.abs(Crypto.getRandomInteger()), uppercaseChars.length());
	            randomString.add(uppercaseChars.subString(pointer,pointer+1));
	            nextIsUppercase = false;
	            nextIsLowercase = true;
	            continue;
	        }
	
	        if (nextIsLowercase) {
	        	Integer pointer = Math.mod(Math.abs(Crypto.getRandomInteger()), lowercaseChars.length());
	            randomString.add(lowercaseChars.subString(pointer,pointer+1));
	            nextIsLowercase = false;
	            nextIsSpecial = true;
	            continue;
	        }

        }

    	return String.join(randomString,'');
    }//FSA-533

    @Future
    private static void convertLeads(Set<Id> accountIds) {
        Map<String, Account> emailToAccountMap = new Map<String, Account>();
        List<String> emails = new List<String>();
        List<Account> accounts = ACAMSAccountDAO.getPersonAccountsFromIds(accountIds);
        for (Account a : accounts) {
            if (a.IsPersonAccount && a.PersonContactId != null) {
                emails.add(a.PersonEmail);
                emailToAccountMap.put(a.PersonEmail, a);
            }
        }
        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        List<Lead> leads = ACAMSAccountDAO.queryLeadsByEmails(emails);
        Map<String, String> ownerIdToAccountIdMap = new Map<String, String>();

        for (Lead lead : leads) {
            if (emailToAccountMap.containsKey(lead.Email)) {
                Account a = emailToAccountMap.remove(lead.Email);
                if (lead.ConvertedAccountId == null) {
                    lead.setOptions(dmlOpts);
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(lead.Id);
                    lc.setDoNotCreateOpportunity(true);
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    lc.setAccountId(a.Id);

                    Database.LeadConvertResult lcr = Database.convertLead(lc, dmlOpts);
                    System.debug('Converting lead + ' + lead.Id + ' to Account ' + a.Id + '. Success: ' + lcr.isSuccess());
                    ownerIdToAccountIdMap.put(lead.OwnerId, a.Id);
                }
            }
        }
        updateAccountOwnerIds(ownerIdToAccountIdMap);
    }

    private static void updateAccountOwnerIds(Map<String, String> ownerIdToAccountIdMap) {
        Map<Id, Account> accountsMap = new Map<Id, Account>([
                SELECT OwnerId
                FROM Account
                WHERE Id IN :ownerIdToAccountIdMap.values()
        ]);
        for (String ownerId : ownerIdToAccountIdMap.keySet()) {
            accountsMap.get(ownerIdToAccountIdMap.get(ownerId)).OwnerId = ownerId;
        }
        update accountsMap.values();
    }

    private void syncUsernameAndEmail() {
        Profile profile = ACAMSUserDAO.getB2BProfile();
        for (User user : this.newUsers) {
            if (user.ProfileId == profile.Id) {
                if (user.Username != this.oldMap.get(user.Id).Username) {
                    if (user.Username != user.Email) {
                        user.Email = user.Username;
                    }
                } else if (user.Email != this.oldMap.get(user.Id).Email) {
                    if (user.Username != user.Email) {
                        user.Username = user.Email;
                    }
                }
            }
        }
    }

    private void syncCommunityUsers() {
        Map<Id, String> accountIdToEmailMap = new Map<Id, String>();
        Map<Id, String> accountIdToCompanyNameMap = new Map<Id, String>();
        Map<Id, String> accountIdToFirstNameMap = new Map<Id, String>();
        Map<Id, String> accountIdToLastNameMap = new Map<Id, String>();
        for (User user : ACAMSUserDAO.queryCommunityUsersByIdsAndProfiles(
                this.newMap.keySet(), new Set<String>{
                        ACAMSUtil.B2B_COMMERCE_USER_PROFILE
                })
        ) {
            if (user.Username != oldMap.get(user.Id).Username) {
                accountIdToEmailMap.put(user.Account_Id__c, user.Username);
            }

            if (user.CompanyName != null && !user.CompanyName.equalsIgnoreCase(oldMap.get(user.Id).CompanyName)) {
                accountIdToCompanyNameMap.put(user.Account_Id__c, user.CompanyName);
            }

            if (user.FirstName != null && !user.FirstName.equalsIgnoreCase(oldMap.get(user.Id).FirstName)) {
                accountIdToFirstNameMap.put(user.Account_Id__c, user.FirstName);
            }

            if (user.LastName != null && !user.LastName.equalsIgnoreCase(oldMap.get(user.Id).LastName)) {
                accountIdToLastNameMap.put(user.Account_Id__c, user.LastName);
            }
        }
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> consolidatedIds = new Set<Id>();
        consolidatedIds.addAll(accountIdToFirstNameMap.keySet());
        consolidatedIds.addAll(accountIdToLastNameMap.keySet());
        consolidatedIds.addAll(accountIdToCompanyNameMap.keySet());
        consolidatedIds.addAll(accountIdToEmailMap.keySet());
        for (Account account : [
                SELECT  Id, Primary_Email__pc, Work_Email__pc, Secondary_Email__pc, Other_Email__pc, FirstName,
                        LastName,ccrz__CompanyName__pc
                FROM Account
                WHERE Id IN :consolidatedIds
        ]) {
            if (accountIdToEmailMap.containsKey(account.Id)) {
                if (account.Primary_Email__pc == 'Work' || account.Primary_Email__pc == null) {
                    account.Work_Email__pc = accountIdToEmailMap.get(account.Id);
                } else if (account.Primary_Email__pc == 'Personal') {
                    account.Secondary_Email__pc = accountIdToEmailMap.get(account.Id);
                } else if (account.Primary_Email__pc == 'Other') {
                    account.Other_Email__pc = accountIdToEmailMap.get(account.Id);
                }
            }
            if (accountIdToCompanyNameMap.containsKey(account.Id)) {
                account.ccrz__CompanyName__pc = accountIdToCompanyNameMap.get(account.Id);
            }
            if (accountIdToFirstNameMap.containsKey(account.Id)) {
                account.FirstName = accountIdToFirstNameMap.get(account.Id) == null ? account.FirstName :
                        accountIdToFirstNameMap.get(account.Id);
            }
            if (accountIdToLastNameMap.containsKey(account.Id)) {
                account.LastName = accountIdToLastNameMap.get(account.Id) == null ? account.LastName :
                        accountIdToLastNameMap.get(account.Id);
            }
            accountsToUpdate.add(account);
        }

        if (!accountsToUpdate.isEmpty()) {
            System.enqueueJob(new ACAMSUtil.UpdateObject(accountsToUpdate));
        }
    }
}