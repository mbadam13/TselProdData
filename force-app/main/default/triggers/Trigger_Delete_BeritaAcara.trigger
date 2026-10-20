trigger Trigger_Delete_BeritaAcara on Berita_Acara__c (before delete) {
    
if (label.Trigger_Delete_BeritaAcara_On == 'YES') {
    
    for(Berita_Acara__c oldBaRec : trigger.old){
        
        List<Traffic__c> trfList = [SELECT Id, Name FROM Traffic__c WHERE Berita_Acara__c =: oldBaRec.Id];
        
        if(trfList.size() > 0){
            oldBaRec.addError('There is Traffic data for this Berita Acara, so it cannot be deleted.');
        }
    }
    
}

}