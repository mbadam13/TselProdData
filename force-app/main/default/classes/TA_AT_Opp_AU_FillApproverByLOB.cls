/**
 *  Author      :   Yusuf Ramadhan (yusuf.ramadhan@saasten.com)
 *  Purpose     :   Get Correctly Approver from LOB
 *  Test Class  :   TA_AT_Opp_AU_FillApproverByLOBTest
 *  Project     :   TSEL-2411-ReOrg and Approval Enhancement
 * 
 *  Date            PIC         Ticket          Brief of changes
 *  25/03/2025      Yusuf       APE-006         Initial Created
 * 
 */
public with sharing class TA_AT_Opp_AU_FillApproverByLOB implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
        System.debug('=== TA_AT_Opp_AU_FillApproverByLOB is Fired ===');

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(oldList);
        Map<Id, Id> brandToSO = TA_QR_Opportunity.getInstance().BrandToSeniorOfficerMap;
        Map<String, Id> userL234 = TA_QR_Opportunity.getInstance().ActiveUserRoleL234;

        // Build a set of OwnerIds to query their roles
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity opp : newList) {
            ownerIds.add(opp.OwnerId);
        }

        // Query OwnerId → UserRole.Name
        Map<Id, String> ownerIdToRoleName = new Map<Id, String>();
        for (User u : [
            SELECT Id, UserRole.Name
            FROM User
            WHERE Id IN :ownerIds
        ]) {
            ownerIdToRoleName.put(u.Id, u.UserRole != null ? u.UserRole.Name : null);
        }

        System.debug('=== ownerIdToRoleName: '+ownerIdToRoleName);

        List<Opportunity> changedOpportunities = new List<Opportunity>();
        Map<Id, String> oppIdToOwnerRole = new Map<Id, String>();

        for (Opportunity newOpp : newList) {
            Opportunity oldOpp = oldMap.get(newOpp.Id);

            Boolean brandChanged = newOpp.Brand__c != oldOpp.Brand__c;
            Boolean ownerChanged = newOpp.OwnerId != oldOpp.OwnerId;

            if (brandChanged || ownerChanged) {
                changedOpportunities.add(newOpp);
                oppIdToOwnerRole.put(newOpp.Id, ownerIdToRoleName.get(newOpp.OwnerId));
            }
        }

        if (!changedOpportunities.isEmpty()) {
            OpportunityService.populatingApproverBasedOnLOB(
                changedOpportunities,
                oldMap,
                brandToSO,
                userL234,
                oppIdToOwnerRole
            );
        }
    }
}