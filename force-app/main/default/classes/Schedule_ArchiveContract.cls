global class Schedule_ArchiveContract implements Schedulable {
    
    // Daily Scheduler
    global void execute(SchedulableContext sc){
        List<Contract> listContract = [Select id, Name, archive__c, AccountId, StartDate, EndDate, status, ContractNumber, No_PKS__c
                                       FROM Contract 
                                       WHERE status = 'Activated'
                                       and archive__c = False 
                                       and EndDate = Yesterday];
        system.debug('listContract = ' + listContract.size() + ' | '+ listContract);
        
        List<String> accIdListForNewContract = new List<String>();
        
        for(Contract myContract:listContract){  
            system.debug(' contract ' + myContract );
            myContract.archive__c = TRUE;
            myContract.Status = 'Inactive';
            accIdListForNewContract.add(myContract.AccountId);//get account ID masukin ke List accountListTemp
        }
        system.debug('list contract >>>>' + listContract);
        update listContract;
       
        //query contract active in period untuk accountListTemp --> contractListTemp
        List<Contract> newContractList = [Select id, Name, Status, archive__c, StartDate, EndDate, ContractNumber, AccountId, No_PKS__c                                         
                                          FROM Contract 
                                          WHERE AccountId IN: accIdListForNewContract  
                                          and archive__c = False 
                                          and StartDate <= TODAY 
                                          and EndDate >= TODAY
                                          ORDER BY CreatedDate];
        system.debug('newContractList = ' + newContractList.size() + ' | '+ newContractList);
        
        //panggil Stamping_Contract_Info.updateContractDateonAccount(contractListTemp);
        Stamping_Contract_Info.updateContractDateonAccount(newContractList);
    }
}