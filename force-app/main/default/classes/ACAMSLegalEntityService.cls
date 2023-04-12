public with sharing class ACAMSLegalEntityService {

    public static void updateLineItemLegalEntityFromFormula(
            List<SObject> lineItems,
            String legalEntityFormulaFieldName,
            String legalEntityFieldName
    ) {
        for (SObject lineItem : lineItems) {
            String legalEntityFormulaValue = (String) lineItem.get(legalEntityFormulaFieldName);
            lineItem.put(legalEntityFieldName, legalEntityFormulaValue);
        }
    }

    public static void calculateLegalEntitySummary(
            List<SObject> records,
            String legalEntityFieldName,
            String acamsLlcFieldName,
            String acamsGermanyFieldName,
            String acamsCanadaFieldName,
            String acamsBeijingLlcFieldName
    ) {
        calculateLegalEntitySummary(
                records,
                legalEntityFieldName,
                new Map<String, String>{
                        'ACAMS LLC' => acamsLlcFieldName,
                        'ACAMS Germany' => acamsGermanyFieldName,
                        'ACAMS Canada' => acamsCanadaFieldName,
                        'ACAMS Beijing' => acamsBeijingLlcFieldName
                }
        );
    }

    public static void calculateLegalEntitySummary(
            List<SObject> records,
            String legalEntityFieldName,
            Map<String, String> rollupCountFieldNameByLegalEntityName
    ) {
        for (SObject record : records) {
            record.put(legalEntityFieldName, getLegalEntitySummary(record, rollupCountFieldNameByLegalEntityName));
        }
    }

    public static String getLegalEntitySummary(
            SObject record,
            Map<String, String> rollupCountFieldNameByLegalEntityName
    ) {
        Set<String> foundLegalEntityNames = new Set<String>();
        for (String legalEntityName : rollupCountFieldNameByLegalEntityName.keySet()) {
            String rollupCountFieldName = rollupCountFieldNameByLegalEntityName.get(legalEntityName);
            Decimal rollupCount = (Decimal) record.get(rollupCountFieldName);
            if (rollupCount > 0) {
                foundLegalEntityNames.add(legalEntityName);
            }
        }

        if (!foundLegalEntityNames.isEmpty()) {
            String firstEntityName;
            for (String entityName : foundLegalEntityNames) {
                firstEntityName = entityName;
                break;
            }

            ACAMS_Legal_Entity__mdt legalEntity = [
                    SELECT
                            Id,
                            Address__c
                    FROM
                            ACAMS_Legal_Entity__mdt
                    WHERE
                            MasterLabel = :firstEntityName
            ];

            record.put('Legal_Entity_Address__c', legalEntity.Address__c);
        }

        return String.join(new List<String>(foundLegalEntityNames), ';');
    }
}