public with sharing class DSPFeeTriggerHandler {

    public static void setDealIDandBrandtoTheRecord(List<dsp_fee__c> newDSPFeeList){
        try {
            list<dsp_fee__c> updateNewDSPFeeList = new list<dsp_fee__c>();
            for(dsp_fee__c newDSPFeeListRec :newDSPFeeList) {
            
                list<string> splitCampaigntoList = newDSPFeeListRec.campaign__c.split('_');
            
                //TADEX_TELKOMSEL_TTD_3300_DISPLAY_01102231122022_OVO_PM-TRRR-4949
                string brandValue = '';
                string dealId = '';
                if(splitCampaigntoList.size() > 6){
                    brandValue = splitCampaigntoList[6];
                    newDSPFeeListRec.brand__c = brandValue;

                    dealId = splitCampaigntoList[7];
                    newDSPFeeListRec.deal_id__c = dealId;
                }else{
                    newDSPFeeListRec.brand__c = '';
                    newDSPFeeListRec.deal_id__c = '';
                }
                
                updateNewDSPFeeList.add(newDSPFeeListRec);
            }
        } catch (Exception e) {
            string errMessage = 'Error on DSPFeeTriggerHandler.setDealIDandBrandtoTheRecord method.::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

    public void OnBeforeInsert(List<dsp_fee__c> newDSPFeesList){
        setDealIDandBrandtoTheRecord(newDSPFeesList);
    }

}