@IsTest
class ACAMSOpportunityQuoteServiceTest {

    static final Decimal CART_ITEM_PRICE1 = 15;
    static final Decimal CART_ITEM_PRICE2 = 30;

    static void makeData(Integer stage) {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> testData = testUtil.initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        Account testAccount = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);
        ccrz__E_Cart__c testCart = (ccrz__E_Cart__c) testData.get(CCAviTestUtil.PN_CART);
        ccrz__E_Product__c testProduct = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        Opportunity testOpportunity;
        Quote testQuote;
        ccrz__E_CartItem__c testCartItem;
        if (stage >= 1) {
            testOpportunity = new Opportunity(
                    AccountId = testAccount.Id,
                    CC_Cart__c = testCart.Id,
                    Name = 'Test Opportunity',
                    StageName = Opportunity.StageName.getDescribe().getPicklistValues()[0].getValue(),
                    CloseDate = Date.today().addDays(10)
            );
            if (stage == 1) {
                Test.startTest();
            }
            insert testOpportunity;
        }
        if (stage >= 2) {
            testOpportunity = [
                    SELECT SyncedQuoteId, CC_Cart__c, CC_Cart__r.Id, CC_Cart__r.Name
                    FROM Opportunity
                    WHERE Id = :testOpportunity.Id
            ];
            testUtil.KEY = String.valueOf(Datetime.now().getTime() + 10);
            testCartItem = testUtil.createCartItem(testOpportunity.CC_Cart__r, CART_ITEM_PRICE1, 1, testProduct, null);
            Id addressId = ((ccrz__E_ContactAddr__c) testData.get(CCAviTestUtil.PN_CONTACT_ADDRESS)).Id;
            insert testCartItem;
            update new ccrz__E_Cart__c(
                    Id = testOpportunity.CC_Cart__c,
                    ccrz__BillTo__c = addressId,
                    ccrz__ShipTo__c = addressId
            );
            testQuote = new Quote(
                    Name = 'test quote',
                    OpportunityId = testOpportunity.Id
            );
            if (stage == 2) {
                Test.startTest();
            }
            insert testQuote;
        }
        if (stage >= 3) {
            testQuote = [
                    SELECT CC_Cart__c
                    FROM Quote
                    WHERE Id = :testQuote.Id
            ];
            testCartItem = [
                    SELECT ccrz__Price__c
                    FROM ccrz__E_CartItem__c
                    WHERE ccrz__Cart__c = :testQuote.CC_Cart__c
            ];
            testCartItem.ccrz__Price__c = CART_ITEM_PRICE2;
            update testCartItem;
            testOpportunity.SyncedQuoteId = testQuote.Id;
            if (stage == 3) {
                Test.startTest();
            }
            update testOpportunity;
        }
        if (stage >= 4) {
            testOpportunity = [
                    SELECT SyncedQuoteId
                    FROM Opportunity
                    LIMIT 1
            ];
            if (stage == 4) {
                Test.startTest();
            }else{
                Test.startTest();
            }
            testOpportunity.SyncedQuoteId = null;
            update testOpportunity;
        }
    }

    @IsTest
    static void createCartForOpportunity() {
        makeData(1);
        Test.stopTest();
        Opportunity testOpportunity = [
                SELECT CC_Cart__c
                FROM Opportunity
                LIMIT 1
        ];
        System.assert(!String.isBlank(testOpportunity.CC_Cart__c));
    }

    @IsTest
    static void createQuote() {
        makeData(2);
        Test.stopTest();
        Opportunity testOpportunity = [
                SELECT CC_Cart__c, CC_Cart__r.ccrz__TotalQuantity__c
                FROM Opportunity
                LIMIT 1
        ];
        Quote testQuote = [
                SELECT Id, CC_Cart__c, CC_Cart__r.ccrz__TotalQuantity__c
                FROM Quote
                LIMIT 1
        ];
        ccrz__E_CartItem__c quoteCartItem = [
                SELECT Id, Quote__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__c = :testQuote.CC_Cart__c
        ];
        System.assertEquals(testQuote.Id, quoteCartItem.Quote__c);
        System.assertNotEquals(
                testOpportunity.CC_Cart__c,
                testQuote.CC_Cart__c
        );
        System.assertEquals(
                testOpportunity.CC_Cart__r.ccrz__TotalQuantity__c,
                testQuote.CC_Cart__r.ccrz__TotalQuantity__c
        );
    }

    @IsTest
    static void syncQuote() {
        makeData(3);
        Test.stopTest();
        Opportunity testOpportunity = [
                SELECT CC_Cart__c, CC_Cart__r.ccrz__SubtotalAmount__c
                FROM Opportunity
                LIMIT 1
        ];
        Quote testQuote = [
                SELECT Id, CC_Cart__c, CC_Cart__r.ccrz__SubtotalAmount__c
                FROM Quote
                LIMIT 1
        ];
        System.assertEquals(
                testOpportunity.CC_Cart__c,
                testQuote.CC_Cart__c
        );
        System.assertEquals(
                testOpportunity.CC_Cart__r.ccrz__SubtotalAmount__c,
                testQuote.CC_Cart__r.ccrz__SubtotalAmount__c
        );
    }

/*    @IsTest
    static void unsyncQuote() {
        makeData(4);
        Test.stopTest();    
        Opportunity testOpportunity = [
                SELECT CC_Cart__c, CC_Cart__r.ccrz__SubtotalAmount__c
                FROM Opportunity
                LIMIT 1
        ];
        Quote testQuote = [
                SELECT Id, CC_Cart__c, CC_Cart__r.ccrz__SubtotalAmount__c
                FROM Quote
                LIMIT 1
        ];
        System.assertNotEquals(
                testOpportunity.CC_Cart__c,
                testQuote.CC_Cart__c
        );
        System.assertEquals(
                testOpportunity.CC_Cart__r.ccrz__SubtotalAmount__c,
                testQuote.CC_Cart__r.ccrz__SubtotalAmount__c
        );
       
    }*/
}