global class ACAMSInvoiceVertexScheduler implements Schedulable, Database.Batchable<SObject> {

    global void execute(SchedulableContext context) {
        Database.executeBatch(new ACAMSInvoiceVertexScheduler());
    }

    // FSA-1350
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
                SELECT
                        Id
                FROM
                        ccrz__E_Invoice__c
                WHERE
                        Finalized__c = TRUE
                AND
                        Seller_Tax_Registration_ID__c = NULL
                AND
                        CreatedBy.Name != 'Data Migration'
                AND
                        Sent_to_Vertex__c = FALSE
                AND
                        Destination_Country__c != 'China'
                AND     
                        ccrz__Status__c = 'Open'
                ORDER BY
                        createdDate 
                DESC 
                LIMIT 
                        900
        ]);
    }

    global void execute(Database.BatchableContext context, List<ccrz__E_Invoice__c> invoices) {
        try {
            List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure> requests =
                    new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>();
            for (ccrz__E_Invoice__c invoice : invoices) {
                Vertex.VertexAnyRequest.InvokeAnyRequestStructure request =
                        new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
                request.recordId = invoice.Id;
                request.type = 'CC Invoice';
                requests.add(request);
            }
            Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();
            if (!bypassSettings.Bypass_Invoice_Tax_Calculation__c) {
                Vertex.VertexAnyRequest.InvokeAllRequests(requests);
            }
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext context) {
    }
}