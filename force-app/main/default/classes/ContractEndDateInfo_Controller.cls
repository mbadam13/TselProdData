public class ContractEndDateInfo_Controller {
    
    public String contractInfo_msg {get; set;}
    
    public ContractEndDateInfo_Controller() {
        
        String opp_id = apexpages.currentpage().getparameters().get('id'); system.debug('*** opp_id = ' + opp_id);
        
        Opportunity opp_rec = [SELECT Id, Name, ContractId, Contract.ContractNumber, Contract_Status__c, Contract_End_Date__c,
                               Day_s_Before_Contract_End__c, Display_Contract_End_Date_Info__c, Penagihan_based_on__c 
                               FROM Opportunity WHERE Id =: opp_id];
        system.debug('*** opp_rec = ' + opp_rec);
        
        contractInfo_msg = 'Contract will be expired within ' + opp_rec.Day_s_Before_Contract_End__c + ' day(s). Contract End Date is on ' + opp_rec.Contract_End_Date__c + '.';
        
        if(opp_rec.Display_Contract_End_Date_Info__c == true){
            if(opp_rec.Day_s_Before_Contract_End__c < 0){
                contractInfo_msg = 'Contract has expired.';
            }else if(opp_rec.Day_s_Before_Contract_End__c == 0){
                contractInfo_msg = 'Contract will be end by today.';
            }else{
                contractInfo_msg = 'Contract will be expired within ' + opp_rec.Day_s_Before_Contract_End__c + ' day(s).';
            }
            
            contractInfo_msg = contractInfo_msg + ' Contract End Date is on ' + opp_rec.Contract_End_Date__c.format() + '.';
            
            if(opp_rec.Day_s_Before_Contract_End__c < integer.valueOf(Label.Days_Before_ContractEndDate_To_Prevent_Creating_SOA_Quotation)){
                
                String x = '';
                
                if(opp_rec.Penagihan_based_on__c == 'Prepaid'){x = 'Quotation';}
                else if(opp_rec.Penagihan_based_on__c == 'Postpaid'){x = 'SOA';}
                
                contractInfo_msg = contractInfo_msg + ' Please renew the contract before create ' + x + ' or continue to the next step.';
            }
        }
        
    }
    
}