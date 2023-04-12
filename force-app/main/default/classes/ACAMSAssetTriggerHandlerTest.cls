@IsTest
public class ACAMSAssetTriggerHandlerTest {
    public ACAMSAssetTriggerHandlerTest() {

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
        
          Map<String, Object> initialData = new CCACAMSTestUtil().initData();
        ccrz__E_Order__c order = (ccrz__E_Order__c) initialData.get(CCAviTestUtil.PN_ORDER);
        User u = [SELECT Id FROM user WHERE profile.name='System Administrator' AND isActive = true limit 1];
        order.OwnerId=u.id;
        update order;
        List<ccrz__E_OrderItem__c> orderItems = (List<ccrz__E_OrderItem__c>) initialData.get(CCAviTestUtil.PN_ORDER_ITEMS);
        ccrz__E_OrderItem__c orderItem = orderItems[0];
        ccrz__E_Invoice__c invoice = new ccrz__E_Invoice__c (
                ccrz__BillAddress__c = order.ccrz__BillTo__c,
                ccrz__SoldAddress__c = order.ccrz__ShipTo__c,
                ccrz__BillTo__c = order.ccrz__Account__c,
                ccrz__SoldTo__c = order.ccrz__Account__c,
                ccrz__OriginalAmount__c = order.ccrz__SubtotalAmount__c,
                ccrz__RemainingAmount__c = order.ccrz__SubtotalAmount__c,
                ccrz__CCOrder__c = order.Id,
                ccrz__Contact__c = order.ccrz__Contact__c,
                ccrz__User__c = order.ccrz__User__c,
                ccrz__CurrencyCode__c = order.ccrz__CurrencyISOCode__c
        );
        insert invoice;
        ccrz__E_InvoiceItem__c invoiceItem = new ccrz__E_InvoiceItem__c(
                ccrz__Invoice__c = invoice.Id,
                ccrz__CCOrder__c = order.Id,
                ccrz__CCOrderItem__c = orderItem.Id,
                ccrz__OriginalAmount__c = orderItem.ccrz__SubAmount__c
        );
        insert invoiceItem;
        Map<Id, Decimal> orderItemsMap = new Map<Id, Decimal>();
        for (ccrz__E_OrderItem__c orderItemiterate : order.ccrz__E_OrderItems__r) {
            orderItemsMap.put(orderItemiterate.Id, orderItemiterate.ccrz__Quantity__c);
        }
        
        ACAMSAssetHelper.generateAssetsFuture(order.id);
             ACAMSAssetHelper.activateAssetsFuture(orderItemsMap);
        
        Contact testContact = new Contact(
                LastName = 'Test',
                AccountId = testAccount.Id,
                Member_Expire_Date__c = (Date.today()+20)
        );
        insert testContact;
        
        Contact testContact2 = new Contact(
                LastName = 'Test23',
                AccountId = testAccount.Id,
                Membership_Type__c  = 'MEMBER',
                Member_Expire_Date__c = (Date.today()+20)
        );
        insert testContact2;

        LMSCourse__c lmsc = new LMSCourse__c();
        lmsc.Name= 'Test Course';
        lmsc.Description__c = 'Test Course Description';
        lmsc.Credits__c = 10;
        insert lmsc;


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

        ccrz__E_Product__c secpd = new ccrz__E_Product__c();
        secpd.HigherLogic_Group__c = 'HL Security Group';
        secpd.Level_1__c = 'Certification';
        secpd.ProductCategory__c = 'Memberships';
        secpd.ccrz__SKU__c= '3456';
        secpd.Days_to_Expire__c = 200;
        secpd.LMS_Course__c = lmsc.Id;
        
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
        
        //added by Chinnamanaidu Neerasa- FSA 2544 
        ccrz__E_Product__c hlex = new ccrz__E_Product__c();
        hlex.Level_1__c = 'Certification';
        hlex.Level_2__c = 'CAMS';
        hlex.Level_3__c = 'New';
        hlex.Certification_Level__c = 'Specialist';
        hlex.Exam_Code__c = 'CAMS6_PTBFEB';
        hlex.ProductCategory__c = 'Memberships';
        hlex.ccrz__SKU__c= 'AML';
        hlex.Days_to_Expire__c = 205;
        hlex.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c hlex2 = new ccrz__E_Product__c();
        hlex2.Level_1__c = 'Certification';
        hlex2.Level_2__c = 'Advanced CAMS - Audit';
        hlex2.Level_3__c = 'New';
        hlex2.Certification_Level__c = 'Advanced';
        hlex2.ProductCategory__c = 'Memberships';
        hlex2.ccrz__SKU__c= 'AMLEX';
        hlex2.Days_to_Expire__c = 205;
        hlex2.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c hlex3 = new ccrz__E_Product__c();
        hlex3.Level_1__c = 'Certification';
        hlex3.Level_2__c = 'CAMS';
        hlex3.Level_3__c = 'New';
        hlex3.Certification_Level__c = 'Specialist';
        hlex3.ProductCategory__c = 'Memberships';
        hlex3.ccrz__SKU__c= 'AMLAX';
        hlex3.Days_to_Expire__c = 205;
        hlex3.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c hlex4 = new ccrz__E_Product__c();
        hlex4.Level_1__c = 'Certification';
        hlex4.Level_2__c = 'Singapore Regime';
        hlex4.Level_3__c = 'New';
        hlex4.Certification_Level__c = 'Regime Exam';
        hlex4.ProductCategory__c = 'Memberships';
        hlex4.ccrz__SKU__c= 'AMLAXM';
        hlex4.Days_to_Expire__c = 205;
        hlex4.LMS_Course__c = lmsc.Id;
        
       /* ccrz__E_Product__c hlNull1 = new ccrz__E_Product__c();
        hlNull1.Level_1__c = 'Certification';
        hlNull1.Level_2__c = 'Advanced CAMS - Audit';
        hlNull1.Level_3__c = 'Recertification';
        hlNull1.ProductCategory__c = 'Memberships';
        hlNull1.ccrz__SKU__c= '345';
        hlNull1.Days_to_Expire__c = 205;
        hlNull1.LMS_Course__c = lmsc.Id;
        hlNull1.Exam_Date_to_Expire__c = 118;*/
        
        products.add(compd);
        products.add(secpd);
        products.add(hlNull);
        products.add(thirdpd);
        products.add(hlex);
        products.add(hlex2);
        products.add(hlex3);
        products.add(hlex4);
        //products.add(hlNull1);
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
                        Certification_Approved_Application__c = false
                      
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
                        Certification_Approved_Application__c = false
                ),
                new Asset(
                        Name = 'test3',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[0].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false
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
                        Certification_Approved_Application__c = false
                ),
                new Asset(
                        Name = 'test4',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = thirdpd.Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false
                ),
                    // Added by Chinna -FSA 2544
                new Asset(
                        Name = 'test5',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = thirdpd.Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false
                        
                ),
                new Asset(
                        Name = 'test6',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = thirdpd.Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CancelDate__c = date.newInstance(2021,05,22),
                        LMS_Access_Exp_Date__c = date.newInstance(2021,05,22)
       
                ),
                new Asset(
                        Name = 'ExamTest1',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact2.Id,
                        status__c='Active',
                        CC_Product__c = products[4].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        EAD_created__c = False,
                        Retake__c = False,
                        Recert__c = False,
                        Certification_Approved_Application__c = True,
                        Application_Date__c = Date.newInstance(2021,09,28)
                ),
                    
               new Asset(
                        Name = 'ExamTest2',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact2.Id,
                        status__c='Active',
                        CC_Product__c = products[5].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        EAD_created__c = False,
                        Retake__c = False,
                        Recert__c = False,
                        Certification_Approved_Application__c = True,
                        Application_Date__c = Date.newInstance(2021,09,28)
                ),
                new Asset(
                        Name = 'ExamTest3',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact2.Id,
                        status__c='Active',
                        CC_Product__c = products[6].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        EAD_created__c = False,
                        Retake__c = False,
                        Recert__c = False,
                        Certification_Approved_Application__c = True,
                        Application_Date__c = Date.newInstance(2021,09,28)
                ),
                 new Asset(
                        Name = 'ExamTest4',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact2.Id,
                        status__c='Active',
                        CC_Product__c = products[7].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        EAD_created__c = False,
                        Retake__c = False,
                        Recert__c = False,
                        SG_AML_REGIME_Exam_Application_Approved__c = True,
                        Application_Date__c = Date.newInstance(2021,09,28)
                )
                 /*  new Asset(
                        Name = 'ExamTest5',
                        AccountId = testAccount.Id,
                        Assignee__c = testContact2.Id,
                        status__c='Active',
                        CC_Product__c = products[8].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        EAD_created__c = True,
                        Retake__c = True,
                        Recert__c = False,
                        Certification_Approved_Application__c = True,
                        SG_AML_REGIME_Exam_Application_Approved__c = True,
                        Application_Date__c = Date.newInstance(2021,09,28),
                       Exam_Schedule_Date__c = Date.newInstance(2021,09,29)
                )*/
                    
        };
        insert testAssets;
        
        set<id> contactIdSet = new set<id>();
        contactIdSet.add(testContact2.Id);
      //  ACAMSAssetDao.getAssetsByContactIds(contactIdSet);
        set<id> assetIdSet = new set<id>();
        assetIdSet.add(testAssets[0].id);
     // ACAMSAssetDao.getAssetsByIds(assetIdSet);
      
         Contact mldcContact = new Contact(
                LastName = 'Testmldc',
                AccountId = testAccount.Id
                
        );
        insert mldcContact;
      /*    Recertification_Application__c recertapp = new Recertification_Application__c(
                Asset__c = testAssets[0].id
        );
        insert recertapp;*/
        MLDC_Data__c mldcdata = new MLDC_Data__c(
                contact__c = mldcContact.id, Name='test',Content_Alerts__c = true,
                Weekly_Newsletter__c = true
            
        );
        insert mldcdata;
        List<Generate_Asset__e> assetEvents = new List<Generate_Asset__e>();
        assetEvents.add(new Generate_Asset__e(Order_ID__c=testOrder.id));
        List<Asset_Method__e> assetMethodEvents = new List<Asset_Method__e>();
        assetMethodEvents.add(new Asset_Method__e(Record_ID__c=testAssets[0].id,Method_Name__c='recertificationApplicationUpdate'));
        List<Asset_Method__e> assetMethodEvents3 = new List<Asset_Method__e>();
        assetMethodEvents3.add(new Asset_Method__e(Record_ID__c=testAccount.id,Method_Name__c='AssetAccountUpdate'));
        List<Asset_Method__e> assetMethodEvents2 = new List<Asset_Method__e>();
        assetMethodEvents2.add(new Asset_Method__e(Record_ID__c=mldcContact.id,Method_Name__c='insertMLDCRecords'));
        Test.startTest();
         List<Database.SaveResult> resultsAssetMethod2 = EventBus.publish(assetMethodEvents2);
        List<Database.SaveResult> results = EventBus.publish(assetEvents);
        List<Database.SaveResult> resultsAssetMethod = EventBus.publish(assetMethodEvents);
        List<Database.SaveResult> resultsAssetMethod3 = EventBus.publish(assetMethodEvents3);
       
        Test.stopTest();
        System.assertEquals(true, results[0].isSuccess());
        System.assertEquals(true, resultsAssetMethod[0].isSuccess());
        System.assertEquals(true, resultsAssetMethod3[0].isSuccess());
        System.assertEquals(true, resultsAssetMethod2[0].isSuccess());

        
        
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

        update updateList;

        for(Asset a : updateList){
            a.Paid_Cert__c = true;
            a.Certification_Approved_Application__c = true;
            a.Payment_Status__c = 'Completed';
            
        }
        //update updateList;
         for(Asset a : updateList){
            a.status__c = 'Inactive';
            a.Certification_Approved_Application__c = true;
            a.Payment_Status__c = 'Completed';
        }
        //update updateList;
        Test.stopTest();
    }
    @isTest
    public static void updateCanceldate(){
      Test.startTest();
        
        Asset testAsset = [SELECT Id,Paid_Cert__c,status__c,CancelDate__c, Name FROM Asset where Name = 'test4' Limit 1];
        system.debug('testAsset.CancelDate__c::'+testAsset.CancelDate__c);
        system.debug('testAsset.status__c::'+testAsset.status__c);
        testAsset.CancelDate__c = system.today();
        update testAsset;
        
        Asset testAsset1 = [SELECT Id,Paid_Cert__c,status__c, Name,CancelDate__c FROM Asset where Name = 'test4' Limit 1];
        system.assertEquals(testAsset1.CancelDate__c,system.today());
        system.assertEquals(testAsset1.status__c,'Inactive');
        Test.stopTest();  
      
    }
    @isTest
    public static void updateCurrentExpirationDate(){
      Test.startTest();
        
        Asset testAsset = [SELECT Id,Paid_Cert__c,status__c,Enterprise_Product_HL__c, Name,Exam_Result_for_Exp_date__c FROM Asset where Name = 'test4' Limit 1];
        system.debug('testAsset.Exam_Result_for_Exp_date__c::'+testAsset.Exam_Result_for_Exp_date__c);
        system.debug('testAsset.Enterprise_Product_HL__c::'+testAsset.Enterprise_Product_HL__c);
        testAsset.Exam_Result_for_Exp_date__c = 'Pass';
        update testAsset;
        
        Asset testAsset1 = [SELECT Id,Paid_Cert__c,status__c, Name,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'test4' Limit 1];
        
        Date currentExpirationdate = Date.valueOf('2099-12-15');
       // system.assertEquals(testAsset1.CurrentExpirationDate__c,currentExpirationdate);
        Test.stopTest();  
    }
    
    @isTest
    public static void testAuthorisedAssets(){
      Test.startTest();
        
        Asset testAsset = [SELECT Id,Paid_Cert__c,status__c,Payment_Status__c,Enterprise_Product_HL__c, Name,Exam_Result_for_Exp_date__c FROM Asset where Name = 'Membership' Limit 1];
        system.debug('testAsset.Exam_Result_for_Exp_date__c::'+testAsset.Exam_Result_for_Exp_date__c);
        system.debug('testAsset.Enterprise_Product_HL__c::'+testAsset.Enterprise_Product_HL__c);
        Map<Id,Asset> oldMap = new Map<ID,Asset>();
        oldMap.put(testAsset.id, testAsset);
        
        testAsset = [SELECT Id,Paid_Cert__c,status__c, Assignee__c,Name,Payment_Status__c,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'Membership' Limit 1];
        
        
        testAsset.Exam_Result_for_Exp_date__c = 'Pass';
        testAsset.Payment_Status__c = 'Authorized';
        
        ACAMSAssetTriggerHandler.isauthorizedStatusUpdated=false;
        update testAsset;
        
        Asset testAsset1 = [SELECT Id,Paid_Cert__c,status__c, Name, Payment_Status__c,Assignee__c,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'Membership' Limit 1];
        List<Asset> newAssets = new List<Asset>();
        newAssets.add(testAsset1);
        ACAMSAssetTriggerHandler.isauthorizedStatusUpdated=false;
        
        ACAMSAssetTriggerHandler.authorizedStatus(newAssets,oldMap);
        
        Date currentExpirationdate = Date.valueOf('2099-12-15');
        system.assertEquals(null, testAsset1.CurrentExpirationDate__c);
        Test.stopTest();  
    } 
    
    @isTest
    public static void testrecertExpDate(){
      Test.startTest();
        
        Asset testAsset = [SELECT Id,Paid_Cert__c,status__c,Payment_Status__c,Enterprise_Product_HL__c, Certification_Approved_Application__c,Name,Exam_Result_for_Exp_date__c FROM Asset where Name = 'Membership' Limit 1];
        system.debug('testAsset.Exam_Result_for_Exp_date__c::'+testAsset.Exam_Result_for_Exp_date__c);
        system.debug('testAsset.Enterprise_Product_HL__c::'+testAsset.Enterprise_Product_HL__c);
        
        Map<Id,Asset> oldMap = new Map<ID,Asset>();
        oldMap.put(testAsset.id, testAsset);
        
        testAsset = [SELECT Id,Paid_Cert__c,status__c, Assignee__c,Name,Payment_Status__c,Certification_Approved_Application__c,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'Membership' Limit 1];
        
        
        
        testAsset.Exam_Result_for_Exp_date__c = 'Pass';
        testAsset.Payment_Status__c = 'Completed';
        testAsset.Paid_Cert__c = true;
        
        ACAMSAssetTriggerHandler.isauthorizedStatusUpdated=false;
        update testAsset;
        
        system.debug('test data'+testAsset.Payment_Status__c);
        system.debug('test data'+testAsset.Paid_Cert__c);
        
        
        Asset testAsset1 = [SELECT Id,Paid_Cert__c,status__c, Name, Certification_Approved_Application__c,Payment_Status__c,Assignee__c,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'Membership' Limit 1];
        List<Asset> newAssets = new List<Asset>();
        newAssets.add(testAsset1);
        ACAMSAssetTriggerHandler.isrecertExpDateUpdated=false;
        
        ACAMSAssetTriggerHandler.recertExpDate(newAssets,oldMap);
        
        Date currentExpirationdate = Date.valueOf('2099-12-15');
        system.assertEquals(null, testAsset1.CurrentExpirationDate__c);
        Test.stopTest();  
    } 
   // Added by Chinna -FSA 2544
    @isTest
    public static void testassetAccountUpdate(){
        
        Test.startTest();
          Asset testAsset1 = [SELECT Id,Paid_Cert__c,status__c, Name,Accountid,Certification_Approved_Application__c,Payment_Status__c,Assignee__c,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'Test5' Limit 1];
        List<Asset> newAssets = new List<Asset>();
        newAssets.add(testAsset1);
        ACAMSAssetTriggerHandler.AssetAccountUpdate(newAssets);
        Test.stopTest();  
    }
    
    // Added by Chinna -FSA 2544
    @isTest
    public static void testupsertLMSEnrollment(){
        Test.startTest();
        Asset testAsset = [SELECT Id,Paid_Cert__c,status__c,LMS_Access_Exp_Date__c,CancelDate__c,Name,Accountid,Certification_Approved_Application__c,Payment_Status__c,Assignee__c,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'Test6' Limit 1];
       
        Map<Id,Asset> oldMap = new Map<ID,Asset>();
        oldMap.put(testAsset.id, testAsset);
        Asset testAsset1 = [SELECT Id,Paid_Cert__c,status__c,LMS_Access_Exp_Date__c,CancelDate__c,Name,Accountid,Certification_Approved_Application__c,Payment_Status__c,Assignee__c,Enterprise_Product_HL__c,CurrentExpirationDate__c FROM Asset where Name = 'Test6' Limit 1];
        testAsset1.CancelDate__c = date.newInstance(2021,05,26);
        testAsset1.LMS_Access_Exp_Date__c = date.newInstance(2021,05,26);
        update testAsset1;
        List<Asset> newAssets = new List<Asset>();
        newAssets.add(testAsset1);
        List<BeckerLMS_Enrollment__c> lms = new List<BeckerLMS_Enrollment__c>();
        ACAMSAssetTriggerHandler.UpsertLMSEnrollment(newAssets,oldMap);
        Test.stopTest();
    }
    
    // Added by Chinna -FSA 2544
    @isTest
    public static void testcreateExamAuthorization(){
        Test.startTest();
        Asset testAsset = [SELECT Id,Application_Date__c,Paid_Cert__c,Exam_Code__c,Product_level_3__c,Product_level_2__c,Product_level_1__c,status__c,EAD_created__c,Recert__c,Retake__c,Membership_Type__c,LMS_Access_Exp_Date__c,CancelDate__c,Name,Accountid,Certification_Approved_Application__c,Payment_Status__c,Assignee__c,Enterprise_Product_HL__c FROM Asset where Name = 'ExamTest1' Limit 1];
       
        Asset testAsset2 = [SELECT Id,Application_Date__c,Paid_Cert__c,Exam_Code__c,Product_level_3__c,Product_level_2__c,Product_level_1__c,status__c,EAD_created__c,Recert__c,Retake__c,Membership_Type__c,LMS_Access_Exp_Date__c,CancelDate__c,Name,Accountid,Certification_Approved_Application__c,Payment_Status__c,Assignee__c,Enterprise_Product_HL__c FROM Asset where Name = 'ExamTest2' Limit 1];
        
        Asset testAsset3 = [SELECT Id,Application_Date__c,Paid_Cert__c,Exam_Code__c,Product_level_3__c,Product_level_2__c,Product_level_1__c,status__c,EAD_created__c,Recert__c,Retake__c,Membership_Type__c,LMS_Access_Exp_Date__c,CancelDate__c,Name,Accountid,Certification_Approved_Application__c,Payment_Status__c,Assignee__c,Enterprise_Product_HL__c FROM Asset where Name = 'ExamTest3' Limit 1];
       
         Asset testAsset4 = [SELECT Id,Application_Date__c,Paid_Cert__c,Exam_Code__c,Product_level_3__c,Product_level_2__c,Product_level_1__c,status__c,EAD_created__c,Recert__c,Retake__c,Membership_Type__c,LMS_Access_Exp_Date__c,CancelDate__c,Name,Accountid,SG_AML_REGIME_Exam_Application_Approved__c,Payment_Status__c,Assignee__c,Enterprise_Product_HL__c FROM Asset where Name = 'ExamTest4' Limit 1];
       
        // Asset testAsset5 = [SELECT Id,Application_Date__c,CC_Product__c,Exam_Schedule_Date__c,CC_Product__r.Exam_Date_to_Expire__c,Paid_Cert__c,Exam_Code__c,Product_level_3__c,Product_level_2__c,Product_level_1__c,status__c,EAD_created__c,Recert__c,Retake__c,Membership_Type__c,LMS_Access_Exp_Date__c,CancelDate__c,Name,Accountid,SG_AML_REGIME_Exam_Application_Approved__c,Certification_Approved_Application__c,Payment_Status__c,Assignee__c FROM Asset where Name = 'ExamTest5' Limit 1];
       
         List<Asset> newAssets = new List<Asset>();
         newAssets.add(testAsset);
        
        List<Asset> newAssets2 = new List<Asset>();
         newAssets2.add(testAsset2);
        
          List<Asset> newAssets3 = new List<Asset>();
         newAssets3.add(testAsset3);
        
         List<Asset> newAssets4 = new List<Asset>();
         newAssets4.add(testAsset4);
        
           //List<Asset> newAssets5 = new List<Asset>();
         //newAssets5.add(testAsset5);
        
    /*     ACAMSAssetTriggerHandler.isexamAuthorized=False;
        ACAMSAssetTriggerHandler.CreateExamAuthorization(newAssets);
        ACAMSAssetTriggerHandler.CreateExamAuthorization(newAssets2);
         ACAMSAssetTriggerHandler.CreateExamAuthorization(newAssets3);
         ACAMSAssetTriggerHandler.CreateExamAuthorization(newAssets4);
         //ACAMSAssetTriggerHandler.CreateExamAuthorization(newAssets5); */
        
        Test.stopTest();
    }
}