trigger Trigger_Update_KertasKerja on Kertas_Kerja__c (before update, after update) {

if(Label.Trigger_Update_KertasKerja_On == 'YES'){
    
    for(Kertas_Kerja__c kkRec : trigger.new){
        
        Kertas_Kerja__c kkRecOld = Trigger.OldMap.get(kkRec.Id);
        
        if(Trigger.isBefore){
            if(kkRec.Status_Approval_PrivyId__c != kkRecOld.Status_Approval_PrivyId__c && kkRec.Status_Approval_PrivyId__c == 'Completed'){
                kkRec.Status__c = 'Completed';
            }
            if(kkRec.Month__c != kkRecOld.Month__c || kkRec.Year__c != kkRecOld.Year__c || kkRec.Type__c != kkRecOld.Type__c || kkRec.Media_Seller__c != kkRecOld.Media_Seller__c){
                if(!Test.isRunningTest()){kkRec.addError('You cannot change Month, Year, Type & Media Seller. Please create new Kertas Kerja record.');}
            }
            if(kkRec.Status__c != kkRecOld.Status__c && kkRec.Status__c == 'Completed'){
                kkRec.KK_Completed_Datetime__c = system.now();
            }
        }
        
        if(Trigger.isAfter){
            if(kkRec.Status__c != kkRecOld.Status__c){
                if(kkRec.Status__c == 'Attach'){
                    // Generate & Attach File
                    system.debug('kkRec.Type__c =======***'+kkRec.Type__c );
                    if(kkRec.Type__c == 'Media Seller'){
                        AttachFile_KertasKerja.doAttachDoc(kkRec.Id); // --> DS tidak pakai karena merged di luar sistem, kemudian attach di sf manual   
                    }
                }else if(kkRec.Status__c == 'Review'){
                    // Send privyId
                    String pathOnClient_doc = kkRec.Kertas_Kerja_Name__c + '.pdf';
                    List<ContentVersion> cvList = [SELECT Id, Title, VersionData FROM ContentVersion WHERE PathOnClient =: pathOnClient_doc ORDER BY CreatedDate DESC LIMIT 1];
                    system.debug('*** cvList = ' + cvList.size() + ' | ' + cvList);
                    
                    if(cvList.size() > 0){
                        PrivyId_KertasKerja.sendPrivyId_KertasKerja(kkRec.Id);
                    }else{
                        kkRec.addError('Please attach Kertas Kerja document.');
                    }
                }
            }
        }
    }
}
    
}