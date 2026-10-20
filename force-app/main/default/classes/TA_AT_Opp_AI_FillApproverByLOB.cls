/**
 *  Author      :   Yusuf Ramadhan (yusuf.ramadhan@saasten.com)
 *  Purpose     :   Get Correctly Approver from LOB
 *  Test Class  :   TA_AT_Opp_AI_FillApproverByLOBTest
 *  Project     :   TSEL-2411-ReOrg and Approval Enhancement
 * 
 *  Date            PIC         Ticket          Brief of changes
 *  03/03/2025      Yusuf       APE-006         Initial Created
 *  25/03/2025      Yusuf       APE-006         Call Service method instead
 * 
 */
public with sharing class TA_AT_Opp_AI_FillApproverByLOB implements TriggerAction.AfterInsert {
    /**
     * GIVEN    :   Brand is populated
     * WHEN     :   Insert Opportunity
     * THEN     :   Get Correctly Approver from LOB based on Brand
     *
     * Requirements:
     * 1. Oppty has field Brand__c
     * 2. inside the Brand__c record they has LOB__c
     * 3. and its LOB__c record they has LOB_Group__c
     * 4. again in LOB_Group__c record they has Senior_Officer__c Lookup user, this field will be a value for Opportunity.Approval_1__c
     * 5. but if the Senior_Officer__c is blank we don't need to fill it or keep opportunity.Approval_1 blank
     * 6. next, we need query active user with Role name [GM Sales, VP, and DIRECTOR]
     * 7. Opportunity.Approval_2__c is User GM Sales
     * 8. Opportunity.Approval_1__c is User VP
     * 9. Opportunity.Approval_3__c is User DIRECTOR
     */
    public void afterInsert(List<Opportunity> newList) {
        System.debug('=== TA_AT_Opp_AI_FillApproverByLOB is Fired ===');
        if (newList.isEmpty()) return;
    
        
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
    
        // Load cached data from Singleton
        Map<Id, Id> brandToSO = TA_QR_Opportunity.getInstance().BrandToSeniorOfficerMap;
        Map<String, Id> userL234 = TA_QR_Opportunity.getInstance().ActiveUserRoleL234;

        String currentUserRole = [SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].UserRole.Name;
        System.debug('=== Current User Role: ' + currentUserRole + ' ===');

        Map<Id, String> oppIdToUserRole = new Map<Id, String>();
        for (Opportunity opp : newList) {
            oppIdToUserRole.put(opp.Id, currentUserRole);
        }
        
        if(!newList.isEmpty()){
            OpportunityService.populatingApproverBasedOnLOB(
                newList,
                null,
                brandToSO,
                userL234,
                oppIdToUserRole
            );
         }
        
        /*
        // Assign Approvers
        for (Opportunity anOppty : newList) {
            Opportunity oppToUpdate = new Opportunity(Id = anOppty.Id);
    
            // Ensure Approval_1__c is only populated if there's a valid Senior Officer and the user is NOT 'SALES SENIOR OFFICER
            if (anOppty.Brand__c != null && brandToSO.containsKey(anOppty.Brand__c) && currentUserRole != 'SALES SENIOR OFFICER') {
                oppToUpdate.Approval_1__c = brandToSO.get(anOppty.Brand__c);
                System.debug('=== Brand__c is populated and Approval_1__c is sucessfully filled ===');
            }
    
            // Assign Approval_2__c (GM SALES), Approval_3__c (VP), Approval_4__c (DIRECTOR)
            oppToUpdate.Approval_2__c = (userL234.containsKey('GM SALES') ? userL234.get('GM SALES') : null);
            oppToUpdate.Approval_3__c = (userL234.containsKey('VP') ? userL234.get('VP') : null);
            oppToUpdate.Approval_4__c = (userL234.containsKey('DIRECTOR') ? userL234.get('DIRECTOR') : null);
    
            oppsToUpdate.put(oppToUpdate.Id, oppToUpdate);
        }
    
        // Perform Bulk Update
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate.values();
        } */
    }
    
    
}