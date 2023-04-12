trigger ACAMSValidateQueueNameTrigger on Assignment_Group_Queues__c (before insert, before update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSValidateQueueNameTriggerHandler()).run();
    }
}