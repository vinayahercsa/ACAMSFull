public with sharing class ACAMSSubscriptionDAO {

    public static List<ccrz__E_Subscription__c> getSubscriptionsByOrder(Id orderId) {
        List<ccrz__E_Subscription__c> subs = [
                SELECT
                        ccrz__AutoRenew__c,
                        ccrz__CCOrder__c,
                        ccrz__CCOrderItem__c,
                        ccrz__SPT__r.ccrz__SubProdTermId__c
                FROM
                        ccrz__E_Subscription__c
                WHERE
                        ccrz__CCOrder__c = :orderId
        ];
        return subs;
    }
}