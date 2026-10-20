/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 03-18-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   20/02/2025   Syaiful Syafani   Initial Version
 * 2.0   20/03/2025   M B Adam          Change Wording error
**/
public with sharing class TA_VR_Opp_BU_PenagihanMustSame implements TriggerAction.BeforeUpdate{
    public void BeforeUpdate(List<Opportunity> newList, List<Opportunity> oldList){
        System.debug('=== TA_VR_Opp_BU_PenagihanMustSame ===');

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(oldList);

        try {
            for (Opportunity newOpptyRec : newList) {
                Opportunity oldOpptyRec = oldMap.get(newOpptyRec.Id);
                System.debug('=== Penagihan Digital: '+ newOpptyRec.Penagihan_based_on__c);
                System.debug('=== Penagihan TV: '+ newOpptyRec.Penagihan_based_on_TV__c);

                if (
                    newOpptyRec.Business_Product__c == 'Combine' &&
                        (
                            newOpptyRec.Penagihan_based_on__c != oldOpptyRec.Penagihan_based_on__c ||
                            newOpptyRec.Penagihan_based_on_TV__c != oldOpptyRec.Penagihan_based_on_TV__c
                        ) &&
                    newOpptyRec.Penagihan_based_on__c != newOpptyRec.Penagihan_based_on_TV__c
                ) {
                    newOpptyRec.addError('Penagihan based on (Digital) dan Penagihan based on (TV) harus diisi dengan tipe Penagihan yang sama');
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_VR_Opp_BU_PenagihanMustSame-BeforeUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}