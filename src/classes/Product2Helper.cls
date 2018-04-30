public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name =: Constants.INVENTORY_ANNOUNCEMENTS 
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> newList,List<Product2> oldList){
		List<Product2> needsAnnouncement = new List<Product2>();
		Map<String,Inventory_Setting__mdt> inventorySettingMap = new Map<String,Inventory_Setting__mdt>();
        for(Inventory_Setting__mdt inventorySetting : [SELECT DeveloperName,Id,Low_Quantity_Alert__c FROM Inventory_Setting__mdt]){
            inventorySettingMap.put(inventorySetting.DeveloperName,inventorySetting);
        }
        System.debug('inventorySettingMap===='+inventorySettingMap);
        for(Integer i=0;i<newList.size();i++){
            String oldProdFamily = oldList[i].Family;
            String newProdFamily = newList[i].Family;
            Decimal oldProdCount = oldList[i].Quantity_Remaining__c;
            Decimal newProdCount = newList[i].Quantity_Remaining__c;
            if((inventorySettingMap.containskey(oldProdFamily) || inventorySettingMap.containskey(newProdFamily)) && 
              (inventorySettingMap.get(oldProdFamily).Low_Quantity_Alert__c < oldProdCount && inventorySettingMap.get(newProdFamily).Low_Quantity_Alert__c > newProdCount)){
                needsAnnouncement.add(newList[i]);
            }
        }
        PostAlerts(needsAnnouncement);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = p.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;
            messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            messageInput.messageSegments.add(textSegment);
            // ToDo: Construct a new AnnouncementInput for the Chatter Group so that it:
            ConnectApi.AnnouncementInput announcement = new ConnectApi.AnnouncementInput();
            announcement.sendEmails = false;
            announcement.body = messageInput;
            announcement.expirationDate = Date.today().addDays(1);
            announcement.parentId  = COLLABORATION_GROUP[0].Id;
        }
         AnnouncementQueueable q = new AnnouncementQueueable(toPost);
         System.enqueueJob(q);
    }
}