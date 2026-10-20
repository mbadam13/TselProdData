@isTest(seealldata=false)
public class Test_Trigger_CampaignMyads_Before_Update {
    static testMethod void testMethod_Create_Cmyadsnonvoucher() {
        Test.startTest();
        
        Account newAcc = new Account();
        newAcc.Name='TINFIVE212';
        newAcc.User_ID__c = 'REG-DO-00000121662946223312';
        newAcc.Tanggal_Daftar__c= Date.today();
        newAcc.Tanggal_Approval_Aktivasi__c=system.now();
        newAcc.Email__c='PTSEJAHTERAMUDA1@GMAIL.COM';
        newAcc.Account_Type__c='DO';
        Upsert newAcc;
        
        Campaign_MyAds__c newCampMyAds = new Campaign_MyAds__c();
        newCampMyAds.Campaign_Type__c = 'Program';
        newCampMyAds.Campaign_Name__c='ini campaign';
        newCampMyAds.Voucher__c='Tanpa Kode Voucher';
        newCampMyAds.Own_proposal__c=true;
        newCampMyAds.Start_Date__c=date.today();
        newCampMyAds.End_Date__c=system.today().adddays(10);
        
        insert newCampMyAds;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'PrivyID';
        cv.PathOnClient = 'PrivyID.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        system.debug('isi condocid'+ conDocId);
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = newCampMyAds.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        newCampMyAds.Stage__c='Closed Won';
        update newCampMyAds;
        
        topup_voucher__c tuvoc = new topup_voucher__c();
        tuvoc.Campaign_MyAds__c = newCampMyAds.id;
        tuvoc.Amount__c = 100000;
        tuvoc.Account__c = newAcc.id;
        tuvoc.Payment_Method__c = 'Credit Card';
        tuvoc.Date_Time_Reedem__c = Date.today();
        tuvoc.Status_Top_Up__c = 'First Top Up';
        insert tuvoc;
        
        topup_voucher__c tuvoc3 = new topup_voucher__c();
        tuvoc3.Campaign_MyAds__c = newCampMyAds.id;
        tuvoc3.Amount__c = 100000;
        tuvoc3.Account__c = newAcc.id;
        tuvoc3.Payment_Method__c = 'Credit Card';
        tuvoc3.Date_Time_Reedem__c = Date.today();
        tuvoc3.Status_Top_Up__c = 'Re-Top Up';
        insert tuvoc3;
        
        Top_Up_Invoice__c tuinv= new Top_Up_Invoice__c();
        tuinv.ID_Transaksi__c='123xyz1';
        tuinv.Amount__c=100000;
        tuinv.User_Id__c=newAcc.id;
        tuinv.paid_date__c= Date.today();
        tuinv.Total_Topup__c=1;
        tuinv.Top_Up_Voucher__c= tuvoc.id;
        insert tuinv;
        
        Top_Up_Invoice__c newtuinv= new Top_Up_Invoice__c();
        newtuinv.ID_Transaksi__c='123xyzq';
        newtuinv.Amount__c=100000;
        newtuinv.User_Id__c=newAcc.id;
        newtuinv.paid_date__c= Date.today();
        tuinv.Total_Topup__c=2;
        tuinv.Top_Up_Voucher__c= tuvoc3.id;
        insert newtuinv;
        
        newCampMyAds.Stage__c='Completed';
        update newCampMyAds;
             
        Test.stopTest();

    }
    
    static testMethod void testMethod_Create_Cmyadsvoucher() {
        Test.startTest();
        
        Account newAcc = new Account();
        newAcc.Name='TINFIVE212';
        newAcc.User_ID__c = 'REG-DO-00000121662946223312';
        newAcc.Tanggal_Daftar__c= Date.today();
        newAcc.Tanggal_Approval_Aktivasi__c=system.now();
        newAcc.Email__c='PTSEJAHTERAMUDA1@GMAIL.COM';
        newAcc.Account_Type__c='DO';
        Upsert newAcc;
        
        Campaign_MyAds__c newCampMyAds = new Campaign_MyAds__c();
        newCampMyAds.Campaign_Type__c = 'Program';
        newCampMyAds.Campaign_Name__c='ini campaign22';
        newCampMyAds.Voucher__c='Pakai Kode Voucher';
        newCampMyAds.Own_proposal__c=true;
        newCampMyAds.Start_Date__c= Date.today();
        newCampMyAds.End_Date__c=system.today().adddays(10);
        newCampMyAds.Kode_Voucher__c='kodeads21';
        
        insert newCampMyAds;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'PrivyID';
        cv.PathOnClient = 'PrivyID.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        system.debug('isi condocid'+ conDocId);
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = newCampMyAds.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        newCampMyAds.Stage__c='Closed Won';
        update newCampMyAds;
        
        // ---dep -start
        newAcc.Tanggal_Pendaftaran__c = system.today().addDays(1);
        update newAcc;
        
        topup_voucher__c tuvoc1 = new topup_voucher__c();
        tuvoc1.Campaign_MyAds__c = newCampMyAds.id;
        tuvoc1.Amount__c = 100000;
        tuvoc1.Account__c = newAcc.id;
        tuvoc1.Payment_Method__c = 'Credit Card';
        tuvoc1.Date_Time_Reedem__c = Date.today();
        tuvoc1.Status_Top_Up__c = 'First Top Up';
        insert tuvoc1;
        
        topup_voucher__c tuvoc2 = new topup_voucher__c();
        tuvoc2.Campaign_MyAds__c = newCampMyAds.id;
        tuvoc2.Amount__c = 100000;
        tuvoc2.Account__c = newAcc.id;
        tuvoc2.Payment_Method__c = 'Credit Card';
        tuvoc2.Date_Time_Reedem__c = Date.today(); 
        tuvoc2.Status_Top_Up__c = 'Re-Top Up';
        insert tuvoc2;
        // ---dep -end
        
        
        
        Top_Up_Invoice__c tuinv= new Top_Up_Invoice__c();
        tuinv.ID_Transaksi__c='123xyz2';
        tuinv.Amount__c=100000;
        tuinv.User_Id__c=newAcc.id;
        tuinv.paid_date__c= Date.today();
        tuinv.Total_Topup__c=1;
        tuinv.Top_Up_Voucher__c= tuvoc1.id;
        insert tuinv;
        
        Top_Up_Invoice__c newtuinv= new Top_Up_Invoice__c();
        newtuinv.ID_Transaksi__c='123xyz1';
        newtuinv.Amount__c=100000;
        newtuinv.User_Id__c=newAcc.id;
        newtuinv.paid_date__c= Date.today();
        tuinv.Total_Topup__c=2;
        tuinv.Top_Up_Voucher__c= tuvoc2.id;
        insert newtuinv;
             
        newCampMyAds.Stage__c='Completed';
        update newCampMyAds;
        
        Test.stopTest();

    }
}