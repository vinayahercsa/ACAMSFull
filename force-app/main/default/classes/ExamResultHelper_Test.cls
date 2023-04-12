@IsTest
public class ExamResultHelper_Test {


    static CCAviTestUtil util = new CCAviTestUtil();

       //csa fix added test code for newly created method validateDateFormat
@isTest
static void testValidateDateFormat() {
    String validDateString1 = '2023/02/17';
    String validDateString2 = '02/17/2023';
    String invalidDateString = '17-02-2023';
    String expectedDateFormat1 = 'yyyy/MM/dd';
    String expectedDateFormat2 = 'MM/dd/yyyy';
    
    // Test for valid date string in yyyy/MM/dd format
    String actualDateFormat1 = ExamResultHelper.validateDateFormat(validDateString1);
    System.assertEquals(expectedDateFormat1, actualDateFormat1, 'Invalid date format for valid date string in yyyy/MM/dd format');
    
    // Test for valid date string in MM/dd/yyyy format
    String actualDateFormat2 = ExamResultHelper.validateDateFormat(validDateString2);
    System.assertEquals(expectedDateFormat2, actualDateFormat2, 'Invalid date format for valid date string in MM/dd/yyyy format');
    
    // Test for invalid date string
    String actualDateFormat3 = ExamResultHelper.validateDateFormat(invalidDateString);
    System.assertEquals(null, actualDateFormat3, 'Invalid date format for invalid date string');
}

    @IsTest
    static void UpdateCertResult_test() {
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);

        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        Exam_Results__c exam = new Exam_Results__c();
        List<Exam_Results__c> examlist = new List<Exam_Results__c>();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'Pass';
        exam.Exam_Type__c = 'CAMS';
        exam.Test_Date__c = myDate;
        examlist.add(exam);
        insert exam;

        Exam_Results__c exam2 = new Exam_Results__c();
        List<Exam_Results__c> examlist2 = new List<Exam_Results__c>();
        exam2.Contact__c = con.Id;
        exam2.Voucher_Code__c = voucher.Id;
        exam2.Result__c = 'Pass';
        exam2.Exam_Type__c = 'Singapore AML Regime Exam';
        exam2.Test_Date__c = myDate;
        examlist2.add(exam2);
        insert exam2;

        Regional_Funding__c rg = new Regional_Funding__c();
        List<Regional_Funding__c> rglist = new List<Regional_Funding__c>();
        rg.Status__c = 'exam App Approved';
        rg.Contact__c = con.Id;
        rglist.add(rg);
        insert rg;

        ExamResultHelper.UpdateCertResult(examlist);
        List<Regional_Funding__c> regList = [
                SELECT
                        Id,
                        Passed_AML_Regime_Exam_Date__c,
                        Passed_CAMS_Exam_Date__c
                FROM
                        Regional_Funding__c
                WHERE
                        Contact__c = :con.Id
        ];
        System.assert(regList.get(0).Passed_CAMS_Exam_Date__c == myDate);
        ExamResultHelper.UpdateCertResult(examlist2);
        regList = [
                SELECT
                        Id,
                        Passed_AML_Regime_Exam_Date__c,
                        Passed_CAMS_Exam_Date__c
                FROM
                        Regional_Funding__c
                WHERE
                        Contact__c = :con.Id
        ];
        System.assert(regList.get(0).Passed_AML_Regime_Exam_Date__c == myDate);
    }

    @IsTest
    static void UpdateCertResult2_test() {
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);

        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        Exam_Results__c exam = new Exam_Results__c();
        List<Exam_Results__c> examlist = new List<Exam_Results__c>();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'Pass';
        exam.Test_Date__c = myDate;
        exam.Exam_Type__c = 'CAMS';
        examlist.add(exam);
        insert exam;

        Regional_Funding__c rg = new Regional_Funding__c();
        List<Regional_Funding__c> rglist = new List<Regional_Funding__c>();
        rg.Status__c = 'exam App Approved';
        rg.Contact__c = con.Id;
        rglist.add(rg);
        insert rg;

        List<Regional_Funding__c> regList = [
                SELECT
                        Id,
                        Passed_AML_Regime_Exam_Date__c,
                        Passed_CAMS_Exam_Date__c
                FROM
                        Regional_Funding__c
                WHERE
                        Contact__c = :con.Id
        ];

        ExamResultHelper.UpdateCertResult(examlist);
        System.assert(regList.get(0).Passed_AML_Regime_Exam_Date__c == null && regList.get(0).Passed_CAMS_Exam_Date__c == null);
    }

    @IsTest
    static void UpsertExamResultOnAsset_test() {
        
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        System.assert(a.Id != null);
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        ccrz__E_Product__c prod = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        prod.Exam_Code__c = 'test';
        prod.ProductCategory__c = 'Certifications';
        update prod;

        Asset ast = new Asset();
        ast.Name = 'Certifications';
        ast.Status__c = 'Active';
        ast.AccountId = a.Id;
        ast.ContactId = con.Id;
        ast.Assignee__c = con.Id;
        ast.Paid_Cert__c = true;
        ast.EAD_created__c = false;
        ast.CC_Product__c = prod.Id;
        insert ast;

        List<Exam_Results__c> examlist = new List<Exam_Results__c>();
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'pass';
        exam.Exam_Type__c = 'CAMS';
        exam.Test_Date__c = myDate;
        examlist.add(exam);
        ast.ExamResult__c = exam.id;
        //update ast;
test.startTest();
        ExamResultHelper.UpsertExamResultOnAsset(examlist);

        Asset asset1 = [
                SELECT
                        Id, ExamResult__c
                FROM
                        Asset
                WHERE
                        Name = 'Certifications'
                Limit
                        1
        ];
        test.stopTest();
        // System.assert(asset1.ExamResult__c != null);
    }

    @IsTest
    static void UpsertExamResultOnAsset2_test() {
        
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);
         
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        System.assert(a.Id != null);
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;

        ccrz__E_Product__c prod = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        prod.ProductCategory__c = 'Advanced Certifications';
        prod.Exam_Code__c = 'test';
        prod.ccrz__SKU__c = 'ADV1';
        update prod;
        test.startTest();
        Asset ast = new Asset();
        ast.Name = 'Advanced Certification';
        ast.Status__c = 'Active';
        ast.AccountId = a.Id;
        ast.ContactId = con.Id;
        ast.Assignee__c = con.Id;
        ast.Paid_Cert__c = true;
        ast.EAD_created__c = false;
        ast.CC_Product__c = prod.Id;
        // FSA-180a
        //insert ast;

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        List<Exam_Results__c> examlist = new List<Exam_Results__c>();
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'pass';
        exam.Exam_Type__c = 'CAMS-Audit';
        exam.Test_Date__c = myDate;
        examlist.add(exam);
        insert exam;
       

        List<Exam_Results__c> examlist2 = new List<Exam_Results__c>();
        Exam_Results__c exam2 = new Exam_Results__c();
        exam2.Contact__c = con.Id;
        exam2.Voucher_Code__c = voucher.Id;
        exam2.Result__c = 'pass';
        exam2.Exam_Type__c = 'CAMS-FCI';
        exam2.Test_Date__c = myDate;
        examlist2.add(exam2);
        insert exam2;
        
        ExamResultHelper.UpsertExamResultOnAsset(examlist);
        ExamResultHelper.UpsertExamResultOnAsset(examlist2);

         test.stopTest();
        // System.assert(asset1.ExamResult__c != null);
    }

    @IsTest
    static void UpsertExamResultOnAsset3_test() {
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);
     test.startTest();
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        System.assert(a.Id != null);
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;

        ccrz__E_Product__c prod = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        prod.ProductCategory__c = 'Advanced Certifications';
        prod.Exam_Code__c = 'test';
        prod.ccrz__SKU__c = 'ADV2';
        update prod;

        Asset ast = new Asset();
        ast.Name = 'Advanced Certification';
        ast.Status__c = 'Active';
        ast.AccountId = a.Id;
        ast.ContactId = con.Id;
        ast.Assignee__c = con.Id;
        ast.Paid_Cert__c = true;
        ast.EAD_created__c = false;
        ast.CC_Product__c = prod.Id;
        // FSA-180a
        //insert ast;

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        List<Exam_Results__c> examlist = new List<Exam_Results__c>();
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'pass';
        exam.Exam_Type__c = 'CAMS-FCI';
        exam.Test_Date__c = myDate;
        examlist.add(exam);
        insert exam;

        ExamResultHelper.UpsertExamResultOnAsset(examlist);
        // FSA-180a
        /*
        Asset asset1 = [
                SELECT
                        Id, ExamResult__c
                FROM
                        Asset
                WHERE
                        Name = 'Advanced Certification'
                LIMIT   
                        1
        ];
        */
         test.stopTest();
        // System.assert(asset1.ExamResult__c != null);
    }

    @IsTest
    static void UpsertExamResultOnAsset4_test() {
       
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);
 
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        System.assert(a.Id != null);
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;

        ccrz__E_Product__c prod = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        prod.ProductCategory__c = 'Certifications';
        prod.ccrz__SKU__c = 'SG-AML-Regime';
        prod.Exam_Code__c = 'test';
        update prod;

    

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        List<Exam_Results__c> examlist = new List<Exam_Results__c>();
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'pass';
        exam.Exam_Type__c = 'Singapore AML Regime Exam';
        exam.Test_Date__c = myDate;
        examlist.add(exam);
        insert exam;
         test.startTest();
        ExamResultHelper.UpsertExamResultOnAsset(examlist);
   
         test.stopTest();
        // System.assert(asset1.ExamResult__c != null);
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    @IsTest
    static void SendContactInfo_test() {
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);

        Set<Id> scnt = new Set<Id>();
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);
        a.FirstName = 'test';
        a.LastName = 'test';
        a.BillingCountry = 'Canada';        
        a.Phone = '+3221232321';

        System.assert(a.Id != null);
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        con.FirstName = 'test';
        con.LastName = 'test';
        con.Phone = '3221232321';
        // con.MailingCountry = 'Canada';
        // con.MailingStreet = 'testtt ttttt ttttttt tttttes ttttttttt tttt ttttttt ttttttttestest test tes test tes test test';
        // con.MailingState = 'Florida';
        con.Account_Name_Chinese__c = 'test';
        con.Account_Last_Name_Chinese__c = 'test';
        con.Address_Chinese__c = 'testtt ttttt ttttttt tttttes ttttttttt tttt ttttttt ttttttttestest test tes test tes test test';
        con.Asia_City__c = 'test';
        update con;

        scnt.add(a.Id);
        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        List<Exam_Results__c> examlist = new List<Exam_Results__c>();
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'pass';
        exam.Exam_Type__c = 'CAMS';
        exam.Test_Date__c = myDate;
        examlist.add(exam);
        insert exam;

        ExamResultHelper.SendContactInfo(scnt);
    }
    
    @IsTest
    static void TestMethodSendContactInfo2() {
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);

        Set<Id> scnt = new Set<Id>();
        //FSA - 55a
        List<Account> acList = new List<Account>{
                new Account(FirstName='initialFirstName', Phone='+13221232321',LastName='LastName', Description='sometest',BillingCountry='US',BillingCity='Chicago',BillingPostalCode='60616',BillingStreet = '1001 Main Street', Website='www.test.com',Work_Email__pc=String.valueOf(String.valueOf(Date.today()))+'@test.com', ccrz__CompanyName__pc = 'Abcdef')
                    };
        insert acList;
        
        for(Account a : acList){
                scnt.add(a.Id);
        }

        ExamResultHelper.SendContactInfo(scnt);
    }
    
    
    @IsTest
    static void SendEADInfo_test() {
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);

        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        System.assert(a.Id != null);
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        List<Exam_Results__c> examlist = new List<Exam_Results__c>();
        Set<Id> idlist = new Set<Id>();
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'pass';
        exam.Exam_Type__c = 'CAMS';
        exam.Test_Date__c = myDate;
        exam.examSeriesCode__c = 'CAMS6_ENU';
        exam.eligibilityApptDateFirst__c = System.today();
        exam.eligibilityApptDateLast__c = System.today() + 180;
        examlist.add(exam);
        insert exam;

        idlist.add(exam.Id);

        ExamResultHelper.SendEADInfo(idlist, 'original', 'Add');
        ExamResultHelper.SendEADInfo(idlist, 'retake', 'Add');
        ExamResultHelper.SendEADInfo(idlist, 'extension', 'update');
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest
    static void updateSGAMLAsset_Test() {
        Test.startTest();
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);

        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        System.assert(a.Id != null);
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;

        ccrz__E_Product__c prod = new ccrz__E_Product__c();
        prod.Name = 'name';
        prod.ccrz__SKU__c = 'sku123';
        prod.ccrz__ProductType__c = 'Product';
        prod.ccrz__ProductStatus__c = 'Released';
        prod.ccrz__Storefront__c = 'storefront';
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        prod.Level_3__c = 'Recertification';
        prod.Certification_Level__c='Specialist';
        insert prod;

        List<Asset> asList = new List<Asset>();
        Set<Id> idlist = new Set<Id>();
        Asset ast = new Asset();
        ast.Name = 'testing';
        ast.accountId = a.Id;
        ast.CC_Product__c = prod.Id;
        
        insert ast;

        idlist.add(ast.Id);

        ExamResultHelper.updateSGAMLAsset(idlist);  
        Test.stopTest();      

    }

    
    @IsTest
    static void splitStreetAddress_Test() {

        ExamResultHelper.splitStreetAddress('first');
        ExamResultHelper.splitStreetAddress('first, second');
        ExamResultHelper.splitStreetAddress('first, second, third');
        ExamResultHelper.splitStreetAddress('first, second, third, fourth');
        ExamResultHelper.splitStreetAddress('first, second, third, fourth, fifth');
        ExamResultHelper.splitStreetAddress('first, second, third, fourth, fifth, sixth');
        
        ExamResultHelper.splitStreetAddress('first ');
        ExamResultHelper.splitStreetAddress('first,  second');
        ExamResultHelper.splitStreetAddress('first,   second');        
        ExamResultHelper.splitStreetAddress('first,    second');                
        ExamResultHelper.splitStreetAddress('first,   second,   third');
        ExamResultHelper.splitStreetAddress('first,    second,    third,    fourth');
        ExamResultHelper.splitStreetAddress('first,     second,     third,     fourth,     fifth');
        ExamResultHelper.splitStreetAddress('first,      second,      third,      fourth,      fifth,      sixth');

        ExamResultHelper.splitStreetAddress('first');
        ExamResultHelper.splitStreetAddress('first,second');
        ExamResultHelper.splitStreetAddress('first,second,third');
        ExamResultHelper.splitStreetAddress('first,second,third,fourth');
        ExamResultHelper.splitStreetAddress('first,second,third,fourth,fifth');
        ExamResultHelper.splitStreetAddress('first,second,third,fourth,fifth,sixth');
        
        ExamResultHelper.splitStreetAddress('first,');
        ExamResultHelper.splitStreetAddress('first,,second');
        ExamResultHelper.splitStreetAddress('first,,,second,,,third');
        ExamResultHelper.splitStreetAddress('first,,,,second,,,,third,,,,fourth');
        ExamResultHelper.splitStreetAddress('first,,,,,second,,,,,third,,,,,fourth,,,,,fifth');
        ExamResultHelper.splitStreetAddress('first,,,,,,second,,,,,,third,,,,,,fourth,,,,,,fifth,,,,,,sixth');

        ExamResultHelper.splitStreetAddress('first');
        ExamResultHelper.splitStreetAddress('first second');
        ExamResultHelper.splitStreetAddress('first second third');
        ExamResultHelper.splitStreetAddress('first second third fourth');
        ExamResultHelper.splitStreetAddress('first second third fourth fifth');
        ExamResultHelper.splitStreetAddress('first second third fourth fifth sixth');

    }
    
    
    
    
    @IsTest
    static void updateContactVUE_Test(){

        List<Account> acList = new List<Account>{
            new Account(FirstName='initialFirstName', LastName='LastName', Phone='+13221232321', Work_Email__pc=String.valueOf(String.valueOf(Date.today()))+'@test.com')
        };
        insert acList;       

        ExamResultHelper.updateContactVUE(String.valueOf(acList[0].Id), 12345678);        // String ClientCandidateID, Integer CandidateID

    }

    

    @IsTest
    static void updateEADVUE_Test(){

        List<Account> acList = new List<Account>{
            new Account(FirstName='initialFirstName', LastName='LastName', Phone='+13221232321',Work_Email__pc=String.valueOf(String.valueOf(Date.today()))+'@test.com')
        };
        insert acList;
        
        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);

        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        System.assert(a.Id != null);
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'pass';
        exam.Exam_Type__c = 'CAMS';
        exam.Test_Date__c = myDate;
        exam.examSeriesCode__c = 'CAMS6_ENU';
        exam.eligibilityApptDateFirst__c = System.today();
        exam.eligibilityApptDateLast__c = System.today() + 180;
        insert exam;
        

        ExamResultHelper.updateEADVUE(123456,String.valueOf(exam.Id), '12/16/20');        // Integer authorizationID, String clientAuthorizationID, String responsedate

    }

    

    @IsTest
    static void updateIntStatusOnAsset_Test(){

        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);
        Account a = (Account) testData.get(CCAviTestUtil.PN_USER_ACCOUNT);

        System.assert(a.Id != null);
        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);
        con.AccountId = a.Id;
        update con;

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        ccrz__E_Product__c prod = (ccrz__E_Product__c) testData.get(CCAviTestUtil.PN_PRODUCT);
        prod.Level_1__c = 'Certification';
        prod.Level_2__c = 'CAMS';
        prod.Exam_Code__c = 'test';
        prod.ProductCategory__c = 'Certifications';
        update prod;
        
        Asset ast = new Asset();
        ast.Name = 'Certifications';
        ast.Status__c = 'Active';
        ast.AccountId = a.Id;
        ast.ContactId = con.Id;
        ast.Assignee__c = con.Id;
        ast.Paid_Cert__c = true;
        ast.EAD_created__c = false;
        ast.CC_Product__c = prod.Id;
        insert ast;
        test.startTest();
        ExamResultHelper.updateIntStatusOnAsset(a.id, 'contact', 'test message', 'Accepted');        // Id assetId, String type, String message, String status
        ExamResultHelper.updateIntStatusOnAsset(a.id, 'contact', 'test message', 'Denied'); 
                test.stopTest();
/*
        ExamResultHelper.updateIntStatusOnAsset(a.id, 'original', 'test message', 'Accepted');
        ExamResultHelper.updateIntStatusOnAsset(a.id, 'original', 'test message', 'Denied');

        ExamResultHelper.updateIntStatusOnAsset(a.id, 'extension', 'test message', 'Accepted');
        ExamResultHelper.updateIntStatusOnAsset(a.id, 'extension', 'test message', 'Denied');

        ExamResultHelper.updateIntStatusOnAsset(a.id, 'retake', 'test message', 'Accepted');
        ExamResultHelper.updateIntStatusOnAsset(a.id, 'retake', 'test message', 'Denied');   
*/

       
    }

    
    
    
    
        
    
    
    
    @IsTest
    static void UpdatePVDates_Test(){

        Map<String, Object> testData = util.initData();
        Date myDate = Date.newInstance(1990, 11, 21);

        Contact con = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);

        Voucher__c voucher = new Voucher__c();
        voucher.Contact__c = con.Id;
        voucher.Product_Code__c = 'CAMS English';
        insert voucher;

        Exam_Results__c exam = new Exam_Results__c();
        List<Exam_Results__c> examlist = new List<Exam_Results__c>();
        exam.Contact__c = con.Id;
        exam.Voucher_Code__c = voucher.Id;
        exam.Result__c = 'Pass';
        exam.Exam_Type__c = 'CAMS';
        exam.Test_Date__c = myDate;
        exam.Exam_Date__c = String.valueOf(Date.today().addDays(-14))+'111';
        String str = String.valueOf(Date.today().addDays(-14))+'11';
        System.debug('----dd-->'+exam.Exam_Date__c+'--size--'+str.length());        
        examlist.add(exam);
        insert exam;

        Exam_Results__c exam2 = new Exam_Results__c();
        List<Exam_Results__c> examlist2 = new List<Exam_Results__c>();
        exam2.Contact__c = con.Id;
        exam2.Voucher_Code__c = voucher.Id;
        exam2.Result__c = 'Pass';
        exam2.Exam_Type__c = 'Singapore AML Regime Exam';
        exam2.Test_Date__c = myDate;
        exam.Exam_Date__c = '1234567890';        
        examlist2.add(exam2);
        insert exam2;

//        ExamResultHelper.UpdatePVDates(examlist);
        ExamResultHelper.UpdatePVDates(examlist2);
        
    }
    
     @IsTest
    static void UpdateCertResultToPass_Test(){
       
       Date dt = system.today();
         Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con; 
        
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CAFCA';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
        
       }
    
     @IsTest
    static void UpdateCertResultToPass_Test1(){
       
       Date dt = system.today();
         Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con; 
        
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CKYCA';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
       // ACAMSRecertCycleTriggerHandlerTest.ACAMSRecertCycleTriggerHandler();
    }
    
    @IsTest
    static void UpdateCertResultToPass_Test2(){
       
       Date dt = system.today();
         Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con; 
        
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CTMA';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
    }
    
     @IsTest
    static void UpdateCertResultToPass_Test3(){
       
       Date dt = system.today();
         Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con; 
        
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CAMS';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
    }
    
     @IsTest
    static void UpdateCertResultToPass_Test4(){
       
       Date dt = system.today();
         Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con; 
        
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CAMS-Audit';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
    }
    
     @IsTest
    static void UpdateCertResultToPass_Test5(){
       
       Date dt = system.today();
         Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con; 
        
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CAMS-FCI';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
    }
    
     @IsTest
    static void UpdateCertResultToPass_Test6(){
       
       Date dt = system.today();
         Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con; 
        
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CAMSRM';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
    }
    
     @IsTest
    static void UpdateCertResultToPass_Test7(){
       
       Date dt = system.today();
         Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con; 
        
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CGSS';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
    }
    
     @IsTest
    static void UpdateCertResultToPass_Test8(){
       
       Date dt = system.today();
         Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Last';
        con.Email = 'First.Last@test.com';
        insert con; 
        
        Exam_Results__c exam = new Exam_Results__c();
        exam.Contact__c = con.Id;
        exam.Exam_Type__c = 'CCAS';
        exam.Test_Date__c = dt;
        insert exam;
        
        exam.Test_Date__c = dt.addDays(1);
        exam.Result__c = 'pass';
        update exam;
    }
    
    
    








    
    
}