trigger Trigger_Update_BeritaAcara on Berita_Acara__c (before update, after update) {
    
if (label.Trigger_Update_BeritaAcara_On == 'YES') {
    
    for(Berita_Acara__c baRec : trigger.new){
        
        Berita_Acara__c baRecOld = Trigger.oldMap.get(baRec.Id);
        
        if(trigger.isBefore){
            
            if(baRec.Account__c != baRecOld.Account__c || baRec.Year__c != baRecOld.Year__c || baRec.Month__c != baRecOld.Month__c){
                baRec.addError('Account & Period (Month & Year) cannot be updated.');
            }
        }
        
        if(trigger.isAfter){
            
            if(baRec.Status__c == 'Shared' && baRec.Status__c != baRecOld.Status__c){
                
                List<Traffic__c> trafficList = [SELECT Id, Name FROM Traffic__c WHERE Berita_Acara__c =: baRec.Id];
                system.debug('*** trafficList = ' + trafficList.size() + ' | ' + trafficList);
                
                if(trafficList.size() > 0){
                    Tadex_ShareDocs.share_ba_traffic(baRec.Id);
                }else{
                    baRec.addError('There is no Traffic for this Berita Acara.');
                }
                
            }
        
        }
        
    }

}

}