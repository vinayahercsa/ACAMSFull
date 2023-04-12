public with sharing class ACAMSCaseScoreTriggerHandler extends CCAviTriggerHandler {
    
    private List<Contact_Center_Scorecard__c> newList;
    private List<Contact_Center_Scorecard__c> oldList;
    private Map<Id, Contact_Center_Scorecard__c> newMap;
    private Map<Id, Contact_Center_Scorecard__c> oldMap;

    public ACAMSCaseScoreTriggerHandler() {
        super();
        this.newList = (List<Contact_Center_Scorecard__c>) Trigger.new;
        this.oldList = (List<Contact_Center_Scorecard__c>) Trigger.old;
        this.newMap = (Map<Id, Contact_Center_Scorecard__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Contact_Center_Scorecard__c>) Trigger.oldMap;
    }
    
    public override void beforeInsert(){
        this.CalculationAndResult(this.newList);
    }
    
    public override void beforeUpdate(){
        this.CalculationAndResult(this.newList);
    }
    @TestVisible
    private void CalculationAndResult(List<Contact_Center_Scorecard__c> Calculateresult){
        double greetpass = 0;
        double greetfail = 0;
        Decimal greetscore;
        double carepass = 0;
        double carefail = 0;
        Decimal carescore;
        double ownpass = 0;
        double ownfail = 0;
        Decimal ownscore;
        double listenpass = 0;
        double listenfail = 0;
        Decimal listenscore;
        double skillspass = 0;
        double skillsfail = 0;
        Decimal skillsscore;
        double accuratepass = 0;
        double accuratefail = 0;
        Decimal accuratescore;
        double closingpass = 0;
        double closingfail = 0;
        Decimal closingscore;
        double docpass = 0.0;
        double docfail = 0.0;
        Decimal docscore;
        double finalpass = 0.0;
        double finalfail = 0.0;
        Decimal finalscore;

 for (Contact_Center_Scorecard__c ccs : Calculateresult) {
         
         // GREET CALCULATION AND RESULT
         
             if(ccs.GREET_Verified_customer_information__c=='Fail'){         
             ccs.GREET_result__c='Fail';} 
                 
                 else {
         
             if(ccs.GREET_Thanked_customer__c=='Pass'){
             greetpass = 1;}else{
             if(ccs.GREET_Thanked_customer__c=='Fail'){
             greetfail = 1;}else{}
             }
             if(ccs.GREET_Identified_self_offered_assistan__c=='Pass'){
             greetpass = greetpass +1;}else{
             if(ccs.GREET_Identified_self_offered_assistan__c=='Fail'){
             greetfail = greetfail +1;}else{}
             }
             
             if(ccs.GREET_Verified_customer_information__c=='Pass'){
             greetpass = greetpass +1;}else{
             if(ccs.GREET_Verified_customer_information__c=='Fail'){
             greetfail = greetfail +1;}else{}
             }       
             
             if(greetpass != 0 || greetfail != 0)    {
                 greetscore = greetpass/(greetpass+greetfail);   
             if(greetscore>=0.5){
             ccs.GREET_result__c='Pass';} else {ccs.GREET_result__c='Fail';}  
             }  else {   ccs.GREET_result__c='N/A';}
               
             } 

         // CARE CALCULATION AND RESULT
        
             if(ccs.CARE_Acknowledged_customer_issue__c=='Pass'){
             carepass = 1;}else{
             if(ccs.CARE_Acknowledged_customer_issue__c=='Fail'){
             carefail = 1;}else{}
             }
             
             if(ccs.CARE_Used_polite_expressions__c=='Pass'){
             carepass = carepass + 1;}else{
             if(ccs.CARE_Used_polite_expressions__c=='Fail'){
             carefail = carefail + 1;}else{}
             }
         
             if(ccs.CARE_Followed_proper_hold_procedure__c=='Pass'){
             carepass = carepass + 1;}else{
             if(ccs.CARE_Followed_proper_hold_procedure__c=='Fail'){
             carefail = carefail + 1;}else{}
             }
             if(carepass != 0 || carefail != 0)    {
             carescore = carepass/(carepass+carefail);   
             if(carescore>=0.5){
             ccs.CARE_result__c='Pass';} else {ccs.CARE_result__c='Fail';}  
             }  else {   ccs.CARE_result__c='N/A';}

         // OWN CALCULATION AND RESULT

             if(ccs.OWN_CCS_Ownership_items__c=='Fail'){         
             ccs.OWN_result__c='Fail';}                  
                 else {
             if(ccs.OWN_Took_responsibility_to_answer_inquir__c=='Pass'){
             ownpass = 1;}else{
             if(ccs.OWN_Took_responsibility_to_answer_inquir__c=='Fail'){
             ownfail = 1;}else{}
             }

             if(ccs.OWN_Reviewed_SFDC_for_inquiry_info__c=='Pass'){
             ownpass = ownpass + 1;}else{
             if(ccs.OWN_Reviewed_SFDC_for_inquiry_info__c=='Fail'){
             ownfail = ownfail + 1;}else{}
             }

             if(ccs.OWN_Reviewed_SFDC_for_outstanding_issues__c=='Pass'){
             ownpass = ownpass + 1;}else{
             if(ccs.OWN_Reviewed_SFDC_for_outstanding_issues__c=='Fail'){
             ownfail = ownfail + 1;}else{}
             }

             if(ccs.OWN_Asked_appropiate_probing_questions__c=='Pass'){
             ownpass = ownpass + 1;}else{
             if(ccs.OWN_Asked_appropiate_probing_questions__c=='Fail'){
             ownfail = ownfail + 1;}else{}
             }

             if(ccs.OWN_CCS_Ownership_items__c=='Pass'){
             ownpass = ownpass + 1;}else{
             if(ccs.OWN_CCS_Ownership_items__c=='Fail'){
             ownfail = ownfail + 1;}else{}
             } 
             if(ownpass != 0 || ownfail != 0)    {
             ownscore = ownpass/(ownpass+ownfail);   
             if(ownscore>=0.5){
             ccs.OWN_result__c='Pass';} else {ccs.OWN_result__c='Fail';}  
             }  else {   ccs.OWN_result__c='N/A';}  
             }
         // LISTEN CALCULATION AND RESULT
             if(ccs.LISTEN_Actively_listened__c=='Pass'){
             listenpass = 1;}else{
             if(ccs.LISTEN_Actively_listened__c=='Fail'){
             listenfail = 1;}else{}
             }

             if(ccs.LISTEN_Restated_understanding_of_issue__c=='Pass'){
             listenpass = listenpass + 1;}else{
             if(ccs.LISTEN_Restated_understanding_of_issue__c=='Fail'){
             listenfail = listenfail + 1;}else{}
             }

             if(ccs.LISTEN_Addressed_all_issues_and_concerns__c=='Pass'){
             listenpass = listenpass + 1;}else{
             if(ccs.LISTEN_Addressed_all_issues_and_concerns__c=='Fail'){
             listenfail = listenfail + 1;}else{}
             }

             if(ccs.LISTEN_Did_not_ask_customer_to_repeat_in__c=='Pass'){
             listenpass = listenpass + 1;}else{
             if(ccs.LISTEN_Did_not_ask_customer_to_repeat_in__c=='Fail'){
             listenfail = listenfail + 1;}else{}
             }             

             if(ccs.LISTEN_Did_not_interrupt_the_customer__c=='Pass'){
             listenpass = listenpass + 1;}else{
             if(ccs.LISTEN_Did_not_interrupt_the_customer__c=='Fail'){
             listenfail = listenfail + 1;}else{}
             }
             if(listenpass != 0 || listenfail != 0)    {
                 listenscore = listenpass/(listenpass+listenfail);   
             if(listenscore>=0.5){
             ccs.LISTEN_result__c='Pass';} else {ccs.LISTEN_result__c='Fail';}  
             }  else {   ccs.LISTEN_result__c='N/A';}
                 

         // SKILLS CALCULATION AND RESULT
             if(ccs.SKILLS_Projected_pleasant_upbeat_tone__c=='Pass'){
             skillspass = 1;}else{
             if(ccs.SKILLS_Projected_pleasant_upbeat_tone__c=='Fail'){
             skillsfail = 1;}else{}
             }
             
             if(ccs.SKILLS_Kept_a_good_pace_during_call__c=='Pass'){
             skillspass = skillspass + 1;}else{
             if(ccs.SKILLS_Kept_a_good_pace_during_call__c=='Fail'){
             skillsfail = skillsfail + 1;}else{}
             }

             if(ccs.SKILLS_Performed_a_warm_transfer__c=='Pass'){
             skillspass = skillspass + 1;}else{
             if(ccs.SKILLS_Performed_a_warm_transfer__c=='Fail'){
             skillsfail = skillsfail + 1;}else{}
             }

             if(ccs.SKILLS_Spoke_clearly__c=='Pass'){
             skillspass = skillspass + 1;}else{
             if(ccs.SKILLS_Spoke_clearly__c=='Fail'){
             skillsfail = skillsfail + 1;}else{}
             }

             if(ccs.SKILLS_Minimal_dead_air_time__c=='Pass'){
             skillspass = skillspass + 1;}else{
             if(ccs.SKILLS_Minimal_dead_air_time__c=='Fail'){
             skillsfail = skillsfail + 1;}else{}
             }

             if(ccs.SKILLS_Well_formed_written_communication__c=='Pass'){
             skillspass = skillspass + 1;}else{
             if(ccs.SKILLS_Well_formed_written_communication__c=='Fail'){
             skillsfail = skillsfail + 1;}else{}
             }
             if(skillspass != 0 || skillsfail != 0)    {
             skillsscore = skillspass/(skillspass+skillsfail);   
             if(skillsscore>=0.5){
             ccs.SKILLS_result__c='Pass';} else {ccs.SKILLS_result__c='Fail';}  
             }  else {   ccs.SKILLS_result__c='N/A';}

         // ACCURATE CALCULATION AND RESULT

             if(ccs.ACCURATE_Used_available_resources__c=='Fail'){         
             ccs.ACCURATE_result__c='Fail';}                  
                 else {
             if(ccs.ACCURATE_Used_available_resources__c=='Pass'){
             accuratepass = 1;}else{
             if(ccs.ACCURATE_Used_available_resources__c=='Fail'){
             accuratefail = 1;}else{}
             }

             if(ccs.ACCURATE_Followed_proper_procedure__c=='Pass'){
             accuratepass = accuratepass + 1;}else{
             if(ccs.ACCURATE_Followed_proper_procedure__c=='Fail'){
             accuratefail = accuratefail + 1;}else{}
             }

             if(ccs.ACCURATE_1_call_case_resolution__c=='Pass'){
             accuratepass = accuratepass + 1;}else{
             if(ccs.ACCURATE_1_call_case_resolution__c=='Fail'){
             accuratefail = accuratefail + 1;}else{}
             }
             if(accuratepass != 0 || accuratefail != 0)    {
             accuratescore = accuratepass/(accuratepass+accuratefail);   
             if(accuratescore>=0.5){
             ccs.ACCURATE_result__c='Pass';} else {ccs.ACCURATE_result__c='Fail';}  
             }  else {   ccs.ACCURATE_result__c='N/A';}
             }
         // CLOSING CALCULATION AND RESULT
             if(ccs.CLOSING_Summarized_actions_taken__c=='Pass'){
             closingpass = 1;}else{
             if(ccs.CLOSING_Summarized_actions_taken__c=='Fail'){
             closingfail = 1;}else{}
             }

             if(ccs.CLOSING_Advised_next_steps__c=='Pass'){
             closingpass = closingpass + 1;}else{
             if(ccs.CLOSING_Advised_next_steps__c=='Fail'){
             closingfail = closingfail + 1;}else{}
             }

             if(ccs.CLOSING_Thanked_the_Customer__c=='Pass'){
             closingpass = closingpass + 1;}else{
             if(ccs.CLOSING_Thanked_the_Customer__c=='Fail'){
             closingfail = closingfail + 1;}else{}
             }

             if(ccs.CLOSING_Offered_additional_assistance__c=='Pass'){
             closingpass = closingpass + 1;}else{
             if(ccs.CLOSING_Offered_additional_assistance__c=='Fail'){
             closingfail = closingfail + 1;}else{}
             }

             if(ccs.CLOSING_Categorized_the_case_correctly__c=='Pass'){
             closingpass = closingpass + 1;}else{
             if(ccs.CLOSING_Categorized_the_case_correctly__c=='Fail'){
             closingfail = closingfail + 1;}else{}
             }
             if(closingpass != 0 || closingfail != 0)    {
             closingscore = closingpass/(closingpass+closingfail);   
             if(closingscore>=0.5){
             ccs.CLOSING_result__c='Pass';} else {ccs.CLOSING_result__c='Fail';}  
             }  else {   ccs.CLOSING_result__c='N/A';}

         // DOC CALCULATION AND RESULT

            if(ccs.DOC_Included_detailed_and_accurate_notes__c=='Fail'){         
             ccs.DOC_result__c='Fail';
            }                  
            else {
                if(ccs.DOC_Included_detailed_and_accurate_notes__c=='Pass'){
                docpass = 1.0;
                }
                else{
                 if(ccs.DOC_Included_detailed_and_accurate_notes__c=='Fail'){
                    docfail = 1.0;
                 }else{}
                } 
                 if(ccs.DOC_Case_completed_correctly__c=='Pass'){
                    docpass = docpass + 1;}
                    else{
                     if(ccs.DOC_Case_completed_correctly__c=='Fail'){
                        docfail = docfail + 1;
                     }else{}
                 }             
                 if(ccs.DOC_Used_proper_grammar_spelling__c=='Pass'){
                    docpass = docpass + 1;
                 }
                 else{
                    if(ccs.DOC_Used_proper_grammar_spelling__c=='Fail'){
                     docfail = docfail + 1;
                     }else{}
                 } 
                  
                 if(docpass != 0 || docfail != 0)    { 
                  // System.debug('docpass: '+docpass);
                  // System.debug('docfail: '+docfail);    
                     docscore = docpass/(docpass+docfail);
                  // System.debug('docscore : '+(docpass/(docpass+docfail)));
                  // System.debug('ccs : '+ccs);
                 
                    
                  if(docscore>=0.5){
                  ccs.DOC_result__c='Pass';} else {ccs.DOC_result__c='Fail';}  
                  }  else {   ccs.DOC_result__c='N/A';}
                  }
 
 
        //  FINAL SCORE AND RESULT
            if(ccs.GREET_Verified_customer_information__c=='Fail'||ccs.OWN_CCS_Ownership_items__c=='Fail'||ccs.ACCURATE_Used_available_resources__c=='Fail'||ccs.DOC_Included_detailed_and_accurate_notes__c=='Fail'){
            ccs.FINAL_result__c='Fail';}
                else {
                    if(ccs.GREET_result__c == 'Pass'){finalpass =1;} else{if(ccs.GREET_result__c == 'Fail'){finalfail =1;}}
                    if(ccs.CARE_result__c == 'Pass'){finalpass = finalpass+1;} else{if(ccs.CARE_result__c == 'Fail'){finalfail = finalfail+ 1;}}
                    if(ccs.OWN_result__c == 'Pass'){finalpass = finalpass+1;} else{if(ccs.OWN_result__c == 'Fail'){finalfail = finalfail+ 1;}}
                    if(ccs.LISTEN_result__c == 'Pass'){finalpass = finalpass+1;} else{if(ccs.LISTEN_result__c == 'Fail'){finalfail = finalfail+ 1;}}
                    if(ccs.SKILLS_result__c == 'Pass'){finalpass = finalpass+1;} else{if(ccs.SKILLS_result__c == 'Fail'){finalfail = finalfail+ 1;}}
                    if(ccs.ACCURATE_result__c == 'Pass'){finalpass = finalpass+1;} else{if(ccs.ACCURATE_result__c == 'Fail'){finalfail = finalfail+ 1;}}
                    if(ccs.CLOSING_result__c == 'Pass'){finalpass = finalpass+1;} else{if(ccs.CLOSING_result__c == 'Fail'){finalfail = finalfail+ 1;}}
                    if(ccs.DOC_result__c == 'Pass'){finalpass = finalpass+1;} else{if(ccs.DOC_result__c == 'Fail'){finalfail = finalfail+ 1;}}

                    if(finalpass != 0 || finalfail != 0)    {
                    finalscore = finalpass/(finalpass+finalfail);   
                    if(finalscore>=0.5){
                    ccs.FINAL_result__c='Pass';} else {ccs.FINAL_result__c='Fail';}  
                    }  else {   ccs.FINAL_result__c='N/A';}
                    }
                    
    }
        
        
    }
}