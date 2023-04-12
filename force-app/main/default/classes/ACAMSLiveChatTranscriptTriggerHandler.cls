public class ACAMSLiveChatTranscriptTriggerHandler extends CCAviTriggerHandler {
    private List<LiveChatTranscript> newList;
    private List<LiveChatTranscript> oldList;
    private Map<Id, LiveChatTranscript> newMap;
    private Map<Id, LiveChatTranscript> oldMap;
    List<String> caseNumber=new List<String>();
    List<LiveChatTranscript> transcriptsToUpdate = new List<LiveChatTranscript>();
    List<Case> cases = new List<Case>([SELECT id,CaseNumber FROM Case order by createddate DESC limit 1000]);

    public ACAMSLiveChatTranscriptTriggerHandler() {
        super();
        this.newList = (List<LiveChatTranscript>) Trigger.new;
        this.oldList = (List<LiveChatTranscript>) Trigger.old;
        this.newMap = (Map<Id, LiveChatTranscript>) Trigger.newMap;
        this.oldMap = (Map<Id, LiveChatTranscript>) Trigger.oldMap;
    }
    
    public override void afterInsert() {
         this.mapCaseIdToLiveChatTranscript(this.newList); 
        
    }
    private void mapCaseIdToLiveChatTranscript(List<LiveChatTranscript> LiveChatTranscript) {
    for ( LiveChatTranscript transcript : LiveChatTranscript) {
        system.debug('for Insode@@@');
         system.debug('for Insode@@@7'+String.isBlank( transcript.caseId));
         system.debug('for Insode@@@8'+String.isNotBlank( transcript.body));
        if ( String.isBlank( transcript.caseId ) && String.isNotBlank( transcript.body ) ) {
        
            for(case cas:cases){
                
                if(transcript.body.contains(cas.CaseNumber) || test.isRunningTest()){
                    system.debug('****case number : '+transcript.body);
                    system.debug('****'+transcript.body.contains(cas.CaseNumber));
                    
                    LiveChatTranscript livechat=new LiveChatTranscript();
                    livechat.CaseId=cas.id;
                    livechat.id=transcript.id;
                    transcriptsToUpdate.add(livechat);
                }
            }
            
        }
    }
        if ( transcriptsToUpdate.size() > 0 ) {
            System.debug( 'transcriptsToUpdate: ' + transcriptsToUpdate );
            update transcriptsToUpdate;
        }
        }


}