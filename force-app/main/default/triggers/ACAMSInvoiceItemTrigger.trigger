trigger ACAMSInvoiceItemTrigger on ccrz__E_InvoiceItem__c (before insert, before update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSInvoiceItemTriggerHandler()).run();
    }
}