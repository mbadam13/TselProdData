/**
 * @description       : HANDLER FOR LEAD TRIGGER
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : RKA
**/
public without sharing class LeadTriggerHandler extends METriggerHandler {
    LeadManagerHandler mh = new LeadManagerHandler();

    protected override void beforeInsert(){
        mh.beforeInsert((List<Lead>) Trigger.new);
    }

    protected override void beforeUpdate(){
        mh.beforeUpdate((List<Lead>) Trigger.new);
    }

    protected override void beforeDelete() {
        mh.beforeDelete((List<Lead>) Trigger.Old);
    }


    protected override void afterInsert(){
        mh.afterInsert((List<Lead>) Trigger.new);
    }

    protected override void afterUpdate(){
        mh.afterUpdate((List<Lead>) Trigger.new);
    }

    protected override void afterDelete() {
        mh.afterDelete((List<Lead>) Trigger.Old);
    }
}