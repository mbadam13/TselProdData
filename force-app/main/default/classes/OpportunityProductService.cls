/**
 * @description       :
 * @author            : Doddy Prima
 * @group             :
 * @last modified on  : 27/03/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   -            Doddy Prima       Initial Version
 * 2.0   11/02/2025   Syaiful Syafani   Add method 'getOpptyProduct'
 * 3.0   20/02/2025   Syaiful Syafani   Add method 'CheckBusinessProduct'
 * 3.1   26/02/2025   Yusuf Ramadhan    Add method 'calculateDiscountForTV' and 'calculateDisCountForDIGITAL' 
 * 3.2   03/03/2025   Yusuf Ramadhan    Add method 'calculateACWApprovalPath'
 * 3.3   06/05/2025   Yusuf Ramadhan    fix processDiscountApproval to add the OldApp_Path_No__c
 **/
public with sharing class OpportunityProductService {
    public static List<Usage__c> getUsagesOfProduct(ID opportunityProductID) {
        List<Usage__c> usageList = new List<Usage__c>();

        ID opportunityID = null;
        //ID opportunityProductID = '00k2u000002fnuKAAQ'; get from parameter
        ID productID = null;
        ID bucketDetailID = null;

        /* TUTUP DULU */
        //get opportunityID
        /*
        opportunityLineItem oliRec = [
            SELECT 
                id, opportunityid, product2ID, product2.name  
            FROM 
                opportunityLineItem 
            WHERE 
                id = :opportunityProductID
        ];
        System.debug ('=== oliRec : ' + oliRec);
        */

        /*

        opportunityID = oliRec.opportunityid;
        productID = oliRec.product2ID;

        //get orderItem that relate to opportunity and product
        List<OrderItem> orderItemList = [
            SELECT 
                id, order.name, product2.name 
            FROM 
                OrderItem
            WHERE 
                Opportunity__c = :opportunityID
                AND Opportunity_Product__c = :opportunityProductID
        ];
        System.debug ('=== orderItemList : ' + orderItemList);


        if (orderItemList.size() > 0) {
            bucketDetailID = orderItemList[0].id;

            usageList = [
                SELECT ID, name, date__c 
                FROM 
                    Usage__c
                WHERE 
                    Bucket_Detail__c = :bucketDetailID
            ];
            
            Integer usagesCount = usageList.size();

            System.debug ('=== usagesCount : ' + usagesCount);
            System.debug ('=== usageList : ' + usageList);

            /*
            if ( usagesCount > 0 ) {
                //add.error
                System.debug ('=== Cannot Update/Delete the product because this product is avalaible the usage');
            }
        }
        */

        usageList = [
            SELECT ID, name, date__c
            FROM Usage__c
            WHERE Bucket_Detail__r.opp_product_id__c = :opportunityProductID
        ];

        Integer usagesCount = usageList.size();

        System.debug('=== usagesCount : ' + usagesCount);
        System.debug('=== usageList : ' + usageList);

        return usageList;
    }

    public static List<OpportunityLineItem> getOpptyProduct(Id opportunityID) {
        List<OpportunityLineItem> opptyProductList = [
            SELECT Id
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityID
        ];

        return opptyProductList;
    }

    /* tidak digunakan lg
    public static void CheckBusinessProduct(Set<Id> opptyIds){
        System.debug('=== OpportunityProductService.ProductTV ===');

        List<Opportunity> opptyList = [
            SELECT 
                Id,
                Digital_Media_Products__c,
                TV_Media_Products__c,
                Penagihan_based_on__c,
                Penagihan_based_on_TV__c
            FROM 
                Opportunity
            WHERE 
                ID IN :opptyIds
        ];
        System.debug('== opptyList: '+ opptyList);

        List<Opportunity> updateOpptyList = new List<Opportunity>();
        for (Opportunity opptyRec : opptyList) {
            if (opptyRec.Digital_Media_Products__c == 0 && (opptyRec.TV_Media_Products__c == 0 || opptyRec.TV_Media_Products__c >= 0)) { // ini masuk ke tv media
                opptyRec.Type = 'Existing Business';
                opptyRec.Penagihan_based_on_TV__c = 'PostPaid';
                opptyRec.Penagihan_based_on_TV__c = '';
                updateOpptyList.add(opptyRec);
            }
        }

        if (!updateOpptyList.isEmpty()) {
            update updateOpptyList;
        }
    }
    */
    
    public static Map<Id, Integer> calculateDiscountForTV(Set<OpportunityLineItem> TVOLIRecordsToBeCalculate, Map<Id, Product2> productMap) {
        Map<Id, Integer> AppPathNoTV_Result = new Map<Id, Integer>();
        /*
         *
         * Path No 1 : {!$Record.Discount__c} <= {!$Record.Product2.IPTV_Max_Disc__c}
         * Path No 2 : {!$Record.Discount__c} > {!$Record.Product2.IPTV_Max_Disc__c} && {!$Record.Discount_2__c} <= {!$Record.Product2.RDM__c} && {!$Record.Discount_2__c} <= 30
         * Path No 3 : {!$Record.Discount__c} > {!$Record.Product2.IPTV_Max_Disc__c} && {!$Record.Discount_2__c} <= {!$Record.Product2.RDM__c} && {!$Record.Discount_2__c} > 30
         * Path No 4 : {!$Record.Discount__c} > {!$Record.Product2.IPTV_Max_Disc__c} && {!$Record.Discount_2__c} > {!$Record.Product2.RDM__c}
         * 
         */
    
        System.debug('=== 1. Processing ' + TVOLIRecordsToBeCalculate.size() + ' TV Media OLIs ===');
    
        for (OpportunityLineItem oli : TVOLIRecordsToBeCalculate) {
            System.debug('=== 2. Processing OLI: ' + oli.Id + ' ===');
    
            // Ensure the Product2 data exists
            Product2 product = productMap.get(oli.Product2Id);
            if (product == null) {
                System.debug('=== 2.1. Skipping OLI: ' + oli.Id + ' - Product2 not found ===');
                continue; // Skip if product is not found
            }
    
            // Retrieve discount thresholds
            Decimal maxDisc = product.IPTV_Max_Disc__c;
            Decimal rdm = product.RDM__c;
            Decimal discount1 = oli.Discount__c;
            Decimal discount2 = oli.Discount_2__c;
    
            // Log retrieved values
            System.debug('=== 3. OLI ' + oli.Id + ' - Max Disc: ' + maxDisc + ', RDM: ' + rdm + ', Discount1: ' + discount1 + ', Discount2: ' + discount2 + ' ===');
    
            // Ensure discounts are not null
            if (discount1 == null) discount1 = 0;
            if (discount2 == null) discount2 = 0;
    
            // Determine Approval Path (Only store valid values: 1, 2, 3, or 4)
            Integer pathNumber = null;
            if (discount1 <= maxDisc) {
                pathNumber = 1;
            } else if (discount1 > maxDisc && discount2 <= rdm && discount2 <= 30) {
                pathNumber = 2;
            } else if (discount1 > maxDisc && discount2 <= rdm && discount2 > 30) {
                pathNumber = 3;
            } else if (discount1 > maxDisc && discount2 > rdm) {
                pathNumber = 4;
            } else {
                System.debug('=== 4. No matching condition for OLI ' + oli.Id + ' - Check values ===');
            }
    
            // Store in the result map if valid
            if (pathNumber != null) {
                AppPathNoTV_Result.put(oli.Id, pathNumber);
                System.debug('=== 5. OLI ' + oli.Id + ' - Assigned Approval Path: ' + pathNumber + ' ===');
            }
        }
    
        System.debug('=== 6. Final TV Discount Approval Paths: ' + AppPathNoTV_Result + ' ===');
    
        return AppPathNoTV_Result;
    }

    public static Map<Id, Integer> calculateDisCountForDIGITAL(Set<OpportunityLineItem> DIGITALOLIRecordsToBeCalculate) {
        Map<Id, Integer> AppPathNoDIGITAL_Result = new Map<Id, Integer>();
    
        System.debug('=== 1. Processing ' + DIGITALOLIRecordsToBeCalculate.size() + ' Digital Media OLIs ===');
    
        for (OpportunityLineItem oli : DIGITALOLIRecordsToBeCalculate) {
            System.debug('=== 2. Processing OLI: ' + oli.Id + ' ===');
    
            Decimal discount = oli.Discount__c;
    
            // Ensure discount is not null
            if (discount == null) discount = 0;
    
            System.debug('=== 3. OLI ' + oli.Id + ' - Discount: ' + discount + ' ===');
    
            Integer pathNumber = null;
            if (discount == 0) {
                pathNumber = 1;
            } else if (discount > 0 && discount <= 30) {
                pathNumber = 2;
            } else if (discount > 30 && discount <= 80) {
                pathNumber = 3;
            } else if (discount > 80 && discount <= 100) {
                pathNumber = 4;
            } else {
                System.debug('=== 4. No matching condition for OLI ' + oli.Id + ' - Check discount value ===');
            }
    
            if (pathNumber != null) {
                AppPathNoDIGITAL_Result.put(oli.Id, pathNumber);
                System.debug('=== 5. OLI ' + oli.Id + ' - Assigned Approval Path: ' + pathNumber + ' ===');
            }
        }
    
        System.debug('=== 6. Final Digital Discount Approval Paths: ' + AppPathNoDIGITAL_Result + ' ===');
    
        return AppPathNoDIGITAL_Result;
    }
    

     /**
     * This method replicates the OpptyACW_Calculation Flow logic in Apex.
     * Determines the ACW Approval Path based on Old and Current Approval Path numbers.
     */
    public static Integer calculateACWApprovalPath(OpportunityLineItem oli) {
        System.debug('=== Start calculateACWApprovalPath ===');
    
        Integer newApprovalPath;
    
        // Determine which path to use based on Business_Product__c
        Decimal currentPathRaw;
        if (oli.Business_Product__c == 'Digital Media') {
            currentPathRaw = oli.App_Path_No_Digital__c;
            System.debug('=== Using App_Path_No_Digital__c for current path ===');
        } else {
            currentPathRaw = oli.App_Path_No__c;
            System.debug('=== Using App_Path_No__c for current path ===');
        }
    
        if (currentPathRaw == null || oli.OldApp_Path_No__c == null) {
            System.debug('=== Skipping: one of the paths is null ===');
            return null;
        }
    
        Integer current = Integer.valueOf(currentPathRaw);
        Integer old = Integer.valueOf(oli.OldApp_Path_No__c);
    
        System.debug('=== Current: ' + current + ', Old: ' + old + ', Product: ' + oli.Business_Product__c + ' ===');
    
        // Match logic from Flow "Go to Whom"
        if (current == 1 && (old == 1 || old == 2 || old == 3 || old == 4)) {
            newApprovalPath = 1;
            System.debug('=== Assigned Path: 1 (Manager) ===');
        } else if (current == 2 && (old == 1 || old == 2 || old == 3 || old == 4)) {
            newApprovalPath = 2;
            System.debug('=== Assigned Path: 2 (Manager > GM) ===');
        } else if (current == 3 && (old == 1 || old == 2 || old == 4)) {
            newApprovalPath = 3;
            System.debug('=== Assigned Path: 3 (Manager > GM > VP) ===');
        } else if (current == 4 && (old == 1 || old == 2 || old == 3)) {
            newApprovalPath = 4;
            System.debug('=== Assigned Path: 4 (Manager > GM > VP > DIR) ===');
        } else if ((current == 3 && old == 3) || (current == 4 && old == 4)) {
            newApprovalPath = 2;
            System.debug('=== Assigned Path: 2 (Downgrade from Same Level) ===');
        } else {
            newApprovalPath = current;
            System.debug('=== Default Fallback Path: ' + newApprovalPath + ' ===');
        }
    
        System.debug('=== Final Approval Path Returned: ' + newApprovalPath + ' ===');
        return newApprovalPath;
    }
    
    
    

    /**
     * Purpose: TA_AT_OLI_AU_CalculationDiskon, TA_AT_AI_OLI_AU_CalculationDiskon
     * 
     */
    public static void processDiscountApproval(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap) {
        System.debug('=== 1. Start processDiscountApproval - Processing ' + newList.size() + ' records ===');
    
        Map<Id, Integer> discountTVResults = new Map<Id, Integer>();
        Map<Id, Integer> discountDIGITALResults = new Map<Id, Integer>();
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> oliIdsToUpdate = new Set<Id>();
        Set<OpportunityLineItem> TVOLIRecordsToBeCalculate = new Set<OpportunityLineItem>();
        Set<OpportunityLineItem> DIGITALOLIRecordsToBeCalculate = new Set<OpportunityLineItem>();

        try {
            // Collect Product2 IDs for querying Business_Product__c
            for (OpportunityLineItem anOLI : newList) {
                Boolean shouldProcess = oldMap == null || !oldMap.containsKey(anOLI.Id) 
                    || oldMap.get(anOLI.Id).Discount <> anOLI.Discount 
                    || oldMap.get(anOLI.Id).Discount__c <> anOLI.Discount__c 
                    || oldMap.get(anOLI.Id).UnitPrice <> anOLI.UnitPrice 
                    || oldMap.get(anOLI.Id).Product2Id <> anOLI.Product2Id
                    || oldMap.get(anOLI.Id).Quantity <> anOLI.Quantity 
                    || oldMap.get(anOLI.Id).OldApp_Path_No__c <> anOLI.OldApp_Path_No__c;
        
                if (shouldProcess) {
                    System.debug('=== 2. Processing OLI: ' + anOLI.Id + ', Product2Id=' + anOLI.Product2Id + ' ===');
                    productIds.add(anOLI.Product2Id);
                }
            }
        
            // Query Product2 to get Business_Product__c
            if (!productIds.isEmpty()) {
                System.debug('=== 3. Querying Product2 for ' + productIds.size() + ' products ===');
                productMap = new Map<Id, Product2>(
                    [SELECT Id, IPTV_Max_Disc__c, RDM__c, Business_Product__c FROM Product2 WHERE Id IN :productIds]
                );
            }
        
            // Process OLIs after fetching Business_Product__c from Product2
            for (OpportunityLineItem anOLI : newList) {
                if (productMap.containsKey(anOLI.Product2Id)) {
                    Product2 relatedProduct = productMap.get(anOLI.Product2Id);
                    System.debug('=== 5. Processing OLI: ' + anOLI.Id + ', Business_Product__c=' + relatedProduct.Business_Product__c + ' ===');
        
                    // Special Handling for Adjustment (ACW)
                    if (anOLI.Opportunity.Has_Adjustment_After_Close_Won__c) {
                        Integer acwApprovalPath = OpportunityProductService.calculateACWApprovalPath(anOLI);
                        System.debug('=== 6. ACW Adjustment - Setting ACW_App_Path_No__c=' + acwApprovalPath + ' ===');
                        if (acwApprovalPath != null) {
                            oliIdsToUpdate.add(anOLI.Id);
                        }
                    } else {
                        if (relatedProduct.Business_Product__c == 'TV Media') {
                            System.debug('=== 7. TV Media Product Found - OLI: ' + anOLI.Id + ' ===');
                            TVOLIRecordsToBeCalculate.add(anOLI);
                        } else if (relatedProduct.Business_Product__c == 'Digital Media') {
                            System.debug('=== 8. Digital Media Product Found - OLI: ' + anOLI.Id + ' ===');
                            DIGITALOLIRecordsToBeCalculate.add(anOLI);
                        }
                    }
                }
            }
        
            // Calculate approval path for TV & Digital Media
            if (!TVOLIRecordsToBeCalculate.isEmpty()) {
                System.debug('=== 10. Calculating Discount Approval Path for TV Media - ' + TVOLIRecordsToBeCalculate.size() + ' records ===');
                discountTVResults = OpportunityProductService.calculateDiscountForTV(TVOLIRecordsToBeCalculate, productMap);
            }
        
            if (!DIGITALOLIRecordsToBeCalculate.isEmpty()) {
                System.debug('=== 11. Calculating Discount Approval Path for Digital Media - ' + DIGITALOLIRecordsToBeCalculate.size() + ' records ===');
                discountDIGITALResults = OpportunityProductService.calculateDiscountForDIGITAL(DIGITALOLIRecordsToBeCalculate);
            }
        
            // Collect OLIs to update
            oliIdsToUpdate.addAll(discountTVResults.keySet());
            oliIdsToUpdate.addAll(discountDIGITALResults.keySet());
        
            if (!oliIdsToUpdate.isEmpty()) {
                System.debug('=== 12. Querying OLIs for update ===');
                List<OpportunityLineItem> oliUpdates = [
                    SELECT Id, Business_Product__c, App_Path_No__c, App_Path_No_Digital__c, ACW_App_Path_No__c, OldApp_Path_No__c, OpportunityId, Opportunity.Has_Adjustment_After_Close_Won__c 
                    FROM OpportunityLineItem 
                    WHERE Id IN :oliIdsToUpdate
                ];
        
                for (OpportunityLineItem oli : oliUpdates) {
                    if (discountTVResults.containsKey(oli.Id)) {
                        System.debug('=== 13. Updating App_Path_No__c for OLI: ' + oli.Id + ' → ' + discountTVResults.get(oli.Id) + ' ===');
                        oli.App_Path_No__c = discountTVResults.get(oli.Id);
                    }
        
                    if (discountDIGITALResults.containsKey(oli.Id)) {
                        System.debug('=== 14. Updating App_Path_No_Digital__c for OLI: ' + oli.Id + ' → ' + discountDIGITALResults.get(oli.Id) + ' ===');
                        oli.App_Path_No_Digital__c = discountDIGITALResults.get(oli.Id);
                    }

                    if (oli.Opportunity.Has_Adjustment_After_Close_Won__c) {
                        Integer acwApprovalPath = OpportunityProductService.calculateACWApprovalPath(oli);
                        System.debug('=== Updating ACW_App_Path_No__c for OLI: ' + oli.Id + ' → ' + acwApprovalPath + ' ===');
                        oli.ACW_App_Path_No__c = acwApprovalPath;
                    }
                }
        
                // Perform bulk update
                if (!oliUpdates.isEmpty()) {
                    System.debug('=== 15. Performing bulk update for ' + oliUpdates.size() + ' records ===');
                    update oliUpdates;
                }
            } else {
                System.debug('=== 16. No updates required ===');
            }
        
            System.debug('=== 17. Finished processDiscountApproval ===');
        }
        catch (Exception ex) {
            System.debug('=== 18. Exception:'+ex.getmessage());
            String errMessage = 'Error on TA_AT_OLI_AU_CalculationDiskon afterUpdate function::' + ex.getmessage() + '::' + ex.getLineNumber() ;
            AppUtils.putError(errMessage);
        }
    
        
    }
    
    
    
}