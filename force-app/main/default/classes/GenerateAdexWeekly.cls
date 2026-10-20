/*
    Created By : Victor S & Andre
    5 September 2022
    
    This class is used to generate adex transaction weekly
*/

public class GenerateAdexWeekly {
	Date targetDate = date.today().addmonths(-1); // validation last month
    String month = string.ValueOf(targetDate.month());
    String year = string.ValueOf(targetDate.year());
   
    //update for vf
    public Boolean batchStatusBool1 {get;set;}
    public String batchStatus1 {get;set;}
    ID batchprocessid1;
    public Boolean pollerBool1 {get;set;}

	public Boolean batchStatusBool2 {get;set;}
    public String batchStatus2 {get;set;}
    ID batchprocessid2;
    public Boolean pollerBool2 {get;set;}

    public Boolean batchStatusBool3 {get;set;}
    public String batchStatus3 {get;set;}
    ID batchprocessid3;
    public Boolean pollerBool3 {get;set;}

    public Boolean batchStatusBool4 {get;set;}
    public String batchStatus4 {get;set;}
    ID batchprocessid4;
    public Boolean pollerBool4 {get;set;}

    public Boolean batchStatusBool5 {get;set;}
    public String batchStatus5 {get;set;}
    ID batchprocessid5;
    public Boolean pollerBool5 {get;set;}

    public Boolean batchStatusBool6 {get;set;}
    public String batchStatus6 {get;set;}
    ID batchprocessid6;
    public Boolean pollerBool6 {get;set;}

    public GenerateAdexWeekly() {
        batchStatusBool1 = false;
        pollerBool1 = false;
        
        batchStatusBool2 = false;
        pollerBool2 = false;

        batchStatusBool3 = false;
        pollerBool3 = false;
        
        batchStatusBool4 = false;
        pollerBool4 = false;

        batchStatusBool5 = false;
        pollerBool5 = false;
        
        batchStatusBool6 = false;
        pollerBool6 = false;
    }

    public void execute() {
		// Validation
		List<Adex_Transaction_Weekly__c> listATW = [SELECT id, Month_in_Text__c, Year__c FROM Adex_Transaction_Weekly__c WHERE Month__c =:month AND Year__c=:year LIMIT 1];
	    if(listATW.size() > 0){
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Data Month '+listATW[0].Month_in_Text__c+' '+listATW[0].Year__c+' Already Exists'));
	        return;
	    }
		
        batchStatusBool1 = true;
    	BatchGenerateAdexWeekly newBatchGenerateAdexweekly1 = new BatchGenerateAdexWeekly();
    	newBatchGenerateAdexweekly1.executeWeek = 1; 
    	batchprocessid1 = Database.executeBatch(newBatchGenerateAdexweekly1);
        checkBatchStatus1();
        
        batchStatusBool2 = true;
    	BatchGenerateAdexWeekly newBatchGenerateAdexweekly2 = new BatchGenerateAdexWeekly();
    	newBatchGenerateAdexweekly2.executeWeek = 2; 
    	batchprocessid2 = Database.executeBatch(newBatchGenerateAdexweekly2);
        checkBatchStatus2();

        batchStatusBool3 = true;
    	BatchGenerateAdexWeekly newBatchGenerateAdexweekly3 = new BatchGenerateAdexWeekly();
    	newBatchGenerateAdexweekly3.executeWeek = 3; 
    	batchprocessid3 = Database.executeBatch(newBatchGenerateAdexweekly3);
        checkBatchStatus3();

        batchStatusBool4 = true;
    	BatchGenerateAdexWeekly newBatchGenerateAdexweekly4 = new BatchGenerateAdexWeekly();
    	newBatchGenerateAdexweekly4.executeWeek = 4; 
    	batchprocessid4 = Database.executeBatch(newBatchGenerateAdexweekly4);
        checkBatchStatus4();

        batchStatusBool5 = true;
    	BatchGenerateAdexWeekly newBatchGenerateAdexweekly5 = new BatchGenerateAdexWeekly();
    	newBatchGenerateAdexweekly5.executeWeek = 5; 
    	batchprocessid5 = Database.executeBatch(newBatchGenerateAdexweekly5);
        checkBatchStatus5();

        batchStatusBool6 = true;
    	BatchGenerateAdexWeekly newBatchGenerateAdexweekly6 = new BatchGenerateAdexWeekly();
    	newBatchGenerateAdexweekly6.executeWeek = 6; 
    	batchprocessid6 = Database.executeBatch(newBatchGenerateAdexweekly6);
        checkBatchStatus6();
    }

    public void checkBatchStatus1() {
        AsyncApexJob job1 = [SELECT Id,  Status FROM AsyncApexJob WHERE Id =: batchprocessid1];
        batchStatus1 = job1.Status;
        if(batchStatus1 == 'Completed') {
            pollerBool1 = false;
        } else {
            pollerBool1 = true;
        }
    }
    
    public void checkBatchStatus2() {
        AsyncApexJob job2 = [SELECT Id,  Status FROM AsyncApexJob WHERE Id =: batchprocessid2];
        batchStatus2 = job2.Status;
        if(batchStatus2 == 'Completed') {
            pollerBool2 = false;
        } else {
            pollerBool2 = true;
        }
    }

    public void checkBatchStatus3() {
        AsyncApexJob job3 = [SELECT Id,  Status FROM AsyncApexJob WHERE Id =: batchprocessid3];
        batchStatus3 = job3.Status;
        if(batchStatus3 == 'Completed') {
            pollerBool3 = false;
        } else {
            pollerBool3 = true;
        }
    }

    public void checkBatchStatus4() {
        AsyncApexJob job4 = [SELECT Id,  Status FROM AsyncApexJob WHERE Id =: batchprocessid4];
        batchStatus4 = job4.Status;
        if(batchStatus4 == 'Completed') {
            pollerBool4 = false;
        } else {
            pollerBool4 = true;
        }
    }

    public void checkBatchStatus5() {
        AsyncApexJob job5 = [SELECT Id,  Status FROM AsyncApexJob WHERE Id =: batchprocessid5];
        batchStatus5 = job5.Status;
        if(batchStatus5 == 'Completed') {
            pollerBool5 = false;
        } else {
            pollerBool5 = true;
        }
    }

    public void checkBatchStatus6() {
        AsyncApexJob job6 = [SELECT Id,  Status FROM AsyncApexJob WHERE Id =: batchprocessid6];
        batchStatus6 = job6.Status;
        if(batchStatus6 == 'Completed') {
            pollerBool6 = false;
        } else {
            pollerBool6 = true;
        }
    }
    
}