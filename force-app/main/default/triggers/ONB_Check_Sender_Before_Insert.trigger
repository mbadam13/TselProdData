trigger ONB_Check_Sender_Before_Insert on Order_Non_Bulk__c (Before insert, Before Update) {
if (label.Trigger_ONB_Check_Sender_Before_Insert_On== 'YES') {
     if(Trigger.isBefore){
        
         if(Trigger.isUpdate)
         {
             for(Order_Non_Bulk__c newONB:trigger.new) {
                if(newONB.Status__c=='Validate')
                {
                    List<ContentVersion> attachments = AppUtils.getFilesOnBase64(newONB.id);
                    if (attachments.size()==0){
                         newONB.addError('Validate Need Upload File');
                    }
                }
             }
         }
     }
  }
}