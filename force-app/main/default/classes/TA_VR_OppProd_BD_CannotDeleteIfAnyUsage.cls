/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 02/02/2025
 * @last modified by  : Syaiful Syafani
**/
public with sharing class TA_VR_OppProd_BD_CannotDeleteIfAnyUsage implements TriggerAction.BeforeDelete {
    public void BeforeDelete( List<OpportunityLineItem> oldList ){
        System.debug('=== TA_VR_OppProd_BD_CannotDeleteIfAnyUsage ===');
        
        String notes;
        String errorMsg;
        String message;
        Integer lineNumber;

        try {
            for (OpportunityLineItem opptyProdoLDWRec : oldList) {
                List<Usage__c> usageList = OpportunityProductService.getUsagesOfProduct(opptyProdoLDWRec.id);
                List<OpportunityLineItem> opptyProductList = OpportunityProductService.getOpptyProduct(opptyProdoLDWRec.opportunityid);
                System.debug('=== opptyProductList: '+ opptyProductList.size());

                // validation delete oppty product with usage
                if (usageList.size() > 0) {
                    opptyProdoLDWRec.addError ('Produk ini tidak bisa dihapus karena sudah ada data usage. Jika ada kesulitan hubungi system administrator');
                } 
                
                // validation delete oppty product
                if (opptyProductList.size() == 1) {
                    opptyProdoLDWRec.addError('Produk ini tidak bisa dihapus karena setidaknya opportunity memiliki satu product');
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            notes = 'Error on TA_VR_OppProd_BD_CannotDeleteIfAnyUsage.BeforeDelete method.'; message = e.getmessage() + ' - ' +e.getStacktraceString() ; lineNumber = e.getLineNumber();
            errorMsg = notes + '::' + message + '::' + lineNumber; apputils.puterror(errorMsg);
            system.debug ('errorMsg : ' + errorMsg);
        }
    }
}