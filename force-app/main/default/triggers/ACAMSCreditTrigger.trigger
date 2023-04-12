trigger ACAMSCreditTrigger on Credit__c (after insert, after update, after delete) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        new ACAMSCreditTriggerHandler().run();
    }
}