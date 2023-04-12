public with sharing class ACAMSOrderItemTriggerHandler extends CCAviTriggerHandler {

    public ACAMSOrderItemTriggerHandler() {
    }

    public static Boolean skipPopulateLegalEntityValueFromFormula = false;

    protected override void beforeInsert() {
        populateLegalEntityValueFromFormula();
    }
    protected override void beforeUpdate() {
        populateLegalEntityValueFromFormula();
    }

    public override void afterUpdate() {
        Map<Id, ccrz__E_OrderItem__c> oldMap = (Map<Id, ccrz__E_OrderItem__c>) Trigger.oldMap;
        Map<Id, ccrz__E_OrderItem__c> newMap = (Map<Id, ccrz__E_OrderItem__c>) Trigger.newMap;
        Set<Id> orderIds = new Set<Id>();

        for (ccrz__E_OrderItem__c orderItem : newMap.values()) {
            orderIds.add(orderItem.ccrz__Order__c);
        }

        ccrz__E_OrderItem__c[] orderItemsToRefundCredit = new ccrz__E_OrderItem__c[]{};
        Set<Id> orderIdsToClone = new Set<Id>();
        Set<Id> refundOrderIdsToClone = new Set<Id>();
        Set<Id> creditOrderIdsToClone = new Set<Id>();
        Set<Id> orderItemsToCase = new Set<Id>();
        for (Id orderItemId : Trigger.newMap.keySet()) {
            ccrz__E_OrderItem__c newItem = newMap.get(orderItemId);
            ccrz__E_OrderItem__c oldItem = oldMap.get(orderItemId);
            if (oldItem.ccrz__OrderItemStatus__c != ACAMSUtil.REFUNDED &&
                    newItem.ccrz__OrderItemStatus__c == ACAMSUtil.REFUNDED) {
                orderIdsToClone.add(newItem.ccrz__Order__c);
                refundOrderIdsToClone.add(newItem.ccrz__Order__c);
                orderItemsToCase.add(orderItemId);
            } else if (oldItem.ccrz__OrderItemStatus__c != ACAMSUtil.ORDER_ITEM_STATUS_REFUNDED_CREDIT &&
                    newItem.ccrz__OrderItemStatus__c == ACAMSUtil.ORDER_ITEM_STATUS_REFUNDED_CREDIT &&
                    newItem.Order_Status__c != ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT) {
                orderIdsToClone.add(newItem.ccrz__Order__c);
                creditOrderIdsToClone.add(newItem.ccrz__Order__c);
                orderItemsToRefundCredit.add(newItem);
            }
        }

        if (!orderIdsToClone.isEmpty()) {
            Map<Id, ccrz__E_Order__c> idToOrderMap = new Map<Id, ccrz__E_Order__c>(ACAMSOrderDAO.getOrders(orderIdsToClone));
            List<ccrz__E_OrderItem__c> childOrderItems = ACAMSOrderDAO.getChildOrderItems(newMap.keySet());
            List<ccrz__E_OrderItem__c> orderItems = ACAMSOrderDAO.getOrderItemsByOrderItemIds(orderItemsToCase);
            Map<Id, List<ccrz__E_OrderItem__c>> idToOrderItemsMap = new Map<Id, List<ccrz__E_OrderItem__c>>();
            Set<Id> childOrderItemIds = new Set<Id>();
            for (ccrz__E_OrderItem__c childOrderItem : childOrderItems) {
                if (idToOrderItemsMap.containsKey(childOrderItem.ccrz__ParentOrderItem__c)) {
                    List<ccrz__E_OrderItem__c> orderItemsList = idToOrderItemsMap.get(childOrderItem.ccrz__ParentOrderItem__c);
                    orderItemsList.add(childOrderItem);
                    idToOrderItemsMap.put(childOrderItem.ccrz__ParentOrderItem__c, orderItemsList);
                } else {
                    List<ccrz__E_OrderItem__c> orderItemsList = new List<ccrz__E_OrderItem__c>{
                            childOrderItem
                    };
                    idToOrderItemsMap.put(childOrderItem.ccrz__ParentOrderItem__c, orderItemsList);
                }
                childOrderItemIds.add(childOrderItem.Id);
                if (childOrderItem.ccrz__ParentOrderItem__r.ccrz__OrderItemStatus__c == ACAMSUtil.REFUNDED) {
                    childOrderItem.ccrz__OrderItemStatus__c = ACAMSUtil.REFUNDED;
                } else if (childOrderItem.ccrz__ParentOrderItem__r.ccrz__OrderItemStatus__c ==
                        ACAMSUtil.ORDER_ITEM_STATUS_REFUNDED_CREDIT) {
                    childOrderItem.ccrz__OrderItemStatus__c = ACAMSUtil.ORDER_ITEM_STATUS_REFUNDED_CREDIT;
                }
            }
            update childOrderItems;

            List<ccrz__E_OrderItem__c> checkRefundList = new List<ccrz__E_OrderItem__c>();
            List<ccrz__E_OrderItem__c> wireTransferRefundList = new List<ccrz__E_OrderItem__c>();

            for (ccrz__E_OrderItem__c orderItem : orderItems) {
                if (orderItem.ccrz__OrderItemStatus__c == ACAMSUtil.REFUNDED) {
                    if (orderItem.ccrz__Order__r.ccrz__PaymentMethod__c == ACAMSUtil.CHECK) {
                        checkRefundList.add(orderItem);
                    } else if (orderItem.ccrz__Order__r.ccrz__PaymentMethod__c == ACAMSUtil.WIRE_TRANSFER) {
                        wireTransferRefundList.add(orderItem);
                    }
                }
            }
            childOrderItemIds.addAll(newMap.keySet());
            if (!refundOrderIdsToClone.isEmpty()) {
                ACAMSOrderHelper.cloneOrders(refundOrderIdsToClone, Trigger.newMap.values(), idToOrderMap, idToOrderItemsMap,
                        ACAMSUtil.REFUNDED);
            }
            if (!creditOrderIdsToClone.isEmpty()) {
                ACAMSOrderHelper.cloneOrders(creditOrderIdsToClone, Trigger.newMap.values(), idToOrderMap, idToOrderItemsMap,
                        ACAMSUtil.ORDER_STATUS_REFUNDED_CREDIT);
            }
            if (!orderItemsToRefundCredit.isEmpty()) {
                ACAMSCreditService.createCreditsForOrderItems(orderItemsToRefundCredit);
            }

            ACAMSAssetHelper.cancelAssetsByOrderItemIds(childOrderItemIds);
        }
    }

    private void populateLegalEntityValueFromFormula() {
        if (!skipPopulateLegalEntityValueFromFormula) {
            ACAMSLegalEntityService.updateLineItemLegalEntityFromFormula(
                    Trigger.new,
                    ccrz__E_OrderItem__c.Legal_Entity_Formula__c.getDescribe().getName(),
                    ccrz__E_OrderItem__c.Legal_Entity__c.getDescribe().getName()
            );
        }
    }

}