trigger AssetEMEnrollmentEventsTrigger on Asset_EM_Enrollment_Event__e (after insert) {
    Static Integer counter = 0;
    Static Integer BATCHSIZE = 100;
    list<BeckerLMS_Enrollment__c> beckLMSInsertList = new list<BeckerLMS_Enrollment__c>();
    list<BeckerLMS_Enrollment__c> beckLMSUpdateList = new list<BeckerLMS_Enrollment__c>();
    Static String throttleSizeStr = ACAMS_Platform_Event_Setting__mdt.getInstance('Asset_EM_Enrollment_Event')?.Value__c;
    if(String.isNotBlank(throttleSizeStr))
    {
        BATCHSIZE = Integer.valueOf(throttleSizeStr);
    }

    for (Asset_EM_Enrollment_Event__e eventItem : Trigger.New) {
		counter++;
        BeckerLMS_Enrollment__c lmsEnrollment = new BeckerLMS_Enrollment__c();
        lmsEnrollment.Id = eventItem.Asset_ID__c;
        if(eventItem.isInsertLMS__c == true){
            beckLMSInsertList.add(lmsEnrollment);
        }else if(eventItem.isUpdateLMS__c == true){
            beckLMSUpdateList.add(lmsEnrollment);
        }
        if(counter == BATCHSIZE) {
            //  Set the last executed event as the checkpoint, to continue later from the next event
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(eventItem.ReplayId);
            break;
        }  
    }
    if(!beckLMSInsertList.isEmpty()){
        try{
            ACAMSUtil.reportException(null, null, 'Asset EM EnrollMent PE', null,  'Becker LMS EnrollMent Insertion', JSON.serialize(beckLMSInsertList), null);
            DMLUtility.InsertSObjects(beckLMSInsertList);
        }catch (Exception e) {
            // Only retry so many times, before giving up (thus avoid disabling the trigger)
            //Keeping retries times to 3, after the retries count go past 3, it should throw exceptiuon
            if (EventBus.TriggerContext.currentContext().retries < 4) {
                throw new EventBus.RetryableException(e.getMessage());
            }
            else
                 ACAMSUtil.reportException(null, null,'Becker LMS EnrollMent Insertion Platform Event Failed ', null, e.getMessage(), null, null);

                
        }
        
	}
    if(!beckLMSUpdateList.isEmpty()){
        try{
            ACAMSUtil.reportException(null, null, 'Asset EM EnrollMent PE', null,  'Becker LMS EnrollMent Updation', JSON.serialize(beckLMSUpdateList), null);
            DMLUtility.UpdateSObjects(beckLMSUpdateList);
        }catch (Exception e) {
            // Only retry so many times, before giving up (thus avoid disabling the trigger)
            //Keeping retries times to 3, after the retries count go past 3, it should throw exceptiuon
            if (EventBus.TriggerContext.currentContext().retries < 4) {
                throw new EventBus.RetryableException(e.getMessage());
            }
            else
                 ACAMSUtil.reportException(null, null,'Becker LMS EnrollMent Update Platform Event Failed ', null, e.getMessage(), null, null);
  
        }
        
    }
}