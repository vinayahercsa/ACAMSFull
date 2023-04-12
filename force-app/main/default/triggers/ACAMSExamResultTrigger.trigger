trigger ACAMSExamResultTrigger on Exam_Results__c (before insert, after insert, before update, after update) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSExamResultTriggerHandler()).run();
    }
}