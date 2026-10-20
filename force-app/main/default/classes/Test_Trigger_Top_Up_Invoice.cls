@isTest
public class Test_Trigger_Top_Up_Invoice{
     static testMethod void testMethod_up_TUinvoice() 
     {
            Test.startTest();
            Account acc = new Account ();
            acc.Name= 'Sukses Maju lah';
            acc.User_ID__c='REG-DO-0000001066171';
            acc.npwp__c='123412';
            insert acc;
            
            Campaign_MyAds__c newCampMyAds = new Campaign_MyAds__c();
            newCampMyAds.Campaign_Name__c='ini campaign';
            newCampMyAds.Own_proposal__c=true;
            newCampMyAds.Start_Date__c=date.today();
            newCampMyAds.End_Date__c=system.today().adddays(10);
            newCampMyAds.Kode_Voucher__c='kodeads1';
            
            insert newCampMyAds;
            
            Top_Up_Voucher__c tuvoc= new Top_Up_Voucher__c();
            tuvoc.Campaign_MyAds__c=newCampMyAds.id;
            tuvoc.Amount__c=100000;
            tuvoc.Account__c=acc.id;
            tuvoc.Payment_Method__c='Credit Card';
            tuvoc.Date_Time_Reedem__c=datetime.now();
            insert tuvoc;
  
            Top_Up_Invoice__c tuinv= new Top_Up_Invoice__c();
            tuinv.ID_Transaksi__c='123xyz';
            tuinv.Amount__c=100000;
            tuinv.User_Id__c=acc.id;
            tuinv.paid_date__c=DateTime.newInstance(2021, 1, 1, 3, 3, 3);
            insert tuinv;
            
            Top_Up_Invoice__c newtuinv= new Top_Up_Invoice__c();
            newtuinv.ID_Transaksi__c='1234xyz';
            newtuinv.Amount__c=100000;
            newtuinv.User_Id__c=acc.id;
            newtuinv.paid_date__c=datetime.now();
            newtuinv.Total_Topup__c = 1;
            insert newtuinv;
         
         	Top_Up_Invoice__c re_tui_01 = new Top_Up_Invoice__c();
            re_tui_01.ID_Transaksi__c='123retui01';
         	re_tui_01.Total_Topup__c = 3;
            re_tui_01.Amount__c = 120000;
            re_tui_01.User_Id__c = acc.id;
            re_tui_01.paid_date__c = datetime.now();
            insert re_tui_01;
         	
         	List<Top_Up_Invoice__c> tui_list = [SELECT Id, Paid_Date__c, Paid_Date_Date__c FROM Top_Up_Invoice__c ORDER BY CreatedDate ASC];
         	
         	Id jobid_actualsme = Database.executeBatch(new Batch_GetActualSME(tui_list), 200);
    
            Test.stopTest();
       }

}