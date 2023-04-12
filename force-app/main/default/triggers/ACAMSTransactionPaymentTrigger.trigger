trigger ACAMSTransactionPaymentTrigger on ccrz__E_TransactionPayment__c (before insert, after insert) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        new ACAMSTransactionPaymentTriggerHandler().run();
    }
}