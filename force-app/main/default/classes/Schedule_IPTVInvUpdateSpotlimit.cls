/**
 * @description       : 
 * @author            : M B Adam
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Schedule_IPTVInvUpdateSpotlimit implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        List<IPTV_Inventory__c> iptvInventories = getIPTVInventories();
        IPTVInvService.updateIPTVInventorySpotLimit(iptvInventories);
    }
    
    private List<IPTV_Inventory__c> getIPTVInventories() {
        List<IPTV_Inventory__c> iptvInventories = new List<IPTV_Inventory__c>();
        
        // Perform query to get IPTV_Inventory__c records
        iptvInventories = [
            SELECT Id
            FROM IPTV_Inventory__c
            // Add any additional WHERE conditions if needed
        ];
        
        return iptvInventories;
    }
    
    
}