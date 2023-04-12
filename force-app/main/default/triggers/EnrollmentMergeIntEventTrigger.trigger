trigger EnrollmentMergeIntEventTrigger on Enrollment_Merge_Integration__e (after insert) {
    Static Integer counter = 0;
    Static Integer BATCHSIZE = 100;
    String calloutString;
    Static String throttleSizeStr = ACAMS_Platform_Event_Setting__mdt.getInstance('Enrollment_Merge_Integration')?.Value__c;
    if(String.isNotBlank(throttleSizeStr))
    {
        BATCHSIZE = Integer.valueOf(throttleSizeStr);
    }

    for (Enrollment_Merge_Integration__e eventItem : Trigger.New) {
		counter++;
        calloutString = eventItem.MergeEnrollmentBody__c;
        if(counter == BATCHSIZE) {
            //  Set the last executed event as the checkpoint, to continue later from the next event
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(eventItem.ReplayId);
            break;
        }  
    }
    if(String.isNotBlank(calloutString)){
        try{
            ACAMSUtil.reportException(null, null, 'Merge Enrollment Integration PE', null,  'Merge Enrollment Integration', calloutString, null);
            CalloutUtility.SendRequestFuture('EnrollmentMergeIntegration', true, calloutString);
        }catch (Exception e) {
            // Only retry so many times, before giving up (thus avoid disabling the trigger)
            //Keeping retries times to 3, after the retries count go past 3, it should throw exceptiuon
            if (EventBus.TriggerContext.currentContext().retries < 4) {
                throw new EventBus.RetryableException(e.getMessage());
            }
            else
                 ACAMSUtil.reportException(null, null,'Enrollment Event Platform Event Failed ', null, e.getMessage(), null, null);

        }
        
	}
}