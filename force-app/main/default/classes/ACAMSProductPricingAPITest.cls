@IsTest
private class ACAMSProductPricingAPITest {
    static CCAviTestUtil testUtil = new CCAviTestUtil();

    @IsTest
    static void testProductPricing() {
        Map<String, Object> testData = testUtil.initData();
        ccrz__E_Product__c product = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        ACAMSProductPricing.ProductPricingResponse response =
                ACAMSProductPricing.getProductPricing(new List<String>{product.Id}, 'USD');
        System.assertEquals(response.memberPriceMap.get(product.Id), 10.00);
        System.assertEquals(response.memberPriceMap.get(product.Id), 10.00);
    }

    @IsTest
    static void testProductPricingComparison() {
        Map<String, Object> testData = testUtil.initData();
        ccrz__E_Product__c product = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        ACAMSProductPricingComparison.ProductPricingComparisonResponse response =
                ACAMSProductPricingComparison.getProductPricingComparison(new List<String>{product.Id}, 'USD');
        System.assertEquals(response.priceMap.get(product.Id).get('private'), 10.00);
        System.assertEquals(response.priceMap.get(product.Id).get('public'), 10.00);
    }
    @IsTest
    static void testProductPricingComparisonsubProd() {
        Map<String, Object> testData = testUtil.initData();
        ccrz__E_SubProdTerm__c subProdTerm = (ccrz__E_SubProdTerm__c) testData.get(CCAviTestUtil.PN_SUBPRODUCT);
        ACAMSProductPricingComparisonSubProd.ProductPricingComparisonResponse response =
                ACAMSProductPricingComparisonSubProd.getProductPricingComparison(new List<String>{subProdTerm.Id}, 'USD');

    }
	@IsTest
    static void testProductPricingComparisonsubProdnull() {
        Map<String, Object> testData = testUtil.initData();
        ccrz__E_SubProdTerm__c subProdTerm = (ccrz__E_SubProdTerm__c) testData.get(CCAviTestUtil.PN_SUBPRODUCT);
        ACAMSProductPricingComparisonSubProd.ProductPricingComparisonResponse response =
                ACAMSProductPricingComparisonSubProd.getProductPricingComparison(null, 'USD');

    }
}