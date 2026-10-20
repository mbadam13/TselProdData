trigger UpdateSIDonFile on ContentVersion (before insert) {
if (label.Trigger_UpdateSIDonFile_On== 'YES') {  
    
    Set<Id> contentDocumentIdSet = new Set<Id>();
    
    for(ContentVersion cv:trigger.new)
    {
        if(cv.ContentDocumentId != null)
        {
            contentDocumentIdSet.add(cv.ContentDocumentId);
        }
        system.Debug('isi cv'+cv);
    }
    
     system.Debug('isi IN:contentDocumentIdSet'+contentDocumentIdSet);
     system.Debug('Size contentDocumentIdSet'+contentDocumentIdSet.size());
     if(contentDocumentIdSet.size()>0)
     {
     
            ContentDocumentLink cdl = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet order by SystemModstamp DESC Limit 1];
             system.Debug('isi cdl'+cdl);
            //List<Order_Non_Bulk__c> onbList = [SELECT Id, name,Status__c FROM Order_Non_Bulk__c where Id =:cdl.LinkedEntityId];
            
            List<SID_Tools__c> sidList = [SELECT Id, name,Status__c FROM SID_Tools__c where Id =:cdl.LinkedEntityId];   
            //system.Debug('isi onbList'+onbList);
            //List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion where Id IN: Trigger.newMap.keySet()];
            system.debug('isi size'+sidList.size());
            if(sidList.size()>0){
                for(SID_Tools__c sd:sidList)
                {
                    if(sd.Status__c=='Negotiation' || sd.Status__c=='Verify' || sd.Status__c=='Completed')
                    {
                        sd.addError('Cant Update FIles');
                    }
                }
            }
   }
   }
}