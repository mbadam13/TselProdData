/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 05-24-2024
 * @last modified by  : Doddy Prima
**/
trigger OpportunityProductTrigger on OpportunityLineItem (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
    new MetadataTriggerHandler().run();
}