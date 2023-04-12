trigger ACAMSMembershipsandCertificationsTrigger on Memberships_and_Certifications__c (after insert, after update) {
     if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
          (new ACAMSMemsandCertTriggerHandler()).run();
     }
}