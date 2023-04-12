global without sharing class ACAMSSubscriptions extends ccrz.cc_hk_Subscriptions {

    /**
     * This override method makes sure that $0 recurring installments are not sent to Cybersource where trying to
     * capture a $0 auth will result in an error.
     */
    global override Map<String, Object> processRecurrInstallments(Map<String, Object> inputData) {
        Map<String, String> subIdToStoredPaymentMap = new Map<String, String>();
        List<ccrz__E_Subscription__c> subscriptionList = (List<ccrz__E_Subscription__c>) inputData.get(ccrz.cc_hk_Subscriptions.PARAM_PROCESS_SUBSCRIPTIONS);
        for (ccrz__E_Subscription__c sub : subscriptionList) {
            ccrz__E_Subscription__c amtSub = sub;

            final List<ccrz__E_Subscription__c> mainChildSub = sub.ccrz__CCSubscriptions__r;
            if ((null != mainChildSub) && !mainChildSub.isEmpty()) {
                amtSub = mainChildSub[0];
            }
            if ((sub.ccrz__RecurringPrice__c == null || sub.ccrz__RecurringPrice__c == 0) &&
                    (sub.ccrz__RecurringPriceSubAmt__c == null || sub.ccrz__RecurringPriceSubAmt__c == 0) &&
                    (amtSub.ccrz__RecurringPrice__c == null || amtSub.ccrz__RecurringPrice__c == 0) &&
                    (amtSub.ccrz__RecurringPriceSubAmt__c == null || amtSub.ccrz__RecurringPriceSubAmt__c == 0)) {
                subIdToStoredPaymentMap.put(sub.Id, sub.ccrz__StoredPayment__c);
                sub.ccrz__StoredPayment__c = null;
            }
        }
        Map<String, Object> outputData = super.processRecurrInstallments(inputData);
        List<ccrz__E_Subscription__c> subsToUpdate = new List<ccrz__E_Subscription__c>();
        for (ccrz__E_Subscription__c sub : subscriptionList) {
            if (subIdToStoredPaymentMap.containsKey(sub.Id)) {
                sub.ccrz__StoredPayment__c = subIdToStoredPaymentMap.get(sub.Id);
                subsToUpdate.add(sub);
            }
        }
        update subsToUpdate;
        return outputData;
    }
}