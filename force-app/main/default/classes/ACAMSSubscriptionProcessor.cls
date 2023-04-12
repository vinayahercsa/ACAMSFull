global class ACAMSSubscriptionProcessor implements Schedulable {
    global void execute(SchedulableContext sc) {
        Map<String, Object> params = new Map<String, Object>{
                ccrz.cc_batch_SubscriptionProcessor.STOREFRONT => 'acams',
                ccrz.cc_batch_SubscriptionProcessor.PROC_CONTEXT => null,
                ccrz.cc_batch_SubscriptionProcessor.USE_CONTINUANCE => true,
                ccrz.cc_batch_SubscriptionProcessor.CONTINUATION_SCOPE => 1
        };

        Database.executeBatch(new ccrz.cc_batch_SubscriptionProcessor(params));
    }
}