/*
    Created By : Victor S
    14 January 2022
    
    This class is used to generate adex brand and mapping that into adex transaction
*/

public class GenerateAdexBrand {
    public Boolean batchStatusBool {get;set;}
    public String batchStatus {get;set;}
    ID batchprocessid;
    public Boolean pollerBool {get;set;}

    public GenerateAdexBrand() {
        batchStatusBool = false;
        pollerBool = false;
    }

    public void execute() {   
        
           // Validation
           List<Adex_Transaction__c> listAT = [SELECT id FROM Adex_Transaction__c WHERE Adex_Brand__c = NULL AND CreatedDAte >= LAST_WEEK AND CreatedDAte <= THIS_WEEK LIMIT 1];
           if(listAT.size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Data Not Found'));
            return;
           }
           
           batchStatusBool = true;
           BatchGenerateAdex newBatchGenerateAdex = new BatchGenerateAdex();
           batchprocessid = Database.executeBatch(newBatchGenerateAdex);
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