/**
* @description       : 
* @author            : Diky Nurosid
* @group             : 
* @last modified on  : 10-20-2023
* @last modified by  : Ahmat Zulkifli Murad
* Modifications Log 
* Ver  Modification
* 1.0  Change Logic Account to Brand
**/
public with sharing class TTDTrafficServices {
    public static final String accountTTd = System.label.Account_TTD;
    
    public static void createMonthlyTtdTraffic(List<TTD_Traffic__c> newTTDTraffics){
        DSP_TTD_Product_Settings__c DSPProductIdSetting = DSP_TTD_Product_Settings__c.getValues('DMP TTD');
        Set<Id> ttdIds = new Set<Id>();
        Set<String> uniqueKeys = new Set<String>();
        Set<String> userIds = new Set<String>();
        Map<String,String> accountNameMap = new Map<String,String>();
        List<MonthlyTTDTraffic__c> newMonthlyTTdList = new List<MonthlyTTDTraffic__c>();
        set<date> periodeTraffic = new set<date>();
        
        for (TTD_Traffic__c ttdTraffic : newTTDTraffics) {
            String accountName = ttdTraffic.Advertiser__c;
            String userId = ttdTraffic.Advertiser__c;
            if(accountName != null){
                accountName = accountName.substringBefore('(');
            }
            if(userId != null){
                userId = userId.substringBetween('(', ')');
                userIds.add(userId);
                accountNameMap.put(userId,accountName);
            }
             ttdIds.add(ttdTraffic.Id);
             if(ttdTraffic.Date__c != null){
                periodeTraffic.add(ttdTraffic.Date__c);
             }
            
        }
        
        Map<date, additional_setting__c> AdditionalforVATRecordMap = new Map<date, additional_setting__c>();
        Map<date, ExchangeRates__c> exchangeRateRecordMap = new Map<date, ExchangeRates__c>();
        Map<date, additional_setting__c> AdditionalforDiscountRecordMap = new Map<date, additional_setting__c>();
        
        if(!periodeTraffic.isEmpty()){
            for(date periodeTrafficValue :periodeTraffic){
                additional_setting__c additionalVAT =  AppUtils.getAdditionalValue('VAT', 'VAT', periodeTrafficValue);
                additional_setting__c additionalDiscount =  AppUtils.getAdditionalValue('discount', 'MonthlyTTDTraffic__c', periodeTrafficValue);
                ExchangeRates__c exchangeRate = (AppUtils.exchangeRateConversion(periodeTrafficValue) != null) ? AppUtils.exchangeRateConversion(periodeTrafficValue) : null;
                
                AdditionalforVATRecordMap.put(periodeTrafficValue, additionalVAT);
                exchangeRateRecordMap.put(periodeTrafficValue, exchangeRate);
                AdditionalforDiscountRecordMap.put(periodeTrafficValue, additionalDiscount);
            }
        }
        
        Map<String, Brand__c> brandUserIdMap = createOrUpdateBrands(userIds, accountNameMap); 
        List <AggregateResult> ttdTrafficResult = [
            SELECT Advertiser__c advertiser
            ,SUM(ImpressionCount__c) impression, SUM(TotalDataCostInUSD__c) dataCostUSD
            ,date__c date
            ,Sales__c sales
            ,SalesNik__c salesNIK
            FROM TTD_Traffic__c
            WHERE Id IN :ttdIds
            GROUP BY Advertiser__c, date__c, Sales__c, SalesNik__c
        ];
        //Id VAT = AppUtils.VAT();
        
        system.debug('ttdTrafficResult: ' + json.serialize(ttdTrafficResult));
        for(AggregateResult ttdResultRec: ttdTrafficResult){
            String advertiser = (String) ttdResultRec.get('advertiser');
            Date datePeriod = (Date) ttdResultRec.get('date');
            if(datePeriod != null){
                String monthDate = string.valueOf(datePeriod.month());
                String yearDate = string.valueOf(datePeriod.year());
                string uniqueKey = yearDate + '/' + monthDate + '/' + advertiser;
                uniqueKeys.add(uniqueKey);
            }
          
        }
        
        List<MonthlyTTDTraffic__c> monthlyTTDTraffics = [
            SELECT Id, Advertiser__c, Date__c, UniqueKey__c,ImpressionCount__c,TotalDataCostInUSD__c
            FROM MonthlyTTDTraffic__c
            WHERE UniqueKey__c IN :uniqueKeys
        ];
        
        Map<String, MonthlyTTDTraffic__c> monthlyTTDTrafficsMap = new Map<String, MonthlyTTDTraffic__c>();
        for (MonthlyTTDTraffic__c monthlyTTDTraffic : monthlyTTDTraffics) {
            monthlyTTDTrafficsMap.put(monthlyTTDTraffic.UniqueKey__c, monthlyTTDTraffic);
        }
        
        list<monthlyTTDTraffic__c> monthlyTTDTraffictoUpdate = new list<monthlyTTDTraffic__c>();
        list<monthlyTTDTraffic__c> monthlyTTDraffictoinsert = new list<monthlyTTDTraffic__c>();
        
        for(AggregateResult ttdResultRec: ttdTrafficResult){
            
            String advertiser = (String) ttdResultRec.get('advertiser');
            Date datePeriod = (Date) ttdResultRec.get('date');
            string uniqueKey;
            if(datePeriod != null){
                String monthDate = string.valueOf(datePeriod.month());
                String yearDate = string.valueOf(datePeriod.year());
                uniqueKey = yearDate + '/' + monthDate + '/' + advertiser;
            }
          
            String userId = (advertiser != null) ? advertiser.substringBetween('(', ')') : null;
            Decimal impressionCollected = (Decimal) ttdResultRec.get('impression');
            Decimal dataCostUsd = (Decimal) ttdResultRec.get('dataCostUSD');
            String sales = (String) ttdResultRec.get('sales');
            String nik = (String) ttdResultRec.get('salesNIK');
            
            //ExchangeRates__c exchangeRate = AppUtils.exchangeRateConversion(datePeriod);
            MonthlyTTDTraffic__c newMonthlyTTDTraffic = new MonthlyTTDTraffic__c();
            newMonthlyTTDTraffic.Advertiser__c = advertiser;
            newMonthlyTTDTraffic.Date__c = datePeriod;
            newMonthlyTTDTraffic.Account__c = accountTTd; 
            newMonthlyTTDTraffic.Brand__c = (brandUserIdMap.get(userId) != null ) ? brandUserIdMap.get(userId).Id : null ;
            newMonthlyTTDTraffic.product__c = String.valueOf(DSPProductIdSetting.Product_Id__c);
            newMonthlyTTDTraffic.UniqueKey__c = uniqueKey;
            newMonthlyTTDTraffic.ImpressionCount__c = impressionCollected;
            newMonthlyTTDTraffic.TotalDataCostInUSD__c = dataCostUsd;
            newMonthlyTTDTraffic.VATRelated__c = (datePeriod != null ) ? AdditionalforVATRecordMap.get(datePeriod).id : null;
            newMonthlyTTDTraffic.discount_related__c = (datePeriod != null) ? AdditionalforDiscountRecordMap.get(datePeriod).id : null;
            newMonthlyTTDTraffic.Sales__c = sales;
            newMonthlyTTDTraffic.Sales_Nik__c = nik;
            newMonthlyTTDTraffic.ExchangeRatesRelated__c = (datePeriod != null) ? exchangeRateRecordMap.get(datePeriod).id : null;
            System.debug('mttd ==> '+ json.serialize(newMonthlyTTDTraffic));
            monthlyTTDraffictoinsert.add(newMonthlyTTDTraffic);
        }
        
        Map<String, monthlyTTDTraffic__c> existmonthlyTTDTrafficMap = new Map<String, monthlyTTDTraffic__c>();
        list<monthlyTTDTraffic__c> existmonthlyProgrammaticTraffic = [
            SELECT id, 
            Impressioncount__c,
            uniquekey__c,
            totaldatacostinusd__c FROM monthlyTTDTraffic__c 
            WHERE uniquekey__c IN :uniqueKeys
        ];
        
        for(monthlyTTDTraffic__c existmonthlyTTDTrafficRec : existmonthlyProgrammaticTraffic){
            existmonthlyTTDTrafficMap.put(existmonthlyTTDTrafficRec.uniquekey__c, existmonthlyTTDTrafficRec);
        }
        list<monthlyTTDTraffic__c> monthlyTTDTrafficFinaltoinsert = new list<monthlyTTDTraffic__c>();
        for(monthlyTTDTraffic__c monthlyTTDraffictoinsertRec :monthlyTTDraffictoinsert){
            monthlyTTDTraffic__c existMonthlyProgrammaticRec = existmonthlyTTDTrafficMap.get(monthlyTTDraffictoinsertRec.uniquekey__c);
            if(existMonthlyProgrammaticRec != null){
                existMonthlyProgrammaticRec.Impressioncount__c = existMonthlyProgrammaticRec.Impressioncount__c + monthlyTTDraffictoinsertRec.Impressioncount__c ; // (Double) proggramaticTrafficAggregateRec.get('sumImpression');
                existMonthlyProgrammaticRec.totaldatacostinusd__c = existMonthlyProgrammaticRec.totaldatacostinusd__c + monthlyTTDraffictoinsertRec.totaldatacostinusd__c;
                update existMonthlyProgrammaticRec;
               // monthlyTTDTraffictoUpdate.add(existMonthlyProgrammaticRec);
            }else{
                monthlyTTDTrafficFinaltoinsert.add(monthlyTTDraffictoinsertRec);
            }
        }
        // if(!monthlyTTDTraffictoUpdate.isEmpty()){
        //     update monthlyTTDTraffictoUpdate;
        // }

        insert  monthlyTTDTrafficFinaltoinsert; 
        
        Map<string, MonthlyTTDTraffic__c> existingMonthlyTTDTrafficMap = new Map<string, MonthlyTTDTraffic__c>();
        list<MonthlyTTDTraffic__c> existingMonthlyTTDTrafficList = [
            SELECT id, UniqueKey__c 
            FROM MonthlyTTDTraffic__c 
            WHERE UniqueKey__c in: uniqueKeys
        ];
        
        if(!existingMonthlyTTDTrafficList.isEmpty()){
            for(MonthlyTTDTraffic__c existingMonthlyClientTTDListRec :existingMonthlyTTDTrafficList){
                existingMonthlyTTDTrafficMap.put(existingMonthlyClientTTDListRec.UniqueKey__c, existingMonthlyClientTTDListRec);
            }
        }
        
        List<TTD_Traffic__c> ttdTraffictoUpdateList = new List<TTD_Traffic__c>();
        List<TTD_Traffic__c> newTTDTrafficList = [
            SELECT 
            id, 
            date__c, 
            advertiser__c 
            FROM TTD_Traffic__c 
            WHERE id in:ttdIds
        ];
        
        for(TTD_Traffic__c newTTDTrafficsRec :newTTDTrafficList){
            String monthDate = (newTTDTrafficsRec.date__c != null) ? string.valueOf(newTTDTrafficsRec.date__c.month()) : null;
            String yearDate = (newTTDTrafficsRec.date__c != null) ? string.valueOf(newTTDTrafficsRec.date__c.year()) : null;
            String userId = (newTTDTrafficsRec.advertiser__c != null ) ? newTTDTrafficsRec.advertiser__c.substringBetween('(', ')') : null;
            String accountName = (newTTDTrafficsRec.advertiser__c != null) ? newTTDTrafficsRec.advertiser__c.substringBefore('(') : null;
            string uniqueKey = yearDate + '/' + monthDate + '/' + newTTDTrafficsRec.advertiser__c;
            
            newTTDTrafficsRec.MonthlyTTDTraffic__c = existingMonthlyTTDTrafficMap.get(uniqueKey).id;
            newTTDTrafficsRec.Brand__c = (brandUserIdMap.get(userId) != null ) ? brandUserIdMap.get(userId).Id : null ;
            newTTDTrafficsRec.Account__c = accountTTd;
            ttdTraffictoUpdateList.add(newTTDTrafficsRec);
        }
        
        if(!ttdTraffictoUpdateList.isEmpty()){
            update ttdTraffictoUpdateList;
        }
    }

    public static void userMappingWithNik(List<TTD_Traffic__c> newTTDTraffics){
        Set<String> nikSet = new Set<String>();
        Map<String,Id> nikSalesMap = new Map<String,Id>();
        for(TTD_Traffic__c ttdTraffic : newTTDTraffics){
            nikSet.add(ttdTraffic.SalesNik__c);
        }
        
        List<User> userSales = [SELECT Id,NIK__c FROM User WHERE NIK__c IN : nikSet];
        for(User userRec: userSales){
            nikSalesMap.put(userRec.NIK__c,userRec.Id);
        }
        
        for(TTD_Traffic__c ttdTraffic : newTTDTraffics){
            string uniqueKey;
            Date datePeriod = ttdTraffic.date__c;

            if(datePeriod != null){
                String monthDate = string.valueOf(datePeriod.month());
                String yearDate = string.valueOf(datePeriod.year());
                uniqueKey = yearDate + '/' + monthDate + '/' + ttdTraffic.Advertiser__c;
            }
            
            ttdTraffic.Sales__c = nikSalesMap.get(ttdTraffic.SalesNik__c);
            ttdTraffic.Monthly_TTD_Traffic_Unique_ID__c = uniqueKey;
        }
    }
    
    /*
    public static void updateMonthlyTraffic(List<TTD_Traffic__c> newTTDTraffics,List<TTD_Traffic__c> oldTTDTraffics){
        Set<Id> monthlyIds = new Set<Id>();
        Map<Id,TTD_Traffic__c> oldMap = new Map<Id,TTD_Traffic__c>(oldTTDTraffics);
        
        for(TTD_Traffic__c ttdRec : newTTDTraffics){
            monthlyIds.add(ttdRec.MonthlyTTDTraffic__c);
        }
        
        List <AggregateResult> ttdTrafficResult = [
            SELECT Advertiser__c advertiser
            ,SUM(ImpressionCount__c) impression, SUM(TotalDataCostInUSD__c) dataCostUSD
            ,date__c date
            ,Sales__c sales
            FROM TTD_Traffic__c
            WHERE MonthlyTTDTraffic__c IN :monthlyIds
            GROUP BY Advertiser__c, date__c, Sales__c
        ];
        
        List<MonthlyTTDTraffic__c> monthlyTTDTraffics = [
            SELECT Id,UniqueKey__c,ImpressionCount__c,TotalDataCostInUSD__c
            FROM MonthlyTTDTraffic__c
            WHERE Id IN :monthlyIds
        ];
        
        Map<Id, MonthlyTTDTraffic__c> monthlyTTDTrafficsMap = new Map<Id, MonthlyTTDTraffic__c>();
        for (MonthlyTTDTraffic__c monthlyTTDTraffic : monthlyTTDTraffics) {
            monthlyTTDTrafficsMap.put(monthlyTTDTraffic.UniqueKey__c, monthlyTTDTraffic);
        }
        
        List<MonthlyTTDTraffic__c> monthlyList = new List<MonthlyTTDTraffic__c>();
        for(AggregateResult ttdRec : ttdTrafficResult){
            String advertiser = (String) ttdRec.get('advertiser');
            Date datePeriod = (Date) ttdRec.get('date');
            String monthDate = string.valueOf(datePeriod.month());
            String yearDate = string.valueOf(datePeriod.year());
            string uniqueKey = yearDate + '/' + monthDate + '/' + advertiser;
            
            Decimal newImpressionValue = (Decimal) ttdRec.get('impression');
            Decimal newTotalDataCostValue = (Decimal) ttdRec.get('dataCostUSD');
            
            MonthlyTTDTraffic__c existingMonthlyTTDTraffic = monthlyTTDTrafficsMap.get(uniqueKey);
            existingMonthlyTTDTraffic.ImpressionCount__c = newImpressionValue;
            existingMonthlyTTDTraffic.TotalDataCostInUSD__c = newTotalDataCostValue;
            monthlyList.add(existingMonthlyTTDTraffic);
        }
        update monthlyList;
    }
    */
    
    /** Private */
    private static Map<String, Brand__c> createOrUpdateBrands(Set<String> userIds,Map<String,String> accountNameMap){
        system.debug('userIds: ' +userIds); 
        Map<String,Brand__c> brandUserIdMap = new Map<String,Brand__c>();
        List<Brand__c> newBrandList = new List<Brand__c>();
        
        List<Brand__c> existBrandList = [
            SELECT Id,User_Id__c
            FROM Brand__c
            WHERE User_Id__c IN :userIds
        ];
        
        system.debug('existBrandList: ' + existBrandList);
        if(!existBrandList.isEmpty()){
            for(Brand__c brandRec: existBrandList){
                brandUserIdMap.put(brandRec.User_Id__c,brandRec);
            }
        }
        
        for(string userIdsValues :userIds){
            system.debug('userIdsValues : ' + userIdsValues);
            if(brandUserIdMap.get(userIdsValues) == null){
                Brand__c newBrand = new Brand__c();
                newBrand.Name = accountNameMap.get(userIdsValues);
                newBrand.User_Id__c = userIdsValues;
                newBrand.Advertiser__c = String.valueOf(System.label.Account_TTD);
                newBrandList.add(newBrand);
            }
        }
        
        system.debug('newBrandList: ' + json.serialize(newBrandList));
        
        if (!newBrandList.isEmpty()) {
            insert newBrandList;
            for (Brand__c brandRec : newBrandList) {
                brandUserIdMap.put(brandRec.User_Id__c, brandRec);
            }
        } 
        
        return brandUserIdMap;
    }
    
    
    
}