public with sharing class ACAMSOrderDAO {

    public static ccrz__E_Order__c getOrder(Id orderId) {
        ccrz__E_Order__c theOrder = [
                SELECT
                        Id,
                        Name,
                        ccrz__Account__c,
                        ccrz__Account__r.ccrz__CompanyName__pc,
                        ccrz__Account__r.ccrz__E_AccountGroup__c,
                        ccrz__Account__r.CommunityUser__c,
                        ccrz__Account__r.Industry,
                        ccrz__Account__r.Name,
                        ccrz__Account__r.Number_of_Orders__c,
                        ccrz__Account__r.OwnerId,
                        ccrz__Account__r.RecordType.DeveloperName,
                        ccrz__BillTo__r.ccrz__Country__c,
                        ccrz__BillTo__r.ccrz__CountryISOCode__c,
                        ccrz__BillTo__r.ccrz__City__c,
                        ccrz__BillTo__r.ccrz__PostalCode__c,
                        ccrz__BillTo__r.ccrz__State__c,
                        ccrz__BillTo__r.ccrz__StateISOCode__c,
                        ccrz__BillTo__r.ccrz__AddressFirstline__c,
                        ccrz__BillTo__r.ccrz__AddressSecondLine__c,
                        ccrz__BillTo__r.ccrz__AddressThirdLine__c,
                        ccrz__BillTo__r.Named_Territory__c,
                        ccrz__BillTo__r.SubTerritory__c,
                        ccrz__BillTo__r.Region__c,
                        ccrz__BuyerEmail__c,
                        ccrz__BuyerFirstName__c,
                        ccrz__BuyerLastName__c,
                        ccrz__BuyerPhone__c,
                        ccrz__Contact__c,
                        ccrz__Contact__r.FirstName,
                        ccrz__Contact__r.LastName,
                        ccrz__Contact__r.Email,
                        ccrz__OriginatedCart__c,
                        ccrz__OriginatedCart__r.opportunity__c,
                        ccrz__OrderDate__c,
                        ccrz__OrderNumber__c,
                        ccrz__OrderStatus__c,
                        ccrz__PaymentMethod__c,
                        ccrz__ShipAmount__c,
                        ccrz__ShipMethod__c,
                        ccrz__ShipTo__r.ccrz__FirstName__c,
                        ccrz__ShipTo__r.ccrz__MiddleName__c,
                        ccrz__ShipTo__r.ccrz__LastName__c,
                        ccrz__ShipTo__r.ccrz__AddressFirstline__c,
                        ccrz__ShipTo__r.ccrz__AddressSecondline__c,
                        ccrz__ShipTo__r.ccrz__AddressThirdline__c,
                        ccrz__ShipTo__r.ccrz__City__c,
                        ccrz__ShipTo__r.ccrz__State__c,
                        ccrz__ShipTo__r.ccrz__StateISOCode__c,
                        ccrz__ShipTo__r.ccrz__Country__c,
                        ccrz__ShipTo__r.ccrz__CountryISOCode__c,
                        ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__ShipTo__r.ccrz__DaytimePhone__c,
                        ccrz__ShipTo__r.ccrz__HomePhone__c,
                        ccrz__ShipTo__r.ccrz__Email__c,
                        ccrz__ShipTo__r.OwnerId,
                        ccrz__ShipTo__r.ccrz__Partner_Id__c,
                        ccrz__ShipTo__r.ccrz__AddrReadOnly__c,
                        ccrz__ShipTo__r.ccrz__CompanyName__c,
                        ccrz__ShipTo__r.ccrz__MailStop__c,
                        ccrz__ShipTo__r.ccrz__ShippingComments__c,
                        ccrz__ShipTo__r.CreatedById,
                        ccrz__TaxAmount__c,
                  ccrz__TotalAmount__c,
                  Paid_in_Full_Date__c,
                        ccrz__User__c,
                        Channel__c,
                        Account_Group__r.Enterprise_Account__c,
                        Enterprise_Upgrade__c,
                        Number_of_B2B_Order_Items__c,
                        Opportunity__c,
                        Opportunity__r.OwnerId,
                        Opportunity__r.Account_Owner__c,
                        Opportunity__r.Company_Name__c,
                        Opportunity__r.Enterprise_Account__c,
                        Opportunity__r.Industry__c,
                        Opportunity__r.BillTo_AddressFirstLine__c,
                        Opportunity__r.BillTo_City__c,
                        Opportunity__r.AddressRegion__c,
                        Opportunity__r.AddressNamed_Territory__c,
                        Opportunity__r.AddressSubTerritory__c,
                        Opportunity__r.BillTo_PostalCode__c,
                        Opportunity__r.BillTo_CountryISOCode__c,
                        Opportunity__r.New_or_Existing__c,
                        Opportunity__r.Channel__c,
                        Opportunity__r.No_Assets__c,
                        OwnerId,
                  CreatedBy.Name ,LastModifiedBy.Name,Vertex_Tax_Area_Confidence__c,
                  Vertex_Tax_Area_Id__c,
                        Purchaser_Email__c,
                        Tax_Transaction_Code__c, (
                        SELECT
                                Id,
                                ccrz__Quantity__c,
                                ccrz__Product__r.Event_Date__c,
                                ccrz__Product__r.Level_1__c,
                                ccrz__Product__r.Level_2__c,
                                ccrz__Product__r.Level_3__c,
                                ccrz__Product__r.Name,
                                ccrz__Product__r.ccrz__ProductType__c,
                                ccrz__Product__r.Term__c,
                                ccrz__Product__r.ccrz__SKU__c,
                                ccrz__SubProdTerm__c,
                                ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,
                                ccrz__SubProdTerm__r.ccrz__InstallmentCount__c,
                                ccrz__Order__c,
                                ccrz__Order__r.ccrz__Account__c,
                                ccrz__Order__r.ccrz__Contact__c

                        FROM
                                ccrz__E_OrderItems__r
                ), (
                        SELECT
                                Id,
                                Finalized__c
                        FROM
                                ccrz__CCInvoices__r
                )
                FROM
                        ccrz__E_Order__c
                WHERE
                        Id = :orderId
        ];
        return theOrder;
    }
    //FSA-875
public static ccrz__E_Order__c getOrderForUpdate(Id orderId) {
        ccrz__E_Order__c theOrder = [
                SELECT
                        Id,
                        Name,
                        ccrz__Account__c,
                        ccrz__Account__r.ccrz__CompanyName__pc,
                        ccrz__Account__r.ccrz__E_AccountGroup__c,
                        ccrz__Account__r.CommunityUser__c,
                        ccrz__Account__r.Industry,
                        ccrz__Account__r.Name,
                        ccrz__Account__r.Number_of_Orders__c,
                        ccrz__Account__r.OwnerId,
                        ccrz__Account__r.RecordType.DeveloperName,
                        ccrz__BillTo__r.ccrz__Country__c,
                        ccrz__BillTo__r.ccrz__CountryISOCode__c,
                        ccrz__BillTo__r.ccrz__City__c,
                        ccrz__BillTo__r.ccrz__PostalCode__c,
                        ccrz__BillTo__r.ccrz__State__c,
                        ccrz__BillTo__r.ccrz__StateISOCode__c,
                        ccrz__BillTo__r.ccrz__AddressFirstline__c,
                        ccrz__BillTo__r.ccrz__AddressSecondLine__c,
                        ccrz__BillTo__r.ccrz__AddressThirdLine__c,
                        ccrz__BillTo__r.Named_Territory__c,
                        ccrz__BillTo__r.SubTerritory__c,
                        ccrz__BillTo__r.Region__c,
                        ccrz__BuyerEmail__c,
                        ccrz__BuyerFirstName__c,
                        ccrz__BuyerLastName__c,
                        ccrz__BuyerPhone__c,
                        ccrz__Contact__c,
                        ccrz__Contact__r.FirstName,
                        ccrz__Contact__r.LastName,
                        ccrz__Contact__r.Email,
                        ccrz__OriginatedCart__c,
                        ccrz__OrderDate__c,
                        ccrz__OrderNumber__c,
                        ccrz__OrderStatus__c,
                        ccrz__PaymentMethod__c,
                        ccrz__ShipAmount__c,
                        ccrz__ShipMethod__c,
                        ccrz__ShipTo__r.ccrz__FirstName__c,
                        ccrz__ShipTo__r.ccrz__MiddleName__c,
                        ccrz__ShipTo__r.ccrz__LastName__c,
                        ccrz__ShipTo__r.ccrz__AddressFirstline__c,
                        ccrz__ShipTo__r.ccrz__AddressSecondline__c,
                        ccrz__ShipTo__r.ccrz__AddressThirdline__c,
                        ccrz__ShipTo__r.ccrz__City__c,
                        ccrz__ShipTo__r.ccrz__State__c,
                        ccrz__ShipTo__r.ccrz__StateISOCode__c,
                        ccrz__ShipTo__r.ccrz__Country__c,
                        ccrz__ShipTo__r.ccrz__CountryISOCode__c,
                        ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__ShipTo__r.ccrz__DaytimePhone__c,
                        ccrz__ShipTo__r.ccrz__HomePhone__c,
                        ccrz__ShipTo__r.ccrz__Email__c,
                        ccrz__ShipTo__r.OwnerId,
                        ccrz__ShipTo__r.ccrz__Partner_Id__c,
                        ccrz__ShipTo__r.ccrz__AddrReadOnly__c,
                        ccrz__ShipTo__r.ccrz__CompanyName__c,
                        ccrz__ShipTo__r.ccrz__MailStop__c,
                        ccrz__ShipTo__r.ccrz__ShippingComments__c,
                        ccrz__ShipTo__r.CreatedById,
                        ccrz__TaxAmount__c,
                        ccrz__User__c,
                        Channel__c,
                        Account_Group__r.Enterprise_Account__c,
                        Enterprise_Upgrade__c,
                        Number_of_B2B_Order_Items__c,
                        Opportunity__c,
                        Opportunity__r.Id,
                        Opportunity__r.No_Assets__c,
                        Opportunity__r.OwnerId,
                        Opportunity__r.Account_Owner__c,
                        Opportunity__r.Company_Name__c,
                        Opportunity__r.Enterprise_Account__c,
                        Opportunity__r.Industry__c,
                        Opportunity__r.BillTo_AddressFirstLine__c,
                        Opportunity__r.BillTo_City__c,
                        Opportunity__r.AddressRegion__c,
                        Opportunity__r.AddressNamed_Territory__c,
                        Opportunity__r.AddressSubTerritory__c,
                        Opportunity__r.BillTo_PostalCode__c,
                        Opportunity__r.BillTo_CountryISOCode__c,
                        Opportunity__r.New_or_Existing__c,
                        Opportunity__r.Channel__c,
                       // Opportunity__r.No_Assets__c,
                        OwnerId,
                        Purchaser_Email__c,
                        Tax_Transaction_Code__c, (
                        SELECT
                                Id,
                                ccrz__Quantity__c,
                                ccrz__Product__r.Event_Date__c,
                                ccrz__Product__r.Level_1__c,
                                ccrz__Product__r.Level_2__c,
                                ccrz__Product__r.Level_3__c,
                                ccrz__Product__r.Name,
                                ccrz__Product__r.ccrz__ProductType__c,
                                ccrz__Product__r.Term__c,
                                ccrz__Product__r.ccrz__SKU__c,
                                ccrz__SubProdTerm__c,
                                ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,
                                ccrz__SubProdTerm__r.ccrz__InstallmentCount__c,
                                ccrz__Order__c,
                                ccrz__Order__r.ccrz__Account__c,
                                ccrz__Order__r.ccrz__Contact__c

                        FROM
                                ccrz__E_OrderItems__r
                ), (
                        SELECT
                                Id,
                                Finalized__c
                        FROM
                                ccrz__CCInvoices__r
                )
                FROM
                        ccrz__E_Order__c
                WHERE
                        Id = :orderId FOR UPDATE
        ];
        return theOrder;
    }    

    public static List<ccrz__E_Order__c> getOrders(Set<Id> orderIds) {
        List<ccrz__E_Order__c> theOrders = [
                SELECT
                        Id,
                        ccrz__Account__c,
                        ccrz__Account__r.ccrz__CompanyName__pc,
                        ccrz__Account__r.RecordType.DeveloperName,
                        ccrz__Account__r.Name,
                        ccrz__Account__r.OwnerId,
                        ccrz__Account__r.CommunityUser__c,
                        ccrz__Account__r.Industry,
                        ccrz__Account__r.Number_of_Orders__c,
                        ccrz__Account__r.Member_Number__c,
                        ccrz__BillTo__c,
                        ccrz__BillTo__r.ccrz__AddressFirstline__c,
                        ccrz__BillTo__r.ccrz__City__c,
                        ccrz__BillTo__r.ccrz__CountryISOCode__c,
                        ccrz__BillTo__r.ccrz__PostalCode__c,
                        ccrz__BillTo__r.ccrz__StateISOCode__c,
                        ccrz__BillTo__r.Named_Territory__c,
                        ccrz__BillTo__r.Region__c,
                        ccrz__BuyerCompanyName__c,
                        ccrz__BuyerEmail__c,
                        ccrz__BuyerFirstName__c,
                        ccrz__BuyerLastName__c,
                        ccrz__BuyerMobilePhone__c,
                        ccrz__BuyerPhone__c,
                        ccrz__Contact__c,
                        ccrz__CurrencyISOCode__c,
                        ccrz__Order__c,
                        ccrz__Order__r.ccrz__OrderNumber__c,
                        ccrz__Order__r.ccrz__OrderStatus__c,
                        ccrz__OrderDate__c,
                        ccrz__OrderNumber__c,
                        ccrz__OrderStatus__c,
                        ccrz__OriginatedCart__c,
                        ccrz__PaymentMethod__c,
                        ccrz__ShipAmount__c,
                        ccrz__ShipMethod__c,
                        ccrz__ShipTo__c,
                        ccrz__ShipTo__r.ccrz__AddressFirstline__c,
                        ccrz__ShipTo__r.ccrz__City__c,
                        ccrz__ShipTo__r.ccrz__CountryISOCode__c,
                        ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__ShipTo__r.ccrz__StateISOCode__c,
                        ccrz__Storefront__c,
                        ccrz__SubtotalAmount__c,
                        ccrz__TaxAmount__c,
                        ccrz__TotalAmount__c,
                        ccrz__User__c,
                        ccrz__Contact__r.Member_Number__c,
                        Applied_Credits__c,
                        Account_Group__r.Enterprise_Account__c,
                        Enterprise_Account_Id__c,
                        Name,
                        Number_of_B2B_Order_Items__c,
                        Opportunity__c,
                        Opportunity__r.OwnerId,
                        OwnerId,
                        Tax_Transaction_Code__c, (
                        SELECT
                                Id,
                                ccrz__Quantity__c,
                                ccrz__Product__r.Level_1__c,
                                ccrz__Product__r.Level_2__c,
                                ccrz__Product__r.Level_3__c,
                                ccrz__Product__r.Name,
                                ccrz__Order__c,
                                ccrz__Order__r.ccrz__Contact__c,
                                ccrz__AdjustmentAmount__c

                        FROM
                                ccrz__E_OrderItems__r
                ), (
                        SELECT
                                Id
                        FROM
                                ccrz__CCInvoices__r
                )
                FROM
                        ccrz__E_Order__c
                WHERE
                        Id IN :orderIds
        ];

        return theOrders;
    }

    public static List<ccrz__E_Order__c> getOrdersByContactId(Id contactId) {
        List<ccrz__E_Order__c> oList = [
                SELECT
                        Id,
                        ccrz__Contact__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Contact__c = :contactId
        ];
        return oList;
    }

    public static List<ccrz__E_OrderItem__c> getOrderItems(Set<Id> orderIds) {
        List<ccrz__E_OrderItem__c> oList = [
                SELECT
                        Original_Order_Item__c,
                        Total_Item_Taxes__c,
                        ccrz__Order__c,
                        ccrz__Order__r.ccrz__OrderNumber__c,
                        ccrz__Order__r.ccrz__Order__c,
                        ccrz__Order__r.Name,
                        ccrz__Order__r.ccrz__SubtotalAmount__c,
                        ccrz__Order__r.ccrz__TotalAmount__c,
                        ccrz__Order__r.ccrz__TaxAmount__c,
                        ccrz__Order__r.ccrz__ShipAmount__c,
                        ccrz__Order__r.ccrz__User__c,
                        ccrz__Order__r.ccrz__PaymentMethod__c,
                        ccrz__OrderItemStatus__c,
                        ccrz__OrderLineType__c,
                        ccrz__OriginalItemPrice__c,
                        ccrz__ParentOrderItem__c,
                        ccrz__Price__c,
                        ccrz__Product__c,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__Product__r.Name,
                        ccrz__Quantity__c,
                        ccrz__StoreId__c,
                        ccrz__SubAmount__c,
                        ccrz__AdjustmentAmount__c
                FROM
                        ccrz__E_OrderItem__c
                WHERE
                        ccrz__Order__c IN :orderIds
        ];

        return oList;
    }

    public static ccrz__E_TransactionPayment__c getTransactionPayment(Id transactionId) {
        ccrz__E_TransactionPayment__c theTP = [
                SELECT
                        Id,
                        ccrz__Account__c,
                        ccrz__Contact__c,
                        ccrz__User__c,
                        ccrz__BillTo__c,
                        ccrz__SoldTo__c,
                        ccrz__CCOrder__c,
                        ccrz__AccountNumber__c,
                        ccrz__AccountType__c,
                        ccrz__Amount__c,
                        ccrz__RequestAmount__c,
                        ccrz__CurrencyISOCode__c,
                        ccrz__TransactionType__c,
                        ccrz__VerificationCode__c,
                        ccrz__TransactionTS__c,
                        ccrz__Storefront__c,
                        ccrz__PaymentType__c,
                        ccrz__SubAccountNumber__c,
                        ccrz__Token__c,
                        ccrz__TransactionCode__c,
                        ccrz__TransactionPaymentId__c,
                        ccrz__TransactionSubcode__c,
                        ccrz__SourceTransactionPayment__c
                FROM
                        ccrz__E_TransactionPayment__c
                WHERE
                        Id = :transactionId

        ];
        return theTP;
    }

    public static List<ccrz__E_TransactionPayment__c> getTransactionPayments(Set<Id> orderIds) {
        List<ccrz__E_TransactionPayment__c> tList = [
                SELECT
                        Id,
                        CC_Order_Shipment__c,
                        CC_Order_Shipment__r.ccrz__OrderShipmentId__c,
                        ccrz__Account__c,
                        ccrz__Contact__c,
                        ccrz__User__c,
                        ccrz__BillTo__c,
                        ccrz__SoldTo__c,
                        ccrz__CCOrder__c,
                        ccrz__CCOrder__r.ccrz__PaymentMethod__c,
                        ccrz__CCOrder__r.ccrz__TotalAmount__c,
                        ccrz__CCOrder__r.ccrz__OrderNumber__c,
                        ccrz__CCOrder__r.ccrz__Storefront__c,
                        ccrz__AccountNumber__c,
                        ccrz__AccountType__c,
                        ccrz__Amount__c,
                        ccrz__RequestAmount__c,
                        ccrz__CurrencyISOCode__c,
                        ccrz__TransactionType__c,
                        ccrz__VerificationCode__c,
                        ccrz__TransactionTS__c,
                        ccrz__Storefront__c,
                        ccrz__PaymentType__c,
                        ccrz__SubAccountNumber__c,
                        ccrz__Token__c,
                        ccrz__TransactionCode__c,
                        ccrz__TransactionPaymentId__c,
                        ccrz__TransactionSubcode__c,
                        ccrz__SourceTransactionPayment__c,
                        ccrz__Contact__r.Member_Number__c
                FROM
                        ccrz__E_TransactionPayment__c
                WHERE
                        ccrz__CCOrder__c IN :orderIds
        ];

        return tList;
    }

    public static List<ccrz__E_TransactionPayment__c> getCapturedTransactionPayments(Set<Id> orderIds) {
        List<ccrz__E_TransactionPayment__c> tList = [
                SELECT
                        Id,
                        ccrz__CCOrder__c
                FROM
                        ccrz__E_TransactionPayment__c
                WHERE
                        ccrz__CCOrder__c IN :orderIds
                AND
                        ccrz__TransactionType__c = 'capture'
        ];

        return tList;
    }

    public static List<ccrz__E_TransactionPayment__c> getTransactionPaymentsByIds(Set<Id> transactionIds) {
        List<ccrz__E_TransactionPayment__c> tList = [
                SELECT
                        Id,
                        CC_Order_Shipment__c,
                        CC_Order_Shipment__r.ccrz__OrderShipmentId__c,
                        ccrz__Account__c,
                        ccrz__Contact__c,
                        ccrz__User__c,
                        ccrz__BillTo__c,
                        ccrz__SoldTo__c,
                        ccrz__CCOrder__c,
                        ccrz__CCOrder__r.ccrz__PaymentMethod__c,
                        ccrz__CCOrder__r.ccrz__TotalAmount__c,
                        ccrz__CCOrder__r.ccrz__OrderNumber__c,
                        ccrz__AccountNumber__c,
                        ccrz__AccountType__c,
                        ccrz__Amount__c,
                        ccrz__RequestAmount__c,
                        ccrz__CurrencyISOCode__c,
                        ccrz__TransactionType__c,
                        ccrz__VerificationCode__c,
                        ccrz__TransactionTS__c,
                        ccrz__Storefront__c,
                        ccrz__PaymentType__c,
                        ccrz__SubAccountNumber__c,
                        ccrz__Token__c,
                        ccrz__TransactionCode__c,
                        ccrz__TransactionPaymentId__c,
                        ccrz__TransactionSubcode__c,
                        ccrz__SourceTransactionPayment__c,
                        ccrz__Contact__r.Member_Number__c
                FROM
                        ccrz__E_TransactionPayment__c
                WHERE
                        Id IN :transactionIds
        ];

        return tList;
    }

    public static List<ccrz__E_OrderShipment__c> getOrderShipments(Set<Id> orderIds) {
        List<ccrz__E_OrderShipment__c> oList = [
                SELECT
                        CC_Order_Item__c,
                        ccrz__Order__c,
                        ccrz__OrderShipmentId__c,
                        Status__c,
                        Shipment_Type__c
                FROM
                        ccrz__E_OrderShipment__c
                WHERE
                        ccrz__Order__c IN :orderIds
        ];

        return oList;
    }

    public static List<ccrz__E_OrderItem__c> getOrderItemsToCapture(Set<Id> orderIds) {
        List<ccrz__E_OrderItem__c> oList = [
                SELECT
                        Total_Item_Taxes__c,
                        ccrz__Order__c,
                        ccrz__Order__r.ccrz__OrderNumber__c,
                        ccrz__Order__r.ccrz__Storefront__c,
                        ccrz__Order__r.ccrz__Contact__r.Member_Number__c,
                        ccrz__OrderLineType__c,
                        ccrz__Price__c,
                        ccrz__Product__c,
                        ccrz__StoreId__c,
                        ccrz__SubAmount__c
                FROM
                        ccrz__E_OrderItem__c
                WHERE
                ccrz__Order__c IN :orderIds
                AND
                ccrz__Price__c > 0
        ];

        return oList;
    }

    public static List<ccrz__E_OrderItem__c> getChildOrderItems(Set<Id> orderItemIds) {
        List<ccrz__E_OrderItem__c> oList = [
                SELECT
                        Id,
                        ccrz__ParentOrderItem__c,
                        ccrz__ParentOrderItem__r.ccrz__OrderItemStatus__c,
                        ccrz__Order__c,
                        ccrz__Order__r.ccrz__TaxAmount__c,
                        ccrz__Price__c,
                        ccrz__ItemTotal__c,
                        Total_Item_Taxes__c,
                        ccrz__Quantity__c,
                        ccrz__SubAmount__c,
                        ccrz__Product_Name__c,
                        ccrz__RequestDate__c,
                        ccrz__OrderLineType__c,
                        ccrz__OrderItemStatus__c,
                        ccrz__Product__c,
                        ccrz__ProductType__c,
                        ccrz__UnitOfMeasure__c,
                        ccrz__StoreId__c,
                        ccrz__Coupon__c,
                        ccrz__ItemStatus__c,
                        ccrz__OriginalQuantity__c,
                        ccrz__OriginalItemPrice__c
                FROM
                        ccrz__E_OrderItem__c
                WHERE
                        ccrz__ParentOrderItem__c IN :orderItemIds
        ];
        return oList;
    }

    public static List<ccrz__E_OrderItem__c> getOrderItems(Id orderId) {
        List<ccrz__E_OrderItem__c> orderItems = [
                SELECT
                        Id,
                        Name,
                        ccrz__ItemTotal__c,
                        ccrz__Order__c,
                        ccrz__OrderItemId__c,
                        ccrz__OrderItemStatus__c,
                        ccrz__OrderLineType__c,
                        ccrz__OriginalItemPrice__c,
                        ccrz__OriginalQuantity__c,
                        ccrz__ParentOrderItem__c,
                        ccrz__ParentOrderItem__r.ccrz__OrderItemId__c,
                        ccrz__Price__c,
                        ccrz__Product_Name__c,
                        ccrz__Product__c,
                        ccrz__Product__r.Name,
                        ccrz__Product__r.ccrz__ProductType__c,
                        ccrz__Product__r.ccrz__ShippingWeight__c,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__Product__r.ccrz__TaxRateId__c,
                        ccrz__Product__r.Educational_Credits__c,
                        ccrz__Product__r.Cerego_ID__c,
                        ccrz__Quantity__c,
                        ccrz__RequestDate__c,
                        ccrz__StoreId__c,
                        ccrz__SubAmount__c,
                        CC_Account_Group__c,
                        Educational_Credits__c,
                        List_Price__c
                FROM
                        ccrz__E_OrderItem__c
                WHERE
                        ccrz__Order__r.Id = :orderId
        ];
        return orderItems;
    }

    public static List<ccrz__E_Order__c> getInvoiceOrders(Set<Id> orderIds) {
        List<ccrz__E_Order__c> orderList = [
                SELECT
                        Id,ccrz__OrderStatus__c, (
                        SELECT
                                Id,
                                ccrz__RemainingAmount__c,
                                ccrz__Status__c,
                                Invoice_Status__c,
                                ccrz__ParentInvoice__c,
                                Finalized__c //FSA-376
                        FROM
                                ccrz__CCInvoices__r
                        ORDER BY
                                ccrz__DateIssued__c
                                        DESC
                )
                FROM
                        ccrz__E_Order__c
                WHERE
                        Id
                                IN :orderIds
        ];

        return orderList;
    }

    public static List<ccrz__E_OrderItem__c> getOrderItemsByOrderItemIds(Set<Id> orderItemIds) {
        List<ccrz__E_OrderItem__c> orderItems = [
                SELECT
                        Id,
                        Name,
                        ccrz__ItemTotal__c,
                        ccrz__Order__c,
                        ccrz__Order__r.ccrz__PaymentMethod__c,
                        ccrz__Order__r.ccrz__CurrencyISOCode__c,
                        ccrz__Order__r.ccrz__TotalAmount__c,
                        ccrz__Order__r.ccrz__Contact__c,
                        ccrz__Order__r.ccrz__Account__c,
                        ccrz__OrderItemId__c,
                        ccrz__OrderItemStatus__c,
                        ccrz__OrderLineType__c,
                        ccrz__OriginalItemPrice__c,
                        ccrz__OriginalQuantity__c,
                        ccrz__ParentOrderItem__c,
                        ccrz__ParentOrderItem__r.ccrz__OrderItemId__c,
                        ccrz__Price__c,
                        ccrz__Product_Name__c,
                        ccrz__Product__c,
                        ccrz__Product__r.Name,
                        ccrz__Product__r.ccrz__ProductType__c,
                        ccrz__Product__r.ccrz__ShippingWeight__c,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__Product__r.ccrz__TaxRateId__c,
                        ccrz__Product__r.Educational_Credits__c,
                        ccrz__Product__r.Cerego_ID__c,
                        ccrz__Quantity__c,
                        ccrz__RequestDate__c,
                        ccrz__StoreId__c,
                        ccrz__SubAmount__c,
                        Educational_Credits__c
                FROM
                        ccrz__E_OrderItem__c
                WHERE
                        Id IN :orderItemIds
                FOR
                        UPDATE
        ];
        return orderItems;
    }
}