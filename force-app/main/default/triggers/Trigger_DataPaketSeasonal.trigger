trigger Trigger_DataPaketSeasonal on Data_Paket_Seasonal__c (before insert, after insert) {
    if (label.Trigger_DataPaketSeasonal == 'YES') {
        
         if(trigger.isAfter){ 
            if(trigger.isInsert){
                TH_DataPaketSeasonal_TriggerHandler.afterInsertDataPaket(Trigger.new);
            }
        }
          if(trigger.isBefore){
            if(trigger.isInsert){
                TH_DataPaketSeasonal_TriggerHandler.beforeInsertDataPaket(Trigger.new);  
            }
        }
    }
}