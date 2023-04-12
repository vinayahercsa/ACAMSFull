@IsTest public with sharing class ACAMS_RegistrationPageControllerTest {
    @IsTest(SeeAllData=true) public static void testACAMS_RegistrationPageController() {
        PageReference pageRef = Page.ACAMS_RegistrationPage;
        Test.setCurrentPage(pageRef);
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('AppName','Drupal');
          ApexPages.currentPage().getParameters().put('Language','en');
         User usr = [Select Id,Interface_Language__c,countrycode,statecode FROM user limit 1];


       
        // Instantiate a new controller with all parameters in the page
        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(usr);
        ACAMS_RegistrationPageController controller2 = new ACAMS_RegistrationPageController(controller);
        controller2.areacode='+1';
        controller2.companyname='test';
        controller2.confirmpassword='Tester_123!';
        controller2.country='US';
        controller2.firstname='test';
        controller2.industry='Accounting Firm';
        controller2.lastname='testing';
        controller2.marketing=true;
        controller2.password='Tester_123!';
        controller2.workphone='5151231234';
        controller2.getareacodes();
        controller2.getIndustries();
        controller2.registerUser();
        controller2.refreshPage();
       
        
        Test.stopTest();     
        
        
    }    
}