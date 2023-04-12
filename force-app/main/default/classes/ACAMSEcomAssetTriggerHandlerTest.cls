@IsTest
public class ACAMSEcomAssetTriggerHandlerTest {
    public ACAMSEcomAssetTriggerHandlerTest() {

    }

    @TestSetup
    static void initData() {
        CCACAMSTestUtil testUtil = new CCACAMSTestUtil();
        Account testAccount = new Account(
                Name = 'test',
                Assets_Assigned__c = 2
        );
        insert testAccount;
        ccrz__E_Order__c testOrder = new ccrz__E_Order__c(
                Assets_Assigned__c = 2
        );
        insert testOrder;

        ccrz__E_OrderItem__c testOrderItem = new ccrz__E_OrderItem__c(
                ccrz__Order__c = testOrder.Id,
                ccrz__Price__c = 32,
                ccrz__Quantity__c = 1,
                ccrz__SubAmount__c = 3
        );
        insert testOrderItem;

        ccrz__E_Subscription__c testSub = new ccrz__E_Subscription__c(
                ccrz__CCOrderItem__c = testOrderItem.Id,
                ccrz__Quantity__c = 1,
                ccrz__Sequence__c = 1,
                ccrz__Storefront__c = 'acams',
                ccrz__SubscriptionStartDate__c = datetime.now(),
                ccrz__SubscriptionStatus__c = 'Purchased'
        );
        insert testSub;

        Contact testContact = new Contact(
                LastName = 'Test',
                AccountId = testAccount.Id,
                Member_Expire_Date__c = (Date.today()+20)
        );
        insert testContact;

        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Test Course';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;


        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
        ccrz__E_Product__c compd = new ccrz__E_Product__c();
        compd.HigherLogic_Group__c = 'HL Community';
        compd.Level_1__c = 'Certification';
        compd.ProductCategory__c = 'Memberships';
        compd.ccrz__SKU__c= '1234';
        compd.Days_to_Expire__c = 200;
        compd.LMS_Course__c = lmsc.Id;

        ccrz__E_Product__c secpd = new ccrz__E_Product__c();
        secpd.HigherLogic_Group__c = 'HL Security Group';
        secpd.Level_1__c = 'Certification';
        secpd.ProductCategory__c = 'Memberships';
        secpd.ccrz__SKU__c= '3456';
        secpd.Days_to_Expire__c = 200;
        secpd.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c camsCert = new ccrz__E_Product__c();
        camsCert.Level_1__c = 'Certification';
        camsCert.Level_2__c = 'CAMS';
        camsCert.Level_3__c = 'Recertification';
        camsCert.Certification_Level__c = 'Specialist';
        camsCert.ProductCategory__c = 'Memberships';
        camsCert.ccrz__SKU__c= '1735';
        camsCert.Days_to_Expire__c = 205;
        camsCert.LMS_Course__c = lmsc.Id;

        ccrz__E_Product__c hlNull = new ccrz__E_Product__c();
        hlNull.Level_1__c = 'Certification';
        hlNull.Level_2__c = 'Advanced CAMS - Audit';
        hlNull.Level_3__c = 'Recertification';
        hlNull.Certification_Level__c = 'Advanced';
        hlNull.ProductCategory__c = 'Memberships';
        hlNull.ccrz__SKU__c= '1734';
        hlNull.Days_to_Expire__c = 205;
        hlNull.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c thirdpd = new ccrz__E_Product__c();
        thirdpd.Level_1__c = 'Certification';
        thirdpd.Level_2__c = 'CGSS';
        thirdpd.Level_3__c = 'Recertification';
        thirdpd.Certification_Level__c = 'Specialist';
        thirdpd.ProductCategory__c = 'Memberships';
        thirdpd.ccrz__SKU__c= 'SG-AML-Regime';
        thirdpd.Days_to_Expire__c = 205;
        thirdpd.LMS_Course__c = lmsc.Id;

        ccrz__E_Product__c ckycaPd = new ccrz__E_Product__c();
        ckycaPd.Level_1__c = 'Certification';
        ckycaPd.Level_2__c = 'CKYCA';
        ckycaPd.Level_3__c = 'Recertification';
        ckycaPd.Certification_Level__c = 'Associate';
        ckycaPd.ProductCategory__c = 'Memberships';
        ckycaPd.ccrz__SKU__c= '1456';
        ckycaPd.Days_to_Expire__c = 205;
        ckycaPd.LMS_Course__c = lmsc.Id;

        ccrz__E_Product__c ctmaPd = new ccrz__E_Product__c();
        ctmaPd.Level_1__c = 'Certification';
        ctmaPd.Level_2__c = 'CTMA';
        ctmaPd.Level_3__c = 'Recertification';
        ctmaPd.Certification_Level__c = 'Associate';
        ctmaPd.ProductCategory__c = 'Memberships';
        ctmaPd.ccrz__SKU__c= '4252';
        ctmaPd.Days_to_Expire__c = 205;
        ctmaPd.LMS_Course__c = lmsc.Id;

        ccrz__E_Product__c cafcaPd = new ccrz__E_Product__c();
        cafcaPd.Level_1__c = 'Certification';
        cafcaPd.Level_2__c = 'CAFCA';
        cafcaPd.Level_3__c = 'Recertification';
        cafcaPd.Certification_Level__c = 'Associate';
        cafcaPd.ProductCategory__c = 'Memberships';
        cafcaPd.ccrz__SKU__c= '4052';
        cafcaPd.Days_to_Expire__c = 205;
        cafcaPd.LMS_Course__c = lmsc.Id;
        
        products.add(compd);
        products.add(secpd);
        products.add(hlNull);
        products.add(thirdpd);
        products.add(ckycaPd);
        products.add(ctmaPd);
        products.add(cafcaPd);
        products.add(camsCert);
        insert products;

        List<Asset> testAssets = new List<Asset>{
                new Asset(
                        Name = 'Membership',
                        AccountId = testAccount.Id,
                        status__c='Active',
                        Assignee__c = testContact.Id,
                        CC_Product__c = products[0].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = false,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'Moneylaundering.com',
                        AccountId = testAccount.Id,
                        status__c='Active',
                        Assignee__c = testContact.Id,
                        CC_Product__c = products[1].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = false,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'CGSS Certification - New',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[0].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'CAMS Certification - New',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[0].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'ACAMS Today '+'Printed Subscription',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[2].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'Advanced CAMS - Audit Certification - New',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = thirdpd.Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'CKYCA Certification - New',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[4].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'CTMA Certification - New',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[5].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'CAFCA Certification',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[6].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),

                new Asset(
                        Name = 'Advanced CAMS - FCI Certification - New',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[6].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),

                new Asset(
                        Name = 'Advanced CAMS - Risk Management Certification - New',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[6].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),

                //recertification asset
                new Asset(
                        Name = 'CAMS Certification - Recertification',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[0].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                
                new Asset(
                        Name = 'CGSS Certification - Recertification',
                        Paid_Cert__c = true,
                        CC_Product__c = products[0].Id
                ),
                new Asset(
                        Name = 'CKYCA Certification - Recertification',
                        CC_Product__c = products[0].Id
                ),
                new Asset(
                        Name = 'CTMA Certification - Recertification',
                        CC_Product__c = products[0].Id
                ),
                new Asset(
                        Name = 'Advanced CAMS - Audit Certification - Recertification',
                        CC_Product__c = products[0].Id
                ),
                new Asset(
                        Name = 'Advanced CAMS - FCI Certification - Recertification',
                        CC_Product__c = products[0].Id
                ),
                new Asset(
                        Name = 'Advanced CAMS - Risk Management Certification - Recertification',
                        CC_Product__c = products[0].Id
                )
                
        };
        insert testAssets;

        
        List<BeckerLMS_Enrollment__c> lmsEnrollment = new List<BeckerLMS_Enrollment__c>{
            new BeckerLMS_Enrollment__c(Account__c = testAccount.Id,Purchase_Date__c = Date.today().addDays(-14), LMS_Course__c=lmsc.Id, Asset__c=testAssets[0].Id)
        };
        insert lmsEnrollment;
    }

    @IsTest
    public static void testUpdateAsset(){
        Test.startTest();
        
        List<Asset> updateList = [SELECT Id,Paid_Cert__c,status__c, Name FROM Asset LIMIT 50];
        for(Asset a : updateList){
            a.Paid_Cert__c = false;
            a.Certification_Approved_Application__c = true;
            a.Payment_Status__c = 'Authorized';
        }

        List<BeckerLMS_Enrollment__c> lmscs = [SELECT Id,Name,Asset__c FROM BeckerLMS_Enrollment__c LIMIT 1];
        lmscs[0].Asset__c = updateList[0].Id;
        //insert lmscs;

        update updateList[0];

        for(Asset a : updateList){
            a.Paid_Cert__c = true;
            //a.Certification_Approved_Application__c = true;
            a.Payment_Status__c = 'Completed';
            
        }
        update updateList[0];
         for(Asset a : updateList){
            a.status__c = 'Inactive';
            //a.Certification_Approved_Application__c = true;
            a.Payment_Status__c = 'Completed';
        }
        update updateList[0];

        Test.stopTest();
       
    }

    @isTest
    public static void updateCanceldate(){
        Test.startTest();
        
        Asset testAsset = [SELECT Id,Paid_Cert__c,status__c,CancelDate__c, Name FROM Asset where Name = 'CKYCA Certification - New' Limit 1];
        system.debug('testAsset.CancelDate__c::'+testAsset.CancelDate__c);
        system.debug('testAsset.status__c::'+testAsset.status__c);
        testAsset.CancelDate__c = system.today();
        update testAsset;
        
        Asset testAsset1 = [SELECT Id,Paid_Cert__c,status__c, Name,CancelDate__c FROM Asset where Name = 'CKYCA Certification - New' Limit 1];
        system.assertEquals(testAsset1.CancelDate__c,system.today());
        system.assertEquals(testAsset1.status__c,'Inactive');
        Test.stopTest();    
    }

    @isTest
    public static void updateCurrentExpirationDate(){
        Test.startTest();
        
        Asset testAsset = [SELECT Id,Paid_Cert__c,status__c,Enterprise_Product_HL__c, Name,Exam_Result_for_Exp_date__c FROM Asset where Name = 'CKYCA Certification - New' Limit 1];
        system.debug('testAsset.Exam_Result_for_Exp_date__c::'+testAsset.Exam_Result_for_Exp_date__c);
        system.debug('testAsset.Enterprise_Product_HL__c::'+testAsset.Enterprise_Product_HL__c);
        testAsset.Exam_Result_for_Exp_date__c = 'Pass';
        update testAsset;
        
        Asset testAsset1 = [SELECT Id,Paid_Cert__c,status__c, Name,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'CKYCA Certification - New' Limit 1];
        
        Date currentExpirationdate = Date.valueOf('2099-12-15');
      //  system.assertEquals(testAsset1.CurrentExpirationDate__c,null);
        Test.stopTest();    
    }
    
    @isTest
    public static void testAuthorisedAssets(){
        Test.startTest();
        
        Asset testAsset = [SELECT Id,Paid_Cert__c,status__c,Enterprise_Product_HL__c, Name,Exam_Result_for_Exp_date__c FROM Asset where Name = 'Membership' Limit 1];
        system.debug('testAsset.Exam_Result_for_Exp_date__c::'+testAsset.Exam_Result_for_Exp_date__c);
        system.debug('testAsset.Enterprise_Product_HL__c::'+testAsset.Enterprise_Product_HL__c);
        
        testAsset = [SELECT Id,Paid_Cert__c,status__c, Assignee__c,Name,Payment_Status__c,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'Membership' Limit 1];
        Map<Id,Asset> oldMap = new Map<ID,Asset>();
        oldMap.put(testAsset.id, testAsset);
        
        testAsset.Exam_Result_for_Exp_date__c = 'Pass';
        testAsset.Payment_Status__c = 'Authorized';
        
        ACAMSAssetTriggerHandler.isauthorizedStatusUpdated=false;
        update testAsset;
        
        Asset testAsset1 = [SELECT Id,Paid_Cert__c,status__c, Name, Payment_Status__c,Assignee__c,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'Membership' Limit 1];
        List<Asset> newAssets = new List<Asset>();
        newAssets.add(testAsset1);
        ACAMSAssetTriggerHandler.isauthorizedStatusUpdated=false;
        
        ACAMSAssetTriggerHandler.authorizedStatus(newAssets,oldMap);
        
        system.assertEquals(Date.today().addDays(5), testAsset1.CurrentExpirationDate__c);
        Test.stopTest();    
    }
}