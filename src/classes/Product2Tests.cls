@isTest
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Test.startTest();
            // To Ensure that you simulate a user visiting the product2New page by using the appropriate method
            PageReference pageRef = Page.Product2New;
            Test.setCurrentPage(pageRef);
            Product2 prod = TestDataFactory.ConstructProducts(1)[0];
            insert prod;
            ApexPages.StandardController sc = new ApexPages.StandardController(prod);
            Product2Extension ext = new Product2Extension(sc);
            System.assertEquals(Constants.DEFAULT_ROWS,ext.productsToInsert.size());
            ext.addRows();
            System.assertEquals(2 * Constants.DEFAULT_ROWS,ext.productsToInsert.size());
            for(Integer i=0;i<4;i++){
                ext.productsToInsert[i].productRecord.Name = 'Test' + '-' + i;
                ext.productsToInsert[i].productRecord.Family = 'Side';
                ext.productsToInsert[i].productRecord.isActive = true;
                ext.productsToInsert[i].productRecord.Initial_Inventory__c = 10;
                ext.productsToInsert[i].pricebookEntryRecord.UnitPrice = 10;
            }
            ext.save();
            Integer lProductsCount = [Select count() from Product2];
            System.assertEquals(5,lProductsCount);
        Test.stopTest();
    }

    @isTest
    private static void Product2Trigger_UnitTest(){
         List<Product2> prod = TestDataFactory.ConstructProducts(1);
         insert prod;
         CollaborationGroup chatter = new CollaborationGroup();
         chatter.Name = 'Test Data Chatter Group';
         chatter.Description = 'test';
         chatter.CollaborationType = 'Public';
         insert chatter;
        prod[0].Quantity_Ordered__c=3;
        update prod;
    }

    @isTest
    private static void testPostAlerts(){
        List<Product2> prod = TestDataFactory.ConstructProducts(3);
        insert prod;
        Product2Helper.PostAlerts(prod);
    }
}