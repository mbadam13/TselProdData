trigger Trigger_Contract on Contract (After update) {
    if (label.Trigger_Contract == 'YES') { 
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                system.debug('trigger.contract >> after update');
                Stamping_Contract_Info.updateContractDateonAccount(Trigger.new);
            }
            
        }
    }
}