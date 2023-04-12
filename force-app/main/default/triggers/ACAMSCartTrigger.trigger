trigger ACAMSCartTrigger on ccrz__E_Cart__c (before update, after update) {
    // FSA-773-a - add after update
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        new ACAMSCartTriggerHandler().run();
    }
}