//FSA-557
@isTest
public class ACAMSMembershipAndCertStatusTest {
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
        camsCert.ProductCategory__c = 'Memberships';
        camsCert.ccrz__SKU__c= '1735';
        camsCert.Days_to_Expire__c = 205;
        camsCert.LMS_Course__c = lmsc.Id;

        ccrz__E_Product__c hlNull = new ccrz__E_Product__c();
        hlNull.Level_1__c = 'Certification';
        hlNull.Level_2__c = 'Advanced CAMS - Audit';
        hlNull.Level_3__c = 'Recertification';
        hlNull.ProductCategory__c = 'Memberships';
        hlNull.ccrz__SKU__c= '1734';
        hlNull.Days_to_Expire__c = 205;
        hlNull.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c thirdpd = new ccrz__E_Product__c();
        thirdpd.Level_1__c = 'Certification';
        thirdpd.Level_2__c = 'CGSS';
        thirdpd.Level_3__c = 'Recertification';
        thirdpd.ProductCategory__c = 'Memberships';
        thirdpd.ccrz__SKU__c= 'SG-AML-Regime';
        thirdpd.Days_to_Expire__c = 205;
        thirdpd.LMS_Course__c = lmsc.Id;

        ccrz__E_Product__c ckycaPd = new ccrz__E_Product__c();
        ckycaPd.Level_1__c = 'Certification';
        ckycaPd.Level_2__c = 'CKYCA';
        ckycaPd.Level_3__c = 'Recertification';
        ckycaPd.ProductCategory__c = 'Memberships';
        ckycaPd.ccrz__SKU__c= '4010';
        ckycaPd.Days_to_Expire__c = 205;
        ckycaPd.LMS_Course__c = lmsc.Id;

        ccrz__E_Product__c ctmaPd = new ccrz__E_Product__c();
        ctmaPd.Level_1__c = 'Certification';
        ctmaPd.Level_2__c = 'CTMA';
        ctmaPd.Level_3__c = 'Recertification';
        ctmaPd.ProductCategory__c = 'Memberships';
        ctmaPd.ccrz__SKU__c= '4252';
        ctmaPd.Days_to_Expire__c = 205;
        ctmaPd.LMS_Course__c = lmsc.Id;

        ccrz__E_Product__c cafcaPd = new ccrz__E_Product__c();
        cafcaPd.Level_1__c = 'Certification';
        cafcaPd.Level_2__c = 'CAFCA';
        cafcaPd.Level_3__c = 'Recertification';
        cafcaPd.ProductCategory__c = 'Memberships';
        cafcaPd.ccrz__SKU__c= '4052';
        cafcaPd.Days_to_Expire__c = 205;
        cafcaPd.LMS_Course__c = lmsc.Id;
        
        //FSA-557
        ccrz__E_Product__c memPd = new ccrz__E_Product__c();
        memPd.Level_1__c = 'Membership';
        //memPd.Level_2__c = 'Enterprise Bundle';
        //memPd.Level_3__c = 'Recertification';
        memPd.ProductCategory__c = 'Memberships';
        memPd.ccrz__SKU__c= '4000';
        memPd.Days_to_Expire__c = 205;
        memPd.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c memPd2 = new ccrz__E_Product__c();
        memPd2.Level_1__c = 'Enterprise Bundle';
        //memPd2.Level_2__c = 'Enterprise Bundle';
        //memPd2.Level_3__c = 'Recertification';
        memPd2.ProductCategory__c = 'Memberships';
        memPd2.ccrz__SKU__c= '4001';
        memPd2.Days_to_Expire__c = 205;
        memPd2.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c pubPd = new ccrz__E_Product__c();
        pubPd.Level_1__c = 'Publications';
        pubPd.Level_2__c = 'Moneylaundering.com';
        //pubPd.Level_3__c = 'Recertification';
        pubPd.ProductCategory__c = 'Memberships';
        pubPd.ccrz__SKU__c= '4002';
        pubPd.Days_to_Expire__c = 205;
        pubPd.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c ACAMSTodayPd = new ccrz__E_Product__c();
        ACAMSTodayPd.Level_1__c = 'Publications';
        ACAMSTodayPd.Level_2__c = 'ACAMS Today';
        //pubPd.Level_3__c = 'Recertification';
        ACAMSTodayPd.ProductCategory__c = 'Memberships';
        ACAMSTodayPd.ccrz__SKU__c= '4003';
        ACAMSTodayPd.Days_to_Expire__c = 205;
        ACAMSTodayPd.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c FCIPd = new ccrz__E_Product__c();
        FCIPd.Level_1__c = 'Certification';
        FCIPd.Level_2__c = 'Advanced CAMS - FCI';
        FCIPd.Level_3__c = 'New';
        FCIPd.ProductCategory__c = 'Memberships';
        FCIPd.ccrz__SKU__c= '4004';
        FCIPd.Days_to_Expire__c = 205;
        FCIPd.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c CRiskPd = new ccrz__E_Product__c();
        CRiskPd.Level_1__c = 'Certification';
        CRiskPd.Level_2__c = 'Advanced CAMS - Risk Management';
        CRiskPd.Level_3__c = 'New';
        CRiskPd.ProductCategory__c = 'Memberships';
        CRiskPd.ccrz__SKU__c= '4005';
        CRiskPd.Days_to_Expire__c = 205;
        CRiskPd.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c IndiaRegPd = new ccrz__E_Product__c();
        IndiaRegPd.Level_1__c = 'Certification';
        IndiaRegPd.Level_2__c = 'India Regime';
        IndiaRegPd.Level_3__c = 'New';
        IndiaRegPd.ProductCategory__c = 'Memberships';
        IndiaRegPd.ccrz__SKU__c= '4006';
        IndiaRegPd.Days_to_Expire__c = 205;
        IndiaRegPd.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c SNRegPd = new ccrz__E_Product__c();
        SNRegPd.Level_1__c = 'Certification';
        SNRegPd.Level_2__c = 'Singapore Regime';
        SNRegPd.Level_3__c = 'New';
        SNRegPd.ProductCategory__c = 'Memberships';
        SNRegPd.ccrz__SKU__c= '4007';
        SNRegPd.Days_to_Expire__c = 205;
        SNRegPd.LMS_Course__c = lmsc.Id;
        //FSA-2576
        ccrz__E_Product__c hkRegPd = new ccrz__E_Product__c();
        hkRegPd.Level_1__c = 'Certification';
        hkRegPd.Level_2__c = 'Regime Exam';
        hkRegPd.Level_3__c = 'New';
        hkRegPd.ProductCategory__c = 'Memberships';
        hkRegPd.ccrz__SKU__c= '4018';
        hkRegPd.Days_to_Expire__c = 205;
        hkRegPd.LMS_Course__c = lmsc.Id;
        
        ccrz__E_Product__c chMem = new ccrz__E_Product__c();
        chMem.Level_1__c = 'Chapter';
        chMem.Level_2__c = 'Membership';
        //chMem.Level_3__c = 'New';
        chMem.ProductCategory__c = 'Memberships';
        chMem.ccrz__SKU__c= '4008';
        chMem.Days_to_Expire__c = 205;
        chMem.LMS_Course__c = lmsc.Id;
        //FSA-557
        
        //FSA-961/962
        ccrz__E_Product__c cafcaPdNew = new ccrz__E_Product__c();
        cafcaPdNew.Level_1__c = 'Certification';
        cafcaPdNew.Level_2__c = 'CAFCA';
        cafcaPdNew.Level_3__c = 'New';
        cafcaPdNew.ProductCategory__c = 'Memberships';
        cafcaPdNew.ccrz__SKU__c= '4009';
        cafcaPdNew.Days_to_Expire__c = 205;
        cafcaPdNew.LMS_Course__c = lmsc.Id;
        //FSA-961/962
        
        products.add(compd);
        products.add(secpd);
        products.add(hlNull);
        products.add(thirdpd);
        products.add(ckycaPd);
        products.add(ctmaPd);
        products.add(cafcaPd);
        products.add(camsCert);
        
        //FSA-557
        products.add(memPd);
        products.add(memPd2);
        products.add(pubPd);
        products.add(ACAMSTodayPd);
        products.add(FCIPd);
        products.add(CRiskPd);
        products.add(IndiaRegPd);
        products.add(SNRegPd);
        products.add(hkRegPd);
        products.add(chMem);
        //FSA-557
        
        products.add(cafcaPdNew); //FSA-961/962
        
        try{
        insert products;
        } catch(Exception e) {
        	system.debug('line no::'+e.getLineNumber()+'::msg::'+e.getMessage());
        }

        List<Asset> testAssets = new List<Asset>{
                new Asset(
                        Name = 'Membership',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
				//FSA-961/962                
                new Asset(
                        Name = 'CAFCA Certification - New',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[17].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
				//FSA-961/962
                new Asset(
                        Name = 'Advanced CAMS - FCI Certification - New',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
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
                        ContactId = testContact.Id,
                        AccountId = testAccount.Id,
                        Paid_Cert__c = true
                ),
                new Asset(
                        Name = 'CKYCA Certification - Recertification',
                        ContactId = testContact.Id,
                        AccountId = testAccount.Id
                ),
                new Asset(
                        Name = 'CTMA Certification - Recertification',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id
                ),
                new Asset(
                        Name = 'Advanced CAMS - Audit Certification - Recertification',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id
                ),
                new Asset(
                        Name = 'Advanced CAMS - FCI Certification - Recertification',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id
                ),
                new Asset(
                        Name = 'Advanced CAMS - Risk Management Certification - Recertification',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id
                ),
                //FSA-557
                new Asset(
                        Name = 'Membership',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[8].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'Enterprise Bundle',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[9].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'Moneylaundering.com',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[10].Id,
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
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[11].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'Advanced CAMS - Audit - New',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
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
                        Name = 'Advanced CAMS - FCI - Recert',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[12].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                 new Asset(
                        Name = 'Advanced CAMS - Risk Management - ReCert',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[13].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                 new Asset(
                        Name = 'India Regime - Recert',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[14].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                 new Asset(
                        Name = 'Singapore Regime - Recert',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[15].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                   //FSA-2576
                    new Asset(
                        Name = 'Regime Exam',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[16].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'Chapter - Membership',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[17].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                ),
                new Asset(
                        Name = 'Cert - CAMS',
                        AccountId = testAccount.Id,
                        ContactId = testContact.Id,
                        Assignee__c = testContact.Id,
                        status__c='Active',
                        CC_Product__c = products[7].Id,
                        CC_Order__c = testOrder.Id,
                        Paid_Cert__c = true,
                        Payment_Status__c = 'Pending',
                        Certification_Approved_Application__c = false,
                        CC_Order_Item__c = testOrderItem.Id,
                        Effective_Date__c = Date.today().addDays(5),
                        CurrentExpirationDate__c = Date.today().addDays(5)
                )
                //FSA-557
                
        };
        try {
        upsert testAssets;
        } catch(Exception e) {
        	system.debug('line no::'+e.getLineNumber()+'::msg::'+e.getMessage());
        }

        
        List<BeckerLMS_Enrollment__c> lmsEnrollment = new List<BeckerLMS_Enrollment__c>{
            new BeckerLMS_Enrollment__c(Account__c = testAccount.Id,Purchase_Date__c = Date.today().addDays(-14), LMS_Course__c=lmsc.Id, Asset__c=testAssets[0].Id)
        };
        insert lmsEnrollment;
    }
    
     @isTest
    public static void testBatchrun() {
	    Test.startTest();
	    List<Asset> assetList = [SELECT Id, AccountId, ContactId, CC_Product__c, Status__c, Assignee__c, CurrentExpirationDate__c
	                FROM Asset
	                WHERE CurrentExpirationDate__c >= TODAY];
	    ACAMSMemAndCertStatusRunBatch AMCS = new ACAMSMemAndCertStatusRunBatch();
	    Database.executeBatch(AMCS);
	    AMCS.execute(null,assetList);
	    
	    Set<Id> contactIds = new Set<Id>();
	    for(Asset a : assetList) {
	    	contactIds.add(a.Assignee__c);
	    }
	    
	    List<contact> con = [select Id, Chapter_Member__c, ACAMS_Member__c, CAMS__c, CAMS_Audit__c, CAMS_FCI__c from contact where Id In: contactIds LIMIT 1 ];
         /*   if(con != null && con.size() > 0){    
                system.assertEquals(con[0].Chapter_Member__c, false);
                system.assertEquals(con[0].ACAMS_Member__c, false);
                system.assertEquals(con[0].CAMS__c, false);
                system.assertEquals(con[0].CAMS_Audit__c, false);
                system.assertEquals(con[0].CAMS_FCI__c, false);
            } */
    	    Test.stopTest();
    } 
}