@isTest(seeAllData=false)
private with sharing class Test_WrapperSIDBatchController {
    static testMethod void doScenario1Test() {
        test.starttest();
        
        //SID_Tools__c SIDToolsObj = new SID_Tools__c();
        
        //select Id, Name,Batch__c,CP_Name__c,SID__c,Media_Seller__r.name from SID_Tools__c 
        //where Batch__c = null and documentStatus__c ='Completed' and CP_Name__c like:keyname 
        // and Type_Sender__c like:keytpe limit 50];
        
        
        SID_Tools__c sobj = new SID_Tools__c(
            Type_Sender__c = 'Premium',                                                                                                                                                    // Type Sender
            Company__c = 'MUSTIKA MDM',                                                                                                                                                      // Company
            No_Surat__c = 'SR.2002.03',                                                                                                                                                      // No Surat
            No_Kontrak__c = 'KR.2020.03',                                                                                                                                                    // No Kontrak
            //Media_Seller__c = 'undefined',                                                                                                                                                   // Media Seller
            Kategori_Pesan__c = 'Premium Notif',                                                                                                                                             // Kategori Pesan
            Sub_Reseller__c = false,                                                                                                                                                         // Sub Reseller?
            Format_Pesan__c = 'okre',                                                                                                                                                        // Format Pesan
            //Brand__c = 'undefined',                                                                                                                                                          // Brand
            Type_SMS__c = 'SMS Bulk',                                                                                                                                                        // Type
            Status__c = 'Draft',                                                                                                                                                       // Stages Status (Batch)
            Sender_ID__c = 'BANKMANDIRI',                                                                                                                                                    // Sender ID
            SID__c = 'rmstbanbankmandirirmryb',                                                                                                                                              // SID
            download__c = '== Keyset NOT found ==',                                                                                                                                          // download
            documentStatus__c = 'Completed',                                                                                                                                               // PrivyID Status
            docToken__c = 'a1aa339f84fedbc3f13d64072147d77ec77af5c6321106c73db18b55e05c6552',                                                                                                // docToken
            urlDocument__c = 'https://sign.privy.id/doc/a1aa339f84fedbc3f13d64072147d77ec77af5c6321106c73db18b55e05c6552',                                                                   // urlDocument
            Info_PrivyID__c = 'PrivyId:Ananda BudimuliaStatus:In ProgressDatetime:nullPrivyId:Laura M MinnesotaStatus:In ProgressDatetime:nullPrivyId:nullStatus:In ProgressDatetime:null',  // Info PrivyID
            Status_Approval_PrivyId__c = 'Waiting approval from Ananda Budimulia',                                                                                                           // Status Approval PrivyId
            Submit_Date__c = Datetime.valueOf('2020-10-10 07:00:00'),                                                                                                                        // Submit Date
            Batch__c = null
            
        );
        insert sobj;
            
        
        //apexpages.standardcontroller sc = new apexpages.standardcontroller(SIDToolsObj);
        //WrapperSIDBatchController WrapperSIDBatchControllerObj = new WrapperSIDBatchController(SC);
        
        WrapperSIDBatchController  wrapperSIDBatchControllerObj  = New WrapperSIDBatchController();
        //apexpages.standardcontroller sc = new apexpages.standardcontroller(wrapperSIDBatchControllerObj);
        
        wrapperSIDBatchControllerObj.searchKeyname = 'sms';
        wrapperSIDBatchControllerObj.searchKeytype = 'Premium';
        wrapperSIDBatchControllerObj.searchRecord();
       
        
        wrapperSIDBatchControllerObj.processSelected();
        wrapperSIDBatchControllerObj.ActivateData();
        wrapperSIDBatchControllerObj.DeActivateData();
        //wrapperSIDBatchControllerObj.back();
         wrapperSIDBatchControllerObj.clear();
        wrapperSIDBatchControllerObj.callpageredirect();
        
        
        test.stoptest();
        
    }
}