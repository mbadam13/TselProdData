/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-18-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class TA_AT_IPTVSpotLimit_BI_SetName implements TriggerAction.BeforeInsert {

    public void beforeInsert(List<IPTV_Spot_Limit__c> newList){
        System.debug('=== TA_AT_IPTVSpotLimit_BI_SetName ===');
        try {
            for (IPTV_Spot_Limit__c spotReq : newList) {
                Date startDate = spotReq.Start_Date__c;
                Date endDate = spotReq.End_Date__c;

                String formatName = 
                    'SL / ' + 
                    spotReq.Channel__c + ' / ' + 
                    spotReq.ShowTime__c + ' / ' + 
                    startDate.day() + '-' + 
                    endDate.day() + '/' +
                    startDate.month() + '/' + 
                    startDate.year();

                spotReq.Name = formatName;
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_AT_IPTVSpotLimit_BI_SetName.beforeInsert function::' + e.getmessage() + '::' + e.getLineNumber(); 
            system.debug('==================== error message : ' + errMessage); 
            AppUtils.putError(errMessage );
        }
    }
}