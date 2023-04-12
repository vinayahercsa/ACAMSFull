/**
 *  ACR-2255 test class for ACMSExamResultTriggerHandler
 *  Jun 11, 2020, Ray
 */
@IsTest
public class ACAMSExamResultTriggerHandlerTest {

    @IsTest
    public static void testUpdateCAMSExamResult(){
        List<Exam_Results__c> examResults = new List<Exam_Results__c>();
        Exam_Results__c e = new Exam_Results__c();
        e.Exam_Type__c = 'Singapore AML Regime Exam';
        e.Test_Date__c = Date.today() -244;
        e.Result__c = 'Failed';
        e.PearsonVUE__c = true;
        e.Original_EAD__c = true;
        examResults.add(e);
        Test.startTest();
        insert examResults;


        ccrz__E_Product__c ccProd = new ccrz__E_Product__c();
        ccProd.Name = 'CAMS Certification';
        ccProd.Level_1__c = 'Certification';
        ccProd.Level_2__c = 'CAMS';
        ccProd.ccrz__SKU__c = 'CAMS';
        insert ccProd;

        List<Asset> assetList = new List<Asset>();
        Asset a = new Asset();
        a.Name = 'CAMS Certification';
        a.CC_Product__c = ccProd.Id;
        a.ExamResult__c = e.Id;
        assetList.add(a);
        insert assetList;

        
        
        e.Exam_Type__c = 'CAMS';
        e.Result__c = 'Pass';
        update examResults;

        e.Exam_Type__c = 'CGSS';
        e.Result__c = 'Pass';
        update examResults;

        Test.stopTest();
    }

    @IsTest
    public static void testUpdateCGSSExamResult(){
        List<Exam_Results__c> examResults = new List<Exam_Results__c>();
        Exam_Results__c e = new Exam_Results__c();
        e.Exam_Type__c = 'Singapore AML Regime Exam';
        e.Test_Date__c = Date.today() -244;
        e.Result__c = 'Failed';
        e.PearsonVUE__c = true;
        e.Original_EAD__c = true;
        examResults.add(e);
        Test.startTest();
        insert examResults;


        ccrz__E_Product__c ccProd = new ccrz__E_Product__c();
        ccProd.Name = 'CGSS Certification';
        ccProd.Level_1__c = 'Certification';
        ccProd.Level_2__c = 'CGSS';
        ccProd.ccrz__SKU__c = 'CGSS';
        insert ccProd;

        List<Asset> assetList = new List<Asset>();
        Asset a = new Asset();
        a.Name = 'CGSS Certification';
        a.CC_Product__c = ccProd.Id;
        a.ExamResult__c = e.Id;
        assetList.add(a);
        insert assetList;

        e.PearsonVUE__c = false;
        e.Exam_Type__c = 'CGSS';
        e.Result__c = 'Pass';
        update examResults;

        Test.stopTest();
    }

    @IsTest
    public static void testUpdateCKYCAExamResult(){
        List<Exam_Results__c> examResults = new List<Exam_Results__c>();
        Exam_Results__c e = new Exam_Results__c();
        e.Exam_Type__c = 'Singapore AML Regime Exam';
        e.Test_Date__c = Date.today() -244;
        e.Result__c = 'Failed';
        e.PearsonVUE__c = true;
        e.Original_EAD__c = true;
        examResults.add(e);
        Test.startTest();
        insert examResults;


        ccrz__E_Product__c ccProd = new ccrz__E_Product__c();
        ccProd.Name = 'CKYCA Certification';
        ccProd.Level_1__c = 'Certification';
        ccProd.Level_2__c = 'CKYCA';
        ccProd.ccrz__SKU__c = 'CKYCA';
        insert ccProd;

        List<Asset> assetList = new List<Asset>();
        Asset a = new Asset();
        a.Name = 'CKYCA Certification';
        a.CC_Product__c = ccProd.Id;
        a.ExamResult__c = e.Id;
        assetList.add(a);
        insert assetList;


        e.Exam_Type__c = 'CGSS';
        e.Result__c = 'Pass';
        update examResults;

        Test.stopTest();
    }

}