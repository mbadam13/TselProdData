public class MultiAddCampaignOrder {
ApexPages.StandardSetController setCon; 
ApexPages.StandardController con;

public String OrderProductID {get;set;}
        //will hold the Campaign_Order__c records to be saved
        public List<Campaign_Order__c>lstCO = new List<Campaign_Order__c>();
        //list of the inner class
        public List<innerClass> lstInner{ get;set; }
        //will indicate the row to be deleted
        public String selectedRowIndex{get;set;}
        //no. of rows added/records in the inner class list
        public Integer count = 1;    //{get;set;}

        ////save the records by adding the elements in the inner class list to lstCO,return to the same page
        public PageReference Save(){
            //PageReference pr = new PageReference('/apex/MultiAdd');   
            PageReference pr = con.cancel();
            for(Integer j = 0;j<lstInner.size();j++)    {  
                
                if (lstInner[j].tmpStartCampaignDateTime <>'') 
                    lstInner[j].CO.Start_Campaign__c = Datetime.valueOf(lstInner[j].tmpStartCampaignDateTime+':00');
                if (lstInner[j].tmpEndCampaignDateTime<>'') 
                    lstInner[j].CO.End_Campaign__c = Datetime.valueOf(lstInner[j].tmpEndCampaignDateTime+':00');
                
                lstCO.add(lstInner[j].CO); 
            } 
            insert lstCO;    
            pr.setRedirect(True);   
            return pr;
        }

        //add one more row
        public void Add(){
            count = count+1;
            addMore();
        }

        /*Begin addMore*/

        public void addMore(){
            //call to the iner class constructor
            innerClass objInnerClass = new innerClass(count);
            OrderProductID = con.getRecord().id;
            system.debug('isi get record'+con.getRecord());
            objInnerClass.CO.Order_Product__c=OrderProductID;
            //objInnerClass.CO.Order__c=OrderID;
            //add the record to the inner class list
            lstInner.add(objInnerClass);
            system.debug('lstInner—->'+lstInner);
        }/* end addMore*/

        /* begin delete */

        public void Del(){
            system.debug('selected row index—->'+selectedRowIndex);    
            lstInner.remove(Integer.valueOf(selectedRowIndex)-1);    
            count = count-1;

        }/*End del*/
        
        public void cloneEntry(){
    
             system.debug('selected row index—->'+selectedRowIndex);
            
            count = count+1;
            innerClass tobeClone = new innerClass(count);
            system.debug('=== lstInner1 :' + lstInner);
            innerClass tmpobjInnerClass = lstInner[Integer.valueOf(selectedRowIndex)-1];
            system.debug('=== lstInner2 :' + lstInner);

            tobeClone.co.Masking_Sender_Brand__c = tmpobjInnerClass.co.Masking_Sender_Brand__c;
            tobeClone.co.Profiling_Lokasi__c = tmpobjInnerClass.co.Profiling_Lokasi__c;

            tobeClone.tmpStartCampaignDateTime = tmpobjInnerClass.tmpStartCampaignDateTime ;
            tobeClone.co.Start_Campaign__c = tmpobjInnerClass.co.Start_Campaign__c;
            
            tobeClone.tmpEndCampaignDateTime = tmpobjInnerClass.tmpEndCampaignDateTime ;
            tobeClone.co.End_Campaign__c = tmpobjInnerClass.co.End_Campaign__c;
            
            
            tobeClone.co.Impression_Click__c = tmpobjInnerClass.co.Impression_Click__c;
            tobeClone.co.SMS_Per_Day_Location__c = tmpobjInnerClass.co.SMS_Per_Day_Location__c;
            tobeClone.co.WORDING_PICTURE_VIDEO__c = tmpobjInnerClass.co.WORDING_PICTURE_VIDEO__c;
            tobeClone.co.Placement__c = tmpobjInnerClass.co.Placement__c;
                
            system.debug('=== lstInner3 :' + lstInner);
            lstInner.add(tobeClone);
            system.debug('=== lstInner4 :' + lstInner);
        }

        /*Constructor*/

       public MultiAddCampaignOrder(ApexPages.StandardController ctlr){            
           lstInner = new List<innerClass>();
           con = ctlr;

           addMore();
           selectedRowIndex = '0';

        }/*End Constructor*/

        /*Inner Class*/

        public class innerClass{
            /*recCount acts as a index for a row. This will be helpful to identify the row to be deleted */
            public String recCount{get;set;}  
            public Campaign_Order__c CO{get;set;}
            public String DateTimeField{get;set;}
            
            public string tmpStartCampaignDateTime  {get;set;} 
    		public string tmpEndCampaignDateTime  {get;set;} 
    
            
            /*Inner Class Constructor*/    
            public innerClass(Integer intCount){  
                recCount = String.valueOf(intCount);  
                tmpStartCampaignDateTime='';
                tmpEndCampaignDateTime='';
                
                /*create a new Campaign_Order__c*/        
                CO = new Campaign_Order__c();
            }/*End Inner class Constructor*/

        }/*End inner Class*/

}/*End Class*/