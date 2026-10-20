/**
 * @description       : 
 * @Test Class        : Test_TH_Traffic_SID_TriggerHandler
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 06-27-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-23-2023   Novando Utoyo Agmawan   Initial Version
**/

trigger Trigger_Traffic_SID_After_Insert  on Traffics_SID__c (before insert, before update) {    
  if (label.Trigger_Traffic_SID_After_Insert_On== 'YES'){
    if(trigger.isbefore){
      if(trigger.isinsert){
        TH_Traffic_SID_TriggerHandler.beforeInsertHandler(Trigger.new);
      }

      if(trigger.isUpdate){
          TH_Traffic_SID_TriggerHandler.beforeInsertHandler(Trigger.new); // TODO: perlu di handle ketika ada update amount atau apapun itu akan kepanggil terus untuk set harga        
      }
    }

    /*if(trigger.isafter){
      if(trigger.isinsert){
        TH_Traffic_SID_TriggerHandler.afterInsertHandler(Trigger.new);
      }
      if(trigger.isupdate){
        TH_Traffic_SID_TriggerHandler.afterInsertHandler(Trigger.new);
      }
    }*/
  }
}