global with sharing class ACAMSLogicCartPlace extends ccrz.ccLogicCartPlace {

    private User drupalIntegration = ACAMSUserDAO.getDrupalIntegrationUser();
   

    global virtual override Map<String, Object> process(Map<String, Object> inputData) {
        Boolean isSuccess = false;
        Map<String, Object> outputData;
        ccrz.cc_hk_Payment.TransactionPaymentParams tpParams;
        // Workaround for getting ccrz__E_TransactionPayment__c objects to be created through API calls
        try {
            Map<String, Object> tpMso = (Map<String, Object>) inputData.get(ccrz.ccApiCart.TRANSPAYMENTDATA);
            tpParams = ccrz.cc_hk_Payment.deserializeTransactionParams(JSON.serialize(tpMso));
        } catch (Exception e) {
            tpParams = (ccrz.cc_hk_Payment.TransactionPaymentParams) inputData.get(ccrz.ccApiCart.TRANSPAYMENTDATA);
        }
        inputData.put(ccrz.ccApiCart.TRANSPAYMENTDATA, tpParams);
        outputData = super.process(inputData);
        isSuccess = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);
			if (isSuccess) {
            try {
                String orderId = (String) outputData.get(ccrz.ccApiCart.ORDER_ID);
                if(!system.isFuture()){
                    ACAMSInvoiceService.splitOrderInvoice(orderId);
                }
               else{
                   ACAMSInvoiceService.splitOrderInvoiceFuture(orderId);
                }
                ccrz__E_Order__c order = ACAMSOrderDAO.getOrder(orderId);
               /* csa fix:method is commented
                * if(!system.isFuture()){
                addNumberOfOrdersToAccount(order.ccrz__Account__c);
                }
               else{
                   addNumberOfOrdersToAccountfuture(order.ccrz__Account__c);
                }*/
                addNumberOfOrdersToAccountfuture(order.ccrz__Account__c);
				 if(system.isFuture()){
                Set<ID> cntAddId = new Set<ID>();
                List<ccrz__E_Invoice__c> invLst =[select ccrz__BillAddress__r.id from ccrz__E_Invoice__c where ccrz__CCOrder__c =:order.Id];
                for(ccrz__E_Invoice__c cv : invLst){
                    cntAddId.add(cv.ccrz__BillAddress__r.id);
                }
                List<ccrz__E_ContactAddr__c> cntAddLstUpdate = New List<ccrz__E_ContactAddr__c>();
                List<ccrz__E_ContactAddr__c> cntAddLst =[select Vertex_Tax_Area_Confidence__c,Vertex_Tax_Area_Id__c from ccrz__E_ContactAddr__c where id in: cntAddId];
                for(ccrz__E_ContactAddr__c cadd : cntAddLst){
                    if(cadd.Vertex_Tax_Area_Confidence__c == null && cadd.Vertex_Tax_Area_Id__c == null){
                    cadd.Vertex_Tax_Area_Confidence__c = order.Vertex_Tax_Area_Confidence__c;
                    cadd.Vertex_Tax_Area_Id__c = order.Vertex_Tax_Area_Id__c;
                    cntAddLstUpdate.add(cadd);
                    }
                }
                if(cntAddLstUpdate.size() >0){
                    update cntAddLstUpdate;
                }
                }
                List<ccrz__E_OrderItem__c> orderItems = ACAMSOrderDAO.getOrderItems(orderId);
                Map<String, ccrz__E_CartItem__c> cartItemsMap = new Map<String, ccrz__E_CartItem__c>(
                        ACAMSCartDAO.getCartItemsByCartId(order.ccrz__OriginatedCart__c)
                );
                List<ccrz__E_CartItem__c> cartItems = cartItemsMap.values();
                Map<String, Boolean> autoRenewCartItemsMap = new Map<String, Boolean>();
                for (ccrz__E_CartItem__c cartItem : cartItems) {
                    if (cartItem.ccrz__SubProdTerm__c != null) {
                        autoRenewCartItemsMap.put(cartItem.Id, cartItem.Auto_Renew_Subscription__c);
                    }
                }
                Map<String, List<ccrz__E_Subscription__c>> orderItemToSubscriptionsMap = new Map<String, List<ccrz__E_Subscription__c>>();
                List<ccrz__E_Subscription__c> subscriptions = ACAMSSubscriptionDAO.getSubscriptionsByOrder(orderId);
                for (ccrz__E_Subscription__c sub : subscriptions) {
                    if (!orderItemToSubscriptionsMap.containsKey(sub.ccrz__CCOrderItem__c)) {
                        List<ccrz__E_Subscription__c> subList = new List<ccrz__E_Subscription__c>{sub};
                        orderItemToSubscriptionsMap.put(sub.ccrz__CCOrderItem__c, subList);
                    } else {
                        orderItemToSubscriptionsMap.get(sub.ccrz__CCOrderItem__c).add(sub);
                    }
                }
                Set<String> ceregoIds = new Set<String>();
                Boolean zeroDollar = false;
                for (ccrz__E_OrderItem__c orderItem : orderItems) {
                    orderItem.Educational_Credits__c = orderItem.ccrz__Product__r.Educational_Credits__c;
                    if (orderItem.ccrz__Product__r.Cerego_ID__c != null) {
                        ceregoIds.add(orderItem.ccrz__Product__r.Cerego_ID__c);
                    }
                    if (orderItemToSubscriptionsMap.containsKey(orderItem.Id)) {
                        List<ccrz__E_Subscription__c> subs = orderItemToSubscriptionsMap.get(orderItem.Id);
                        List<ccrz__E_Subscription__c> subsToUpdate = new List<ccrz__E_Subscription__c>();
                        for (ccrz__E_Subscription__c sub : subs) {
                            if (autoRenewCartItemsMap.containsKey(orderItem.ccrz__OrderItemId__c)) {
                                sub.ccrz__AutoRenew__c = autoRenewCartItemsMap.get(orderItem.ccrz__OrderItemId__c);
                                subsToUpdate.add(sub);
                            }
                        }
                        update subsToUpdate;
                    }
                    if (cartItemsMap.containsKey(orderItem.ccrz__OrderItemId__c)) {
                        if (cartItemsMap.get(orderItem.ccrz__OrderItemId__c).List_Price__c != null) {
                            orderItem.List_Price__c = cartItemsMap.get(orderItem.ccrz__OrderItemId__c).List_Price__c;
                        } else {
                            orderItem.List_Price__c = cartItemsMap.get(orderItem.ccrz__OrderItemId__c).ccrz__Price__c;
                        }
                        orderItem.CC_Account_Group__c = cartItemsMap.get(orderItem.ccrz__OrderItemId__c).CC_Account_Group__c;
                        if (cartItemsMap.get(orderItem.ccrz__OrderItemId__c).Line_Description__c != null) {
                            orderItem.Line_Description__c = cartItemsMap.get(orderItem.ccrz__OrderItemId__c).Line_Description__c;
                        }
                    }
                }
                update orderItems;

                if (!ceregoIds.isEmpty()) {
                    String ceregoUsername = order.ccrz__BuyerFirstName__c + ' ' + order.ccrz__BuyerLastName__c;
                    ACAMSCeregoService.ceregoProductCall(ceregoIds, ceregoUsername, order.ccrz__BuyerEmail__c, order.Id);
                }

                Boolean wirePayment = false;
                Boolean checkPayment = false;
                Boolean creditCardPayment = false;
                Boolean purchaseOrderPayment = false;
                Boolean invoicePayment = false;
                List<ccrz__E_TransactionPayment__c> payments = ACAMSOrderDAO.getTransactionPayments(new Set<Id>{
                        orderId
                });
                if (!payments.isEmpty()) {
                    for (ccrz__E_TransactionPayment__c payment : payments) {
                        if (Test.isRunningTest()) {
                            payment.ccrz__RequestAmount__c = 1.00;
                            update payment;
                        }
                        if (payment.ccrz__AccountType__c == ACAMSUtil.PO) {
                            purchaseOrderPayment = true;
                            break;
                        } else if (payment.ccrz__AccountType__c == ACAMSUtil.WT_CAPS) {
                            wirePayment = true;
                            break;
                        } else if (payment.ccrz__AccountType__c == ACAMSUtil.ACH_CAPS) {
                            checkPayment = true;
                            break;
                        } else if (payment.ccrz__AccountType__c == ACAMSUtil.ZERO_DOLLAR_API) {
                            zeroDollar = true;
                            break;
                        } else {
                            creditCardPayment = true;
                            break;
                        }
                    }
                } else {
                    invoicePayment = true;
                }
                if (order.ccrz__ShipAmount__c != null && order.ccrz__ShipAmount__c > 0) {
                    ccrz__E_OrderItem__c shippingOrderItem = new ccrz__E_OrderItem__c(ccrz__Order__c = orderId, ccrz__Product__c = ACAMSProductDAO.getShippingProductId(), ccrz__Price__c = order.ccrz__ShipAmount__c != null ? order.ccrz__ShipAmount__c : 0, ccrz__Quantity__c = 1, ccrz__SubAmount__c = 0);
                    insert shippingOrderItem;
                }

                order.ccrz__BuyerFirstName__c = order.ccrz__Contact__r.FirstName;
                order.ccrz__BuyerLastName__c = order.ccrz__Contact__r.LastName;
                order.ccrz__BuyerEmail__c = order.ccrz__Contact__r.Email;
                String prEmail = (String) inputData.get(ACAMSUtil.USER_EMAIL);
                if(prEmail != null){
                if(prEmail.contains('.localdomain')){
                   prEmail = prEmail + '.com';
                }
                }
                order.Purchaser_Email__c = prEmail;

                order.Account_Group__c = order.ccrz__Account__r.ccrz__E_AccountGroup__c;

                // FSA-985
                /*
                if (order.ccrz__TaxAmount__c == null) {
                    order.ccrz__TaxAmount__c = 0;
                }
                */
                if (wirePayment) {
                    order.ccrz__OrderStatus__c = ACAMSUtil.ON_HOLD;
                    order.ccrz__PaymentMethod__c = ACAMSUtil.WIRE_TRANSFER;
                } else if (checkPayment) {
                    order.ccrz__OrderStatus__c = ACAMSUtil.ON_HOLD;
                    order.ccrz__PaymentMethod__c = ACAMSUtil.CHECK;
                } else if (creditCardPayment) {
                    order.ccrz__OrderStatus__c = ACAMSUtil.IN_PROCESS;
                    order.ccrz__PaymentMethod__c = ACAMSUtil.CC;
                } else if (zeroDollar) {
                    order.ccrz__OrderStatus__c = ACAMSUtil.COMPLETED;
                    if (order.ccrz__BuyerEmail__c != order.Purchaser_Email__c) {
                        order.ccrz__PaymentMethod__c = ACAMSUtil.CSR_ZERO_DOLLAR;
                    } else {
                        order.ccrz__PaymentMethod__c = ACAMSUtil.ZERO_DOLLAR;
                    }
                } else if (invoicePayment) {
                    if (UserInfo.getUserId() == drupalIntegration.Id) {
                        order.ccrz__OrderStatus__c = ACAMSUtil.INVOICED;
                        order.ccrz__PaymentMethod__c = ACAMSUtil.INVOICE;
                    }
                }

                updateOrderWithMinorLineItems(order, orderItems);
                updateOrderWithOrderShipments(order, orderItems);
                update order;
                 
               // FSA-1695 added by Koti
                 if (UserInfo.getUserId() != drupalIntegration.Id) {
                    string OppIds = order.ccrz__OriginatedCart__r.opportunity__c;
                for(opportunity op : [select id,name,No_Assets__c from opportunity WHERE Id =: OppIds]){
                    if(op.No_Assets__c == false){
                     pushGenerateAssetsEvents(order.Id);
              
                    }
                                    }
                 }
                else{
                     pushGenerateAssetsEvents(order.Id);
                }
                            //FSA-875
                if(!system.isFuture()){
                stampObjects(order.Id);
                }
                else{
                stampObjectsfuture(order.Id);
                }
       /*         if(system.isFuture()){
                Id profileId = UserInfo.getProfileId();
                String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
                if(order.createdBy.Name != 'Drupal Integration' && order.LastModifiedBy.name != 'Drupal Integration' && (order.ccrz__TotalAmount__c < 1 ) && (profileName  == 'ACAMS - Customer Service' || profileName  == 'ACAMS - Operations' || profileName  == 'System Administrator - Set Audit' || profileName  == 'System Administrator (Restricted)' || profileName  == 'ACAMS - Sales' )){
                order.ccrz__PaymentMethod__c = 'Zero Dollar';
                order.Paid_in_Full_Date__c = order.ccrz__OrderDate__c;
                order.ccrz__OrderStatus__c = 'Completed';
                update order;
                ccrz__E_TransactionPayment__c ccrPayment = new ccrz__E_TransactionPayment__c();
                ccrPayment.ccrz__AccountType__c = 'zero_dollar';
                ccrPayment.ccrz__Amount__c = order.ccrz__TotalAmount__c;
                ccrPayment.ccrz__RequestAmount__c = order.ccrz__TotalAmount__c;
                ccrPayment.ccrz__CurrencyISOCode__c = 'USD';
                ccrPayment.ccrz__TransactionType__c = 'capture';
                ccrPayment.ccrz__PaymentType__c = 'zero_dollar';
                ccrPayment.ccrz__Storefront__c = 'acams';
                ccrPayment.ccrz__SoldTo__c = order.ccrz__Account__c;
                ccrPayment.ccrz__BillTo__c = order.ccrz__Account__c;
                ccrPayment.ccrz__Account__c = order.ccrz__Account__c;
                ccrPayment.ccrz__Contact__c = order.ccrz__Contact__c;
                ccrPayment.ccrz__User__c = order.ccrz__User__c;
                //ccrPayment.ccrz__CCOrder__c = ord.Id;
                //ccrPayment.ccrz__TransactionTS__c =ord.Paid_in_Full_Date__c;
                insert ccrPayment;
                 List<Asset> assetList = new List<Asset>();
        ccrz__E_Invoice__c invList = [SELECT Id,ccrz__CCOrder__c From ccrz__E_Invoice__c  Where ccrz__CCOrder__c =:order.Id];
        ccrz__E_TransactionPayment__c ccrPaymentobj = [SELECT Id, ccrz__CCOrder__c,ccrz__TransactionTS__c,ccrz__InvoiceAppliedFor__c FROM ccrz__E_TransactionPayment__c Where Id = :ccrPayment.id];
            ccrPaymentobj.ccrz__CCOrder__c = orderId;
            ccrPaymentobj.ccrz__InvoiceAppliedFor__c = invList.Id;
            update ccrPaymentobj;
          
           
                }
            } */
            }catch (Exception e) {
                 //csa fix added exception logger statement. 
           		ACAMSUtil.reportException(null, null,'process Method', null, e.getMessage(), null, null);
            }
        }
        return outputData;

    }

    private void updateOrderWithMinorLineItems(ccrz__E_Order__c order, List<ccrz__E_OrderItem__c> orderItems) {
            Map<String, ccrz__E_OrderItem__c> productToMajorLineItem = new Map<String, ccrz__E_OrderItem__c>();
            List<String> productIds = new List<Id>();

            for (ccrz__E_OrderItem__c orderItem : orderItems) {
                if (orderItem.ccrz__OrderLineType__c != null &&
                        orderItem.ccrz__OrderLineType__c.equalsIgnoreCase(ACAMSUtil.MAJOR) &&
                        orderItem.ccrz__Product__r.ccrz__ProductType__c.equalsIgnoreCase(ACAMSUtil.BUNDLE)) {
                    productToMajorLineItem.put(orderItem.ccrz__Product__c, orderItem);
                    productIds.add(orderItem.ccrz__Product__c);
                }
            }

            if (productIds != null && !productIds.isEmpty()) {
                List<ccrz__E_OrderItem__c> newMinorItems = new List<ccrz__E_OrderItem__c>();
                List<ccrz__E_CompositeProduct__c> childBundles = ACAMSProductDAO.getChildBundles(productIds);

                if (childBundles != null && !childBundles.isEmpty()) {
                    for (ccrz__E_CompositeProduct__c childBundle : childBundles) {
                        ccrz__E_OrderItem__c parentOrderItem = productToMajorLineItem.get(childBundle.ccrz__Composite__c);
                        ccrz__E_OrderItem__c minorItem = new ccrz__E_OrderItem__c();
                        minorItem.ccrz__Order__c = order.Id;
                        minorItem.ccrz__Price__c = 0.00;
                        minorItem.ccrz__Quantity__c = parentOrderItem.ccrz__Quantity__c;
                        minorItem.ccrz__SubAmount__c = 0.00;
                        minorItem.ccrz__RequestDate__c = parentOrderItem.ccrz__RequestDate__c;
                        minorItem.ccrz__PricingType__c = ACAMSUtil.AUTO;
                        minorItem.ccrz__OrderLineType__c = ACAMSUtil.MINOR;
                        minorItem.ccrz__Product__c = childBundle.ccrz__Component__c;
                        minorItem.ccrz__ProductType__c = ACAMSUtil.BUNDLE;
                        minorItem.ccrz__ParentOrderItem__c = parentOrderItem.Id;
                        minorItem.ccrz__StoreId__c = parentOrderItem.ccrz__StoreId__c;
                        minorItem.ccrz__OriginalQuantity__c = parentOrderItem.ccrz__OriginalQuantity__c;
                        minorItem.ccrz__OriginalItemPrice__c = 0.00;
                        newMinorItems.add(minorItem);
                    }
                    if(!newMinorItems.isEmpty()){
                        try{
                            insert newMinorItems;
                        }catch(Exception ex){
                            ACAMSUtil.reportException(null, null,'updateOrderWithMinorLineItems Method', null, ex.getMessage(), null, null);
                        }
                    }
                    
                }
            }
        
    }

    private void updateOrderWithOrderShipments(ccrz__E_Order__c order, List<ccrz__E_OrderItem__c> orderItems) {
            List<ccrz__E_OrderShipment__c> orderShipments = new List<ccrz__E_OrderShipment__c>();
            List<ccrz__E_OrderShipmentItem__c> orderShipmentItems = new List<ccrz__E_OrderShipmentItem__c>();

            Integer orderItemCount = 1;
            for (ccrz__E_OrderItem__c orderItem : orderItems) {
                ccrz__E_OrderShipment__c orderShipment = new ccrz__E_OrderShipment__c();
                orderShipment.ccrz__Order__c = order.Id;
                orderShipment.ccrz__OrderShipmentId__c = order.ccrz__OrderNumber__c + '-' + orderItemCount++;
                orderShipment.ccrz__ShippingMethod__c = order.ccrz__ShipMethod__c;
                if (orderItem.ccrz__Product__r.ccrz__ShippingWeight__c > 0 && orderItem.ccrz__Product__r.ccrz__ProductType__c != ACAMSUtil.BUNDLE) {
                    orderShipment.Status__c = ACAMSUtil.RELEASED;
                    orderShipment.Shipment_Type__c = ACAMSUtil.PHYSICAL;
                } else {
                    orderShipment.Status__c = ACAMSUtil.RELEASED;
                    orderShipment.Shipment_Type__c = ACAMSUtil.DIGITAL;
                }
                orderShipment.Order_Shipment_Email__c = order.ccrz__Contact__r.Email;
                if (order.ccrz__ShipTo__c != null) {
                    orderShipment.Shipping_Address__c = order.ccrz__ShipTo__c;
                }
                orderShipment.CC_Order_Item__c = orderItem.Id;
                orderShipments.add(orderShipment);
            }
            if(!orderShipments.isEmpty()){
                try{
                    insert orderShipments;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'updateOrderWithOrderShipments Method', null, ex.getMessage(), null, null);
                }
            }

            Integer index = 0;
            for (ccrz__E_OrderShipment__c orderShipment : orderShipments) {
                ccrz__E_OrderShipmentItem__c orderShipmentItem = new ccrz__E_OrderShipmentItem__c();
                orderShipmentItem.ccrz__OrderShipment__c = orderShipment.Id;
                orderShipmentItem.ccrz__Quantity__c = 1;
                orderShipmentItem.ccrz__SKU__c = orderItems.get(index).ccrz__Product__r.ccrz__SKU__c;
                orderShipmentItems.add(orderShipmentItem);
            }
            if(!orderShipmentItems.isEmpty()){
                try{
                    insert orderShipmentItems;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'updateOrderWithOrderShipments Method', null, ex.getMessage(), null, null);
                }
            }        
    }

   /*csa fix:not using this method anywhere
    *  @Future
    public static void addNumberOfOrdersToAccount(Id accountId) {
        List<ccrz__E_Order__c> orderList = [
                SELECT
                        Id
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Account__c = :accountId
                AND
                        ccrz__Name__c != :ACAMSUtil.REFUNDED_ORDER
                AND
                        ccrz__OrderStatus__c = :ACAMSUtil.COMPLETED
        ];

        List<Account> accounts = [
                SELECT
                        Id, Number_of_Orders__c
                FROM
                        Account
                WHERE
                        Id = :accountId
               
        ];

        if (!accounts.isEmpty()) {
            Account account = accounts.get(0);
            account.Number_of_Orders__c = orderList.size();
            if (Schema.SObjectType.Account.isUpdateable()) {
                ACAMSUtil.bypassPhoneValidation = true;
                try{  //FSA-1275
                update account;
                }
                catch(Exception e){    //FSA-1275
                system.debug('the error is' + e.getMessage());
                   // update account;
                } 
                ACAMSUtil.bypassPhoneValidation = false;
            }
        }
    }*/
    public static void addNumberOfOrdersToAccountfuture(Id accountId) {
        List<ccrz__E_Order__c> orderList = [
                SELECT
                        Id
                FROM
                        ccrz__E_Order__c
                WHERE
                        ccrz__Account__c = :accountId
                AND
                        ccrz__Name__c != :ACAMSUtil.REFUNDED_ORDER
                AND
                        ccrz__OrderStatus__c = :ACAMSUtil.COMPLETED
        ];

        List<Account> accounts = [
                SELECT
                        Id, Number_of_Orders__c
                FROM
                        Account
                WHERE
                        Id = :accountId
               
        ];

        if (!accounts.isEmpty()) {
            Account account = accounts.get(0);
            account.Number_of_Orders__c = orderList.size();
            System.debug('no of orders:'+orderList.size());
            if (Schema.SObjectType.Account.isUpdateable()) {
                ACAMSUtil.bypassPhoneValidation = true;
                try{  //FSA-1275
                update account;
                }
                catch(Exception e){    //FSA-1275
                     //csa fix added exception logger statement. 
           			ACAMSUtil.reportException(null, null,'addNumberOfOrdersToAccountfuture Method', null, e.getMessage(), null, null);
                  //  update account;
                } 
                ACAMSUtil.bypassPhoneValidation = false;
            }
        }
    }



    @Future
    private static void stampObjects(Id orderId) {
            ccrz__E_Order__c orderToUpdate = ACAMSOrderDAO.getOrderForUpdate(orderId);//FSA-875

            List<ccrz__E_AccountAddressBook__c> accAddrBooks = [
                    SELECT
                            Id
                    FROM
                            ccrz__E_AccountAddressBook__c
                    WHERE
                            ccrz__AddressType__c = 'Billing'
                    AND
                            ccrz__Default__c = TRUE
                    AND
                            ccrz__Account__c = :orderToUpdate.ccrz__Account__c FOR UPDATE //FSA-875
            ];

            if (accAddrBooks.isEmpty()) {
                Account account = ACAMSAccountDAO.getAccountFromId(orderToUpdate.ccrz__Account__c);
                for (ccrz__E_OrderItem__c orderItem : orderToUpdate.ccrz__E_OrderItems__r) {
                    if (orderItem.ccrz__Product__r.Level_1__c.equalsIgnoreCase(ACAMSUtil.CERTIFICATION)) {
                        account.BillingCity = orderToUpdate.ccrz__BillTo__r.ccrz__City__c;
                        /*account.BillingCountry = orderToUpdate.ccrz__BillTo__r.ccrz__Country__c != null ?
                                orderToUpdate.ccrz__BillTo__r.ccrz__Country__c :
                                orderToUpdate.ccrz__BillTo__r.ccrz__CountryISOCode__c;*/
                        //CSA-Fix for BillingCountry wherein mapping should be done with ccrz__BillTo__r.ccrz__Country__c  
                        account.BillingCountry = orderToUpdate.ccrz__BillTo__r.ccrz__Country__c;    
                        account.BillingCountryCode = orderToUpdate.ccrz__BillTo__r.ccrz__CountryISOCode__c;
                        account.BillingState = orderToUpdate.ccrz__BillTo__r.ccrz__State__c;
                        account.BillingPostalCode = orderToUpdate.ccrz__BillTo__r.ccrz__PostalCode__c;
                        //account.BillingStateCode = orderToUpdate.ccrz__BillTo__r.ccrz__State__c;
                        //CSA-Fix for BillingStateCode wherein mapping should be done with ccrz__BillTo__r.ccrz__StateISOCode__c
                        account.BillingStateCode = orderToUpdate.ccrz__BillTo__r.ccrz__StateISOCode__c;
                        String billingStreet = orderToUpdate.ccrz__BillTo__r.ccrz__AddressFirstline__c;
                        if (String.isNotBlank(orderToUpdate.ccrz__BillTo__r.ccrz__AddressSecondline__c)) {
                            billingStreet = billingStreet + '\n' + orderToUpdate.ccrz__BillTo__r.ccrz__AddressSecondline__c;
                        }
                        if (String.isNotBlank(orderToUpdate.ccrz__BillTo__r.ccrz__AddressThirdline__c)) {
                            billingStreet = billingStreet + '\n' + orderToUpdate.ccrz__BillTo__r.ccrz__AddressThirdline__c;
                        }
                        account.BillingStreet = billingStreet;
                    }
                }

                
                try{
                    ACAMSUtil.bypassPhoneValidation = true;
                    update account;
                    ACAMSUtil.bypassPhoneValidation = false;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'stampObjects Method', null, ex.getMessage(), null, null);
                }   
            }

            if (orderToUpdate.ccrz__Account__r.RecordType.DeveloperName == ACAMSUtil.ACCOUNT_RECORD_TYPE_BUSINESS) {
                orderToUpdate.ccrz__BuyerCompanyName__c = orderToUpdate.ccrz__Account__r.Name;
                orderToUpdate.Account_Owner__c = orderToUpdate.ccrz__Account__r.OwnerId;
            } else {
                orderToUpdate.ccrz__BuyerCompanyName__c = orderToUpdate.ccrz__Account__r.ccrz__CompanyName__pc;
                orderToUpdate.Account_Owner__c = orderToUpdate.ccrz__Account__r.CommunityUser__c;
            }
            if (orderToUpdate.Opportunity__c != null) {
                orderToUpdate.Opportunity_Owner__c = orderToUpdate.Opportunity__r.OwnerId;
            }

            orderToUpdate.BillTo_City__c = orderToUpdate.ccrz__BillTo__r.ccrz__City__c;
            orderToUpdate.BillTo_AddressFirstLine__c = orderToUpdate.ccrz__BillTo__r.ccrz__AddressFirstline__c;
            orderToUpdate.BillTo_StateISOCode__c = orderToUpdate.ccrz__BillTo__r.ccrz__State__c;
            orderToUpdate.BillTo_PostalCode__c = orderToUpdate.ccrz__BillTo__r.ccrz__PostalCode__c;
            orderToUpdate.BillTo_CountryISOCode__c = orderToUpdate.ccrz__BillTo__r.ccrz__CountryISOCode__c;
            orderToUpdate.BillTo_Named_Territory__c = orderToUpdate.ccrz__BillTo__r.Named_Territory__c;
            orderToUpdate.BillTo_Region__c = orderToUpdate.ccrz__BillTo__r.Region__c;
            orderToUpdate.BillTo_SubTerritory__c = orderToUpdate.ccrz__BillTo__r.SubTerritory__c;
            orderToUpdate.Enterprise_Account__c = orderToUpdate.Account_Group__r.Enterprise_Account__c;
            orderToUpdate.Industry__c = orderToUpdate.ccrz__Account__r.Industry;
            
            if(orderToUpdate.Account_Owner__c == NULL){
                orderToUpdate.Account_Owner__c = orderToUpdate.Opportunity__r.Account_Owner__c;
            }
            if(orderToUpdate.ccrz__BuyerCompanyName__c == NULL){
                orderToUpdate.ccrz__BuyerCompanyName__c = orderToUpdate.Opportunity__r.Company_Name__c;
            }
            
            if(orderToUpdate.Enterprise_Account__c == NULL){
                orderToUpdate.Enterprise_Account__c = orderToUpdate.Opportunity__r.Enterprise_Account__c;
            }
            
            if(orderToUpdate.Industry__c == NULL){
                orderToUpdate.Industry__c = orderToUpdate.Opportunity__r.Industry__c;
            }
            
            if(orderToUpdate.BillTo_AddressFirstLine__c == NULL){
                orderToUpdate.BillTo_AddressFirstLine__c = orderToUpdate.Opportunity__r.BillTo_AddressFirstLine__c;
            }
            
            if(orderToUpdate.BillTo_City__c == NULL){
                orderToUpdate.BillTo_City__c = orderToUpdate.Opportunity__r.BillTo_City__c;
            }
            
            if(orderToUpdate.BillTo_Region__c == NULL){
                orderToUpdate.BillTo_Region__c = orderToUpdate.Opportunity__r.AddressRegion__c;
            }
            
            if(orderToUpdate.BillTo_Named_Territory__c == NULL){
                orderToUpdate.BillTo_Named_Territory__c = orderToUpdate.Opportunity__r.AddressNamed_Territory__c;
            }
            
            if(orderToUpdate.BillTo_SubTerritory__c == NULL){
                orderToUpdate.BillTo_SubTerritory__c = orderToUpdate.Opportunity__r.AddressSubTerritory__c;
            }
            
            if(orderToUpdate.BillTo_PostalCode__c == NULL){
                orderToUpdate.BillTo_PostalCode__c = orderToUpdate.Opportunity__r.BillTo_PostalCode__c;
            }
            
            if(orderToUpdate.BillTo_CountryISOCode__c == NULL){
                orderToUpdate.BillTo_CountryISOCode__c = orderToUpdate.Opportunity__r.BillTo_CountryISOCode__c;
            }
            
            List<ccrz__E_Order__c> orderList = [
                    SELECT
                            Id
                    FROM
                            ccrz__E_Order__c
                    WHERE
                            ccrz__Account__c = :orderToUpdate.ccrz__Account__c
                    AND
                            ccrz__Name__c != :ACAMSUtil.REFUNDED_ORDER
            ];

            if (orderList.size() > 1) {
                orderToUpdate.New_or_Existing__c = 'Existing';
            } else {
                orderToUpdate.New_or_Existing__c = 'New';
            }
            
            if(orderToUpdate.New_or_Existing__c == NULL){
                orderToUpdate.New_or_Existing__c = orderToUpdate.Opportunity__r.New_or_Existing__c;
            }

            Map<String, Profile> profileMap = ACAMSUserDAO.getProfilesMap(new Set<String>{
                    ACAMSUtil.SALES_PROFILE, ACAMSUtil.CSR_PROFILE
            });
            Profile salesProfile = profileMap.containsKey(ACAMSUtil.SALES_PROFILE) ? profileMap.get(ACAMSUtil.SALES_PROFILE) : null;
            Profile customerServiceProfile = profileMap.containsKey(ACAMSUtil.CSR_PROFILE) ? profileMap.get(ACAMSUtil.CSR_PROFILE) : null;
            User userFromOrder = [
                    SELECT
                            Id, ProfileId
                    FROM
                            User
                    WHERE
                            Id = :orderToUpdate.OwnerId
            ];
        /*if (salesProfile != null && userFromOrder.ProfileId == salesProfile.Id) {
            orderToUpdate.Channel__c = 'Web Assisted';
            } else*/ if (orderToUpdate.Opportunity__c == null && orderToUpdate.ccrz__BuyerEmail__c != null &&
                    (!orderToUpdate.ccrz__BuyerEmail__c.equals(orderToUpdate.Purchaser_Email__c))) {
                orderToUpdate.Channel__c = 'Web Assisted';
            } else if (orderToUpdate.Opportunity__c == null) {
                orderToUpdate.Channel__c = 'Web Order';
            } /*else if (customerServiceProfile != null && userFromOrder.ProfileId == customerServiceProfile.Id) {
            orderToUpdate.Channel__c = 'Customer Service';
            }*/

            if (orderToUpdate.Opportunity__c == null) {
                if (orderToUpdate.Number_of_B2B_Order_Items__c > 0) {
                    orderToUpdate.Type__c = 'B2B';
                } else if (orderToUpdate.Number_of_B2B_Order_Items__c == 0) {
                    orderToUpdate.Type__c = 'B2C';
                }
            } else if (orderToUpdate.Opportunity__c != null) {
                if (orderToUpdate.ccrz__Account__r.RecordType.DeveloperName == ACAMSUtil.ACCOUNT_RECORD_TYPE_PERSON) {
                    orderToUpdate.Type__c = 'B2C';
                } else {
                    orderToUpdate.Type__c = 'B2B';
                }
            }
        /*  if (orderToUpdate.Number_of_B2B_Order_Items__c > 0) {
                createUnassignedAssetsCase(orderToUpdate); // The ticket fsa-6081 will replace this function.
            } */
            
            if(orderToUpdate.Channel__c == NULL){
                orderToUpdate.Channel__c = orderToUpdate.Opportunity__r.Channel__c;
            }

            if (orderToUpdate.Opportunity__c != null) {
                Opportunity oppToUpdate = ACAMSOpportunityDAO.getOpportunity(orderToUpdate.Opportunity__c);
                orderToUpdate.Enterprise_Upgrade__c = oppToUpdate.Enterprise_Upgrade__c;

                // Opportunities
                if (oppToUpdate.Account.RecordType.DeveloperName == ACAMSUtil.ACCOUNT_RECORD_TYPE_BUSINESS) {
                    oppToUpdate.Company_Name__c = oppToUpdate.Account.Name;
                    oppToUpdate.Account_Owner__c = oppToUpdate.Account.OwnerId;
                } else {
                    oppToUpdate.Company_Name__c = oppToUpdate.Account.ccrz__CompanyName__pc;
                    oppToUpdate.Account_Owner__c = oppToUpdate.Account.CommunityUser__c;
                }

                oppToUpdate.BillTo_City__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__City__c;
                oppToUpdate.BillTo_AddressFirstLine__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__AddressFirstline__c;
                oppToUpdate.BillTo_State__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__State__c;
                oppToUpdate.BillTo_PostalCode__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__PostalCode__c;
                oppToUpdate.BillTo_CountryISOCode__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__CountryISOCode__c;
                oppToUpdate.Enterprise_Account__c = oppToUpdate.Account.ccrz__E_AccountGroup__r.Enterprise_Account__c;
                oppToUpdate.Industry__c = oppToUpdate.Account.Industry;

                if (oppToUpdate.Account.Number_of_Orders__c > 0) {
                    oppToUpdate.New_or_Existing__c = 'Existing';
                } else {
                    oppToUpdate.New_or_Existing__c = 'New';
                }

                User oppOwner = [
                        SELECT
                                Id, ProfileId
                        FROM
                                User
                        WHERE
                                Id = :oppToUpdate.OwnerId
                ];

                /*if (salesProfile != null && oppOwner.ProfileId == salesProfile.Id) {
                    oppToUpdate.Channel__c = 'Web Assisted';
                } else if (customerServiceProfile != null && oppOwner.ProfileId == customerServiceProfile.Id) {
                    oppToUpdate.Channel__c = 'Customer Service';
                }*/

                if (oppToUpdate.Account.RecordType.DeveloperName == ACAMSUtil.ACCOUNT_RECORD_TYPE_PERSON) {
                    oppToUpdate.Type = 'B2C';
                } else {
                    oppToUpdate.Type = 'B2B';
                }
				try{
                    update oppToUpdate;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'stampObjects Method', null, ex.getMessage(), null, null);
                }  
            }
            try{
                update orderToUpdate;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'stampObjects Method', null, ex.getMessage(), null, null);
            }          
    }
    
        private static void stampObjectsfuture(Id orderId) {
            ccrz__E_Order__c orderToUpdate = ACAMSOrderDAO.getOrderForUpdate(orderId);//FSA-875

            List<ccrz__E_AccountAddressBook__c> accAddrBooks = [
                    SELECT
                
                            Id
                    FROM
                            ccrz__E_AccountAddressBook__c
                    WHERE
                            ccrz__AddressType__c = 'Billing'
                    AND
                            ccrz__Default__c = TRUE
                    AND
                            ccrz__Account__c = :orderToUpdate.ccrz__Account__c FOR UPDATE //FSA-875
            ];

            if (accAddrBooks.isEmpty()) {
                Account account = ACAMSAccountDAO.getAccountFromId(orderToUpdate.ccrz__Account__c);
                for (ccrz__E_OrderItem__c orderItem : orderToUpdate.ccrz__E_OrderItems__r) {
                    if (orderItem.ccrz__Product__r.Level_1__c.equalsIgnoreCase(ACAMSUtil.CERTIFICATION)) {
                        account.BillingCity = orderToUpdate.ccrz__BillTo__r.ccrz__City__c;
                        /*account.BillingCountry = orderToUpdate.ccrz__BillTo__r.ccrz__Country__c != null ?
                                orderToUpdate.ccrz__BillTo__r.ccrz__Country__c :
                                orderToUpdate.ccrz__BillTo__r.ccrz__CountryISOCode__c;*/
                        //CSA-Fix for BillingCountry wherein mapping should be done with ccrz__BillTo__r.ccrz__Country__c  
                        account.BillingCountry = orderToUpdate.ccrz__BillTo__r.ccrz__Country__c; 
                        account.BillingCountryCode = orderToUpdate.ccrz__BillTo__r.ccrz__CountryISOCode__c;
                        account.BillingState = orderToUpdate.ccrz__BillTo__r.ccrz__State__c;
                        account.BillingPostalCode = orderToUpdate.ccrz__BillTo__r.ccrz__PostalCode__c;
                        //account.BillingStateCode = orderToUpdate.ccrz__BillTo__r.ccrz__State__c;
                        //CSA-Fix for BillingStateCode wherein mapping should be done with ccrz__BillTo__r.ccrz__StateISOCode__c
                        account.BillingStateCode = orderToUpdate.ccrz__BillTo__r.ccrz__StateISOCode__c;
                        String billingStreet = orderToUpdate.ccrz__BillTo__r.ccrz__AddressFirstline__c;
                        if (String.isNotBlank(orderToUpdate.ccrz__BillTo__r.ccrz__AddressSecondline__c)) {
                            billingStreet = billingStreet + '\n' + orderToUpdate.ccrz__BillTo__r.ccrz__AddressSecondline__c;
                        }
                        if (String.isNotBlank(orderToUpdate.ccrz__BillTo__r.ccrz__AddressThirdline__c)) {
                            billingStreet = billingStreet + '\n' + orderToUpdate.ccrz__BillTo__r.ccrz__AddressThirdline__c;
                        }
                        account.BillingStreet = billingStreet;
                    }
                }
				
                try{
                    ACAMSUtil.bypassPhoneValidation = true;
                    update account;
                    ACAMSUtil.bypassPhoneValidation = false;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'stampObjectsfuture Method', null, ex.getMessage(), null, null);
                }  
                
            }

            if (orderToUpdate.ccrz__Account__r.RecordType.DeveloperName == ACAMSUtil.ACCOUNT_RECORD_TYPE_BUSINESS) {
                orderToUpdate.ccrz__BuyerCompanyName__c = orderToUpdate.ccrz__Account__r.Name;
                orderToUpdate.Account_Owner__c = orderToUpdate.ccrz__Account__r.OwnerId;
            } else {
                orderToUpdate.ccrz__BuyerCompanyName__c = orderToUpdate.ccrz__Account__r.ccrz__CompanyName__pc;
                orderToUpdate.Account_Owner__c = orderToUpdate.ccrz__Account__r.CommunityUser__c;
            }
            if (orderToUpdate.Opportunity__c != null) {
                orderToUpdate.Opportunity_Owner__c = orderToUpdate.Opportunity__r.OwnerId;
            }

            orderToUpdate.BillTo_City__c = orderToUpdate.ccrz__BillTo__r.ccrz__City__c;
            orderToUpdate.BillTo_AddressFirstLine__c = orderToUpdate.ccrz__BillTo__r.ccrz__AddressFirstline__c;
            orderToUpdate.BillTo_StateISOCode__c = orderToUpdate.ccrz__BillTo__r.ccrz__State__c;
            orderToUpdate.BillTo_PostalCode__c = orderToUpdate.ccrz__BillTo__r.ccrz__PostalCode__c;
            orderToUpdate.BillTo_CountryISOCode__c = orderToUpdate.ccrz__BillTo__r.ccrz__CountryISOCode__c;
            orderToUpdate.BillTo_Named_Territory__c = orderToUpdate.ccrz__BillTo__r.Named_Territory__c;
            orderToUpdate.BillTo_Region__c = orderToUpdate.ccrz__BillTo__r.Region__c;
            orderToUpdate.BillTo_SubTerritory__c = orderToUpdate.ccrz__BillTo__r.SubTerritory__c;
            orderToUpdate.Enterprise_Account__c = orderToUpdate.Account_Group__r.Enterprise_Account__c;
            orderToUpdate.Industry__c = orderToUpdate.ccrz__Account__r.Industry;
            
            if(orderToUpdate.Account_Owner__c == NULL){
                orderToUpdate.Account_Owner__c = orderToUpdate.Opportunity__r.Account_Owner__c;
            }
            if(orderToUpdate.ccrz__BuyerCompanyName__c == NULL){
                orderToUpdate.ccrz__BuyerCompanyName__c = orderToUpdate.Opportunity__r.Company_Name__c;
            }
            
            if(orderToUpdate.Enterprise_Account__c == NULL){
                orderToUpdate.Enterprise_Account__c = orderToUpdate.Opportunity__r.Enterprise_Account__c;
            }
            
            if(orderToUpdate.Industry__c == NULL){
                orderToUpdate.Industry__c = orderToUpdate.Opportunity__r.Industry__c;
            }
            
            if(orderToUpdate.BillTo_AddressFirstLine__c == NULL){
                orderToUpdate.BillTo_AddressFirstLine__c = orderToUpdate.Opportunity__r.BillTo_AddressFirstLine__c;
            }
            
            if(orderToUpdate.BillTo_City__c == NULL){
                orderToUpdate.BillTo_City__c = orderToUpdate.Opportunity__r.BillTo_City__c;
            }
            
            if(orderToUpdate.BillTo_Region__c == NULL){
                orderToUpdate.BillTo_Region__c = orderToUpdate.Opportunity__r.AddressRegion__c;
            }
            
            if(orderToUpdate.BillTo_Named_Territory__c == NULL){
                orderToUpdate.BillTo_Named_Territory__c = orderToUpdate.Opportunity__r.AddressNamed_Territory__c;
            }
            
            if(orderToUpdate.BillTo_SubTerritory__c == NULL){
                orderToUpdate.BillTo_SubTerritory__c = orderToUpdate.Opportunity__r.AddressSubTerritory__c;
            }
            
            if(orderToUpdate.BillTo_PostalCode__c == NULL){
                orderToUpdate.BillTo_PostalCode__c = orderToUpdate.Opportunity__r.BillTo_PostalCode__c;
            }
            
            if(orderToUpdate.BillTo_CountryISOCode__c == NULL){
                orderToUpdate.BillTo_CountryISOCode__c = orderToUpdate.Opportunity__r.BillTo_CountryISOCode__c;
            }
            
            List<ccrz__E_Order__c> orderList = [
                    SELECT
                            Id
                    FROM
                            ccrz__E_Order__c
                    WHERE
                            ccrz__Account__c = :orderToUpdate.ccrz__Account__c
                    AND
                            ccrz__Name__c != :ACAMSUtil.REFUNDED_ORDER
            ];

            if (orderList.size() > 1) {
                orderToUpdate.New_or_Existing__c = 'Existing';
            } else {
                orderToUpdate.New_or_Existing__c = 'New';
            }
            
            if(orderToUpdate.New_or_Existing__c == NULL){
                orderToUpdate.New_or_Existing__c = orderToUpdate.Opportunity__r.New_or_Existing__c;
            }

            Map<String, Profile> profileMap = ACAMSUserDAO.getProfilesMap(new Set<String>{
                    ACAMSUtil.SALES_PROFILE, ACAMSUtil.CSR_PROFILE
            });
            Profile salesProfile = profileMap.containsKey(ACAMSUtil.SALES_PROFILE) ? profileMap.get(ACAMSUtil.SALES_PROFILE) : null;
            Profile customerServiceProfile = profileMap.containsKey(ACAMSUtil.CSR_PROFILE) ? profileMap.get(ACAMSUtil.CSR_PROFILE) : null;
            User userFromOrder = [
                    SELECT
                            Id, ProfileId
                    FROM
                            User
                    WHERE
                            Id = :orderToUpdate.OwnerId
            ];
            /*if (salesProfile != null && userFromOrder.ProfileId == salesProfile.Id) {
                orderToUpdate.Channel__c = 'Web Assisted';
            } 
            }*/  if (orderToUpdate.Opportunity__c == null && orderToUpdate.ccrz__BuyerEmail__c != null &&
                    (!orderToUpdate.ccrz__BuyerEmail__c.equals(orderToUpdate.Purchaser_Email__c))) {
                orderToUpdate.Channel__c = 'Web Assisted';
            } else if (orderToUpdate.Opportunity__c == null) {
                orderToUpdate.Channel__c = 'Web Order';
            }/* else if (customerServiceProfile != null && userFromOrder.ProfileId == customerServiceProfile.Id) {
                orderToUpdate.Channel__c = 'Customer Service';
            }*/

            if (orderToUpdate.Opportunity__c == null) {
                if (orderToUpdate.Number_of_B2B_Order_Items__c > 0) {
                    orderToUpdate.Type__c = 'B2B';
                } else if (orderToUpdate.Number_of_B2B_Order_Items__c == 0) {
                    orderToUpdate.Type__c = 'B2C';
                }
            } else if (orderToUpdate.Opportunity__c != null) {
                if (orderToUpdate.ccrz__Account__r.RecordType.DeveloperName == ACAMSUtil.ACCOUNT_RECORD_TYPE_PERSON) {
                    orderToUpdate.Type__c = 'B2C';
                } else {
                    orderToUpdate.Type__c = 'B2B';
                }
            }
        /*  if (orderToUpdate.Number_of_B2B_Order_Items__c > 0) {
                createUnassignedAssetsCase(orderToUpdate); //The ticket fsa-6081 will replace this function.
            } */
            
            if(orderToUpdate.Channel__c == NULL){
                orderToUpdate.Channel__c = orderToUpdate.Opportunity__r.Channel__c;
            }

            if (orderToUpdate.Opportunity__c != null) {
                Opportunity oppToUpdate = ACAMSOpportunityDAO.getOpportunity(orderToUpdate.Opportunity__c);
                orderToUpdate.Enterprise_Upgrade__c = oppToUpdate.Enterprise_Upgrade__c;

                // Opportunities
                if (oppToUpdate.Account.RecordType.DeveloperName == ACAMSUtil.ACCOUNT_RECORD_TYPE_BUSINESS) {
                    oppToUpdate.Company_Name__c = oppToUpdate.Account.Name;
                    oppToUpdate.Account_Owner__c = oppToUpdate.Account.OwnerId;
                } else {
                    oppToUpdate.Company_Name__c = oppToUpdate.Account.ccrz__CompanyName__pc;
                    oppToUpdate.Account_Owner__c = oppToUpdate.Account.CommunityUser__c;
                }

                oppToUpdate.BillTo_City__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__City__c;
                oppToUpdate.BillTo_AddressFirstLine__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__AddressFirstline__c;
                oppToUpdate.BillTo_State__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__State__c;
                oppToUpdate.BillTo_PostalCode__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__PostalCode__c;
                oppToUpdate.BillTo_CountryISOCode__c = oppToUpdate.CC_Cart__r.ccrz__BillTo__r.ccrz__CountryISOCode__c;
                oppToUpdate.Enterprise_Account__c = oppToUpdate.Account.ccrz__E_AccountGroup__r.Enterprise_Account__c;
                oppToUpdate.Industry__c = oppToUpdate.Account.Industry;

                if (oppToUpdate.Account.Number_of_Orders__c > 0) {
                    oppToUpdate.New_or_Existing__c = 'Existing';
                } else {
                    oppToUpdate.New_or_Existing__c = 'New';
                }

                User oppOwner = [
                        SELECT
                                Id, ProfileId
                        FROM
                                User
                        WHERE
                                Id = :oppToUpdate.OwnerId
                ];

            /*if (salesProfile != null && oppOwner.ProfileId == salesProfile.Id) {
                    oppToUpdate.Channel__c = 'Web Assisted';
                } else if (customerServiceProfile != null && oppOwner.ProfileId == customerServiceProfile.Id) {
                    oppToUpdate.Channel__c = 'Customer Service';
                }*/

                if (oppToUpdate.Account.RecordType.DeveloperName == ACAMSUtil.ACCOUNT_RECORD_TYPE_PERSON) {
                    oppToUpdate.Type = 'B2C';
                } else {
                    oppToUpdate.Type = 'B2B';
                }
				try{
                    update oppToUpdate;
                }catch(Exception ex){
                    ACAMSUtil.reportException(null, null,'stampObjectsfuture Method', null, ex.getMessage(), null, null);
                } 
            }
            try{
                update orderToUpdate;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'stampObjectsfuture Method', null, ex.getMessage(), null, null);
            }
    }

    private static void createUnassignedAssetsCase(ccrz__E_Order__c order) {
            AssignmentRule assignmentRule = new AssignmentRule();
            assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = TRUE LIMIT 1];

            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= assignmentRule.Id;

            Case unassignedAssetCase = new Case();
            unassignedAssetCase.CC_Order__c = order.Id;
            unassignedAssetCase.Subject = 'Unassigned Assets on Order: ' + order.Name;
            unassignedAssetCase.Description = 'Unassigned Assets on created Order';
            unassignedAssetCase.ContactId = order.ccrz__Contact__c;
            unassignedAssetCase.AccountId = order.ccrz__Account__c;
            unassignedAssetCase.Origin = 'Order';
            unassignedAssetCase.Type = 'Revenue Impacting';
            unassignedAssetCase.Secondary_Case_Type__c = 'Group Orders';
            unassignedAssetCase.setOptions(dmlOpts);
			try{
                insert unassignedAssetCase;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'createUnassignedAssetsCase Method', null, ex.getMessage(), null, null);
            }        
    }
    
    private static void pushGenerateAssetsEvents(ID orderId){
        List<Generate_Asset__e> assetEvents = new List<Generate_Asset__e>();
        assetEvents.add(new Generate_Asset__e(Order_ID__c=orderId));
        
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(assetEvents);
        
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }       
        } 
    }

}