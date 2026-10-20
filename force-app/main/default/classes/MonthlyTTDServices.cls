/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * test class         : MonthlyTTDServicesTest
 * @last modified on  : 10-21-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class MonthlyTTDServices {

    public static void createSOA(Set<Id> monthlyIds) {
        
        try {
            // Membuat daftar bulan
            Set<Date> monthlySet = new Set<Date>();
            List<MonthlyTTDTraffic__c> newMonthlyList = [
                SELECT Id, SOA__c, Date__c, ImpressionCount__c, TotalDataCostInUSD__c, Account__c
                FROM MonthlyTTDTraffic__c
                WHERE Id IN :monthlyIds
            ];
            
            for (MonthlyTTDTraffic__c monthlyTtdTraffic : newMonthlyList) {
                monthlySet.add(monthlyTtdTraffic.Date__c);
            }
    
            // Mengambil data SOA__c yang sesuai dengan type dan start Date
            List<SOA__c> soaList = [
                SELECT Id, Name, SOA_Start_Date__c, SOA_End_Date__c, SOA_Type__c
                FROM SOA__c
                WHERE SOA_Type__c = 'TTD' AND SOA_Start_Date__c IN :monthlySet
            ];

            System.debug('SOA LIST == > '+soaList);
    
            Map<Date, SOA__c> soaTtdMap = new Map<Date, SOA__c>();
            for (SOA__c soaRec : soaList) {
                soaTtdMap.put(soaRec.SOA_Start_Date__c, soaRec);
            }
            
    
            List<SOA__c> newSoaList = new List<SOA__c>();
            System.debug('soaTtdMap ==> '+soaTtdMap );
            for (MonthlyTTDTraffic__c monthlyTtdTraffic : newMonthlyList) {
               
                if (!soaTtdMap.containsKey(monthlyTtdTraffic.Date__c)) {
                    Integer numberOfDays = Date.daysInMonth(monthlyTtdTraffic.Date__c.year(), monthlyTtdTraffic.Date__c.month());
                    Date lastDayOfMonth = Date.newInstance(monthlyTtdTraffic.Date__c.year(), monthlyTtdTraffic.Date__c.month(), numberOfDays);
                    
                    SOA__c soaRec = new SOA__c();
                    soaRec.SOA_Start_Date__c = monthlyTtdTraffic.Date__c;
                    soaRec.Account__c = monthlyTtdTraffic.Account__c;
                    soaRec.SOA_End_Date__c = lastDayOfMonth;
                    soaRec.SOA_Type__c = 'TTD';
                    soaRec.SOA_Sources__c = 'TTD';
    
                    newSoaList.add(soaRec);
                    soaTtdMap.put(monthlyTtdTraffic.Date__c, soaRec);
                }else{
                    monthlyTtdTraffic.SOA__c = soaTtdMap.get(monthlyTtdTraffic.Date__c).Id;
                }
            }
    
            if (!newSoaList.isEmpty()) {
                insert newSoaList;
                for (MonthlyTTDTraffic__c newMonthlyRec : newMonthlyList) {
                    if (soaTtdMap.containsKey(newMonthlyRec.Date__c)) {
                        newMonthlyRec.SOA__c = soaTtdMap.get(newMonthlyRec.Date__c).Id;
                    }
                }
            }

            update newMonthlyList;
    
        } catch (Exception e) {
            String errMessage = 'Error on createSOA function::' + e.getMessage() + '::' + e.getLineNumber();
            System.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        } 
    }
    
    public static void createOrderforMonthlyTTD(list<MonthlyTTDTraffic__c> monthlyTTDList){
        
        try {
            
            if( !monthlyTTDList.isEmpty() ){
                List<Order> orderList = new List<Order>();
                system.debug('monthlyTTDList: ' + json.serialize(monthlyTTDList));
                //Pricebook2 pricebookRec = [select id, name from Pricebook2 where isStandard = true limit 1];
				Id stdPricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT id, name FROM Pricebook2 WHERE isStandard = true limit 1].Id;
                for(MonthlyTTDTraffic__c monthlyTTDListRec :monthlyTTDList){
                    Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(monthlyTTDListRec.date__c);
                    date StartDate = Map_rangeDate.get('rangeStartDate');
                    date EndDate = Map_rangeDate.get('rangeEndDate');

                    Order newOrder = new order();
                    newOrder.SOA__c = monthlyTTDListRec.soa__c;
                    newOrder.Monthly_Traffic_Unique_Id__c = monthlyTTDListRec.UniqueKey__c;
                    newOrder.EffectiveDate = StartDate;
                    newOrder.EndDate = EndDate;
                    newOrder.Sales__c = (monthlyTTDListRec.Sales__c != null) ? monthlyTTDListRec.Sales__c : UserInfo.getUserId();
                    newOrder.AccountId = monthlyTTDListRec.Account__c; //mandatory
                    newOrder.Brand__c = monthlyTTDListRec.Brand__c;//(monthlyTTDListRec.Brand__c != null) ? monthlyTTDListRec.Brand__c : null;
                    newOrder.Order_Type__c = 'TTD';
                    newOrder.Status = 'Draft';//'Completed';
                    newOrder.SOA_Quotation_No__c = monthlyTTDListRec.Name;
                    newOrder.Brand__c = monthlyTTDListRec.Brand__c;
                    newOrder.Pricebook2Id = stdPricebookId;
                    orderList.add(newOrder);
                }
                if(!orderList.isEmpty()){
                    insert orderList;
                    //UpdateOrderStatusToCompleted(orderList);
                }
                
            }

          
        } catch (Exception e) {
            string errMessage = 'Error on MonthlyTTDServices.createOrderforMonthlyTTD function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

    //pindah di order services
    /*
    public static void updateOrderItem(Set<Id> monthlyIds){

        Map<String,Id> soaBrandProductMap = new Map<String,Id>();
        Map<String,Id> soaBrandMonthlyIdMap = new Map<String,Id>();
        Map<Id,Decimal> monthlyTrafficPricesMap = new Map<Id,Decimal>();
        Map<Id,Decimal> monthlyTrafficQtyMap = new Map<Id,Decimal>();
        Set<Id> soaIds = new Set<Id>();
        Set<Id> brandIds = new Set<Id>();
        Set<Id> orderItemIds = new Set<Id>();

        List<MonthlyTTDTraffic__c> monthlyTTDList = [SELECT Id,Price__c,Traffic__c,SOA__c,Brand__c,Product__c FROM MonthlyTTDTraffic__c WHERE Id IN : monthlyIds];
        System.debug('monthlyTTdList ==> '+ monthlyTTDList);
        for(MonthlyTTDTraffic__c monthlyRec :monthlyTTdList){
            soaBrandProductMap.put(monthlyRec.SOA__c+'-'+monthlyRec.Brand__c, monthlyRec.Product__c);
            soaBrandMonthlyIdMap.put(monthlyRec.SOA__c+'-'+monthlyRec.Brand__c, monthlyRec.Id);
            monthlyTrafficPricesMap.put(monthlyRec.Id, monthlyRec.Price__c);
            monthlyTrafficQtyMap.put(monthlyRec.Id, monthlyRec.Traffic__c);
            soaIds.add(monthlyRec.SOA__c);
            brandIds.add(monthlyRec.Brand__c);

        }

        //List<Order> orderList = [SELECT Id, Name, SOA__c, Brand__c, (SELECT Id, UnitPrice,Quantity FROM OrderItems ) FROM Order WHERE SOA__c IN: soaIds AND Brand__c IN: brandIds];
        List<Order> orderList = [SELECT Id,Name,SOA__c,Brand__c FROM Order WHERE SOA__c IN: soaIds AND Brand__c IN: brandIds];
        Set<Id> orderIds = new Set<Id>();
        System.debug('orderList==> '+ orderList);
        for(Order orderRec : orderList){
            orderIds.add(orderRec.Id);
        }

        List<OrderItem> orderItemList = [SELECT Id, OrderId,Order.SOA__c
                                        ,Order.Brand__c, UnitPrice
                                        ,Quantity FROM OrderItem 
                                        WHERE OrderId IN: orderIds];
        List<OrderItem> newUpdateOrderItem = new List<OrderItem>();
        for(Id orderId : orderIds){
            for(OrderItem orderItemRec : orderItemList){
                if(orderId == orderItemRec.OrderId){
                    orderItemIds.add(orderItemRec.Id);
                    OrderItem orderItemObj = new OrderItem();
                    orderItemObj.Id =orderItemRec.Id;

                    String soaWithBrand = orderItemRec.Order.SOA__c + '-' +orderItemRec.Order.Brand__c;
                    Id monthlyId = soaBrandMonthlyIdMap.get(soaWithBrand);
                    System.debug('monthlyTrafficPricesMap.get(monthlyId) ==> '+monthlyTrafficPricesMap.get(monthlyId));
                    System.debug('soaWithBrand==>'+soaWithBrand);
                  
                    System.debug('monthlyId ==>'+monthlyId);
                    orderItemObj.UnitPrice = monthlyTrafficPricesMap.get(monthlyId);
                    orderItemObj.Quantity = monthlyTrafficQtyMap.get(monthlyId);
                    if(orderItemObj.Quantity != orderItemObj.Usage_Actual__c){
                        orderItemObj.Usage_Actual__c = monthlyTrafficQtyMap.get(monthlyId);
                    }
                    
                    newUpdateOrderItem.add(orderItemObj);
                }
               
            }
        }
        System.debug('newUpdateOrderItem ==> ' + newUpdateOrderItem);
        if(!newUpdateOrderItem.isEmpty()){
            update newUpdateOrderItem;

            updateActualUsage(orderItemIds);
        }       
    }
    */
/*
    public static void updateActualUsage(set<id> orderItemIds){
        Set<Id> usageIds = new Set<Id>();
        list<usage__c> usageList = [
            SELECT 
            id,
            Bucket_Detail__c,
            Bucket_Detail__r.Quantity,
            Amount__c,
            Telkomsel_Revenue__c  
            FROM usage__c
            WHERE Bucket_Detail__c in: orderItemIds
        ];


        list<usage__c> usageListToUpdate = new list<usage__c>();  
        if(!usageList.isEmpty()){
            for(usage__c usageListRec :usageList){
                usageIds.add(usageListRec.Id);
                usageListRec.Amount__c = usageListRec.Bucket_Detail__r.Quantity;

                usageListToUpdate.add(usageListRec);
            }
        }

        if(!usageListToUpdate.isEmpty()){
            update usageListToUpdate;

            UpdateUsageonMonthlySalesTarget(usageIds);
        }
    }

    public static void updateUsageonMonthlySalesTarget(set<id> usageIds){
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
                monthlySalesTargetListRec.amount__c = monthlySalesTargetListRec.usage__r.Telkomsel_Revenue__c;
                monthlySalesTargetListRec.date__c = monthlySalesTargetListRec.usage__r.date__c;

                monthlySalesTargetListtoUpdate.add(monthlySalesTargetListRec);
            }
        }

        if(!monthlySalesTargetListtoUpdate.isEmpty()){
            update monthlySalesTargetListtoUpdate;
        }
    }
    
    
    public static void UpdateOrderStatusToCompleted(list<order> orderList){
        list<order> orderListtoUpdate = new list<order>();
        for(order orderListRec :orderList){
            orderListRec.Status = 'Completed';
            orderListRec.Order_Completed_Date__c = System.today();

            orderListtoUpdate.add(orderListRec);
        }

        if(!orderListtoUpdate.isEmpty()){
            update orderListtoUpdate;
        }
    }*/
}