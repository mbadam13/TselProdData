/**
 * @description       : 
 * @author            : Andre Prasetya
 * @group             : 
 * @last modified on  : 09-14-2022
 * @last modified by  : Andre Prasetya
**/

global class BatchDeleteAdexDaily implements Database.Batchable<sObject>{
  
    String query;

    public Database.QueryLocator start(Database.BatchableContext context)
    {

        query = 'SELECT id FROM Adex_Transaction__c WHERE Date__c = LAST_N_MONTHS:2 AND Date__c < LAST_N_MONTHS:1';
        return Database.getQueryLocator(query);
        
    }

    public void execute(Database.BatchableContext context, List<SObject> records)
    {
        delete records;
    }

    global void finish(Database.BatchableContext context){
    }

}