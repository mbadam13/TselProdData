trigger Trigger_Insert_Site on Sites__c (after insert) {
    
if (label.Trigger_Insert_Site_On == 'YES') {
    
    for(Sites__c newSite : trigger.new){
        if(newSite.Account_Type__c == 'Publisher'){
            system.debug('*** Acc publisher call callout class to create site !!! ' + newSite.Id);
            TadexAPI_Site.createSite(newSite.Id);
        }
    }
    
}
    
}