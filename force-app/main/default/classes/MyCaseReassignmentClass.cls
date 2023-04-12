public class MyCaseReassignmentClass {
    @Future
    public static void reassignCaseWithActiveRule(Id myCaseId) {
        System.debug('>>>>>myCaseId: ' + myCaseId);
        //fetching the desired assignment rules on Case...
        AssignmentRule AR = new AssignmentRule();
        AR = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = TRUE LIMIT 1];

        //recreating the DMLOptions setting for "Assign using active assignment rules" checkbox on Case object...
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.Id;

        if (myCaseId <> null) {
            //get current instance of sObject (Case)...
            Case myCase = [SELECT Id, Assigned_to_Service_Cloud_Agent__c FROM Case WHERE Id = :myCaseId LIMIT 1];

            //set DMLOptions on this record so it will be processed suing assignment rules...
            myCase.setOptions(dmlOpts);
            //  myCase.Additional_Information__c = 'processed w/ @future on '+ dateTime.now();
            update myCase;
        }
    }
}