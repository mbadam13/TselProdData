public with sharing class GenerateSID_PDFController {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
    
    Date myDate = system.today();
    public SID_Tools__c pageSID;
    public Boolean initialised{get; set;}

    public String senderID{get;set;}

    public List<SID_Tools__c> senderitemRec{get;set;}
    public List<SID_Tools__c> senderRec{get;set;}
    Public List<String> NewStrings{get;set;}

    public GenerateSID_PDFController (ApexPages.StandardController controller) {
       //try
       //{
            con = controller;
            senderID= con.getRecord().id;
            initialised=false;
                                  
            senderitemRec= [select id, Company__c,Media_Seller__r.Name,Brand__r.Name,Brand__r.Line_Of_Business__c,Kategori_Industri__r.name,Format_Pesan__c,Type_SMS__c,Sender_ID__c,Kategori_Pesan__c from SID_Tools__c where id=:senderID];
            senderRec= [select id,Media_Seller__r.Name,Company__c,No_Kontrak__c,No_Surat__c,Manager_Media_Seller__c,Manager_Media_Seller_Title__c,Owner.Name, Owner.Title from SID_Tools__c where id=:senderID];
            
            //String[] ch = new String[senderitemRec[0].Sender_ID__c.length()]; 
  
            String[] stringCharacters = senderitemRec[0].Sender_ID__c.split('');
            System.debug(stringCharacters);
            NewStrings=stringCharacters;
            String myGeneratedFileName = senderitemRec[0].Company__c+'_'+senderitemRec[0].Media_Seller__r.Name+'_'+'SID PrivyID.pdf';
            Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+myGeneratedFilename); 
            back();
       /*}
       catch(exception e) 
       {
           string errMessage = 'Error on GenerateSID_PDFController function::' + e.getmessage() + '::' + e.getLineNumber() ;
           system.debug('==================== error message : ' + errMessage);
           AppUtils.putError(errMessage );
           
       }*/
                              
    }
    
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
      public PageReference back()
    {
        PageReference cancel = con.cancel();
        return cancel;
    }
        
}