@isTest
public class Test_Schedule_Archive_Contract {
	
    static testMethod void test_schArchContract(){
        Test.startTest();
        
        Account acc = new Account();
        acc.Name = 'Acc ABC';
        acc.Status__c = 'Approved by Settlement';
        acc.NPWP__c = '1234';
        insert acc; 
        system.debug('>>> acc = ' + acc);
        
        Contract contractRec = new Contract();
        contractRec.AccountId = acc.Id;
        contractRec.Status = 'Draft';
     	contractRec.StartDate = system.today().addDays(-31);
     	contractRec.ContractTerm = 1;
        contractRec.Archive__c = false;
        insert contractRec; 
        
        contractRec.Status = 'Activated';
        update contractRec;
        
        String CRON_EXP = '0 0 1 * * ?';
        System.schedule('Schedule ArchiveContract',CRON_EXP, new Schedule_ArchiveContract());    
        Test.stopTest();
        
    }
}