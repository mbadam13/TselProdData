/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-08-2024
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-08-2024   Novando Utoyo Agmawan   Initial Version
**/

trigger MediaOrderItemTrigger on Media_Order_Item__c ( 
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