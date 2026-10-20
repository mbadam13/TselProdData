/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-12-2023
 * @last modified by  : Diky Nurosid
**/
trigger MonthlyTTDTrigger on MonthlyTTDTraffic__c (before insert, after insert, after update) {
  //  try {

        if(trigger.isBefore && trigger.isInsert){
       //     MonthlyTTDTriggerHandler.beforeInsert(trigger.new);
        }

        if(trigger.isAfter && trigger.isInsert){
            MonthlyTTDTriggerHandler.afterInsert(Trigger.new);
        }

        if(trigger.isAfter && trigger.isUpdate){
            MonthlyTTDTriggerHandler.afterUpdate(Trigger.new, Trigger.Old);
        }
        
 //   } catch (Exception e) {
 //       string errMessage = 'Error on MonthlyTTDTrigger  function::' + e.getmessage() + '::' + e.getLineNumber() ;
 //       system.debug('==================== error message : ' + errMessage);
 //       AppUtils.putError(errMessage );
 //   }
}