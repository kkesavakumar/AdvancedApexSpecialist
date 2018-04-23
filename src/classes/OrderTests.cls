@isTest
private class OrderTests {

    @isTest
    private static void OrderUpdate_UnitTest(){
        SetupTestData();
        Product2 prod = [Select Id,Quantity_Ordered__c from Product2 Limit 1];
        List<Order> lOrdersToUpdate = [Select Id,Status from Order where Status=:Constants.DRAFT_ORDER_STATUS];
        lOrdersToUpdate[0].Status = Constants.ACTIVATED_ORDER_STATUS;
        update lOrdersToUpdate;
        Product2 prod1 = [Select Id,Quantity_Ordered__c from Product2 Limit 1];
        TestDataFactory.VerifyQuantityOrdered(prod,prod1, 2);
    }

    @testSetup static void SetupTestData(){
        TestDataFactory.InsertTestData(1);
    }
}