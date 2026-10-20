/*
	Created by Victor
	25 January 2022
*/

global class BatchGenerateAdex implements Database.batchable<sObject>{
	List<Adex_Brand__c> listAdexBrand = new List<Adex_Brand__c>();
	List<Adex_Brand__c> listNewAdexBrand = new List<Adex_Brand__c>();
	Map<String, Id> wholeAdexBrand = new Map<String, Id>();
	List<Adex_Transaction__c> listAdexTransaction = new List<Adex_Transaction__c>();
	String query;
	
    global Database.querylocator start(Database.BatchableContext BC){
    	query = 'SELECT id, Identifier__c, Section__c, Category__c, Advertiser__c, Brand_Name__c, Brand_Type__c FROM Adex_Transaction__c WHERE Adex_Brand__c = NULL AND CreatedDAte >= LAST_WEEK AND CreatedDAte <= THIS_WEEK';
    	
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<Adex_Transaction__c> listAdexTransaction){
    	listAdexBrand = [SELECT id, Identifier__c FROM Adex_Brand__c];
    	listNewAdexBrand = new List<Adex_Brand__c>();
    	
    	// Mapping existing adex brand
    	for(Adex_Brand__c myAdexBrand : listAdexBrand){
    		wholeAdexBrand.put(myAdexBrand.Identifier__c , myAdexBrand.id);
    	}
    	
    	// Check existing or not adex brand, if not then insert new adex brand
    	AggregateResult[] listAdexTransactionUnique = [SELECT count(id), Section__c, Category__c, Advertiser__c, Brand_Name__c, Brand_Type__c FROM Adex_Transaction__c WHERE Adex_Brand__c = NULL AND CreatedDAte >= LAST_WEEK AND CreatedDAte <= THIS_WEEK GROUP BY Section__c, Category__c, Advertiser__c, Brand_Name__c, Brand_Type__c LIMIT 2000];
    	for(AggregateResult myAdexTransactionUnique : listAdexTransactionUnique){
    		String newUniqIdentifier = string.valueOf(myAdexTransactionUnique.get('Section__c'))+'|'+string.valueOf(myAdexTransactionUnique.get('Category__c'))+'|'+string.valueOf(myAdexTransactionUnique.get('Advertiser__c'))+'|'+string.valueOf(myAdexTransactionUnique.get('Brand_Name__c'))+'|'+string.valueOf(myAdexTransactionUnique.get('Brand_Type__c'));
    		newUniqIdentifier = newUniqIdentifier.trim().toLowerCase();
    		Id idAdexBrand = wholeAdexBrand.get(newUniqIdentifier);
    		if(idAdexBrand == null){
    			Adex_Brand__c newAdexBrand = new Adex_Brand__c();
    			newAdexBrand.Section__c = string.valueOf(myAdexTransactionUnique.get('Section__c'));
    			newAdexBrand.Category__c = string.valueOf(myAdexTransactionUnique.get('Category__c'));
    			newAdexBrand.Advertiser__c = string.valueOf(myAdexTransactionUnique.get('Advertiser__c'));
    			newAdexBrand.Brand_Name__c = string.valueOf(myAdexTransactionUnique.get('Brand_Name__c'));
    			newAdexBrand.Brand_Type__c = string.valueOf(myAdexTransactionUnique.get('Brand_Type__c'));
    			
    			listNewAdexBrand.add(newAdexBrand);
    		}
    	}
		insert listNewAdexBrand;
    	
    	// Re-mapping new adex brand
		for(Adex_Brand__c myAdexBrand : listNewAdexBrand){
			String newUniqIdentifier = myAdexBrand.Section__c+'|'+myAdexBrand.Category__c+'|'+myAdexBrand.Advertiser__c+'|'+myAdexBrand.Brand_Name__c+'|'+myAdexBrand.Brand_Type__c;
			newUniqIdentifier = newUniqIdentifier.trim().toLowerCase();
			wholeAdexBrand.put(newUniqIdentifier , myAdexBrand.id);
		}
    	
    	for(Adex_Transaction__c newAdexTransaction : listAdexTransaction){
    		Id idAdexBrand = wholeAdexBrand.get(newAdexTransaction.Identifier__c);
			newAdexTransaction.Adex_Brand__c = idAdexBrand;
    	}
    	update listAdexTransaction;
    }
    
    global void finish(Database.BatchableContext info){
    	
    }
}