trigger Trigger_Insert_DPC on Data_Performance_Campaign__c (after insert) {
    
if(Label.Trigger_Insert_DPC_On == 'YES'){
    
    for(Data_Performance_Campaign__c dpcRec : trigger.new){
        
        Performance_Campaign__c pc_rec = [SELECT Id, Name, Campaign_Name__r.Name FROM Performance_Campaign__c WHERE Id =: dpcRec.Performance_Campaign__c];
        
        Historical_Campaign_Performance__c hpc_rec = new Historical_Campaign_Performance__c();
		hpc_rec.Date__c = dpcRec.Date__c;
        hpc_rec.Campaign_Name__c = pc_rec.Campaign_Name__r.Name;
        hpc_rec.Impression__c = dpcRec.Impression__c;
        hpc_rec.Sunk_Cost__c = dpcRec.Sunk_Cost__c;
        hpc_rec.Revenue__c = dpcRec.Revenue__c;
        hpc_rec.P_L__c = dpcRec.P_L__c;
        hpc_rec.P_L_Percentage__c = dpcRec.P_L_Percentage__c;
        insert hpc_rec;
        
        Data_Performance_Campaign__c dpc_rec = new Data_Performance_Campaign__c();
        dpc_rec.Id = dpcRec.Id;
        dpc_rec.Historical_Campaign_Performance__c = hpc_rec.Id;
        update dpc_rec;
    }
    
}
    
}