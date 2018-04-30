/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        loadPaginationData();
        total = 0;
        pieData = new List<chartHelper.chartData>();
        //loop through the order Items for the orderRecord
        for(OrderItem item : orderRecord.OrderItems){
            orderItemMap.put(item.Product2Id,item);
            if(item.Quantity > 0){
                pieData.add(new ChartHelper.chartData(item.Product2.Name,item.Quantity * item.UnitPrice));
                total += item.Quantity * item.UnitPrice;
            }
        }
    }

    public void loadPaginationData(){
        String query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c FROM PricebookEntry';
        query += ' ';
        query += 'where IsActive = True';
        if(selectedFamily != null && selectedFamily != Constants.SELECT_ONE){
            query += ' AND Product2.Family=:selectedFamily';
        }
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
        System.debug('standardSetController==='+standardSetController);
    }

    public void loadOrderItemdata(){
        System.debug('loadOrderData=====');
        orderItemList = new List<OrderItem>();
        for(SObject record : standardSetController.getRecords()){
            System.debug('for=====');
            PricebookEntry pbeRecord = (PricebookEntry)record;
            if(orderItemMap.containsKey(pbeRecord.Product2Id)) {
                System.debug('if=====');
                orderItemList.add(orderItemMap.get(pbeRecord.Product2Id));
            } else{
                System.debug('else======');
                OrderItem orderItem = new OrderItem(
                PricebookEntryId = pbeRecord.Id,
                Product2Id = pbeRecord.Product2Id,
                UnitPrice = pbeRecord.UnitPrice,
                Quantity = 0,
                Product2 = pbeRecord.Product2
                );
                orderItemList.add(orderItem);
                orderItemMap.put(pbeRecord.Product2Id,orderItem);
            }
        }
        System.debug('orderItemList===='+orderItemList);
        System.debug('orderItemMap==='+orderItemMap);
    }


    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        pieData = new List<chartHelper.chartData>();
        total = 0;
        for(OrderItem item : orderItemMap.values()){
            pieData.add(new ChartHelper.chartData(item.Product2.Name,item.Quantity * item.UnitPrice));
            total += item.Quantity * item.UnitPrice;
        }
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        loadPaginationData();
        loadOrderItemdata();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        Savepoint sp = Database.setSavepoint();
        List<OrderItem> lOrderItemsToInsert = new List<OrderItem>();
        List<OrderItem> lOrderItemsToDelete = new List<OrderItem>();
        try{
            if(orderRecord.Pricebook2Id == null){
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord;
            for(OrderItem oItem : orderItemMap.values()){
                System.debug('for=======');
                if(oItem.Quantity > 0 ){
                    oItem.OrderId = orderRecord.Id;
                    lOrderItemsToInsert.add(oItem);
                }else{
                    lOrderItemsToDelete.add(oItem);
                }
            }
            upsert lOrderItemsToInsert;
            delete lOrderItemsToDelete;
        }catch(Exception ex){
            Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,Constants.ERROR_MESSAGE));
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
        System.debug('first====');
        standardSetController.first();
        loadOrderItemdata();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
        System.debug('next=====');
        standardSetController.next();
        loadOrderItemdata();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        System.debug('prevopus=====');
        standardSetController.previous();
        loadOrderItemdata();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        System.debug('last====');
        standardSetController.last();
        loadOrderItemdata();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        System.debug('total pages==='+standardSetController.getResultSize());
        return (Integer)Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> productFamilyOptions = new List<SelectOption>();
        productFamilyOptions.add(new SelectOption(Constants.SELECT_ONE ,Constants.SELECT_ONE));
        for(Schema.PicklistEntry picklistEntry : Constants.PRODUCT_FAMILY){
            productFamilyOptions.add(new SelectOption(picklistEntry.getLabel(),picklistEntry.getValue()));
        }
        return productFamilyOptions;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}