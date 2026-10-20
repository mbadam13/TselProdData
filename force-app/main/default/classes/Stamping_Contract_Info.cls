public class Stamping_Contract_Info {   
    //Contract
    public static void updateContractDateonAccount(list<Contract> newContractList){
        system.debug('Masuk Stamping_Contract_Info.updateContractDateonAccount !!!');
        List<Account> newAccountListUpdate = new List <account>();
        
        for(contract newContractRec : newContractList){
            
            system.debug('*** Status | archive__c | StartDate | Today | EndDate = ' + newContractRec.Status + ' | ' + newContractRec.archive__c + ' | ' 
                     + newContractRec.StartDate + ' | '+ system.today() + ' | ' + newContractRec.EndDate);
            
            if(newContractRec.Status == 'Activated' 
               && newContractRec.archive__c == False 
               && newContractRec.StartDate <= system.today() 
               && newContractRec.EndDate >= system.today())
            {
                system.debug('*** Masuk Looping contract ' + newContractRec.ContractNumber);
                Account accountRec = new Account();
                accountRec.id = newContractRec.AccountId;
                accountRec.ContractId__c = newContractRec.id;
                accountRec.No_PKS__c = newContractRec.No_PKS__c;
                accountRec.Active_Contract_Start_Date__c = newContractRec.StartDate;
                accountRec.Active_Contract_End_Date__c = newContractRec.EndDate;
                
                newAccountListUpdate.add(accountRec);
            }
        }
        update newAccountListUpdate;
    }
    
}