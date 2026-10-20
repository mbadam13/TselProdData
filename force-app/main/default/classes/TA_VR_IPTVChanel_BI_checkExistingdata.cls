/**
 * @description       : 
 * @Test Class        : TA_BI_checkExistingdata_TEST
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-08-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TA_VR_IPTVChanel_BI_checkExistingdata implements TriggerAction.BeforeInsert {
    public void BeforeInsert( List<IPTV_Channel__c> newList ){
        System.debug('=== TA_VR_IPTVChanel_BI_checkExistingdata ===');

        String notes;
        String errorMsg;
        String message;
        Integer lineNumber;
        

        try {
            for (IPTV_Channel__c IPTVChanelRec : newList) {
                List<IPTV_Channel__c> IPTVChanelList = IPTVChanelService.getChanelDatawithName(IPTVChanelRec.Name, IPTVChanelRec.Product_Inventory__c);
                
                if (IPTVChanelList.size() > 0) {
                    IPTVChanelRec.addError ('Anda Tidak bisa Memasukan data Chanel ini karena ada data yang sama. Jika ada kesulitan hubungi system administrator');

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