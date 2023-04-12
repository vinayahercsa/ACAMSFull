trigger ACAMSRecertCycleTrigger on Recert_Cycle__c (after update ,before Update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
            (new ACAMSRecertCycleTriggerHandler()).run();
    }
}