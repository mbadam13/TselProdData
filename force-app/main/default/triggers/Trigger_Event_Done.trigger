trigger Trigger_Event_Done on Event (after update) {
if (label.Trigger_Event_Done_On== 'YES') {    
    if(trigger.isupdate)
    {

      if(trigger.isAfter) {
        for(Event eventNew : system.trigger.new){
        Event eventOld=Trigger.oldMap.get(eventNew.id);
          
          system.debug('======= eventNew.Result__c : ' + eventNew.Result__c);
          system.debug('======= eventOld.Result__c : ' + eventOld.Result__c);
          
          if (eventNew.Result__c == 'Done' && eventOld.Result__c <> 'Done' ) {
            system.debug('======= do Process when Done after update');
            
            //-- do calculation Selling Actual
            Calculation_Controller cc = new Calculation_Controller();
            string id = cc.calcVisitActual(eventNew.ID,eventNew.ownerId, eventNew.Activity_Date__c);
          }
        }
        
      }
    }
  }
}