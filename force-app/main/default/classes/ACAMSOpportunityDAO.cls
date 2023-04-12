public with sharing class ACAMSOpportunityDAO {

    public static List<Opportunity> getOpportunities(Set<Id> oppIds) {
        List<Opportunity> oppList = [
                SELECT
                        Id,
                        StageName
                FROM
                        Opportunity
                WHERE
                        Id IN :oppIds
        ];

        return oppList;
    }

    public static List<ccrz__E_Order__c> getOrdersWithOpportunities(Set<Id> oppIds) {
        List<ccrz__E_Order__c> orders = [
                SELECT
                        Id,
                        Opportunity__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        Opportunity__c IN :oppIds
        ];

        return orders;
    }

    public static Opportunity getOpportunity(Id oppId) {
        Opportunity opp = null;
        List<Opportunity> opps = [
                SELECT
                        Id,
                        OwnerId,
                        AccountId,
                        Account.Name,
                        Account.OwnerId,
                        Account.Industry,
                        Account.Number_of_Orders__c,
                        Account.ccrz__E_AccountGroup__r.Enterprise_Account__c,
                        Account.RecordType.DeveloperName,
                        Account.ccrz__CompanyName__pc,
                        Account.CommunityUser__c,
                        CC_Cart__r.ccrz__BillTo__r.ccrz__City__c,
                        CC_Cart__r.ccrz__BillTo__r.ccrz__AddressFirstline__c,
                        CC_Cart__r.ccrz__BillTo__r.ccrz__State__c,
                        CC_Cart__r.ccrz__BillTo__r.ccrz__PostalCode__c,
                        CC_Cart__r.ccrz__BillTo__r.ccrz__CountryISOCode__c,
            			BillTo_City__c,   //FSA-1872
            			BillTo_AddressFirstLine__c,
            			BillTo_State__c,
            			BillTo_PostalCode__c,
          			    BillTo_CountryISOCode__c,
            			Enterprise_Account__c,
            			Industry__c,  //FSA-1872
                        Enterprise_Upgrade__c  
                FROM
                        Opportunity
                WHERE
                        Id = :oppId

        ];
        if (!opps.isEmpty()) {
            opp = opps.get(0);
        }
        return opp;
    }
}