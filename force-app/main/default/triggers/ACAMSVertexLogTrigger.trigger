trigger ACAMSVertexLogTrigger on Vertex__VertexLog__c (after insert) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSVertexLogTriggerHandler()).run();
    }
}