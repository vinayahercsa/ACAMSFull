/**
 *      @author Kumar Ganadurai
 *      @date   06/05/2017 - Initial Version
        @description    ManageAttachments trigger on Attachment object created for certification eligibility calculation 
        
 */

trigger ManageAttachments on Attachment (after insert) {
  if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
    AttachmentHelper.EvaluateCreditOnCerttification(trigger.new);
  }
}