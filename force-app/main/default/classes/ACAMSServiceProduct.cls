global with sharing class ACAMSServiceProduct extends ccrz.ccServiceProduct {
    /**
     * Adds custom fields to the locale query.
     */
    global virtual override Map<String, Object> getSubQueryMap(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getSubQueryMap(inputData);
        if (outputData.containsKey('Product_Item_I18Ns__r')) {
            outputData.put('Product_Item_I18Ns__r', '(SELECT Id, AlternateName__c, Name, Locale__c, ShortDescRT__c, ' +
                    'SEOId__c, Name_Variant__c FROM Product_Item_I18Ns__r WHERE (Locale__c = :fullLocale OR ' +
                    'Locale__c = :langLocale))');
        } else if (outputData.containsKey('XLProduct_Item_I18Ns__r')) {
            outputData.put('XLProduct_Item_I18Ns__r', '(SELECT Id, AlternateName__c, Name, Locale__c, LongDescRT__c, ' +
                    'ShortDescRT__c, SEOId__c, Name_Variant__c FROM Product_Item_I18Ns__r WHERE ' +
                    '(Locale__c = :fullLocale OR Locale__c = :langLocale))');
        }
        return outputData;
    }

    /**
     *  Sets the custom fields for the supplied locale on the product to return in the API response.
     */
    global virtual override Map<String, Object> runQuery(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.runQuery(inputData);
        String fullLocale = (String) outputData.get(ccrz.ccService.FULLLOCALEKEY);
        String langLocale = (String) outputData.get(ccrz.ccService.LANGLOCALEKEY);
        List<ccrz__E_Product__c> products = (List<ccrz__E_Product__c>) outputData.get(ccrz.ccService.QUERYRESULTS);
        for (ccrz__E_Product__c product : products) {
            if (product.ccrz__Product_Item_I18Ns__r != null && product.ccrz__Product_Item_I18Ns__r.size() > 0) {
                for (ccrz__E_ProductItemI18N__c item : product.ccrz__Product_Item_I18Ns__r) {
                    if (item.ccrz__Locale__c == fullLocale || item.ccrz__Locale__c == langLocale) {
                        product.Name_Variant__c = item.Name_Variant__c;
                    }
                }
            }
        }
        return outputData;
    }

    /**
     *  Sets the localized name of the SubProdTerm on the sfdcName field in the API response.
     */
    global virtual override Map<String, Object> prepReturn(Map<String, Object> inputData) {
        String fullLocale = (String) inputData.get(ccrz.ccService.FULLLOCALEKEY);
        Map<String, Object> subProdTerms = (Map<String, Object>) inputData.get('sptByProdId');
        Set<Id> subProdTermIds = new Set<Id>();
        if (subProdTerms != null) {
            Integer version = (Integer) subProdTerms.remove('version');
            for (Object subProdTermList : (List<Object>) subProdTerms.values()) {
                for (Object subProdTerm : (List<Map<String, Object>>) subProdTermList) {
                    subProdTermIds.add((String) ((Map<String, Object>) subProdTerm).get('sfid'));
                }
            }
            Map<String, String> subProdTermIdsToName = new Map<String, String>();
            for (ccrz__E_SubProdTerm__c subProdTerm : [
                    SELECT Id, Name, (SELECT Id, Name FROM ccrz__SubProdTermI18Ns__r WHERE ccrz__Locale__c = :fullLocale)
                    FROM ccrz__E_SubProdTerm__c
                    WHERE Id IN :subProdTermIds
            ]) {
                String name = subProdTerm.Name;
                if (subProdTerm.ccrz__SubProdTermI18Ns__r.size() > 0) {
                    name = subProdTerm.ccrz__SubProdTermI18Ns__r[0].Name != null ?
                            subProdTerm.ccrz__SubProdTermI18Ns__r[0].Name : subProdTerm.Name;
                }
                subProdTermIdsToName.put(subProdTerm.Id, name);
            }
            for (Object subProdTermList : (List<Object>) subProdTerms.values()) {
                for (Object subProdTerm : (List<Map<String, Object>>) subProdTermList) {
                    ((Map<String, Object>) subProdTerm).put('sfdcName',
                            subProdTermIdsToName.get((String) ((Map<String, Object>) subProdTerm).get('sfid')));
                }
            }
            subProdTerms.put('version', version);
        }
        /*List<Map<String, Object>> subProdTerms = (List<Map<String, Object>>) inputData.get('sptList');
        Set<Id> subProdTermIds = new Set<Id>();
        for (Map<String, Object> subProdTerm : subProdTerms) {
            subProdTermIds.add((String) subProdTerm.get('sfid'));
        }
        Map<String, String> subProdTermIdsToName = new Map<String, String>();
        for (ccrz__E_SubProdTerm__c subProdTerm : [
                SELECT Id, Name, (SELECT Id, Name FROM ccrz__SubProdTermI18Ns__r WHERE ccrz__Locale__c = :fullLocale)
                FROM ccrz__E_SubProdTerm__c
                WHERE Id IN :subProdTermIds
        ]) {
            String name = subProdTerm.Name;
            if (subProdTerm.ccrz__SubProdTermI18Ns__r.size() > 0) {
                name = subProdTerm.ccrz__SubProdTermI18Ns__r[0].Name != null ?
                        subProdTerm.ccrz__SubProdTermI18Ns__r[0].Name : subProdTerm.Name;
            }
            subProdTermIdsToName.put(subProdTerm.Id, name);
        }
        for (Map<String, Object> subProdTerm : subProdTerms) {
            subProdTerm.put('sfdcName', subProdTermIdsToName.get((String) subProdTerm.get('sfid')));
        }*/
        Map<String, Object> outputData = super.prepReturn(inputData);
        return outputData;
    }
}