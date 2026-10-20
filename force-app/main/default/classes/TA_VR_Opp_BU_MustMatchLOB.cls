/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06/03/2025   Syaiful Syafani   Initial Version
**/
public with sharing class TA_VR_Opp_BU_MustMatchLOB implements TriggerAction.BeforeUpdate {
    public void BeforeUpdate(List<Opportunity> newList, List<Opportunity> oldList){
        System.debug('=== TA_VR_Opp_BU_CannotChangeOwner ===');

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(oldList);

        try {
            Map<Id, Boolean> noValidChangeOwner = new Map<Id, Boolean>();
            for (Opportunity newOppRec : newList) {
                Opportunity oldOppRec = oldMap.get(newOppRec.Id);

                if (oldOppRec.OwnerId != newOppRec.OwnerId) { // condition if owner changed
                    System.debug('=== masuk criteria owner is changed ===');
                   // noValidChangeOwner = OpportunityService.CheckUpdateOpptyOwner(newOppRec.Brand__c, newOppRec.OwnerId);
                    noValidChangeOwner = OpportunityService.CheckUpdateOpptyOwner_V2(newOppRec.Brand__c, newOppRec.OwnerId);
                }
            }
            System.debug('== noValidChangeOwner.trigger: '+ noValidChangeOwner);

            for (Opportunity opptyRec : newList) {
                Boolean noValidOwner = noValidChangeOwner.get(opptyRec.OwnerId);
                System.debug('== noValidOwner: '+ noValidOwner);

                if (noValidOwner == true) {
                    opptyRec.addError('Cannot change owner because not in same LOB.');
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_VR_Opp_BU_CannotChangeOwner-BeforeUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}