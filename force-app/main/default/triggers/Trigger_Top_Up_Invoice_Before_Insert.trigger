trigger Trigger_Top_Up_Invoice_Before_Insert on Top_Up_Invoice__c(Before insert, After Insert) {

if (label.Trigger_Top_Up_Invoice_Before_Insert_ON== 'YES') {
    if(trigger.isBefore)
     {
    
        if(trigger.isInsert)
        {

            for(Top_Up_Invoice__c newTI:trigger.new) {        
                 try {
                       
                       List<Top_Up_Voucher__c> ListTopVoucher = [SELECT id FROM Top_Up_Voucher__c WHERE CALENDAR_YEAR(Date_Time_Reedem__c)=:newTI.Paid_Date__c.year() and Account__c=:newTI.User_id__c order by createddate DESC LIMIT 1];
                       List<Top_Up_Invoice__c> ListTopInvoice = [SELECT id FROM Top_Up_Invoice__c WHERE CALENDAR_YEAR(Paid_Date__c)=:newTI.Paid_Date__c.year() and User_Id__c=:newTI.User_id__c order by createddate DESC LIMIT 1];
                       

                       if(newTI.Payment_Method__c=='Credit Card'){
                           newTI.Fee_Finnet__c=Integer.valueof(Label.Credit_Card_Fee);
                       }
                       else if(newTI.Payment_Method__c=='LinkAja'){
                           newTI.Fee_Finnet__c=Integer.valueof(Label.LinkAja_Fee);
                       }
                        else if(newTI.Payment_Method__c=='Pulsa'){
                            newTI.Fee_Finnet__c=0;
                       }
                       else{
                           newTI.Fee_Finnet__c=Integer.valueof(Label.Others_Fee);
                       }
                       
                       if(ListTopInvoice.size()+ListTopVoucher.size()==0)
                       {
                           newTI.Status_Top_Up__c='First Top Up';
                       }
                        else
                       {
                           newTI.Status_Top_Up__c='Re-Top Up';
                       }
                   }
                   catch (Exception e) {
                       string errMessage = 'Error on AppUtils Trigger_Top_Up_invoice_Before_Insert method.::' + e.getmessage() + '::' + e.getLineNumber() ;
                       system.debug('==================== error message : ' + errMessage);
                       AppUtils.putError(errMessage );
                   }
            }
        }
        
    }
     if(trigger.isAfter)
     {
    
        if(trigger.isInsert)
        {
            decimal Month;
            decimal Year;
            String EID;
            double Amount_id;
           List<Monthly_Sales_Target__c> MSTlist = new List<Monthly_Sales_Target__c> ();
           Set<String> tinvSets = new Set <String>();
           Set<String> ownerset = new Set <String>();
           Set<Integer> monthSets = new Set <Integer>();
           Set<Integer> yearSets = new Set <Integer>();
           String OwnerID;
           double Amount_id_top;
           double Amount_id_re;
           for(Top_Up_Invoice__c newTI:trigger.new) 
           { 
               Date myDate = date.newinstance(newTI.Paid_Date__c.year(), newTI.Paid_Date__c.month(), newTI.Paid_Date__c.day());
               OwnerID=Label.Owner_SME;
               List<Campaign_MyAds__c> ListCampAds = [SELECT id FROM Campaign_MyAds__c WHERE Start_Date__c >=:myDate AND End_Date__c <=:myDate order by createddate DESC];
                 System.debug('isi ListCampAds'+ListCampAds);
               if(ListCampAds.size()==0){
                   //AggregateResult[] ListTopInvoiceretop = [SELECT count(amount__c)sot,User_Id__c FROM Top_Up_Invoice__c WHERE ID_Transaksi__c =:newTI.ID_Transaksi__c and Status_Top_Up__c='First Top Up' group by User_Id__c];
                    //system.debug('ListTopInvoiceretop size'+ListTopInvoiceretop.size());             
                   tinvSets.add(newTI.Id);
                   monthSets.add(newTI.Paid_Date__c.month());
                   yearSets.add(newTI.Paid_Date__c.year());
                   //ownerset.add(newTI.Owner__c);
               }
           }
           for(Integer montype : monthSets){
               AggregateResult[] ListTopInvoicetop = [SELECT count(amount__c)sot,User_Id__c,CALENDAR_MONTH(Paid_Date__c)Month,CALENDAR_YEAR(Paid_Date__c)Year FROM Top_Up_Invoice__c WHERE id in:tinvSets and Status_Top_Up__c='First Top Up' and CALENDAR_MONTH(Paid_Date__c) =:montype and CALENDAR_YEAR(Paid_Date__c) in:yearSets group by User_Id__c,CALENDAR_MONTH(Paid_Date__c),CALENDAR_YEAR(Paid_Date__c)];
               AggregateResult[] ListTopInvoiceretop = [SELECT count(amount__c)som,User_Id__c,CALENDAR_MONTH(Paid_Date__c)Month,CALENDAR_YEAR(Paid_Date__c)Year FROM Top_Up_Invoice__c WHERE id in:tinvSets and Status_Top_Up__c='Re-Top Up' and CALENDAR_MONTH(Paid_Date__c) =:montype and CALENDAR_YEAR(Paid_Date__c) in:yearSets group by User_Id__c,CALENDAR_MONTH(Paid_Date__c),CALENDAR_YEAR(Paid_Date__c)];
               Monthly_Sales_Target__c new_mst = new Monthly_Sales_Target__c();
               Month = montype;
               new_mst.Type__c='Actual User Top Up';
               new_mst.group_type__c='Actual';
               new_mst.MST_Type__c='SME';
               new_mst.sales__c=ownerid;
               new_mst.ownerid=ownerid;
               if(ListTopInvoicetop.size()>0)
               {
                   //for (AggregateResult art : ListTopInvoicetop)  {
                    
                    Year = (Integer) ListTopInvoicetop[0].get('Year');

                    new_mst.Status_Top_Up__c='First Top Up';
                    new_mst.Date__c= Date.valueOf(Year+'-'+Month+'-'+'1');
                    
                    EId ='Organic-TopUp'+'-'+Month+'-'+Year;
                    new_mst.Unique_ID__c=EID;
                    new_mst.Number_of__c=ListTopInvoicetop.size();
                    
                    MSTlist.add(new_mst);
    
                    //}
                    upsert MSTlist new_mst.Unique_ID__c;
               }
               
               if(ListTopInvoiceretop.size()>0)
               {
                   //for (AggregateResult art : ListTopInvoiceretop)  {
                    Month = montype;
                    Year =  (Integer) ListTopInvoiceretop[0].get('Year');
                    
                    new_mst.Date__c= Date.valueOf(Year+'-'+Month+'-'+'1');
                    //Amount_id = (double) art.get('som');
                    new_mst.Status_Top_Up__c='Re-Top Up';
                    EId ='Organic-ReTopUp'+'-'+Month+'-'+Year;
                    new_mst.Unique_ID__c=EID;

                    new_mst.Number_of__c=ListTopInvoiceretop.size();
                    
                    MSTlist.add(new_mst);
    
                    //}
                    upsert MSTlist Unique_ID__c;
               }
           } 
           //system.debug('isi dari ListTopInvoiceretop'+ListTopInvoiceretop); 
           //system.debug('isi dari ListTopInvoicetop '+ListTopInvoicetop);            
        }
     }
  }
}