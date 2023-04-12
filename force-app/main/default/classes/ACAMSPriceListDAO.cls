public with sharing class ACAMSPriceListDAO {

    public static List<ccrz__E_AccountGroupPriceList__c> getAccountGroupPriceLists(Set<Id> accountGroupIds) {
        List<ccrz__E_AccountGroupPriceList__c> aList = [
                SELECT
                        ccrz__AccountGroup__c,
                        ccrz__EndDate__c,
                        ccrz__Pricelist__c,
                        ccrz__Pricelist__r.Name,
                        ccrz__StartDate__c
                FROM
                        ccrz__E_AccountGroupPriceList__c
                WHERE
                ccrz__StartDate__c <= TODAY
                AND
                ccrz__EndDate__c >= TODAY
                AND
                ccrz__Pricelist__r.Name != 'PortalAccount'
                AND
                ccrz__AccountGroup__c IN :accountGroupIds
        ];

        return aList;
    }

    public static List<ccrz__E_PriceListItem__c> getPriceListItems(Set<Id> priceListIds) {
        List<ccrz__E_PriceListItem__c> pList = [
                SELECT
                        ccrz__EndDate__c,
                        ccrz__Price__c,
                        ccrz__Pricelist__c,
                        ccrz__Pricelist__r.ccrz__StartDate__c,
                        ccrz__Pricelist__r.ccrz__EndDate__c,
                        ccrz__Product__c,
                        ccrz__StartDate__c,
                        Id
                FROM
                        ccrz__E_PriceListItem__c
                WHERE
                ccrz__StartDate__c <= TODAY
                AND
                ccrz__EndDate__c >= TODAY
                AND
                ccrz__Pricelist__r.ccrz__StartDate__c <= TODAY
                AND
                ccrz__Pricelist__r.ccrz__EndDate__c >= TODAY
                AND
                ccrz__Pricelist__c IN :priceListIds
        ];

        return pList;
    }
    //FSA-1029/834/1490
    public static List<ccrz__E_PriceListItem__c> getPriceListItemsForSubProdId(Set<String> priceListIds) {
        List<ccrz__E_PriceListItem__c> pList = [
                SELECT
            ccrz__SubProdTerm__c,
            ccrz__SubProdTerm__r.Name,
                  ccrz__SubProdTerm__r.Avoid_from_Price_List__c,
                        Id
                FROM
                        ccrz__E_PriceListItem__c
                WHERE
             
                Id IN :priceListIds
        ];

        return pList;
    }
    //FSA-1029/834/1490
}