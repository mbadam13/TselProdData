/*
    Created By : Victor S & Andre
    7 September 2022
    
    This class is used to generate adex transaction monthly
*/

public class GenerateAdexMonthly {
    Date targetDate = date.today().addmonths(-1); //validation last month
    String month = string.ValueOf(targetDate.month());
    String year = string.ValueOf(targetDate.year());

    //update for vf
    public Boolean batchStatusBool {get;set;}
    public String batchStatus {get;set;}
    ID batchprocessid;
    public Boolean pollerBool {get;set;}

    public GenerateAdexMonthly() {
        batchStatusBool = false;
        pollerBool = false;
    }

    public void execute() {

        // Validation
        List<Adex_Transaction_Monthly__c> listATM = [SELECT id, Month_in_Text__c, Year__c FROM Adex_Transaction_Monthly__c WHERE Month__c =:month AND Year__c=:year LIMIT 1];
        if(listATM.size() > 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Data Month '+listATM[0].Month_in_Text__c+' '+listATM[0].Year__c+' Already Exists'));
            return;
        }
        
        batchStatusBool = true;
        BatchGenerateAdexMonthly newBatchGenerateAdexMonthly = new BatchGenerateAdexMonthly();
        batchprocessid = Database.executeBatch(newBatchGenerateAdexMonthly);
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