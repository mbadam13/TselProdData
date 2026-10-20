trigger Trigger_Lead_Before_Update on Lead (before update) { 
/*
if(label.Trigger_Lead_Before_Update_On== 'YES') {
     if(trigger.isbefore)
     {
       if(trigger.isupdate)
        {
         for(Lead con:trigger.new) {  
              if(Trigger.oldMap.get(con.Id).Ownerid != con.ownerid){
                  con.stamp_owner__c=Trigger.oldMap.get(con.Id).Ownerid;
                  //system.debug('owner lama'+Trigger.oldMap.get(con.Id).Ownerid);
              }
                
          }
        }
     }
  }
 */
}