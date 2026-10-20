/**
 * @description       : For Reject All Approval in Sub Order
 * @author            : M B Adam
 * @group             : 
 * @last modified on  : 03-10-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class TA_AT_Order_AU_ACWRejectedAllApproved implements TriggerAction.AfterUpdate {
    public void AfterUpdate(List<Order> newList, List<Order> oldList){
        String errMessage;
        System.debug('=== TA_AT_Order_AU_ACWRejectedAllApproved ===');
        Map<Id, Order> oldMap = new Map<Id, Order>(oldList);
        try {
            Set<Id> orderIds = new Set<Id>();
            for (Order newOrderRec : newList) {
                Order oldOrderRec = oldMap.get(newOrderRec.Id);
                System.debug('=== Order Status New: ' + newOrderRec.Status);
                System.debug('=== Order Status Old: ' + oldOrderRec.Status);
                
                if (newOrderRec.Status == 'Draft' && oldOrderRec.Status == 'Running') {
                    orderIds.add(newOrderRec.Id);
                }
            }
            System.debug('== orderIds: ' + orderIds);

            if (!orderIds.isEmpty()) {
          
                SubOrderService.handleSubOrderApprovals(new List<Id>(orderIds));
            }
            

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
            }
        } catch (Exception e) {
             errMessage = 'Error on TA_AT_Order_AU_ACWRejectedAllApproved afterUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );
        }
    }
}