trigger Trigger_OPNB_Before_Insert on Order_Product_Non_Bulk__c (before insert) {
    if(trigger.isBefore){
        
        if(trigger.isInsert){
            
            for(Order_Product_Non_Bulk__c OPNB : trigger.New){
                
                List<Order_Product_Non_Bulk__c> existOPNB = [SELECT Id, Name FROM Order_Product_Non_Bulk__c WHERE Order_Non_Bulk_Number__c=: OPNB.Order_Non_Bulk_Number__c];
                
                if(existOPNB.size() > 0){
                    OPNB.addError('Product hanya boleh 1 untuk 1 Order Non Bulk.');
                }
            }
        }
    }

}