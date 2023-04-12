public class ACAMSZeroDollarTransaction {
    @future
    public static void updateCCTransactionPayments(Id transxId, Id orderId) {
        List<Asset> assetList = new List<Asset>();

        // Query for the invoice related to the order
        ccrz__E_Invoice__c invList = [SELECT Id, ccrz__CCOrder__c FROM ccrz__E_Invoice__c WHERE ccrz__CCOrder__c = :orderId];

        // Query for the transaction payment
        List<ccrz__E_TransactionPayment__c> ccrPayment = [SELECT Id, ccrz__CCOrder__c, ccrz__TransactionTS__c, ccrz__InvoiceAppliedFor__c FROM ccrz__E_TransactionPayment__c WHERE Id = :transxId];

        if (ccrPayment.size() > 0) {
            ccrPayment[0].ccrz__CCOrder__c = orderId;
            ccrPayment[0].ccrz__InvoiceAppliedFor__c = invList.Id;
            update ccrPayment[0];
        }

        // Query for the order 
        ccrz__E_Order__c orderRec = [SELECT Id, ccrz__OrderStatus__c, Opportunity__c, Total_Order_Amount__c, (SELECT Id, Status__c FROM Assets__r) FROM ccrz__E_Order__c WHERE Id = :orderId];

        if (orderRec != null && orderRec.Total_Order_Amount__c < 1) {
            for (Asset assetZero : orderRec.Assets__r) {
                assetZero.status__c = 'Active';
                assetZero.Payment_Status__c = 'Completed';
                assetZero.Paid_Cert__c = true;
                assetList.add(assetZero);
            }
        }

        // Csa fix:Update all asset
        if (!assetList.isEmpty()) {
            try{
                update assetList;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'updateCCTransactionPayments Method', null, ex.getMessage(), null, null);
            }
        }

        // Csa fix:Query for the opportunity
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :orderRec.Opportunity__c];

        if (opp != null) {
            opp.StageName = 'Closed Won';
            try{
                update opp;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'updateCCTransactionPayments Method', null, ex.getMessage(), null, null);
            }
        }
    }
}