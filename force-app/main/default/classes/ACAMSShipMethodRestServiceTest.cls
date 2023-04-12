/**
 * @Description: Tests for ACAMSShipMethodRestService class.
 */
@IsTest
private with sharing class ACAMSShipMethodRestServiceTest {
    @TestSetup
    static void testSetup() {
        User testUser = new User();
        testUser.Alias = 'test';
        testUser.DigestFrequency = 'D';
        testUser.DefaultGroupNotificationFrequency = 'N';
        testUser.Email = 'test@Email.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.LastName = 'testLastName';
        testUser.CommunityNickname = 'testCName';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.Username = 'testUser@smth.com';
        insert testUser;

        createStandardUser();

        System.runAs(testUser) {
            ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
            insert cart;
        }
    }

    static User createStandardUser() {
        User testUser = new User();
        testUser.Alias = 'test1';
        testUser.DigestFrequency = 'D';
        testUser.DefaultGroupNotificationFrequency = 'N';
        testUser.Email = 'test1@Email.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.LastName = 'testLastName1';
        testUser.CommunityNickname = 'testCName1';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.Username = 'testUser1@smth.com';
        insert testUser;
        return testUser;
    }

    @IsTest
    static void testSetShipMethodPositive() {
        User testUser = getUser();

        System.runAs(testUser) {
            Test.startTest();

            ccrz__E_Cart__c cart = [
                    SELECT ccrz__ShipMethod__c, ccrz__ShipAmount__c
                    FROM ccrz__E_Cart__c
                    LIMIT 1
            ];

            String sfid = String.valueOf(cart.Id);
            String shipMethod = 'testShipMethod';
            String shipAmount = '5.8895';
            String shipDiscount = '1.2';

            String currentUrl = Url.getOrgDomainUrl().toExternalForm();

            RestRequest request = new RestRequest();
            request.requestURI = currentUrl + '/services/apexrest/api/cart/revise';
            request.httpMethod = 'POST';
            request.addParameter('sfid', sfid);
            request.addParameter('shipMethod', shipMethod);
            request.addParameter('shipAmount', shipAmount);
            request.addParameter('shipDiscount', shipDiscount);
            RestContext.request = request;
            System.debug('testSetShipMethodPositive request: ' + RestContext.request);
            ACAMSShipMethodRestService.ReviseResult result = ACAMSShipMethodRestService.setShipMethod(sfid, shipMethod, shipAmount, shipDiscount);

            System.debug('testSetShipMethodPositive json: ' + JSON.serializePretty(result));
            cart = [
                    SELECT ccrz__ShipMethod__c, ccrz__ShipAmount__c, ccrz__ShipDiscountAmount__c
                    FROM ccrz__E_Cart__c
                    LIMIT 1
            ];
            Test.stopTest();

            System.assert(result != null);
            System.assertEquals(true, result.getSuccess());
            System.assertEquals(shipMethod, cart.ccrz__ShipMethod__c);
            System.assertEquals(Decimal.valueOf(shipAmount).setScale(2), cart.ccrz__ShipAmount__c);
            System.assertEquals(Decimal.valueOf(shipDiscount).setScale(2), cart.ccrz__ShipDiscountAmount__c);
        }
    }

    @IsTest
    static void testSetShipMethodNegative() {
        User testUser = getUser();

        System.runAs(testUser) {
            Test.startTest();

            ccrz__E_Cart__c cart = [
                    SELECT ccrz__ShipMethod__c, ccrz__ShipAmount__c
                    FROM ccrz__E_Cart__c
                    LIMIT 1
            ];

            String sfid = String.valueOf(cart.Id);
            String shipMethod = 'testShipMethod';
            String shipAmount = 'testShipAmount';
            String shipDiscount = 'testShipDiscount';

            String currentUrl = Url.getOrgDomainUrl().toExternalForm();

            RestRequest request = new RestRequest();
            request.requestURI = currentUrl + '/services/apexrest/api/cart/revise';
            request.httpMethod = 'POST';
            request.addParameter('sfid', sfid);
            request.addParameter('shipMethod', shipMethod);
            request.addParameter('shipAmount', shipAmount);
            request.addParameter('shipDiscount', shipDiscount);
            RestContext.request = request;
            System.debug('testSetShipMethodNegative request: ' + RestContext.request);
            ACAMSShipMethodRestService.ReviseResult result = ACAMSShipMethodRestService.setShipMethod(sfid, shipMethod, shipAmount, shipDiscount);

            System.debug('testSetShipMethodNegative json: ' + JSON.serializePretty(result));
            Test.stopTest();

            System.assert(result != null);
            System.assertEquals(false, result.getSuccess());
        }
    }

    @IsTest
    static void testSetEmptyShipMethodPositive() {
        User testUser = getUser();

        System.runAs(testUser) {
            Test.startTest();

            ccrz__E_Cart__c cart = [
                    SELECT ccrz__ShipMethod__c, ccrz__ShipAmount__c
                    FROM ccrz__E_Cart__c
                    LIMIT 1
            ];

            String sfid = String.valueOf(cart.Id);
            String shipMethod = '';
            String shipAmount = '';
            String shipDiscount = '';

            String currentUrl = Url.getOrgDomainUrl().toExternalForm();

            RestRequest request = new RestRequest();
            request.requestURI = currentUrl + '/services/apexrest/api/cart/revise';
            request.httpMethod = 'POST';
            request.addParameter('sfid', sfid);
            request.addParameter('shipMethod', shipMethod);
            request.addParameter('shipAmount', shipAmount);
            request.addParameter('shipDiscount', shipDiscount);
            RestContext.request = request;
            System.debug('testSetEmptyShipMethodPositive request: ' + RestContext.request);
            ACAMSShipMethodRestService.ReviseResult result = ACAMSShipMethodRestService.setShipMethod(sfid, shipMethod, shipAmount, shipDiscount);

            System.debug('testSetEmptyShipMethodPositive json: ' + JSON.serializePretty(result));
            cart = [
                    SELECT ccrz__ShipMethod__c, ccrz__ShipAmount__c, ccrz__ShipDiscountAmount__c
                    FROM ccrz__E_Cart__c
                    LIMIT 1
            ];
            Test.stopTest();

            System.assert(result != null);
            System.assertEquals(true, result.getSuccess());
            System.assertEquals(null, cart.ccrz__ShipMethod__c);
            System.assertEquals(null, cart.ccrz__ShipAmount__c);
            System.assertEquals(null, cart.ccrz__ShipDiscountAmount__c);
        }
    }

    @IsTest
    static void testUpdateShipMethodNegative() {
        User testUser = getStdUser();

        RestRequest request = new RestRequest();
        ccrz__E_Cart__c cart = [
                SELECT ccrz__ShipMethod__c, ccrz__ShipAmount__c
                FROM ccrz__E_Cart__c
                LIMIT 1
        ];
        String sfid = String.valueOf(cart.Id);
        String shipMethod = '';
        String shipAmount = '';
        String shipDiscount = '';
        ACAMSShipMethodRestService.ReviseResult result;

        System.runAs(testUser) {
            Test.startTest();
            String currentUrl = Url.getOrgDomainUrl().toExternalForm();

            request.requestURI = currentUrl + '/services/apexrest/api/cart/revise';
            request.httpMethod = 'POST';
            request.addParameter('sfid', sfid);
            request.addParameter('shipMethod', shipMethod);
            request.addParameter('shipAmount', shipAmount);
            request.addParameter('shipDiscount', shipDiscount);
            RestContext.request = request;
            System.debug('testUpdateShipMethodNegative request: ' + RestContext.request);
            result = ACAMSShipMethodRestService.setShipMethod(sfid, shipMethod, shipAmount, shipDiscount);

            System.debug('testUpdateShipMethodNegative json: ' + JSON.serializePretty(result));
        }

        System.debug('testUpdateShipMethodNegative json: ' + JSON.serializePretty(result));
        cart = [
                SELECT ccrz__ShipMethod__c, ccrz__ShipAmount__c, ccrz__ShipDiscountAmount__c
                FROM ccrz__E_Cart__c
                LIMIT 1
        ];
        Test.stopTest();

        System.assert(result != null);
        System.assertEquals(false, result.getSuccess());
        System.assertEquals(null, cart.ccrz__ShipMethod__c);
        System.assertEquals(null, cart.ccrz__ShipAmount__c);
        System.assertEquals(null, cart.ccrz__ShipDiscountAmount__c);
    }

    static User getUser() {
        return [
                SELECT Id, Profile.Name
                FROM User
                WHERE Username = 'testUser@smth.com'
                LIMIT 1
        ];
    }

    static User getStdUser() {
        return [
                SELECT Id, Profile.Name
                FROM User
                WHERE Username = 'testUser1@smth.com'
                LIMIT 1
        ];
    }
}