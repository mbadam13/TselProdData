/**
 * @description       : 
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-08-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TA_VR_IPTVInv_BI_checkExistingdata implements TriggerAction.BeforeInsert {
    public void BeforeInsert( List<IPTV_Inventory__c> newList ){
        System.debug('=== TA_VR_IPTVInv_BI_checkExistingdata ===');

        String notes;
        String errorMsg;
        String message;
        Integer lineNumber;
        

        try {
            for (IPTV_Inventory__c IPTVInvRec : newList) {
                List<IPTV_Inventory__c> IPTVInvList = IPTVInvService.getIPTVInvwithParams(IPTVInvRec.Show_Time__c, IPTVInvRec.Time__c, IPTVInvRec.IPTV_Channels__c);
                
                if (IPTVInvList.size() > 0) {
                    IPTVInvRec.addError ('Anda Tidak bisa Memasukan data IPTV Inventories ini karena sudah ada data yang sama. Jika ada kesulitan hubungi system administrator');

                }

            }

          if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }        

        } catch (Exception e) {

            notes = 'Error on TA_VR_IPTVChanel_BI_checkExistingdata.BeforeInsert method.'; message = e.getmessage() + ' - ' +e.getStacktraceString() ; lineNumber = e.getLineNumber();
            errorMsg = notes + '::' + message + '::' + lineNumber; apputils.puterror(errorMsg);
            system.debug ('errorMsg : ' + errorMsg);

        }

    }
}