@isTest
public class Test_PrivyId_SID {
	
    static testMethod void testMethod_sendPrivyId_SID(){
        
        SID_Tools__c SIT = new SID_Tools__c();
        SIT.Sender_ID__c = 'jatis';
        SIT.Media_Seller__c = Label.parentid;
        SIT.OwnerId = Label.Owner_MS;
        SIT.Type_Sender__c = 'Premium';
        //SIT.Kategori_Pesan__c = 'SMS Bulk';
        //SIT.Brand__c = MB.id;
        SIT.Type_SMS__c = 'SMS Bulk';
        SIT.SID__c = 'jatis123xyz';
        SIT.Sub_Reseller__c = FALSE;
        SIT.Company__c = 'PT Coba Testing';
        //SIT.SID_Approval__c = 'Approved';
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
        insert cdl;
        
        SIT.SID_Approval__c = 'Approved';
        update SIT;
    }
}