/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-24-2023
 * @last modified by  : Diky Nurosid
**/
public with sharing class ProgrammaticTrafficServices {

    public static void evaluateProgrammaticTraffic(List<Programmatic_Traffic__c> progTrafficList){

        Set<String> brandSet = new Set<String>();
        Set<String> mitraSet = new Set<String>();
        Set<String> productNameSet = new Set<String>();
        Set<String> userNIKSet = new Set<String>();

        Map<String,product2> productMap = new Map<String,product2>();
        Map<String,Account> accountMap = new Map<String,Account>();
        map<string, user> userMap = new map <string, user>();

        for(Programmatic_Traffic__c progTrafficRec : progTrafficList){
            brandSet.add(progTrafficRec.Brand__c);
            productNameSet.add(progTrafficRec.Inventory__c);
            mitraSet.add(progTrafficRec.Mitra__c);
            if(progTrafficRec.Sales_NIK__c != null){
                userNIKSet.add(progTrafficRec.Sales_NIK__c);
            }
        }

        System.debug('userNIKSet ==> '+ userNIKSet);

        List<Account> accountList = [SELECT Id, User_ID__c, Name FROM Account WHERE User_ID__c IN :mitraSet];
        List<Product2> productList = [SELECT Id, Product_Name_MS__c, name FROM Product2 WHERE Product_Name_MS__c IN :productNameSet];
        list<user> userList = [SELECT id, username, nik__c FROM user WHERE nik__c IN: userNIKSet];

        for(user userListRec: userList){
            userMap.put(userListRec.nik__c, userListRec);
        } 

        for(Account accRec : accountList){
            accountMap.put(accRec.User_ID__c,accRec);
        }

        for(Product2 prodRec : productList){
            string productName = prodRec.Product_Name_MS__c; 
            productMap.put(productName.toLowerCase(), prodRec);
        }

        Map<String,Brand__c> brandMap = createOrUpdateBrands(brandSet);

        for(Programmatic_Traffic__c progTrafficRec : progTrafficList){
            date periode = progTrafficRec.periode__c;
            string accountName = (accountMap != null) ? accountMap.get(progTrafficRec.Mitra__c).name : null; 
            string brandName = (brandMap != null) ? brandMap.get(progTrafficRec.Brand__c).name : null; 
            string productName = (productMap != null) ? productMap.get(progTrafficRec.inventory__c.toLowerCase()).name : null; 
            String monthlyProgrammaticUniqueId = accountName + '_' + brandName + '_' + productName + '_' + string.valueOf(periode.year() + '-' + periode.month()) + '_' + progTrafficRec.channel__c + '_' + progTrafficRec.sales_nik__c;
            
            progTrafficRec.Inventory_Related__c = (productMap.get(progTrafficRec.Inventory__c.toLowerCase()) != null) ? productMap.get(progTrafficRec.Inventory__c.toLowerCase()).id : null;
            progTrafficRec.Brand_Related__c = (brandMap != null) ? brandMap.get(progTrafficRec.Brand__c).Id : null;
            progTrafficRec.Mitra_Related__c = (accountMap != null) ? accountMap.get(progTrafficRec.Mitra__c).id : null;
            progTrafficRec.sales__c = (userMap.get(progTrafficRec.Sales_NIK__c) != null) ? userMap.get(progTrafficRec.Sales_NIK__c).id : system.label.ProgrammaticSales;
            progTrafficRec.Monthly_Prog_Traffic_Unique_id__c = monthlyProgrammaticUniqueId;
           
        }
    }

    public static void createMonthlyProgrammaticTraffic(set<id> programmaticTrafficIds){
        try {
            system.debug('programmaticTrafficIds: ' + programmaticTrafficIds);
            set<date> periodeTraffic = new set<date>();
            set<String> uniqIdSet = new set<String>();
            list<Programmatic_Traffic__c> programmaticList = [
                SELECT id, Periode__c, date__c FROM Programmatic_Traffic__c WHERE Id IN:programmaticTrafficIds
            ];

            for(Programmatic_Traffic__c periodeTrafficValue :programmaticList){
                periodeTraffic.add(periodeTrafficValue.date__c);
            }

            Map<date, additional_setting__c> AdditionalforVATRecordMap = new Map<date, additional_setting__c>();
            Map<date, additional_setting__c> AdditionalforDiscountRecordMap = new Map<date, additional_setting__c>();
            Map<date, ExchangeRates__c> exchangeRateRecordMap = new Map<date, ExchangeRates__c>();

            if(!periodeTraffic.isEmpty()){
                for(date periodeTrafficValue :periodeTraffic){
                    additional_setting__c additionalVAT =  AppUtils.getAdditionalValue('VAT', 'VAT', periodeTrafficValue);
                    additional_setting__c additionalRevenueShare =  AppUtils.getAdditionalValue('Discount', 'Monthly_Programmatic_Traffic__c', periodeTrafficValue);
                    ExchangeRates__c exchangeRate =  (AppUtils.exchangeRateConversion(periodeTrafficValue) != null) ? AppUtils.exchangeRateConversion(periodeTrafficValue) : null;
    
                    AdditionalforVATRecordMap.put(periodeTrafficValue, additionalVAT);
                    exchangeRateRecordMap.put(periodeTrafficValue, exchangeRate);
                    AdditionalforDiscountRecordMap.put(periodeTrafficValue, additionalRevenueShare);
                }
            }
            

            map<string, user> userMap = new map <string, user>();
            list<user> userList = [select id, username, nik__c from user where nik__c != null];
            for(user userListRec: userList){
                userMap.put(userListRec.nik__c, userListRec);
            } 

            list<AggregateResult> programmaticTrafficAggregateList = [
                SELECT 
                mitra_related__r.name mitraName,
                mitra_related__c mitraRecordId,
                inventory_related__r.name inventoryName,
                inventory_related__c inventoryRecordId,
                date__c PeriodeDate,
                brand_related__r.name brandName,
                brand_related__c brandRecordId,
                channel__c channelName,
                Sales_NIK__c salesNik,

                SUM(Paid_Impression__c) sumImpression,
                SUM(Revenue__c) sumRevenue
                
                FROM Programmatic_Traffic__c

                where Monthly_Programmatic_Traffic__c = null 

                GROUP BY 
                mitra_related__r.name,
                mitra_related__c,
                inventory_related__r.name,
                inventory_related__c,
                date__c,
                brand_related__r.name,
                brand_related__c,
                channel__c,
                Sales_NIK__c
            ];

            for(AggregateResult proggramaticTrafficAggregateRec : programmaticTrafficAggregateList){
                Date periode = (Date) proggramaticTrafficAggregateRec.get('PeriodeDate');
                String monthlyProgrammaticUniqueId = (String) proggramaticTrafficAggregateRec.get('mitraName') + '_' + (String) proggramaticTrafficAggregateRec.get('brandName') + '_' + (String) proggramaticTrafficAggregateRec.get('inventoryName') + '_' + string.valueOf(periode.year() + '-' + periode.month()) + '_' + (String) proggramaticTrafficAggregateRec.get('channelName') + '_' + proggramaticTrafficAggregateRec.get('salesNik');
                uniqIdSet.add(monthlyProgrammaticUniqueId);
            }

            list<Monthly_Programmatic_Traffic__c> monthlyProgrammaticTraffictoUpdate = new list<Monthly_Programmatic_Traffic__c>();
            list<Monthly_Programmatic_Traffic__c> monthlyProgrammaticTraffictoinsert = new list<Monthly_Programmatic_Traffic__c>();
            list<Monthly_Programmatic_Traffic__c> monthlyProgrammaticTraffictoMapProgrammatic = new list<Monthly_Programmatic_Traffic__c>();

            Date periode;
            for(AggregateResult proggramaticTrafficAggregateRec : programmaticTrafficAggregateList){
                
                periode = (Date) proggramaticTrafficAggregateRec.get('PeriodeDate');
                user userMapRec = userMap.get((String) proggramaticTrafficAggregateRec.get('salesNik'));
                additional_setting__c AdditionalforDiscountRecordMapRec = AdditionalforDiscountRecordMap.get(date.newInstance(periode.year(), periode.month(), 1));                
                String monthlyProgrammaticUniqueId = (String) proggramaticTrafficAggregateRec.get('mitraName') + '_' + (String) proggramaticTrafficAggregateRec.get('brandName') + '_' + (String) proggramaticTrafficAggregateRec.get('inventoryName') + '_' + string.valueOf(periode.year() + '-' + periode.month()) + '_' + (String) proggramaticTrafficAggregateRec.get('channelName') + '_' + (String) proggramaticTrafficAggregateRec.get('salesNik');

                Monthly_Programmatic_Traffic__c monthlyProgrammaticRec = new Monthly_Programmatic_Traffic__c();
                monthlyProgrammaticRec.Inventory__c = (String) proggramaticTrafficAggregateRec.get('inventoryName');
                monthlyProgrammaticRec.Inventory_Related__c = (id) proggramaticTrafficAggregateRec.get('inventoryRecordId');
                monthlyProgrammaticRec.Paid_Impression__c = (Double) proggramaticTrafficAggregateRec.get('sumImpression');
                monthlyProgrammaticRec.Revenue__c = (Double) proggramaticTrafficAggregateRec.get('sumRevenue');
                monthlyProgrammaticRec.VAT_Related__c = AdditionalforVATRecordMap.get(periode).id;
                monthlyProgrammaticRec.Exchange_Rates_Related__c = exchangeRateRecordMap.get(periode).id;
                monthlyProgrammaticRec.Discount_related__c = (AdditionalforDiscountRecordMapRec != null) ? (AdditionalforDiscountRecordMapRec.channel__c == (String) proggramaticTrafficAggregateRec.get('channelName')) ? AdditionalforDiscountRecordMapRec.id : null : null; // TODO di filled in di customs Setting mungkin
                monthlyProgrammaticRec.Mitra__c = (Id) proggramaticTrafficAggregateRec.get('mitraRecordId');
                monthlyProgrammaticRec.Brand__c = (id) proggramaticTrafficAggregateRec.get('brandRecordId');
                monthlyProgrammaticRec.Periode__c = date.newInstance(periode.year(), periode.month(), 1);
                monthlyProgrammaticRec.unique_id__c = monthlyProgrammaticUniqueId;
                monthlyProgrammaticRec.Channel__c = (string) proggramaticTrafficAggregateRec.get('channelName');
                monthlyProgrammaticRec.Sales__c = (userMapRec != null) ? userMapRec.id : '0052v00000fyt9BAAQ'; //'0052v00000fyt9BAAQ'; //TODO: put the value in custo setting 

                monthlyProgrammaticTraffictoinsert.add(monthlyProgrammaticRec);
            }

            Map<String,Monthly_Programmatic_Traffic__c> existmonthlyProgrammaticMap = new Map<String,Monthly_Programmatic_Traffic__c>();
            list<Monthly_Programmatic_Traffic__c> existmonthlyProgrammaticTraffic = [
                SELECT id, 
                Paid_Impression__c,
                unique_id__c,
                Revenue__c FROM Monthly_Programmatic_Traffic__c 
                WHERE unique_id__c IN :uniqIdSet
            ];

            for(Monthly_Programmatic_Traffic__c existmonthlyProgTrafficRec : existmonthlyProgrammaticTraffic){
                existmonthlyProgrammaticMap.put(existmonthlyProgTrafficRec.unique_id__c, existmonthlyProgTrafficRec);
            }
            
            list<Monthly_Programmatic_Traffic__c> monthlyProgrammaticTrafficFinaltoinsert = new list<Monthly_Programmatic_Traffic__c>();
            for(Monthly_Programmatic_Traffic__c monthlyProgrammaticTraffictoinsertRec :monthlyProgrammaticTraffictoinsert){
                Monthly_Programmatic_Traffic__c existMonthlyProgrammaticRec = existmonthlyProgrammaticMap.get(monthlyProgrammaticTraffictoinsertRec.unique_id__c);
                if(existMonthlyProgrammaticRec != null){
                    existMonthlyProgrammaticRec.Paid_Impression__c = existMonthlyProgrammaticRec.Paid_Impression__c + monthlyProgrammaticTraffictoinsertRec.Paid_Impression__c ; // (Double) proggramaticTrafficAggregateRec.get('sumImpression');
                    existMonthlyProgrammaticRec.Revenue__c = existMonthlyProgrammaticRec.Revenue__c + monthlyProgrammaticTraffictoinsertRec.Revenue__c;
                    
                    update existMonthlyProgrammaticRec;
                    monthlyProgrammaticTraffictoMapProgrammatic.add(existMonthlyProgrammaticRec);
                }else{
                    monthlyProgrammaticTrafficFinaltoinsert.add(monthlyProgrammaticTraffictoinsertRec);
                }
            }

            insert  monthlyProgrammaticTrafficFinaltoinsert; 

            for(Monthly_Programmatic_Traffic__c monthlyProgrammaticTrafficFinaltoinsertRec :monthlyProgrammaticTrafficFinaltoinsert){
                monthlyProgrammaticTraffictoMapProgrammatic.add(monthlyProgrammaticTrafficFinaltoinsertRec);
            }

            if(!monthlyProgrammaticTraffictoMapProgrammatic.isEmpty()){
                mapMonthlytoTrafficProgrammatic(monthlyProgrammaticTraffictoMapProgrammatic);
            }
        } catch (Exception e) {
            String errMessage = 'Error on ProgrammaticTrafficServices.createMonthlyProgrammaticTraffic ::' + e.getMessage() + '::' + e.getLineNumber();
            System.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    } 

    /*
    // exisint do not repalces
    public static void createMonthlyProgrammaticTraffic(set<id> programmaticTrafficIds){
        system.debug('programmaticTrafficIds: ' + programmaticTrafficIds);
        set<date> periodeTraffic = new set<date>();
        set<String> uniqIdSet = new set<String>();
        list<Programmatic_Traffic__c> programmaticList = [
            SELECT id, Periode__c FROM Programmatic_Traffic__c WHERE Id IN:programmaticTrafficIds
        ];

        for(Programmatic_Traffic__c periodeTrafficValueu :programmaticList){
            periodeTraffic.add(periodeTrafficValueu.periode__c);
        }

        Map<date, additional_setting__c> AdditionalforVATRecordMap = new Map<date, additional_setting__c>();
        Map<date, ExchangeRates__c> exchangeRateRecordMap = new Map<date, ExchangeRates__c>();

        for(date periodeTrafficValue :periodeTraffic){
            additional_setting__c additionalVAT =  AppUtils.getAdditionalValue('VAT', 'VAT', periodeTrafficValue);
            ExchangeRates__c exchangeRate =  AppUtils.exchangeRateConversion(periodeTrafficValue);

            AdditionalforVATRecordMap.put(periodeTrafficValue, additionalVAT);
            exchangeRateRecordMap.put(periodeTrafficValue, exchangeRate);
        }

        list<AggregateResult> programmaticTrafficList = [
            SELECT 
            mitra_related__r.name mitraName,
            mitra_related__c mitraRecordId,
            inventory_related__r.name inventoryName,
            inventory_related__c inventoryRecordId,
            periode__c PeriodeDate,
            brand_related__r.name brandName,
            brand_related__c brandRecordId,
            channel__c channelName,

            SUM(Paid_Impression__c) sumImpression,
            SUM(Revenue__c) sumRevenue
            
            FROM Programmatic_Traffic__c

            where Monthly_Programmatic_Traffic__c = null 

            GROUP BY 
            mitra_related__r.name,
            mitra_related__c,
            inventory_related__r.name,
            inventory_related__c,
            periode__c,
            brand_related__r.name,
            brand_related__c,
            channel__c 
        ];

        for(AggregateResult proggramaticTrafficAggregateRec : programmaticTrafficList){
            Date periode = (Date) proggramaticTrafficAggregateRec.get('PeriodeDate');
            String monthlyProgrammaticUniqueId = (String) proggramaticTrafficAggregateRec.get('mitraName') + '_' + (String) proggramaticTrafficAggregateRec.get('brandName') + '_' + (String) proggramaticTrafficAggregateRec.get('inventoryName') + '_' + string.valueOf(periode.year() + '-' + periode.month()) + '_' + (string) proggramaticTrafficAggregateRec.get('channelName');
            uniqIdSet.add(monthlyProgrammaticUniqueId);
        }

        Map<String,Monthly_Programmatic_Traffic__c> existmonthlyProgrammaticMap = new Map<String,Monthly_Programmatic_Traffic__c>();
        list<Monthly_Programmatic_Traffic__c> existmonthlyProgrammaticTraffic = [
            SELECT id, Paid_Impression__c,Revenue__c FROM Monthly_Programmatic_Traffic__c WHERE unique_id__c IN:uniqIdSet
        ];

        for(Monthly_Programmatic_Traffic__c existmonthlyProgTrafficRec : existmonthlyProgrammaticTraffic){
            existmonthlyProgrammaticMap.put(existmonthlyProgTrafficRec.unique_id__c,existmonthlyProgTrafficRec);
        }

        list<Monthly_Programmatic_Traffic__c> monthlyProgrammaticTraffictoUpsert = new list<Monthly_Programmatic_Traffic__c>();
        for(AggregateResult proggramaticTrafficAggregateRec : programmaticTrafficList){
          
            Date periode = (Date) proggramaticTrafficAggregateRec.get('PeriodeDate');
            String monthlyProgrammaticUniqueId = (String) proggramaticTrafficAggregateRec.get('mitraName') + '_' + (String) proggramaticTrafficAggregateRec.get('brandName') + '_' + (String) proggramaticTrafficAggregateRec.get('inventoryName') + '_' + string.valueOf(periode.year() + '-' + periode.month()) + '_' + (String) proggramaticTrafficAggregateRec.get('channelName');
            
            if(existmonthlyProgrammaticMap.containsKey(monthlyProgrammaticUniqueId)){
                Monthly_Programmatic_Traffic__c existMonthlyProgrammaticRec = existmonthlyProgrammaticMap.get(monthlyProgrammaticUniqueId);
                existMonthlyProgrammaticRec.Paid_Impression__c += (Double) proggramaticTrafficAggregateRec.get('sumImpression');
                existMonthlyProgrammaticRec.Revenue__c += (Double) proggramaticTrafficAggregateRec.get('sumRevenue');
                monthlyProgrammaticTraffictoUpsert.add(existMonthlyProgrammaticRec);
            }else{
                Monthly_Programmatic_Traffic__c monthlyProgrammaticRec = new Monthly_Programmatic_Traffic__c();
                monthlyProgrammaticRec.Inventory__c = (String) proggramaticTrafficAggregateRec.get('inventoryName');
                monthlyProgrammaticRec.Inventory_Related__c = (id) proggramaticTrafficAggregateRec.get('inventoryRecordId');
                monthlyProgrammaticRec.Paid_Impression__c = (Double) proggramaticTrafficAggregateRec.get('sumImpression');
                monthlyProgrammaticRec.Revenue__c = (Double) proggramaticTrafficAggregateRec.get('sumRevenue');
                monthlyProgrammaticRec.VAT_Related__c = AdditionalforVATRecordMap.get(periode).id;
                monthlyProgrammaticRec.Exchange_Rates_Related__c = exchangeRateRecordMap.get(periode).id;
                monthlyProgrammaticRec.Share_Revenue__c = 80; // TODO di filled in di customs Setting mungkin
                monthlyProgrammaticRec.Mitra__c = (Id) proggramaticTrafficAggregateRec.get('mitraRecordId');
                monthlyProgrammaticRec.Brand__c = (id) proggramaticTrafficAggregateRec.get('brandRecordId');
                monthlyProgrammaticRec.Periode__c = periode;
                monthlyProgrammaticRec.unique_id__c = monthlyProgrammaticUniqueId;
                monthlyProgrammaticRec.Sales__c = '0052v00000fyt9BAAQ'; //TODO: put the value in custo setting 

                monthlyProgrammaticTraffictoUpsert.add(monthlyProgrammaticRec);
            }
        }

        if(!monthlyProgrammaticTraffictoUpsert.isEmpty()){
            UPSERT monthlyProgrammaticTraffictoUpsert unique_id__c;

            mapMonthlytoTrafficProgrammatic(monthlyProgrammaticTraffictoUpsert);
        }
    } 
    */

   /** Private */
    private static Map<String, Brand__c> createOrUpdateBrands(Set<String> nameSet){
        Map<String,Brand__c> brandNameMap = new Map<String,Brand__c>();
        
        try {
            List<Brand__c> newBrandList = new List<Brand__c>();
            String pubmaticAccount = System.label.Account_PubmaticInc; 
            List<Brand__c> existBrandList = [
                SELECT Id, Name, Advertiser__c
                FROM Brand__c
                WHERE Name IN :nameSet AND Advertiser__c = :pubmaticAccount
            ];

            system.debug('existBrandList: ' + existBrandList);
            if(!existBrandList.isEmpty()){
                for(Brand__c brandRec: existBrandList){
                    brandNameMap.put(brandRec.Name,brandRec);
                }
            }

            for(string nameExctract :nameSet){
                if(brandNameMap.get(nameExctract) == null){
                    Brand__c newBrand = new Brand__c();
                    newBrand.Name = nameExctract;
                    newBrand.Advertiser__c = pubmaticAccount;
                    newBrandList.add(newBrand);
                }
            }
            
            system.debug('newBrandList: ' + json.serialize(newBrandList));
            
            if (!newBrandList.isEmpty()) {
                insert newBrandList;
                for (Brand__c brandRec : newBrandList) {
                    brandNameMap.put(brandRec.Name, brandRec);
                }
            } 
            
            
        } catch (Exception e) {
            String errMessage = 'Error on programmaticservices.createOrUpdateBrands function::' + e.getMessage() + '::' + e.getLineNumber();
            System.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
        
        return brandNameMap;
    }  

    private static void mapMonthlytoTrafficProgrammatic(list<Monthly_Programmatic_Traffic__c> monthlyProggramaticTrafficList){
        System.debug('MASUK UPDATE UNIQUE ID DI PROGRAMMATIC');
        set<String> monthlyProggramaticTrafficUniqueIds = new set<String>();
        map<string, Monthly_Programmatic_Traffic__c> monthlyProggramaticTrafficRecordMap = new map<string, Monthly_Programmatic_Traffic__c>();

        for(Monthly_Programmatic_Traffic__c monthlyProggramaticTrafficListRec :monthlyProggramaticTrafficList){
            monthlyProggramaticTrafficUniqueIds.add(monthlyProggramaticTrafficListRec.unique_id__c);
            monthlyProggramaticTrafficRecordMap.put(monthlyProggramaticTrafficListRec.unique_id__c, monthlyProggramaticTrafficListRec);
        }

        List<Programmatic_Traffic__c> programmaticTrafficList = [
            SELECT id,
            brand_related__r.name,
            mitra_related__r.name,
            inventory_related__r.name,
            periode__c,
            sales_nik__c,
            channel__c, 
            Monthly_Programmatic_Traffic__c,
            Monthly_Prog_Traffic_Unique_id__c
            FROM Programmatic_Traffic__c  
            WHERE Monthly_Programmatic_Traffic__c = NULL
        ];

        List<Programmatic_Traffic__c> programmaticTrafficListtoUpdate = new list<Programmatic_Traffic__c>();
        for(Programmatic_Traffic__c  programmaticTrafficListRec :programmaticTrafficList){
            String monthlyProggramaticTrafficUniqueId = programmaticTrafficListRec.mitra_related__r.name + '_' + programmaticTrafficListRec.brand_related__r.name + '_' +  programmaticTrafficListRec.inventory_related__r.name + '_' + string.valueOf(programmaticTrafficListRec.periode__c.year() + '-' + programmaticTrafficListRec.periode__c.month()) + '_' + programmaticTrafficListRec.channel__c + '_' + programmaticTrafficListRec.sales_nik__c;
            Monthly_Programmatic_Traffic__c monthlyProggramaticTrafficRecord = monthlyProggramaticTrafficRecordMap.get(monthlyProggramaticTrafficUniqueId);
            //programmaticTrafficListRec.Monthly_Prog_Traffic_Unique_id__c = (monthlyProggramaticTrafficRecord != null) ? monthlyProggramaticTrafficRecord.unique_id__c : null;
            programmaticTrafficListRec.Monthly_Programmatic_Traffic__c = (monthlyProggramaticTrafficRecord != null) ? monthlyProggramaticTrafficRecord.id : null;
            
            programmaticTrafficListtoUpdate.add(programmaticTrafficListRec);
        }

        if(!programmaticTrafficListtoUpdate.isEmpty()){
            update programmaticTrafficListtoUpdate;
        }
    }
    
}