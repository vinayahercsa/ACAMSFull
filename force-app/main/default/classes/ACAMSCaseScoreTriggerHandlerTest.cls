@IsTest
public class ACAMSCaseScoreTriggerHandlerTest {
   
    static testMethod void myUnitTest() {
   
        
    Case objcase = new case();
      objcase.Status='New';
      objcase.Subject='Test Subject';
      //objcase.CurrencyIsoCode='USD';
      objcase.Origin='Chat';
      insert objcase;
    List<Contact_Center_Scorecard__c> cc = new list<Contact_Center_Scorecard__c>();
       
    Contact_Center_Scorecard__c scoreCard=new  Contact_Center_Scorecard__c();
        scoreCard.Case__c =objcase.Id;
        scorecard.GREET_Verified_customer_information__c = 'Pass';
        scorecard.GREET_Thanked_customer__c = 'Pass';
        scorecard.CARE_Acknowledged_customer_issue__c = 'Pass';
        scorecard.CARE_Used_polite_expressions__c = 'Pass';
        scorecard.CARE_Followed_proper_hold_procedure__c = 'Pass';
        scorecard.GREET_Identified_self_offered_assistan__c = 'Pass';
        scorecard.OWN_CCS_Ownership_items__c = 'Pass';
        scorecard.OWN_Took_responsibility_to_answer_inquir__c = 'Pass';
        scorecard.OWN_Reviewed_SFDC_for_inquiry_info__c = 'Pass';
        scorecard.OWN_Asked_appropiate_probing_questions__c = 'Pass';
        scorecard.LISTEN_Actively_listened__c ='Pass';
        scorecard.LISTEN_Restated_understanding_of_issue__c = 'Pass';
        scorecard.LISTEN_Addressed_all_issues_and_concerns__c ='Pass';
        scorecard.LISTEN_Did_not_ask_customer_to_repeat_in__c = 'Pass';
        scorecard.LISTEN_Did_not_interrupt_the_customer__c = 'Pass';
        scorecard.SKILLS_Projected_pleasant_upbeat_tone__c = 'Pass';
        scorecard.SKILLS_Kept_a_good_pace_during_call__c = 'Pass';
        scorecard.SKILLS_Performed_a_warm_transfer__c = 'Pass';
        scorecard.SKILLS_Spoke_clearly__c = 'Pass';
        scorecard.SKILLS_Minimal_dead_air_time__c = 'Pass';
        scorecard.SKILLS_Well_formed_written_communication__c = 'Pass';
        scorecard.ACCURATE_Used_available_resources__c = 'Pass';
        scorecard.ACCURATE_Followed_proper_procedure__c = 'Pass';
        scorecard.ACCURATE_1_call_case_resolution__c = 'Pass';
        scorecard.CLOSING_Summarized_actions_taken__c = 'Pass';
        scorecard.CLOSING_Advised_next_steps__c = 'Pass';
        scorecard.CLOSING_Thanked_the_Customer__c = 'Pass';
        scorecard.CLOSING_Offered_additional_assistance__c = 'Pass';
        scorecard.CLOSING_Categorized_the_case_correctly__c = 'Pass';
        scorecard.DOC_Included_detailed_and_accurate_notes__c = 'Pass';
        scorecard.DOC_Case_completed_correctly__c = 'Pass';
        scorecard.DOC_Used_proper_grammar_spelling__c = 'Pass';
       
        insert scoreCard;
        
        
        scorecard.GREET_Verified_customer_information__c = 'Fail';
        scorecard.GREET_Thanked_customer__c = 'Fail';
        scorecard.CARE_Acknowledged_customer_issue__c = 'Fail';
        scorecard.CARE_Used_polite_expressions__c = 'Fail';
        scorecard.CARE_Followed_proper_hold_procedure__c = 'Fail';
        scorecard.GREET_Identified_self_offered_assistan__c = 'Fail';
        scorecard.OWN_CCS_Ownership_items__c = 'Fail';
        scorecard.OWN_Took_responsibility_to_answer_inquir__c = 'Fail';
        scorecard.OWN_Reviewed_SFDC_for_inquiry_info__c = 'Fail';
        scorecard.OWN_Asked_appropiate_probing_questions__c = 'Fail';
        scorecard.LISTEN_Actively_listened__c ='Fail';
        scorecard.LISTEN_Restated_understanding_of_issue__c = 'Fail';
        scorecard.LISTEN_Addressed_all_issues_and_concerns__c ='Fail';
        scorecard.LISTEN_Did_not_ask_customer_to_repeat_in__c = 'Fail';
        scorecard.LISTEN_Did_not_interrupt_the_customer__c = 'Fail';
        scorecard.SKILLS_Projected_pleasant_upbeat_tone__c = 'Fail';
        scorecard.SKILLS_Kept_a_good_pace_during_call__c = 'Fail';
        scorecard.SKILLS_Performed_a_warm_transfer__c = 'Fail';
        scorecard.SKILLS_Spoke_clearly__c = 'Fail';
        scorecard.SKILLS_Minimal_dead_air_time__c = 'Fail';
        scorecard.SKILLS_Well_formed_written_communication__c = 'Fail';
        scorecard.ACCURATE_Used_available_resources__c = 'Fail';
        scorecard.ACCURATE_Followed_proper_procedure__c = 'Fail';
        scorecard.ACCURATE_1_call_case_resolution__c = 'Fail';
        scorecard.CLOSING_Summarized_actions_taken__c = 'Fail';
        scorecard.CLOSING_Advised_next_steps__c = 'Fail';
        scorecard.CLOSING_Thanked_the_Customer__c = 'Fail';
        scorecard.CLOSING_Offered_additional_assistance__c = 'Fail';
        scorecard.CLOSING_Categorized_the_case_correctly__c = 'Fail';
        scorecard.DOC_Included_detailed_and_accurate_notes__c = 'Fail';
        scorecard.DOC_Case_completed_correctly__c = 'Fail';
        scorecard.DOC_Used_proper_grammar_spelling__c = 'Fail';
        
        update scorecard;
        
        cc.add(scorecard);
       
       
    ACAMSCaseScoreTriggerHandler ccs = new ACAMSCaseScoreTriggerHandler();
        ccs.CalculationAndResult(cc);
       
       
 }
     static testMethod void myUnitTest1() {
   
        
    Case objcase = new case();
      objcase.Status='New';
      objcase.Subject='Test Subject';
      //objcase.CurrencyIsoCode='USD';
      objcase.Origin='Chat';
      insert objcase;
    List<Contact_Center_Scorecard__c> cc = new list<Contact_Center_Scorecard__c>();
       
    Contact_Center_Scorecard__c scoreCard=new  Contact_Center_Scorecard__c();
        scoreCard.Case__c =objcase.Id;
        scorecard.GREET_Verified_customer_information__c = 'Fail';
        scorecard.GREET_Thanked_customer__c = 'Fail';
        scorecard.CARE_Acknowledged_customer_issue__c = 'Fail';
        insert scoreCard;
        scorecard.GREET_Verified_customer_information__c = 'Pass';
        scorecard.GREET_Thanked_customer__c = 'Pass';
        scorecard.CARE_Acknowledged_customer_issue__c = 'Pass';
         
        
        update scorecard;
       
         
        cc.add(scorecard);
       
       
    ACAMSCaseScoreTriggerHandler ccs = new ACAMSCaseScoreTriggerHandler();
        ccs.CalculationAndResult(cc);
          
             
 }
}