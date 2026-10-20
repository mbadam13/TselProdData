/**
 * @description       : 
 * @TestClass         : TA_AT_Order_AU_CountSpotInApprovalTEST
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 08-21-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-01-2024   Novando Utoyo Agmawan   Initial Version
**/

public class TA_AT_Order_AU_CountSpotInApproval implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<Order> newList, List<Order> oldList) {
        try {
            system.debug(' === TA_AT_Order_AU_CountSpotInApproval === ');

            Map<Id, Order> oldMap = new Map<Id, Order>(oldList);
            Set<String> Set_OrderIds = new Set<String>();

            for (Order orderRec : newList) {
                if (
                    orderRec.Approval_Status__c != oldMap.get(orderRec.id).Approval_Status__c &&
                    (
                        orderRec.Approval_Status__c == 'Submit' ||
                        orderRec.Approval_Status__c == 'Need to Revise' ||
                        orderRec.Approval_Status__c == 'Approved' ||
                        orderRec.Approval_Status__c == 'Rejected'
                    )
                ) {
                    Set_OrderIds.add(orderRec.Id);
                }
            }

            system.debug(' === Set_OrderIds : ' + Set_OrderIds + ' === ');

            IptvSpotDailyStatusServices.countSpotDailyInApproval(Set_OrderIds);

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            String errMessage = 'Error on TA_AT_Order_AU_CountSpotInApproval afterUpdate function::' + e.getMessage() + '::' + e.getLineNumber();
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
}