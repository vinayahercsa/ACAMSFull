trigger ACAMSEducationalCreditUnitTrigger on Educational_Credit_Unit_Legacy__c (after Insert ,before Update, before Insert) {     
  if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSEducationalCreditUnitTriggerHandler()).run();
    }
}