public class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            System.debug('new status==='+newList[i].Status);
            System.debug('old status'+oldList[i].Status);
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status == Constants.DRAFT_ORDER_STATUS ){
                orderIds.add(newList[i].Id);
            }
        }
        RollUpOrderItems(orderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        System.debug('Ids==='+activatedOrderIds);
        Map<Id,Product2> productMap = new Map<Id,Product2>();
        Set<Id> productIds = new Set<Id>();
        for(OrderItem orderItemRec : [SELECT Id,Product2Id FROM OrderItem WHERE OrderId IN: activatedOrderIds]){
            productIds.add(orderItemRec.Product2Id);
        }
        System.debug('productIds==='+productIds);
        productMap = new Map<Id,Product2>([SELECT Id,Initial_Inventory__c,Quantity_Ordered__c,Quantity_Remaining__c FROM Product2 where Id IN: productIds]);
        AggregateResult[] result = [Select Product2Id,SUM(Quantity) from OrderItem where Product2Id IN: productMap.keySet() Group By Product2Id ];
        System.debug('result===='+result);
        for(AggregateResult ar : result){
            Id productId = (Id)ar.get('Product2Id');
            Integer totalQuantityOrdered = Integer.valueOf(ar.get('expr0'));
            if(productMap.get(productId) != null){
                productMap.get(productId).Quantity_Ordered__c = totalQuantityOrdered;
            }
        }
        if(productMap != null && productMap.size() > 0) {
         update productMap.values();
        }
    }
}