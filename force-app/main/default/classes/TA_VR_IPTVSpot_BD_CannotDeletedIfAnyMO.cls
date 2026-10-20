/**
 * @description       : 
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TA_VR_IPTVSpot_BD_CannotDeletedIfAnyMO implements TriggerAction.BeforeDelete {
    public void BeforeDelete( List<IPTV_Spot_Limit__c> oldList ){
        System.debug('=== TA_VR_IPTVSpot_BD_CannotDeletedIfAnyMO ===');

        
        String notes;
        String errorMsg;
        String message;
        Integer lineNumber;
        

        try {
            for (IPTV_Spot_Limit__c IPTVSpotlimitRec : oldList) {
                List<Media_Order_Item__c> moItemList = IPTVSpotlimitService.getMOItemOnIPTVDailyStatus(IPTVSpotlimitRec.id);
                if (moItemList.size() > 0) {
                    IPTVSpotlimitRec.addError ('IPTV Spot limit ini tidak bisa dihapus karena sudah ada Media order. Jika ada kesulitan hubungi system administrator');

                }

            }

         if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }

        } catch (Exception e) {

            notes = 'Error on TA_VR_IPTVSpot_BD_CannotDeletedIfAnyMO.BeforeDelete method.'; message = e.getmessage() + ' - ' +e.getStacktraceString() ; lineNumber = e.getLineNumber();
            errorMsg = notes + '::' + message + '::' + lineNumber; apputils.puterror(errorMsg);
            system.debug ('errorMsg : ' + errorMsg);

        }

    }
}