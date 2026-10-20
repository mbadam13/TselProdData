/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class ClientTrafficServices {
   
    
    public static void evaluateClientTraffic(List<Client_Traffic__c> clientTrafficList){
        Set<String> userIdSet = new Set<String>();
        Set<String> brandSet = new Set<String>();
        Set<String> productNameSet = new Set<String>();
        Map<String,Id> accountMap = new Map<String,Id>();
        Map<String,Id> brandWithAdvMap = new Map<String,Id>();
        Map<String,Id> productMap = new Map<String,Id>();
        Map<String,Id> salesMap = userMappingWithNik(clientTrafficList);
        for(Client_Traffic__c clientTrafficRec : clientTrafficList){
            userIdSet.add(clientTrafficRec.ID__c);
            productNameSet.add(clientTrafficRec.Tipe_Kanal__c+' '+clientTrafficRec.Kategori_Iklan__c);
            brandSet.add(clientTrafficRec.brand__c);
        }

     //   List<Brand__c> brandList = [SELECT Id, Name FROM Brand__c WHERE Name IN : brandSet];
        List<Account> accountList = [SELECT Id,User_ID__c FROM Account WHERE User_ID__c IN :userIdSet];
        List<Product2> productList = [SELECT Id,Product_Name_MS__c FROM Product2 WHERE Product_Name_MS__c IN :productNameSet];

        for(Account accRec : accountList){
            accountMap.put(accRec.User_ID__c,accRec.Id);
        }

        for(Product2 prodRec : productList){
            string productName = prodRec.Product_Name_MS__c; 
            productMap.put(productName.toLowerCase(), prodRec.Id);
        }

        Map<String,Brand__c> brandMap = createOrUpdateBrands(clientTrafficList,brandSet,accountMap);
        
        for(Client_Traffic__c clientTrafficRec : clientTrafficList){
            String productNameMS = clientTrafficRec.Tipe_Kanal__c + ' ' + clientTrafficRec.Kategori_Iklan__c;
            String valueStr = clientTrafficRec.Detil_Status__c;
            string uniqueId = clientTrafficRec.brand__c + '_' + productNameMS + '_' + string.valueOf(clientTrafficRec.tgl_tayang__c.year() + '-' + clientTrafficRec.tgl_tayang__c.month()) + '_' + clientTrafficRec.sales_nik__c;

            if (valueStr.contains('.')) {
                valueStr = valueStr.replace('.', '');
            }
            String[] parts = valueStr.split(' ');
            Integer suksesValue;
            Integer gagalValue;

            for (Integer i = 0; i < parts.size(); i++) {
                if (parts[i] == 'Sukses:') {
                    suksesValue = Integer.valueOf(parts[i+1]);
                } else if (parts[i] == 'Gagal:') {
                    gagalValue = Integer.valueOf(parts[i+1]);
                }
            }
            clientTrafficRec.Product_Name__c = productNameMS;
            clientTrafficRec.Traffic_Failed__c = gagalValue;
            clientTrafficRec.Traffic_Success__c = suksesValue;
           // clientTrafficRec.Order_Quantity__c = suksesValue+gagalValue;
            clientTrafficRec.Company_Name__c = accountMap.get(clientTrafficRec.ID__c);
            clientTrafficRec.Product_Related__c = productMap.get(productNameMS.toLowerCase());
            clientTrafficRec.Sales__c = salesMap.get(clientTrafficRec.Sales_Nik__c);
            clientTrafficRec.Monthly_Client_Traffic_Unique_ID__c = uniqueId;
            clientTrafficRec.Brand_Related__c = brandMap.get(clientTrafficRec.brand__c).Id;
        }
        //createBrand(clientTrafficList, accountMap);
    }

    private static Map<String, Brand__c> createOrUpdateBrands(List<Client_Traffic__c> clientTrafficList,Set<String> brandNameSet, Map<String,Id> accountMap){
        Map<String,Brand__c> brandNameMap = new Map<String,Brand__c>();
        
        try {
           Map<String,Id> brandWithAdvertiserMap = new Map<String,Id>();
            Set<Id> advertiserIds = new Set<Id>();
            for(Client_Traffic__c clientTrafficRec : clientTrafficList){
                Id advertiserId = (Id) accountMap.get(clientTrafficRec.ID__c);
                advertiserIds.add(advertiserId);
                brandWithAdvertiserMap.put(clientTrafficRec.Brand__c,advertiserId);
            }

            List<Brand__c> newBrandList = new List<Brand__c>();
            List<Brand__c> existBrandList = [
                SELECT Id, Name, Advertiser__c
                FROM Brand__c
                WHERE Name IN :brandNameSet AND Advertiser__c IN :advertiserIds
            ];

            system.debug('existBrandList: ' + existBrandList);
            if(!existBrandList.isEmpty()){
                for(Brand__c brandRec: existBrandList){
                    brandNameMap.put(brandRec.Name,brandRec);
                }
            }

            for(string nameExctract :brandNameSet){
                if(brandNameMap.get(nameExctract) == null){
                    Brand__c newBrand = new Brand__c();
                    newBrand.Name = nameExctract;
                    newBrand.Advertiser__c = brandWithAdvertiserMap.get(nameExctract);
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

/*
    private static void createBrand(List<Client_Traffic__c> clientTrafficList, Map<String,Id> accountMap){
        Set<String> brandNameSet = new Set<String>();
        Set<Id> advertiserIds = new Set<Id>();
        Map<String,String> brandMap = new Map<String,String>(); 
        for(Client_Traffic__c clientTrafficRec : clientTrafficList){
            brandNameSet.add(clientTrafficRec.Brand__c);
            Id advertiserId = (Id) accountMap.get(clientTrafficRec.ID__c);
            advertiserIds.add(advertiserId);
        }

        List<Brand__c> brandList = [SELECT Id, Name FROM Brand__c WHERE Name IN : brandNameSet AND Advertiser__c IN : advertiserIds];

        for(Brand__c brandRec : brandList){
            brandMap.put(brandRec.Name,brandRec.Id);
        }

        System.debug('brandMap ==> '+ brandMap);

        List<Brand__c> newBrandList = new List<Brand__c>();
        List<Client_Traffic__c> updateClientTrafficList = new List<Client_Traffic__c>();
        for(Client_Traffic__c clientTrafficRec : clientTrafficList){
           if(brandMap.get(clientTrafficRec.Brand__c) == null){
                Brand__c newBrand = new Brand__c();
                newBrand.Name = clientTrafficRec.Brand__c;
                newBrand.Advertiser__c = accountMap.get(clientTrafficRec.ID__c);
                newBrandList.add(newBrand);
           }else{
             //   Client_Traffic__c updateClientTraffic = new Client_Traffic__c();
               // updateClientTraffic.Id = clientTrafficRec.Id;
               clientTrafficRec.Brand_Related__c = brandMap.get(clientTrafficRec.Brand__c);
             //   updateClientTrafficList.add(updateClientTraffic);
           }
        }

        if(!newBrandList.isEmpty()){
            insert newBrandList;
        }

        // if(!updateClientTrafficList.isEmpty()){
        //     update updateClientTrafficList;
        // }     
    }*/

    /**Private */
    private static Map<String,Id> userMappingWithNik(List<Client_Traffic__c> clientTrafficList){
        Set<String> nikSet = new Set<String>();
        Map<String,Id> nikSalesMap = new Map<String,Id>();
        for(Client_Traffic__c clientTraffic : clientTrafficList){
            nikSet.add(clientTraffic.Sales_Nik__c);
        }

        List<User> userSales = [SELECT Id,NIK__c FROM User WHERE NIK__c IN : nikSet];
        for(User userRec: userSales){
            nikSalesMap.put(userRec.NIK__c,userRec.Id);
        }
        return nikSalesMap;
    }

    public static void createMonthlyClientTraffic(set<Id> clientTrafficIds){
        
        set<string> monthlyClientTrafficUniqueIds = new set <string>();
        set<date> periodeTraffic = new set<date>();
        List<Monthly_Client_Traffic__c> failedRecords = new List<Monthly_Client_Traffic__c>();
        list<Client_Traffic__c> clientTrafficList = [
                SELECT id, 
                Periode__c, 
                tgl_tayang__c 
                FROM Client_Traffic__c 
                WHERE Id IN:clientTrafficIds
        ];

        for(Client_Traffic__c clientTrafficListRec :clientTrafficList){
            
            date periode = date.newInstance(clientTrafficListRec.tgl_tayang__c.year(), clientTrafficListRec.tgl_tayang__c.month(), 1); 
            //string uniqueId = clientTrafficListRec.brand__c + '_' + clientTrafficListRec.product_name__c + '_' + string.valueOf(clientTrafficListRec.tgl_tayang__c.year() + '-' + clientTrafficListRec.tgl_tayang__c.month()) + '_' + clientTrafficListRec.sales_nik__c;

            //monthlyClientTrafficUniqueIds.add(uniqueId);
            clientTrafficIds.add(clientTrafficListRec.id);
            periodeTraffic.add(periode);
        }

        Map<date, additional_setting__c> AdditionalforVATRecordMap = new Map<date, additional_setting__c>();
        Map<date, additional_setting__c> AdditionalforDiscountRecordMap = new Map<date, additional_setting__c>();
        Map<date, ExchangeRates__c> exchangeRateRecordMap = new Map<date, ExchangeRates__c>();

        for(date periodeTrafficValue :periodeTraffic){
            System.debug('periodeTrafficValue: ' + periodeTrafficValue);
            additional_setting__c additionalVAT =  AppUtils.getAdditionalValue('VAT', 'VAT', periodeTrafficValue);
            System.debug('additionalVAT: ' + additionalVAT);
            additional_setting__c additionalDiscount =  AppUtils.getAdditionalValue('Discount', 'Monthly_Client_Traffic__c', periodeTrafficValue);
            System.debug('additionalDiscount: ' + additionalDiscount);

            //ExchangeRates__c exchangeRate =  AppUtils.exchangeRateConversion(periodeTrafficValue);

            AdditionalforVATRecordMap.put(periodeTrafficValue, additionalVAT);
            //exchangeRateRecordMap.put(periodeTrafficValue, exchangeRate);
            AdditionalforDiscountRecordMap.put(periodeTrafficValue, additionalDiscount);
        }
        
        map<string, user> userMap = new map <string, user>();
        list<user> userList = [select id, username, nik__c from user where nik__c != null];
        for(user userListRec: userList){
            userMap.put(userListRec.nik__c, userListRec);
        }  

        List<AggregateResult> ClientTrafficAggregate = [
            SELECT brand__c brandName, 
            brand_related__c brandRelated, 
            company_name__c companyName,
            periode__c tglTayang, 
            product_name__c productName, 
            product_related__c productRelated, 
            Sales_nik__c salesNik, 
            sales__c sales, 
            
            sum(traffic_success__c) trafficSuccess,
            sum(traffic_failed__c) trafficFailed,
            sum(order_quantity__c) orderQuantity 
            
            from Client_Traffic__c 
            
            WHERE Monthly_Client_Traffic__c = null 
 
            GROUP BY 
            brand__c ,
            company_name__c, 
            periode__c , 
            product_name__c , 
            product_related__c , 
            brand_related__c , 
            Sales_nik__c,  
            sales__c 
        ];

        for(AggregateResult ClientTrafficAggregateRec :ClientTrafficAggregate){
            
            date tglTayang = (date) ClientTrafficAggregateRec.get('tglTayang');
            date periode = date.newInstance(tglTayang.year(), tglTayang.month(), 1);
            monthlyClientTrafficUniqueIds.add((string) ClientTrafficAggregateRec.get('brandName') + '_' + (string) ClientTrafficAggregateRec.get('productName') + '_' + string.valueOf(tglTayang.year() + '-' + tglTayang.month()) + '_' + (string) ClientTrafficAggregateRec.get('salesNik'));
        }

        
        list<Monthly_Client_Traffic__c> monthlyClientTraffictoUpdate = new list<Monthly_Client_Traffic__c>();
        list<Monthly_Client_Traffic__c> monthlyClientTraffictoinsert = new list<Monthly_Client_Traffic__c>();
        list<Monthly_Client_Traffic__c> monthlyCientTraffictoMapClient = new list<Monthly_Client_Traffic__c>();

        date periode;
        system.debug('AdditionalforDiscountRecordMap : ' + AdditionalforDiscountRecordMap);
        for(AggregateResult ClientTrafficAggregateRec :ClientTrafficAggregate){
            
            date tglTayang = (date) ClientTrafficAggregateRec.get('tglTayang');
            periode = date.newInstance(tglTayang.year(), tglTayang.month(), 1);
            string uniqueId = (string) ClientTrafficAggregateRec.get('brandName') + '_' + (string) ClientTrafficAggregateRec.get('productName') + '_' + string.valueOf(tglTayang.year() + '-' + tglTayang.month()) + '_' + (string) ClientTrafficAggregateRec.get('salesNik');
            System.debug('216.AdditionalforDiscountRecordMap: ' + AdditionalforDiscountRecordMap.get(periode).id);

            Monthly_Client_Traffic__c newMonthlyClientTrafficRec = new Monthly_Client_Traffic__c();
            newMonthlyClientTrafficRec.Periode__c = tglTayang;
            newMonthlyClientTrafficRec.Campaign_Name__c = string.valueOf( (string) ClientTrafficAggregateRec.get('brandName') + '_' + periode.year() + '_' +  periode.month());
            newMonthlyClientTrafficRec.Brand__c = (string) ClientTrafficAggregateRec.get('brandName');
            newMonthlyClientTrafficRec.Brand_Related__c = (id) ClientTrafficAggregateRec.get('brandRelated');
            newMonthlyClientTrafficRec.company_name__c = (id) ClientTrafficAggregateRec.get('companyName');
            newMonthlyClientTrafficRec.Sales_NIK__c = (string) ClientTrafficAggregateRec.get('salesNik');
            newMonthlyClientTrafficRec.sales__c = (id) ClientTrafficAggregateRec.get('sales');
            newMonthlyClientTrafficRec.Start_Date__c = periode;
            newMonthlyClientTrafficRec.end_date__c = periode.addMonths(1).addDays(-1);
            newMonthlyClientTrafficRec.Inventory__c = (string) ClientTrafficAggregateRec.get('productName');
            newMonthlyClientTrafficRec.Inventory_Related__c = (id) ClientTrafficAggregateRec.get('productRelated');
            newMonthlyClientTrafficRec.Order_quantity__c = (double) ClientTrafficAggregateRec.get('orderQuantity');
            newMonthlyClientTrafficRec.Traffic__c = (double) ClientTrafficAggregateRec.get('trafficSuccess');
            //newMonthlyClientTrafficRec.discount__c = AdditionalforDiscountRecordMap.get(periode);//10; // TODO: put the value in additional setting
            newMonthlyClientTrafficRec.Discount_related__c = AdditionalforDiscountRecordMap.get(periode).id;
            newMonthlyClientTrafficRec.VAT_related__c = AdditionalforVATRecordMap.get(periode).id;
            newMonthlyClientTrafficRec.Unique_ID__c = uniqueId;

            MonthlyClientTraffictoInsert.add(newMonthlyClientTrafficRec);
                    
        }
                
        map<string, Monthly_Client_Traffic__c> existingMonthlyClientTrafficMap = new map<string, Monthly_Client_Traffic__c>();
        list<Monthly_Client_Traffic__c> existingMonthlyClientTrafficList = [
            SELECT id, unique_id__c, Traffic__c
            FROM Monthly_Client_Traffic__c 
            WHERE unique_id__c in: monthlyClientTrafficUniqueIds FOR UPDATE
        ];    
    
        for(Monthly_Client_Traffic__c existingMonthlyClientTrafficListRec :existingMonthlyClientTrafficList){
            existingMonthlyClientTrafficMap.put(existingMonthlyClientTrafficListRec.unique_id__c, existingMonthlyClientTrafficListRec);
        }

        list<Monthly_Client_Traffic__c> monthlyClientTrafficFinaltoinsert = new list<Monthly_Client_Traffic__c>();
        for(Monthly_Client_Traffic__c MonthlyClientTraffictoInsertRec :MonthlyClientTraffictoInsert){
            Monthly_Client_Traffic__c existMonthlyClientRec = existingMonthlyClientTrafficMap.get(MonthlyClientTraffictoInsertRec.unique_id__c);
            if(existMonthlyClientRec != null){
                existMonthlyClientRec.Traffic__c = existMonthlyClientRec.Traffic__c + MonthlyClientTraffictoInsertRec.Traffic__c ; // (Double) proggramaticTrafficAggregateRec.get('sumImpression');
                //existMonthlyClientRec.Total_Harga__c = existMonthlyClientRec.Total_Harga__c + MonthlyClientTraffictoInsertRec.Total_Harga__c;
                
                update existMonthlyClientRec;
                monthlyCientTraffictoMapClient.add(existMonthlyClientRec);
            }else{
                monthlyClientTrafficFinaltoinsert.add(MonthlyClientTraffictoInsertRec);
            }
        }
        System.debug('monthlyClientTrafficFinaltoinsert ==> '+ monthlyClientTrafficFinaltoinsert);
      
        //Database.SaveResult[] srList = Database.insert(monthlyClientTrafficFinaltoinsert, false);
        insert  monthlyClientTrafficFinaltoinsert; 
        
       /* for(Database.SaveResult sr : srList) {
            if(sr.isSuccess()) {
                // Handle successful insert
            } else {
                for(Database.Error error : sr.getErrors()) {
                    // kalo errornya duplicate
                    if(error.getStatusCode() == StatusCode.DUPLICATE_VALUE) {
                        failedRecords.add(monthlyClientTrafficFinaltoinsert[sr.getIndex()]);
                        
                    }
                    
                }
            }
        }

        insert failedRecords;*/
        
        for(Monthly_Client_Traffic__c monthlyClientTrafficFinaltoinsertRec :monthlyClientTrafficFinaltoinsert){
            monthlyCientTraffictoMapClient.add(monthlyClientTrafficFinaltoinsertRec);
        }

        if(!monthlyCientTraffictoMapClient.isEmpty()){
            mapMonthlytoClientTraffic(monthlyCientTraffictoMapClient);
        }
        
    }

    /*
    public static void updateMonthlyClientTraffic(clienTrafficIds){
        system.debug('in updateMonthlyClientTraffic');
        Set<Id> monthlyIds = new Set<Id>();
        
        list<Client_Traffic__c> newClientTraffics = [
                SELECT id, 
                Periode__c, 
                tgl_tayang__c 
                FROM Client_Traffic__c 
                WHERE Id IN:clienTrafficIds
        ];
        for(Client_Traffic__c clientTrafficRec : newClientTraffics){
            monthlyIds.add(clientTrafficRec.Monthly_Client_Traffic__c);
        }

        List<AggregateResult> ClientTrafficAggregate = [
            SELECT brand__c brandName, 
            brand_related__c brandRelated, 
            company_name__c companyName,
            periode__c tglTayang, 
            product_name__c productName, 
            product_related__c productRelated, 
            Sales_nik__c salesNik, 
            sales__c sales, 
            
            sum(traffic_success__c) trafficSuccess,
            sum(traffic_failed__c) trafficFailed,
            sum(order_quantity__c) orderQuantity 
            
            from Client_Traffic__c 
            
            WHERE product_related__c != null AND    
            brand_related__c != null AND 
            sales__c != null AND
            Monthly_Client_Traffic__c in:monthlyIds
            GROUP BY 
            brand__c ,
            company_name__c, 
            periode__c , 
            product_name__c , 
            product_related__c , 
            brand_related__c , 
            Sales_nik__c,  
            sales__c 
        ];

        List<Monthly_Client_Traffic__c> monthlyClientTraffics = [
            SELECT Id,
            Traffic__c,
            Tarif__c, 
            Order_Quantity__c, 
            Unique_ID__c
            FROM Monthly_Client_Traffic__c
            WHERE Id IN :monthlyIds
        ];

        Map<string, Monthly_Client_Traffic__c> monthlyClientTrafficsMap = new Map<string, Monthly_Client_Traffic__c>();
        for (Monthly_Client_Traffic__c monthlyClientTraffic : monthlyClientTraffics) {
            monthlyClientTrafficsMap.put(monthlyClientTraffic.Unique_ID__c, monthlyClientTraffic);
        }

        List<Monthly_Client_Traffic__c> monthlyList = new List<Monthly_Client_Traffic__c>();
        if(!ClientTrafficAggregate.isEmpty() && ClientTrafficAggregate != null){
            
            for(AggregateResult ClientTrafficAggregateRec :ClientTrafficAggregate){
                date tglTayang = (date) ClientTrafficAggregateRec.get('tglTayang');
                date periode = date.newInstance(tglTayang.year(), tglTayang.month(), 1);
                string uniqueId = (string) ClientTrafficAggregateRec.get('brandName') + '_' + (string) ClientTrafficAggregateRec.get('productName') + '_' + string.valueOf(tglTayang.year() + '-' + tglTayang.month()) + '_' + (string) ClientTrafficAggregateRec.get('salesNik');

                Monthly_Client_Traffic__c newMonthlyClientTrafficRecMap = monthlyClientTrafficsMap.get(uniqueId);

                newMonthlyClientTrafficRecMap.Order_quantity__c = (double) ClientTrafficAggregateRec.get('orderQuantity');
                newMonthlyClientTrafficRecMap.Traffic__c = (double) ClientTrafficAggregateRec.get('trafficSuccess');

                monthlyList.add(newMonthlyClientTrafficRecMap);
            }
        }

        if(!monthlyList.isEmpty()){
            update monthlyList;
        }
    }
    */

    private static void mapMonthlytoClientTraffic(list<Monthly_Client_Traffic__c> monthlyClientTrafficList){
        set<String> monthlyClientTrafficUniqueIds = new set<String>();
        map<string, Monthly_Client_Traffic__c> monthlyClientTrafficRecordMap = new map<string, Monthly_Client_Traffic__c>();

        for(Monthly_Client_Traffic__c monthlyClientTrafficListRec :monthlyClientTrafficList){
            monthlyClientTrafficUniqueIds.add(monthlyClientTrafficListRec.unique_id__c);
            monthlyClientTrafficRecordMap.put(monthlyClientTrafficListRec.unique_id__c, monthlyClientTrafficListRec);
        }
        
        list<Client_Traffic__c> ClientTrafficListtoUpdate = new list<Client_Traffic__c>();
        list<Client_Traffic__c> existingClientTrafficList = [ 
                select id, 
                Periode__c, 
                Brand__c, 
                product_name__c, 
                sales_nik__c, 
                Monthly_Client_Traffic__c 
                from Client_Traffic__c 
                where Monthly_Client_Traffic__c = NULL
        ];
        
        
        for(Client_Traffic__c clientTrafficListRec :existingClientTrafficList){
            date periode = date.newInstance(clientTrafficListRec.periode__c.year(), clientTrafficListRec.periode__c.month(), 1); 
            string uniqueId = clientTrafficListRec.brand__c + '_' + clientTrafficListRec.product_name__c + '_' + string.valueOf(clientTrafficListRec.periode__c.year() + '-' + clientTrafficListRec.periode__c.month()) + '_' + clientTrafficListRec.sales_nik__c;
            
            Monthly_Client_Traffic__c monthlyClientTrafficRec = monthlyClientTrafficRecordMap.get(uniqueId);
            if(monthlyClientTrafficRec != null){
                clientTrafficListRec.Monthly_Client_Traffic__c = monthlyClientTrafficRec.id;
                clientTrafficListRec.Monthly_Client_Traffic_Unique_ID__c = uniqueId;
            }

            ClientTrafficListtoUpdate.add(clientTrafficListRec);
        }
    

        if(!ClientTrafficListtoUpdate.isEmpty()){
            update ClientTrafficListtoUpdate;
        }
    }

    /*
    public static void updateMonthlyClientTraffic(List<Client_Traffic__c> newClientTraffics,List<Client_Traffic__c> oldClientTraffics){
        system.debug('in updateMonthlyClientTraffic');
        Set<Id> monthlyIds = new Set<Id>();
        Map<Id,Client_Traffic__c> oldMap = new Map<Id,Client_Traffic__c>(oldClientTraffics);

        for(Client_Traffic__c clientTrafficRec : newClientTraffics){
            monthlyIds.add(clientTrafficRec.Monthly_Client_Traffic__c);
        }

        List<Monthly_Client_Traffic__c> monthlyClientTraffics = [
            SELECT Id,Traffic__c,Tarif__c, Order_Quantity__c
            FROM Monthly_Client_Traffic__c
            WHERE Id IN :monthlyIds
        ];

        Map<Id, Monthly_Client_Traffic__c> monthlyClientTrafficsMap = new Map<Id, Monthly_Client_Traffic__c>();
        for (Monthly_Client_Traffic__c monthlyClientTraffic : monthlyClientTraffics) {
            monthlyClientTrafficsMap.put(monthlyClientTraffic.Id, monthlyClientTraffic);
        }

        List<Monthly_Client_Traffic__c> monthlyList = new List<Monthly_Client_Traffic__c>();
        for(Client_Traffic__c clientTrafficRec : newClientTraffics){
            Decimal newSuccessValue  = clientTrafficRec.Traffic_Success__c;
            Decimal oldSuccessValue  = oldMap.get(clientTrafficRec.Id).Traffic_Success__c;
            Decimal newOrderQtyValue = clientTrafficRec.Order_Quantity__c;
            Decimal oldOrderQtyValue = oldMap.get(clientTrafficRec.Id).Order_Quantity__c;
             Monthly_Client_Traffic__c existingMonthlyClientTraffic = monthlyClientTrafficsMap.get(clientTrafficRec.Monthly_Client_Traffic__c);
             existingmonthlyClientTraffic.Traffic__c += (newSuccessValue - oldSuccessValue);
             existingmonthlyClientTraffic.Order_quantity__c += (newOrderQtyValue - oldOrderQtyValue);
         //    existingmonthlyClientTraffic.TotalDataCostInUSD__c += (newTotalDataCostValue - oldTotalDataCostValue);
             monthlyList.add(existingmonthlyClientTraffic);
        }
        update monthlyList;
    }
    */
    
}