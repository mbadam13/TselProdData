trigger DSPFeeTrigger on dsp_fee__c (before insert) {

    DSPFeeTriggerHandler DSPFeeTriggerHandlerClass = new DSPFeeTriggerHandler();
    if(Trigger.isInsert && Trigger.isBefore) {
        DSPFeeTriggerHandlerClass.OnBeforeInsert(Trigger.new);  
    }

}