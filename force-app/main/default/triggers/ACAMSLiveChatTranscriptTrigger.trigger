trigger ACAMSLiveChatTranscriptTrigger on LiveChatTranscript (After insert) {
    if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        (new ACAMSLiveChatTranscriptTriggerHandler()).run();
    }
}