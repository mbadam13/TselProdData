@istest
public class Test_Trigger_Contract {
    static testMethod void testMethod_Create_Contract() {
        
        //Create Account
        Account acc = new Account ();
        acc.Name ='PT.Company Uji Coba';
        acc.RecordTypeId=Label.Account_RT_Advertiser;
        acc.Account_Type__c='Advertiser';
        acc.Email__c='ujicoba@ujicom.co.id';
        acc.Phone='654321';
        acc.Status__c = 'Approved by Settlement';
        acc.NPWP__c = '1234';
        acc.Converted_from_Lead__c=TRUE;
        insert acc;
        
        //Create Contract
        Contract contractRec = new Contract();
        contractRec.AccountId = acc.Id;
        contractRec.Status = 'Draft';
        contractRec.StartDate = Date.today();
        contractRec.ContractTerm = 12;
        contractRec.No_PKS__c = '123';
        insert contractRec; 
        
        contractRec.status = 'Activated';
        Upsert contractRec;
    }
}