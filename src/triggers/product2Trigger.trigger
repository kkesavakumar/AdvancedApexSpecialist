/**
 * @name product2Trigger
 * @description Trigger to notify staff of low levels of inventory
**/
trigger product2Trigger on Product2 (after update) {
    
    if(trigger.isupdate){
        if(trigger.isAfter){
            Product2Helper.AfterUpdate(trigger.new, trigger.old);
        }
    }
}