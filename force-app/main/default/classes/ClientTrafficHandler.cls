/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class ClientTrafficHandler {

    public static void beforeInsert(List<Client_Traffic__c> clientTrafficList){
        ClientTrafficServices.evaluateClientTraffic(clientTrafficList);
    }

    public static void afterInsert(List<Client_Traffic__c> clientTrafficList){
        //ClientTrafficServices.createBrand(clientTrafficList);
        List<Client_Traffic__c> newClientTrafficList = new List<Client_Traffic__c>();
        for( Client_Traffic__c clientTrafficListRec :clientTrafficList){
            if(clientTrafficListRec.monthly_client_traffic__c == null){
                newClientTrafficList.add(clientTrafficListRec);
            }
        }

        set<id> MonthlyClientTrafficIds = new set<id>();
        for(Client_Traffic__c newClientTrafficListRec :newClientTrafficList){
            MonthlyClientTrafficIds.add(newClientTrafficListRec.id);
        }

        if(!MonthlyClientTrafficIds.isEmpty()){
            ClientTrafficServices.createMonthlyClientTraffic(MonthlyClientTrafficIds);
        }

        
        
    }
/*
    public static void afterUpdate(List<Client_Traffic__c> clientTrafficList,List<Client_Traffic__c> oldClientTrafficList){
        
        Map<Id,Client_Traffic__c> oldMap = new Map<Id,Client_Traffic__c>(oldClientTrafficList);
        set<id> newClientTrafficIds = new set<id>();

        for(Client_Traffic__c clientTrafficRec: clientTrafficList){

            if(clientTrafficRec.order_quantity__c != oldMap.get(clientTrafficRec.Id).order_quantity__c){
                newClientTrafficIds.add(clientTrafficRec.id);
            }
        }
        if(!newClientTrafficIds.isEmpty()){
            ClientTrafficServices.createMonthlyClientTraffic(newClientTrafficIds);
        }
    }
*/  
}