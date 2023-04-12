@IsTest public with sharing class ACAMSSSOControllerTest {
    @IsTest(SeeAllData=true) public static void testACAMSSSOController() {
        PageReference pageRef = Page.ACAMSSiteLogin;
        Test.setCurrentPage(pageRef);
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('AppName','Drupal');
        ApexPages.currentPage().getParameters().put('Language','en');
         User usr = [Select Id,Interface_Language__c FROM user limit 1];


        ApexPages.StandardController controller = new ApexPages.StandardController(usr);
        // Instantiate a new controller with all parameters in the page
        ACAMSSSOController controller2 = new ACAMSSSOController(controller);
        controller2.url= PageRef.getUrl();
        controller2.decodedUrl= EncodingUtil.urlDecode(controller2.url, 'UTF-8'); 
        controller2.username='test@gmail.com';
        controller2.password='tester_123!';
        controller2.getDrupalInfo();
        controller2.getDrupalRegisterUrl();
        controller2.getDrupalUrl();
        controller2.getRelayUrl();
        controller2.redirect();
        controller2.refreshPage();
        controller2.login();
        
        
        
    }    
}