public with sharing class ACAMSCartTaxRecalculationController {
    @AuraEnabled
    public static void recalculateTaxes(String recordId){
        try {
            Vertex.VertexAnyRequest.InvokeAnyRequestStructure request =
                new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
            request.recordId = recordId;
            request.type = 'CC Cart';
            Vertex_Tax_Calculation_Bypass__c bypassSettings = Vertex_Tax_Calculation_Bypass__c.getInstance();
            if (!bypassSettings.Bypass_Cart_Tax_Calculation__c) {
                Vertex.VertexAnyRequest.InvokeAllRequests(
                    new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>{
                        request
                    }
                );
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}