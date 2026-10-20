trigger Trigger_Top_Up_Voucher_Before_Insert on Top_Up_Voucher__c(Before insert) {

if (label.Trigger_Top_Up_Voucher_Before_Insert_On== 'YES') {
    if(trigger.isBefore)
     {
    
        if(trigger.isInsert)
        {
         
            for(Top_Up_Voucher__c newTU:trigger.new) {                
                 try {
                       //List<Top_Up_Voucher__c> ListTopVoucher = [SELECT id FROM Top_Up_Voucher__c WHERE Date_Time_Reedem__c=THIS_YEAR and Account__c=:newTU.Account__c order by createddate DESC LIMIT 1];
                       //List<Top_Up_Invoice__c> ListTopInvoice = [SELECT id FROM Top_Up_Invoice__c WHERE Paid_Date__c=THIS_YEAR and User_Id__c=:newTU.Account__c order by createddate DESC LIMIT 1];
                       
                       List<Top_Up_Voucher__c> ListTopVoucher = [SELECT id FROM Top_Up_Voucher__c WHERE CALENDAR_YEAR(Date_Time_Reedem__c)=:newTU.Date_Time_Reedem__c.year() and Account__c=:newTU.Account__c order by createddate DESC LIMIT 1];
                       List<Top_Up_Invoice__c> ListTopInvoice = [SELECT id FROM Top_Up_Invoice__c WHERE CALENDAR_YEAR(Paid_Date__c)=:newTU.Date_Time_Reedem__c.year() and User_Id__c=:newTU.Account__c order by createddate DESC LIMIT 1];
                       
                       
                       if(newTU.Payment_Method__c=='Credit Card'){
                           newTU.Fee_Finnet__c=Integer.valueof(Label.Credit_Card_Fee);
                       }
                       else if(newTU.Payment_Method__c=='LinkAja'){
                           newTU.Fee_Finnet__c=Integer.valueof(Label.LinkAja_Fee);
                       }
                       else{
                           newTU.Fee_Finnet__c=Integer.valueof(Label.Others_Fee);
                       }
                       
                       if(ListTopVoucher.size()+ListTopInvoice.size()==0)
                       {
                           newTU.Status_Top_Up__c='First Top Up';
                       }
                        else
                       {
                           newTU.Status_Top_Up__c='Re-Top Up';
                       }
                   }
                   catch (Exception e) {
                       string errMessage = 'Error on AppUtils Trigger_Top_Up_Vouchert_Before_Insert method.::' + e.getmessage() + '::' + e.getLineNumber() ;
                       system.debug('==================== error message : ' + errMessage);
                       AppUtils.putError(errMessage );
                   }
            }
        }
    }
  }
}