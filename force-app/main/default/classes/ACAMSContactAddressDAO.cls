public with sharing class ACAMSContactAddressDAO {

    public static List<ccrz__E_ContactAddr__c> getContactAddrsByIds(Set<Id> contactAddrIds) {
        List<ccrz__E_ContactAddr__c> contactAddrs = [
                SELECT
                        Id,
                        ccrz__AddressFirstline__c,
                        ccrz__AddressSecondline__c,
                        ccrz__AddressThirdLine__c,
                        ccrz__City__c,
                        ccrz__State__c,
                        ccrz__StateISOCode__c,
                        ccrz__Country__c,
                        ccrz__CountryISOCode__c,
                        ccrz__PostalCode__c,
                        Vertex_Tax_Area_Id__c,
                        Vertex_Tax_Area_Confidence__c
                FROM
                        ccrz__E_ContactAddr__c
                WHERE
                        Id IN :contactAddrIds
        ];
        return contactAddrs;
    }
}