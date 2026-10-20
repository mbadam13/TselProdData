trigger BlackListTrigger on Blacklist__c (Before insert) {
if (label.Trigger_BlackListTrigger_On== 'YES') {     
    if(Trigger.isBefore){
        // Call Methods for Before Triggers.      
        // Call After Insert methods.
        if(Trigger.isInsert){
            for(Blacklist__c newBL :system.trigger.new)
            {
                
                List<Blacklist__c> listblacklist =[SELECT id,Name FROM Blacklist__c where Name=:newBL.Name.toLowercase()];
                if(listblacklist.size()>0)
                {
                   newBL.addError('Invalid, Please Change');
                }
                else
                {
                     newBL.Name=newBL.Name.toLowercase();
                }
            }
        }  
    }
  }
}