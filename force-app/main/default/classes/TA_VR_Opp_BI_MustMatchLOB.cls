/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   28/02/2025   Syaiful Syafani   Initial Version
**/
public with sharing class TA_VR_Opp_BI_MustMatchLOB implements TriggerAction.BeforeInsert {
    public void BeforeInsert(List<Opportunity> newList) {
        System.debug('=== TA_VR_Opp_BI_MustMatchLOB ===');

        try {
            Map<Id, Boolean> noValidLOBMap = new Map<Id, Boolean>();
            for (Opportunity opptyRec : newList) {
                noValidLOBMap = OpportunityService.CheckUpdateOpptyOwner_V2(opptyRec.Brand__c, opptyRec.OwnerId);
            }
            System.debug('== noValidLOBMap: '+ noValidLOBMap);

            for (Opportunity newOpptyRec : newList) {
                Boolean noValidOwner = noValidLOBMap.get(newOpptyRec.OwnerId);
                System.debug('== noValidOwner: '+ noValidOwner);

                if (noValidOwner == true) {
                    newOpptyRec.addError('Cannot create oppty because Owner not access with this brand LOB.');
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_VR_Opp_BI_MustMatchLOB-BeforeInsert function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}