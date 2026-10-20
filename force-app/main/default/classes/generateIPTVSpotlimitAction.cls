/**
 * @description       : 
 * @test Class        : generateIPTVSpotlimitActionTEST
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-17-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class generateIPTVSpotlimitAction {
    @InvocableMethod(label='Generate IPTV Spot limit' description='Generate a new Spot Limit')
    public static List<List<IPTV_Spot_Limit__c>> createIPTVSpotlimit(List<DateRangeRequest> requestList) {
        List<List<IPTV_Spot_Limit__c>> IPTVSpotLimitList = new List<List<IPTV_Spot_Limit__c>>();
    
        for(DateRangeRequest request : requestList) {
            List<IPTV_Spot_Limit__c> IPTVspotlimitRec = new List<IPTV_Spot_Limit__c>();
            if (request.Type == 'Yearly') {
                IPTVspotlimitRec.addAll(IPTVSpotlimitService.createYearlyRecords(request.Year, request.spotLimit, request.IPTVInventoryId));
            } else if (request.Type == 'Specific') {
                IPTVspotlimitRec.addAll(IPTVSpotlimitService.createCustomDateRangeRecords(request.StartDate, request.EndDate, request.spotLimit, request.IPTVInventoryId));
            }
    
            // Insert records and handle DML exceptions
            try {
                insert IPTVspotlimitRec;
                
                // Create daily spot limit records after the main records are inserted
                IPTVSpotlimitService.createDailySpotLimitRecords(IPTVspotlimitRec);
                
            } catch (DmlException e) {
                // Handle exception
                System.debug('Error inserting records: ' + e.getMessage());
            }
    
            IPTVSpotLimitList.add(IPTVspotlimitRec);
        }
    
        return IPTVSpotLimitList;
    }

   

    public class DateRangeRequest {
        @InvocableVariable(required=true)
        public String Type; // 'Yearly' or 'CustomDateRange'
    
        @InvocableVariable
        public Integer Year; // Required for 'Yearly' type
    
        @InvocableVariable
        public Integer spotLimit;
    
        @InvocableVariable
        public Date StartDate; // Required for 'CustomDateRange' type
    
        @InvocableVariable
        public Date EndDate; // Required for 'CustomDateRange' type
    
        @InvocableVariable
        public Id IPTVInventoryId; // Single Inventory ID
    }
}