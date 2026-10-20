public class GITA_ProductDiscount_Controller {
	
    public List<OpportunityLineItem> oli_list {get; set;}
    
    public GITA_ProductDiscount_Controller (){
        
        system.debug('*** GITA_ProductListAndDiscount_Controller CONSTRUCTOR !!!');
        
        String targetObjectId = '';
        
        String recId = apexpages.currentpage().getparameters().get('id'); system.debug('*** recId = ' + recId);
        
        List<ProcessInstanceWorkitem> piwRec_list = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE Id =: recId];
        system.debug('*** piwRec_list = ' + piwRec_list.size() + ' | ' +  piwRec_list);
        
        if(piwRec_list.size() > 0){
            targetObjectId = piwRec_list[0].ProcessInstance.TargetObjectId;
        }else{
            List<ProcessInstanceStep> pisRec_list = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE Id =: recId ];
        	system.debug('*** pisRec_list = ' + pisRec_list.size() + ' | ' +  pisRec_list);
            targetObjectId = pisRec_list[0].ProcessInstance.TargetObjectId;
        }
        
        oli_list = [SELECT Id, Product2Id, Product2.Name, Quantity, Discount__c, Max_Discount__c, Discount_Checking__c 
                    FROM OpportunityLineItem 
                    WHERE OpportunityId =: targetObjectId];
        system.debug('*** oli_list.size() = ' + oli_list.size());
    }
}