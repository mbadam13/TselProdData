/**
 * @description       : 
 * Test Class         : IPTVSpotlimitService_Test
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * V 1.0         Muhammad Bustamil Adam      Intial Create
**/
public with sharing class IPTVSpotlimitService {
   
    public static List<IPTV_Spot_Limit__c> createYearlyRecords(Integer year, Integer spotLimit, Id IPTVInventoryId) {
        List<IPTV_Spot_Limit__c> IPTVspolimitYearlyRec = new List<IPTV_Spot_Limit__c>();
    
        for (Integer month = 1; month <= 12; month++) {
            Date startDate = Date.newInstance(year, month, 1);
            Date endDate = calculateEndOfMonth(startDate);
            IPTVspolimitYearlyRec.add(createRecord(IPTVInventoryId, spotLimit, startDate, endDate));
        }
    
        return IPTVspolimitYearlyRec;
    }
    
    public static List<IPTV_Spot_Limit__c> createCustomDateRangeRecords(Date startDate, Date endDate, Integer spotLimit, Id IPTVInventoryId) {
        List<IPTV_Spot_Limit__c> IPTVspolimitSpecifiRec = new List<IPTV_Spot_Limit__c>();
    
        Date currentDate = startDate;
    
        while (currentDate <= endDate) {
            Date currentEndDate = currentDate.month() == endDate.month() && currentDate.year() == endDate.year() ? endDate : calculateEndOfMonth(currentDate);
            IPTVspolimitSpecifiRec.add(createRecord(IPTVInventoryId, spotLimit, currentDate, currentEndDate));
            currentDate = currentDate.addMonths(1).toStartOfMonth();
        }
    
        return IPTVspolimitSpecifiRec;
    }
    
    public static IPTV_Spot_Limit__c createRecord(Id IPTVInventoryId, Integer spotLimit, Date startDate, Date endDate) {
        IPTV_Spot_Limit__c IPTVspotlimitDataRec = new IPTV_Spot_Limit__c();
        IPTVspotlimitDataRec.IPTV_Inventory__c = IPTVInventoryId;
        IPTVspotlimitDataRec.Spot_Limit__c = spotLimit;
        IPTVspotlimitDataRec.Start_Date__c = startDate;
        IPTVspotlimitDataRec.End_Date__c = endDate;
        IPTVspotlimitDataRec.is_Active__c = true;
        return IPTVspotlimitDataRec;
    }

    public static Date calculateEndOfMonth(Date startDate) {
        Integer lastDay = startDate.toStartOfMonth().addMonths(1).addDays(-1).day();
        return Date.newInstance(startDate.year(), startDate.month(), lastDay);
    }

    public static void createDailySpotLimitRecords(List<IPTV_Spot_Limit__c> IPTVspolimitListRec) {
        List<IPTV_Spot_Daily_Status__c> IPTVspotdailyRec = new List<IPTV_Spot_Daily_Status__c>();
        
        // Get a set of IPTV Inventory IDs
        Set<Id> inventoryIds = new Set<Id>();
        for (IPTV_Spot_Limit__c spotLimit : IPTVspolimitListRec) {
            inventoryIds.add(spotLimit.IPTV_Inventory__c);
        }
        
        // Query the IPTV Inventory records to get their related data
        Map<Id, IPTV_Inventory__c> inventoryMap = new Map<Id, IPTV_Inventory__c>();
        for (IPTV_Inventory__c inventory : [SELECT Id, Name, IPTV_Channels__r.Name, Show_Time__c, Time__c FROM IPTV_Inventory__c WHERE Id IN :inventoryIds]) {
            inventoryMap.put(inventory.Id, inventory);
        }
        
        for (IPTV_Spot_Limit__c spotLimit : IPTVspolimitListRec) {
            IPTV_Inventory__c inventory = inventoryMap.get(spotLimit.IPTV_Inventory__c);
            Date currentDate = spotLimit.Start_Date__c;
            while (currentDate <= spotLimit.End_Date__c) {
                IPTVspotdailyRec.add(createDailyRecord(spotLimit.Id, currentDate, spotLimit.Spot_Limit__c, inventory));
                currentDate = currentDate.addDays(1);
            }
        }
        
        try {
            insert IPTVspotdailyRec;
        } catch (DmlException e) {
            System.debug('Error inserting daily records: ' + e.getMessage());
        }
    }
    
    public static IPTV_Spot_Daily_Status__c createDailyRecord(Id spotLimitId, Date currentDate, Decimal spotLimit, IPTV_Inventory__c inventory) {
        IPTV_Spot_Daily_Status__c IPTVspotdailyDataRec = new IPTV_Spot_Daily_Status__c();
        IPTVspotdailyDataRec.Name = 'SDS / ' + inventory.IPTV_Channels__r.Name + ' / ' + inventory.Show_Time__c + ' / ' + currentDate.year() + ' - ' + currentDate.month() + ' - ' + currentDate.day();
        IPTVspotdailyDataRec.IPTV_Spot_Limit__c = spotLimitId;
        IPTVspotdailyDataRec.Date__c = currentDate;
        // IPTVspotdailyDataRec.Channel__c = inventory.IPTV_Channels__r.Name; 
        // IPTVspotdailyDataRec.ShowTime__c = inventory.Time__c;
        IPTVspotdailyDataRec.Inventory_Name__c = inventory.Id;
        // IPTVspotdailyDataRec.Spot_Limit__c = spotLimit;
        
        return IPTVspotdailyDataRec;
    }

    public static List<Media_Order_Item__c> getMOItemOnIPTVDailyStatus(Id IPTVSpotlimitId) {
        // Query to get IPTV Spot Daily Status records related to the given IPTV Spot Limit Id
        List<IPTV_Spot_Daily_Status__c> IPTVDailySpotlimitList = [
            SELECT Id, Name, IPTV_Spot_Limit__c, Date__c
            FROM IPTV_Spot_Daily_Status__c
            WHERE IPTV_Spot_Limit__c = :IPTVSpotlimitId
        ];
    
        System.debug('IPTV Daily Spot Limit List: ' + IPTVDailySpotlimitList);
    
        // Collect the IDs of the IPTV Spot Daily Status records
        Set<Id> IPTVDailyStatusIds = new Set<Id>();
        for (IPTV_Spot_Daily_Status__c dailyStatus : IPTVDailySpotlimitList) {
            IPTVDailyStatusIds.add(dailyStatus.Id);
        }
    
        System.debug('IPTV Daily Status IDs: ' + IPTVDailyStatusIds);
    
        // Query to get Media Order Items related to the collected IPTV Spot Daily Status IDs
        List<Media_Order_Item__c> moItemList = new List<Media_Order_Item__c>();
        if (!IPTVDailyStatusIds.isEmpty()) {
            moItemList = [
                SELECT Id, Name, Inventory_Name__c, IPTV_Spot_Daily_Status__c 
                FROM Media_Order_Item__c 
                WHERE IPTV_Spot_Daily_Status__c IN :IPTVDailyStatusIds
            ];
        }
    
        Integer moItemCount = moItemList.size();
        System.debug('Jumlah MO Item: ' + moItemCount);
        System.debug('Result MO Item List: ' + moItemList);
    
        return moItemList;
    }
}