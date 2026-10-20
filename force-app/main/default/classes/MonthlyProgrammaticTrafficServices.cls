/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : Diky Nurosid
**/
public with sharing class MonthlyProgrammaticTrafficServices {

    public static void createSOAforMonthlyProgrammaticTraffic(set<date> monthlyProgrammaticTrafficDates){
        try {
            system.debug('in CrerateSOAforMonthlyClientTraffic');
   
            if(!monthlyProgrammaticTrafficDates.isEmpty()){

                //get soa exisiting
                list<SOA__c> allSOAList = new List<SOA__c>();
                list<SOA__c> existingSOAList = [
                    SELECT id, 
                    soa_start_date__c 
                    from soa__c
                    where soa_start_date__c in :monthlyProgrammaticTrafficDates AND
                    soa_type__c = 'Programmatic'
                ];

                system.debug('existingSOAList: ' + json.serialize(existingSOAList));
                if(!existingSOAList.isEmpty()){
                    for(soa__c existingSOAListRec :existingSOAList){
                        allSOAList.add(existingSOAListRec);
                    }
                }else{
                    list<SOA__c> newSOAtoInsert = new list<SOA__c>();
                    for(date monthlyProgrammaticTrafficDatesRec :monthlyProgrammaticTrafficDates ){
                        
                        SOA__c soaRec = new SOA__c();

                        soaRec.SOA_Start_Date__c = monthlyProgrammaticTrafficDatesRec;
                        soaRec.SOA_End_Date__c = monthlyProgrammaticTrafficDatesRec.addMonths(1).addDays(-1);
                        soaRec.SOA_Type__c = 'Programmatic';
                        soaRec.SOA_Sources__c = 'Programmatic';

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

                
                List<Monthly_programmatic_traffic__c> MonthlyProgrammaticTrafficList = [
                    SELECT 
                    id,
                    name,
                    soa__c,
                    periode__c,
                    mitra__c,
                    date__c,
                    sales__c,
                    unique_id__c,
                    Brand__c
                    FROM Monthly_programmatic_traffic__c 
                    WHERE periode__c in :monthlyProgrammaticTrafficDates    
                ]; 

                system.debug('existingSOAMap: ' +  existingSOAMap);
                list<Monthly_programmatic_traffic__c> MonthlyClientTraffictoUpdateList = new list<Monthly_programmatic_traffic__c> ();
                for(Monthly_programmatic_traffic__c MonthlyProgrammaticTrafficListRec :MonthlyProgrammaticTrafficList){
                    if(MonthlyProgrammaticTrafficListRec.soa__c == null){
                        soa__c soaRec = existingSOAMap.get(MonthlyProgrammaticTrafficListRec.periode__c);
                        if(soaRec != null){
                            MonthlyProgrammaticTrafficListRec.soa__c = soaRec.Id;
                        }
                    }

                    MonthlyClientTraffictoUpdateList.add(MonthlyProgrammaticTrafficListRec);
                }

                set<id> newMonthlyProgrammaticTrafficUpdateIds = new set<id>();
                if(!MonthlyClientTraffictoUpdateList.isEmpty()){
                    update MonthlyClientTraffictoUpdateList;
                }
            }   
            
        } catch (Exception e) {
            String errMessage = 'Error on createSOAforMonthlyProgrammaticTraffic function::' + e.getMessage() + '::' + e.getLineNumber();
            System.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }

    public static void createOrderforMonthlyProgrammaticTraffic(set<string> newMonthlyProgrammaticTrafficIds){
        
        list<Monthly_Programmatic_Traffic__c> newMonthlyClientTrafficList = [ 
            SELECT 
            id,
            name,
            soa__c,
            periode__c,
            mitra__c,
            sales__c,
            unique_id__c,
            Brand__c
            FROM Monthly_Programmatic_Traffic__c 
            WHERE unique_id__c in: newMonthlyProgrammaticTrafficIds
        ];

        list<order> newOrderListtoInsert = new list<order>();
        if(!newMonthlyClientTrafficList.isEmpty()){
           // Pricebook2 pricebookRec = [select id, name from Pricebook2 where isStandard = true limit 1];
            Id stdPricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT id, name FROM Pricebook2 WHERE isStandard = true limit 1].Id;
            for(Monthly_Programmatic_Traffic__c monthlyClientTrafficListRec :newMonthlyClientTrafficList){
                
                Order newOrder = new order();
            
                newOrder.SOA__c = monthlyClientTrafficListRec.soa__c;
                newOrder.EffectiveDate = monthlyClientTrafficListRec.periode__c;
                newOrder.EndDate = monthlyClientTrafficListRec.periode__c.addMonths(1).addDays(-1);
                newOrder.Sales__c = (monthlyClientTrafficListRec.Sales__c != null) ? monthlyClientTrafficListRec.Sales__c : UserInfo.getUserId();
                newOrder.AccountId = monthlyClientTrafficListRec.mitra__c; 
                newOrder.Brand__c = monthlyClientTrafficListRec.Brand__c;
                newOrder.Order_Type__c = 'Programmatic';
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
            set<id> orderIdwitSOANulls = new set<id>();
            for(order newOrderListtoInsertRec :newOrderListtoInsert){
                if(newOrderListtoInsertRec.soa__c == null){
                    orderIdwitSOANulls.add(newOrderListtoInsertRec.id);
                }
                orderIds.add(newOrderListtoInsertRec.Id);
            }
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