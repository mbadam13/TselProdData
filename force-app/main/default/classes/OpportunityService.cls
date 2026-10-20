/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 05-14-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   -            Doddy Prima       Initial Version
 * 2.0   26-08-2024   -                 v.2
 * 3.0   24-02-2024   Syaiful Syafani   add method check owner
 * 4.0   24-03-2025   M B Adam          Check Owner Update Opportunity 
 * 5.0   24-03-2025   Yusuf Ramadhan    add method fill approver
 * **/
public class OpportunityService {
    public static Map<Id, List<Adjustment_Log__c>> getOpportunityAdjustmentLogs(Set<Id> opportunityIds) {
        Map<Id, List<Adjustment_Log__c>> opptyAdjLogMap = new Map<Id, List<Adjustment_Log__c>>();

        // Query to get Opportunities with their Adjustment Logs
        List<Opportunity> opportunityList = [SELECT Id, Adjustment_Version__c,
                                                    (SELECT 
                                                        Id, OwnerId, Name, CreatedById, LastModifiedById, Action__c, 
                                                        Old_Quantity__c, Opp_Product_Id__c, Opportunity__c, 
                                                        Product_Id_Number__c, Product__c, Version__c,
                                                        Opportunity_Product__r.Product_id_number__c,
                                                        Opportunity_Product__r.UnitPrice,
                                                        Opportunity_Product__r.quantity,
                                                        Opportunity_Product__r.PricebookEntryId,
                                                        Opportunity_Product__r.opportunity.ownerId,
                                                        Opportunity_Product__r.id,
                                                        New_Sales_Price__c,
                                                        New_Quantity__c
                                                    FROM Adjustment_Logs__r )
                                            FROM Opportunity 
                                            WHERE Id IN :opportunityIds
                                            ORDER BY CreatedDate DESC
        ];

        system.debug('=== opportunityList : ' + opportunityList);


        // set to map
        for (Opportunity oppREC : opportunityList) {
            List<Adjustment_Log__c> adjLogList = new List<Adjustment_Log__c>();
            for (Adjustment_Log__c adjLogREC : oppREC.Adjustment_Logs__r) {
                if (adjLogREC.Version__c == oppREC.Adjustment_Version__c) {
                    
                    system.debug('=== adjLogREC : ' + adjLogREC);
                    adjLogList.add(adjLogREC);
                }
            }
            if (!adjLogList.isEmpty()) {
                opptyAdjLogMap.put(oppREC.Id, adjLogList);
            }
        }

        return opptyAdjLogMap;
    }

    // public static Map<Id,Boolean> CheckInsertOpptyOwner(Id brandId, Id ownerId) {
    //     System.debug('=== OpportunityService.CheckInsertOpptyOwner ===');

    //     // query get record user by param ownerId
    //     List<User> userList = [
    //         SELECT
    //             Id,
    //             UserRoleId,
    //             userrole.name
    //         FROM
    //             User
    //         WHERE
    //             Id = :ownerId
    //     ];
    //     System.debug('== userList: '+ userList);
        
    //     // put to map user
    //     Map<Id, User> userMap = new Map<Id, User>();
    //     for (User userRec : userList) {
    //         userMap.put(userRec.Id, userRec);
    //     }
    //     System.debug('== userMap: '+ userMap);

    //     // query get record brand by param brandId
    //     List<Brand__c> brandList = [
    //         SELECT
    //             Id,
    //             Name,
    //             LOB__c, // lob name
    //             Brand_Category__c // lob Id
    //         FROM
    //             Brand__c
    //         WHERE
    //             Id = :brandId
    //     ];
    //     System.debug('== brandList: '+ brandList);

    //     // mapping lob by brand
    //     Set<Id> lobIds = new Set<Id>();
    //     for (Brand__c brandRec : brandList) {
    //         lobIds.add(brandRec.Brand_Category__c);
    //     }
    //     System.debug('== lobIds: '+ lobIds);

    //     // query lob sales mapping by lobIds
    //     List<LOB_Sales_Mapping__c> lobSalesMappingList = [
    //         SELECT
    //             Id,
    //             Sales__c,
    //             LOB__c, // lob id
    //             LOB__r.Name, // lob Name
    //             LOB_Group_Name__c
    //         FROM
    //             LOB_Sales_Mapping__c
    //         WHERE
    //             LOB__c IN :lobIds AND Sales__c = :ownerId 
    //     ];
    //     System.debug('== lobSalesMappingList: '+ lobSalesMappingList);
    //     System.debug('== lobSalesMappingList: '+ lobSalesMappingList.size());

    //     Map<Id, Boolean> noValidLOBMap = new Map<Id, Boolean>();
    //     for (LOB_Sales_Mapping__c lobRec : lobSalesMappingList) {
    //         // mapping user 
    //         Id currentUser = ownerId; // ngambil user saat oppty kebuat dari parameter yg di lempar
    //         Id salesByLOBMapping = lobRec.Sales__c;
    //         System.debug('== currentUser: '+ currentUser); // sales saat ini
    //         System.debug('== salesByLOBMapping: '+ salesByLOBMapping); // sales pada lob mapping

    //         // get user map dari currentUser(ngambil dari param ownerId) untuk ambil user role
    //         User userRec = userMap.get(currentUser);
    //         String userRole = userRec.userrole.name;
    //         System.debug('== userRole: '+ userRole); 

    //         // result same user role (if same the result is true)
    //         String lobGroupNameByLOBMapping = lobRec.LOB_Group_Name__c;
    //         Boolean sameRoleResult = (userRole.contains(lobRec.LOB_Group_Name__c)) ? true : false;
    //         System.debug('== sameRoleResult: '+ sameRoleResult);

    //         // result different sales
    //         Boolean sameSalesResult = (salesByLOBMapping == currentUser) ? true : false;
    //         System.debug('== sameSalesResult: '+ sameSalesResult);

            
    //         if (sameSalesResult != true && sameRoleResult == true) { 
    //             System.debug('== masuk criteria ==');
    //             noValidLOBMap.put(currentUser, true);
    //         } else {
    //             System.debug('== ga masuk ==');
    //         }
    //     }
    //     System.debug('== noValidLOBMap: '+ noValidLOBMap);
    //     return noValidLOBMap;
    // }

    // public static Map<Id,Boolean> CheckUpdateOpptyOwner(Id brandId, Id currentOwnerId){
    //     System.debug('=== OpportunityService.CheckUpdateOpptyOwner ===');

    //     // query get record user by param ownerId
    //     List<User> userList = [
    //         SELECT
    //             Id,
    //             UserRoleId,
    //             userrole.name
    //         FROM
    //             User
    //         WHERE
    //             Id = :currentOwnerId
    //     ];
    //     System.debug('== userList: '+ userList);
        
    //     // put to map user
    //     Map<Id, User> userMap = new Map<Id, User>();
    //     for (User userRec : userList) {
    //         userMap.put(userRec.Id, userRec);
    //     }
    //     System.debug('== userMap: '+ userMap);

    //     // query get record brand by param brandId
    //     List<Brand__c> brandList = [
    //         SELECT
    //             Id,
    //             Name,
    //             LOB__c, // lob name
    //             Brand_Category__c // lob Id
    //         FROM
    //             Brand__c
    //         WHERE
    //             Id = :brandId
    //     ];
    //     System.debug('== brandList: '+ brandList);

    //     // mapping lob by brand
    //     Set<Id> lobIds = new Set<Id>();
    //     for (Brand__c brandRec : brandList) {
    //         lobIds.add(brandRec.Brand_Category__c);
    //     }
    //     System.debug('== lobIds: '+ lobIds);

    //     // query lob sales mapping by lobIds
    //     List<LOB_Sales_Mapping__c> lobSalesMappingList = [
    //         SELECT
    //             Id,
    //             Sales__c,
    //             LOB__c, // lob id
    //             LOB__r.Name, // lob Name
    //             LOB_Group_Name__c
    //         FROM
    //             LOB_Sales_Mapping__c
    //         WHERE
    //             LOB__c IN :lobIds
    //     ];
    //     System.debug('== lobSalesMappingList: '+ lobSalesMappingList);
    //     System.debug('== lobSalesMappingList: '+ lobSalesMappingList.size());

    //     Map<Id, Boolean> noValidLOBMap = new Map<Id, Boolean>();
    //     for (LOB_Sales_Mapping__c lobRec : lobSalesMappingList) {
    //         // mapping user 
    //         Id currentUser = currentOwnerId; // get user from oppty created param
    //         Id salesByLOBMapping = lobRec.LOB__c;
    //         System.debug('== currentUser: '+ currentUser); // current sales
    //         System.debug('== salesByLOBMapping: '+ salesByLOBMapping); // sales from lob mapping

    //         // get user map from currentUser(get from ownerId param) for get user role
    //         User userRec = userMap.get(currentUser);
    //         String userRole = userRec.userrole.name;
    //         System.debug('== userRole: '+ userRole); 

    //         // result same user role (if same the result is true)
    //         String lobGroupNameByLOBMapping = lobRec.LOB_Group_Name__c;
    //         Boolean sameRoleResult = (userRole.contains(lobRec.LOB_Group_Name__c)) ? true : false;
    //         System.debug('== sameRoleResult: '+ sameRoleResult);

    //         // result different sales
    //         Boolean sameSalesResult = (salesByLOBMapping == currentUser) ? true : false;
    //         System.debug('== sameSalesResult: '+ sameSalesResult);

            
    //         if (sameSalesResult != true && sameRoleResult == true) { // same lob with different sales
    //             System.debug('== masuk criteria 1 ==');
    //             noValidLOBMap.put(currentUser, true);
    //         } else if (sameSalesResult != true && sameRoleResult != true) { // different both of sales and lob
    //             System.debug('== masuk criteria 2 ==');
    //             noValidLOBMap.put(currentUser, true);
    //         } else {
    //             System.debug('== ga masuk ==');
    //         }
    //     }
    //     System.debug('== noValidLOBMap: '+ noValidLOBMap);
    //     return noValidLOBMap;
    // }


    public static Map<Id, Boolean> CheckUpdateOpptyOwner_V2(Id BrandId, Id OpptyOwnerId) {
        System.debug('=== OpportunityService.CheckUpdateOpptyOwner V2 ===');
        
        System.debug(' == OwnerId Change: ' + OpptyOwnerId);
        System.debug(' == BrandId: ' + BrandId);
    
        // Fetch brand information including LOB details
        Brand__c brand = [
            SELECT Id, Name, LOB__c, Brand_Category__c
            FROM Brand__c
            WHERE Id = :BrandId
            LIMIT 1
        ];

     
    
        // Extract LOB information
        String LOBName = brand.LOB__c;

        LOB__c LOBrecord =[
            SELECT Id, Name, LOB_Group__r.Name 
            FROM  LOB__c 
            WHERE Name=: LOBName
            LIMIT 1
        ];

        String LOBGroupName = LOBrecord.LOB_Group__r.Name  ;
        System.debug(' == LOB Name: ' + LOBName);
        System.debug(' == LOB Group Name: ' + LOBGroupName);
    
        // Fetch the role of the Opportunity Owner
        User opptyOwner = [
            SELECT Id, UserRole.Name
            FROM User
            WHERE Id = :OpptyOwnerId
            LIMIT 1
        ];
    
        // Convert role name to lowercase to make comparison case-insensitive
        String roleNameLower = opptyOwner.UserRole.Name.toLowerCase();
        System.debug(' == User Role (lowercase): ' + roleNameLower);
    
        // Initialize the map to store validation results
        Map<Id, Boolean> noValidLOBMap = new Map<Id, Boolean>();
    
        // Check if role contains "sales" or is exactly "sales senior officer"
        if (roleNameLower.contains('sales')) {
            List<SObject> LMSObj; // Use SObject for mixed-type queries
            if (roleNameLower.equals('sales senior officer')) {
                // Query the LOB_Group object instead of LOB_Sales_Mapping
                LMSObj = [
                    SELECT Id, Name, Senior_Officer__c, Active__c FROM LOB_Group__c
                    WHERE Name = :LOBGroupName 
                    AND Senior_Officer__c = :OpptyOwnerId
                    //AND Active__c = true
                ];
            } else {
                // Standard query for other sales roles
                LMSObj = [
                    SELECT Id, Sales__c, LOB__c, LOB__r.Name, LOB_Group_Name__c, Active__c
                    FROM LOB_Sales_Mapping__c
                    WHERE LOB__r.Name = :LOBName
                    AND Sales__c = :OpptyOwnerId
                    //AND Active__c = true
                ];
            }
    
            System.debug('Size of LMSObj: ' + LMSObj.size());
            System.debug('== LMSObj: ' + LMSObj);
    
            // Determine if a valid LOB Sales Mapping exists
            Boolean LOBMatch = LMSObj.isEmpty();
            System.debug('LOB Match: ' + LOBMatch);
    
            // If no matching record found, it's a valid scenario
            if (LOBMatch) {
                noValidLOBMap.put(OpptyOwnerId, true);
            } else {
                System.debug('== Matching LOB Sales Mapping exists ==');
            }
        } else {
            System.debug('== Role does not meet conditions for further checks ==');
        }
    
        System.debug('== noValidLOBMap: ' + noValidLOBMap);
        return noValidLOBMap;
    }

    public static void populatingApproverBasedOnLOB(
        List<Opportunity> newList,
        Map<Id, Opportunity> oldMap,
        Map<Id, Id> brandToSO,
        Map<String, Id> userL234,
        Map<Id, String> oppIdToUserRole
    ) {
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();

        try {
            for (Opportunity anOppty : newList) {
                Opportunity oldOppty = oldMap != null ? oldMap.get(anOppty.Id) : null;
    
                Boolean shouldProcess = (oldMap == null)
                || (oldOppty.Brand__c != anOppty.Brand__c)
                || (oldOppty.OwnerId != anOppty.OwnerId);
    
                if (!shouldProcess) continue;
    
                String userRole = oppIdToUserRole.get(anOppty.Id);
                System.debug('=== userRole: '+userRole);
                Opportunity oppToUpdate = new Opportunity(Id = anOppty.Id);
                Boolean hasChanges = false;
    
                if (anOppty.Brand__c != null && brandToSO.containsKey(anOppty.Brand__c) && userRole != 'SALES SENIOR OFFICER') {
                    Id seniorOfficerId = brandToSO.get(anOppty.Brand__c);
                    if (anOppty.Approval_1__c != seniorOfficerId) {
                        oppToUpdate.Approval_1__c = seniorOfficerId;
                        hasChanges = true;
                    }
                }
    
                if (anOppty.Approval_1__c != null && userRole == 'SALES SENIOR OFFICER') {
                    System.debug('=== Reset approval 1');
                    oppToUpdate.Approval_1__c = null;
                    hasChanges = true;
                }
    
                if (userL234.containsKey('GM SALES') && anOppty.Approval_2__c != userL234.get('GM SALES')) {
                    oppToUpdate.Approval_2__c = userL234.get('GM SALES');
                    hasChanges = true;
                }
    
                if (userL234.containsKey('VP') && anOppty.Approval_3__c != userL234.get('VP')) {
                    oppToUpdate.Approval_3__c = userL234.get('VP');
                    hasChanges = true;
                }
    
                if (userL234.containsKey('DIRECTOR') && anOppty.Approval_4__c != userL234.get('DIRECTOR')) {
                    oppToUpdate.Approval_4__c = userL234.get('DIRECTOR');
                    hasChanges = true;
                }
    
                if (hasChanges) {
                    oppsToUpdate.put(oppToUpdate.Id, oppToUpdate);
                }
            }
    
            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate.values();
            }
        }
        catch (Exception ex) {
            String operation = (oldMap == null || oldMap.isEmpty()) 
                ? 'TA_AT_Opp_AI_FillApproverByLOB afterInsert' 
                : 'TA_AT_Opp_AU_FillApproverByLOB afterUpdate';
            String errMessage = operation+' function::' + ex.getmessage() + '::' + ex.getLineNumber() ;
            AppUtils.putError(errMessage);
        }
        
    }

    
    
    
      
    
}