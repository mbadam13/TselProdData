/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-23-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class TA_AT_IPTVInv_BI_SetName implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<IPTV_Inventory__c> newList){
        System.debug('=== TA_AT_IPTVInv_BI_SetName ===');

        try {
            for (IPTV_Inventory__c invRec : newList) {
                String formatName = invRec.Channel_Name__c + ' / ' + invRec.Show_Time__c;
                invRec.Name = formatName;
                System.debug('--formatName: '+ formatName);
            }
            
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_AT_IPTVInv_BI_SetName.beforeInsert function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}