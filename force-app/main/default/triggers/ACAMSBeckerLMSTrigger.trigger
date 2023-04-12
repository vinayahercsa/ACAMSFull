trigger ACAMSBeckerLMSTrigger on BeckerLMS_Enrollment__c (before insert, before update, after insert, after update) {//FSA-950
	if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
		(new ACAMSBeckerLMSTriggerHandler()).run();
	}
}