@isTest
private class TestLMSEnrollmentService {
    static testMethod void test_Enrollment() {
        Account a = UtilCreateTestData.CreateAccount();
        insert a;
        System.assert(a.Id != NULL);

        Contact c = UtilCreateTestData.CreateContact('Test FirstName', 'Test LastName', a.Id);
        insert c;
        System.assert(c.Id != NULL);

        LMSCourse__c lmsc = UtilCreateTestData.CreateLMSCourse('Test Course', 'Test Course Description', 4, '1');
        insert lmsc;
        System.assert(lmsc.Id != NULL);

        BeckerLMS_Enrollment__c lmse = UtilCreateTestData.CreateLMSEnrollment(lmsc.Id, c.Id, system.today(), system.today().addDays(10));
        insert lmse;
        System.assert(lmse.Id != NULL);

        LMSEnrollmentService.LMSEnrollmentCreateRequest requestC = new LMSEnrollmentService.LMSEnrollmentCreateRequest();
        requestC.enrollee = c.Id;
        requestC.id = '2';
        requestC.lmsCourseId = '1';
        requestC.startDate = system.today();
        requestC.endDate = system.today().addDays(10);
        requestC.purchaseDate = system.today();
        requestC.selfEnrolled = true;
        requestC.parentLMSEnrollmentId = lmse.Id;

        List<LMSEnrollmentService.LMSEnrollmentCreateResponse> responseC = LMSEnrollmentService.CreateEnrollment(new List<LMSEnrollmentService.LMSEnrollmentCreateRequest>{requestC});
        System.assert(responseC != NULL);
        System.assert(responseC.size() > 0);
        LMSEnrollmentService.LMSEnrollmentCreateResponse response = responseC.get(0);
        System.assert(response.successful);
        System.assert(response.lmsEnrollmentId != NULL);

        LMSEnrollmentService.LMSEnrollmentUpdateRequest requestU = new LMSEnrollmentService.LMSEnrollmentUpdateRequest();
        requestU.lmsEnrollmentId = response.lmsEnrollmentId;
        requestU.endDate = system.today().addDays(20);
        requestU.score = 95;
        requestU.status = 'Completed';

        List<LMSEnrollmentService.LMSEnrollmentUpdateResponse> responseU = LMSEnrollmentService.UpdateEnrollment(new List<LMSEnrollmentService.LMSEnrollmentUpdateRequest>{requestU});
        System.assert(responseU != NULL);
        System.assert(responseU.size() > 0);
        LMSEnrollmentService.LMSEnrollmentUpdateResponse response1 = responseU.get(0);
       // System.assert(response1.successful);
    }

    static testMethod void test_EnrollmentNull() {
        List<LMSEnrollmentService.LMSEnrollmentCreateResponse> responseC = LMSEnrollmentService.CreateEnrollment(NULL);
        System.assert(responseC != NULL);
        System.assert(responseC.size() > 0);
        LMSEnrollmentService.LMSEnrollmentCreateResponse response = responseC.get(0);
        System.assert(!response.successful);
        System.assert(response.message == 'Invalid Request');

        responseC = LMSEnrollmentService.CreateEnrollment(new List<LMSEnrollmentService.LMSEnrollmentCreateRequest>{NULL});
        System.assert(responseC != NULL);
        System.assert(responseC.size() > 0);
        response = responseC.get(0);
        System.assert(!response.successful);
        System.assert(response.message == 'Invalid Request');

        List<LMSEnrollmentService.LMSEnrollmentUpdateResponse> responseU = LMSEnrollmentService.UpdateEnrollment(NULL);
        System.assert(responseU != NULL);
        System.assert(responseU.size() > 0);
        LMSEnrollmentService.LMSEnrollmentUpdateResponse response1 = responseU.get(0);
        System.assert(!response1.successful);
        System.assert(response1.message == 'Invalid Request');

        responseU = LMSEnrollmentService.UpdateEnrollment(new List<LMSEnrollmentService.LMSEnrollmentUpdateRequest>{NULL});
        System.assert(responseU != NULL);
        System.assert(responseU.size() > 0);
        response1 = responseU.get(0);
        System.assert(!response1.successful);
        System.assert(response1.message == 'Invalid Request or Invalid LMS Enrollment Id');
    }

    static testMethod void EnrollmentNegative() {
        LMSEnrollmentService.raiseException = true;
        List<LMSEnrollmentService.LMSEnrollmentCreateResponse> responseC = LMSEnrollmentService.CreateEnrollment(NULL);
        System.assert(responseC != NULL);
        System.assert(responseC.size() > 0);
        LMSEnrollmentService.LMSEnrollmentCreateResponse response = responseC.get(0);
        System.assert(!response.successful);

        List<LMSEnrollmentService.LMSEnrollmentUpdateResponse> responseU = LMSEnrollmentService.UpdateEnrollment(NULL);
        System.assert(responseU != NULL);
        System.assert(responseU.size() > 0);
        LMSEnrollmentService.LMSEnrollmentUpdateResponse response1 = responseU.get(0);
        System.assert(!response1.successful);
    }

    static testMethod void test_CreateEnrollmentDMLNegative() {
        Account a = UtilCreateTestData.CreateAccount();
        insert a;
        System.assert(a.Id != NULL);

        Contact c = UtilCreateTestData.CreateContact('Test FirstName', 'Test LastName', a.Id);
        insert c;
        System.assert(c.Id != NULL);

        LMSCourse__c lmsc = UtilCreateTestData.CreateLMSCourse('Test Course', 'Test Course Description', 4, '1');
        insert lmsc;
        System.assert(lmsc.Id != NULL);

        BeckerLMS_Enrollment__c lmse = UtilCreateTestData.CreateLMSEnrollment(lmsc.Id, c.Id, system.today(), system.today().addDays(10));
        insert lmse;
        System.assert(lmse.Id != NULL);

        LMSEnrollmentService.LMSEnrollmentCreateRequest requestC = new LMSEnrollmentService.LMSEnrollmentCreateRequest();
        requestC.enrollee = c.Id;
        requestC.id = '1';
        requestC.lmsCourseId = '2';
        requestC.startDate = system.today();
        requestC.endDate = system.today().addDays(10);
        requestC.purchaseDate = system.today();
        requestC.selfEnrolled = false;
        requestC.parentLMSEnrollmentId = lmse.Id;

        List<LMSEnrollmentService.LMSEnrollmentCreateResponse> responseC = LMSEnrollmentService.CreateEnrollment(new List<LMSEnrollmentService.LMSEnrollmentCreateRequest>{requestC});
        System.assert(responseC != NULL);
        System.assert(responseC.size() > 0);
        LMSEnrollmentService.LMSEnrollmentCreateResponse response = responseC.get(0);
        System.assert(!response.successful);
    }

    static testMethod void test_UpdateEnrollmentDMLNegative() {
        Account a = UtilCreateTestData.CreateAccount();
        insert a;
        System.assert(a.Id != NULL);

        Contact c = UtilCreateTestData.CreateContact('Test FirstName', 'Test LastName', a.Id);
        insert c;
        System.assert(c.Id != NULL);

        LMSCourse__c lmsc = UtilCreateTestData.CreateLMSCourse('Test Course', 'Test Course Description', 4, '1');
        insert lmsc;
        System.assert(lmsc.Id != NULL);

        BeckerLMS_Enrollment__c lmse = UtilCreateTestData.CreateLMSEnrollment(lmsc.Id, c.Id, system.today(), system.today().addDays(10));
        insert lmse;
        System.assert(lmse.Id != NULL);

        LMSEnrollmentService.LMSEnrollmentUpdateRequest requestU = new LMSEnrollmentService.LMSEnrollmentUpdateRequest();
        requestU.lmsEnrollmentId = lmse.Id;
        requestU.endDate = system.today().addDays(20);
        requestU.score = 95;
        requestU.status = 'Complete';

        List<LMSEnrollmentService.LMSEnrollmentUpdateResponse> responseU = LMSEnrollmentService.UpdateEnrollment(new List<LMSEnrollmentService.LMSEnrollmentUpdateRequest>{requestU});
        System.assert(responseU != NULL);
        System.assert(responseU.size() > 0);
        LMSEnrollmentService.LMSEnrollmentUpdateResponse response = responseU.get(0);
        System.assert(!response.successful);
    }

    static testMethod void test_UpdateEnrollmentInvalidId() {
        Account a = UtilCreateTestData.CreateAccount();
        insert a;
        System.assert(a.Id != NULL);

        Contact c = UtilCreateTestData.CreateContact('Test FirstName', 'Test LastName', a.Id);
        insert c;
        System.assert(c.Id != NULL);

        LMSCourse__c lmsc = UtilCreateTestData.CreateLMSCourse('Test Course', 'Test Course Description', 4, '1');
        insert lmsc;
        System.assert(lmsc.Id != NULL);

        LMSEnrollmentService.LMSEnrollmentUpdateRequest requestU = new LMSEnrollmentService.LMSEnrollmentUpdateRequest();
        requestU.lmsEnrollmentId = c.Id;
        requestU.endDate = system.today().addDays(20);
        requestU.score = 95;
        requestU.status = 'Completed';

        List<LMSEnrollmentService.LMSEnrollmentUpdateResponse> responseU = LMSEnrollmentService.UpdateEnrollment(new List<LMSEnrollmentService.LMSEnrollmentUpdateRequest>{requestU});
        System.assert(responseU != NULL);
        System.assert(responseU.size() > 0);
        LMSEnrollmentService.LMSEnrollmentUpdateResponse response = responseU.get(0);
        System.assert(!response.successful);
    }
}