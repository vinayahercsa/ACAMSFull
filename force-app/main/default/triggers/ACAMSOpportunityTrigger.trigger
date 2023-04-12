trigger ACAMSOpportunityTrigger on Opportunity (before insert,before update, after insert, after update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSOpportunityTriggerHandler()).run();
    }
}