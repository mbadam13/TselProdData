/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-13-2023
 * @last modified by  : Diky Nurosid
**/
public with sharing class MonthlyClientTrafficServices {
    
    public static void createSOAforMonthlyClientTraffic(set<date> monthlyClientTrafficDates){
        system.debug('in CrerateSOAforMonthlyClientTraffic');
        
      //  try {
            if(!monthlyClientTrafficDates.isEmpty()){

                //get soa exisiting
                list<SOA__c> allSOAList = new List<SOA__c>();
                list<SOA__c> existingSOAList = [
                    SELECT id, 
                    soa_start_date__c 
                    from soa__c
                    where soa_start_date__c in :monthlyClientTrafficDates AND
                    soa_type__c = 'Client' FOR UPDATE
                ];
    
                system.debug('existingSOAList: ' + json.serialize(existingSOAList));
                if(!existingSOAList.isEmpty()){
                    for(soa__c existingSOAListRec :existingSOAList){
                        allSOAList.add(existingSOAListRec);
                    }
                }else{
                    list<SOA__c> newSOAtoInsert = new list<SOA__c>();
                    for(date monthlyClientTrafficDatesRec :monthlyClientTrafficDates ){
                        
                        SOA__c soaRec = new SOA__c();
    
                        soaRec.SOA_Start_Date__c = monthlyClientTrafficDatesRec;
                        soaRec.SOA_End_Date__c = monthlyClientTrafficDatesRec.addMonths(1).addDays(-1);
                        soaRec.SOA_Type__c = 'Client';
                        soaRec.SOA_Sources__c = 'Client';
    
                        newSOAtoInsert.add(soaRec);
                    }
    
                    system.debug('newSOAtoInsert: ' +  newSOAtoInsert);
                    if(!newSOAtoInsert.isEmpty()){
                        insert newSOAtoInsert;
    
                        for(SOA__c newSOAtoInsertRec :newSOAtoInsert){
                            allSOAList.add(newSOAtoInsertRec);
                        }
                    }
                }
    
                map<date, soa__c> existingSOAMap = new map <date, soa__c>();
                if(!allSOAList.isEmpty()){
                    for(SOA__c allSOAListRec :allSOAList){
                        existingSOAMap.put(allSOAListRec.soa_start_date__c, allSOAListRec);
                    }
                }
                
                List<Monthly_Client_Traffic__c> MonthlyClientTrafficList = [
                    SELECT id, 
                    periode__c,
                    soa__c,
                    Unique_ID__c
                    FROM Monthly_Client_Traffic__c 
                    WHERE periode__c in :monthlyClientTrafficDates    
                ]; 
    
                system.debug('existingSOAMap: ' +  existingSOAMap);
                list<Monthly_Client_Traffic__c> MonthlyClientTraffictoUpdateList = new list<Monthly_Client_Traffic__c> ();
                for(Monthly_Client_Traffic__c MonthlyClientTrafficListRec :MonthlyClientTrafficList){
                    if(MonthlyClientTrafficListRec.soa__c == null){
                        MonthlyClientTrafficListRec.soa__c = (existingSOAMap.get(MonthlyClientTrafficListRec.Periode__c) != null) ? existingSOAMap.get(MonthlyClientTrafficListRec.Periode__c).Id : null;
                    }
    
                    MonthlyClientTraffictoUpdateList.add(MonthlyClientTrafficListRec);
                }
    
                if(!MonthlyClientTraffictoUpdateList.isEmpty()){
                    update MonthlyClientTraffictoUpdateList;
                }
            }
      /*  } catch (Exception e) {
            String errMessage = 'Error on MonthlyClientTrafficServices.createSOAforMonthlyClientTraffic function::' + e.getMessage() + '::' + e.getLineNumber();
            System.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }*/
    }

    public static void createOrderforMonthlyclientTraffic(set<id> newMonthlyClientTrafficIds){
        list<Monthly_Client_Traffic__c> newMonthlyClientTrafficList = [ 
            SELECT 
            id,
            name,
            soa__c,
            periode__c,
            Company_Name__c,
            sales__c,
            unique_id__c,
            Brand__c,
            Brand_Related__c
            FROM Monthly_Client_Traffic__c 
            WHERE id in: newMonthlyClientTrafficIds
        ];

        list<order> newOrderListtoInsert = new list<order>();
        if(!newMonthlyClientTrafficList.isEmpty()){
           // Pricebook2 pricebookRec = [select id, name from Pricebook2 where isStandard = true limit 1];
            Id stdPricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT id, name FROM Pricebook2 WHERE isStandard = true limit 1].Id;
            for(Monthly_Client_Traffic__c monthlyClientTrafficListRec :newMonthlyClientTrafficList){
                
                Order newOrder = new order();
            
                newOrder.SOA__c = monthlyClientTrafficListRec.soa__c;
                newOrder.EffectiveDate = monthlyClientTrafficListRec.periode__c;
                newOrder.EndDate = monthlyClientTrafficListRec.periode__c.addMonths(1).addDays(-1);
                newOrder.Sales__c = (monthlyClientTrafficListRec.Sales__c != null) ? monthlyClientTrafficListRec.Sales__c : UserInfo.getUserId();
                newOrder.AccountId = monthlyClientTrafficListRec.Company_Name__c; //mandatory
                newOrder.Brand__c = monthlyClientTrafficListRec.brand_related__c;//(monthlyTTDListRec.Brand__c != null) ? monthlyTTDListRec.Brand__c : null;
                newOrder.Order_Type__c = 'Client';
                newOrder.Status = 'Draft';
                newOrder.SOA_Quotation_No__c = monthlyClientTrafficListRec.Name;
                newOrder.Pricebook2Id = stdPricebookId;
                newOrder.Order_Completed_Date__c = System.today();
                newOrder.Monthly_Traffic_Unique_Id__c = monthlyClientTrafficListRec.unique_id__c;

                newOrderListtoInsert.add(newOrder);
            }
        }
        system.debug('newOrderListtoInsert: ' +  json.serialize(newOrderListtoInsert));
        if(!newOrderListtoInsert.isEmpty()){
            insert newOrderListtoInsert;

            set<id> orderIds = new set<id>();
            for(order newOrderListtoInsertRec :newOrderListtoInsert){
                orderIds.add(newOrderListtoInsertRec.Id);
            }
            
            //UpdateorderStatustoComplete(orderIds);
        }        
    }
/*
    public static void UpdateorderStatustoComplete(set<id> orderIds){
        list<order> orderList = [
            SELECT id,
            name, 
            status
            FROM Order
            where id in:orderIds
        ];

        list<order> orderListtoUpdate = new list<order>();
        if(!orderList.isEmpty()){
            for(order orderListRec :orderList){
                orderListRec.Status = 'Completed';
                orderListRec.Order_Completed_Date__c = system.today();

                orderListtoUpdate.add(orderListRec);
            }
        }

        if(!orderListtoUpdate.isEmpty()){
            update orderListtoUpdate;
        }
    }

    */
}