public with sharing class ACAMSProductTriggerHandler extends CCAviTriggerHandler {
    private List<ccrz__E_Product__c> newList = (List<ccrz__E_Product__c>) Trigger.new;
    private List<ccrz__E_Product__c> oldList = (List<ccrz__E_Product__c>) Trigger.old;
    private Map<Id, ccrz__E_Product__c> newMap = (Map<Id, ccrz__E_Product__c>) Trigger.newMap;
    private Map<Id, ccrz__E_Product__c> oldMap = (Map<Id, ccrz__E_Product__c>) Trigger.oldMap;

    public static Boolean skipRegionFieldPopulation = false;
    public static Boolean skipVertexAddressValidation = false;

    protected override void beforeInsert() {
        populateAddressRegionField();
    }

    protected override void afterInsert() {
        validateEventAddress();
    }

    protected override void beforeUpdate() {
        populateAddressRegionField();
    }

    protected override void afterUpdate() {
        validateEventAddress();
    }

    private void populateAddressRegionField() {
        if (!skipRegionFieldPopulation) {
            ACAMSAddressFieldsService.beforeTriggerCall(
                    this.newList,
                    this.oldMap,
                    null,
                    ccrz__E_Product__c.Event_Address_Country__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Address_Region__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Address_Continent__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Address_Named_Territory__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Address_SubTerritory__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Vertex_Country__c.getDescribe().getName()
            );
        }
    }

    private void validateEventAddress() {
        if (!skipVertexAddressValidation) {
            List<ccrz__E_Product__c> productsToValidate = new List<ccrz__E_Product__c>();
            for (ccrz__E_Product__c productToUpdate : this.newList) {
                if (isAvailableToValidateAddress(productToUpdate)) {
                    productsToValidate.add(productToUpdate);
                }
            }
            if (!productsToValidate.isEmpty()) {
                ACAMSAddressValidationService.getProductValidationService()
                        .identifyAddressTaxAreaIdAsync(productsToValidate);
            }
        }
    }

    private Boolean isAvailableToValidateAddress(ccrz__E_Product__c updatedProduct) {
        Boolean isContainingRequiredFields = (
            !String.isBlank(updatedProduct.Event_Address_Street_1__c) &&
            !String.isBlank(updatedProduct.Event_Address_City__c) &&
            !String.isBlank(updatedProduct.Event_Address_Country__c)
        );
        ccrz__E_Product__c oldProductData = this.oldMap == null ? null : this.oldMap.get(updatedProduct.Id);
        Boolean isHavingUpdatedFields = (
            oldProductData == null || (
                updatedProduct.Event_Address_Street_1__c != oldProductData.Event_Address_Street_1__c ||
                updatedProduct.Event_Address_Street_2__c != oldProductData.Event_Address_Street_2__c ||
                updatedProduct.Event_Address_City__c != oldProductData.Event_Address_City__c ||
                updatedProduct.Event_Address_State__c != oldProductData.Event_Address_State__c ||
                updatedProduct.Event_Address_Country__c != oldProductData.Event_Address_Country__c ||
                updatedProduct.Event_Address_Zip__c != oldProductData.Event_Address_Zip__c
            )
        );
        return isContainingRequiredFields && isHavingUpdatedFields;
    }

}