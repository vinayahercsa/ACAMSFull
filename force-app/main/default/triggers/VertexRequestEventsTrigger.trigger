trigger VertexRequestEventsTrigger on Vertex_Request_PE__e (after insert) {
    Static Integer counter = 0;
    Static Integer BATCHSIZE = 100;
    Static String throttleSizeStr = ACAMS_Platform_Event_Setting__mdt.getInstance('Vertex_Request_Platform_Event')?.Value__c;
    List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure> requestList = new List<Vertex.VertexAnyRequest.InvokeAnyRequestStructure>();
    if(String.isNotBlank(throttleSizeStr))
    {
        BATCHSIZE = Integer.valueOf(throttleSizeStr);
    }
    for (Vertex_Request_PE__e eventItem : Trigger.New) {
        counter++;
        Vertex.VertexAnyRequest.InvokeAnyRequestStructure req = new Vertex.VertexAnyRequest.InvokeAnyRequestStructure();
        req.recordId =eventItem.RecordId__c;
        req.type =eventItem.Type__c;
        requestList.add(req);

        if(counter == BATCHSIZE) {
            //  Set the last executed event as the checkpoint, to continue later from the next event
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(eventItem.ReplayId);
            break;
        }  
    }
    ACAMSUtil.reportException(null, null, 'Vertex Request PE', null,  'Vertex Request Creation', JSON.serialize(requestList), null);
    if(!requestList.isEmpty()){
        try{
            Vertex.VertexAnyRequest.InvokeAllRequests(requestList);
        }catch (Exception e) {
            // Only retry so many times, before giving up (thus avoid disabling the trigger)
            //Keeping retries times to 3, after the retries count go past 3, it should throw exceptiuon
            if (EventBus.TriggerContext.currentContext().retries < 4) {
                throw new EventBus.RetryableException(e.getMessage());
            }
            else
                 ACAMSUtil.reportException(null, null,'Vertex Request Platform Event Failed ', null, e.getMessage(), null, null);
        }
        
    }
}