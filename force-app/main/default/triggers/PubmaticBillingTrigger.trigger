trigger PubmaticBillingTrigger on pubmatic_billing__c (before update) {

    PubmaticBillingTriggerHandler PubmaticBillingTriggerHandlerClass = new PubmaticBillingTriggerHandler();
    if(Trigger.isUpdate && Trigger.isBefore){
        PubmaticBillingTriggerHandlerClass.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
}