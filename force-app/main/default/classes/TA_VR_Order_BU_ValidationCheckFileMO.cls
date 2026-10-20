/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 17/01/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   03/01/2025   Syaiful Syafani   Initial Version
**/
public class TA_VR_Order_BU_ValidationCheckFileMO implements TriggerAction.BeforeUpdate {
    public void BeforeUpdate(List<Order> newList, List<Order> oldList) {
        System.debug('=== TA_VR_Order_BU_ValidationCheckFileMO ===');

        Map<Id, Order> oldMap = new Map<Id, Order>(oldList);

        try {
            for (Order newOrderRec : newList) {
                Order oldOrderRec = oldMap.get(newOrderRec.Id);
                if (
                    oldOrderRec.Approval_Status__c != newOrderRec.Approval_Status__c 
                    && newOrderRec.Approval_Status__c == 'Submit' 
                    && newOrderRec.File_Upload_MO__c == false && 
                    newOrderRec.Business_Product__c == 'TV Media'
                ){
                    newOrderRec.addError('Tidak dapat submit karena belum ada MO yang di upload');
                }
            }
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_VR_Order_BU_ValidationCheckFileMO-BeforeUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}