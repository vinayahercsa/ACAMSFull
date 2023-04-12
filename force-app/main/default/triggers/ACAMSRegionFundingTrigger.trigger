trigger ACAMSRegionFundingTrigger on Regional_Funding__c (Before insert,Before update,After insert,After update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSRegionFundingTriggerHandler()).run();
    }
}