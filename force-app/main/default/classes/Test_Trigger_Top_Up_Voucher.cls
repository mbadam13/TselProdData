@isTest
public class Test_Trigger_Top_Up_Voucher{
     static testMethod void testMethod_up_TUvoucher() 
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
            
            Top_Up_Voucher__c newtuvoc= new Top_Up_Voucher__c();
            newtuvoc.Campaign_MyAds__c=newCampMyAds.id;
            newtuvoc.Amount__c=100000;
            newtuvoc.Account__c=acc.id;
            tuvoc.Payment_Method__c='LinkAja';
            newtuvoc.Date_Time_Reedem__c=datetime.now();
            insert newtuvoc;
  
            Test.stopTest();
       }

}