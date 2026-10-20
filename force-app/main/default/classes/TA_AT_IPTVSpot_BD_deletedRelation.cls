/**
 * @description       : Trigger Automation for Deteled data Relation
 * @testClass         : deleteRelatedRec_Test
 * @author            : M B Adam
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TA_AT_IPTVSpot_BD_deletedRelation implements TriggerAction.BeforeDelete {
    public void BeforeDelete(List<IPTV_Spot_Limit__c> oldList ) {
        System.debug('=== TA_AT_IPTVInv_BD_deletedRelation ===');

        Set<Id> IPTVspotlimitId = new Set<Id>();

        // Collect the IDs of the deleted IPTV inventories
        for (IPTV_Spot_Limit__c IPTVSpotlimitRec : oldList) {
            IPTVspotlimitId.add(IPTVSpotlimitRec.Id);
        }

          System.debug('Data IPT inventory IDs: ' + IPTVspotlimitId);

        
            // Query the related IPTV Spot Limit records
           List<IPTV_Spot_Daily_Status__c> IPTVDailyspotLimitsToDelete = [
            SELECT Id, IPTV_Spot_Limit__c
            FROM IPTV_Spot_Daily_Status__c 
            WHERE IPTV_Spot_Limit__c IN :IPTVspotlimitId
            ];
            

          
                // Delete the IPTV Spot Limit records
            delete IPTVDailyspotLimitsToDelete;
            
        
    }
}