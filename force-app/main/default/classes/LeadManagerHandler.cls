/**
 * @description       : MANAGE HANDLER FOR TRIGGER LEAD
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : RKA
**/
public without sharing class LeadManagerHandler {
    public final static String USER_INTEGRATION_DIGIADS = System.Label.USER_INTEGRATION_DIGIADS;

    public void beforeInsert(List<Lead> leads) {
        
    }
    
    public void beforeUpdate(List<Lead> leads) {
        if (System.Label.Trigger_Lead_Before_Update_On ==  'YES') {
            for (Lead ld : leads) {
                Lead oldLd = (Lead) Trigger.OldMap.get(ld.Id);
                if (oldLd.OwnerId != ld.OwnerId) {
                    ld.stamp_owner__c = oldLd.OwnerId;
                }
            }
        }
    }
    
    public void beforeDelete(List<Lead> leads) {
        
    }
    
    public void afterInsert(List<Lead> leads) {
        
    }
    
    public void afterUpdate(List<Lead> leads) {
        if ((!system.isFuture() && !system.isBatch() && !system.isQueueable() && !system.isScheduled() && UserInfo.getUserId() != USER_INTEGRATION_DIGIADS) || Test.isRunningTest()) {
            updateLeadCSSMInfo(leads);
        }
    }
    
    public void afterDelete(List<Lead> leads) {
        for (Lead ld : leads) {
            if ((String.isNotBlank(ld.CSSM_Record_Id_DigiAds__c) && !system.isFuture() && !system.isBatch() && !system.isQueueable() && !system.isScheduled() && UserInfo.getUserId() != USER_INTEGRATION_DIGIADS) || Test.isRunningTest()) {
                LeadServices.deleteLeadCSSM(ld.CSSM_Record_Id_DigiAds__c);
            }
        }
    }
    
    private void updateLeadCSSMInfo(List<Lead> leads) {
        Set<String> leadIds = new Set<String>();
        Set<String> leadConvertedIds = new Set<String>();
        
        for (Lead ld : leads) {
            Lead oldLd = (Lead) Trigger.OldMap.get(ld.Id);
            if (String.isNotBlank(ld.CSSM_Record_Id_DigiAds__c) && !ld.IsConverted) {
                leadIds.add(ld.Id);
            } else if (String.isNotBlank(ld.CSSM_Record_Id_DigiAds__c) && ld.IsConverted && oldLd.IsConverted != ld.IsConverted) {
                leadConvertedIds.add(ld.Id);
            }
        }
        
        if (leadIds.size() > 0 && !Test.isRunningTest()) {
            LeadServices.patchLead(leadIds);
        }

        if (leadConvertedIds.size() > 0 && !Test.isRunningTest()) {
            LeadServices.convertLead(leadConvertedIds);
        }
    }
}