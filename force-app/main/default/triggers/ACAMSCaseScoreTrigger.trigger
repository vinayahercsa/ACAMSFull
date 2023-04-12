trigger ACAMSCaseScoreTrigger on Contact_Center_Scorecard__c (before insert, before update ) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSCaseScoreTriggerHandler()).run();
    }
}