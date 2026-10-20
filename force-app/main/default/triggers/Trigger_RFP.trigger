trigger Trigger_RFP on Request_for_proposal__c (before insert, before update) {
     if(trigger.isbefore)
     {
       if(trigger.isinsert)
        {
  
           for (Request_for_proposal__c myrfp : Trigger.new) {
               integer deadline_date = integer.valueof(label.RFP_Deadline_Date);
               myrfp.default_deadline__c = AppUtils.nextDate(myrfp.date__c, deadline_date, false, false, false);
               myrfp.deadline__c = AppUtils.nextDate(myrfp.date__c, deadline_date, false, false, false);
           }
        }
     }
         if(trigger.isbefore)
         {
           if(trigger.isupdate)
            {
                 for (Request_for_proposal__c myrfp : Trigger.new) {
                     Request_for_proposal__c myrfpOld= Trigger.oldMap.get(myrfp.id);
                     if(myrfp.Document_Version__c=='Submit' && myrfpOld.Document_Version__c!='Submit')
                         {
                           integer deadline_date = integer.valueof(label.RFP_Deadline_Date);
                           myrfp.default_deadline__c = AppUtils.nextDate(date.today(), deadline_date, false, false, false);
                           myrfp.deadline__c = AppUtils.nextDate(date.today(), deadline_date, false, false, false);
                         }
                 }
                 
            }
         }
}