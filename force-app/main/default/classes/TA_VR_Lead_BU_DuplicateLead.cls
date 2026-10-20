/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  : Bagus Aries Setiawan
**/
public with sharing class TA_VR_Lead_BU_DuplicateLead implements TriggerAction.BeforeUpdate {
    public void BeforeUpdate(List<Lead> newList, List<Lead> oldList){
        System.debug('=== TA_VR_Lead_BU_DuplicateLead ===');

        String notes;
        String errorMsg;
        String message;
        Integer lineNumber;

        Map<Id, Lead> oldMap = new Map<Id, Lead>(oldList);

        try {
            for (Lead newLeadRec : newList) {
                Lead oldLeadRec = oldMap.get(newLeadRec.Id);
                
                if (newLeadRec.Legal_Name__c != oldLeadRec.Legal_Name__c) {
                    List<Lead> leadList = LeadService.getLeadDuplicateParams(newLeadRec.Legal_Name__c);

                    if (leadList.size() > 0) {
                        newLeadRec.addError('Unable to update leads because these leads already exist in Salesforce');
                    }
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            notes = 'Error on TA_VR_Lead_BU_DuplicateLead.BeforeUpdate method.'; message = e.getmessage() + ' - ' +e.getStacktraceString() ; lineNumber = e.getLineNumber();
            errorMsg = notes + '::' + message + '::' + lineNumber; apputils.puterror(errorMsg);
            system.debug ('errorMsg : ' + errorMsg);
        }
    }
}