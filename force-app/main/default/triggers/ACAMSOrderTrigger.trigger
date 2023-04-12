trigger ACAMSOrderTrigger on ccrz__E_Order__c (before update,before insert,after update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        new ACAMSOrderTriggerHandler().run();
    }
}