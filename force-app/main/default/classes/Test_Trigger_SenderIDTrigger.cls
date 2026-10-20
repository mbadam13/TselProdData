@isTest
public class Test_Trigger_SenderIDTrigger {
       
     static testMethod void testMethod_positive() {

        Blacklist__c BL = new Blacklist__c();
        BL.Name='digiads';
        insert BL;
         
        //insert kategori industri 
        Kategori_Industri__c kategori =  new Kategori_Industri__c();
        kategori.prefix_ms__c = 'oth'; 
        kategori.Name = 'Others';
        Insert kategori ; 
      
        /* 
        //insert media seller
        account medsel = new account();
        medsel.Name = 'DWS';
        medsel.prefix_ms__c = 'dws';
        medsel.User_ID__c = 'dws'; 
        Insert medsel;
         
        //Insert SID 
        SID_Tools__c SIT = new SID_Tools__c();
        SIT.Sender_id__c='telkom';
        SIT.Type_Sender__c ='Premium';
        SIT.Kategori_Pesan__c ='Premium OTP';
        SIT.Type_SMS__c = 'SMS Bulk';
        SIT.Kategori_Industri__c = kategori.id;
        SIT.Media_Seller__c = medsel.id;
        insert SIT;
        
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
        cdl.LinkedEntityId = SIT.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        SIT.Status__c='Negotiation';
        Update SIT;
        */
         
        Test.startTest(); 
        //Insert custom setting 
        Use_Case_Setting__c useCase = new Use_Case_Setting__c();
        useCase.Name   = 'OTP';
        useCase.Code__c   = 'otp'; 
        insert useCase; 
         
        //Create (Insert) PNV 
        RecordType recType = [ SELECT Id, Name, DeveloperName, IsActive, SobjectType FROM RecordType WHERE Name = 'PNV' AND SobjectType = 'SID_Tools__c'];
        system.debug('Name Recordtype = ' + recType); 
        
         
        SID_Tools__c PNV   = new SID_Tools__c();
        PNV.RecordTypeId   = recType.Id;
        system.debug('Record Type   = ' + recType.Id);
         
        PNV.Legal_Name__c   = 'Test PNV 1234';
        PNV.App_Name__c   = 'Test PNV 1234';
        PNV.Indico__c   = 'Yes';
        //PNV.Registration_Number__c   = 1234;
        PNV.Address__c   = 'Bandung';
        PNV.URL__c   = 'ABCD.com';
        PNV.Privacy_Policy_URL__c   = 'ABCD.com';
        PNV.Terms_Conditions_URL__c   = 'ABCD.com'; 
        PNV.IP_s_to_be_whitelisted__c   ='ABCD.com';
        PNV.Media_Seller__c   = Label.MediaSeller_DWS;
        PNV.Anticipated_Launch_Date__c   = Date.today();
        PNV.Anticipated_Monthly_Transaction_Volume__c   = 1234;
        PNV.Use_Case__c   = 'OTP';
        PNV.PNV_Attachment__c   = 1;
        Insert PNV;
        System.debug('>>> PNV = ' + PNV);
        
        ContentVersion cv_pnv = new ContentVersion();
        cv_pnv.Title = 'PNVDoc';
        cv_pnv.PathOnClient = 'PNVDoc.pdf';
        cv_pnv.VersionData = Blob.valueOf('Test Content PNV');
        cv_pnv.IsMajorVersion = true;
        Insert cv_pnv;
        
        //Get Content Documents
        Id conPNVDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv_pnv.Id].ContentDocumentId;
        
        system.debug('isi condocid'+ conPNVDocId);
        //Create ContentDocumentLink 
        ContentDocumentLink cdl_pnv = New ContentDocumentLink();
        cdl_pnv.LinkedEntityId = PNV.Id;
        cdl_pnv.ContentDocumentId = conPNVDocId;
        cdl_pnv.shareType = 'V';
        Insert cdl_pnv;
         

        //Create (Update) PNV 
        PNV.Status__c   = 'Partnership Verification';
        Update PNV;
        System.debug('>>> PNV = ' + PNV);
         
        Test.stopTest();
    }
}