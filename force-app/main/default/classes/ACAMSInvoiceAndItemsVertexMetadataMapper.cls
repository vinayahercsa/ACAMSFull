/* FSA-537
*
*/
public with sharing class ACAMSInvoiceAndItemsVertexMetadataMapper {
    public static Map<String, Vertex_Invoice__mdt> vertexByEntityCountryCodeCombination;
    public static Map<String, string> countryAndCodeMap = new Map<String, String>();
    public static Map<Id, List<ccrz__E_InvoiceItem__c>> invoiceMapTaxidList = new Map<Id, List<ccrz__E_InvoiceItem__c>>();
    
    public static void matchAndSetVertexDetailsFromMetadata(List<SObject> listValues,  Map<Id, ccrz__E_Invoice__c> idToInvoiceMap){
        vertexByEntityCountryCodeCombination = queryVertexMetadataSettings();        
         //fsa-2071
        Set<Id> oitemIds = new Set<Id>();
        Map<Id, ccrz__E_OrderItem__c> orderItemMap = new Map<id, ccrz__E_OrderItem__c>();
        for(SObject sobj:listValues){
            if(sobj instanceof ccrz__E_InvoiceItem__c){
                ccrz__E_InvoiceItem__c ccInvItem = (ccrz__E_InvoiceItem__c)sobj;
                system.debug('-----------'+ccInvItem.ccrz__CCOrderItem__c);
                if(ccInvItem.ccrz__CCOrderItem__c != null)
                    oitemIds.add(ccInvItem.ccrz__CCOrderItem__c);
            }
        }
        
        system.debug('----oitemIds--21-----'+oitemIds);
        if(oitemIds.size() > 0){
            List<ccrz__E_OrderItem__c> ordItemList = [select id, ccrz__Product__r.Is_live__c, ccrz__Product__r.is_Virtual__c, ccrz__Product__r.Event_Address_State__c, ccrz__Product__r.Event_Address_Country__c from ccrz__E_OrderItem__c where Id in: oitemIds and ccrz__Product__c != null]; // and ccrz__Product__r.Is_live__c = true and ccrz__Product__r.Event_Address_Country__c != null
            for(ccrz__E_OrderItem__c oi : ordItemList){
                orderItemMap.put(oi.id,oi);
            }
        }
        system.debug('----orderItemMap--29-----'+orderItemMap.size());
        //fsa-2071 close 
        for(SObject sobj:listValues){
            if(sobj instanceof ccrz__E_InvoiceItem__c){
                ccrz__E_InvoiceItem__c ccInvItem = (ccrz__E_InvoiceItem__c)sobj;
                String sellerTaxid;
                String impositionType;              
                String invoiceDestinationCountry ='';
                String state; //FSA-2292 
                
                if(!idToInvoiceMap.isempty()){
                    invoiceDestinationCountry = idToInvoiceMap.get(ccInvItem.ccrz__Invoice__c).Destination_Country__c!=null?idToInvoiceMap.get(ccInvItem.ccrz__Invoice__c).Destination_Country__c.toUpperCase():null;
                }
                
                //Fsa-2071 start - only lop for live products only, for others it wont go inside
                if(orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c) != null){
                    system.debug('-----------'+orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c));                
                    system.debug('-----------'+orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.Is_live__c);
                    system.debug('-----------'+orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.Event_Address_Country__c);
                    system.debug('-----------'+countryAndCodeMap.get(orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.Event_Address_Country__c));
                    //fsa-6025 
          if(orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.Is_live__c == true && orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.is_Virtual__c == false){ 
                        //only islive = true, product country logic
                        if(orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.Event_Address_Country__c != null ){
                            if(countryAndCodeMap.get(orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.Event_Address_Country__c) != null){
                                invoiceDestinationCountry = countryAndCodeMap.get(orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.Event_Address_Country__c).toUpperCase();
                            } else {
                                invoiceDestinationCountry='DEFAULT'; // DEFAULT is key to get impostion type as 'TAX' and sellerTaxid as '88-0594034' for live events when there is no event region country value present in Vertex Invoice Custom metadata type . Added as part of FSA-5638.
                            }                            
                        }
                        //only islive = true, product state logic FSA-2292 
                        if(orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.Event_Address_State__c != null){
                            state = orderItemMap.get(ccInvItem.ccrz__CCOrderItem__c).ccrz__Product__r.Event_Address_State__c ;
                        }
                    }
                }
                // fsa-2071 close
                // only if added fsa-2292 
                if(state == null || state ==''){
                    state = idToInvoiceMap.get(ccInvItem.ccrz__Invoice__c).Destination_State__c !=null?idToInvoiceMap.get(ccInvItem.ccrz__Invoice__c).Destination_State__c.toUpperCase():null;
                }
                System.debug('=>Aditya<=' +state );
                System.debug('invoiceDestinationCountry  ::'+invoiceDestinationCountry);
                System.debug('Key:: '+ccInvItem.Legal_Entity__c+invoiceDestinationCountry);
                System.debug('vertexByEntityCountryCodeCombination.get(ccInvItem.Legal_Entity__c+invoiceDestinationCountry):'+                            vertexByEntityCountryCodeCombination.get(ccInvItem.Legal_Entity__c+invoiceDestinationCountry));
                if(vertexByEntityCountryCodeCombination.containsKey(ccInvItem.Legal_Entity__c+invoiceDestinationCountry) && invoiceDestinationCountry != 'CANADA'){
                    sellerTaxid = vertexByEntityCountryCodeCombination.get(ccInvItem.Legal_Entity__c+invoiceDestinationCountry).Invoice_Registration_ID__c;
                    impositionType = vertexByEntityCountryCodeCombination.get(ccInvItem.Legal_Entity__c+invoiceDestinationCountry).Invoice_Imposition__c;
                    system.debug('=>Aditya imposition Type<=' +impositionType );
                } 
                else if(invoiceDestinationCountry == 'CANADA' && (state == 'BC' ||state == 'British Columbia')){
                    impositionType = 'GST/PST';
                    sellerTaxid = '735448078RT0001';   
                }
                else if(invoiceDestinationCountry == 'CANADA' && (state == 'QC' ||state == 'Quebec')){
                    impositionType = 'GST/QST';
                    sellerTaxid = '735448078RT0001'; 
                }
                else if(invoiceDestinationCountry == 'CANADA' && (state != 'BC' || state != 'British Columbia') && (state != 'QC' || state != 'Quebec') ){
                    impositionType = 'GST/HST'; // if state values are toronto, ON or any other states this tax values 
                    sellerTaxid = '735448078RT0001';
                }
                else {
                    system.debug('---------allelse----noCountry and state'+ invoiceDestinationCountry +'---state------>'+state);
                    sellerTaxid = '88-0594034';
                    impositionType = 'TAX';
                }
                ccInvItem.Seller_Tax_Registration_ID__c = sellerTaxid;
                ccInvItem.Imposition_Type__c = impositionType;
                system.debug('-----sellerTaxid------'+sellerTaxid);
                //fsa-2071 start
                if(invoiceMapTaxidList.containsKey(ccInvItem.ccrz__Invoice__c)) {
                    List<ccrz__E_InvoiceItem__c> ccInvItemsList = invoiceMapTaxidList.get(ccInvItem.ccrz__Invoice__c);
                    ccInvItemsList.add(ccInvItem);
                    invoiceMapTaxidList.put(ccInvItem.ccrz__Invoice__c, ccInvItemsList);
                } else {
                    List<ccrz__E_InvoiceItem__c> ccInvItemsList = new List<ccrz__E_InvoiceItem__c>{ccInvItem};
                    invoiceMapTaxidList.put(ccInvItem.ccrz__Invoice__c, ccInvItemsList);
                }               
                //fsa-2071 close
                system.debug('----------invoiceMapTaxidList------'+invoiceMapTaxidList.size());
            } else if(sobj instanceof ccrz__E_Invoice__c){
              //  ((ccrz__E_Invoice__c)sobj).Seller_Tax_Registration_ID__c = invoiceIdToSellerTaxRegistrationIDMap.get(invoice.Id);
              //  ((ccrz__E_Invoice__c)sobj).Sent_to_Vertex__c = true;              
            }
        } 
        
        //fsa-2071 - value assigning on invoice level 
        system.debug('----before-invoiceMapTaxidList------'+invoiceMapTaxidList);   
        List<ccrz__E_InvoiceItem__c> allInvoiceItemsList = [select id, Seller_Tax_Registration_ID__c, ccrz__Invoice__c  from ccrz__E_InvoiceItem__c where Seller_Tax_Registration_ID__c != null and ccrz__Invoice__c in: invoiceMapTaxidList.keyset()];
        if(allInvoiceItemsList.size() > 0){
            for(ccrz__E_InvoiceItem__c ccInvItem : allInvoiceItemsList){
                if(invoiceMapTaxidList.containsKey(ccInvItem.ccrz__Invoice__c)) {
                    List<ccrz__E_InvoiceItem__c> ccInvItemsList = invoiceMapTaxidList.get(ccInvItem.ccrz__Invoice__c);
                    ccInvItemsList.add(ccInvItem);
                    invoiceMapTaxidList.put(ccInvItem.ccrz__Invoice__c, ccInvItemsList);
                } else {
                    List<ccrz__E_InvoiceItem__c> ccInvItemsList = new List<ccrz__E_InvoiceItem__c>{ccInvItem};
                    invoiceMapTaxidList.put(ccInvItem.ccrz__Invoice__c, ccInvItemsList);
                }   
            }
        }
        system.debug('----after-----invoiceMapTaxidList------'+invoiceMapTaxidList);
        if(!invoiceMapTaxidList.isEmpty()){
            for(ID invId : invoiceMapTaxidList.keyset()){
                ccrz__E_Invoice__c inv = new ccrz__E_Invoice__c();
                if(idToInvoiceMap.get(invId) != null)
                    inv = idToInvoiceMap.get(invId);         
                String taxids='';
                for(ccrz__E_InvoiceItem__c invItem : invoiceMapTaxidList.get(invId)){
                    if(invItem.Seller_Tax_Registration_ID__c != null){
                        taxids = taxids +invItem.Seller_Tax_Registration_ID__c+'; ';
                    }
                }                
                // getting all invoice items, and making unique string for tax ids
                Set<String> tmpSet = New Set<String>(taxids.split('; '));
                taxids = string.join(New List<String>(tmpSet),'; ');
                system.debug('----taxids----------'+taxids);            
                inv.Seller_Tax_Registration_ID__c = taxids;             
            }
        }    
        system.debug('-----idToInvoiceMap------'+idToInvoiceMap);       
        //fsa-2071 close        
    }
    
    private static Map<String, Vertex_Invoice__mdt> queryVertexMetadataSettings() {
        Map<String, Vertex_Invoice__mdt> vertexByEntityCountryCodeCombination = new Map<String, Vertex_Invoice__mdt>();
        final String queryString = 'SELECT Code__c, Country__c, Country_Code__c, Entity__c, Invoice_Imposition__c, State__c, Invoice_Registration_ID__c FROM Vertex_Invoice__mdt';
        for(Vertex_Invoice__mdt vimdt : Database.query(queryString)){
            if(vimdt!=null && vimdt.Country__c!=null && vimdt.Entity__c!=null){
                    String country = vimdt.Country__c.toUpperCase();
                    vertexByEntityCountryCodeCombination.put(vimdt.Entity__c+country, vimdt);
                    countryAndCodeMap.put(vimdt.Country_Code__c, vimdt.Country__c); //fsa-2071
            }            
        }                
        return vertexByEntityCountryCodeCombination;
    }    
}