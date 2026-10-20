@istest
public class Test_Stamping_Contract_Info {   
    static testMethod void testStampingContractInfo(){
        test.startTest();
            
         //Create Account
        Account acc = new Account ();
        acc.Name ='PT.Company Uji Coba';
        acc.RecordTypeId=Label.Account_RT_Advertiser;
        acc.Account_Type__c='Advertiser';
        acc.Email__c='ujicoba@ujicom.co.id';
        acc.Phone='654321';
        acc.Converted_from_Lead__c=TRUE;
        acc.Status__c = 'Approved by Settlement';
        acc.NPWP__c = '1234';
        insert acc;
        
        //Create Contract
        Contract contractRec = new Contract();
        contractRec.AccountId = acc.Id;
        contractRec.Status = 'Draft';
        contractRec.StartDate = system.today().addDays(-30);
        contractRec.ContractTerm = 1;
        contractRec.No_PKS__c = '123';
        insert contractRec; 
        
        contractRec.status = 'Activated';
        Upsert contractRec;
        
        Test.stopTest();      
    }
}