trigger Trigger_CO_Before_Insert on Campaign_Order__c (before insert) {

    if(trigger.isBefore){
        
        if(trigger.isInsert){
            system.debug('isBefore insert');
            List <Order_Non_Bulk__c> myOrder = new List <Order_Non_Bulk__c>();
            List<ID> ONBIds = New List<ID>();
            List<String> MySender = New List<String>();
            for(Campaign_Order__c CO : trigger.New){
                
                List<Campaign_Order__c> existCO = [SELECT Id, Name FROM Campaign_Order__c WHERE Order_Non_Bulk__c=: CO.Order_Non_Bulk__c];

                ONBIds.add(CO.Order_Non_Bulk__c);
                MySender.add(CO.Masking_Sender_Brand__c);
                if (label.Trigger_CO_Before_Insert_On == 'YES') {
                    if(existCO.size() > 0){
                        CO.addError('CO hanya boleh 1 untuk 1 Order Non Bulk.');
                    }
                }
            }
            List<Order_Non_Bulk__c> existOrder = [Select Id,Sender__c from Order_Non_Bulk__c where id in :ONBIds];
            
            for(integer i = 0 ; i < existOrder.size(); i++){
            existOrder[i].Sender__c= MySender[0];
          }
        
          update existOrder;
        }
    }
}