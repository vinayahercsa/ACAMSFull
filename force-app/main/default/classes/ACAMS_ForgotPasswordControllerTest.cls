/**
* An apex page controller that exposes the site forgot password functionality
*/
@IsTest public with sharing class ACAMS_ForgotPasswordControllerTest {
    @IsTest(SeeAllData=true) public static void testACAMS_ForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
         User usr = [Select Id,Interface_Language__c FROM user limit 1];
        PageReference pageRef = Page.ACAMS_ForgotPassword;
test.setCurrentPageReference(pageRef);
pageRef.getParameters().put('Language','en');

        ApexPages.StandardController controller = new ApexPages.StandardController(usr);

        ACAMS_ForgotPasswordController controller2 = new ACAMS_ForgotPasswordController(controller);
        controller2.username = 'test@salesforce.com';
        controller2.ClosePopup();
        controller2.ShowPopup();
        controller2.langValue=pageRef.getParameters().put('Language','en');
        controller2.refreshPage();
       
        
        System.assertEquals(controller2.forgotPassword(),null); 
    }
}