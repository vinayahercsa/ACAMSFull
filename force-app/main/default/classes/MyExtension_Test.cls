@isTest
public class MyExtension_Test {
    static testMethod void testMyextension(){
        Case objcase = new Case();
        objcase.status = 'New';
        objcase.Subject = 'Test Subject';
        objcase.Origin = 'Chat';
        insert objcase;
        
        Contact_Center_Scorecard__c scoreCard = new Contact_Center_Scorecard__c();
        scoreCard.case__c = objcase.Id;
        insert scoreCard;
        
        Test.startTest();
            Apexpages.StandardController sc = new Apexpages.StandardController(scoreCard);
            MyExtension ext = new MyExtension(sc);
            ext.saveandredirectcase();
            ext.saveAndredirectphone();
            ext.recalculatecase();
            ext.recalculatephone();
            //save
            sc.save();
            ext.saveAndredirectcase();
            ext.saveAndredirectphone();
            //Edit
            sc.edit();
            ext.recalculatecase();
        	ext.recalculatephone();
        Test.stopTest();
    }
}