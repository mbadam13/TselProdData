public class Batch_EB_ConfirmedExpired implements Database.Batchable<sObject>, Database.Stateful{
	
    public List<Expired_Bucket__c> eb_List = new List<Expired_Bucket__c>();
    
    public Batch_EB_ConfirmedExpired(List<Expired_Bucket__c> paramEbList){
        system.debug('Masuk Batch_EB_ConfirmedExpired constructor !!!');
        eb_List = paramEbList;
    }
    
    public List<Expired_Bucket__c> start(Database.BatchableContext BC){
        system.debug('Masuk Batch_EB_ConfirmedExpired START !!!');
        return eb_List;
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('Masuk execute Batch_EB_ConfirmedExpired -- eb_List.size() = ' + eb_List.size());
        system.debug('*** scope.size() = ' + scope.size());
        List<Expired_Bucket__c> ebListToUpdate = (List<Expired_Bucket__c>) scope;
        update ebListToUpdate;
    } 
    
    public void finish(Database.BatchableContext BC){
	        
    }
}