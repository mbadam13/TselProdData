public class Tadex_ShareDocs {
    
    @future(callout=true)
    public static void share_ba_traffic(Id ba_id){
        
        Berita_Acara__c baRec = [SELECT Id, Name, Account_Name__c, Month__c, Year__c, Chatter_Group_Id__c FROM Berita_Acara__c WHERE Id =: ba_id];
        system.debug('*** baRec = ' + baRec);
        
        String pubName = baRec.Account_Name__c.remove('.');
        pubName = pubName.replace(' ','_');
        system.debug('*** pubName = ' + pubName);
        
        String period_ba = baRec.Month__c + baRec.Year__c;
        
        String fileName_end = pubName + '-' + period_ba;
        
        List<String> fileName_list = new List<String>{'BA-'+fileName_end,'Traffic-'+fileName_end};
        system.debug('*** fileName_list = ' + fileName_list);
        
        List<ContentVersion> cvChatterList = new List<ContentVersion>();
        for(String fileName : fileName_list){
            
            PageReference page_pdf =  new PageReference('/'+baRec.Id);
            if(fileName.contains('BA-')){
                page_pdf =  Page.BeritaAcara_pdf;
            }else if (fileName.contains('Traffic-')){
                page_pdf =  Page.TrafficPage;
            }
            page_pdf.getParameters().put('Id',baRec.Id);
            page_pdf.setRedirect(true);
            
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.PathOnClient = fileName + '.pdf';
            cv.Title = fileName ;
            if(!Test.isRunningTest())
                {cv.VersionData = page_pdf.getContent();}
            else
                {cv.VersionData = Blob.valueOf('Content in file for test class.');}
            insert cv;
                
            // Get the Content Document Id from ContentVersion Object
            Id cd = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            // Create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = baRec.Id;
            cdl.ContentDocumentId = cd;
            cdl.shareType = 'V';
            insert cdl;
            
            ContentVersion cv_chatter = new ContentVersion();
            cv_chatter.Title = fileName;
            cv_chatter.PathOnClient = fileName + '.pdf';
            if(!Test.isRunningTest())
                {cv_chatter.VersionData = page_pdf.getContent();}
            else
                {cv_chatter.VersionData = Blob.valueOf('Content in file for test class..');}
            cvChatterList.add(cv_chatter);
        }
        
        insert cvChatterList;
        
        FeedItem fi = new FeedItem();
        fi.Body = 'Berita Acara & Traffic for ' + pubName + ' in period ' + baRec.Month__c + ' ' + baRec.Year__c + ' . Please find the attachments below.';
        fi.ParentId = baRec.Chatter_Group_Id__c; 
        insert fi;
        
        List<FeedAttachment> faList = new List<FeedAttachment>();
        for(ContentVersion cvChatter_rec : cvChatterList){
            FeedAttachment fa = new FeedAttachment();
            fa.FeedEntityId = fi.Id;
            fa.RecordId = cvChatter_rec.Id;
            fa.Type = 'CONTENT';
            faList.add(fa);
        }
        insert faList;
        
    }

}