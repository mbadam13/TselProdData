trigger Trigger_Update_BMC on Business_Model_Category__c (before update) {
	
    List<Demand_Source_Information__c> dsiList = [SELECT Id, Name, Demand_Source__c, Share__c FROM Demand_Source_Information__c];
    system.debug('*** dsiList = ' + dsiList.size() + ' | ' + dsiList);
    Map<String,Demand_Source_Information__c> mapdsi_id_rec = new Map<String,Demand_Source_Information__c>();
    for(Demand_Source_Information__c dsiRec : dsiList){
        mapdsi_id_rec.put(dsiRec.Id,dsiRec);
    }
    system.debug('*** mapdsi_id_rec = ' + mapdsi_id_rec.size() + ' | ' + mapdsi_id_rec);
    
    for(Business_Model_Category__c bmcRec : trigger.new){
        bmcRec.Demand_Source__c = mapdsi_id_rec.get(bmcRec.Demand_Source_Information__c).Demand_Source__c;
        bmcRec.Percentage__c = mapdsi_id_rec.get(bmcRec.Demand_Source_Information__c).Share__c;
    }
}