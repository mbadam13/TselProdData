/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 05-19-2024
 * @last modified by  : Syaiful Syafani
**/
trigger OpportunityTrigger on Opportunity ( 
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    new MetadataTriggerHandler().run();
}