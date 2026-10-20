/*
    Created by Victor & Andre
    5 September 2022
*/

global class BatchGenerateAdexWeekly implements Database.batchable<sObject>, Database.Stateful{
    String query;
    Map<String, Decimal> AdSpendMap = new Map<String, Decimal>();
    Map<String, Decimal> AdImpMap = new Map<String, Decimal>();
    Map<String, Decimal> CountDataMap = new Map<String, Decimal>();
    List<Adex_Transaction_Weekly__c> listAdexTransactionWeekly = new List<Adex_Transaction_Weekly__c>();
    List<Adex_Transaction_Weekly__c> listLimitAdexTransactionWeekly = new List<Adex_Transaction_Weekly__c>();
    public Integer executeWeek;
    
    global Database.querylocator start(Database.BatchableContext BC){
        query = 'SELECT id, name, date__c, Grouping_Identifier__c, AdSpend__c, Section__c, Category__c, Advertiser__c, Brand_Name__c, Brand_Type__c, Week_Per_Month__c, Adex_Brand__c, Inventory_Type__c, Buy_Type__c, AdImp__c, Product__c FROM Adex_Transaction__c WHERE date__c = LAST_N_MONTHS:1 AND Week_Per_Month__c =\''+executeWeek+'\''; //last n month:1
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<Adex_Transaction__c> listAdexTransaction){
        for(Adex_Transaction__c myAdexTransaction : listAdexTransaction) {
            if(AdSpendMap.containsKey(myAdexTransaction.Grouping_Identifier__c)){
                // Calculate AdSpend
                Decimal valueAdSpend = AdSpendMap.get(myAdexTransaction.Grouping_Identifier__c) + myAdexTransaction.AdSpend__c;
                AdSpendMap.put(myAdexTransaction.Grouping_Identifier__c, valueAdSpend);
                
                // Calculate AdImp
                Decimal valueAdImp = AdImpMap.get(myAdexTransaction.Grouping_Identifier__c) + myAdexTransaction.AdImp__c;
                AdImpMap.put(myAdexTransaction.Grouping_Identifier__c, valueAdImp);
                
                // Counting Data
                Decimal valueCountData = CountDataMap.get(myAdexTransaction.Grouping_Identifier__c) + 1;
                CountDataMap.put(myAdexTransaction.Grouping_Identifier__c, valueCountData);
            } else if(!AdSpendMap.containsKey(myAdexTransaction.Grouping_Identifier__c)){
                AdSpendMap.put(myAdexTransaction.Grouping_Identifier__c, myAdexTransaction.AdSpend__c);
                AdImpMap.put(myAdexTransaction.Grouping_Identifier__c, myAdexTransaction.AdImp__c);
                CountDataMap.put(myAdexTransaction.Grouping_Identifier__c, 1);
                Date myDate = myAdexTransaction.Date__c;
                String month = String.valueOf(myDate.Month());
                String year = String.valueOf(myDate.Year());
                
                Adex_Transaction_Weekly__c newAdexTransactionWeekly = new Adex_Transaction_Weekly__c();
                newAdexTransactionWeekly.Section__c = myAdexTransaction.Section__c;
                newAdexTransactionWeekly.Category__c   = myAdexTransaction.Category__c;
                newAdexTransactionWeekly.Advertiser__c = myAdexTransaction.Advertiser__c;
                newAdexTransactionWeekly.Brand_Name__c = myAdexTransaction.Brand_Name__c;
                newAdexTransactionWeekly.Brand_Type__c = myAdexTransaction.Brand_Type__c;
                newAdexTransactionWeekly.month__c = month;
                newAdexTransactionWeekly.year__c = year;
                newAdexTransactionWeekly.AdSpend__c = 0;
                newAdexTransactionWeekly.Week__c = myAdexTransaction.Week_Per_Month__c; 
                newAdexTransactionWeekly.Count_Data__c = 0; 
                newAdexTransactionWeekly.Adex_Brand__c = myAdexTransaction.Adex_Brand__c;
                newAdexTransactionWeekly.Inventory_Type__c = myAdexTransaction.Inventory_Type__c;
                newAdexTransactionWeekly.Buy_Type__c = myAdexTransaction.Buy_Type__c;
                newAdexTransactionWeekly.Product__c = myAdexTransaction.Product__c;
                newAdexTransactionWeekly.AdImp__c = 0;
                
                listAdexTransactionWeekly.add(newAdexTransactionWeekly);
            }
        }
        
        for(Adex_Transaction_Weekly__c myAdexTransactionWeekly : listAdexTransactionWeekly){
            String groupIdentifier = myAdexTransactionWeekly.Section__c+'|'+myAdexTransactionWeekly.Category__c+'|'+myAdexTransactionWeekly.Advertiser__c+'|'+myAdexTransactionWeekly.Brand_Name__c+'|'+myAdexTransactionWeekly.Brand_Type__c+'|'+myAdexTransactionWeekly.Week__c+'|'+myAdexTransactionWeekly.Adex_Brand__c+'|'+myAdexTransactionWeekly.Inventory_Type__c+'|'+myAdexTransactionWeekly.Buy_Type__c;
            groupIdentifier = groupIdentifier.trim().toLowerCase();
            Decimal valueAdSpend =  AdSpendMap.get(groupIdentifier);
            Decimal valueAdImp =  AdImpMap.get(groupIdentifier);
            Decimal valueCountData = CountDataMap.get(groupIdentifier);
            
            myAdexTransactionWeekly.AdSpend__c = valueAdSpend;
            myAdexTransactionWeekly.AdImp__c = valueAdImp;
            myAdexTransactionWeekly.Count_Data__c = valueCountData;
        }
    }
    
    global void finish(Database.BatchableContext info){
        insert listAdexTransactionWeekly;
    }
}