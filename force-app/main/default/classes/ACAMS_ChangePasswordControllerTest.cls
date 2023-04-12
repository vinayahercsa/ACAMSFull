/**
 * An apex page controller that exposes the change password functionality
 */
@IsTest public with sharing class ACAMS_ChangePasswordControllerTest {
     @IsTest(SeeAllData=true) public static void testACAMS_ChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        User usr = [Select Id,Interface_Language__c FROM user limit 1];
        PageReference pageRef = Page.ACAMS_ChangePassword;
test.setCurrentPageReference(pageRef);
pageRef.getParameters().put('Language','en');

        ApexPages.StandardController controller = new ApexPages.StandardController(usr);
        ACAMS_ChangePasswordController controller2 = new ACAMS_ChangePasswordController(controller);
        controller2.oldPassword = '123456';
        controller2.newPassword = 'qwerty1'; 
        controller2.verifyNewPassword = 'qwerty1';
        controller2.langValue =pageRef.getParameters().put('Language','en');
        controller2.refreshPage();
      //  System.assertEquals(controller2.changePassword(),null);                           
    }    
}