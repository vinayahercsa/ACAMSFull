global with sharing class ACAMSPaymentProcessing {

    public static String getCybersourceXMLString(String username, String key, String body) {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soapenv:Header>' +
                '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">' +
                '<wsse:UsernameToken>' +
                '<wsse:Username>' +
                username +
                '</wsse:Username>' +
                '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' +
                key +
                '</wsse:Password>' +
                '</wsse:UsernameToken>' +
                '</wsse:Security>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                '<requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.155">' +
                '<merchantID>' +
                username +
                '</merchantID>' +
                body +
                '</requestMessage>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>';
    }

    @Future(Callout=true)
    public static void refundPayments(Set<Id> orderIds) {
        Map<Id, List<ccrz__E_TransactionPayment__c>> transactionPaymentMap = new Map<Id, List<ccrz__E_TransactionPayment__c>>();
        List<ccrz__E_TransactionPayment__c> transactionPayments = ACAMSOrderDAO.getTransactionPayments(orderIds);
        for (ccrz__E_TransactionPayment__c transactionPayment : transactionPayments) {
            if (!transactionPaymentMap.containsKey(transactionPayment.ccrz__CCOrder__c)) {
                transactionPaymentMap.put(transactionPayment.ccrz__CCOrder__c, transactionPayments);
            }
        }

        List<ccrz__E_TransactionPayment__c> transactionsToRefund = new List<ccrz__E_TransactionPayment__c>();
        for (Id orderId : orderIds) {
            List<ccrz__E_TransactionPayment__c> transactionPaymentList = transactionPaymentMap.get(orderId);
            if (transactionPaymentList != null) {
                for (ccrz__E_TransactionPayment__c transactionPayment : transactionPaymentList) {
                    if (transactionPayment.ccrz__AccountType__c == 'sopcc' &&
                            !transactionPayment.ccrz__TransactionType__c.containsIgnoreCase(ACAMSUtil.AUTHORIZATION)) {
                        transactionsToRefund.add(transactionPayment);
                    }
                }
            }
        }
        Set<Id> transactionIds = new Set<Id>();
        for (ccrz__E_TransactionPayment__c tp : transactionsToRefund) {
            transactionIds.add(tp.Id);
        }
        refundTransactions(transactionIds, new Map<Id, Decimal> ());
    }

    @Future(Callout=true)
    public static void refundTransactionsFuture(Set<Id> transactionIds, Map<Id, Decimal> transactionIdsToAmounts) {
        refundTransactions(transactionIds, transactionIdsToAmounts);
    }

    public static void refundTransactions(Set<Id> transactionIds, Map<Id, Decimal> transactionIdsToAmounts) {
        List<ccrz__E_TransactionPayment__c> transactionsToRefund = ACAMSOrderDAO.getTransactionPaymentsByIds(transactionIds);
        if (transactionsToRefund != null) {
            CyberSource_SOAP_API__c soapApi = CyberSource_SOAP_API__c.getInstance();
            if (soapApi != null) {
                List<ccrz__E_TransactionPayment__c> newTransactionPayments = new List<ccrz__E_TransactionPayment__c>();
                for (ccrz__E_TransactionPayment__c transactionPayment : transactionsToRefund) {
                    String orderShipmentId = transactionPayment.CC_Order_Shipment__c != null ? transactionPayment.CC_Order_Shipment__r.ccrz__OrderShipmentId__c : transactionPayment.ccrz__CCOrder__r.ccrz__OrderNumber__c.toPlainString();
                    String storefront = transactionPayment.ccrz__Storefront__c;
                    String memberNumber = transactionPayment.ccrz__Contact__r.Member_Number__c;
                    String body = '';
                    Decimal grandTotalAmount = 0;
                    if (!transactionIdsToAmounts.isEmpty() &&
                            transactionIdsToAmounts.containsKey(transactionPayment.Id)) {
                        grandTotalAmount = transactionIdsToAmounts.get(transactionPayment.Id);
                        if (grandTotalAmount < 0) {
                            grandTotalAmount = -(grandTotalAmount);
                        }
                    } else {
                        grandTotalAmount = transactionPayment.ccrz__Amount__c;
                        if (grandTotalAmount < 0) {
                            grandTotalAmount = -(grandTotalAmount);
                        }
                    }
                    body += '<merchantReferenceCode>' +
                            orderShipmentId + ',' + storefront + ',' + memberNumber +
                            '</merchantReferenceCode>' +
                            '<purchaseTotals>' +
                            '<currency>' +
                            transactionPayment.ccrz__CurrencyISOCode__c +
                            '</currency>' +
                            '<grandTotalAmount>' +
                            grandTotalAmount +
                            '</grandTotalAmount>' +
                            '</purchaseTotals>' +
                            '<ccCreditService run="true">' +
                            '<captureRequestID>' +
                            transactionPayment.ccrz__TransactionPaymentId__c +
                            '</captureRequestID>' +
                            '</ccCreditService>';
                    String xml = getCybersourceXMLString(soapApi.Username__c, soapApi.Key1__c + soapApi.Key2__c, body);

                    Http http = new Http();

                    HttpRequest req = new HttpRequest();
                    req.setMethod('POST');
                    req.setEndpoint('callout:ccpgcs_soap');
                    req.setHeader('Content-Type', 'application/xml');
                    req.setBodyAsBlob(Blob.valueOf(xml));

                    HttpResponse res = http.send(req);
                    if (res.getStatusCode() == 200) {
                        DOM.Document doc = res.getBodyDocument();
                        try {
                            Dom.XmlNode bodyNode = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                            Dom.XmlNode replyMessageNode = bodyNode.getChildElement('replyMessage', 'urn:schemas-cybersource-com:transaction-data-1.155');
                            String requestId = replyMessageNode.getChildElement('requestID', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();
                            String decision = replyMessageNode.getChildElement('decision', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();
                            String reasonCode = replyMessageNode.getChildElement('reasonCode', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();
                            Dom.XmlNode ccCreditReplyNode = replyMessageNode.getChildElement('ccCreditReply', 'urn:schemas-cybersource-com:transaction-data-1.155');
                            String requestDateTime = ccCreditReplyNode.getChildElement('requestDateTime', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();
                            String amount = ccCreditReplyNode.getChildElement('amount', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();

                            ccrz__E_TransactionPayment__c newTransaction = transactionPayment.clone(false, true, true, false);
                            newTransaction.ccrz__Account__c = transactionPayment.ccrz__Account__c;
                            newTransaction.ccrz__Contact__c = transactionPayment.ccrz__Contact__c;
                            newTransaction.ccrz__User__c = transactionPayment.ccrz__User__c;
                            newTransaction.ccrz__BillTo__c = transactionPayment.ccrz__BillTo__c;
                            newTransaction.ccrz__SoldTo__c = transactionPayment.ccrz__SoldTo__c;
                            newTransaction.ccrz__CCOrder__c = transactionPayment.ccrz__CCOrder__c;
                            newTransaction.ccrz__AccountNumber__c = transactionPayment.ccrz__AccountNumber__c;
                            newTransaction.ccrz__AccountType__c = transactionPayment.ccrz__AccountType__c;
                            newTransaction.ccrz__Amount__c = Decimal.valueOf(amount);
                            newTransaction.ccrz__RequestAmount__c = Decimal.valueOf(amount);
                            newTransaction.ccrz__CurrencyISOCode__c = transactionPayment.ccrz__CurrencyISOCode__c;
                            newTransaction.ccrz__TransactionType__c = ACAMSUtil.CREDIT;
                            newTransaction.ccrz__VerificationCode__c = transactionPayment.ccrz__VerificationCode__c;
                            newTransaction.ccrz__TransactionTS__c = Datetime.valueOf(requestDateTime.replace('T', ' '));
                            newTransaction.ccrz__Storefront__c = transactionPayment.ccrz__Storefront__c;
                            newTransaction.ccrz__PaymentType__c = transactionPayment.ccrz__PaymentType__c;
                            newTransaction.ccrz__SubAccountNumber__c = transactionPayment.ccrz__SubAccountNumber__c;
                            newTransaction.ccrz__Token__c = transactionPayment.ccrz__Token__c;
                            newTransaction.ccrz__TransactionCode__c = decision;
                            newTransaction.ccrz__TransactionPaymentId__c = requestId;
                            newTransaction.ccrz__TransactionSubcode__c = reasonCode;
                            newTransaction.ccrz__SourceTransactionPayment__c = transactionPayment.Id;
                            newTransactionPayments.add(newTransaction);
                        } catch (Exception e) {
                            System.debug('Refund Payment exception: ' + e);
                        }
                    }
                }
                insert newTransactionPayments;
            }
        }
    }

    public class CapturePayment implements Queueable, Database.AllowsCallouts {
        Id transactionId = null;
        Decimal requestAmount = null;
        String orderShipmentId = null;
        String shipmentSfId = null;
        String storefront = null;
        String memberNumber = null;
        Id invoiceId = null;
        Queueable chainedJob;

        public CapturePayment(Id transactionId, Decimal requestAmount, String orderShipmentId, String shipmentSfId,
                String storefront, String memberNumber, Id invoiceId) {
            this.transactionId = transactionId;
            this.requestAmount = requestAmount;
            this.orderShipmentId = orderShipmentId;
            this.shipmentSfId = shipmentSfId;
            this.storefront = storefront;
            this.memberNumber = memberNumber;
            this.invoiceId = invoiceId;
        }

        public void setChainedJob(Queueable chainedJob) {
            this.chainedJob = chainedJob;
        }

        public void execute(QueueableContext context) {
            ccrz__E_TransactionPayment__c transactionPayment = ACAMSOrderDAO.getTransactionPayment(transactionId);
            if (transactionPayment != null) {
                List<ccrz__E_TransactionPayment__c> transactionPayments = new List<ccrz__E_TransactionPayment__c>();
                Integer sequence = 1;
                if (requestAmount > transactionPayment.ccrz__RequestAmount__c) {
                    requestAmount = transactionPayment.ccrz__RequestAmount__c;
                }
                CyberSource_SOAP_API__c soapApi = CyberSource_SOAP_API__c.getInstance();
                if (soapApi != null) {
                    String body = '<merchantReferenceCode>' +
                            orderShipmentId + ',' + storefront + ',' + memberNumber +
                            '</merchantReferenceCode>' +
                            '<purchaseTotals>' +
                            '<currency>' +
                            transactionPayment.ccrz__CurrencyISOCode__c +
                            '</currency>' +
                            '<grandTotalAmount>' +
                            requestAmount +
                            '</grandTotalAmount>' +
                            '</purchaseTotals>' +
                            '<ccCaptureService run="true">' +
                            '<authRequestID>' +
                            transactionPayment.ccrz__VerificationCode__c +
                            '</authRequestID>' +
                            '<sequence>' +
                            sequence++ +
                            '</sequence>' +
                            '<totalCount>' +
                            1 +
                            '</totalCount>' +
                            '</ccCaptureService>';
                    String xml = getCybersourceXMLString(soapApi.Username__c, soapApi.Key1__c + soapApi.Key2__c, body);
                    Http http = new Http();

                    HttpRequest req = new HttpRequest();
                    req.setMethod('POST');
                    req.setEndpoint('callout:ccpgcs_soap');
                    req.setHeader('Content-Type', 'application/xml');
                    req.setBodyAsBlob(Blob.valueOf(xml));

                    HttpResponse res = http.send(req);
                    if (res.getStatusCode() == 200) {
                        DOM.Document doc = res.getBodyDocument();
                        try {
                            Dom.XmlNode bodyNode = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                            Dom.XmlNode replyMessageNode = bodyNode.getChildElement('replyMessage', 'urn:schemas-cybersource-com:transaction-data-1.155');
                            String requestId = replyMessageNode.getChildElement('requestID', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();
                            String decision = replyMessageNode.getChildElement('decision', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();
                            String reasonCode = replyMessageNode.getChildElement('reasonCode', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();
                            Dom.XmlNode ccCaptureReplyNode = replyMessageNode.getChildElement('ccCaptureReply', 'urn:schemas-cybersource-com:transaction-data-1.155');
                            String requestDateTime = ccCaptureReplyNode.getChildElement('requestDateTime', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();
                            String amount = ccCaptureReplyNode.getChildElement('amount', 'urn:schemas-cybersource-com:transaction-data-1.155').getText();

                            ccrz__E_TransactionPayment__c newTransaction = transactionPayment.clone(false, true, true, false);
                            newTransaction.ccrz__Account__c = transactionPayment.ccrz__Account__c;
                            newTransaction.ccrz__Contact__c = transactionPayment.ccrz__Contact__c;
                            newTransaction.ccrz__User__c = transactionPayment.ccrz__User__c;
                            newTransaction.ccrz__BillTo__c = transactionPayment.ccrz__BillTo__c;
                            newTransaction.ccrz__SoldTo__c = transactionPayment.ccrz__SoldTo__c;
                            newTransaction.ccrz__CCOrder__c = transactionPayment.ccrz__CCOrder__c;
                            newTransaction.ccrz__AccountNumber__c = transactionPayment.ccrz__AccountNumber__c;
                            newTransaction.ccrz__AccountType__c = transactionPayment.ccrz__AccountType__c;
                            newTransaction.ccrz__Amount__c = Decimal.valueOf(amount);
                            newTransaction.ccrz__RequestAmount__c = Decimal.valueOf(amount);
                            newTransaction.ccrz__CurrencyISOCode__c = transactionPayment.ccrz__CurrencyISOCode__c;
                            newTransaction.ccrz__TransactionType__c = 'capture';
                            newTransaction.ccrz__VerificationCode__c = transactionPayment.ccrz__VerificationCode__c;
                            newTransaction.ccrz__TransactionTS__c = Datetime.valueOf(requestDateTime.replace('T', ' '));
                            newTransaction.ccrz__Storefront__c = transactionPayment.ccrz__Storefront__c;
                            newTransaction.ccrz__PaymentType__c = transactionPayment.ccrz__PaymentType__c;
                            newTransaction.ccrz__SubAccountNumber__c = transactionPayment.ccrz__SubAccountNumber__c;
                            newTransaction.ccrz__Token__c = transactionPayment.ccrz__Token__c;
                            newTransaction.ccrz__TransactionCode__c = decision;
                            newTransaction.ccrz__TransactionPaymentId__c = requestId;
                            newTransaction.ccrz__TransactionSubcode__c = reasonCode;
                            newTransaction.ccrz__SourceTransactionPayment__c = transactionPayment.Id;
                            newTransaction.CC_Order_Shipment__c = shipmentSfId;
                            if (invoiceId != null) {
                                newTransaction.ccrz__InvoiceAppliedFor__c = invoiceId;
                            }
                            transactionPayments.add(newTransaction);
                        } catch (Exception e) {
                            System.debug('Capture Payment exception: ' + e);
                            transactionPayment.Capture_Error__c = e.getStackTraceString();
                            transactionPayment.Capture_Error_Message__c = e.getMessage() + '\n' + e.getCause();
                            update transactionPayment;
                        }
                    } else {
                        transactionPayment.Capture_Error__c = res.getBody().substring(0, 32768);
                        update transactionPayment;
                    }
                }
                try {
                    insert transactionPayments;
                } catch (Exception e) {
                    transactionPayment.Capture_Error__c = e.getStackTraceString();
                    transactionPayment.Capture_Error_Message__c = e.getMessage() + '\n' + e.getCause();
                    update transactionPayment;
                }
            }

            if (this.chainedJob != null) {
                System.enqueueJob(this.chainedJob);
            }
        }
    }

}