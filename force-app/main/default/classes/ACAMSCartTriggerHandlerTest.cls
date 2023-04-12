@IsTest
public class ACAMSCartTriggerHandlerTest {
    public ACAMSCartTriggerHandlerTest() {

    }

    @TestSetup
    static void initData() {
        ccrz__E_AccountGroup__c anoTestAccountGroup = new ccrz__E_AccountGroup__c();
        anoTestAccountGroup.Name = 'Anonymous';
        Insert anoTestAccountGroup;

        Account testAccount = new Account(
                Name = 'test',
                Assets_Assigned__c = 2,
                ccrz__E_AccountGroup__c = anoTestAccountGroup.Id
        );
        insert testAccount;

        ccrz__E_Product__c secpd = new ccrz__E_Product__c();
            secpd.HigherLogic_Group__c = 'HL Security Group';
            secpd.Level_1__c = 'Membership';
            secpd.ProductCategory__c = 'Memberships';
            secpd.ccrz__SKU__c= '3456';
            secpd.Days_to_Expire__c = 200;
        insert secpd;

        ccrz__E_Cart__c anoCart = new ccrz__E_Cart__c();
        anoCart.ccrz__Account__c = testAccount.Id;
        anoCart.isDrupalCallCompleted__c = false;
        insert anoCart;

        /*
        ccrz__E_CartItem__c cItem = new ccrz__E_CartItem__c(
                ccrz__Cart__c = anoCart.Id,
                ccrz__SubAmount__c = 300,
                ccrz__Price__c = 300,
                ccrz__OriginalItemPrice__c=300,
                ccrz__OriginalQuantity__c = 1,
                ccrz__Quantity__c = 1,
                ccrz__cartItemType__c = 'Major',
                ccrz__ProductType__c = 'Product',
                ccrz__StoreID__c = 'acams',
                ccrz__Product__c = secpd.Id
        );
        insert cItem; 
        */
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
                delete relateCartItems;
            }

        }
        Test.stopTest();
    }
    }
}

// FSA-773-a