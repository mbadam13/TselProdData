trigger Trigger_Brand_Before_Insert on Brand__c (before insert,after update) {
if (label.Trigger_Brand_Before_Insert_On== 'YES') {
   if(trigger.isbefore)
     {
        if(trigger.isinsert)
        {
        String Accountid;
            for(Brand__c newBrand :system.trigger.new)
                {
                     list<contact>allcontact=[SELECT id,name,AccountId from Contact where id=:newBrand.PIC_Advertiser__c];
                     if(allcontact.size()>0){
                         Accountid=allcontact[0].AccountId;
                         for(Contact thisItem:allcontact)
                            {
                                newBrand.Advertiser__c=Accountid;
                            }
                     }
                     
                }
        } 
     }
  }
}