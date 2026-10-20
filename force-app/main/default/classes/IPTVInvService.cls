/**
 * @description       : 
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class IPTVInvService {




    public static void updateIPTVInventorySpotLimit(List<IPTV_Inventory__c> inventories) {
        if (inventories == null || inventories.isEmpty()) {
            return;
        }

        // Collect all IPTV_Inventory__c IDs
        Set<Id> inventoryIds = new Set<Id>();
        for (IPTV_Inventory__c inventory : inventories) {
            inventoryIds.add(inventory.Id);
        }

        Date today = Date.today();

        // Query all relevant IPTV_Spot_Limit__c records in one go
        Map<Id, IPTV_Spot_Limit__c> latestSpotLimitsMap = new Map<Id, IPTV_Spot_Limit__c>();
        for (IPTV_Spot_Limit__c spotLimit : [
            SELECT Id, LastModifiedDate, IPTV_Inventory__c, Start_Date__c, End_Date__c
            FROM IPTV_Spot_Limit__c
            WHERE IPTV_Inventory__c IN :inventoryIds AND Start_Date__c <= :today AND End_Date__c >= :today
            ORDER BY IPTV_Inventory__c, LastModifiedDate DESC
        ]) {
            // Store the first spot limit (which is the latest due to ordering) for each inventory
            if (!latestSpotLimitsMap.containsKey(spotLimit.IPTV_Inventory__c)) {
                latestSpotLimitsMap.put(spotLimit.IPTV_Inventory__c, spotLimit);
            }
        }

        // Prepare records for update
        List<IPTV_Inventory__c> inventoryToUpdate = new List<IPTV_Inventory__c>();
        for (IPTV_Inventory__c inventory : inventories) {
            IPTV_Spot_Limit__c latestSpotLimit = latestSpotLimitsMap.get(inventory.Id);
            if (latestSpotLimit != null) {
                inventory.Current_Spotlimit__c = latestSpotLimit.Id;
                inventoryToUpdate.add(inventory);
            }
        }

        // Perform the update
        if (!inventoryToUpdate.isEmpty()) {
            update inventoryToUpdate;
        }
    }
  

    public static List<Media_Order_Item__c> getMOItem (ID IPTVInventoryId){

        List<Media_Order_Item__c> moItemList = New List<Media_Order_Item__c>();

        moItemList = [
            SELECT Id, Name, Inventory_Name__c 
            FROM Media_Order_Item__c 
            Where 
            Inventory_Name__c = : IPTVInventoryId
        ];

        Integer moItemCount = moItemList.size();

        System.debug('Jumlah Mo Item' + moItemCount);
        System.debug('result MO Item List' + moItemList);

        return moItemList;
    }

    public static List<IPTV_Inventory__c> getIPTVInvwithParams(String IPTVInvShowtime, String IPTVInvTime, String IPTVChanelId){

        List<IPTV_Inventory__c> IPTVInvList = New List<IPTV_Inventory__c>();

        IPTVInvList = [
            SELECT Id, Name, IPTV_Channels__c, Show_Time__c, Time__c
            FROM IPTV_Inventory__c 
            Where 
            Show_Time__c = : IPTVInvShowtime And Time__c =: IPTVInvTime And IPTV_Channels__c =: IPTVChanelId
        ];
           

        Integer IPTVInvCount = IPTVInvList.size();

        System.debug('Jumlah IPTV Chanel' + IPTVInvCount);
        System.debug('result IPTV Chanel List' + IPTVInvList);

        return IPTVInvList;
    }

    

    

}