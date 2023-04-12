@IsTest
public class ACAMSCertAppHelperTest {

    static CCAviTestUtil util = new CCAviTestUtil();

    @IsTest static void UpdateAsset_test() {
        Map<String, Object> testData = util.initData();
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);
        System.assert(a.Id != null);

        Contact c = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        System.assert(c.Id != null);

        
        ccrz__E_Product__c prod = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        prod.Level_1__c = 'Certification';
        prod.Exam_Code__c = 'test';
        update prod;

        Asset ast = new Asset();
        ast.CC_Product__c = prod.Id;
        ast.Name = 'CAMS Certification';
        ast.Status__c = 'Active';
        ast.AccountId = a.Id;
        ast.ContactId = c.Id;
        ast.Assignee__c = c.Id;
        ast.Paid_Cert__c = true;
        ast.CurrentExpirationDate__c = Date.today().addDays(20);
        insert ast;
 Test.startTest();
        List<Certification_Application__c> calist = new List<Certification_Application__c>();
        Certification_Application__c ca = new Certification_Application__c();
        ca.Contact__c = c.Id;
        ca.Asset_Pending_to_Process__c = true;
        ca.Application_Type__c = 'CAMS';

        insert ca;
       
        ca.Status__c = 'Under Review';
        update ca;
        ast.Application_Received__c = true;
        //update ast;

        ca.Status__c = 'Approved';
        update ca;
        ast.Certification_Approved_Application__c = true;
        //update ast;
        
        calist.add(ca);
        ACAMSCertAppHelper.UpdateAsset(calist, true);
        System.assertEquals(ca.Asset__c, ast.Id);
        Test.stopTest();
    }

    @IsTest
    static void updateRecertAsset_test() {
        
        Map<String, Object> testData = util.initData();
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        Contact c = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);

        ccrz__E_Product__c prod2 = new ccrz__E_Product__c();
        prod2.Name = 'CAMS Recert';
        prod2.ccrz__ProductType__c = 'Product';
        prod2.ccrz__ProductStatus__c = 'Released';
        prod2.ccrz__Storefront__c = 'acams';
        prod2.ccrz__SKU__c = 'CAMSR';
        prod2.Level_1__c = 'Certification';
        prod2.Level_2__c = 'CAMS';
        prod2.Level_3__c = 'Recertification';
        prod2.Certification_Level__c = 'Specialist';
        insert prod2;

        
        Asset ast2 = new Asset();
        ast2.CC_Product__c = prod2.Id;
        ast2.Name = 'CAMS Certification - Recertification';
        ast2.Status__c = 'Active';
        ast2.AccountId = a.Id;
        ast2.ContactId = c.Id;
        ast2.Assignee__c = c.Id;
        ast2.Paid_Cert__c = true;
        ast2.CurrentExpirationDate__c = null; // FSA-424 Not directly related to this bug but asked to only consider, in the query, Assets with null date.
        insert ast2;
        
Test.startTest();
        List<Recertification_Application__c> recalist = new List<Recertification_Application__c>();
        Recertification_Application__c rca = new Recertification_Application__c();
        rca.Contact__c = c.Id;
        rca.Asset_Pending_to_Process__c = true;
        rca.Application_Type__c = 'CAMS';

        insert rca;
     
        rca.Status__c = 'Under Review';
      //  update rca;
        ast2.Application_Received__c = true;
        update ast2;

        rca.Status__c = 'Approved';
        update rca;
        ast2.Certification_Approved_Application__c = true;
        update ast2;
        recalist.add(rca);
        ACAMSCertAppHelper.UpdateAsset(recalist, true);
        rca = [Select Id, Asset__c FROM Recertification_Application__c where id=:rca.id];
        ast2 = [Select Id, (select Id FROM Recertification_Applications__r) From Asset where id=:ast2.id];

        System.assert(ast2.Recertification_Applications__r.size() ==1);
        Test.stopTest();
        ACAMSCertAppHelper.testCoverage();
    }

    @IsTest static void UpdateLocaleOnContact_test() {
        Test.startTest();
        Map<String, Object> testData = util.initData();
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);
        System.assert(a.Id != null);

        Contact c = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        System.assert(c.Id != null);

        List<Certification_Application__c> calist = new List<Certification_Application__c>();
        Certification_Application__c ca = new Certification_Application__c();
        ca.Language_Selected__c = 'en_US';
        ca.Contact__c = c.Id;

        calist.add(ca);
        Certification_Application__c ca2 = new Certification_Application__c();
        ca2.Language_Selected__c = 'de';
        ca2.Contact__c = c.Id;
        calist.add(ca2);
        c.Locale_for_PearsonVUE__c = 'de-DE';
        update c;
        Certification_Application__c ca3 = new Certification_Application__c();
        ca3.Language_Selected__c = 'es';
        ca3.Contact__c = c.Id;
        calist.add(ca3);
        Certification_Application__c ca4 = new Certification_Application__c();
        ca4.Language_Selected__c = 'fr';
        ca4.Contact__c = c.Id;
        calist.add(ca4);
        Certification_Application__c ca5 = new Certification_Application__c();
        ca5.Language_Selected__c = 'pt';
        ca5.Contact__c = c.Id;
        calist.add(ca5);
        Certification_Application__c ca6 = new Certification_Application__c();
        ca6.Language_Selected__c = 'ja';
        ca6.Contact__c = c.Id;
        calist.add(ca6);
        Certification_Application__c ca7 = new Certification_Application__c();
        ca7.Language_Selected__c = 'zh_CN';
        ca7.Contact__c = c.Id;
        calist.add(ca7);
        Certification_Application__c ca8 = new Certification_Application__c();
        ca8.Language_Selected__c = 'zh_TW';
        ca8.Contact__c = c.Id;
        calist.add(ca8);
        ACAMSCertAppHelper.UpdateLocaleOnContact(calist);
        Test.stopTest();
    }
    //FSA-961/962
    @IsTest
    static void updateCAFCARecertAsset_test() {
        
        Map<String, Object> testData = util.initData();
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        Contact c = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        c.CAFCA_Expiration_Date__c = date.today().addDays(-10);
        update c;
        ccrz__E_Product__c prod2 = new ccrz__E_Product__c();
        prod2.Name = 'CAFCA Recert';
        prod2.ccrz__ProductType__c = 'Product';
        prod2.ccrz__ProductStatus__c = 'Released';
        prod2.ccrz__Storefront__c = 'acams';
        prod2.ccrz__SKU__c = 'CAFCAR';
        prod2.Level_1__c = 'Certification';
        prod2.Level_2__c = 'CAFCA';
        prod2.Level_3__c = 'Recertification';
        prod2.Certification_Level__c = 'Associate';
        insert prod2;

        
        Asset ast2 = new Asset();
        ast2.CC_Product__c = prod2.Id;
        ast2.Name = 'CAFCA Certification - Recertification';
        ast2.Status__c = 'Active';
        ast2.AccountId = a.Id;
        ast2.ContactId = c.Id;
        ast2.Assignee__c = c.Id;
        ast2.Paid_Cert__c = true; 
        insert ast2;
        
Test.startTest();
        
        ast2 = [Select Id, (select Id FROM Recertification_Applications__r) From Asset where id=:ast2.id];
        System.assert(ast2.Recertification_Applications__r.size() ==1);
        
        Recertification_Application__c recertapp = ast2.Recertification_Applications__r[0];
        recertapp.Status__c = 'Under Review';
        update recertapp;
        
        Asset ast = [SELECT Id,Application_Date__c,Certification_Approved_Application__c,Application_Received__c,Effective_Date__c,CurrentExpirationDate__c,
          (select Id FROM Recertification_Applications__r) FROM Asset where Id =: ast2.Id Limit 1];
        date previousExpirationDate = date.today().addDays(-10);  
        //system.assertEquals(ast.Application_Date__c,date.today());
        //system.assertEquals(ast.Application_Received__c,True);
       // system.assertEquals(ast.Certification_Approved_Application__c,True);
        //system.assertEquals(ast.Effective_Date__c,date.today());
       // system.assertEquals(ast.CurrentExpirationDate__c,previousExpirationDate.addYears(1));
        
        Test.stopTest();
    }


}