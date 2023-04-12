/**
 * Test class for EducationalCreditUnitcreationcls
 */

@isTest
public with sharing class FSIT_EducationalCreditUnitTest {
    public FSIT_EducationalCreditUnitTest() {

    }

    public static testMethod void testExcecute() {
        List<Account> acctList = FSIT_CalloutUtilityTestDataFactory.createAccount(1);
        insert acctList;

        List<Contact> ctList = FSIT_CalloutUtilityTestDataFactory.createContactRecord();
        ctList[0].AccountId = acctList[0].Id;
        insert ctList;
        
        List<ccrz__E_Product__c> prodList = FSIT_CalloutUtilityTestDataFactory.generateCCProductRecords(1);
        insert prodList;

        List<Asset> asstList = FSIT_CalloutUtilityTestDataFactory.createAssetListWithRecordType(1,'Test_Asset_Name', 'Registrant');
        
        asstList.get(0).CC_Product__c = prodList.get(0).Id;
        asstList.get(0).AccountId = acctList.get(0).Id;
        asstList[0].Assignee__c = ctList[0].Id;

        insert asstList;
        //Database.SaveResult[] srList = Database.Insert(asstList, false);
        System.debug('----CC_PROD_EVENT_Date---->'+prodList[0].Event_Date__c);
        System.debug('------Asset--->'+asstList);
        System.debug('------Event_Date__c--->'+asstList.get(0).Event_Date__c);
        System.debug('------Event_Name__c--->'+asstList[0].Event_Name__c);
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?';
        EducationalCreditUnitcreationcls job = new EducationalCreditUnitcreationcls();
        Database.executeBatch(job);
        Test.stopTest();
    }
}