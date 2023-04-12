@isTest
public class AssetEMEnrollmentEventsTriggerTest {
	@isTest
    static void testAssetEmEventsTrigger() {
        Account testAccount = new Account(
                Name = 'test',
                Assets_Assigned__c = 2
        );
        insert testAccount;
        
         Contact testContact = new Contact(
                LastName = 'Test',
                AccountId = testAccount.Id,
                Member_Expire_Date__c = (Date.today()+20)
        );
        insert testContact;
        
        ccrz__E_ContactAddr__c adr = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId()
        );
        insert adr;
        
        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Test Course';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;
        
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> initialData = new CCACAMSTestUtil().initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        ccrz__E_Order__c lstOrders = (ccrz__E_Order__c) initialData.get(CCAviTestUtil.PN_ORDER);
        lstOrders.ccrz__CurrencyISOCode__c = 'USD';
        update lstOrders;
        
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
        ccrz__E_Product__c compd = new ccrz__E_Product__c();
        compd.HigherLogic_Group__c = 'HL Community';
        compd.Level_1__c = 'Certification';
        compd.Level_2__c = 'CKYCA';
       // compd.Level_3__c = 'Recertification';
       	compd.Certification_Level__c = 'Associate';
        compd.ProductCategory__c = 'Memberships';
        compd.ccrz__SKU__c= '1234';
        compd.Days_to_Expire__c = 200;
        compd.LMS_Course__c = lmsc.Id;
        compd.Expiration_Date_Logic__c = 'Payment';
        
        products.add(compd);
        insert products;
        
        List<Asset> testAssets = new List<Asset>{
                new Asset(
                        Name = 'Membership',
                        AccountId = testAccount.Id,
                        status__c='Active',
                        Assignee__c = testContact.Id,
                        CC_Product__c = products[0].Id,
                        CC_Order__c = lstOrders.Id,
                        Paid_Cert__c = false,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false
                      
                )
                    
        };
        insert testAssets;
        
        List<BeckerLMS_Enrollment__c> lmsEnrollment = new List<BeckerLMS_Enrollment__c>{
            new BeckerLMS_Enrollment__c(Account__c = testAccount.Id,Purchase_Date__c = Date.today().addDays(-14), LMS_Course__c=lmsc.Id, Asset__c=testAssets[0].Id)
        };
        insert lmsEnrollment;
        List<Asset_EM_Enrollment_Event__e> assetPlatformEvents = new List<Asset_EM_Enrollment_Event__e>();
            for(BeckerLMS_Enrollment__c beckLMS : lmsEnrollment){
                assetPlatformEvents.add(new Asset_EM_Enrollment_Event__e(Asset_ID__c=beckLMS.Id,isInsertLMS__c = true));
                
            }
			
        
        // Insert events
        Test.startTest();
        List<Database.SaveResult> results = EventBus.publish(assetPlatformEvents);
        Test.stopTest();       
    }
    
    @isTest
    static void testAssetEmEventsTrigger1() {
        Account testAccount = new Account(
                Name = 'test',
                Assets_Assigned__c = 2
        );
        insert testAccount;
        
         Contact testContact = new Contact(
                LastName = 'Test',
                AccountId = testAccount.Id,
                Member_Expire_Date__c = (Date.today()+20)
        );
        insert testContact;
        
        ccrz__E_ContactAddr__c adr = new ccrz__E_ContactAddr__c(
                OwnerId = UserInfo.getUserId()
        );
        insert adr;
        
        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Test Course';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;
        
        ACAMSContactAddressTriggerHandler.skipAddressValidation = true;
        Map<String, Object> initialData = new CCACAMSTestUtil().initData();
        ACAMSContactAddressTriggerHandler.skipAddressValidation = false;
        ccrz__E_Order__c lstOrders = (ccrz__E_Order__c) initialData.get(CCAviTestUtil.PN_ORDER);
        lstOrders.ccrz__CurrencyISOCode__c = 'USD';
        update lstOrders;
        
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
        ccrz__E_Product__c compd = new ccrz__E_Product__c();
        compd.HigherLogic_Group__c = 'HL Community';
        compd.Level_1__c = 'Certification';
        compd.Level_2__c = 'CKYCA';
       // compd.Level_3__c = 'Recertification';
       	compd.Certification_Level__c = 'Associate';
        compd.ProductCategory__c = 'Memberships';
        compd.ccrz__SKU__c= '1234';
        compd.Days_to_Expire__c = 200;
        compd.LMS_Course__c = lmsc.Id;
        compd.Expiration_Date_Logic__c = 'Payment';
        
        products.add(compd);
        insert products;
        
        List<Asset> testAssets = new List<Asset>{
                new Asset(
                        Name = 'Membership',
                        AccountId = testAccount.Id,
                        status__c='Active',
                        Assignee__c = testContact.Id,
                        CC_Product__c = products[0].Id,
                        CC_Order__c = lstOrders.Id,
                        Paid_Cert__c = false,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false
                      
                )
                    
        };
        insert testAssets;
        
        List<BeckerLMS_Enrollment__c> lmsEnrollment = new List<BeckerLMS_Enrollment__c>{
            new BeckerLMS_Enrollment__c(Account__c = testAccount.Id,Purchase_Date__c = Date.today().addDays(-14), LMS_Course__c=lmsc.Id, Asset__c=testAssets[0].Id)
        };
        insert lmsEnrollment;
        List<Asset_EM_Enrollment_Event__e> assetPlatformEvents = new List<Asset_EM_Enrollment_Event__e>();
            for(BeckerLMS_Enrollment__c beckLMS : lmsEnrollment){
                assetPlatformEvents.add(new Asset_EM_Enrollment_Event__e(Asset_ID__c=beckLMS.Id,isUpdateLMS__c = true));
                
            }
			
        
        // Insert events
        Test.startTest();
        List<Database.SaveResult> results = EventBus.publish(assetPlatformEvents);
        Test.stopTest();       
    }
}