@IsTest
public with sharing class ACAMSCartTaxServiceTest {

    @IsTest
    static void sendTaxRecalculationRequest() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        ACAMSProductTriggerHandler.skipVertexAddressValidation = true;
        Map<String, Object> testData = testUtil.initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        ACAMSProductTriggerHandler.skipVertexAddressValidation = false;
        ccrz__E_Cart__c testCart = (ccrz__E_Cart__c) testData.get(CCAviTestUtil.PN_CART);
        Test.startTest();
        ACAMSCartTaxService.TaxResponse response = ACAMSCartTaxService.checkTax(testCart.Id);
        Test.stopTest();
        System.assertEquals(0, response.tax);
    }

    @IsTest
    static void sendTaxRecalculationRequestForTaxedCart() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        ACAMSProductTriggerHandler.skipVertexAddressValidation = true;
        Map<String, Object> testData = testUtil.initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        ACAMSProductTriggerHandler.skipVertexAddressValidation = false;
        ccrz__E_Cart__c testCart = (ccrz__E_Cart__c) testData.get(CCAviTestUtil.PN_CART);
        update new ccrz__E_Cart__c (
            Id = testCart.Id,
            ccrz__TaxAmount__c = 10
        );
        Test.startTest();
        ACAMSCartTaxService.TaxResponse response = ACAMSCartTaxService.checkTax(testCart.Id);
        Test.stopTest();
        System.assertEquals(10, response.tax);
    }
}