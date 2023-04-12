/**
 * 
 * @ Description : Class will test the functionality to create new case and clone the closed case attachment to new case.
 * @ Created : Kumar
 * @ Date    : 1/12/2016
 * @ 
 * Modification log
 * ---------------------------------------------------
 * Date     Author      Description
 * 
 */
@isTest
public class TestEmailMessageTriggerFunctions {
    public static testmethod void createChildCaseTest(){

    Test.startTest();
    // insert case record
    Case parentCase = new Case();
    parentCase.subject='NEW CASE NOTIFICATION -clone NEW CASE NOTIFICATION -clone NEW CASE NOTIFICATION';
    parentCase.description='test description';
    parentCase.Origin='Email - Europe';
    parentCase.Type = 'Urgent';

    insert parentCase;

    // insert email message

    EmailMessage emailMsg = new EmailMessage();
    emailMsg.ParentId = parentCase.id;
    emailMsg.FromAddress = 'test@gmail.com';
    emailMsg.Incoming = false;
    emailMsg.ToAddress = 'europe@acams.org';
    emailMsg.MessageDate = System.TODAY();
    emailMsg.Subject = 'test email';
    emailMsg.TextBody = 'test email body';
   // emailMsg.ToAddress = 'test232@gmail.com';

    insert emailMsg;

    // update case static
    parentCase.status = 'closed';
    update parentCase;

    // inserting email reply to closed case 
                                                     
    EmailMessage emailReplyMsg = new EmailMessage();
    emailReplyMsg.ParentId = parentCase.id;
    emailReplyMsg.FromAddress = 'test@gmail.com';
    emailReplyMsg.Incoming = true;
    emailReplyMsg.MessageDate = System.TODAY();
    emailReplyMsg.Subject = 'test email';
    emailReplyMsg.TextBody = 'test email body';
    emailReplyMsg.ToAddress = 'enterprise@acams.org';
    //emailReplyMsg.status = 'replied';
    insert emailReplyMsg;

    List<EmailMessage> testCasesMsg = new List<EmailMessage>();

    EmailMessage chapterMsg = new EmailMessage();
    chapterMsg.ParentId = parentCase.id;
    chapterMsg.FromAddress = 'test@gmail.com';
    chapterMsg.Incoming = true;
    chapterMsg.MessageDate = System.TODAY();
    chapterMsg.Subject = 'test email';
    chapterMsg.TextBody = 'test email body';
    chapterMsg.ToAddress = 'asia@acams.org';
    //emailReplyMsg.status = 'replied';
    testCasesMsg.add(chapterMsg);

    EmailMessage priorityMsg = new EmailMessage();
    priorityMsg.ParentId = parentCase.id;
    priorityMsg.FromAddress = 'test@gmail.com';
    priorityMsg.Incoming = true;
    priorityMsg.MessageDate = System.TODAY();
    priorityMsg.Subject = 'test email';
    priorityMsg.TextBody = 'test email body';
    priorityMsg.ToAddress = 'prioritycases@acams.org';
    //emailReplyMsg.status = 'replied';
    testCasesMsg.add(priorityMsg);

    EmailMessage certMsg = new EmailMessage();
    certMsg.ParentId = parentCase.id;
    certMsg.FromAddress = 'test@gmail.com';
    certMsg.Incoming = true;
    certMsg.MessageDate = System.TODAY();
    certMsg.Subject = 'test email';
    certMsg.TextBody = 'test email body';
    certMsg.ToAddress = 'certification@acams.org';
    testCasesMsg.add(certMsg);
    
    EmailMessage sfoldMsg = new EmailMessage();
    sfoldMsg.ParentId = parentCase.id;
    sfoldMsg.FromAddress = 'test@gmail.com';
    sfoldMsg.Incoming = true;
    sfoldMsg.MessageDate = System.TODAY();
    sfoldMsg.Subject = 'test email';
    sfoldMsg.TextBody = 'test email body';
    sfoldMsg.ToAddress = 'sfolder@acams.org';
    testCasesMsg.add(sfoldMsg);
    

    for(EmailMessage m : testCasesMsg){
        insert m;
    }

    
    Attachment attachment = new Attachment();
    attachment.Body = Blob.valueOf('test body wewe');
    attachment.Name = String.valueOf('test.txt');
    attachment.ParentId = emailReplyMsg.ID; 
    insert attachment;

    Test.stopTest();
                  
    }

    public static testmethod void createChildCaseTestWithFillBccAddr(){
        Test.startTest();
         // insert case record
    Case parentCase = new Case();
    parentCase.subject='NEW CASE NOTIFICATION -clone NEW CASE NOTIFICATION -clone NEW CASE NOTIFICATION';
    parentCase.description='test description';
    parentCase.Origin='Email - Europe';
    parentCase.Type = 'Urgent';

    insert parentCase;

    // insert email message

    EmailMessage emailMsg = new EmailMessage();
    emailMsg.ParentId = parentCase.id;
    emailMsg.FromAddress = 'test@gmail.com';
    emailMsg.Incoming = false;
    emailMsg.ToAddress = 'europe@acams.org';
    emailMsg.MessageDate = System.TODAY();
    emailMsg.Subject = 'test email';
    emailMsg.TextBody = 'test email body';
   // emailMsg.ToAddress = 'test232@gmail.com';

    insert emailMsg;

    // update case static
    parentCase.status = 'closed';
    update parentCase;

    // inserting email reply to closed case 
                                                     
    EmailMessage emailReplyMsg = new EmailMessage();
    emailReplyMsg.ParentId = parentCase.id;
    emailReplyMsg.FromAddress = 'test@gmail.com';
    emailReplyMsg.Incoming = true;
    emailReplyMsg.MessageDate = System.TODAY();
    emailReplyMsg.Subject = 'test email';
    emailReplyMsg.TextBody = 'test email body';
    emailReplyMsg.ToAddress = 'enterprise@acams.org';
    emailReplyMsg.BccAddress = 'test@address.com';
    //emailReplyMsg.status = 'replied';
    insert emailReplyMsg;

    List<EmailMessage> testCasesMsg = new List<EmailMessage>();

    EmailMessage chapterMsg = new EmailMessage();
    chapterMsg.ParentId = parentCase.id;
    chapterMsg.FromAddress = 'test@gmail.com';
    chapterMsg.Incoming = true;
    chapterMsg.MessageDate = System.TODAY();
    chapterMsg.Subject = 'test email';
    chapterMsg.TextBody = 'test email body';
    chapterMsg.ToAddress = 'asia@acams.org';
    chapterMsg.BccAddress = 'test@address.com';
    //emailReplyMsg.status = 'replied';
    testCasesMsg.add(chapterMsg);

    EmailMessage priorityMsg = new EmailMessage();
    priorityMsg.ParentId = parentCase.id;
    priorityMsg.FromAddress = 'test@gmail.com';
    priorityMsg.Incoming = true;
    priorityMsg.MessageDate = System.TODAY();
    priorityMsg.Subject = 'test email';
    priorityMsg.TextBody = 'test email body';
    priorityMsg.ToAddress = 'prioritycases@acams.org';
    priorityMsg.BccAddress = 'test@address.com';
    //emailReplyMsg.status = 'replied';
    testCasesMsg.add(priorityMsg);

    EmailMessage certMsg = new EmailMessage();
    certMsg.ParentId = parentCase.id;
    certMsg.FromAddress = 'test@gmail.com';
    certMsg.Incoming = true;
    certMsg.MessageDate = System.TODAY();
    certMsg.Subject = 'test email';
    certMsg.TextBody = 'test email body';
    certMsg.ToAddress = 'certification@acams.org';
    certMsg.BccAddress = 'test@address.com';
    testCasesMsg.add(certMsg);
    
    EmailMessage sfoldMsg = new EmailMessage();
    sfoldMsg.ParentId = parentCase.id;
    sfoldMsg.FromAddress = 'test@gmail.com';
    sfoldMsg.Incoming = true;
    sfoldMsg.MessageDate = System.TODAY();
    sfoldMsg.Subject = 'test email';
    sfoldMsg.TextBody = 'test email body';
    sfoldMsg.ToAddress = 'sfolder@acams.org';
    sfoldMsg.BccAddress = 'test@address.com';
    testCasesMsg.add(sfoldMsg);
    

    for(EmailMessage m : testCasesMsg){
        insert m;
    }
    Test.stopTest();
    }


    public static testmethod void createChildCaseTestWithFillccAddr(){
        Test.startTest();
         // insert case record
    Case parentCase = new Case();
    parentCase.subject='NEW CASE NOTIFICATION -clone NEW CASE NOTIFICATION -clone NEW CASE NOTIFICATION';
    parentCase.description='test description';
    parentCase.Origin='Email - Europe';
    parentCase.Type = 'Urgent';

    insert parentCase;

    // insert email message

    EmailMessage emailMsg = new EmailMessage();
    emailMsg.ParentId = parentCase.id;
    emailMsg.FromAddress = 'test@gmail.com';
    emailMsg.Incoming = false;
    emailMsg.ToAddress = 'europe@acams.org';
    emailMsg.MessageDate = System.TODAY();
    emailMsg.Subject = 'test email';
    emailMsg.TextBody = 'test email body';
   // emailMsg.ToAddress = 'test232@gmail.com';

    insert emailMsg;

    // update case static
    parentCase.status = 'closed';
    update parentCase;

    // inserting email reply to closed case 
                                                     
    EmailMessage emailReplyMsg = new EmailMessage();
    emailReplyMsg.ParentId = parentCase.id;
    emailReplyMsg.FromAddress = 'test@gmail.com';
    emailReplyMsg.Incoming = true;
    emailReplyMsg.MessageDate = System.TODAY();
    emailReplyMsg.Subject = 'test email';
    emailReplyMsg.TextBody = 'test email body';
    emailReplyMsg.ToAddress = 'enterprise@acams.org';
    emailReplyMsg.CcAddress = 'europe@acams.org';
    //emailReplyMsg.status = 'replied';
    insert emailReplyMsg;

    List<EmailMessage> testCasesMsg = new List<EmailMessage>();

    EmailMessage chapterMsg = new EmailMessage();
    chapterMsg.ParentId = parentCase.id;
    chapterMsg.FromAddress = 'test@gmail.com';
    chapterMsg.Incoming = true;
    chapterMsg.MessageDate = System.TODAY();
    chapterMsg.Subject = 'test email';
    chapterMsg.TextBody = 'test email body';
    chapterMsg.ToAddress = 'asia@acams.org';
    chapterMsg.CcAddress = 'enterprise@acams.org';
    //emailReplyMsg.status = 'replied';
    testCasesMsg.add(chapterMsg);

    EmailMessage priorityMsg = new EmailMessage();
    priorityMsg.ParentId = parentCase.id;
    priorityMsg.FromAddress = 'test@gmail.com';
    priorityMsg.Incoming = true;
    priorityMsg.MessageDate = System.TODAY();
    priorityMsg.Subject = 'test email';
    priorityMsg.TextBody = 'test email body';
    priorityMsg.ToAddress = 'prioritycases@acams.org';
    priorityMsg.CcAddress = 'chapters@acams.org';
    //emailReplyMsg.status = 'replied';
    testCasesMsg.add(priorityMsg);

    EmailMessage certMsg = new EmailMessage();
    certMsg.ParentId = parentCase.id;
    certMsg.FromAddress = 'test@gmail.com';
    certMsg.Incoming = true;
    certMsg.MessageDate = System.TODAY();
    certMsg.Subject = 'test email';
    certMsg.TextBody = 'test email body';
    certMsg.ToAddress = 'certification@acams.org';
    certMsg.CcAddress = 'asia@acams.org';
    testCasesMsg.add(certMsg);
    
    EmailMessage sfoldMsg = new EmailMessage();
    sfoldMsg.ParentId = parentCase.id;
    sfoldMsg.FromAddress = 'test@gmail.com';
    sfoldMsg.Incoming = true;
    sfoldMsg.MessageDate = System.TODAY();
    sfoldMsg.Subject = 'test email';
    sfoldMsg.TextBody = 'test email body';
    sfoldMsg.ToAddress = 'sfolder@acams.org';
    sfoldMsg.CcAddress = 'prioritycases@acams.org';
    testCasesMsg.add(sfoldMsg);

    EmailMessage certfMsg = new EmailMessage();
    certfMsg.ParentId = parentCase.id;
    certfMsg.FromAddress = 'test@gmail.com';
    certfMsg.Incoming = true;
    certfMsg.MessageDate = System.TODAY();
    certfMsg.Subject = 'test email';
    certfMsg.TextBody = 'test email body';
    certfMsg.ToAddress = 'sfolder@acams.org';
    certfMsg.CcAddress = 'certification@acams.org';
    testCasesMsg.add(certfMsg);
    

    for(EmailMessage m : testCasesMsg){
        insert m;
    }
    Test.stopTest();
    }


    
    public static testmethod void createChildCaseTestWithFillccBccAddr(){
        Test.startTest();
         // insert case record
    Case parentCase = new Case();
    parentCase.subject='NEW CASE NOTIFICATION -clone NEW CASE NOTIFICATION -clone NEW CASE NOTIFICATION';
    parentCase.description='test description';
    parentCase.Origin='Email - Europe';
    parentCase.Type = 'Urgent';

    insert parentCase;

    // insert email message

    EmailMessage emailMsg = new EmailMessage();
    emailMsg.ParentId = parentCase.id;
    emailMsg.FromAddress = 'test@gmail.com';
    emailMsg.Incoming = false;
    emailMsg.ToAddress = 'europe@acams.org';
    emailMsg.MessageDate = System.TODAY();
    emailMsg.Subject = 'test email';
    emailMsg.TextBody = 'test email body';
   // emailMsg.ToAddress = 'test232@gmail.com';

    insert emailMsg;

    // update case static
    parentCase.status = 'closed';
    update parentCase;

    // inserting email reply to closed case 
                                                     
    EmailMessage emailReplyMsg = new EmailMessage();
    emailReplyMsg.ParentId = parentCase.id;
    emailReplyMsg.FromAddress = 'test@gmail.com';
    emailReplyMsg.Incoming = true;
    emailReplyMsg.MessageDate = System.TODAY();
    emailReplyMsg.Subject = 'test email';
    emailReplyMsg.TextBody = 'test email body';
    emailReplyMsg.ToAddress = 'enterprise@acams.org';
    emailReplyMsg.CcAddress = 'europe@acams.org';
    emailReplyMsg.BccAddress = 'europe@acams.org';
    //emailReplyMsg.status = 'replied';
    insert emailReplyMsg;

    List<EmailMessage> testCasesMsg = new List<EmailMessage>();

    EmailMessage chapterMsg = new EmailMessage();
    chapterMsg.ParentId = parentCase.id;
    chapterMsg.FromAddress = 'test@gmail.com';
    chapterMsg.Incoming = true;
    chapterMsg.MessageDate = System.TODAY();
    chapterMsg.Subject = 'test email';
    chapterMsg.TextBody = 'test email body';
    chapterMsg.ToAddress = 'asia@acams.org';
    chapterMsg.CcAddress = 'enterprise@acams.org';
    chapterMsg.BccAddress = 'enterprise@acams.org';
    //emailReplyMsg.status = 'replied';
    testCasesMsg.add(chapterMsg);

    EmailMessage priorityMsg = new EmailMessage();
    priorityMsg.ParentId = parentCase.id;
    priorityMsg.FromAddress = 'test@gmail.com';
    priorityMsg.Incoming = true;
    priorityMsg.MessageDate = System.TODAY();
    priorityMsg.Subject = 'test email';
    priorityMsg.TextBody = 'test email body';
    priorityMsg.ToAddress = 'prioritycases@acams.org';
    priorityMsg.CcAddress = 'chapters@acams.org';
    priorityMsg.BccAddress = 'chapters@acams.org';
    //emailReplyMsg.status = 'replied';
    testCasesMsg.add(priorityMsg);

    EmailMessage certMsg = new EmailMessage();
    certMsg.ParentId = parentCase.id;
    certMsg.FromAddress = 'test@gmail.com';
    certMsg.Incoming = true;
    certMsg.MessageDate = System.TODAY();
    certMsg.Subject = 'test email';
    certMsg.TextBody = 'test email body';
    certMsg.ToAddress = 'certification@acams.org';
    certMsg.CcAddress = 'asia@acams.org';
    certMsg.BccAddress = 'asia@acams.org';
    testCasesMsg.add(certMsg);
    
    EmailMessage sfoldMsg = new EmailMessage();
    sfoldMsg.ParentId = parentCase.id;
    sfoldMsg.FromAddress = 'test@gmail.com';
    sfoldMsg.Incoming = true;
    sfoldMsg.MessageDate = System.TODAY();
    sfoldMsg.Subject = 'test email';
    sfoldMsg.TextBody = 'test email body';
    sfoldMsg.ToAddress = 'sfolder@acams.org';
    sfoldMsg.CcAddress = 'prioritycases@acams.org';
    sfoldMsg.BccAddress = 'prioritycases@acams.org';
    testCasesMsg.add(sfoldMsg);

    EmailMessage certfMsg = new EmailMessage();
    certfMsg.ParentId = parentCase.id;
    certfMsg.FromAddress = 'test@gmail.com';
    certfMsg.Incoming = true;
    certfMsg.MessageDate = System.TODAY();
    certfMsg.Subject = 'test email';
    certfMsg.TextBody = 'test email body';
    certfMsg.ToAddress = 'sfolder@acams.org';
    certfMsg.CcAddress = 'certification@acams.org';
    certfMsg.BccAddress = 'certification@acams.org';
    testCasesMsg.add(certfMsg);
    

    for(EmailMessage m : testCasesMsg){
        insert m;
    }
    Test.stopTest();
    }


}