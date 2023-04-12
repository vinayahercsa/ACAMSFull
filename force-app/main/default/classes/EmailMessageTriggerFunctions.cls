/**
 * 
 * @ Description : Class will create new case if the old case status is closed
 * @ Created : Kumar
 * @ Date    : 1/12/2016
 * @ 
 * Modification log
 * ---------------------------------------------------
 * Date     Author      Description
 * 
 */
public class EmailMessageTriggerFunctions {
    
    // Method to create case from email to case 
  
  public static void createChildCase(List<EmailMessage> newEmailMsgList){
  
  Set<ID> caseIDSet = new Set<ID>();
  Set<ID> emailSet = new Set<ID>();
  Map<ID,EmailMessage> caseEmailMsgMap = new Map<ID,EmailMessage>();
  List<case> caseInsList = new List<case>();
  List<EmailMessage> emailMsgInsList = new List<EmailMessage>();

  
   // Getting parent case IDs   
        for (EmailMessage emailMsgObj : newEmailMsgList) {
            if(emailMsgObj.parentid != null){
                if(((String)emailMsgObj.parentid).startsWith('500') && emailMsgObj.Incoming){
                  
                    caseIDSet.add(emailMsgObj.parentid); 
                    caseEmailMsgMap.put(emailMsgObj.parentid,emailMsgObj);            
                }
            }
        }   
                
            if(caseIDSet.size()>0){
            for(Case csInsc:[SELECT id, isClosed, Type, Subject,Description, ContactID, SuppliedEmail, SuppliedName, SuppliedPhone, SuppliedCompany, Origin FROM Case WHERE id in:caseIDSet and IsClosed =true ])
                {           
            
                  
                    Case childCase = new Case();
                    childCase.parentid=csInsc.id;  
                    if(caseEmailMsgMap.get(csInsc.id).Subject.length() > 232)
                    {
                        childCase.subject='NEW CASE NOTIFICATION -'+ caseEmailMsgMap.get(csInsc.id).Subject.substring(0,232);//csInsc.subject;
                    }
                    else
                    {
                         childCase.subject='NEW CASE NOTIFICATION -'+ caseEmailMsgMap.get(csInsc.id).Subject;
                    }
                    childCase.description=caseEmailMsgMap.get(csInsc.id).TextBody;
                    //if(!String.isBlank(csInsc.Origin))
                    //{
                    //    childCase.Origin = csInsc.Origin;
                    //}
                    
                    if(!String.isBlank(csInsc.Origin))
                    {
                        if(csInsc.Origin=='Email - Europe')
                        {
                            childCase.Origin = csInsc.Origin;
                        }
                    }
                    
                    if(String.isBlank(caseEmailMsgMap.get(csInsc.id).CcAddress)&&String.isBlank(caseEmailMsgMap.get(csInsc.id).BccAddress))
                    {
                        if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('europe@acams.org'))
                        {
                            childCase.Origin = 'Email - Europe';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('enterprise@acams.org'))
                        {
                            childCase.Origin = 'Email - Enterprise';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('chapters@acams.org'))
                        {
                            childCase.Origin = 'Email - Chapters';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('asia@acams.org'))
                        {
                            childCase.Origin = 'Email - Asia';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('prioritycases@acams.org'))
                        {
                            childCase.Origin = 'Email - PriorityCase';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('certification@acams.org'))
                        {
                            childCase.Origin = 'Email - Certification';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('groupexams@acams.org'))
                        {
                            childCase.Origin = 'Email - Certification';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('sfolder@acams.org'))
                        {
                            childCase.Origin = 'Email - SFolder';
                        }
                        else  //info@acams.org and prioritycases@acams.org
                        {
                            childCase.Origin = 'Email - Info';
                        }}}}}}}}
                    }
                    else { if(String.isBlank(caseEmailMsgMap.get(csInsc.id).CcAddress))
                    {
                        if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('europe@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('europe@acams.org'))
                        {
                            childCase.Origin = 'Email - Europe';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('enterprise@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('enterprise@acams.org'))
                        {
                            childCase.Origin = 'Email - Enterprise';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('chapters@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('chapters@acams.org'))
                        {
                            childCase.Origin = 'Email - Chapters';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('asia@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('asia@acams.org'))
                        {
                            childCase.Origin = 'Email - Asia';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('prioritycases@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('prioritycases@acams.org'))
                        {
                            childCase.Origin = 'Email - PriorityCase';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('certification@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('certification@acams.org'))
                        {
                            childCase.Origin = 'Email - Certification';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('groupexams@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('groupexams@acams.org'))
                        {
                            childCase.Origin = 'Email - Certification';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('sfolder@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('sfolder@acams.org'))
                        {
                            childCase.Origin = 'Email - SFolder';
                        }
                        else  //info@acams.org and prioritycases@acams.org
                        {
                            childCase.Origin = 'Email - Info';
                        }}}}}}}  }                  
                    }
                    else { if(String.isBlank(caseEmailMsgMap.get(csInsc.id).BccAddress))
                    {
                        if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('europe@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('europe@acams.org'))
                        {
                            childCase.Origin = 'Email - Europe';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('enterprise@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('enterprise@acams.org'))
                        {
                            childCase.Origin = 'Email - Enterprise';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('chapters@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('chapters@acams.org'))
                        {
                            childCase.Origin = 'Email - Chapters';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('asia@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('asia@acams.org'))
                        {
                            childCase.Origin = 'Email - Asia';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('prioritycases@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('prioritycases@acams.org'))
                        {
                            childCase.Origin = 'Email - PriorityCase';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('certification@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('certification@acams.org'))
                        {
                            childCase.Origin = 'Email - Certification';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('groupexams@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('groupexams@acams.org'))
                        {
                            childCase.Origin = 'Email - Certification';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('sfolder@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('sfolder@acams.org'))
                        {
                            childCase.Origin = 'Email - SFolder';
                        }
                        else  //info@acams.org and prioritycases@acams.org
                        {
                            childCase.Origin = 'Email - Info';
                        }}}}}}}}
                    }
                    else {
                        if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('europe@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('europe@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('europe@acams.org'))
                        {
                            childCase.Origin = 'Email - Europe';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('enterprise@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('enterprise@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('enterprise@acams.org'))
                        {
                            childCase.Origin = 'Email - Enterprise';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('chapters@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('chapters@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('chapters@acams.org'))
                        {
                            childCase.Origin = 'Email - Chapters';
                        }
                          else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('asia@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('asia@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('asia@acams.org'))
                        {
                            childCase.Origin = 'Email - Asia';
                        }
                          else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('prioritycases@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('prioritycases@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('prioritycases@acams.org'))
                        {
                            childCase.Origin = 'Email - PriorityCase';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('certification@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('certification@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('certification@acams.org'))
                        {
                            childCase.Origin = 'Email - Certification';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('groupexams@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('groupexams@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('groupexams@acams.org'))
                        {
                            childCase.Origin = 'Email - Certification';
                        }
                        else { if(caseEmailMsgMap.get(csInsc.id).ToAddress.contains('sfolder@acams.org')||caseEmailMsgMap.get(csInsc.id).CcAddress.contains('sfolder@acams.org')||caseEmailMsgMap.get(csInsc.id).BccAddress.contains('sfolder@acams.org'))
                        {
                            childCase.Origin = 'Email - SFolder';
                        }
                        else  //info@acams.org and prioritycases@acams.org
                        {
                            childCase.Origin = 'Email - Info';
                        }}}}}}}}
                    }}}
              
                    if(!String.isBlank(csInsc.ContactID))
                    {
                        childCase.contactid=csInsc.ContactID;
                    }
                    if(!String.isBlank(caseEmailMsgMap.get(csInsc.id).FromAddress))
                    {
                        childCase.SuppliedEmail=caseEmailMsgMap.get(csInsc.id).FromAddress;
                    }
                    if(!String.isBlank(caseEmailMsgMap.get(csInsc.id).FromName))
                    {
                        childCase.SuppliedName=caseEmailMsgMap.get(csInsc.id).FromName;
                    }
                    caseInsList.add(childCase);
                }                 
            }    
                if(caseInsList!=null && !caseInsList.isEmpty())
                 {
                   try
                   {
                    
                      insert caseInsList;
                   
                    for(case childCaseInsc : caseInsList)
                        {
                          EmailMessage emailMsg = new EmailMessage();
                         emailMsg.ParentId = childCaseInsc.id;
                         emailMsg.BccAddress = caseEmailMsgMap.get(childCaseInsc.parentid).BccAddress;
                         emailMsg.CcAddress = caseEmailMsgMap.get(childCaseInsc.parentid).CcAddress;
                         emailMsg.FromAddress = caseEmailMsgMap.get(childCaseInsc.parentid).FromAddress;
                         emailMsg.FromName = caseEmailMsgMap.get(childCaseInsc.parentid).FromName;
                         emailMsg.HtmlBody = caseEmailMsgMap.get(childCaseInsc.parentid).HtmlBody;
                         //emailMsg.HasAttachment = caseEmailMsgMap.get(childCaseInsc.parentid).HasAttachment;
                         emailMsg.Headers = caseEmailMsgMap.get(childCaseInsc.parentid).Headers;
                         emailMsg.Incoming = caseEmailMsgMap.get(childCaseInsc.parentid).Incoming;
                         emailMsg.MessageDate = caseEmailMsgMap.get(childCaseInsc.parentid).MessageDate;
                         emailMsg.Status = caseEmailMsgMap.get(childCaseInsc.parentid).Status;
                         emailMsg.Subject = caseEmailMsgMap.get(childCaseInsc.parentid).Subject;
                         emailMsg.TextBody = caseEmailMsgMap.get(childCaseInsc.parentid).TextBody;
                         emailMsg.ToAddress = caseEmailMsgMap.get(childCaseInsc.parentid).ToAddress;
                         emailMsgInsList.add(emailMsg);
                        }
                     
                        if(emailMsgInsList!=null && !emailMsgInsList.isEmpty())
                           insert emailMsgInsList;
                    }
                   catch(exception e)
                   {
                      system.debug('exception 7777'+e);
                   }
                }
            }
 

}