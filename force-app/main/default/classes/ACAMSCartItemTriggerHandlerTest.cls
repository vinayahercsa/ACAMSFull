@IsTest
public class ACAMSCartItemTriggerHandlerTest {

    @TestSetup
    static void initData() {
        ccrz__E_AccountGroup__c anoTestAccountGroup = new ccrz__E_AccountGroup__c();
        anoTestAccountGroup.Name = 'Anonymous';
        Insert anoTestAccountGroup;

        Account acc = new Account(
                ccrz__TaxExemptAccount__c = true,
                Name = 'acc'
        );
        insert acc;
        Contact contact = new Contact(
                AccountId = acc.Id,
                LastName = 'Karl'
        );
        insert contact;
        ccrz__E_ContactAddr__c testAddress = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId(),
                ccrz__AddressFirstline__c = 'line1',
                ccrz__AddressSecondline__c = 'line2',
                ccrz__AddressThirdline__c = 'line3',
                ccrz__City__c = 'city',
                ccrz__State__c = 'state',
                ccrz__Country__c = 'country',
                ccrz__CountryISOCode__c = 'US',
                ccrz__PostalCode__c = 'postalCode',
                Vertex_Tax_Area_Id__c = 780123322
        );
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        insert testAddress;
        System.debug(testAddress.Id);
        ccrz__E_Cart__c cartUnSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
                ccrz__Account__c = acc.Id
        );
        insert cartUnSync;
        ccrz__E_Cart__c cartSync = new ccrz__E_Cart__c(
                ccrz__ShipAmount__c = 2,
                ccrz__TotalDiscount__c = 2,
                ccrz__BillTo__c = testAddress.Id,
                ccrz__ShipTo__c = testAddress.Id,
                ccrz__Account__c = acc.Id
        );
        insert cartSync;
        
        Opportunity testOpportunity = new Opportunity(
            CloseDate = Date.today().addDays(2000),
            ForecastCategoryName = 'Pipeline',
            Name = 'testOpp',
            Probability = 100,
            StageName = 'Qualification',
            SyncedQuoteId = null,
            Coupon_Code__c = 'test',
            CC_Cart__c = cartUnSync.Id,
            AccountId = acc.Id
        );
        insert testOpportunity;
        
        ccrz__E_Product__c compd = new ccrz__E_Product__c();
        compd.HigherLogic_Group__c = 'HL Community';
        compd.Level_1__c = 'Certification';
        compd.ProductCategory__c = 'Memberships';
        compd.ccrz__SKU__c= '1234';
        compd.Days_to_Expire__c = 200;
        insert compd;

        ccrz__E_Product__c secpd = new ccrz__E_Product__c();
        secpd.HigherLogic_Group__c = 'HL Security Group';
        secpd.Level_1__c = 'Certification';
        secpd.ProductCategory__c = 'Memberships';
        secpd.ccrz__SKU__c= '3456';
        secpd.Days_to_Expire__c = 200;
        insert secpd;
        
        ccrz__E_CartItem__c cItem = new ccrz__E_CartItem__c(
                ccrz__Cart__c = cartUnSync.Id,
                ccrz__SubAmount__c = 300,
                ccrz__Price__c = 20,
                ccrz__Quantity__c = 1,
                ccrz__cartItemType__c = 'Major',
                ccrz__ProductType__c = 'Product',
                ccrz__StoreID__c = 'acams',
                ccrz__Product__c = compd.id,
                Opportunity__c = testOpportunity.id
        );
        insert cItem;
        
        ccrz__E_CartItem__c cItem2 = new ccrz__E_CartItem__c(
                ccrz__Cart__c = cartUnSync.Id,
                ccrz__SubAmount__c = 300,
                ccrz__Price__c = 20,
                ccrz__Quantity__c = 1,
                ccrz__cartItemType__c = 'Major',
                ccrz__ProductType__c = 'Product',
                ccrz__StoreID__c = 'acams',
                ccrz__Product__c = secpd.id,
                Opportunity__c = testOpportunity.id
        );
        insert cItem2;
        
        testOpportunity = [SELECT Id, CC_Cart__c, CC_Cart__r.ccrz__ShipTo__c, CC_Cart__r.ccrz__BillTo__c, CC_Cart__r.ccrz__TotalQuantity__c      FROM Opportunity WHERE Id = :testOpportunity.Id];
        system.debug('Oppo::'+testOpportunity); 
        
    }

    @IsTest
    public static void updateCartDrupalCallField(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', FirstName='Drupal', LastName='Integration', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='drupalintegration@adtalem.com.acamsprd.acamsprod');
        insert u;

        System.runAs(u){
            Test.startTest();
                List<ccrz__E_Cart__c> cartList = [SELECT Id, Name, isDrupalCallCompleted__c, ccrz__Account__c, (SELECT Id, Name FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c WHERE isDrupalCallCompleted__c = false LIMIT 1];
                if(cartList != null){
                    cartList[0].isDrupalCallCompleted__c = true;
                    update cartList;
                    
                    List<ccrz__E_CartItem__c> relateCartItems = cartList[0].ccrz__E_CartItems__r;
                    if(relateCartItems != null && relateCartItems.size() > 0){
                        update relateCartItems;
                    }                    

                    if(relateCartItems != null && relateCartItems.size() > 0){
                        delete relateCartItems;
                    }

                }
            Test.stopTest();
        }
    }
}