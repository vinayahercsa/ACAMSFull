global class ACAMSInvoiceSDocScheduler implements Schedulable, Database.Batchable<SObject> {


    global void execute(SchedulableContext context) {
        Integer batchScope;
        batchScope = Integer.valueof(Label.VertexBatchSize);
        Database.executeBatch(new ACAMSInvoiceSDocScheduler(), batchScope);
    }

    global Database.QueryLocator start(Database.BatchableContext context) {
        User drupalUser = ACAMSUserDAO.getDrupalIntegrationUser();
        return Database.getQueryLocator([
                SELECT Id, ccrz__CCOrder__r.ccrz__OrderStatus__c, (
                        SELECT Id
                        FROM ccrz__ChildInvoices__r
                        WHERE ccrz__OriginalAmount__c != 0
                )
                FROM ccrz__E_Invoice__c
                WHERE Sold_To_Tax_Area_Id__c != NULL
                AND Finalized__c = FALSE AND ccrz__OriginalAmount__c != 0
                AND (
                        (
                                ccrz__CCOrder__r.ccrz__OrderStatus__c = :ACAMSUtil.INVOICED
                                AND ccrz__CCOrder__r.ccrz__PaymentMethod__c = :ACAMSUtil.INVOICE
                        )
                        OR ccrz__CCOrder__r.ccrz__OrderStatus__c = 'On Hold'
                    OR ccrz__CCOrder__r.ccrz__OrderStatus__c =: ACAMSUtil.COMPLETED
                )
                AND ccrz__CCOrder__r.CreatedById = :drupalUser.Id
        ]);
    }

    global void execute(Database.BatchableContext context, List<ccrz__E_Invoice__c> invoices) {
        Try{
            List<ccrz__E_Invoice__c> invoicesToUpdate = new List<ccrz__E_Invoice__c>();
            for (ccrz__E_Invoice__c invoice : invoices) {
                if (invoice.ccrz__ChildInvoices__r.size() == 0) {
                    invoice.Finalized__c = true;
                    invoicesToUpdate.add(invoice);
                }
              }
        update invoicesToUpdate;
        }
        catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString());
               ACAMSUtil.reportException(null, null,'Vertex Batch', null, e.getMessage(), null, null);
            }
    }

    global void finish(Database.BatchableContext param1) {
    }
}