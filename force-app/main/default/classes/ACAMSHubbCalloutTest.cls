@IsTest
public class ACAMSHubbCalloutTest {
    public ACAMSHubbCalloutTest() {

    }

    @IsTest
    public static void testSendRequest(){
        
        List<Account> acList = new List<Account>{
            new Account(FirstName='initialFirstName', LastName='LastName',Job_Title__pc='testTitle',PersonTitle='testTitle',Membership_Type__pc='MEMBER',Designation__pc='Designation',Industry='Industy',Company_Name__c='testCmpName', Description='sometest',PersonEmail='test@test12.com', Website='www.test.com',Work_Email__pc=String.valueOf(String.valueOf(Date.today()))+'@test.com')
                };
        insert acList;
        ccrz__E_Product__c ccProd = new ccrz__E_Product__c();
        ccProd.Name = 'CAMS Certification';
        ccProd.Level_1__c = 'Certification';
        ccProd.Level_2__c = 'CAMS';
        ccProd.Level_3__c = 'New';
        ccProd.ccrz__SKU__c = 'CAMS';
        ccProd.Event_Code__c = '5226';
        insert ccProd;

        ACAMSHubbCallout.HubbUser hubUser = new ACAMSHubbCallout.HubbUser();
        hubUser.firstName = 'FirstName';
        hubUser.attendeeId = 'testId';
        hubUser.lastName = 'testA';
        hubUser.personalTitle = 'testId';
        hubUser.personalEmail = 'testEmail';
        hubUser.roles = 'string';
        hubUser.profileMetadata = 'string';
        hubUser.Biography = 'string';
        hubUser.company = 'testCompany';
        hubUser.Id = 123;
        hubUser.IsOptedOut = true;
        hubUser.CalendarFeedId = 'string';
        hubUser.MembershipType ='testMem';
       
        hubuser.Designation = 'testAA';
        hubuser.YearsOfExperience = 'test';


        Asset a = new Asset();
        a.AccountId = acList.get(0).Id;
        a.Name = 'CAMS Certification';
        a.CC_Product__c = ccProd.Id;
        insert a;



        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ACAMSHubbCalloutMockTest());
        Set<Id> acctIds = new Set<Id>();
        List<Account> acctList = [SELECT Id, FirstName, LastName,Company_Name__c, Job_Title__pc, PersonEmail,PersonTitle, Membership_Type__pc, Designation__pc, Industry FROM Account LIMIT 2];
        acctIds.add(acctList[0].Id);
        ACAMSHubbCallout callInstance = new ACAMSHubbCallout();
        ACAMSHubbCallout.hubbUserId = '123456';
        ACAMSHubbCallout.HubbUser user = new ACAMSHubbCallout.HubbUser();
        callInstance.RESTInsertAUser();
        ACAMSHubbCallout.RESTInsertRecords(acctIds,a.Id);
        ACAMSHubbCallout.RESTInsertUserCustomFields(12345,hubuser,a);
        ACAMSHubbCallout.RESTGetRecords();
        ACAMSHubbCallout.getPropertyValues();
        ACAMSHubbCallout.RESTDeleteRecords();
        // FSA-142
        a.Hubb_Status__c = 'Cancelled';
        update a;
        Set<Id> delHubbUserAssetId = new Set<Id>();
        delHubbUserAssetId.add(a.Id);
        ACAMSHubbCallout.RESTFutureDeleteRecords(delHubbUserAssetId);
        Test.stopTest();
    }
}