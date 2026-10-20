trigger ContentDocLinkTrigger on ContentDocumentLink (before insert, before update, before delete ) {
if (label.Trigger_ContentDocLinkTrigger_On== 'YES') {    
    Schema.DescribeSObjectResult inv = SID_Tools__c.sObjectType.getDescribe();
    String invKeyPrefix = inv.getKeyPrefix();
    
    if(trigger.isInsert){
        for(ContentDocumentLink a :trigger.new){
            if(invKeyPrefix == String.valueOf(a.LinkedEntityId).left(3) &&
               ([select status__c from SID_Tools__c where id = :a.LinkedEntityId].status__c =='Completed' || [select status__c from SID_Tools__c where id = :a.LinkedEntityId].status__c =='Verify' || [select status__c from SID_Tools__c where id = :a.LinkedEntityId].status__c =='Negotiation')){
                   a.adderror('This attachment could not be added because this exception record is marked as Completed.');
               }
        }
    }
    
    
    if(trigger.isUpdate){
        for(ContentDocumentLink a :trigger.new){
            if(invKeyPrefix == String.valueOf(a.LinkedEntityId).left(3) &&
               [select status__c from SID_Tools__c where id = :a.LinkedEntityId].status__c =='Completed'){
                   a.adderror('This attachment could not be added because this exception record is marked as Completed.');
               }
        }
    }
    
    if(trigger.isDelete){
        for(ContentDocumentLink a :trigger.old){
            if(invKeyPrefix == String.valueOf(a.LinkedEntityId).left(3) &&
               [select status__c from SID_Tools__c where id = :a.LinkedEntityId].status__c =='Completed'){
                   a.adderror('This attachment could not be added because this exception record is marked as Completed.');
               }
        }
    }

}
}