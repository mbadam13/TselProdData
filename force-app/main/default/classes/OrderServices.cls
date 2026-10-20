/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * Test Class         : OrderServicesTest
 * @last modified on  : 10-18-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class OrderServices {
   
    /** For TTD */
    
    /*public static void createOrderItemforTTD(List<Order> newOrderList){

        system.debug('in OrderServices.createorderitem');
        try {
            set<id> orderIds = new set<id>();

            for(Order orderListRec :newOrderList){
                orderIds.add(orderListRec.Id);
            }

            Set<Id> soaIds = new Set<Id>();
            List<Order> orderList = [
                SELECT Id, 
                Name, 
                brand__c,
                SOA__c, 
                SOA__r.Name,
                AccountId,
                Sales__c,
                Sales__r.NIK__c,
                EffectiveDate,
                EndDate,
                Monthly_Traffic_Unique_Id__c,
                OrderNumber FROM Order 
                WHERE Id IN :orderIds AND
                order_type__c = 'TTD'
            ];
            System.debug('orderList: ' + json.serialize(orderList));
            Map<Id,String> nikOrderMap = new Map<Id,String>();
            Map<String,Id> soaBrandProductMap = new Map<String,Id>();
            Map<String,String> productIdNumberMap = new Map<String,String>();
            Map<String,Id> soaBrandMonthlyIdMap = new Map<String,Id>();
            Map<Id,Id> soaWithProductMap = new Map<Id,Id>();
            Map<Id,Decimal> monthlyTrafficMap = new Map<Id,Decimal>();
            Map<Id,Decimal> monthlyTrafficPricesMap = new Map<Id,Decimal>();
            Set<String> monthlyUniqueIds = new Set<String>();
            for(Order orderRec : orderList){
                soaIds.add(orderRec.SOA__c);
                monthlyUniqueIds.add(orderRec.Monthly_Traffic_Unique_Id__c);
            }

            List<MonthlyTTDTraffic__c> monthlyTTdList = [
                SELECT Id, 
                Product__c, 
                SOA__c,
                UniqueKey__c,
                gross__c,
                price__c,
                Account__c,
                Brand__c,
                ImpressionCount__c,
                Product__r.Product_Id_Number__c,
                TotalDataCostInUSD__c,
                Traffic__c FROM MonthlyTTDTraffic__c 
                WHERE SOA__c IN :soaIds
            ];
            Map<String, MonthlyTTDTraffic__c> monthlyTTDTrafficMap = new map<string, MonthlyTTDTraffic__c>();
            system.debug('monthlyTTdList: ' + json.serialize(monthlyTTdList));
            for(MonthlyTTDTraffic__c monthlyRec :monthlyTTdList){
                monthlyTTDTrafficMap.put(monthlyRec.UniqueKey__c,monthlyRec);
            }

            System.debug('monthlyTrafficPricesMap ==> '+ monthlyTrafficPricesMap);
            System.debug('monthlyTrafficMap ==> '+ monthlyTrafficMap);
            Integer autonumber = 1;

            Id pricebookEntryId;
            String productName = 'DMP TTD';

            list <PricebookEntry> pricebookEntries = [
                SELECT Id, 
                Name, 
                Pricebook2Id, 
                Product2Id
                FROM PricebookEntry
                WHERE name =:productName
                LIMIT 1
            ];
            system.debug('pricebookEntries: ' + json.serialize(pricebookEntries));

            if (!pricebookEntries.isEmpty()) {
                pricebookEntryId = pricebookEntries[0].Id;
                System.debug('PricebookEntryId: ' + pricebookEntryId);
            }
            List<OrderItem> orderProductList = new List<OrderItem>();
            Map<String, MonthlyTTDTraffic__c> monthlyTTDTrafficMapbyOrderItem = new map<string, MonthlyTTDTraffic__c>();
            for(Order orderRec : orderList){

                MonthlyTTDTraffic__c monthlyRecord =  monthlyTTDTrafficMap.get(orderRec.Monthly_Traffic_Unique_Id__c);
                System.debug('monthlyRecord ==>'+json.serialize(monthlyRecord));
                nikOrderMap.put(orderRec.Sales__c,orderRec.Sales__r.NIK__c);
                String productIdNumber = monthlyRecord.Product__r.Product_Id_Number__c;
                String campaignId =  Date.today().year() + '_B' + orderRec.OrderNumber + '_' + orderRec.SOA__r.Name +'_'+productIdNumber+ '_' + autonumber; 
                String campId = orderRec.SOA__r.Name +'_'+productIdNumber+ '_' + autonumber;
                ExchangeRates__c exchangeRate =  AppUtils.exchangeRateConversion(orderRec.EffectiveDate);

                OrderItem newOrderItem = new OrderItem(
                    OrderId = orderRec.Id,
                    PricebookEntryId = pricebookEntryId,
                    Product2Id = monthlyRecord.Product__c,
                    Quantity = monthlyRecord.traffic__c,
                    Campaign_ID__c = campaignId,
                    Camp_ID__c = campId,
                    UnitPrice = monthlyRecord.Price__c,
                    Sales__c = (orderRec.Sales__c != null) ? orderRec.Sales__c : UserInfo.getUserId(),
                    ServiceDate = orderRec.EffectiveDate,
                    EndDate = orderRec.EndDate,
                    Total_Data_Cost_In_USD__c = monthlyRecord.TotalDataCostInUSD__c,
                    Exchange_Rates_Related__c = exchangeRate.Id,
                    Monthly_Traffic_Unique_Id__c = orderRec.Monthly_Traffic_Unique_Id__c
                );
                
                
                autonumber = autonumber + 1;
                // Insert the new OrderItem record
                orderProductList.add(newOrderItem);
                monthlyTTDTrafficMapbyOrderItem.put(orderRec.Id, monthlyRecord);
            }

            if(!orderProductList.isEmpty()){
                set<date> datePeriodes = new set<date>();

                for(orderItem orderProductListRec :orderProductList){
                    datePeriodes.add(orderProductListRec.ServiceDate);
                }

                map<date, Additional_Setting__c> additionalVATValueMap = new map<date, Additional_Setting__c>();
                map<date, Additional_Setting__c> additionalDiscountValueMap = new map<date, Additional_Setting__c>();
                for(date DateValue :datePeriodes){
                    Additional_Setting__c additionalVATRec = apputils.getAdditionalValue('VAT', 'VAT', DateValue);
                    Additional_Setting__c additionalDiscountValueMapRec = apputils.getAdditionalValue('discount', 'MonthlyTTDTraffic__c', DateValue);

                    if(additionalVATRec != null){
                        additionalVATValueMap.put(DateValue, additionalVATRec);
                        additionalDiscountValueMap.put(DateValue, additionalDiscountValueMapRec);
                    }
                }

                for(orderItem orderProductListRec :orderProductList){
                    Additional_Setting__c additionalVATValueMapRec = additionalVATValueMap.get(orderProductListRec.ServiceDate);
                    Additional_Setting__c additionalDiscountValueMapRec = additionalDiscountValueMap.get(orderProductListRec.ServiceDate);

                    if(additionalVATValueMapRec != null){
                        orderProductListRec.vat_related__c = (additionalVATValueMapRec != null) ? additionalVATValueMapRec.id : null;
                        orderProductListRec.Discount_related__c = (additionalDiscountValueMapRec != null) ? additionalDiscountValueMapRec.id : null;
                    }
                }
                System.debug('beforeInsert OrderProductList ==> '+ orderProductList);
                insert orderProductList;

            }
            System.debug('AfterInsert OrderProductList ==> '+ orderProductList);
            List<TTD_Traffic__c> ttdTrafficList = [SELECT Id,Date__c,ImpressionCount__c,SalesNIK__c,Monthly_TTD_Traffic_Unique_ID__c FROM TTD_Traffic__c WHERE Monthly_TTD_Traffic_Unique_ID__c IN:monthlyUniqueIds];
            Map<String, List<TTD_Traffic__c>> maplistTtd = new Map<String, List<TTD_Traffic__c>>(); 
            for (TTD_Traffic__c ttdRec : ttdTrafficList) {
                List<TTD_Traffic__c> ttdSubList = maplistTtd.get(ttdRec.Monthly_TTD_Traffic_Unique_ID__c);
                if (ttdSubList == null) {
                    ttdSubList = new List<TTD_Traffic__c>();
                }
                ttdSubList.add(ttdRec);
                maplistTtd.put(ttdRec.Monthly_TTD_Traffic_Unique_ID__c, ttdSubList);
            }

            /*List<Usage__c> usageList = [SELECT Id,Date__c,Sales__c,Campaign_ID__c,Bucket_Detail__c,Monthly_Traffic_Unique_Id__c FROM Usage__c WHERE Monthly_Traffic_Unique_Id__c IN:monthlyUniqueIds];
            Map<String, List<Usage__c>> maplistUsage = new Map<String, List<Usage__c>>(); 
            for (Usage__c usageRec : usageList) {
                List<Usage__c> usageSubList = maplistUsage.get(usageRec.Monthly_Traffic_Unique_Id__c);
                if (usageSubList == null) {
                    usageSubList = new List<Usage__c>();
                }
                usageSubList.add(usageRec);
                maplistUsage.put(usageRec.Monthly_Traffic_Unique_Id__c, usageSubList);
            }*/
            /*
            List<Usage__c> usageNewList = new List<Usage__c>();
             List<TTD_Traffic__c> ttdNewList = new List<TTD_Traffic__c>();
            for(OrderItem orderItemRec : orderProductList){
                System.debug('orderItemRec ==> '+orderItemRec);
                String weekNumber = string.valueOf(AppUtils.weekOfMonth(orderItemRec.ServiceDate));
                for(TTD_Traffic__c TTDTrafficRec : maplistTtd.get(orderItemRec.Monthly_Traffic_Unique_Id__c)){
                    TTD_Traffic__c newTtdUpdate = new TTD_Traffic__c();
                    newTtdUpdate.Id = TTDTrafficRec.Id;
                    newTtdUpdate.isUsage__c = true;

                    Usage__c newUsage = new Usage__c();
                    newUsage.Sales__c = orderItemRec.sales__c;
                    newUsage.Campaign_ID__c = orderItemRec.Campaign_ID__c;
                    newUsage.Bucket_Detail__c = orderItemRec.Id;
                    newUsage.Week__c = weekNumber;
                    newUsage.Date__c = TTDTrafficRec.Date__c;
                    newUsage.Amount__c = TTDTrafficRec.ImpressionCount__c / 1000;
                    newUsage.NIK__c = ttdTrafficRec.SalesNIK__c;
                    newUsage.Monthly_Traffic_Unique_ID__c = orderItemRec.Monthly_Traffic_Unique_Id__c;
                    usageNewList.add(newUsage);
                    ttdNewList.add(newTtdUpdate);
                }
              /*  MonthlyTTDTraffic__c monthlyRecord =  monthlyTTDTrafficMapbyOrderItem.get(orderItemRec.orderid);
                system.debug('monthlyRecord: ' + monthlyRecord);
             
                String nik = nikOrderMap.get(orderItemRec.Sales__c);
                
                Usage__c usage = new Usage__c();
                usage.Date__c = orderItemRec.ServiceDate;
                usage.Amount__c = monthlyRecord.traffic__c;
                usage.sales__c = orderItemRec.sales__c;
                usage.Campaign_ID__c = orderItemRec.Campaign_ID__c;
                usage.Bucket_Detail__c = orderItemRec.Id;
                usage.NIK__c = nik;
                usage.week__c = 'Week ' + weekNumber;*/
           /* }
             if(!ttdNewList.isEmpty()){
                update ttdNewList;
             }
            
            if(!usageNewList.isEmpty()){
                insert usageNewList;

                set<id> usageIds = new set<id>();
                for(usage__c usageIdsValue :usageNewList){
                    usageIds.add(usageIdsValue.id);
                }

                UpdateUsageonMonthlySalesTarget(usageIds);
            }

        } catch (Exception e) {
            string errMessage = 'Error on OrderServices.createOrderItem function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }*/
    

    
    public static void createOrderItemforTTD(List<Order> newOrderList){

        system.debug('in OrderServices.createorderitem');
        try {
            set<id> orderIds = new set<id>();

            for(Order orderListRec :newOrderList){
                orderIds.add(orderListRec.Id);
            }

            Set<Id> soaIds = new Set<Id>();
            List<Order> orderList = [
                SELECT Id, 
                Name, 
                brand__c,
                SOA__c, 
                SOA__r.Name,
                AccountId,
                Sales__c,
                Sales__r.NIK__c,
                EffectiveDate,
                EndDate,
                Monthly_Traffic_Unique_Id__c,
                OrderNumber FROM Order 
                WHERE Id IN :orderIds AND
                order_type__c = 'TTD'
            ];
            System.debug('orderList: ' + json.serialize(orderList));
            Map<Id,String> nikOrderMap = new Map<Id,String>();
            Map<String,Id> soaBrandProductMap = new Map<String,Id>();
            Map<String,String> productIdNumberMap = new Map<String,String>();
            Map<String,Id> soaBrandMonthlyIdMap = new Map<String,Id>();
            Map<Id,Id> soaWithProductMap = new Map<Id,Id>();
            Map<Id,Decimal> monthlyTrafficMap = new Map<Id,Decimal>();
            Map<Id,Decimal> monthlyTrafficPricesMap = new Map<Id,Decimal>();

            for(Order orderRec : orderList){
                soaIds.add(orderRec.SOA__c);
            }

            List<MonthlyTTDTraffic__c> monthlyTTdList = [
                SELECT Id, 
                Product__c, 
                SOA__c,
                UniqueKey__c,
                gross__c,
                price__c,
                Account__c,
                Brand__c,
                ImpressionCount__c,
                Product__r.Product_Id_Number__c,
                TotalDataCostInUSD__c,
                Traffic__c FROM MonthlyTTDTraffic__c 
                WHERE SOA__c IN :soaIds
            ];
            Map<String, MonthlyTTDTraffic__c> monthlyTTDTrafficMap = new map<string, MonthlyTTDTraffic__c>();
            set<string> monthlyTTDTrafficIds = new set<string>();
            system.debug('monthlyTTdList: ' + json.serialize(monthlyTTdList));
            for(MonthlyTTDTraffic__c monthlyRec :monthlyTTdList){
                monthlyTTDTrafficMap.put(monthlyRec.UniqueKey__c,monthlyRec);
                monthlyTTDTrafficIds.add(monthlyRec.UniqueKey__c);
            }

            System.debug('monthlyTrafficPricesMap ==> '+ monthlyTrafficPricesMap);
            System.debug('monthlyTrafficMap ==> '+ monthlyTrafficMap);
            Integer autonumber = 1;

            Id pricebookEntryId;
            String productName = 'DMP TTD';

            list <PricebookEntry> pricebookEntries = [
                SELECT Id, 
                Name, 
                Pricebook2Id, 
                Product2Id
                FROM PricebookEntry
                WHERE name =:productName
                LIMIT 1
            ];
            system.debug('pricebookEntries: ' + json.serialize(pricebookEntries));

            if (!pricebookEntries.isEmpty()) {
                pricebookEntryId = pricebookEntries[0].Id;
                System.debug('PricebookEntryId: ' + pricebookEntryId);
            }
            List<OrderItem> orderProductList = new List<OrderItem>();
            Map<String, MonthlyTTDTraffic__c> monthlyTTDTrafficMapbyOrderItem = new map<string, MonthlyTTDTraffic__c>();
            for(Order orderRec : orderList){
                MonthlyTTDTraffic__c monthlyRecord =  monthlyTTDTrafficMap.get(orderRec.Monthly_Traffic_Unique_Id__c);
                System.debug('monthlyRecord ==>'+json.serialize(monthlyRecord));
                nikOrderMap.put(orderRec.Sales__c,orderRec.Sales__r.NIK__c);
                String productIdNumber = monthlyRecord.Product__r.Product_Id_Number__c;
                String campaignId =  Date.today().year() + '_B' + orderRec.OrderNumber + '_' + orderRec.SOA__r.Name +'_'+productIdNumber+ '_' + autonumber; 
                String campId = orderRec.SOA__r.Name +'_'+productIdNumber+ '_' + autonumber;
                ExchangeRates__c exchangeRate =  AppUtils.exchangeRateConversion(orderRec.EffectiveDate);

                OrderItem newOrderItem = new OrderItem(
                    OrderId = orderRec.Id,
                    PricebookEntryId = pricebookEntryId,
                    Product2Id = (monthlyRecord != null) ? monthlyRecord.Product__c : null,
                    Quantity = (monthlyRecord != null) ? monthlyRecord.traffic__c : null,
                    Campaign_ID__c = campaignId,
                    Camp_ID__c = campId,
                    UnitPrice = (monthlyRecord != null) ? monthlyRecord.Price__c : null,
                    Sales__c = (orderRec.Sales__c != null) ? orderRec.Sales__c : UserInfo.getUserId(),
                    ServiceDate = orderRec.EffectiveDate,
                    EndDate = orderRec.EndDate,
                    Total_Data_Cost_In_USD__c = monthlyRecord.TotalDataCostInUSD__c,
                    Exchange_Rates_Related__c = exchangeRate.Id,
                    Monthly_Traffic_Unique_Id__c = (monthlyRecord != null) ? monthlyRecord.uniquekey__c : null

                );
                
                
                autonumber = autonumber + 1;
                // Insert the new OrderItem record
                orderProductList.add(newOrderItem);
                monthlyTTDTrafficMapbyOrderItem.put(orderRec.Id, monthlyRecord);
            }

            if(!orderProductList.isEmpty()){
                set<date> datePeriodes = new set<date>();

                for(orderItem orderProductListRec :orderProductList){
                    datePeriodes.add(orderProductListRec.ServiceDate);
                }

                map<date, Additional_Setting__c> additionalVATValueMap = new map<date, Additional_Setting__c>();
                map<date, Additional_Setting__c> additionalDiscountValueMap = new map<date, Additional_Setting__c>();
                for(date DateValue :datePeriodes){
                    Additional_Setting__c additionalVATRec = apputils.getAdditionalValue('VAT', 'VAT', DateValue);
                    Additional_Setting__c additionalDiscountValueMapRec = apputils.getAdditionalValue('discount', 'MonthlyTTDTraffic__c', DateValue);

                    if(additionalVATRec != null){
                        additionalVATValueMap.put(DateValue, additionalVATRec);
                        additionalDiscountValueMap.put(DateValue, additionalDiscountValueMapRec);
                    }
                }

                for(orderItem orderProductListRec :orderProductList){
                    Additional_Setting__c additionalVATValueMapRec = additionalVATValueMap.get(orderProductListRec.ServiceDate);
                    Additional_Setting__c additionalDiscountValueMapRec = additionalDiscountValueMap.get(orderProductListRec.ServiceDate);

                    if(additionalVATValueMapRec != null){
                        orderProductListRec.vat_related__c = (additionalVATValueMapRec != null) ? additionalVATValueMapRec.id : null;
                        orderProductListRec.Discount_related__c = (additionalDiscountValueMapRec != null) ? additionalDiscountValueMapRec.id : null;
                    }
                }

                insert orderProductList;
            }

            List<TTD_Traffic__c> TTDTrafficList = [
                SELECT Id, 
                Date__c, 
                ImpressionCount__c, 
                Sales__c,
                SalesNIK__c, 
                Monthly_TTD_Traffic_Unique_ID__c
                
                FROM TTD_Traffic__c
                
                WHERE Monthly_TTD_Traffic_Unique_ID__c IN :monthlyTTDTrafficIds
            ];

        /*    List<Usage__c> usageList = [SELECT Id,Date__c,Sales__c,Campaign_ID__c,Bucket_Detail__c,Monthly_Traffic_Unique_Id__c FROM Usage__c WHERE Monthly_Traffic_Unique_Id__c IN:monthlyTTDTrafficIds];
            Map<String, List<Usage__c>> maplistUsage = new Map<String, List<Usage__c>>(); 
            for (Usage__c usageRec : usageList) {
                List<Usage__c> usageSubList = maplistUsage.get(usageRec.Monthly_Traffic_Unique_Id__c);
                if (usageSubList == null) {
                    usageSubList = new List<Usage__c>();
                }
                usageSubList.add(usageRec);
                maplistUsage.put(usageRec.Monthly_Traffic_Unique_Id__c, usageSubList);
            }*/
            
            Map<String, List<TTD_Traffic__c>> maplistTtd = new Map<String, List<TTD_Traffic__c>>(); 
            for (TTD_Traffic__c ttdRec : TTDTrafficList) {
                List<TTD_Traffic__c> ttdSubList = maplistTtd.get(ttdRec.Monthly_TTD_Traffic_Unique_ID__c);
                if (ttdSubList == null) {
                    ttdSubList = new List<TTD_Traffic__c>();
                }
                ttdSubList.add(ttdRec);
                maplistTtd.put(ttdRec.Monthly_TTD_Traffic_Unique_ID__c, ttdSubList);
            }
            List<TTD_Traffic__c> ttdNewList = new List<TTD_Traffic__c>();
            List<Usage__c> usageNewList = new List<Usage__c>();
            Map<String, OrderItem> uniqueIdToTTDTrafficMap = new Map<String, OrderItem>();
            System.debug('maplistTtd ==>' + maplistTtd);
            for (OrderItem orderItemRec : orderProductList) {
                
                System.debug('maplistTtdresult ==>' + json.serialize(maplistTtd.get(orderItemRec.Monthly_Traffic_Unique_Id__c)));
                for (TTD_Traffic__c TTDTrafficRec : maplistTtd.get(orderItemRec.Monthly_Traffic_Unique_Id__c)){
                        String weekNumber = String.valueOf(AppUtils.weekOfMonth(TTDTrafficRec.Date__c));
                        TTD_Traffic__c newTtdUpdate = new TTD_Traffic__c();
                        newTtdUpdate.Id = TTDTrafficRec.Id;
                        newTtdUpdate.isUsage__c = true;

                        Usage__c usage = new Usage__c();
                        usage.Date__c = TTDTrafficRec.Date__c;
                        usage.Amount__c = TTDTrafficRec.ImpressionCount__c / 1000;
                        usage.Campaign_ID__c = orderItemRec.Campaign_ID__c;
                        usage.Bucket_Detail__c = orderItemRec.id;
                        usage.Sales__c = orderItemRec.Sales__c;
                        usage.NIK__c = TTDTrafficRec.SalesNIK__c;
                        usage.Week__c = 'Week ' + weekNumber;
                        
                        ttdNewList.add(newTtdUpdate);
                        usageNewList.add(usage);
                }
               // uniqueIdToTTDTrafficMap.put(orderItemRec.Monthly_Traffic_Unique_Id__c, orderItemRec); 
                /*for(Usage__c usageRec : maplistUsage.get(orderItemRec.Monthly_Traffic_Unique_Id__c)){
                    String weekNumber = String.valueOf(AppUtils.weekOfMonth(usageRec.date__c));
                    Usage__c newUsage = new Usage__c();
                    newUsage.Id = usageRec.Id;
                    newUsage.Sales__c = orderItemRec.sales__c;
                    newUsage.Campaign_ID__c = orderItemRec.Campaign_ID__c;
                    newUsage.Bucket_Detail__c = orderItemRec.Id;
                    newUsage.Week__c = weekNumber;
                    usageUpdateList.add(newUsage);
                }*/
            }
            

           /* for (TTD_Traffic__c TTDTrafficRec : TTDTrafficList) {
                 orderItem matchingTTDTraffic = uniqueIdToTTDTrafficMap.get(TTDTrafficRec.Monthly_TTD_Traffic_Unique_ID__c);
            
                 if (matchingTTDTraffic != null) {
                    if(TTDTrafficRec.Monthly_TTD_Traffic_Unique_ID__c == matchingTTDTraffic.Monthly_Traffic_Unique_Id__c){
                        String weekNumber = String.valueOf(AppUtils.weekOfMonth(TTDTrafficRec.date__c));
                        String nik = nikOrderMap.get(matchingTTDTraffic.Sales__c);
                    
                        Usage__c usage = new Usage__c();
                        usage.Date__c = TTDTrafficRec.Date__c;
                        usage.Amount__c = TTDTrafficRec.ImpressionCount__c / 1000;
                        usage.Campaign_ID__c = matchingTTDTraffic.Campaign_ID__c;
                        usage.Bucket_Detail__c = matchingTTDTraffic.id;
                        usage.Sales__c = matchingTTDTraffic.Sales__c;
                        usage.NIK__c = nik;
                        usage.Week__c = 'Week ' + weekNumber;
                    
                        usageList.add(usage);
                        break;
                    }
                }
            }*/
            
            if(!ttdNewList.isEmpty()){
                update ttdNewList;
             }

            if(!usageNewList.isEmpty()){
                System.debug('usageNewList ==> '+usageNewList);
                insert usageNewList;

                set<id> usageIds = new set<id>();
                for(usage__c usageIdsValue :usageNewList){
                    usageIds.add(usageIdsValue.id);
                }

                UpdateUsageonMonthlySalesTarget(usageIds);
            }

        } catch (Exception e) {
            string errMessage = 'Error on OrderServices.createOrderItem function ::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

    public static void UpdateOrderItemforTTD(set<id> MonthlyTTDTrafficIds){
        set<id> SOAIds = new set<id>();
        map<string, MonthlyTTDTraffic__c> MonthlyTTDTrafficMap = new map<string, MonthlyTTDTraffic__c>();
        list<MonthlyTTDTraffic__c> MonthlyTTDTrafficList = [
            SELECT 
            id,
            period__c,
            ImpressionCount__c,
            TotalDataCostInUSD__c,
            price__c,
            traffic__c,
            Brand__c,
            product__c,
            sales__r.nik__c,
            SOA__c,
            Uniquekey__c
            FROM MonthlyTTDTraffic__c
            WHERE id in: MonthlyTTDTrafficIds

        ];
        system.debug('MonthlyTTDTrafficList: ' + json.serialize(MonthlyTTDTrafficList));
        if(!MonthlyTTDTrafficList.isEmpty()){
            for(MonthlyTTDTraffic__c MonthlyTTDTrafficListRec :MonthlyTTDTrafficList){
                SOAIds.add(MonthlyTTDTrafficListRec.soa__c);
                MonthlyTTDTrafficMap.put(MonthlyTTDTrafficListRec.uniquekey__c, MonthlyTTDTrafficListRec);

            }   
        }   

        if(!SOAIds.isEmpty()){

            list<orderItem> orderItemList = [
                SELECT 
                id,
                unitprice,
                Quantity,
                account_name__c,
                Order.Brand__r.Name,
                Order.Order_type__c,
                ServiceDate,
                product2.Product_Name_MS__c,
                Sales__r.NIK__c,
                Order.Monthly_Traffic_Unique_Id__c,
                Monthly_Traffic_Unique_Id__c,
                Campaign_ID__c,
                Sales__c
                FROM orderItem
                WHERE Order.SOA__C in:SOAIds AND
                Order.Order_type__c  = 'TTD'
            ]; 

            set<String> monthlyUniqueTTDTrafficIds = new set<String>();
            List<OrderItem> orderItemListToUpdate = new List<OrderItem>();
            if(!orderItemList.isEmpty()){
                for(orderItem orderItemListRec :orderItemList){
                    monthlyUniqueTTDTrafficIds.add(orderItemListRec.Monthly_Traffic_Unique_Id__c);
                    MonthlyTTDTraffic__c MonthlyTTDTrafficMapRec = MonthlyTTDTrafficMap.get(orderItemListRec.order.Monthly_Traffic_Unique_Id__c);

                    if(MonthlyTTDTrafficMapRec != null){
                        decimal Traffic = MonthlyTTDTrafficMapRec.Traffic__c;
                        decimal paidImpression = MonthlyTTDTrafficMapRec.ImpressionCount__c;
                        decimal unitPrice = MonthlyTTDTrafficMapRec.price__c;
                        decimal totalDataCostinUSD = MonthlyTTDTrafficMapRec.TotalDataCostInUSD__c;

                        orderItemListRec.Quantity = Traffic;
                        orderItemListRec.unitprice = unitPrice;
                        orderItemListRec.Total_Data_Cost_In_USD__c = totalDataCostinUSD;
                    }

                    orderItemListToUpdate.add(orderItemListRec);
                }
            }
            

            if(!orderItemListToUpdate.isEmpty()){

                update orderItemListToUpdate;

               
                List<Usage__c> usageNewList = new List<Usage__c>();
                List<TTD_Traffic__c> TTDTrafficList = [
                                    SELECT Id, Date__c, ImpressionCount__c, Sales__c,
                                    SalesNIK__c, Monthly_TTD_Traffic_Unique_ID__c, isUsage__c
                                    FROM TTD_Traffic__c
                                    WHERE Monthly_TTD_Traffic_Unique_ID__c IN :monthlyUniqueTTDTrafficIds AND isUsage__c = false
                                ];
                                
                Map<String, List<TTD_Traffic__c>> maplistTtd = new Map<String, List<TTD_Traffic__c>>(); 
                for (TTD_Traffic__c ttdRec : TTDTrafficList) {
                    List<TTD_Traffic__c> ttdSubList = maplistTtd.get(ttdRec.Monthly_TTD_Traffic_Unique_ID__c);
                    if (ttdSubList == null) {
                        ttdSubList = new List<TTD_Traffic__c>();
                    }
                    ttdSubList.add(ttdRec);
                    maplistTtd.put(ttdRec.Monthly_TTD_Traffic_Unique_ID__c, ttdSubList);
                }
                 System.debug('maplistTtd == '+maplistTtd);
                List<TTD_Traffic__c> ttdNewList = new List<TTD_Traffic__c>();
                for(orderItem orderItemListRec :orderItemListToUpdate){
                    System.debug('orderItemListRec.Monthly_Traffic_Unique_Id__c == '+orderItemListRec.Monthly_Traffic_Unique_Id__c );
                    if (maplistTtd.containsKey(orderItemListRec.Monthly_Traffic_Unique_Id__c)) {
                        for (TTD_Traffic__c TTDTrafficRec : maplistTtd.get(orderItemListRec.Monthly_Traffic_Unique_Id__c)){
                            String weekNumber = String.valueOf(AppUtils.weekOfMonth(TTDTrafficRec.Date__c));    
                            //TTD_Traffic__c newTtdUpdate = new TTD_Traffic__c();
                            //newTtdUpdate.Id = TTDTrafficRec.Id;
                            TTDTrafficRec.isUsage__c = true;

                            Usage__c usage = new Usage__c();
                            usage.Date__c = TTDTrafficRec.Date__c;
                            usage.Amount__c = TTDTrafficRec.ImpressionCount__c / 1000;
                            usage.Campaign_ID__c = orderItemListRec.Campaign_ID__c;
                            usage.Bucket_Detail__c = orderItemListRec.id;
                            usage.Sales__c = orderItemListRec.Sales__c;
                            usage.NIK__c = TTDTrafficRec.SalesNIK__c;
                            usage.Week__c = 'Week ' + weekNumber;
                        
                            usageNewList.add(usage);
                            ttdNewList.add(TTDTrafficRec);
                        }
                    }
                }

                if(!ttdNewList.isEmpty()){
                    System.debug('ttdNewList ==> '+ ttdNewList);
                    update ttdNewList;
                }
                    
                if(!usageNewList.isEmpty()){
                    insert usageNewList;
                }
            }
        }
    }

    /** Programmatic */
    public static void createOrderItemforProgrammatic(List<Order> newOrderList){

        system.debug('in OrderServices.createOrderItemforProgrammatic');
        try {
            set<id> orderIds = new set<id>();

            for(Order orderListRec :newOrderList){
                orderIds.add(orderListRec.Id);
            }

            Set<Id> soaIds = new Set<Id>();
            List<Order> orderList = [
                SELECT Id, 
                Name, 
                brand__c,
                brand__r.name,
                SOA__c, 
                Monthly_Traffic_Unique_Id__c,
                SOA__r.Name,
                AccountId,
                Sales__c,
                Sales__r.NIK__c,
                EffectiveDate,
                EndDate,
                OrderNumber FROM Order 
                WHERE Id IN :orderIds AND
                order_type__c = 'Programmatic'
            ];

            System.debug('orderList: ' + json.serialize(orderList));

            for(Order orderRec : orderList){
                soaIds.add(orderRec.SOA__c);
            }

            map<string, Monthly_programmatic_traffic__c> monthlyProgTrafficMap = new map<string, Monthly_programmatic_traffic__c>();
            List<Monthly_programmatic_traffic__c> monthlyProgList = [
                SELECT id, 
                periode__c,
                soa__c,
                Unique_ID__c,
                inventory_related__r.Product_Id_Number__c,
                inventory_related__c,
                discount_related__c,
                Paid_Impression__c,
                trafik__c,
                vat_related__c,
                Exchange_Rates_Related__c,
                price__c,
                Revenue__c
                FROM Monthly_programmatic_traffic__c 
                WHERE soa__c IN :soaIds
            ];
            system.debug('monthlyProgList: ' + json.serialize(monthlyProgList));
            set<String> monthlyProgUniqueIds = new set<String>();
            set<string> productNames = new set<string>();
            for(Monthly_programmatic_traffic__c monthlyRec :monthlyProgList){
                monthlyProgTrafficMap.put(monthlyRec.Unique_ID__c, monthlyRec);
                monthlyProgUniqueIds.add(monthlyRec.Unique_ID__c);
            }
            Integer autonumber = 1;

            system.debug('productNames: ' + productNames);
            map<string, PricebookEntry> pricebookEntriesMap = new map<string, PricebookEntry>(); 
            list <PricebookEntry> pricebookEntries = [
                SELECT Id, 
                Name, 
                Pricebook2Id, 
                Product2Id,
                Product2.Product_Id_Number__c,
                Product2.Product_name_ms__c
                FROM PricebookEntry
                WHERE Product2.Product_name_ms__c != null
            ];
            system.debug('pricebookEntries: ' + json.serialize(pricebookEntries));

            if (!pricebookEntries.isEmpty()) {
                for(PricebookEntry pricebookEntriesRec :pricebookEntries){
                    pricebookEntriesMap.put(pricebookEntriesRec.Product2.Product_Id_Number__c, pricebookEntriesRec);
                }
                System.debug('pricebookEntriesMap: ' + pricebookEntriesMap);
            }
            map<id, string> nikOrderMap = new map<id, string>();
            List<OrderItem> orderProductList = new List<OrderItem>();
            map<string, Monthly_programmatic_traffic__c> monthlyprogTrafficOrderMapRec = new map <string, Monthly_programmatic_traffic__c>();
            set<String> monthlyTrafficUniqueIds = new set<String>();
            for(Order orderRec : orderList){ 
                system.debug('orderRec.Monthly_Unique_Id__c: ' + orderRec.Monthly_Traffic_Unique_Id__c);                        
                Monthly_programmatic_traffic__c monthlyprogTrafficMapRec = monthlyProgTrafficMap.get(orderRec.Monthly_Traffic_Unique_Id__c);

                nikOrderMap.put(orderRec.Sales__c, orderRec.Sales__r.NIK__c);

                String soaWithBrand = orderRec.SOA__c + '-' + orderRec.Brand__c;
                Id monthlyId = (monthlyprogTrafficMapRec != null) ? monthlyprogTrafficMapRec.id : null;
                String productId = monthlyprogTrafficMapRec.Inventory_Related__r.Product_Id_Number__c;
                String campaignId =  Date.today().year() + '_B' + orderRec.OrderNumber + '_' + orderRec.SOA__r.Name +'_'+ productId + '_' + autonumber; 
                String campId = orderRec.SOA__r.Name +'_'+ productId + '_' + autonumber;
                system.debug('productId.229: ' + productId);
                system.debug('pricebookEntriesMap: ' + pricebookEntriesMap);

                OrderItem newOrderItem = new OrderItem();
                newOrderItem.OrderId = orderRec.Id;
                newOrderItem.PricebookEntryId = pricebookEntriesMap.get(productId).id;
                newOrderItem.Product2Id = (monthlyprogTrafficMapRec != null ) ? monthlyprogTrafficMapRec.Inventory_Related__c : null;
                newOrderItem.Quantity = (monthlyprogTrafficMapRec != null ) ? monthlyprogTrafficMapRec.trafik__c : null;
                newOrderItem.Campaign_ID__c = campaignId;
                newOrderItem.Discount_related__c = (monthlyprogTrafficMapRec != null) ? monthlyprogTrafficMapRec.discount_related__c : null;
                newOrderItem.Camp_ID__c = campId;
                newOrderItem.Exchange_Rates_Related__c = (monthlyprogTrafficMapRec != null) ? monthlyprogTrafficMapRec.Exchange_Rates_Related__c : null;
                newOrderItem.VAT_Related__c = (monthlyprogTrafficMapRec != null) ? monthlyprogTrafficMapRec.vat_related__c : null;
                newOrderItem.UnitPrice = (monthlyprogTrafficMapRec != null) ? monthlyprogTrafficMapRec.price__c : null;
                newOrderItem.Sales__c = (orderRec.Sales__c != null) ? orderRec.Sales__c : UserInfo.getUserId();
                newOrderItem.ServiceDate = orderRec.EffectiveDate;
                newOrderItem.EndDate = orderRec.EndDate;
                newOrderItem.Total_Data_Cost_In_USD__c = (monthlyprogTrafficMapRec != null) ? monthlyprogTrafficMapRec.Revenue__c : null;
                newOrderItem.Monthly_Traffic_Unique_Id__c = (monthlyprogTrafficMapRec != null) ? monthlyprogTrafficMapRec.unique_id__c : null;
                autonumber = autonumber + 1;
                // Insert the new OrderItem record
                orderProductList.add(newOrderItem);
                monthlyprogTrafficOrderMapRec.put( newOrderItem.OrderId, monthlyprogTrafficMapRec);
                monthlyTrafficUniqueIds.add(newOrderItem.Monthly_Traffic_Unique_Id__c);
            }
            if(!orderProductList.isEmpty()){
                
                insert orderProductList;
                system.debug('orderProductListProg: ' +  json.serialize(orderProductList));
            }

            List<Programmatic_Traffic__c> programmaticList = [
                SELECT Id, 
                Paid_Impression__c, 
                Periode__c,
                Sales__c,
                Sales_NIK__c, 
                Monthly_Prog_Traffic_Unique_id__c 
                
                FROM Programmatic_Traffic__c 
                
                WHERE Monthly_Prog_Traffic_Unique_id__c IN:monthlyTrafficUniqueIds
            ];
            
            System.debug('programmaticList: ' + json.serialize(programmaticList));
            Map<String, List<Programmatic_Traffic__c>> maplistProg = new Map<String, List<Programmatic_Traffic__c>>(); 
                        
            if(!programmaticList.isempty()){
                for (Programmatic_Traffic__c progRec : programmaticList) {
                    
                    List<Programmatic_Traffic__c> progSubList = maplistProg.get(progRec.Monthly_Prog_Traffic_Unique_id__c);
                    if (progSubList == null) {
                        progSubList = new List<Programmatic_Traffic__c>();
                    }
                    
                    progSubList.add(progRec);
                    maplistProg.put(progRec.Monthly_Prog_Traffic_Unique_id__c, progSubList);
                }
            }
            
            System.debug('maplistProg: ' + json.serialize(maplistProg));
            List<Programmatic_Traffic__c> progUpdateList = new List<Programmatic_Traffic__c>();
            set<Programmatic_Traffic__c> progUpdateRecs = new set<Programmatic_Traffic__c>();
            List<Usage__c> usageList = new List<Usage__c>();
            for(OrderItem orderItemRec : orderProductList){
                for(Programmatic_Traffic__c progRec: maplistProg.get(orderItemRec.Monthly_Traffic_Unique_Id__c)){
                    String weekNumber = string.valueOf(AppUtils.weekOfMonth(progRec.Periode__c));
                    Programmatic_Traffic__c newProgUpdate = new Programmatic_Traffic__c();
                    newProgUpdate.Id = progRec.Id;
                    newProgUpdate.isUsage__c = true;
                    
                    Usage__c usage = new Usage__c();
                    usage.Date__c = orderItemRec.ServiceDate;
                    usage.Amount__c = progRec.Paid_Impression__c / 1000;
                    usage.Campaign_ID__c = orderItemRec.Campaign_ID__c;
                    usage.sales__c = progRec.sales__c;
                    usage.Bucket_Detail__c = orderItemRec.Id;
                    usage.NIK__c = progRec.Sales_NIK__c;
                    usage.week__c = 'Week ' + weekNumber;

                    progUpdateList.add(newProgUpdate);
                    usageList.add(usage);
                }
            }

            if(!progUpdateList.isEmpty()){
                // for(Programmatic_Traffic__c progUpdateRecsVal :progUpdateRecs){
                //     progUpdateList.add(progUpdateRecsVal);
                // }

                update progUpdateList;
            }

            if(!usageList.isEmpty()){
                System.debug('usageListprog: ' + json.serialize(usageList));
                insert usageList;

                set<id> usageIds = new set<id>();
                for(usage__c usageIdsValue :usageList){
                    usageIds.add(usageIdsValue.id);
                }

                //UpdateUsageonMonthlySalesTarget(usageIds);
            }
            
        } catch (Exception e) {
            string errMessage = 'Error on OrderServices.createOrderItemforProgrammatic function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

    public static void UpdateOrderItemforProg(set<string> MonthlyProgTrafficIds){
        try {
            system.debug('in UpdateOrderItemforProg');
            set<id> SOAIds = new set<id>();
            map<string, Monthly_programmatic_traffic__c> MonthlyProgTrafficMap = new map<string, Monthly_programmatic_traffic__c>();
            
            list<Monthly_programmatic_traffic__c> MonthlyProgTrafficList = [
                SELECT id, 
                periode__c,
                soa__c,
                Unique_ID__c,
                trafik__c,
                price__c,
                inventory_related__r.Product_Id_Number__c,
                inventory_related__c,
                Paid_Impression__c,
                Revenue__c
                FROM Monthly_programmatic_traffic__c
                WHERE unique_id__c in: MonthlyProgTrafficIds
    
            ];
            set<String> monthlyProgUniqueIds = new set<String>();
            system.debug('MonthlyProgTrafficList: ' + json.serialize(MonthlyProgTrafficList));
            if(!MonthlyProgTrafficList.isEmpty()){
                for(Monthly_programmatic_traffic__c MonthlyProgTrafficListRec :MonthlyProgTrafficList){
                    SOAIds.add(MonthlyProgTrafficListRec.soa__c);
                    MonthlyProgTrafficMap.put(MonthlyProgTrafficListRec.unique_id__c, MonthlyProgTrafficListRec);
                    monthlyProgUniqueIds.add(MonthlyProgTrafficListRec.unique_id__c);
                }   
            }   
    
            if(!SOAIds.isEmpty()){
    
                list<orderItem> orderItemList = [
                    SELECT 
                    id,
                    unitprice,
                    Quantity,
                    account_name__c,
                    Order.Brand__r.Name,
                    Order.Order_type__c,
                    Order.Monthly_Traffic_Unique_Id__c,
                    ServiceDate,
                    Campaign_ID__c,
                    product2.Product_Name_MS__c,
                    Sales__r.NIK__c,
                    Monthly_Traffic_Unique_Id__c
                    FROM orderItem
                    WHERE Order.SOA__C in:SOAIds AND
                    Order.Order_type__c  = 'programmatic'
                ]; 
    
                List<OrderItem> orderItemListToUpdate = new List<OrderItem>();
    
                if(!orderItemList.isEmpty()){
                    for(orderItem orderItemListRec :orderItemList){
                        Monthly_programmatic_traffic__c MonthlyProgTrafficMapRec = MonthlyProgTrafficMap.get(orderItemListRec.order.Monthly_Traffic_Unique_Id__c);
    
                        if(MonthlyProgTrafficMapRec != null){
                            decimal paidImpression = MonthlyProgTrafficMapRec.Paid_Impression__c / 1000;
                            orderItemListRec.Quantity = paidImpression;//MonthlyProgTrafficMapRec.Paid_Impression__c / 1000;
                            //orderItemListRec.usage_actual__c = MonthlyProgTrafficMapRec.trafik__c;
                            orderItemListRec.unitprice = MonthlyProgTrafficMapRec.price__c;
                            orderItemListRec.Total_Data_Cost_In_USD__c = MonthlyProgTrafficMapRec.revenue__c;
                        }
    
                        orderItemListToUpdate.add(orderItemListRec);
                    }
                }
    
                if(!orderItemListToUpdate.isEmpty()){
                    System.debug('orderItemListToUpdate: ' + json.serialize(orderItemListToUpdate));
                    update orderItemListToUpdate;
    
                    List<Programmatic_Traffic__c> programmaticList = [
                        SELECT Id, 
                        Paid_Impression__c, 
                        revenue__c,
                        Periode__c,
                        Sales__c,
                        Sales_NIK__c, 
                        Monthly_Prog_Traffic_Unique_id__c 
                        
                        FROM Programmatic_Traffic__c 
                        
                        WHERE Monthly_Prog_Traffic_Unique_id__c IN:monthlyProgUniqueIds AND 
                        isUsage__c = false
                    ];

                    system.debug('programmaticList.1002: ' + json.serialize(programmaticList));
                    Map<String, List<Programmatic_Traffic__c>> maplistProg = new Map<String, List<Programmatic_Traffic__c>>(); 
                    for (Programmatic_Traffic__c progRec : programmaticList) {
                        List<Programmatic_Traffic__c> progSubList = maplistProg.get(progRec.Monthly_Prog_Traffic_Unique_id__c);
                        if (progSubList == null) {
                            progSubList = new List<Programmatic_Traffic__c>();
                        }
                        progSubList.add(progRec);
                        maplistProg.put(progRec.Monthly_Prog_Traffic_Unique_id__c, progSubList);
                    }

                    List<Programmatic_Traffic__c> progUpdateList = new List<Programmatic_Traffic__c>();
                    List<Usage__c> usageList = new List<Usage__c>();
                    for(OrderItem orderItemRec : orderItemListToUpdate){
                        if(maplistProg.containsKey(orderItemRec.Monthly_Traffic_Unique_Id__c)){
                            for(Programmatic_Traffic__c progRec: maplistProg.get(orderItemRec.Monthly_Traffic_Unique_Id__c)){
                                String weekNumber = string.valueOf(AppUtils.weekOfMonth(progRec.Periode__c));
                                // Programmatic_Traffic__c newProgUpdate = new Programmatic_Traffic__c();
                                // newProgUpdate.Id = progRec.Id;
                                // newProgUpdate.isUsage__c = true;
                                progRec.isUsage__c = true;
    
                                Usage__c usage = new Usage__c();
                                usage.Date__c = orderItemRec.ServiceDate;
                                usage.Amount__c = progRec.Paid_Impression__c / 1000;
                                usage.Campaign_ID__c = orderItemRec.Campaign_ID__c;
                                usage.sales__c = progRec.sales__c;
                                usage.Bucket_Detail__c = orderItemRec.Id;
                                usage.NIK__c = progRec.Sales_NIK__c;
                                usage.week__c = 'Week ' + weekNumber;

                                progUpdateList.add(progRec);
                                usageList.add(usage);
                            }
                        }
                        
                    }

                    if(!progUpdateList.isEmpty()){
                        System.debug('progUpdateList.1045: ' + json.serialize(progUpdateList));
                        update progUpdateList;
                    }

                    if(!usageList.isEmpty()){
                        System.debug('usageList.1050: ' + json.serialize(usageList));
                        insert usageList;
                    }
                }
            }
        } catch (Exception e) {
            string errMessage = 'Error on OrderServices.UpdateOrderItemforProg function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
    /** End Programmatic */

    /** For IMX **/
    /*
    public static void createOrderItemforIMX(List<Order> newOrderList){

        system.debug('in OrderServices.createOrderItemforIMX');
        try {
            set<id> orderIds = new set<id>();

            for(Order orderListRec :newOrderList){
                orderIds.add(orderListRec.Id);
            }

            Set<Id> soaIds = new Set<Id>();
            List<Order> orderList = [
                SELECT Id, 
                Name, 
                brand__c,
                brand__r.name,
                SOA__c, 
                Monthly_Traffic_Unique_Id__c,
                SOA__r.Name,
                AccountId,
                Sales__c,
                Sales__r.NIK__c,
                EffectiveDate,
                EndDate,
                OrderNumber FROM Order 
                WHERE Id IN :orderIds AND
                order_type__c = 'Client'
            ];

            System.debug('orderList: ' + json.serialize(orderList));

            for(Order orderRec : orderList){
                soaIds.add(orderRec.SOA__c);
            }

            

            map<string, Monthly_Client_Traffic__c> monthlyclientTrafficMap = new map<string, Monthly_Client_Traffic__c>();
            List<Monthly_Client_Traffic__c> monthlyClientList = [
                SELECT Id, 
                inventory__c, 
                SOA__c, 
                Penggunaan__c,
                tarif__c,
                company_name__c,
                Brand__c,
                Brand_Related__c,
                periode__c,
                unique_id__c,
                order_quantity__c,
                Sales__r.NIK__c,
                Brand_Related__r.name,
                Inventory_Related__r.Product_Id_Number__c,
                Traffic__c FROM Monthly_Client_Traffic__c 
                WHERE SOA__c IN :soaIds
            ];
            system.debug('monthlyClientList: ' + json.serialize(monthlyClientList));

            set<string> productNames = new set<string>();
            for(Monthly_Client_Traffic__c monthlyRec :monthlyClientList){
                //string monthlyUniqueId = monthlyRec.brand_related__r.name + '_' + string.valueOf(monthlyRec.periode__c.year() + '-' + monthlyRec.periode__c.month()) + '_' + monthlyRec.Sales__r.NIK__c;

                monthlyclientTrafficMap.put(monthlyRec.unique_id__c, monthlyRec);
            }
            Integer autonumber = 1;

            system.debug('productNames: ' + productNames);
            map<string, PricebookEntry> pricebookEntriesMap = new map<string, PricebookEntry>(); 
            list <PricebookEntry> pricebookEntries = [
                SELECT Id, 
                Name, 
                Pricebook2Id, 
                Product2Id,
                Product2.Product_Id_Number__c,
                Product2.Product_name_ms__c
                FROM PricebookEntry
                WHERE Product2.Product_name_ms__c != null
            ];
            system.debug('pricebookEntries: ' + json.serialize(pricebookEntries));

            if (!pricebookEntries.isEmpty()) {
                for(PricebookEntry pricebookEntriesRec :pricebookEntries){
                    pricebookEntriesMap.put(pricebookEntriesRec.Product2.Product_Id_Number__c, pricebookEntriesRec);
                }
                System.debug('pricebookEntriesMap: ' + pricebookEntriesMap);
            }
            map<id, string> nikOrderMap = new map<id, string>();
            List<OrderItem> orderProductList = new List<OrderItem>();
            Map<String, monthly_client_traffic__c> monthlyTTDTrafficMapbyOrderItem = new map<string, monthly_client_traffic__c>();
            for(Order orderRec : orderList){ 
                system.debug('orderRec.Monthly_Traffic_Unique_Id__c: ' + orderRec.Monthly_Traffic_Unique_Id__c);               
                system.debug('monthlyclientTrafficMapRec: ' + monthlyclientTrafficMap);               
                monthly_client_traffic__c monthlyclientTrafficMapRec = monthlyclientTrafficMap.get(orderRec.Monthly_Traffic_Unique_Id__c);

                nikOrderMap.put(orderRec.Sales__c, orderRec.Sales__r.NIK__c);

                String soaWithBrand = orderRec.SOA__c + '-' + orderRec.Brand__c;
                Id monthlyId = monthlyclientTrafficMapRec.id;
                String productId = monthlyclientTrafficMapRec.Inventory_Related__r.Product_Id_Number__c;
                String campaignId =  Date.today().year() + '_B' + orderRec.OrderNumber + '_' + orderRec.SOA__r.Name +'_'+ productId + '_' + autonumber; 
                String campId = orderRec.SOA__r.Name +'_'+ productId + '_' + autonumber;
                system.debug('productId.229: ' + productId);
                system.debug('pricebookEntriesMap: ' + pricebookEntriesMap);

                OrderItem newOrderItem = new OrderItem();
                newOrderItem.OrderId = orderRec.Id;
                newOrderItem.PricebookEntryId = pricebookEntriesMap.get(productId).id;
                newOrderItem.Product2Id = monthlyclientTrafficMapRec.Inventory_Related__c;
                newOrderItem.Quantity = monthlyclientTrafficMapRec.traffic__c;
                newOrderItem.Campaign_ID__c = campaignId;
                newOrderItem.Camp_ID__c = campId;
                newOrderItem.UnitPrice = monthlyclientTrafficMapRec.Tarif__c;
                newOrderItem.Sales__c = (orderRec.Sales__c != null) ? orderRec.Sales__c : UserInfo.getUserId();
                newOrderItem.ServiceDate = orderRec.EffectiveDate;
                newOrderItem.EndDate = orderRec.EndDate;
            
                
                autonumber = autonumber + 1;
                // Insert the new OrderItem record
                orderProductList.add(newOrderItem);
                monthlyTTDTrafficMapbyOrderItem.put(orderRec.id, monthlyclientTrafficMapRec);
            }
            if(!orderProductList.isEmpty()){
                set<date> datePeriodes = new set<date>();

                for(orderItem orderProductListRec :orderProductList){
                    datePeriodes.add(orderProductListRec.ServiceDate);
                }

                map<date, Additional_Setting__c> additionalVATValueMap = new map<date, Additional_Setting__c>();
                map<date, Additional_Setting__c> additionalDiscountValueMap = new map<date, Additional_Setting__c>();
                for(date DateValue :datePeriodes){
                    Additional_Setting__c additionalVATRec = apputils.getAdditionalValue('VAT', 'VAT', DateValue);
                    Additional_Setting__c additionalDiscountValueMapRec = apputils.getAdditionalValue('discount', 'Monthly_Programmatic_Traffic__c', DateValue);

                    if(additionalVATRec != null){
                        additionalVATValueMap.put(DateValue, additionalVATRec);
                        additionalDiscountValueMap.put(DateValue, additionalDiscountValueMapRec);
                    }
                }

                for(orderItem orderProductListRec :orderProductList){
                        orderProductListRec.vat_related__c = (additionalVATValueMap != null) ? additionalVATValueMap.get(orderProductListRec.ServiceDate).id : null;
                        orderProductListRec.Discount_related__c = (additionalDiscountValueMap != null ) ? additionalDiscountValueMap.get(orderProductListRec.ServiceDate).id : null;
                }

                insert orderProductList;
            }

            set<string> monthlyClientTraffic = new set<string>();
            for(OrderItem orderItemRec : orderProductList){
                monthly_client_traffic__c monthlyRecord =  monthlyTTDTrafficMapbyOrderItem.get(orderItemRec.orderid);

                monthlyClientTraffic.add(monthlyRecord.Id);
            }
        

            List<Usage__c> usageList = new List<Usage__c>();
            for(OrderItem orderItemRec : orderProductList){
                monthly_client_traffic__c monthlyRecord =  monthlyTTDTrafficMapbyOrderItem.get(orderItemRec.orderid);
                String weekNumber = string.valueOf(AppUtils.weekOfMonth(orderItemRec.ServiceDate));
                String nik = nikOrderMap.get(orderItemRec.Sales__c);
                Usage__c usage = new Usage__c();
                usage.Date__c = orderItemRec.ServiceDate;
                usage.Amount__c = monthlyRecord.traffic__c;
                usage.Campaign_ID__c = orderItemRec.Campaign_ID__c;
                usage.Bucket_Detail__c = orderItemRec.Id;
                usage.sales__c = orderItemRec.sales__c;
                usage.NIK__c = nik;
                usage.week__c = 'Week ' + weekNumber;

                usageList.add(usage);
            }
            if(!usageList.isEmpty()){
                insert usageList;

                set<id> usageIds = new set<id>();
                for(usage__c usageIdsValue :usageList){
                    usageIds.add(usageIdsValue.id);
                }

                UpdateUsageonMonthlySalesTarget(usageIds);
                
            }
            
        } catch (Exception e) {
            string errMessage = 'Error on OrderServices.createOrderItemforIMX function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
    */

    public static void createOrderItemforClient(List<Order> newOrderList){

        system.debug('in OrderServices.createOrderItemforIMX');
        try {
            set<id> orderIds = new set<id>();

            for(Order orderListRec :newOrderList){
                orderIds.add(orderListRec.Id);
            }

            Set<Id> soaIds = new Set<Id>();
            List<Order> orderList = [
                SELECT Id, 
                Name, 
                brand__c,
                brand__r.name,
                SOA__c, 
                Monthly_Traffic_Unique_Id__c,
                SOA__r.Name,
                AccountId,
                Sales__c,
                Sales__r.NIK__c,
                EffectiveDate,
                EndDate,
                OrderNumber FROM Order 
                WHERE Id IN :orderIds AND
                order_type__c = 'Client'
            ];

            System.debug('orderList: ' + json.serialize(orderList));

            for(Order orderRec : orderList){
                soaIds.add(orderRec.SOA__c);
            }

            map<string, Monthly_Client_Traffic__c> monthlyclientTrafficMap = new map<string, Monthly_Client_Traffic__c>();
            set<String> monthlyClientTrafficIds = new set<String>();
            List<Monthly_Client_Traffic__c> monthlyClientList = [
                SELECT Id, 
                inventory__c, 
                SOA__c, 
                Penggunaan__c,
                tarif__c,
                company_name__c,
                Brand__c,
                Brand_Related__c,
                periode__c,
                unique_id__c,
                order_quantity__c,
                Sales__r.NIK__c,
                Brand_Related__r.name,
                Inventory_Related__r.Product_Id_Number__c,
                Traffic__c FROM Monthly_Client_Traffic__c 
                WHERE SOA__c IN :soaIds
            ];
            system.debug('monthlyClientList: ' + json.serialize(monthlyClientList));

            set<string> productNames = new set<string>();
            for(Monthly_Client_Traffic__c monthlyRec :monthlyClientList){
                //string monthlyUniqueId = monthlyRec.brand_related__r.name + '_' + string.valueOf(monthlyRec.periode__c.year() + '-' + monthlyRec.periode__c.month()) + '_' + monthlyRec.Sales__r.NIK__c;

                monthlyclientTrafficMap.put(monthlyRec.unique_id__c, monthlyRec);
                monthlyClientTrafficIds.add(monthlyRec.unique_id__c);
            }
            Integer autonumber = 1;

            system.debug('productNames: ' + productNames);
            map<string, PricebookEntry> pricebookEntriesMap = new map<string, PricebookEntry>(); 
            list <PricebookEntry> pricebookEntries = [
                SELECT Id, 
                Name, 
                Pricebook2Id, 
                Product2Id,
                Product2.Product_Id_Number__c,
                Product2.Product_name_ms__c
                FROM PricebookEntry
                WHERE Product2.Product_name_ms__c != null
            ];
            system.debug('pricebookEntries: ' + json.serialize(pricebookEntries));

            if (!pricebookEntries.isEmpty()) {
                for(PricebookEntry pricebookEntriesRec :pricebookEntries){
                    pricebookEntriesMap.put(pricebookEntriesRec.Product2.Product_Id_Number__c, pricebookEntriesRec);
                }
                System.debug('pricebookEntriesMap: ' + pricebookEntriesMap);
            }
            map<id, string> nikOrderMap = new map<id, string>();
            List<OrderItem> orderProductList = new List<OrderItem>();
            Map<String, monthly_client_traffic__c> monthlyTTDTrafficMapbyOrderItem = new map<string, monthly_client_traffic__c>();
            for(Order orderRec : orderList){ 
                system.debug('orderRec.Monthly_Traffic_Unique_Id__c: ' + orderRec.Monthly_Traffic_Unique_Id__c);               
                system.debug('monthlyclientTrafficMapRec: ' + monthlyclientTrafficMap);               
                monthly_client_traffic__c monthlyclientTrafficMapRec = monthlyclientTrafficMap.get(orderRec.Monthly_Traffic_Unique_Id__c);

                nikOrderMap.put(orderRec.Sales__c, orderRec.Sales__r.NIK__c);

                String soaWithBrand = orderRec.SOA__c + '-' + orderRec.Brand__c;
                Id monthlyId = monthlyclientTrafficMapRec.id;
                String productId = monthlyclientTrafficMapRec.Inventory_Related__r.Product_Id_Number__c;
                String campaignId =  Date.today().year() + '_B' + orderRec.OrderNumber + '_' + orderRec.SOA__r.Name +'_'+ productId + '_' + autonumber; 
                String campId = orderRec.SOA__r.Name +'_'+ productId + '_' + autonumber;
                system.debug('productId.229: ' + productId);
                system.debug('pricebookEntriesMap: ' + pricebookEntriesMap);

                OrderItem newOrderItem = new OrderItem();
                newOrderItem.OrderId = orderRec.Id;
                newOrderItem.PricebookEntryId = pricebookEntriesMap.get(productId).id;
                newOrderItem.Product2Id = monthlyclientTrafficMapRec.Inventory_Related__c;
                newOrderItem.Quantity = monthlyclientTrafficMapRec.traffic__c;
                newOrderItem.Campaign_ID__c = campaignId;
                newOrderItem.Camp_ID__c = campId;
                newOrderItem.UnitPrice = monthlyclientTrafficMapRec.Tarif__c;
                newOrderItem.Sales__c = (orderRec.Sales__c != null) ? orderRec.Sales__c : UserInfo.getUserId();
                newOrderItem.ServiceDate = orderRec.EffectiveDate;
                newOrderItem.EndDate = orderRec.EndDate;
                newOrderItem.Monthly_Traffic_Unique_Id__c = orderRec.Monthly_Traffic_Unique_Id__c;
            
                
                autonumber = autonumber + 1;
                // Insert the new OrderItem record
                orderProductList.add(newOrderItem);
                monthlyTTDTrafficMapbyOrderItem.put(orderRec.id, monthlyclientTrafficMapRec);
            }
            if(!orderProductList.isEmpty()){
                set<date> datePeriodes = new set<date>();

                for(orderItem orderProductListRec :orderProductList){
                    datePeriodes.add(orderProductListRec.ServiceDate);
                }

                map<date, Additional_Setting__c> additionalVATValueMap = new map<date, Additional_Setting__c>();
                map<date, Additional_Setting__c> additionalDiscountValueMap = new map<date, Additional_Setting__c>();
                for(date DateValue :datePeriodes){
                    Additional_Setting__c additionalVATRec = apputils.getAdditionalValue('VAT', 'VAT', DateValue);
                    Additional_Setting__c additionalDiscountValueMapRec = apputils.getAdditionalValue('discount', 'Monthly_Programmatic_Traffic__c', DateValue);

                    if(additionalVATRec != null){
                        additionalVATValueMap.put(DateValue, additionalVATRec);
                        additionalDiscountValueMap.put(DateValue, additionalDiscountValueMapRec);
                    }
                }

                for(orderItem orderProductListRec :orderProductList){
                        orderProductListRec.vat_related__c = (additionalVATValueMap != null) ? additionalVATValueMap.get(orderProductListRec.ServiceDate).id : null;
                        orderProductListRec.Discount_related__c = (additionalDiscountValueMap != null ) ? additionalDiscountValueMap.get(orderProductListRec.ServiceDate).id : null;
                }

                insert orderProductList;
            }
            
            System.debug('monthlyClientTrafficIds: ' + json.serialize(monthlyClientTrafficIds));
            list<Client_Traffic__c> clientTrafficList = [
                SELECT Id, OwnerId, Name, CreatedById, LastModifiedById, Company_Name__c, Campaign_ID__c, 
                ID_Iklan__c, tgl_Tayang__c, Judul_Pesan_Iklan__c, Monthly_Client_Traffic_Unique_ID__c, 
                Operator_Seluler__c, Kategori_Iklan__c, Tipe_Kanal__c, Product_Related__c, Product_Name__c, 
                Detil_Status__c, Traffic_Success__c, Traffic_Failed__c, Brand__c, Brand_Related__c, ID__c, 
                Sales_NIK__c, Sales__c, Price__c, Monthly_Client_Traffic__c, Periode__c, Order_Quantity__c, 
                
                Total_Harga__c FROM Client_Traffic__c

                WHERE Monthly_Client_Traffic_Unique_ID__c IN:monthlyClientTrafficIds
            ];

            Map<String, List<Client_Traffic__c>> mapClientTraffic = new Map<String, List<Client_Traffic__c>>(); 
            for (Client_Traffic__c clientTraffic : clientTrafficList) {
                List<Client_Traffic__c> clientSubList = mapClientTraffic.get(clientTraffic.Monthly_Client_Traffic_Unique_ID__c);
                if (clientSubList == null) {
                    clientSubList = new List<Client_Traffic__c>();
                }
                clientSubList.add(clientTraffic);
                mapClientTraffic.put(clientTraffic.Monthly_Client_Traffic_Unique_ID__c, clientSubList);
            }
            
            List<Client_Traffic__c> clientUpdateList = new List<Client_Traffic__c>();
            List<Usage__c> usageNewList = new List<Usage__c>();
            Map<String, OrderItem> uniqueIdToTTDTrafficMap = new Map<String, OrderItem>();
            
            System.debug('orderProductList: ' + json.serialize(orderProductList));
            System.debug('clientTrafficList: ' + json.serialize(clientTrafficList));
            System.debug('clientTrafficList: ' + clientTrafficList);

            for (OrderItem orderItemRec : orderProductList) {

                for (Client_Traffic__c clientTrafficListRec : mapClientTraffic.get(orderItemRec.Monthly_Traffic_Unique_Id__c)) {
                     String weekNumber = String.valueOf(AppUtils.weekOfMonth(clientTrafficListRec.tgl_Tayang__c));
                     String nik = nikOrderMap.get(orderItemRec.Sales__c);

                    //  Client_Traffic__c newClientUpdate = new Client_Traffic__c();
                    //  newClientUpdate.Id = clientTrafficListRec.Id;
                    clientTrafficListRec.isUsage__c = true;

                     Usage__c usage = new Usage__c();
                     usage.Date__c = clientTrafficListRec.tgl_Tayang__c;
                     usage.Amount__c = clientTrafficListRec.Traffic_Success__c;
                     usage.Campaign_ID__c = orderItemRec.Campaign_ID__c;
                     usage.Bucket_Detail__c = orderItemRec.Id;
                     usage.Sales__c = orderItemRec.Sales__c;
                     usage.NIK__c = nik;
                     usage.Week__c = 'Week ' + weekNumber;
                     clientUpdateList.add(clientTrafficListRec);
                     usageNewList.add(usage);
                }
            }

           /*
            for (Client_Traffic__c clientTrafficListRec : clientTrafficList) {
                // Cari OrderItem yang sesuai berdasarkan kriteria tertentu (misalnya, Campaign_ID__c)
                OrderItem matchingOrderItem = null;
                for (OrderItem orderItemRec : orderProductList) {
                    if (clientTrafficListRec.Monthly_Client_Traffic_Unique_ID__c == orderItemRec.Monthly_Traffic_Unique_Id__c) {
                        matchingOrderItem = orderItemRec;
                        break;
                    }
                }
            
                if (matchingOrderItem != null) {
                  //  String weekNumber = String.valueOf(AppUtils.weekOfMonth(matchingOrderItem.ServiceDate));
                    String nik = nikOrderMap.get(matchingOrderItem.Sales__c);
            
                    Usage__c usage = new Usage__c();
                    usage.Date__c = clientTrafficListRec.tgl_Tayang__c;
                    usage.Amount__c = clientTrafficListRec.Traffic_Success__c;
                    usage.Campaign_ID__c = matchingOrderItem.Campaign_ID__c;
                    usage.Bucket_Detail__c = matchingOrderItem.Id;
                    usage.Sales__c = matchingOrderItem.Sales__c;
                    usage.NIK__c = nik;
                  //  usage.Week__c = 'Week ' + weekNumber;
            
                    usageList.add(usage);
                }
            }*/

            if(!clientUpdateList.isEmpty()){
                update clientUpdateList;
            }

            System.debug('usageList: ' + json.serialize(usageNewList));
            if(!usageNewList.isEmpty()){
                insert usageNewList;

                set<id> usageIds = new set<id>();
                for(usage__c usageIdsValue :usageNewList){
                    usageIds.add(usageIdsValue.id);
                }

                UpdateUsageonMonthlySalesTarget(usageIds);
                
            }
            
        } catch (Exception e) {
            string errMessage = 'Error on OrderServices.createOrderItemforClient function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

    public static void UpdateOrderItemforClient(set<string> MonthlyClientTrafficIds){
        set<id> SOAIds = new set<id>();
        map<string, Monthly_Client_Traffic__c> MonthlyClientTrafficMap = new map<string, Monthly_Client_Traffic__c>();
        
        list<Monthly_Client_Traffic__c> MonthlyClientTrafficList = [
            SELECT 
            id,
            periode__c,
            order_quantity__c,
            tarif__c,
            traffic__c,
            Brand_Related__c,
            inventory__c,
            sales__r.nik__c,
            SOA__c,
            Unique_ID__c
            FROM Monthly_Client_Traffic__c
            WHERE Unique_ID__c in: MonthlyClientTrafficIds

        ];
        system.debug('MonthlyClientTrafficList: ' + json.serialize(MonthlyClientTrafficList));
        if(!MonthlyClientTrafficList.isEmpty()){
            for(Monthly_Client_Traffic__c MonthlyClientTrafficListRec :MonthlyClientTrafficList){
                SOAIds.add(MonthlyClientTrafficListRec.soa__c);
                MonthlyClientTrafficMap.put(MonthlyClientTrafficListRec.unique_id__c, MonthlyClientTrafficListRec);
            }   
        }   

        if(!SOAIds.isEmpty()){

            list<orderItem> orderItemList = [
                SELECT 
                id,
                unitprice,
                Quantity,
                account_name__c,
                Order.Brand__r.Name,
                Order.Order_type__c,
                ServiceDate,
                Campaign_ID__c,
                Sales__c,
                product2.Product_Name_MS__c,
                Sales__r.NIK__c,
                Monthly_Traffic_Unique_ID__c
                FROM orderItem
                WHERE Order.SOA__C in:SOAIds AND
                Order.Order_type__c  = 'Client'
            ]; 

            List<OrderItem> orderItemListToUpdate = new List<OrderItem>();

            if(!orderItemList.isEmpty()){
                for(orderItem orderItemListRec :orderItemList){

                    string monthlyUniqueId = orderItemListRec.order.Brand__r.Name + '_' + orderItemListRec.product2.Product_Name_MS__c + '_' + string.valueOf(orderItemListRec.ServiceDate.year() + '-' + orderItemListRec.ServiceDate.month() + '_' + orderItemListRec.Sales__r.NIK__c);
                    system.debug('monthlyUniqueId: ' + monthlyUniqueId);
                    system.debug('MonthlyClientTrafficMap: ' + MonthlyClientTrafficMap);
                    Monthly_Client_Traffic__c MonthlyClientTrafficMapRec = MonthlyClientTrafficMap.get(monthlyUniqueId);

                    if(MonthlyClientTrafficMapRec != null){
                        orderItemListRec.Quantity = MonthlyClientTrafficMapRec.traffic__c;
                    }

                    orderItemListToUpdate.add(orderItemListRec);
                }
            }

            if(!orderItemListToUpdate.isEmpty()){
                update orderItemListToUpdate;

                list<Client_Traffic__c> clientTrafficList = [
                    SELECT Id, OwnerId, Name, CreatedById, LastModifiedById, Company_Name__c, Campaign_ID__c, 
                    ID_Iklan__c, tgl_Tayang__c, Judul_Pesan_Iklan__c, Monthly_Client_Traffic_Unique_ID__c, 
                    Operator_Seluler__c, Kategori_Iklan__c, Tipe_Kanal__c, Product_Related__c, Product_Name__c, 
                    Detil_Status__c, Traffic_Success__c, Traffic_Failed__c, Brand__c, Brand_Related__c, ID__c, 
                    Sales_NIK__c, Sales__c, Price__c, Monthly_Client_Traffic__c, Periode__c, Order_Quantity__c, 
                    isUsage__c,Total_Harga__c FROM Client_Traffic__c

                    WHERE Monthly_Client_Traffic_Unique_ID__c IN:monthlyClientTrafficIds
                ];

                Map<String, List<Client_Traffic__c>> mapClientTraffic = new Map<String, List<Client_Traffic__c>>(); 
                for (Client_Traffic__c clientTraffic : clientTrafficList) {
                    List<Client_Traffic__c> clientSubList = mapClientTraffic.get(clientTraffic.Monthly_Client_Traffic_Unique_ID__c);
                    if (clientSubList == null) {
                        clientSubList = new List<Client_Traffic__c>();
                    }
                    clientSubList.add(clientTraffic);
                    mapClientTraffic.put(clientTraffic.Monthly_Client_Traffic_Unique_ID__c, clientSubList);
                }
                
                List<Client_Traffic__c> newClientUpdateList = new List<Client_Traffic__c>();
                List<Usage__c> usageNewList = new List<Usage__c>();

                for (OrderItem orderItemRec : orderItemListToUpdate) {

                    if(mapClientTraffic.containsKey(orderItemRec.Monthly_Traffic_Unique_ID__c)){
                        for (Client_Traffic__c clientTrafficListRec : mapClientTraffic.get(orderItemRec.Monthly_Traffic_Unique_ID__c)) {
                            String weekNumber = String.valueOf(AppUtils.weekOfMonth(clientTrafficListRec.tgl_Tayang__c));
                   
                            Client_Traffic__c newClientUpdate = new Client_Traffic__c();
                            newClientUpdate.Id = clientTrafficListRec.Id;
                            newClientUpdate.isUsage__c = true;

                            Usage__c usage = new Usage__c();
                            usage.Date__c = clientTrafficListRec.tgl_Tayang__c;
                            usage.Amount__c = clientTrafficListRec.Traffic_Success__c;
                            usage.Campaign_ID__c = orderItemRec.Campaign_ID__c;
                            usage.Bucket_Detail__c = orderItemRec.Id;
                            usage.Sales__c = orderItemRec.Sales__c;
                            usage.NIK__c = clientTrafficListRec.Sales_NIK__c;
                            usage.Week__c = 'Week ' + weekNumber;
                            
                            newClientUpdateList.add(newClientUpdate);
                            usageNewList.add(usage);
                       }
                    }
                }

                if(!newClientUpdateList.isEmpty()){
                   update newClientUpdateList;
                }

                if(!usageNewList.isEmpty()){
                    insert usageNewList;
                }
            }
        }
    }

    public static void UpdateUsageonMonthlySalesTarget(set<id> usageIds){
        list<Monthly_Sales_Target__c> monthlySalesTargetList = [
            SELECT id, 
            amount__c, 
            date__c,
            usage__r.Telkomsel_Revenue__c,
            usage__r.date__c
            FROM Monthly_Sales_Target__c 
            WHERE usage__c in:usageIds
        ];

        list<Monthly_Sales_Target__c> monthlySalesTargetListtoUpdate = new list<Monthly_Sales_Target__c> ();
        if(!monthlySalesTargetList.isEmpty()){
            for(Monthly_Sales_Target__c monthlySalesTargetListRec :monthlySalesTargetList){
                System.debug('monthlySalesTargetListRec.amount__c = usage__r.Telkomsel_Revenue__c: ' + monthlySalesTargetListRec.amount__c + ' - ' + monthlySalesTargetListRec.usage__r.Telkomsel_Revenue__c);
                if(monthlySalesTargetListRec.amount__c != monthlySalesTargetListRec.usage__r.Telkomsel_Revenue__c){
                    monthlySalesTargetListRec.amount__c = monthlySalesTargetListRec.usage__r.Telkomsel_Revenue__c;
                    monthlySalesTargetListRec.date__c = monthlySalesTargetListRec.usage__r.date__c;
                }
                monthlySalesTargetListtoUpdate.add(monthlySalesTargetListRec);
            }
        }

        if(!monthlySalesTargetListtoUpdate.isEmpty()){
            update monthlySalesTargetListtoUpdate;
        }
    }

    public static void MapOrderwithSOAnotMapping(set<id> orderMapWithSOAIds, string orderCategory){
        try {
            System.debug('in MapOrderwithSOAnotMapping');

            list<order> orderMapWithSOAList = [
            SELECT 
            id,
            EffectiveDate,
            soa__c
            FROM order where id in :orderMapWithSOAIds
            ];
            System.debug('orderservices.MapOrderwithSOAnotMapping.orderMapWithSOAList: ' + json.serialize(orderMapWithSOAList));

            set<date> soaDates = new set<date>();
            for(order orderMapWithSOAListRec :orderMapWithSOAList){
                soaDates.add(orderMapWithSOAListRec.EffectiveDate);
            }

            map<date, soa__c> soaMap = new map<date, SOA__c>();
            list<SOA__c> existingSOAList = [
                        SELECT id, 
                        soa_start_date__c 
                        from soa__c
                        where soa_start_date__c in :soaDates and
                        SOA_Type__c =: orderCategory
            ];
            System.debug('MapOrderwithSOAnotMapping.existingSOAList: ' + JSON.serialize('existingSOAList'));

            if(existingSOAList != null){
                for(soa__c existingSOAListRec :existingSOAList){
                    soaMap.put(existingSOAListRec.soa_start_date__c, existingSOAListRec);
                }
            }

            list<order> orderListtoupdate = new list<order>();
            for(order orderMapWithSOAListRec :orderMapWithSOAList){
                if(orderMapWithSOAListRec.soa__c == null){
                    orderMapWithSOAListRec.SOA__c = (soaMap.get(orderMapWithSOAListRec.EffectiveDate) != null) ? soaMap.get(orderMapWithSOAListRec.EffectiveDate).id : null;

                    orderListtoupdate.add(orderMapWithSOAListRec);
                }
            }

            if(!orderListtoupdate.isEmpty()){
                system.debug('orderListtoupdate: ' +  json.serialize(orderListtoupdate));
                update orderListtoupdate;
            }

        } catch (Exception e) {
            string errMessage = 'Error on OrderServices.MapOrderwithSOAnotMapping function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

}