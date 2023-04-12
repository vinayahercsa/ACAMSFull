@IsTest
class ACAMSCartTaxRecalculationControllerTest {

    @IsTest
    static void testRecalculateTax() {
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> testData = new CCACAMSTestUtil().initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        ccrz__E_Cart__c cart = (ccrz__E_Cart__c) testData.get(CCAviTestUtil.PN_CART);
        Boolean isException = false;
        Test.startTest();
        try {
            ACAMSCartTaxRecalculationController.recalculateTaxes(cart.Id);
        } catch (Exception e) {
            isException = true;
        }
        Test.stopTest();
        System.assert(!isException);
    }

}