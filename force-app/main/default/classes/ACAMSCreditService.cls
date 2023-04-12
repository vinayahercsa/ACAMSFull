public with sharing class ACAMSCreditService {

    public static void createCreditsForOrders(ccrz__E_Order__c[] sourceOrders) {
        Credit__c[] creditsToCreate = new Credit__c[]{};
        for (ccrz__E_Order__c ordersToCreateCredit : sourceOrders) {
            creditsToCreate.add(getNewCreditForOrder(ordersToCreateCredit));
        }
        insert creditsToCreate;
    }

    public static void createCreditsForOrderItems(ccrz__E_OrderItem__c[] sourceOrderItems) {
        Credit__c[] creditsToCreate = new Credit__c[]{};
        for (ccrz__E_OrderItem__c orderItemsToCreateCredit : sourceOrderItems) {
            creditsToCreate.add(getNewCreditForOrderItem(orderItemsToCreateCredit));
        }
        insert creditsToCreate;
    }

    private static Credit__c getNewCreditForOrderItem(ccrz__E_OrderItem__c orderItemToCreateCredit) {
        Id creditAccountId = orderItemToCreateCredit.Person_Account_Id__c;
        if (orderItemToCreateCredit.Enterprise_Account_Id__c != null) {
            creditAccountId = orderItemToCreateCredit.Enterprise_Account_Id__c;
        }
        Decimal orderItemTaxes = orderItemToCreateCredit.Total_Item_Taxes__c != null ?
                orderItemToCreateCredit.Total_Item_Taxes__c : 0;
        return new Credit__c(
                Account__c = creditAccountId,
                Amount__c = orderItemToCreateCredit.ccrz__ItemTotal__c + orderItemTaxes,
                CC_Order__c = orderItemToCreateCredit.ccrz__Order__c,
                CC_Order_Item__c = orderItemToCreateCredit.Id,
                Credit_Date__c = Date.today(),
                Credit_Type__c = ACAMSUtil.CREDIT_TYPE_REFUND,
                Currency__c = orderItemToCreateCredit.Order_Currency_ISO_Code__c
        );
    }

    private static Credit__c getNewCreditForOrder(ccrz__E_Order__c orderToCreateCredit) {
        Id creditAccountId = orderToCreateCredit.ccrz__Account__c;
        if (orderToCreateCredit.Enterprise_Account_Id__c != null) {
            creditAccountId = orderToCreateCredit.Enterprise_Account_Id__c;
        }
        return new Credit__c(
                Account__c = creditAccountId,
                Amount__c = orderToCreateCredit.ccrz__TotalAmount__c,
                CC_Order__c = orderToCreateCredit.Id,
                Credit_Date__c = Date.today(),
                Credit_Type__c = ACAMSUtil.CREDIT_TYPE_REFUND,
                Currency__c = orderToCreateCredit.ccrz__CurrencyISOCode__c
        );
    }

}