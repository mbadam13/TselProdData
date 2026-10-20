global with sharing  class Schedule_CheckStatusPrivyId_KertasKerja implements Schedulable {
    
	// Daily Scheduler
    global void execute(SchedulableContext sc){
        
        List<Kertas_Kerja__c> kkList = [SELECT Id, Name FROM Kertas_Kerja__c 
                                        WHERE Status__c = 'Review' 
                                        OR (Status__c = 'Completed' AND DAY_ONLY(KK_Completed_Datetime__c) = Today)];
        system.debug('*** kkList = ' + kkList.size() + ' | ' + kkList);
        
        for(Kertas_Kerja__c kkRec : kkList){
			REST_PrivyID_Check_Doc_StatusKertasKerja.CheckDocumentStatus(kkRec.Id);
        }
    }
    
}