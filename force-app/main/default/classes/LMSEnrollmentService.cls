/*
 * REST Service Name: LMSEnrollmentService - LMS Enrollment REST Service class
 * 5/2/2017           mmurphy               Created class.
*/

@RestResource (urlMapping='/enrollment/*')
global class LMSEnrollmentService {
    public static Boolean raiseException = false;
    private class customException extends Exception {}
    @HttpPost
    global static List<LMSEnrollmentCreateResponse> CreateEnrollment(List<LMSEnrollmentCreateRequest> requests) {
        List<LMSEnrollmentCreateResponse> responses = new List<LMSEnrollmentCreateResponse>();
        try{
            if (raiseException) throw new customException('Testing code');

            System.debug('*****LMSEnrollmentService.CreateEnrollment.requests: ' + requests);

            List<BeckerLMS_Enrollment__c> lmsEnrollmentsToInsert = new List<BeckerLMS_Enrollment__c>();
            Map<String,Id> mapLmsCourseIds = new Map<String,Id>();
            Map<Id, BeckerLMS_Enrollment__c> mapParentLmsEnrollmentsByIds = new Map<Id, BeckerLMS_Enrollment__c>();
            Set<String> lmsCourseIds = new Set<String>();
            Set<Id> parentLmsEnrollmentIds = new Set<Id>();

            if (requests == NULL || requests.size()<= 0){
                LMSEnrollmentCreateResponse response = new LMSEnrollmentCreateResponse();
                response.id = NULL;
                response.lmsEnrollmentId = NULL;
                response.successful = false;
                response.message = 'Invalid Request';
                responses.add(response);
                System.debug('*****LMSEnrollmentService.CreateEnrollment.responses: ' + responses);
                return responses;
            }

            for (LMSEnrollmentCreateRequest request : requests){
                if (request != NULL){
                    if (String.isNotBlank(request.lmsCourseId))
                        lmsCourseIds.add(request.lmsCourseId);
                    if (request.parentLMSEnrollmentId != NULL)
                        parentLmsEnrollmentIds.add(request.parentLMSEnrollmentId);
                }
            }
            mapLmsCourseIds = GetLMSCourseIds(lmsCourseIds);
            mapParentLmsEnrollmentsByIds = GetLMSEnrollments(parentLmsEnrollmentIds);
            System.debug('*****LMSEnrollmentService.CreateEnrollment.mapLmsCourseIds: ' + mapLmsCourseIds);
            System.debug('*****LMSEnrollmentService.CreateEnrollment.mapParentLmsEnrollmentsByIds: ' + mapParentLmsEnrollmentsByIds);

            for (LMSEnrollmentCreateRequest request : requests){
                LMSEnrollmentCreateResponse response = new LMSEnrollmentCreateResponse();
                if (request == NULL){
                    response.id = NULL;
                    response.lmsEnrollmentId = NULL;
                    response.successful = false;
                    response.message = 'Invalid Request';
                    responses.add(response);
                    break;
                }
                BeckerLMS_Enrollment__c lms_enrollment = new BeckerLMS_Enrollment__c();
                lms_enrollment.LMS_ID__c = request.id;
                lms_enrollment.Contact__c = request.enrollee;
                lms_enrollment.LMS_Course__c = (mapLmsCourseIds.containsKey(request.lmsCourseId) ? mapLmsCourseIds.get(request.lmsCourseId) : NULL);
                lms_enrollment.Purchase_Date__c = request.purchaseDate;
                lms_enrollment.Start_Date__c = request.startDate;
                lms_enrollment.End_Date__c = request.endDate;
              lms_enrollment.Completed_On__c = request.completionDate;
                BeckerLMS_Enrollment__c lms_enrollmentParent = (mapParentLmsEnrollmentsByIds.containsKey(request.parentLMSEnrollmentId) ? mapParentLmsEnrollmentsByIds.get(request.parentLMSEnrollmentId) : NULL);

                lms_enrollment.BeckerLMS_Enrollment__c = request.parentLMSEnrollmentId;
                lms_enrollment.Self_enrolled__c = (request.selfEnrolled == NULL ? false : request.selfEnrolled);
                lms_enrollment.GenerateCEU__c = ((request.selfEnrolled == NULL || !request.selfEnrolled || lms_enrollmentParent == NULL) ? false : !lms_enrollmentParent.GenerateCEU__c);

                lmsEnrollmentsToInsert.add(lms_enrollment);
            }
            System.debug('*****LMSEnrollmentService.CreateEnrollment.lmsEnrollmentsToInsert: ' + lmsEnrollmentsToInsert);

            List<Database.SaveResult> srList = Database.Insert(lmsEnrollmentsToInsert,false);
            System.debug('*****LMSEnrollmentService.CreateEnrollment.srList: ' + srList);
            for(Integer i=0;i<srList.size();i++){
                BeckerLMS_Enrollment__c lms_enrollment = lmsEnrollmentsToInsert.get(i);
                LMSEnrollmentCreateResponse response = new LMSEnrollmentCreateResponse();
                if (srList.get(i).isSuccess()){
                    response.id = lms_enrollment.LMS_ID__c;
                    response.lmsEnrollmentId = lms_enrollment.Id;
                    response.successful = true;
                    response.message = '';
                    responses.add(response);

                }else {
                    Database.Error error = srList.get(i).getErrors().get(0);
                    response.id = lms_enrollment.LMS_ID__c;
                    response.lmsEnrollmentId = NULL;
                    response.successful = false;
                    response.message = error.getMessage();
                    responses.add(response);
                }

            }
        }
        catch(Exception ex){
            
            LMSEnrollmentCreateResponse response = new LMSEnrollmentCreateResponse();
            response.id = NULL;
            response.lmsEnrollmentId = NULL;
            response.successful = false;
            response.message = ex.getMessage();
            responses.add(response);
        }
        System.debug('*****LMSEnrollmentService.CreateEnrollment.responses: ' + responses);
        return responses;
    }

   @HttpPut
    global static List<LMSEnrollmentUpdateResponse> UpdateEnrollment(List<LMSEnrollmentUpdateRequest> requests) {
       List<LMSEnrollmentUpdateResponse> responses = new List<LMSEnrollmentUpdateResponse>();
       try{
            if (raiseException) throw new customException('Testing code');

            System.debug('*****LMSEnrollmentService.UpdateEnrollment.requests: ' + requests);

            List<BeckerLMS_Enrollment__c> lmsEnrollmentsToUpdate = new List<BeckerLMS_Enrollment__c>();
            Map<Id, BeckerLMS_Enrollment__c> mapLmsEnrollmentsByIds = new Map<Id, BeckerLMS_Enrollment__c>();
            Set<Id> lmsEnrollmentIds = new Set<Id>();

            if (requests == NULL || requests.size()<= 0){
                LMSEnrollmentUpdateResponse response = new LMSEnrollmentUpdateResponse();
                response.lmsEnrollmentId = NULL;
                response.successful = false;
                response.message = 'Invalid Request';
                responses.add(response);
                System.debug('*****LMSEnrollmentService.UpdateEnrollment.responses: ' + responses);
                return responses;
            }

            for (LMSEnrollmentUpdateRequest request : requests){
                if (request != NULL){
                    if (request.lmsEnrollmentId != NULL)
                        lmsEnrollmentIds.add(request.lmsEnrollmentId);
                }
            }
            mapLmsEnrollmentsByIds = GetLMSEnrollments(lmsEnrollmentIds);
            System.debug('*****LMSEnrollmentService.UpdateEnrollment.mapLmsEnrollmentsByIds: ' + mapLmsEnrollmentsByIds);

            for (LMSEnrollmentUpdateRequest request : requests){
                LMSEnrollmentUpdateResponse response = new LMSEnrollmentUpdateResponse();
                if (request == NULL || !mapLmsEnrollmentsByIds.containsKey(request.lmsEnrollmentId) ){
                    response.lmsEnrollmentId = NULL;
                    response.successful = false;
                    response.message = 'Invalid Request or Invalid LMS Enrollment Id';
                    responses.add(response);
                    break;
                }
                BeckerLMS_Enrollment__c lms_enrollment = mapLmsEnrollmentsByIds.get(request.lmsEnrollmentId);
                lms_enrollment.End_Date__c = request.endDate;
                lms_enrollment.Status__c = request.status;
                lms_enrollment.Score__c = request.score;
                 lms_enrollment.Completed_On__c = request.completionDate;
                lmsEnrollmentsToUpdate.add(lms_enrollment);
            }

            List<Database.SaveResult> srList = Database.Update(lmsEnrollmentsToUpdate, false);
            System.debug('*****LMSEnrollmentService.UpdateEnrollment.srList: ' + srList);
            for(Integer i=0;i<srList.size();i++){
                BeckerLMS_Enrollment__c lms_enrollment = lmsEnrollmentsToUpdate.get(i);
                LMSEnrollmentUpdateResponse response = new LMSEnrollmentUpdateResponse();
                if (srList.get(i).isSuccess()){
                    response.lmsEnrollmentId = lms_enrollment.Id;
                    response.successful = true;
                    response.message = '';
                    responses.add(response);
                }else {
                    Database.Error error = srList.get(i).getErrors().get(0);
                    response.lmsEnrollmentId = lms_enrollment.Id;
                    response.successful = false;
                    response.message = error.getMessage();
                    responses.add(response);
                }
            }
        }
        catch(Exception ex){
            
            LMSEnrollmentUpdateResponse response = new LMSEnrollmentUpdateResponse();
            response.lmsEnrollmentId = NULL;
            response.successful = false;
            response.message = ex.getMessage();
            responses.add(response);
        }

        System.debug('*****LMSEnrollmentService.UpdateEnrollment.responses: ' + responses);
        return responses;
    }

    global class LMSEnrollmentCreateRequest {
        public String id {get; set;} //LMS Id (External Id)
        public Id enrollee {get; set;}
        public String lmsCourseId {get; set;} //LMS Course Id (External Id)
        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public Date completionDate{get; set;}
        public Date purchaseDate {get; set;}
        public Boolean selfEnrolled {get; set;}
        public Id parentLMSEnrollmentId {get; set;}
    }

    global class LMSEnrollmentUpdateRequest {
        public Id lmsEnrollmentId {get; set;}
        public Date endDate {get; set;}
        public String status {get; set;}
         public Date completionDate{get; set;}
        public Integer score {get; set;}
    }

    global class LMSEnrollmentCreateResponse {
        public String id {get; set;}
        public Id lmsEnrollmentId {get; set;}
        public Boolean successful {get; set;}
        public String message {get;set;}
    }

    global class LMSEnrollmentUpdateResponse {
        public Id lmsEnrollmentId {get; set;}
        public Boolean successful {get; set;}
        public String message {get;set;}
    }

    private static Map<String,Id> GetLMSCourseIds(Set<String> lmsCourseIds){
        Map<String,Id> result = new Map<String,Id>();
        for (LMSCourse__c c : [SELECT Id, LMSID__c  FROM LMSCourse__c WHERE LMSID__c IN:lmsCourseIds]){
            result.put(c.LMSID__c, c.Id);
        }
        return result;
    }

    private static Map<Id, BeckerLMS_Enrollment__c> GetLMSEnrollments(Set<Id> lmsEnrollmentIds){
        Map<Id, BeckerLMS_Enrollment__c> result = new Map<Id, BeckerLMS_Enrollment__c>();
        for (BeckerLMS_Enrollment__c e : [SELECT Id, End_Date__c, Status__c, Score__c, GenerateCEU__c FROM BeckerLMS_Enrollment__c WHERE Id IN:lmsEnrollmentIds]){
            result.put(e.Id, e);
        }
        return result;
    }
}