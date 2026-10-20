/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
* @last modified on  : 04-29-2024
 * @last modified by  : Ahmat Zulkifli Murad
 * Test class         : CalculateSOAorQuoteFinalRev_BatchTest
**/
global without sharing class CalculateSOAorQuoteFinalRev_Batch implements Database.Batchable<sObject> {
    Set<String> newOrderIds = new Set<String>();
    global CalculateSOAorQuoteFinalRev_Batch(set<String> orderRecordIds) {
        for(string QuoteorSOAIds :orderRecordIds){
            newOrderIds.add('\'' + QuoteorSOAIds + '\'');
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('newOrderIds.size():: ' + newOrderIds.size());
        System.debug('newOrderIds:: ' + newOrderIds);
        String whereCondition = '(' + string.join(newOrderIds, ',') + ')';
        System.debug('whereCondition:: ' + whereCondition);
        
        String queryString =
            'SELECT ' + 
                'id, ' +
                'soa__c, ' +
                'QuoteId ' +
            'FROM '+
                'Order ' +
            'WHERE id IN ' +
                whereCondition;
        
        System.debug('queryString:: ' + queryString);
        
        return Database.getQueryLocator(queryString);
    }
    

    global void execute(Database.BatchableContext BC, List<Order> orderList){
        set<String> SOAIds = new set<String>();
        set<String> QuoteIds = new set<String>();
        System.debug('orderList:: ' + orderList);
        for(Order orderListRec :orderList){
            if(orderListRec.soa__c != null && orderListRec.QuoteId == null){
                SOAIds.add(orderListRec.soa__c);
            }
            else if(orderListRec.soa__c == null && orderListRec.QuoteId != null){
                QuoteIds.add(orderListRec.QuoteId);
            }      
        }
        System.debug('SOAIds:: ' + SOAIds);
        System.debug('QuoteIds:: ' + QuoteIds);
        if(!SOAIds.isEmpty()){
            List<AggregateResult> aggregateOrderSOA =[
                SELECT 
                    SOA__c soaId,
                    SUM(Final_Sum_Revenue_Telkomsel__c) FinalRev
                FROM 
                    Order
                Where 
                    SOA__c IN :SOAIds
                GROUP BY
                    SOA__c                   
            ];

            System.debug('aggregateOrderSOA:: ' + aggregateOrderSOA);
            list<soaRecordWrapper> soaRecordWrapperList = new list<soaRecordWrapper>();
            for(AggregateResult aggregateOrderSOAValue :aggregateOrderSOA){
                soaRecordWrapper soaRecordWrapperClass = new soaRecordWrapper();
                soaRecordWrapperClass.soaid = (String) aggregateOrderSOAValue.get('soaId');
                soaRecordWrapperClass.finalSOARevenue = (Double) aggregateOrderSOAValue.get('FinalRev');

                soaRecordWrapperList.add(soaRecordWrapperClass);
            }

            System.debug('soaRecordWrapperList:: ' + soaRecordWrapperList);
            map<string, double> aggregateOrderSOAMap = new Map<String,Double>();
            for(soaRecordWrapper soaRecordWrapperListRec :soaRecordWrapperList){
                aggregateOrderSOAMap.put(soaRecordWrapperListRec.soaid, soaRecordWrapperListRec.finalSOARevenue);
            }

            list<SOA__c> soaList = [SELECT id, Final_Sum_Revenue_Telkomsel__c FROM SOA__c WHERE Id IN :SOAIds];
            System.debug('soaList:: ' + soaList);
            for(SOA__c soaListRec :soaList){
                double finalRevenue = aggregateOrderSOAMap.get(soaListRec.id);
                soaListRec.Final_Sum_Revenue_Telkomsel__c = finalRevenue;
            }
            System.debug('soaListafter:: ' + soaList);
            update soaList;
        }

        if(!QuoteIds.isEmpty()){
            List<AggregateResult> aggregateOrderQuote =[
                SELECT 
                    QuoteId QuoteRecId,
                    SUM(Final_Sum_Revenue_Telkomsel__c) FinalRev
                FROM 
                    Order
                Where 
                    QuoteId IN :QuoteIds
                GROUP BY
                    QuoteId                   
            ];

            list<quoteRecordWrapper> quoteRecordWrapperList = new list<quoteRecordWrapper>();
            for(AggregateResult aggregateOrderQuoteValue :aggregateOrderQuote){
                quoteRecordWrapper quoteRecordWrapperClass = new quoteRecordWrapper();
                quoteRecordWrapperClass.quoteId = (String) aggregateOrderQuoteValue.get('QuoteRecId');
                quoteRecordWrapperClass.finalSOARevenue = (Double) aggregateOrderQuoteValue.get('FinalRev');

                quoteRecordWrapperList.add(quoteRecordWrapperClass);
            }

            map<string, double> aggregateOrderQuoteMap = new Map<String,Double>();
            for(quoteRecordWrapper quoteRecordWrapperListRec :quoteRecordWrapperList){
                aggregateOrderQuoteMap.put(quoteRecordWrapperListRec.quoteId, quoteRecordWrapperListRec.finalSOARevenue);
            }

            list<Quote> quoteList = [SELECT id, Final_Sum_Revenue_Telkomsel__c FROM Quote WHERE Id IN :QuoteIds];
            for(Quote quoteListRec :quoteList){
                double finalRevenue = aggregateOrderQuoteMap.get(quoteListRec.id);
                quoteListRec.Final_Sum_Revenue_Telkomsel__c = finalRevenue;
            }

            update quoteList;
        }
    }

    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
            Select a.TotalJobItems, 
            a.Status, 
            a.NumberOfErrors,
            a.JobType, 
            a.JobItemsProcessed, 
            a.ExtendedStatus, 
            a.CreatedById,
            a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()
        ];
    }

    global class soaRecordWrapper{
        global string soaId;
        global double finalSOARevenue;
    }

    global class quoteRecordWrapper{
        global string quoteId;
        global double finalSOARevenue;
    }
}