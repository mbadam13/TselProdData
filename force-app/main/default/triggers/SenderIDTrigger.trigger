trigger SenderIDTrigger on SID_Tools__c (Before insert, Before Update, After Update) {
if (label.Trigger_SenderIDTrigger_On== 'YES') { 
    
	if(Trigger.isBefore){
        // Call Methods for Before Triggers.      
        // Call After Insert methods.
        //if(Trigger.isInsert || Trigger.isUpdate ){
       
        if(Trigger.isInsert){
           BlacklistedHandler.blacklistmethod(Trigger.new); // aktifkan saat sudah tidak ada migrasi SID Tools
           
           TH_SID_Tools_TriggerHandler.setUpInfoPNV(Trigger.new);
        }
        
        if(Trigger.isUpdate){
            
           BlacklistedHandler.blacklistmethodUpdate(Trigger.new); // aktifkan saat sudah tidak ada migrasi SID Tools
           TH_SID_Tools_TriggerHandler.setUpInfoPNV(Trigger.new);
			
            for(SID_Tools__c sidTools_rec : Trigger.New){
                
                SID_Tools__c oldSid = Trigger.oldMap.get(sidTools_rec.Id);
                
                string recordTypeName = Schema.getGlobalDescribe().get('SID_Tools__c').getDescribe().getRecordTypeInfosById().get(sidTools_rec.RecordTypeId).getName();
                system.debug('*** recordTypeName = ' + recordTypeName);
                
                if(recordTypeName == 'PNV'){
                    if(sidTools_rec.Status__c == 'Partnership Verification' && oldSid.Status__c != 'Partnership Verification'){
                    	system.debug('*** status jadi Partnership Verification !!');
                        List<ContentDocumentLink> pnvdoc_list = [SELECT Id, ContentDocumentId, LinkedEntityId, LinkedEntity.Name 
                                                             	 FROM ContentDocumentLink 
                                                             	 WHERE LinkedEntityId =: sidTools_rec.Id];
                        system.debug('*** pnvdoc_list = ' + pnvdoc_list.size() + ' | ' + pnvdoc_list);
                        if(pnvdoc_list.size() > 0){
							sidTools_rec.PNV_Attachment__c = pnvdoc_list.size();
                        }else{
                            sidTools_rec.addError('Please attach document CIF/EULA.');
                        }

                    }
                }
            }
        }
	}
	
	if(Trigger.isAfter){
        /*if(Trigger.isInsert){
            system.debug('after Insert SenderIDTrigger');
             TH_SID_Tools_TriggerHandler.generateSID(Trigger.new);
        }*/
        
        if(Trigger.isUpdate){
            for(SID_Tools__c sidTools_rec : Trigger.New){
                system.debug('*** SenderIDTrigger AfterUpdate Id & SID_Approval__c = ' + sidTools_rec.Id + ' | ' + sidTools_rec.SID_Approval__c);
                SID_Tools__c oldSid = Trigger.oldMap.get(sidTools_rec.Id);
                if(sidTools_rec.SID_Approval__c == 'Approved' && oldSid.SID_Approval__c != 'Approved'){
                    system.debug('*** SID_Approval__c Appproved !');
                    PrivyId_SID.sendPrivyId_SID(sidTools_rec.Id);
                }  
            }
            
           // TH_SID_Tools_TriggerHandler.generateSID(Trigger.new);
        }
    }
    
}
}