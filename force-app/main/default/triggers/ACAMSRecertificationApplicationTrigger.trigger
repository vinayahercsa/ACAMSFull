trigger ACAMSRecertificationApplicationTrigger on Recertification_Application__c (before insert, before update,
        after insert, after update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        new ACAMSRecertAppTriggerHandler().run();
    }
}