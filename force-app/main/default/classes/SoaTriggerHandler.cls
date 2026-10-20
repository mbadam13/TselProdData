/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 04-29-2024
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class SoaTriggerHandler {
    
    public static void afterInsert(list<SOA__c> soaList){
        system.debug('===SoaTriggerHandler afterInsert ===');
        for(soa__c soaListRec :soaList){
            if(soaListRec.Opportunity__c != null){
                system.debug('in createOrderforOppty');
                    if(!Test.isRunningTest()){
                    SoaService.createOrderforOppty(soaList);
                }
            }
        }
    }

    public static void afterUpdate(list<soa__c> oldSOAList, list<SOA__c> newSOAList){
        map<id, SOA__c> oldMapSOARec = new map<id, SOA__c>(oldSOAList);
        list<string> SOARecIdListForInvoiceUpdate = new list<string>();
        for(SOA__c newSOAListRec :newSOAList){
            SOA__c oldSOARec = oldMapSOARec.get(newSOAListRec.id);
            
            if(oldSOARec.Invoice__c != newSOAListRec.Invoice__c){
                SOARecIdListForInvoiceUpdate.add(newSOAListRec.id);
            }
        }

        if(!SOARecIdListForInvoiceUpdate.isEmpty()){
            RefreshInvoiceValueinOrderItem_Batch myBatch = new RefreshInvoiceValueinOrderItem_Batch(SOARecIdListForInvoiceUpdate);
            Database.executeBatch(myBatch);
        }
    }
}