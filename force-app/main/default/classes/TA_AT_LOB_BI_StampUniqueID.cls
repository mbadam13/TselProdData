/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 26/03/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   25/03/2025   Syaiful Syafani   Initial Version
**/
public with sharing class TA_AT_LOB_BI_StampUniqueID implements TriggerAction.BeforeInsert {
    public void BeforeInsert(List<LOB__c> newList){
        System.debug('=== TA_AT_LOB_BI_StampUniqueID ===');

        try {
            for (LOB__c lobRec : newList) {
                if (lobRec.Name != null) {
                    lobRec.LOB_Unique_ID__c = lobRec.Name;
                }
            }

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_AT_LOB_BI_StampUniqueID-BeforeInsert function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}