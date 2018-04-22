public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(ApexPages.StandardController stdController){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }
    
    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add(new ProductWrapper());
        }
    }
    
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> productFamilyOptions = new List<SelectOption>();
        productFamilyOptions.add(new SelectOption(Constants.SELECT_ONE ,Constants.SELECT_ONE));
        for(Schema.PicklistEntry picklistEntry : Constants.PRODUCT_FAMILY){
            productFamilyOptions.add(new SelectOption(picklistEntry.getLabel(),picklistEntry.getValue()));
        }
        return productFamilyOptions;
    }

    public List<ChartHelper.ChartData> GetInventory(){
        List<ChartHelper.ChartData> productData = ChartHelper.GetInventory();
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
        Savepoint sp = Database.setSavepoint();
        try {
            List<Product2> lProductsInserted = createProducts(productsToInsert);
            List<PriceBookEntry> lPriceBookEntries = getPriceBookEntries(productsToInsert);
            for(Integer i=0;i<lPriceBookEntries.size();i++){
                lPriceBookEntries[i].Product2Id = lProductsInserted[i].Id;
                lPriceBookEntries[i].Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            insert lPriceBookEntries;
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();
            addRows();
        } catch (Exception e){
			Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,Constants.ERROR_MESSAGE));
        }
        return null;
    }
	
    public class ProductWrapper{
        
        public Product2 productRecord {get;set;}
        public PriceBookEntry priceBookEntryRecord{get;set;}
        
        public ProductWrapper(){
            productRecord = new Product2();
            priceBookEntryRecord = new PriceBookEntry();
        }
    }
    
    /**
     * Method to return and insert list of Product2's
     * @params : List of wrapper records
     * @resturn : List of Product2
     */
    public List<Product2> createProducts(List<ProductWrapper> wrappersToInsert){
        List<Product2> lProductsToInsert = new List<Product2>();
        for(ProductWrapper wrapper : wrappersToInsert){
            System.debug('wrapper===='+wrapper);
            if(wrapper.productRecord.Name != null && wrapper.productRecord.Family !=null && wrapper.productRecord.Initial_Inventory__c != null){
                System.debug('here=====');
               lProductsToInsert.add(wrapper.productRecord); 
            }
        }
        insert lProductsToInsert;
        return lProductsToInsert;
    }
    
    /**
     * Method to return list of PriceBookEntry's
     * @params : List of wrapper records
     * @resturn : List of PriceBookEntry records
     */
    public List<PriceBookEntry> getPriceBookEntries(List<ProductWrapper> wrappersToInsert){
        List<PriceBookEntry> lPriceBookEntries = new List<PriceBookEntry>();
        for(ProductWrapper wrapper : wrappersToInsert){
            if(wrapper.priceBookEntryRecord.UnitPrice != null){
            	lPriceBookEntries.add(wrapper.priceBookEntryRecord);
            }
        }
        return lPriceBookEntries;
    }
}