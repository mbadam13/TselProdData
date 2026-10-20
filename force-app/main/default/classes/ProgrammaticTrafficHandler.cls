/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class ProgrammaticTrafficHandler {
    
    public static void beforeInsert(List<Programmatic_Traffic__c> progTrafficList) {
        ProgrammaticTrafficServices.evaluateProgrammaticTraffic(progTrafficList);
    }

    public static void afterInsert(List<Programmatic_Traffic__c> newProgrammaticList){
        
        Set<Id> IdsforCreateMonthlyProggramatic = new Set<Id>();
        
        for(Programmatic_Traffic__c newProgrammaticListRec :newProgrammaticList){
            if(newProgrammaticListRec.Monthly_Programmatic_Traffic__c == null){
                IdsforCreateMonthlyProggramatic.add(newProgrammaticListRec.id);
            }
        }

        if(!IdsforCreateMonthlyProggramatic.isEmpty()){
            ProgrammaticTrafficServices.createMonthlyProgrammaticTraffic(IdsforCreateMonthlyProggramatic);
        }
    }

    /*
    public static void afterUpdate(List<Programmatic_Traffic__c> newProgrammaticTrafficList, List<Programmatic_Traffic__c> oldProgrammaticTrafficList){
        Map<Id,Programmatic_Traffic__c> oldMap = new Map<Id,Programmatic_Traffic__c>(oldProgrammaticTrafficList);
        set<id> newProgrammaticTrafficUpdateIds = new set<id>();
        for(Programmatic_Traffic__c programmaticTrafficRec: newProgrammaticTrafficList){

            if(
                programmaticTrafficRec.Paid_Impression__c != oldMap.get(programmaticTrafficRec.Id).Paid_Impression__c || 
                programmaticTrafficRec.Revenue__c != oldMap.get(programmaticTrafficRec.Id).Revenue__c
            ){
                newProgrammaticTrafficUpdateIds.add(programmaticTrafficRec.id);
            }
        }
        if(!newProgrammaticTrafficUpdateIds.isEmpty()){
            ProgrammaticTrafficServices.createMonthlyProgrammaticTraffic(newProgrammaticTrafficUpdateIds);
        }
        
    }
    */
}