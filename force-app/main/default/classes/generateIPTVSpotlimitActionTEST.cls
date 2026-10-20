/**
 * @description       : 
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-17-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class generateIPTVSpotlimitActionTEST {
    @isTest
    static void testCreateIPTVSpotlimitYearly() {
        // Set up test data
       
        Integer testYear = 2024;
        Integer testSpotLimit = 100;
        
        IPTV_Channel__c IPTVChannel1 = new IPTV_Channel__c(
            Name = 'AllPlay.ent', 
            Product_Inventory__c = 'TVC PLATINUM', 
            Keyword__c = 'PLATINUM'     
        );
        insert IPTVChannel1;

        IPTV_Inventory__c IPTVInventory1 = new IPTV_Inventory__c(
            Name = 'AllPlay.ent REGULAR TIME', 
            IPTV_Channels__c = IPTVChannel1.Id, 
            Show_Time__c = 'REGULAR TIME', 
            Time__c = '00.00 - 17.00', 
            keyword__c = 'all'
        );
        insert IPTVInventory1;
        
        // Create DateRangeRequest for yearly type
        generateIPTVSpotlimitAction.DateRangeRequest request = new generateIPTVSpotlimitAction.DateRangeRequest();
        request.Type = 'Yearly';
        request.Year = testYear;
        request.spotLimit = testSpotLimit;
        request.IPTVInventoryId = IPTVInventory1.Id;
        
        List<generateIPTVSpotlimitAction.DateRangeRequest> requestList = new List<generateIPTVSpotlimitAction.DateRangeRequest> { request };
        
        // Call the invocable method
        Test.startTest();
        List<List<IPTV_Spot_Limit__c>> result = generateIPTVSpotlimitAction.createIPTVSpotlimit(requestList);
        Test.stopTest();
        
     
    }
    
    @isTest
    static void testCreateIPTVSpotlimitCustomDateRange() {
        // Set up test data
       
        Date testStartDate = Date.newInstance(2024, 1, 1);
        Date testEndDate = Date.newInstance(2024, 12, 31);
        Integer testSpotLimit = 50;
        
         IPTV_Channel__c IPTVChannel1 = new IPTV_Channel__c(
            Name = 'AllPlay.ent', 
            Product_Inventory__c = 'TVC PLATINUM', 
            Keyword__c = 'PLATINUM'     
        );
        insert IPTVChannel1;

        IPTV_Inventory__c IPTVInventory1 = new IPTV_Inventory__c(
            Name = 'AllPlay.ent REGULAR TIME', 
            IPTV_Channels__c = IPTVChannel1.Id, 
            Show_Time__c = 'REGULAR TIME', 
            Time__c = '00.00 - 17.00', 
            keyword__c = 'all'
        );
        insert IPTVInventory1;
        
        // Create DateRangeRequest for custom date range type
        generateIPTVSpotlimitAction.DateRangeRequest request = new generateIPTVSpotlimitAction.DateRangeRequest();
        request.Type = 'Specific';
        request.StartDate = testStartDate;
        request.EndDate = testEndDate;
        request.spotLimit = testSpotLimit;
        request.IPTVInventoryId = IPTVInventory1.Id;
        
        List<generateIPTVSpotlimitAction.DateRangeRequest> requestList = new List<generateIPTVSpotlimitAction.DateRangeRequest> { request };
        
        // Call the invocable method
        Test.startTest();
        List<List<IPTV_Spot_Limit__c>> result = generateIPTVSpotlimitAction.createIPTVSpotlimit(requestList);
        Test.stopTest();
        
       
    }
    
  
}