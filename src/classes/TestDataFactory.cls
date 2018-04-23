/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup chatterGroup = new CollaborationGroup();
        chatterGroup.Name = 'Test'+Constants.INVENTORY_ANNOUNCEMENTS;
        chatterGroup.CollaborationType = 'Public';
        return chatterGroup;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        List<Product2> lProductRecs = new List<Product2>();
        for (Integer i = 0; i < cnt; i++) {
            Product2 p = new Product2();
            p.Name = 'Test Product ' + i;
            if(i>=4){
                p.Family = Constants.PRODUCT_FAMILY[1].getValue();
            }
            else{
                p.Family = Constants.PRODUCT_FAMILY[i].getValue();
            }
            p.Initial_Inventory__c = 10;
            p.IsActive = true;
            lProductRecs.add(p);
        }
        return lProductRecs;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PriceBookEntry> ConstructPricebookEntries(List<Product2> prods){
        List<PriceBookEntry> lPriceBookEntries = new List<PriceBookEntry>();
        for(Product2 product : prods){
            PriceBookEntry priceBookEntryRec = new PriceBookEntry();
            priceBookEntryRec.Product2Id = product.Id;
            priceBookEntryRec.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            priceBookEntryrec.IsActive = true;
            priceBookEntryRec.UnitPrice = 1;
            lPriceBookEntries.add(priceBookEntryRec);
        }
        return lPriceBookEntries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        List<Account> accts = new List<Account>();
        for(Integer i=0;i<cnt;i++) {
            Account a = new Account(Name='TestAccount' + i);
            accts.add(a);
        }
        return accts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        List<Contact> cons = new List<Contact>();
            for (Integer k=0;k<cnt;k++) {
                cons.add(new Contact(firstname='Test'+k,
                                     lastname='Test'+k,
                                     AccountId=accts[k].Id));
            }
        return cons;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        List<Order> orderRecs = new List<Order>();
            for (Integer k=0;k<cnt;k++) {
                orderRecs.add(new Order(EffectiveDate = Date.today().addDays(k),
                                     Status='Draft',
                                     AccountId=accts[k].Id,
                                     Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID));
            }
        return orderRecs;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        List<OrderItem> lOrderItems = new List<OrderItem>();
        for (Integer i = 0; i < cnt; i++) {
            OrderItem orderItemRec = new OrderItem();
            orderItemRec.OrderId = ords[i].Id;
            orderItemRec.PriceBookEntryId = pbes[i].Id;
            orderItemRec.Quantity = Constants.DEFAULT_ROWS;
            orderItemRec.UnitPrice = 1;
            lOrderItems.add(orderItemRec);
        }

        return lOrderItems;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        insert constructCollaborationGroup();

        List<Product2> lProductRecs = constructProducts(cnt);
        insert lProductRecs;

        List<PricebookEntry> lPriceBookEntries = constructPricebookEntries(lProductRecs);
        insert lPriceBookEntries;

        List<Account> lAccountRecs = constructAccounts(cnt);
        insert lAccountRecs;
        insert constructContacts(cnt, lAccountRecs);

        List<Order> lOrderRecs = constructOrders(cnt, lAccountRecs);
        insert lOrderRecs;

        insert constructOrderItems(cnt, lPriceBookEntries, lOrderRecs);

    }

}