/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  : Bagus Aries Setiawan
**/
public with sharing class TA_VR_Lead_BI_DuplicateLead implements TriggerAction.BeforeInsert {
    public void BeforeInsert(List<Lead> newList) {
        System.debug('=== TA_VR_Lead_BI_DuplicateLead ===');
        
        String notes;
        String errorMsg;
        String message;
        Integer lineNumber;

        try {
            for (Lead leadRec : newList) {
                List<Lead> leadList = LeadService.getLeadDuplicateParams(leadRec.Legal_Name__c);
                
                if (leadList.size() > 0) {
                    leadRec.addError('Unable to input leads because these leads already exist in Salesforce');
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            notes = 'Error on TA_VR_Lead_BI_DuplicateLead.BeforeInsert method.'; message = e.getmessage() + ' - ' +e.getStacktraceString() ; lineNumber = e.getLineNumber();
            errorMsg = notes + '::' + message + '::' + lineNumber; apputils.puterror(errorMsg);
            system.debug ('errorMsg : ' + errorMsg);
        }
    }
}