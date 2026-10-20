/**
 * @description       : 
 * @author            : Andre Prasetya
 * @group             : 
 * @last modified on  : 09-15-2022
 * @last modified by  : Andre Prasetya
**/

public class DeleteAdexDaily {
    //update for vf
    public Boolean batchStatusBool {get;set;}
    public String batchStatus {get;set;}
    ID batchprocessid;
    public Boolean pollerBool {get;set;}

    public DeleteAdexDaily() {
        batchStatusBool = false;
        pollerBool = false;
    }

    public void execute() {
        // Validation
		List<Adex_Transaction__c> listAT = [SELECT id, date__c FROM Adex_Transaction__c WHERE Date__c = LAST_N_MONTHS:2 AND Date__c < LAST_N_MONTHS:1];
	    if(listAT.size() == 0){
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Data Doesnt Exists'));
	        return;
	    }   
        
        batchStatusBool = true;
        BatchDeleteAdexDaily newBatchGenerateAdexDaily = new BatchDeleteAdexDaily();
        batchprocessid = Database.executeBatch(newBatchGenerateAdexDaily);
        checkBatchStatus();
    }
 
    public void checkBatchStatus() {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: batchprocessid];
        batchStatus = job.Status;
        if(batchStatus == 'Completed') {
            pollerBool = false;
        } else {
            pollerBool = true;
        }
    }

}