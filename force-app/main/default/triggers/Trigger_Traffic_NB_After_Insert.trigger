/**
 * @description       : 
 * @Test Class        : Test_TH_Traffic_NB_TriggerHandler
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 06-16-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-23-2023   Novando Utoyo Agmawan   Initial Version
**/

trigger Trigger_Traffic_NB_After_Insert on Traffic_Non_Bulk__c (before insert, after insert, before update) {   
   if (label.Trigger_Traffic_NB_After_Insert_On== 'YES') {
      if(trigger.isbefore){
         if(trigger.isinsert){
            TH_Traffic_NB_TriggerHandler.beforeInsertHandler(Trigger.new);
         }

         if(trigger.isUpdate){
            TH_Traffic_NB_TriggerHandler.beforeInsertHandler(Trigger.new);
         }
      }
      
      /*if(trigger.isafter){
         if(trigger.isinsert){
               TH_Traffic_NB_TriggerHandler.afterInsertHandler(Trigger.new);
         }
      }*/
   }
}