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

    @isTest
    private static void OrderExtension_UnitTest(){
        PageReference pageRef = Page.OrderEdit;
        Test.setCurrentPage(pageRef);
        List<Account> lAccs = TestDataFactory.ConstructAccounts(1);
        Order orderRec = TestDatafactory.ConstructOrders(1,lAccs)[0];
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(orderRec);
        OrderExtension orderExtension = new OrderExtension(stdcontroller);
        orderExtension.OnFieldChange();
        orderExtension.SelectFamily();
        orderExtension.Save();
        orderExtension.First();
        orderExtension.Next();
        orderExtension.Previous();
        orderExtension.Last();
        orderExtension.GetHasPrevious();
        orderExtension.GetHasNext();
        orderExtension.GetTotalPages();
        orderExtension.GetPageNumber();
        List<SelectOption> options = orderExtension.GetFamilyOptions();
    }

    @testSetup static void SetupTestData(){
        TestDataFactory.InsertTestData(1);
    }
}