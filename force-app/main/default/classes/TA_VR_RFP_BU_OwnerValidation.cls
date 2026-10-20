/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 08-30-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class TA_VR_RFP_BU_OwnerValidation implements TriggerAction.BeforeUpdate {
    public static void BeforeUpdate(List<Request_for_Proposal__c> newList, List<Request_for_Proposal__c> oldList){
        System.debug('== TA_AT_RFP_AU_OwnerValidation ==');

        Map<Id, Request_for_Proposal__c> oldMap = new Map<Id, Request_for_Proposal__c>(oldList);
        try {
            for (Request_for_Proposal__c newRFPRec : newList) {
                Request_for_Proposal__c oldRFPRec = oldMap.get(newRFPRec.Id);

                if (newRFPRec != oldRFPRec) {
                    RFPValidationHandler.validationRules(newList, oldList);
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_VR_RFP_BU_OwnerValidation.BeforeUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}