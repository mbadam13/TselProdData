@isTest
public class Test_PrivyId_KertasKerja {
	
    static testMethod void test_privyId_kk(){
        
        DataFactory df = new DataFactory();
        List<Account> accList = df.createAccount();
        
        Kertas_Kerja__c kk_dws = new Kertas_Kerja__c();
        kk_dws.Month__c = 'January';
        kk_dws.Year__c = '2021';
        kk_dws.Status__c = 'Draft';
        kk_dws.Type__c = 'Direct Sales';
        //kk_dws.Media_Seller__c = accList[1].Id;
        insert kk_dws;
        
        kk_dws.Status__c = 'Attach';
        update kk_dws;
                
        Kertas_Kerja__c kk_rec = [SELECT Id, Kertas_Kerja_Name__c FROM Kertas_Kerja__c WHERE Id =: kk_dws.Id];
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'PrivyID';
        cv.PathOnClient = kk_rec.Kertas_Kerja_Name__c + '.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        system.debug('isi condocid'+ conDocId);
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = kk_dws.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        insert cdl;
        
		kk_dws.Status__c = 'Review';
        update kk_dws;    
        /*
        Kertas_Kerja__c kk_mus = new Kertas_Kerja__c();
        kk_mus.Month__c = 'January';
        kk_mus.Year__c = '2021';
        kk_mus.Status__c = 'Draft';
        kk_mus.Type__c = 'Media Seller';
        kk_mus.Media_Seller__c = accList[2].Id;
        insert kk_mus;
        
        Kertas_Kerja__c kk_ds = new Kertas_Kerja__c();
        kk_ds.Month__c = 'January';
        kk_ds.Year__c = '2021';
        kk_ds.Status__c = 'Draft';
        kk_ds.Type__c = 'Direct Sales';
        insert kk_ds;
        
		Kertas_Kerja__c kk_ds_clone = kk_ds.clone(false,false,false,false);  

        try
        	{insert kk_ds_clone;}
        catch(Exception ex)
        	{Boolean expectedExceptionThrown =  ex.getMessage().contains('Duplicate Kertas Kerja record:') ? true : false;}
*/    
}
}