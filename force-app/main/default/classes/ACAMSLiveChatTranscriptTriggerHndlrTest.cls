@isTest
public class ACAMSLiveChatTranscriptTriggerHndlrTest {

    @isTest
    static void link_transcript_to_case() {

        Case cs = new Case(
            subject = 'Test Case',
            origin = 'Web'
        );

        insert cs;

        LiveChatVisitor visitor = new LiveChatVisitor();

        insert visitor;

        Test.startTest();

        LiveChatTranscript tx = new LiveChatTranscript(
             liveChatVisitorId = visitor.id,
             body = cs.id
        );
         insert tx;
        LiveChatTranscript tx2=new LiveChatTranscript();
        tx2.caseid=cs.id;
        tx2.id=tx.id;
        update tx;
        Test.stopTest();
    }
    
}