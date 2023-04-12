public with sharing class ACAMSInvoiceService {

    private static final String SOAP_NS_VERTEX = 'urn:vertexinc:o-series:tps:7:0';
    private static final String SOAP_NS_ENVELOPE = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String SOAP_BODY = 'Body';
    private static final String VERTEX_ENVELOPE = 'VertexEnvelope';
    private static final String VERTEX_INVOICE_RESPONSE = 'InvoiceResponse';
    private static final String VERTEX_LINE_ITEM = 'LineItem';
    private static final String VERTEX_LINE_ITEM_ATTR_ID = 'lineItemId';
    private static final String VERTEX_FLEX_FIELDS = 'FlexibleFields';
    private static final String VERTEX_TAX_FIELDS = 'Taxes';
    private static final String SELLER_TAX_ID_CODE = '24';
    private static final String IMPOSITION_TYPE_CODE = '25';
    private static final String EFFECTIVE_RATE = 'EffectiveRate';
    private static final String SOBJECT_NAME_INVOICE_ITEM =
            ccrz__E_InvoiceItem__c.getSObjectType().getDescribe().getName();

  //vara added 
  public static boolean islive = false;
    public static boolean isVirtual = false;
    public static boolean isDigital = false;

    private class LineItemFields {
        public String sellerTaxRegistrationId { get; set; }
        public String impositionType { get; set; }
        public String effectiveRate { get; set; }
    }

    /**
     * Collects Invoice Items of the initial CC Invoice for placed CC Order. Creates child CC Invoices and adds
     * CC Invoice Items splitting all items by legal entity and abroad live event location
     */
    @Future 
    public static void splitOrderInvoice(String orderId) {
        ACAMSCCOrderCCInvoiceEntryService.InvoiceData parentInvoiceData = ACAMSCCOrderCCInvoiceEntryService.getParentInvoiceData(orderId);
        Map<String, List<ccrz__E_InvoiceItem__c>> invoiceItemsByKey = getInvoiceItemsByKey(parentInvoiceData.invoiceItems);
        if (!invoiceItemsByKey.keySet().isEmpty() && invoiceItemsByKey.size() > 1) {
            system.debug('------------------vara--6180-------------------------');
      cloneInvoiceItemsToInvoices(parentInvoiceData.invoice, invoiceItemsByKey);
        }
    }
  
    public static void splitOrderInvoiceFuture(String orderId) {
        ACAMSCCOrderCCInvoiceEntryService.InvoiceData parentInvoiceData = ACAMSCCOrderCCInvoiceEntryService.getParentInvoiceData(orderId);
        Map<String, List<ccrz__E_InvoiceItem__c>> invoiceItemsByKey = getInvoiceItemsByKey(parentInvoiceData.invoiceItems);
        if (!invoiceItemsByKey.keySet().isEmpty() && invoiceItemsByKey.size() > 1) {
            system.debug('------------------vara--6180-------------------------');
      cloneInvoiceItemsToInvoices(parentInvoiceData.invoice, invoiceItemsByKey);
        }
    }

    /**
     * By created Vertex Logs from Vertex Tax Calculation requests, updates CC Invoice Items fields based on flexible
     * fields data returned in response
     */
     /* //FSA-537
    public static void updateInvoiceItemsWithVertexResponse(List<Vertex__VertexLog__c> vertexLogs) {
        Map<Id, LineItemFields> lineItemData = new Map<Id, LineItemFields>();
        for (Vertex__VertexLog__c vertexLog : vertexLogs) {
            lineItemData.putAll(getLineItemData(vertexLog.Vertex__Response__c));
        }
        List<ccrz__E_InvoiceItem__c> invoiceItemsWithInvoiceIds = ACAMSInvoiceDAO.getInvoiceIdsFromInvoiceItems(lineItemData.keySet());
        Map<Id, ccrz__E_InvoiceItem__c> invoiceItemIdToInvoiceItemMap = new Map<Id, ccrz__E_InvoiceItem__c>();
        Set<Id> invoiceIds = new Set<Id>();
        for (ccrz__E_InvoiceItem__c invoiceItem : invoiceItemsWithInvoiceIds) {
            invoiceIds.add(invoiceItem.ccrz__Invoice__c);
            invoiceItemIdToInvoiceItemMap.put(invoiceItem.Id, invoiceItem);
        }
        List<ccrz__E_Invoice__c> invoicesToUpdate = ACAMSInvoiceDAO.getInvoices(invoiceIds);
        Map<Id, String> invoiceIdToSellerTaxRegistrationIDMap = new Map<Id, String>();
        List<ccrz__E_InvoiceItem__c> invoiceItemsToUpdate = new List<ccrz__E_InvoiceItem__c>();
        for (Id invoiceItemId : lineItemData.keySet()) {
            LineItemFields lineItemFieldsData = lineItemData.get(invoiceItemId);
            invoiceItemsToUpdate.add(new ccrz__E_InvoiceItem__c(
                    Id = invoiceItemId,
                    Seller_Tax_Registration_ID__c = lineItemFieldsData.sellerTaxRegistrationId,
                    Imposition_Type__c = lineItemFieldsData.impositionType
            ));
            invoiceIdToSellerTaxRegistrationIDMap.put(
                    invoiceItemIdToInvoiceItemMap.get(invoiceItemId).ccrz__Invoice__c,
                    lineItemFieldsData.sellerTaxRegistrationId
            );
        }
        for (ccrz__E_Invoice__c invoice : invoicesToUpdate) {
            invoice.Seller_Tax_Registration_ID__c = invoiceIdToSellerTaxRegistrationIDMap.get(invoice.Id);
            invoice.Sent_to_Vertex__c = true;
        }
        update invoiceItemsToUpdate;
        update invoicesToUpdate;
    }
  */
    public static Map<Id, LineItemFields> getLineItemData(String vertexResponse) {
        Map<Id, LineItemFields> lineItemData = new Map<Id, LineItemFields>();
        if (!String.isBlank(vertexResponse)) {
            try {
                Dom.Document document = new Dom.Document();
                document.load(vertexResponse);
                List<Dom.XmlNode> informativeNodes =
                        document
                                .getRootElement()
                                .getChildElement(SOAP_BODY, SOAP_NS_ENVELOPE)
                                .getChildElement(VERTEX_ENVELOPE, SOAP_NS_VERTEX)
                                .getChildElement(VERTEX_INVOICE_RESPONSE, SOAP_NS_VERTEX)
                                .getChildren();
                for (Dom.XmlNode informativeNode : informativeNodes) {
                    if (informativeNode.getName() == VERTEX_LINE_ITEM && informativeNode.getAttributeCount() > 0) {
                        Id lineItemAttributeId = (Id) informativeNode.getAttributeValue(
                                informativeNode.getAttributeKeyAt(0),
                                informativeNode.getAttributeKeyNsAt(0)
                        );
                        String sObjectName = lineItemAttributeId.getSobjectType().getDescribe().getName();
                        if (sObjectName == SOBJECT_NAME_INVOICE_ITEM) {
                            lineItemData.put(lineItemAttributeId, getLineItemFlexAndTaxData(informativeNode));
                        }
                    }
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, e.getMessage());
            }
        }
        return lineItemData;
    }

    private static LineItemFields getLineItemFlexAndTaxData(Dom.XmlNode lineItemNode) {
        LineItemFields fieldData = new LineItemFields();
        Dom.XmlNode flexFieldsNode;
        Dom.XmlNode taxFieldsNode;
        for (Dom.XmlNode subNode : lineItemNode.getChildren()) {
            if (subNode.getName() == VERTEX_FLEX_FIELDS) {
                flexFieldsNode = subNode;
            } else if (subNode.getName() == VERTEX_TAX_FIELDS) {
                taxFieldsNode = subNode;
            }
            if (flexFieldsNode != null && taxFieldsNode != null) {
                break;
            }
        }
        for (Dom.XmlNode flexFieldNode : flexFieldsNode.getChildren()) {
            if (flexFieldNode.getAttributeCount() > 0) {
                String flexFieldCode = flexFieldNode.getAttributeValue(
                        flexFieldNode.getAttributeKeyAt(0),
                        flexFieldNode.getAttributeKeyNsAt(0)
                );
                if (flexFieldCode == SELLER_TAX_ID_CODE) {
                    fieldData.sellerTaxRegistrationId = flexFieldNode.getText();
                } else if (flexFieldCode == IMPOSITION_TYPE_CODE) {
                    fieldData.impositionType = flexFieldNode.getText();
                }
            }
        }

        for (Dom.XmlNode taxFieldNode : taxFieldsNode.getChildren()) {
            if (taxFieldNode.getName() == EFFECTIVE_RATE) {
                fieldData.effectiveRate = taxFieldNode.getText();
            }
        }
        return fieldData;
    }

    private static Map<String, List<ccrz__E_InvoiceItem__c>> getInvoiceItemsByKey(List<ccrz__E_InvoiceItem__c> invoiceItems) {
        Map<String, List<ccrz__E_InvoiceItem__c>> invoiceItemsByKey = new Map<String, List<ccrz__E_InvoiceItem__c>>();
        if (invoiceItems != null) {
      for (ccrz__E_InvoiceItem__c parentInvoiceItem : invoiceItems) {
                String invoiceKey = getKey(parentInvoiceItem);
                if (!invoiceItemsByKey.containsKey(invoiceKey)) {
                    invoiceItemsByKey.put(invoiceKey, new List<ccrz__E_InvoiceItem__c>());
                }
        invoiceItemsByKey.get(invoiceKey).add(parentInvoiceItem);
            }
        }
        return invoiceItemsByKey;
    }

    private static String getKey(ccrz__E_InvoiceItem__c invoiceItem) {
        String legalEntity = invoiceItem.Legal_Entity__c;
        Boolean isLiveEvent = (
                invoiceItem.Product_Level_1__c == 'Training' && invoiceItem.Product_Level_3__c == 'Face to Face' ||
                        invoiceItem.Product_Level_1__c == 'Training' && invoiceItem.Product_Level_2__c == 'Seminars' ||
                        invoiceItem.Product_Level_1__c == 'Chapter' && invoiceItem.Product_Level_2__c == 'Event' ||
                        invoiceItem.Product_Level_1__c == 'Conferences'
        );
        String destinationCountry = '--';
        String addressCountry = invoiceItem.ccrz__Invoice__r.ccrz__SoldAddress__r.ccrz__CountryISOCode__c != null ?
                invoiceItem.ccrz__Invoice__r.ccrz__SoldAddress__r.ccrz__CountryISOCode__c :
                invoiceItem.ccrz__Invoice__r.ccrz__BillAddress__r.ccrz__CountryISOCode__c;
        if (isLiveEvent && addressCountry != invoiceItem.Destination_Country__c) {
            destinationCountry = invoiceItem.Destination_Country__c;
        }
        String country = isLiveEvent ? destinationCountry : '--';
        return legalEntity + ':' + country;
    }

    private static void cloneInvoiceItemsToInvoices(ccrz__E_Invoice__c parentInvoice, Map<String, List<ccrz__E_InvoiceItem__c>> sourceInvoiceItemsByKey) {
        Map<String, List<ccrz__E_InvoiceItem__c>> invoiceItemsByKey = new Map<String, List<ccrz__E_InvoiceItem__c>>();
        Map<String, ccrz__E_Invoice__c> invoiceByKey = new Map<String, ccrz__E_Invoice__c>();
        for (String key : sourceInvoiceItemsByKey.keySet()) {
            ccrz__E_Invoice__c childInvoice = parentInvoice.clone();
            List<ccrz__E_InvoiceItem__c> childInvoiceItems = new List<ccrz__E_InvoiceItem__c>();
            Decimal invoiceAmount = 0;
            for (ccrz__E_InvoiceItem__c parentInvoiceItem : sourceInvoiceItemsByKey.get(key)) {
                childInvoiceItems.add(parentInvoiceItem.clone());
                invoiceAmount += parentInvoiceItem.ccrz__OriginalAmount__c == null ? 0 : parentInvoiceItem.ccrz__OriginalAmount__c;
        
        // vara added FSA-6180 
        system.debug('------------------vara--6180-------------------------');
        if(parentInvoiceItem.ccrz__CCOrderItem__r.ccrz__Product__r.is_Virtual__c) {
          isVirtual = true;
        } else if(parentInvoiceItem.ccrz__CCOrderItem__r.ccrz__Product__r.Is_live__c){
          islive = true;
        }else if(parentInvoiceItem.ccrz__CCOrderItem__r.ccrz__Product__r.Is_Digital__c){
          isDigital = true;
        } //6180 close
            }
            childInvoice.ccrz__ParentInvoice__c = parentInvoice.Id;
            childInvoice.ccrz__OriginalAmount__c = invoiceAmount;
            childInvoice.ccrz__RemainingAmount__c = invoiceAmount;
            childInvoice.ccrz__DateIssued__c = Date.today();
            invoiceByKey.put(key, childInvoice);
            invoiceItemsByKey.put(key, childInvoiceItems);      
        }
    
        //6180  (isVirtual && islive) || (isVirtual && isDigital ) || (islive && isDigital )
    if(islive){
      system.debug('---isVirtual---->'+isVirtual+' ------islive----->'+islive+' ------isDigital------->'+isDigital);
      insert invoiceByKey.values();  
    }  
    
        List<ccrz__E_InvoiceItem__c> newInvoiceItems = new List<ccrz__E_InvoiceItem__c>();
        for (String key : invoiceByKey.keySet()) {
            ccrz__E_Invoice__c childInvoice = invoiceByKey.get(key);
            for (ccrz__E_InvoiceItem__c childInvoiceItem : invoiceItemsByKey.get(key)) {
                childInvoiceItem.ccrz__Invoice__c = childInvoice.Id;
                newInvoiceItems.add(childInvoiceItem);
            }
        }
    //6180
    if(islive){
      insert newInvoiceItems;
    }
    }

}