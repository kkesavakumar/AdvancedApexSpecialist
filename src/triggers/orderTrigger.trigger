/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after update) {
    
    if(trigger.isUpdate){
        if(trigger.isAfter) {
            OrderHelper.AfterUpdate(trigger.new,trigger.old);
        }
    }
}