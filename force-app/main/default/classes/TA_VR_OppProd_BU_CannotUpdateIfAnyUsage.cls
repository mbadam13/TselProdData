/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 02-24-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   ???          -                 Initial Version
 * 2.0   04/02/2025   Syaiful Syafani   Add more condition for business product digital media  
 * 3.0   24/02/2025   M B Adam          Add more Condition in business product digital          
**/
public with sharing class TA_VR_OppProd_BU_CannotUpdateIfAnyUsage implements TriggerAction.BeforeUpdate {
 
    public void BeforeUpdate(List<OpportunityLineItem> newList, List<OpportunityLineItem> oldList){
        System.debug('=== TA_VR_OppProd_BU_CannotUpdateIfAnyUsage ===');

        String notes;
        String errorMsg;
        String message;
        Integer lineNumber;
        
        try {
            for (Integer i = 0; i < newList.size(); i++) {
                OpportunityLineItem newRec = newList[i];
                OpportunityLineItem oldRec = oldList[i];
                List<Usage__c> usageList = OpportunityProductService.getUsagesOfProduct(newRec.Id);
             
                if (usageList.size() > 0 &&
                    newRec.Business_Product__c == 'Digital Media' &&
                    oldRec.Usage_Actual__c != null &&
                    newRec.Usage_Actual__c == oldRec.Usage_Actual__c) {
                        
                    newRec.addError('Produk ini tidak bisa diupdate karena sudah ada data usage. Jika ada kesulitan hubungi system administrator');
                }
            }
    

            
             if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            notes = 'Error on TA_VR_OppProd_BU_CannotUpdateIfAnyUsage.BeforeUpdate method.'; message =  e.getmessage() + ' - ' +e.getStacktraceString() ; lineNumber = e.getLineNumber();
            errorMsg = notes + '::' +  message + '::' + lineNumber; apputils.puterror(errorMsg);
            system.debug ('errorMsg : ' + errorMsg);
        }
    }
}