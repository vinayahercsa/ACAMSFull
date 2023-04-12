@RestResource(UrlMapping='/api/email/resendOrder')
global with sharing class ACAMSResendOrderConfirmation {

    @HttpGet
    global static Boolean send() {
        Id orderId = RestContext.request.params.get('orderId');
        String email = RestContext.request.params.get('email');
        String ccEmail = RestContext.request.params.get('ccEmail');
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ACAMS_Order_Confirmation'];
        // TODO:  CHANGE TO CORRECT EMAIL ADDRESS: noresponse@acams.org
        OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE Address = 'dmitry.khalabuda@avionos.com' LIMIT 1];
        ccrz__E_Order__c order = ACAMSOrderDAO.getOrder(orderId);
        List<String> toAddress = new List<String>();
        toAddress.add(email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        mail.setToAddresses(toAddress);
        mail.setTargetObjectId(order.ccrz__User__c);
        mail.setWhatId(orderId);
        mail.setOrgWideEmailAddressId(owa.Id);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        List<String> ccEmails = ccEmail.split(',');
        if (!String.isBlank(ccEmails.get(0))) {
            mail.setCcAddresses(ccEmails);
        }

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);

        try {
            Messaging.sendEmail(allmsg,false);
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return false;
    }
}