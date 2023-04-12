@IsTest
class ACAMSAddressFieldsServiceTest {
    @IsTest
    static void setProductRegionFields() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ccrz__E_Product__c testProduct = testUtil.createProduct('Test', 'TEST', 'acams', 'Conferences');
        testProduct.Event_Address_Country__c = 'CAN';
        insert testProduct;
        testProduct = [
            SELECT Event_Address_Country__c, Event_Address_Region__c, Event_Address_Continent__c
            FROM ccrz__E_Product__c
            WHERE Id = :testProduct.Id
        ];
        System.assertEquals('Americas', testProduct.Event_Address_Region__c);
        System.assertEquals('North America', testProduct.Event_Address_Continent__c);
        testProduct.Event_Address_Country__c = 'CN';
        update testProduct;
        testProduct = [
            SELECT Event_Address_Country__c, Event_Address_Region__c, Event_Address_Continent__c
            FROM ccrz__E_Product__c
            WHERE Id = :testProduct.Id
        ];
        System.assertEquals('APAC', testProduct.Event_Address_Region__c);
        System.assertEquals('Asia', testProduct.Event_Address_Continent__c);

        // FSA-3173a
        List<ccrz__E_Product__c> newList = new List<ccrz__E_Product__c>();
        newList.add(testProduct);
        ACAMSAddressFieldsService.beforeTriggerCall(
                    newList,
                    null,
                    'Event_Address_Country__c',
                    ccrz__E_Product__c.Event_Address_Country__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Address_Region__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Address_Continent__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Address_Named_Territory__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Address_SubTerritory__c.getDescribe().getName(),
                    ccrz__E_Product__c.Event_Vertex_Country__c.getDescribe().getName()
        );
    }

}