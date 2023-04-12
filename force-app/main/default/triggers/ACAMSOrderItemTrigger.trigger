trigger ACAMSOrderItemTrigger on ccrz__E_OrderItem__c (before insert, before update, after update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        new ACAMSOrderItemTriggerHandler().run();
    }
}