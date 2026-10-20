public with sharing class WrapperSIDBatchController {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
    public List<SIDWrapper> listSIDWrapper {get; set;}
    public List<SID_Tools__c> selectedSIDs{get;set;}
    public String searchKeyname {get;set;}
    public String searchKeytype {get;set;}
    Decimal lstid;
    public WrapperSIDBatchController ()
    {
            listSIDWrapper = new List<SIDWrapper>();
            searchRecord();
    }
   
    public void searchRecord()
    {
        listSIDWrapper.clear();
        String keyname= '%'+searchKeyname+'%';
        String keytpe= '%'+searchKeytype+'%';
        
            system.debug('isi dari keyname'+keyname);
            system.debug('isi dari keytpe'+keytpe);
            
            //List<SID_Tools__c> isilistsidTEMP =[select Id, Name, Batch__c, CP_Name__c,SID__c,Media_Seller__r.name, documentStatus__c,  Type_Sender__c from SID_Tools__c];
            //system.debug('isi dari isilistsidTEMP : ' + isilistsidTEMP);
            //system.debug('isi dari Batch__c : ' + isilistsidTEMP[0].Batch__c);
        	
        	Integer limit_querysid = integer.valueof(Label.Limit_Query_SID_Batch);
            List<SID_Tools__c> isilistsid =[select Id, Name,Batch__c,CP_Name__c,SID__c,Media_Seller__r.name from SID_Tools__c where Batch__c = null and documentStatus__c ='Completed' and CP_Name__c like:keyname and Type_Sender__c like:keytpe limit: limit_querysid];
            //List<SID_Tools__c> isilistsid =[select Id, Name,Batch__c,CP_Name__c,SID__c,Media_Seller__r.name from SID_Tools__c where Batch__c = null and documentStatus__c ='Completed' and CP_Name__c like '%:searchkeyname%'  and Type_Sender__c like '%:searchkeytpee%' limit 50];
            
            system.debug('isi dari isilistsid'+isilistsid);
            system.debug('size isilistsidnya :'+isilistsid.size());
            //for(SID_Tools__c s: [select Id, Name,Batch__c,CP_Name__c,SID__c,Media_Seller__r.name from SID_Tools__c where Batch__c = null and documentStatus__c ='Completed' and CP_Name__c like:keyname and Type_Sender__c like:keytpe limit 50])
            for(SID_Tools__c s: isilistsid )
            {
                listSIDWrapper.add(new SIDWrapper(s));
            }
    }
    
    public void clear(){
        listSIDWrapper.clear();
    }

    public void processSelected()
    {
        selectedSIDs = new List<SID_Tools__c>();
        selectedSIDs.clear();
        for(SIDWrapper wrapSIDObj : listSIDWrapper)
        {
            if(!Test.isRunningTest()){
                if(wrapSIDObj.selected == true)
                {
                    selectedSIDs.add(wrapSIDObj.sid);
                }
            }     
            else
            {
                 selectedSIDs.add(wrapSIDObj.sid);
            }
        }
    }

    public void ActivateData()
    {
       try
       {
            list<SID_Tools__c> lastSID = new list<SID_Tools__c>();
            lastSID= [Select ID, Last_Number__c, Batch__c from SID_Tools__c where Batch__c!=null order by Last_Number__c DESC limit 1];
            if(lastSID.size()>0){
                
                lstid = lastSID[0].Last_Number__c;
            }
            else{
                lstid = 0;
            }
            Decimal newNumber=lstid+1;
            
            for(SID_Tools__c sid: selectedSIDs )
            {
                sid.Batch__c ='Batch'+newNumber;
                sid.Last_Number__c=newNumber;
                sid.Batch_Date__c = date.today();
            }
            update selectedSIDs;
            searchRecord();
       }
       catch(exception e) 
       {
           string errMessage = 'Error on WrapperSIDBatchController ActivateData function::' + e.getmessage() + '::' + e.getLineNumber() ;
           system.debug('==================== error message : ' + errMessage);
           AppUtils.putError(errMessage );
           
       }
    }

    public void DeActivateData()
    {
        for(SID_Tools__c sid : selectedSIDs )
        {
            sid.Batch__c =null;
            sid.Last_Number__c=null;
        }
        update selectedSIDs ;
        searchRecord();
    }
   


    // This is our wrapper/container class.
    public class SIDWrapper
    {
        public SID_Tools__c sid {get; set;}
        public Boolean selected {get; set;}
        public SIDWrapper(SID_Tools__c s)
        {
            sid = s;
            selected = false;
        }
    }
    
     public PageReference back()
    {
        PageReference cancel = con.cancel();
        return cancel;
    }
    
     public pagereference callpageredirect(){
        PageReference demoPage = new PageReference(label.URL_SID);
        //pageReference demoPage = new pageReference('/006');
        return demoPage;
    }

}