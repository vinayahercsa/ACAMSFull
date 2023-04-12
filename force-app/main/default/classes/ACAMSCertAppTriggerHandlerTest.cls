@IsTest
class ACAMSCertAppTriggerHandlerTest {

    @IsTest
    static void setCGSS() {
        CCAviTestUtil util = new CCAviTestUtil();
        Map<String, Object> testData = util.initData();
        Contact contact = (Contact) testData.get(CCAviTestUtil.PN_USER_CONTACT);

        Test.startTest();
        Certification_Application__c certApp = new Certification_Application__c();
        certApp.Contact__c = contact.Id;
        certApp.Application_Type__c = ACAMSUtil.CGSS;
        insert certApp;

        certApp = [SELECT Id, CGSS_Check__c FROM Certification_Application__c WHERE Contact__c = :contact.Id];
        System.assert(certApp.CGSS_Check__c == true);

        certApp.Application_Type__c = ACAMSUtil.CAMS;
        update certApp;
        certApp = [SELECT Id, CGSS_Check__c FROM Certification_Application__c WHERE Contact__c = :contact.Id];
        Test.stopTest();
        System.assert(certApp.CGSS_Check__c == false);
    }
}