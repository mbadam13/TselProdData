// Created By Debora E P
// 13 October 2020

trigger Trigger_OrderProduct_Before_After_Delete on OrderItem (before delete) {
	
if(label.Trigger_OrderProduct_Before_After_Delete_On == 'YES'){
    
    for(OrderItem oi: trigger.old){
        
        AggregateResult[] usg_aggr = [SELECT sum(Amount__c) usg, Campaign_ID__c FROM Usage__c
                                      WHERE Bucket_Detail__c =: oi.Id
                                      GROUP BY Campaign_ID__c];
                    
        if(usg_aggr.size() == 1){
        
        	system.debug('*** usg_aggr[0].get(\'usg\') = ' + usg_aggr[0].get('usg'));
            
            Decimal usgAct = (Decimal)usg_aggr[0].get('usg');
            
            system.debug('*** usgAct = ' + usgAct);
            
            // Validasi tidak bisa delete Order Product jika sudah ada Usage Actual
            if(usgAct > 0){
            	oi.addError('Cannot delete Order Product if there is Usage Actual (' + usgAct + ')');
			}
		}else{
        	if(usg_aggr.size() > 1){
            	oi.addError('Check Usage : Multiple Campaign ID (' + usg_aggr.size() + ') for same Order Product.');
        	}
     	}    
    }
    
}
}