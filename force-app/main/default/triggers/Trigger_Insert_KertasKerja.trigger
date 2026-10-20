trigger Trigger_Insert_KertasKerja on Kertas_Kerja__c (after insert) {
	
if(Label.Trigger_Insert_KertasKerja_On == 'YES'){

    for(Kertas_Kerja__c kkRec : trigger.new){
        
        system.debug('*** kkRec.Kertas_Kerja_Name__c = ' + kkRec.Kertas_Kerja_Name__c);
        if(kkRec.Kertas_Kerja_Name__c == '' || kkRec.Kertas_Kerja_Name__c == null){
			
           	String msAccName = kkRec.Media_Seller_Name__c;
            
            String type_kk = '';
            
            if(kkRec.Type__c == 'Direct Sales'){
                type_kk = 'DS';
            }else if(kkRec.Type__c == 'Media Seller'){
                if(msAccName.contains('DWS')){
                    type_kk = 'DWS';
                }else if(msAccName.contains('Mustika')){
                    type_kk = 'MUS';
                }
            }
            system.debug('*** type_kk = ' + type_kk);
            
            String kkName = 'KKVS-' + type_kk + '-' + kkRec.Name.removeStart('KKM-') + '-' + kkRec.Month__c.left(3) + '-' + kkRec.Year__c.right(2);
            system.debug('*** kkName = ' + kkName);
            
            String kkUniqueKey = type_kk + '-' + kkRec.Year__c + '-' + kkRec.Month__c;
            system.debug('*** kkUniqueKey = ' + kkUniqueKey);
            
            List<Kertas_Kerja__c> kkList_check = [SELECT Id, Name, Kertas_Kerja_Name__c FROM Kertas_Kerja__c WHERE Unique_Key_KK__c =: kkUniqueKey]; 
            system.debug('*** kkList_check = ' + kkList_check);
            
            if(kkList_check.size() > 0){
                kkRec.addError('Duplicate Kertas Kerja record: "' + kkList_check[0].Kertas_Kerja_Name__c + '"');
            }else{
                Kertas_Kerja__c kkRecToUpdate = new Kertas_Kerja__c();
                kkRecToUpdate.Id = kkRec.Id;
                kkRecToUpdate.Kertas_Kerja_Name__c = kkName;
                kkRecToUpdate.Unique_Key_KK__c = kkUniqueKey;
                update kkRecToUpdate;
            }
            
        }
    }    
}
    
}