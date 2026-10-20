/*
    Created By : Victor S
    14 January 2022
    
    This trigger is used to mapping brand name and brand type & add 1000 to adspend
*/

trigger Trigger_Adex_Transaction on Adex_Transaction__c (before insert, before update) {
    for(Adex_Transaction__c myTransaction : trigger.new) {
    	if(myTransaction.Product__c.Contains(' - ')){
    		String[] product = myTransaction.Product__c.split(' - ');
            
            if(myTransaction.Product__c.countMatches(' - ')>1){
                myTransaction.addError('invalid format data product');
                }
                      
	    	myTransaction.Brand_Name__c = product[0];
	    	myTransaction.Brand_Type__c = product[1];
    	} else {
    		myTransaction.Brand_Name__c = myTransaction.Product__c;
   			myTransaction.Brand_Type__c = myTransaction.Product__c;
    	}
    	
    	myTransaction.AdSpend__c = myTransaction.AdSpend__c*1000;
    	
    	//  update 31/08/2022 by Andre fungsi convert date menjadi week 1 - week 6
        date myDate = myTransaction.Date__c;
        integer day = myDate.day();
        integer month = myDate.month();
        integer year = myDate.year();
        
        Date dateCalculate = date.newinstance(1900, 4, 2);
        date dateNow = date.newInstance( year, month, 1);
        integer numberDaysDue = dateCalculate.daysBetween(dateNow);        
        integer numberOfWeek = integer.valueOf( math.ceil((  day + double.valueOf( math.MOD( numberDaysDue, 7)) )/ double.valueOf( 7)));
 		myTransaction.Week_Per_Month__c = String.valueOf(numberOfWeek);
    }
}