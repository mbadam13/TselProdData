@isTest
public class Test_Trigger_Account_Before_Insert {

    static testMethod void testMethod_Create_Account() {
        Test.startTest();
        Account newAcc = new Account();
        newAcc.Name='TINFIVE212';
        newAcc.User_ID__c = 'REG-DO-00000121662946223312';
        //newAcc.Tanggal_Pendaftaran__c=system.now();
        newAcc.Tanggal_Daftar__c=system.today();
        newAcc.Tanggal_Approval_Aktivasi__c=system.now();
        newAcc.Email__c='PTSEJAHTERAMUDA1@GMAIL.COM';
        newAcc.Account_Type__c='DO';
        Upsert newAcc;
        Test.stopTest();
        
        List<Account> acc_list = new List<Account>();
        acc_list.add(newAcc);
        Id jobid_actualsme_register = Database.executeBatch(new Batch_GetActualSME_Register(acc_list), 25);
    }
}