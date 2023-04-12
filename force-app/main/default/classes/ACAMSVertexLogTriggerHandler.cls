public without sharing class ACAMSVertexLogTriggerHandler extends CCAviTriggerHandler {

    private List<Vertex__VertexLog__c> newList = (List<Vertex__VertexLog__c>) Trigger.new;
    private List<Vertex__VertexLog__c> oldList = (List<Vertex__VertexLog__c>) Trigger.old;
    private Map<Id, Vertex__VertexLog__c> newMap = (Map<Id, Vertex__VertexLog__c>) Trigger.newMap;
    private Map<Id, Vertex__VertexLog__c> oldMap = (Map<Id, Vertex__VertexLog__c>) Trigger.oldMap;

    public static Boolean skipInvoiceItemUpdateFromResponse = false;

    protected override void afterInsert() {
        if (!skipInvoiceItemUpdateFromResponse) {
           // ACAMSInvoiceService.updateInvoiceItemsWithVertexResponse(this.newList); // FSA-537
        }
    }
}