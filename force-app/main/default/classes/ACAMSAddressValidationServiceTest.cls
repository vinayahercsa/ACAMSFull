@IsTest
public class ACAMSAddressValidationServiceTest {

    @TestSetup static void setup() {
        upsert new VertexSettings__c(
                Username__c = 'Karl',
                Password__c = '12345test',
                TrustedId__c = '$tr.2qZj9kG1',
                Successful_Confidence_Threshold__c = 70
        );
    }

    @IsTest
    public static void identifyAddressTaxAreaIdAsync() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ACAMSAddressValidationServiceMock());
        insert ACAMSAddressValidationServiceTest.getAddress();
        insert ACAMSAddressValidationServiceTest.getProduct();
        Test.stopTest();
        ccrz__E_ContactAddr__c address = [
                SELECT Vertex_Tax_Area_Id__c
                FROM ccrz__E_ContactAddr__c
                LIMIT 1
        ];
        ccrz__E_Product__c product = [
            SELECT Event_Tax_Area_Id__c
            FROM ccrz__E_Product__c
            LIMIT 1
        ];
        System.assert(address.Vertex_Tax_Area_Id__c != null);
        System.assert(product.Event_Tax_Area_Id__c != null);
    }

    @IsTest
    public static void identifyAddressTaxAreaIdOnUpdate() {
        ccrz__E_ContactAddr__c address = ACAMSAddressValidationServiceTest.getAddress();
        ccrz__E_Product__c product = ACAMSAddressValidationServiceTest.getProduct();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        insert address;
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        ACAMSProductTriggerHandler.skipVertexAddressValidation = true;
        insert product;
        ACAMSProductTriggerHandler.skipVertexAddressValidation = false;
        address.ccrz__Country__c = address.ccrz__Country__c + '1';
        product.Event_Address_Country__c = product.Event_Address_Country__c + '1';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ACAMSAddressValidationServiceMock());
        update address;
        update product;
        Test.stopTest();
        ccrz__E_ContactAddr__c addressToCheck = [
                SELECT Vertex_Tax_Area_Id__c
                FROM ccrz__E_ContactAddr__c
                LIMIT 1
        ];
        ccrz__E_Product__c productToCheck = [
            SELECT Event_Tax_Area_Id__c
            FROM ccrz__E_Product__c
            LIMIT 1
        ];
        System.assert(addressToCheck.Vertex_Tax_Area_Id__c != null);
        System.assert(productToCheck.Event_Tax_Area_Id__c != null);
    }

    @IsTest
    public static void getAddressTaxAreaIdtest() {
        ccrz__E_ContactAddr__c adr = new ccrz__E_ContactAddr__c();
        List<ccrz__E_ContactAddr__c> addresses = new List <ccrz__E_ContactAddr__c>();
        addresses.add(adr);
        Test.setMock(HttpCalloutMock.class, new ACAMSAddressValidationServiceMock());
        Test.startTest();
        List <ACAMSAddressValidationService.TaxAreaValidationResult> results =
            ACAMSAddressValidationService.getContactAddressValidationService().getAddressTaxAreaId(
                    new ccrz__E_ContactAddr__c[]{
                            ACAMSAddressValidationServiceTest.getAddress()
                    }
            );
        Test.stopTest();
        System.assertEquals(true, results[0].isSuccess);
    }

    @IsTest
    public static void getAddressTaxAreaIdtestError() {
        ccrz__E_ContactAddr__c adr = new ccrz__E_ContactAddr__c();
        List<ccrz__E_ContactAddr__c> addresses = new List <ccrz__E_ContactAddr__c>();
        addresses.add(adr);
        Test.setMock(HttpCalloutMock.class, new ACAMSAddressValidationServiceMockError());
        Test.startTest();
        List <ACAMSAddressValidationService.TaxAreaValidationResult> results =
            ACAMSAddressValidationService.getContactAddressValidationService().getAddressTaxAreaId(
                    new ccrz__E_ContactAddr__c[]{
                            ACAMSAddressValidationServiceTest.getAddress()
                    }
            );
        Test.stopTest();
        System.assertEquals(false, results[0].isSuccess);
    }

    @IsTest
    static void validateAddressEndpointInvoke() {
        ccrz__E_ContactAddr__c address = ACAMSAddressValidationServiceTest.getAddress();
        Test.setMock(HttpCalloutMock.class, new ACAMSAddressValidationServiceMock());
        Test.startTest();
        ACAMSAddressValidationService.TaxAreaValidationResult results =
                ACAMSAddressValidationService.validateAddress(
                        address.ccrz__AddressFirstline__c,
                        address.ccrz__AddressSecondline__c,
                        address.ccrz__City__c,
                        address.ccrz__State__c,
                        address.ccrz__CountryISOCode__c,
                        address.ccrz__PostalCode__c
                );
        Test.stopTest();
        System.assert(results.isSuccess);
    }

    @IsTest
    static void validateAddressEndpointInvokeSameAddress() {
        ccrz__E_ContactAddr__c address = ACAMSAddressValidationServiceTest.getLegitAddress();
        Test.setMock(HttpCalloutMock.class, new ACAMSAddressValidationServiceMock());
        Test.startTest();
        ACAMSAddressValidationService.TaxAreaValidationResult results =
                ACAMSAddressValidationService.validateAddress(
                        address.ccrz__AddressFirstline__c,
                        address.ccrz__AddressSecondline__c,
                        address.ccrz__City__c,
                        address.ccrz__State__c,
                        address.ccrz__CountryISOCode__c,
                        address.ccrz__PostalCode__c
                );
        Test.stopTest();
        System.assert(results.isSuccess);
    }

    @IsTest
    static void validateAddressEndpointInvokeError() {
        ccrz__E_ContactAddr__c address = ACAMSAddressValidationServiceTest.getAddress();
        Test.setMock(HttpCalloutMock.class, new ACAMSAddressValidationServiceMock());
        Test.startTest();
        ACAMSAddressValidationService.TaxAreaValidationResult results =
                ACAMSAddressValidationService.validateAddress(
                        address.ccrz__AddressFirstline__c,
                        address.ccrz__AddressSecondline__c,
                        address.ccrz__City__c,
                        address.ccrz__State__c,
                        '',
                        address.ccrz__PostalCode__c
                );
        Test.stopTest();
        System.assert(!results.isSuccess);
    }

    static ccrz__E_ContactAddr__c getAddress() {
        return new ccrz__E_ContactAddr__c(
                ccrz__AddressFirstline__c = '405 mission st',
                ccrz__City__c = 'SFrancisco',
                ccrz__State__c = 'CA',
                ccrz__PostalCode__c = '000000',
                ccrz__CountryISOCode__c = 'US'
        );
    }

    static ccrz__E_ContactAddr__c getLegitAddress() {
        return new ccrz__E_ContactAddr__c(
                ccrz__AddressFirstLine__c = '415 Mission St',
                ccrz__City__c = 'San Francisco',
                ccrz__State__c = 'CA',
                ccrz__PostalCode__c = '94105-2533',
                ccrz__CountryISOCode__c = 'USA'
        );
    }

    static ccrz__E_Product__c getProduct() {
        ccrz__E_Product__c testProduct = new CCACAMSTestUtil().createProduct('test product', 'TEST', 'Conferences');
        testProduct.Event_Address_Street_1__c = '405 mission st';
        testProduct.Event_Address_City__c = 'SFrancisco';
        testProduct.Event_Address_State__c = 'CA';
        testProduct.Event_Address_Country__c = 'US';
        testProduct.Event_Address_Zip__c = '000000';
        return testProduct;
    }

}