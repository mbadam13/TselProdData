public class AttachFile_KertasKerja {
	
    @future(callout=true)
    public static void doAttachDoc(Id kk_id){
        
        system.debug('*** Masuk doAttachDoc !!!');
        
        try{
            
            Kertas_Kerja__c kkRec = [SELECT Id, Name, Kertas_Kerja_Name__c, Type__c, docType__c FROM Kertas_Kerja__c WHERE Id =: kk_id /*AND Status__c = 'Review'*/];
            system.debug('*** kkRec = ' + kkRec);
            
            // -------------------------------------------------- Download & Attach KK Pdf File -------------------------------------------------- //
            
            PageReference page_pdf =  null;
			if(kkRec.Type__c == 'Direct Sales'){
            	page_pdf =  Page.KKSummary_Page;
            }else if(kkRec.Type__c == 'Media Seller'){
            	page_pdf =  Page.KKDetail_Page;
            }
            page_pdf.getParameters().put('Id',kkRec.Id);
            page_pdf.setRedirect(true);
            
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.PathOnClient = kkRec.Kertas_Kerja_Name__c + '.pdf';
            cv.Title = kkRec.Kertas_Kerja_Name__c;
            if(!Test.isRunningTest())
                {cv.VersionData = page_pdf.getContent();}
            else
                {cv.VersionData = Blob.valueOf('Content in file for test class.');}
            insert cv;
            
            // Get the Content Document Id from ContentVersion Object
            Id cd = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            // Create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = kkRec.Id;
            cdl.ContentDocumentId = cd;
            cdl.shareType = 'V';
            insert cdl;
            
        }
        catch(exception e){
            
            String errMessage = 'Error on AttachFile_KertasKerja function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
}