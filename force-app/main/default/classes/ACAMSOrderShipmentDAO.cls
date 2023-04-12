public with sharing class ACAMSOrderShipmentDAO {

    public static List<ccrz__E_OrderShipment__c> getOrderShipmentByOrderIds(Set<Id> orderIdSet) {
        return [
                SELECT
                        Id,
                        Shipment_Type__c,
                        Status__c,
                        ccrz__Order__c,
                        ccrz__Order__r.ccrz__ShipTo__c,
                        ccrz__Order__r.ccrz__BillTo__c,
                        ccrz__Order__r.ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__Order__r.ccrz__Storefront__c,
                        ccrz__Order__r.ccrz__ShipAmount__c,
                        ccrz__Order__r.ccrz__ShipMethod__c,
                        ccrz__OrderShipmentId__c,
                        ccrz__ShippingMethod__c,
                        ccrz__ShipmentDate__c,
                        ccrz__Carrier__c,
                        ccrz__TrackingNo__c
                FROM
                        ccrz__E_OrderShipment__c
                WHERE
                        ccrz__Order__c IN :orderIdSet
        ];
    }

    public static List<ccrz__E_OrderShipment__c> getOrderShipmentsByOrderItems(Set<Id> orderItemIds) {
        List<ccrz__E_OrderShipment__c> shipments = [
                SELECT
                        Id,
                        ccrz__OrderShipmentId__c,
                        CC_Order_Item__c
                FROM
                        ccrz__E_OrderShipment__c
                WHERE
                        CC_Order_Item__c IN :orderItemIds
        ];

        return shipments;
    }

}