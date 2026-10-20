/*
	Created by Victor & Andre
	7 September 2022
*/

global class BatchGenerateAdexMonthly implements Database.batchable<sObject>, Database.Stateful{
    String query;
    Map<String, Decimal> AdSpendMap = new Map<String, Decimal>();
    Map<String, Decimal> AdImpMap = new Map<String, Decimal>();
    Map<String, Decimal> CountDataMap = new Map<String, Decimal>();
    List<Adex_Transaction_Monthly__c> listAdexTransactionMonthly = new List<Adex_Transaction_Monthly__c>();
    
    //date untuk last month
    Date targetDate = date.today().addmonths(-1); // last month
    String month = string.ValueOf(targetDate.month());
    String year = string.ValueOf(targetDate.year());
    
    global Database.querylocator start(Database.BatchableContext BC){
        query = 'SELECT id, name, Grouping_Identifier__c, AdSpend__c, Section__c, Category__c, Advertiser__c, Brand_Name__c, Brand_Type__c, Week__c, Month__c, Year__c, Adex_Brand__c, Inventory_Type__c, Buy_Type__c, AdImp__c, Product__c FROM Adex_Transaction_Weekly__c WHERE Month__c = \''+month+'\' AND Year__c = \''+year+'\' ';
        
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext info, List<Adex_Transaction_Weekly__c> listAdexTransactionWeekly){
        for (Adex_Transaction_Weekly__c myAdexTransactionWeekly : listAdexTransactionWeekly) {
            if(AdSpendMap.containsKey(myAdexTransactionWeekly.Grouping_Identifier__c)){
                // Calculate AdSpend
                Decimal valueAdSpend = AdSpendMap.get(myAdexTransactionWeekly.Grouping_Identifier__c) + myAdexTransactionWeekly.AdSpend__c;
                AdSpendMap.put(myAdexTransactionWeekly.Grouping_Identifier__c, valueAdSpend);
                
                // Calculate AdImp
                Decimal valueAdImp = AdImpMap.get(myAdexTransactionWeekly.Grouping_Identifier__c) + myAdexTransactionWeekly.AdImp__c;
                AdImpMap.put(myAdexTransactionWeekly.Grouping_Identifier__c, valueAdImp);
                
                // Counting Data
                Decimal valueCountData = CountDataMap.get(myAdexTransactionWeekly.Grouping_Identifier__c) + 1;
                CountDataMap.put(myAdexTransactionWeekly.Grouping_Identifier__c, valueCountData);
            } else if(!AdSpendMap.containsKey(myAdexTransactionWeekly.Grouping_Identifier__c)){
                AdSpendMap.put(myAdexTransactionWeekly.Grouping_Identifier__c, myAdexTransactionWeekly.AdSpend__c);
                AdImpMap.put(myAdexTransactionWeekly.Grouping_Identifier__c, myAdexTransactionWeekly.AdImp__c);
                CountDataMap.put(myAdexTransactionWeekly.Grouping_Identifier__c, 1);
                
                Adex_Transaction_Monthly__c newAdexTransactionMonthly = new Adex_Transaction_Monthly__c();
                newAdexTransactionMonthly.Section__c = myAdexTransactionWeekly.Section__c;
                newAdexTransactionMonthly.Category__c   = myAdexTransactionWeekly.Category__c;
                newAdexTransactionMonthly.Advertiser__c = myAdexTransactionWeekly.Advertiser__c;
                newAdexTransactionMonthly.Brand_Name__c = myAdexTransactionWeekly.Brand_Name__c;
                newAdexTransactionMonthly.Brand_Type__c = myAdexTransactionWeekly.Brand_Type__c;
                newAdexTransactionMonthly.month__c = myAdexTransactionWeekly.Month__c;
                newAdexTransactionMonthly.year__c = myAdexTransactionWeekly.Year__c;
                newAdexTransactionMonthly.AdSpend__c = 0;
                newAdexTransactionMonthly.Count_Data__c = 0; 
                newAdexTransactionMonthly.Adex_Brand__c = myAdexTransactionWeekly.Adex_Brand__c;
                newAdexTransactionMonthly.Inventory_Type__c = myAdexTransactionWeekly.Inventory_Type__c;
                newAdexTransactionMonthly.Buy_Type__c = myAdexTransactionWeekly.Buy_Type__c;
                newAdexTransactionMonthly.Product__c = myAdexTransactionWeekly.Product__c;
                newAdexTransactionMonthly.AdImp__c = 0;
                
                listAdexTransactionMonthly.add(newAdexTransactionMonthly);
            }
        }
        
        for(Adex_Transaction_Monthly__c myAdexTransactionMonthly : listAdexTransactionMonthly){
            String groupIdentifier = myAdexTransactionMonthly.Section__c+'|'+myAdexTransactionMonthly.Category__c+'|'+myAdexTransactionMonthly.Advertiser__c+'|'+myAdexTransactionMonthly.Brand_Name__c+'|'+myAdexTransactionMonthly.Brand_Type__c+'|'+myAdexTransactionMonthly.Month__c+'|'+myAdexTransactionMonthly.Adex_Brand__c+'|'+myAdexTransactionMonthly.Inventory_Type__c+'|'+myAdexTransactionMonthly.Buy_Type__c;
            groupIdentifier = groupIdentifier.trim().toLowerCase();
            Decimal valueAdSpend =  AdSpendMap.get(groupIdentifier);
            Decimal valueAdImp =  AdImpMap.get(groupIdentifier);
            Decimal valueCountData = CountDataMap.get(groupIdentifier);            
            
            myAdexTransactionMonthly.AdSpend__c = valueAdSpend;
            myAdexTransactionMonthly.AdImp__c = valueAdImp;
            myAdexTransactionMonthly.Count_Data__c = valueCountData;
        }
    }
    
    global void finish(Database.BatchableContext info){
    	insert listAdexTransactionMonthly;
    	
    }
}