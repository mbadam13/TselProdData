/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 08-26-2024
 * @last modified by  : Syaiful Syafani
**/
trigger RequestForProposalTrigger on Request_for_proposal__c (
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