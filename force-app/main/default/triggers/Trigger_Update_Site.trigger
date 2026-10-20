trigger Trigger_Update_Site on Sites__c (after update) {
    
if (label.Trigger_Update_Site_On == 'YES') {
    
    for(Sites__c siteRec : trigger.new){
        
        Sites__c oldSiteRec = Trigger.oldMap.get(siteRec.Id);
        
        // Hit create ad tag saat status "Request ad tag"
        system.debug('*** siteRec Site_ID__c | Status__c = ' + siteRec.Site_ID__c + ' | ' +  siteRec.Status__c);
        if(siteRec.Account_Type__c == 'Publisher' && siteRec.Status__c == 'Request Ad Tag' && siteRec.Status__c != oldSiteRec.Status__c){
            
            if(siteRec.Site_ID__c != '' && siteRec.Site_ID__c != null ){
            
                List<Ad_Tag__c> adTagListToHit = [SELECT Id, Name, Ad_Tag_ID__c FROM Ad_Tag__c WHERE Sites__c =: siteRec.Id];
                for(Ad_Tag__c adtagrec : adTagListToHit){
                    if(adtagrec.Ad_Tag_ID__c == '' || adtagrec.Ad_Tag_ID__c == null){
                        system.debug('**** Hit api adtagrec ' + adtagrec.Name + ' | ' + adtagrec.Id);
                        TadexAPI_AdTag.createAdTag(adtagrec.Id);
                    }
                }
                
            }else{
                siteRec.addError('Please provide Site ID before update Status to "Request Ad Tag"');
            }
        }
    }
    
}

}