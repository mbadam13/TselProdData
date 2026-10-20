public with sharing class MultiEditCO{
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
 
    public String OrderID {get;set;}
    public List<WRAP_CO> wrapCOs { get; set; }
 
    public MultiEditCO(ApexPages.StandardController controller) {
        con = controller;

        OrderID= con.getRecord().id;
        LoadData(OrderID);        
    }
    

    public PageReference Save (){
        system.debug('=== masukSave');  
        List <Campaign_Order__c> tmpCOToUpdateList = new List <Campaign_Order__c>();
        for (WRAP_CO wrapCO : wrapCOs) { 
            
            system.debug('=== wrapCO : ' + wrapCO);            
            if (wrapCO.Checked) {
                
                system.debug('== wrapCO.Starttime :' +wrapCO.Starttime );
                if (wrapCO.Starttime <>'') {
                    try {
                        Datetime tmpStart = Datetime.valueOf(wrapCO.Starttime+':00');
                        system.debug('== tmpStart :' +tmpStart );
                        if (tmpStart <> null) wrapCO.CO.Start_Campaign__c=Datetime.valueOf(tmpStart);
                    } catch (Exception e) { system.debug('== error : ' + e.getStacktraceString() ); }
                } else  {  wrapCO.CO.Start_Campaign__c= null;}
                
                system.debug('== wrapCO.Endttime :' +wrapCO.Endttime );
                if (wrapCO.Endttime <>'') {
                    try {
                        Datetime tmpEnd = Datetime.valueOf(wrapCO.Endttime+':00');
                        system.debug('== tmpEnd :' +tmpEnd );
                        if (tmpEnd <> null) wrapCO.CO.End_Campaign__c=Datetime.valueOf(tmpEnd);
                    } catch (Exception e) { system.debug('== error : ' + e.getStacktraceString() );  }
                } else  {  wrapCO.CO.End_Campaign__c= null;}
                
                tmpCOToUpdateList.add(wrapCO.CO);
                
            }
        }
        system.debug('=== tmpCOToUpdateList : ' + tmpCOToUpdateList);
        if (tmpCOToUpdateList.size()>0) {
            update tmpCOToUpdateList;
        }
            
            
        //return null;
        return con.cancel();
    }
    
    public PageReference Deleterow(){
        system.debug('=== masukSave');  
        List <Campaign_Order__c> tmpCOToUpdateList = new List <Campaign_Order__c>();
        for (WRAP_CO wrapCO : wrapCOs) { 
            
            system.debug('=== wrapCO : ' + wrapCO);            
            if (wrapCO.Checked) {
                
                system.debug('== wrapCO.Starttime :' +wrapCO.Starttime );
                if (wrapCO.Starttime <>'') {
                    try {
                        Datetime tmpStart = Datetime.valueOf(wrapCO.Starttime+':00');
                        system.debug('== tmpStart :' +tmpStart );
                        if (tmpStart <> null) wrapCO.CO.Start_Campaign__c=Datetime.valueOf(tmpStart);
                    } catch (Exception e) { system.debug('== error : ' + e.getStacktraceString() ); }
                } else  {  wrapCO.CO.Start_Campaign__c= null;}
                
                system.debug('== wrapCO.Endttime :' +wrapCO.Endttime );
                if (wrapCO.Endttime <>'') {
                    try {
                        Datetime tmpEnd = Datetime.valueOf(wrapCO.Endttime+':00');
                        system.debug('== tmpEnd :' +tmpEnd );
                        if (tmpEnd <> null) wrapCO.CO.End_Campaign__c=Datetime.valueOf(tmpEnd);
                    } catch (Exception e) { system.debug('== error : ' + e.getStacktraceString() );  }
                } else  {  wrapCO.CO.End_Campaign__c= null;}
                
                tmpCOToUpdateList.add(wrapCO.CO);
                
            }
        }
        system.debug('=== tmpCOToUpdateList : ' + tmpCOToUpdateList);
        if (tmpCOToUpdateList.size()>0) {
            delete tmpCOToUpdateList;
        }
            
            
        //return null;
        return con.cancel();
    }
    
    Public void LoadData(String OrderID) {
        //////COs = new List<multiRowCO>();


        wrapCOs  = new list<WRAP_CO>();
        for (List<Campaign_Order__c> cs : [select c.id, c.Name,c.Channel__c,c.Impression_Click__c,c.Masking_Sender_Brand__c,c.Order_Product__c,c.OwnerId,c.Placement__c,c.Profiling_Lokasi__c,c.SMS_Per_Day_Location__c,c.WORDING_PICTURE_VIDEO__c,c.Start_Campaign__c,c.End_Campaign__c
                              from Campaign_Order__c c WHERE c.Order_Id__c=:OrderID]) {
            for (Campaign_Order__c c : cs) {
                
                WRAP_CO tmpWrapCO = new WRAP_CO();
                tmpWrapCO.Checked = false;
                tmpWrapCO.CO = c ;
                tmpWrapCO.Starttime = string.valueof(c.Start_Campaign__c) ;
                tmpWrapCO.Endttime = string.valueof(c.End_Campaign__c) ;

                wrapCOs.add (tmpWrapCO);
            }
        }
    }

    public class WRAP_CO{
        public Boolean Checked { get; set; }
        public String Starttime {get;set;} 
        public String Endttime{get;set;} 
        public Campaign_Order__c CO  { get; set; }

    }
}