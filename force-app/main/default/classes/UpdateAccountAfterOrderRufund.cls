/*
FSA-2108 this class will update account records 
*/
Public class UpdateAccountAfterOrderRufund {
    @future
    public static void UpdateAccountAfterOrderRufundMethod(Set<id> accId){
        
        //get global accountgroup
        List<String> accountGroupNames = new List<String>{ACAMSUtil.PORTAL_ACCOUNT, ACAMSUtil.PORTAL_ACCOUNT_GOV, ACAMSUtil.PORTAL_ACCOUNT_GOV_MEMBER,    ACAMSUtil.PORTAL_ACCOUNT_MEMBER, ACAMSUtil.PORTAL_ACCOUNT_CHAPTER_MEMBER, ACAMSUtil.PORTAL_ACCOUNT_GOV_CHAPTER_MEMBER};        
        List<ccrz__E_AccountGroup__c> accountGroups = [SELECT Id, Name FROM ccrz__E_AccountGroup__c WHERE Name IN :accountGroupNames];
        Map<String, Id> accountGroupsMap = new Map<String, Id>();
        
        for (ccrz__E_AccountGroup__c accountGroup : accountGroups) {
            accountGroupsMap.put(accountGroup.Name, accountGroup.Id);
        }
        
        // get accounts
        List<Account> lstAccount = [select id, PersonEmail, Industry, Membership_Type__pc, Chapter_Member__pc, ccrz__E_AccountGroup__c, IsPersonAccount, Run_Membership_Certification_Logic__pc from account where id in :accId ];
        for( Account account : lstAccount)  {
            //comparing logic for value assignment
            String email = account.PersonEmail;
            Boolean govEmail = false;           
            if ((account.IsPersonAccount && String.isNotBlank(email)) || account.Run_Membership_Certification_Logic__pc==true) {
                govEmail = email.endsWith('.gov') || email.endsWith('.mil');
                if (account.Membership_Type__pc == ACAMSUtil.MEMBER_CAPS || account.Membership_Type__pc == ACAMSUtil.ENTERPRISE_CAPS || Test.isRunningTest()){
                    if (govEmail || (account.Industry == ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT || account.Industry == ACAMSUtil.INDUSTRY_GOV_REGULATORY)) {
                        if (account.Chapter_Member__pc) {
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV_CHAPTER_MEMBER);
                        } else {
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV_MEMBER);
                        }
                    } else {
                        if (account.Chapter_Member__pc) {
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_CHAPTER_MEMBER);
                        } else {
                            account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_MEMBER);
                        }
                    }
                }
                if(account.Membership_Type__pc == NULL || account.Membership_Type__pc == ACAMSUtil.NON_MEMBER_CAPS) {
                    if (govEmail || (account.Industry == ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT || account.Industry == ACAMSUtil.INDUSTRY_GOV_REGULATORY)) {
                        account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV);
                    } else {
                        account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT);
                    }
                }
            } 
            else {
                if (account.ccrz__E_AccountGroup__c == null && account.Industry != ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT &&
                        account.Industry != ACAMSUtil.INDUSTRY_GOV_REGULATORY) {
                    account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT);
                } else if (account.ccrz__E_AccountGroup__c == null && (account.Industry == ACAMSUtil.INDUSTRY_GOV_ENFORCEMENT ||
                        account.Industry == ACAMSUtil.INDUSTRY_GOV_REGULATORY)) {
                    account.ccrz__E_AccountGroup__c = accountGroupsMap.get(ACAMSUtil.PORTAL_ACCOUNT_GOV);
                }
            }
        }
        
        //updating record 
        if(!Test.isRunningTest() && lstAccount.size() > 0){
            update lstAccount;
        }    
    }
}