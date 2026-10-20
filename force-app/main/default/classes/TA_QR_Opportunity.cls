public without sharing class TA_QR_Opportunity {
    private static TA_QR_Opportunity instance;

    private TA_QR_Opportunity() {}

    public static TA_QR_Opportunity getInstance() {
        if (TA_QR_Opportunity.instance == null) {
            TA_QR_Opportunity.instance = new TA_QR_Opportunity();
        }
        return TA_QR_Opportunity.instance;
    }

    // Stores Brand → Senior Officer mappings (via LOB and LOB Group)
    public Map<Id, Id> BrandToSeniorOfficerMap { get; private set; }

    // Stores UserRole → Active User (GM Sales, VP, DIRECTOR)
    public Map<String, Id> ActiveUserRoleL234 { get; private set; }

    public class Service implements TriggerAction.BeforeInsert {
        public void beforeInsert(List<Opportunity> triggerNew) {
            System.debug('=== TA_QR_Opportunity is Fired ===');
            
            // Load Brand → Senior Officer
            TA_QR_Opportunity.getInstance().BrandToSeniorOfficerMap = getBrandToSeniorOfficerMap(triggerNew);

            // Load Active Users by Role
            TA_QR_Opportunity.getInstance().ActiveUserRoleL234 = getActiveUserRoleL234();
        }

        // Step 1: Query Brands → LOBs
        private Map<Id, Id> getBrandToSeniorOfficerMap(List<Opportunity> triggerNew) {
            System.debug('=== TA_QR_Opportunity 1 is Fired ===');
            Set<Id> brandIds = new Set<Id>();
            Map<Id, Id> brandToLOBGroupMap = new Map<Id, Id>();            
            Map<Id, Id> groupToSeniorOfficerMap = new Map<Id, Id>();

            // Collect all Brand__c IDs from Opportunities
            for (Opportunity opp : triggerNew) {
                if (opp.Brand__c != null) {
                    brandIds.add(opp.Brand__c);
                }
            }

            if (brandIds.isEmpty()) return new Map<Id, Id>();

            // Query Brand → LOB
            for (Brand__c brand : [
                SELECT Id, Brand_Category__c, Brand_Category__r.LOB_Group__c FROM Brand__c WHERE Id IN :brandIds AND Brand_Category__c != NULL
            ]) {
                brandToLOBGroupMap.put(brand.Id, brand.Brand_Category__r.LOB_Group__c);
            }


            // Step 2: Query LOB Group → Senior Officer

            for (LOB_Group__c lobGroup : [
                SELECT Id, Senior_Officer__c FROM LOB_Group__c WHERE Id IN :brandToLOBGroupMap.values() AND Senior_Officer__c != NULL
            ]) {
                groupToSeniorOfficerMap.put(lobGroup.Id, lobGroup.Senior_Officer__c);
            }

            // Step 4: Build Brand → Senior Officer Map
            Map<Id, Id> brandToSeniorOfficerMap = new Map<Id, Id>();

            for (Id brandId : brandToLOBGroupMap.keySet()) {
                Id seniorOfficerId = groupToSeniorOfficerMap.get(brandToLOBGroupMap.get(brandId));

                if (seniorOfficerId != null) {
                    brandToSeniorOfficerMap.put(brandId, seniorOfficerId);
                }
            }

            return brandToSeniorOfficerMap;
        }

        // Get Active Users in Roles ['GM Sales', 'VP', 'DIRECTOR']
        private Map<String, Id> getActiveUserRoleL234() {
            System.debug('=== TA_QR_Opportunity 2 is Fired ===');
            Map<String, Id> roleUserMap = new Map<String, Id>();

            for (User user : [
                SELECT Id, UserRole.Name FROM User 
                WHERE UserRole.Name IN ('GM SALES', 'VP', 'DIRECTOR') 
                AND IsActive = TRUE
            ]) {
                if (!roleUserMap.containsKey(user.UserRole.Name)) {
                    roleUserMap.put(user.UserRole.Name, user.Id);
                }
            }

            return roleUserMap;
        }
    }

    public class AfterUpdateService implements TriggerAction.BeforeUpdate {
        public void beforeUpdate(List<Opportunity> triggerNew, List<Opportunity> triggerOld) {
            System.debug('=== TA_QR_Opportunity Update is Fired ===');
            
            // Load Brand → Senior Officer
            TA_QR_Opportunity.getInstance().BrandToSeniorOfficerMap = getBrandToSeniorOfficerMap(triggerNew);

            // Load Active Users by Role
            TA_QR_Opportunity.getInstance().ActiveUserRoleL234 = getActiveUserRoleL234();
        }

        // Step 1: Query Brands → LOBs
        private Map<Id, Id> getBrandToSeniorOfficerMap(List<Opportunity> triggerNew) {
            System.debug('=== TA_QR_Opportunity Update 1 is Fired ===');
            Set<Id> brandIds = new Set<Id>();
            Map<Id, Id> brandToLOBGroupMap = new Map<Id, Id>();            
            Map<Id, Id> groupToSeniorOfficerMap = new Map<Id, Id>();

            // Collect all Brand__c IDs from Opportunities
            for (Opportunity opp : triggerNew) {
                if (opp.Brand__c != null) {
                    brandIds.add(opp.Brand__c);
                }
            }

            if (brandIds.isEmpty()) return new Map<Id, Id>();

            // Query Brand → LOB
            for (Brand__c brand : [
                SELECT Id, Brand_Category__c, Brand_Category__r.LOB_Group__c FROM Brand__c WHERE Id IN :brandIds AND Brand_Category__c != NULL
            ]) {
                brandToLOBGroupMap.put(brand.Id, brand.Brand_Category__r.LOB_Group__c);
            }


            // Step 2: Query LOB Group → Senior Officer
            for (LOB_Group__c lobGroup : [
                SELECT Id, Senior_Officer__c FROM LOB_Group__c WHERE Id IN :brandToLOBGroupMap.values() AND Senior_Officer__c != NULL
            ]) {
                groupToSeniorOfficerMap.put(lobGroup.Id, lobGroup.Senior_Officer__c);
            }

            // Step 4: Build Brand → Senior Officer Map
            Map<Id, Id> brandToSeniorOfficerMap = new Map<Id, Id>();

            for (Id brandId : brandToLOBGroupMap.keySet()) {
                Id seniorOfficerId = groupToSeniorOfficerMap.get(brandToLOBGroupMap.get(brandId));

                if (seniorOfficerId != null) {
                    brandToSeniorOfficerMap.put(brandId, seniorOfficerId);
                }
            }

            return brandToSeniorOfficerMap;
        }

        // Get Active Users in Roles ['GM Sales', 'VP', 'DIRECTOR']
        private Map<String, Id> getActiveUserRoleL234() {
            System.debug('=== TA_QR_Opportunity Update 2 is Fired ===');
            Map<String, Id> roleUserMap = new Map<String, Id>();

            for (User user : [
                SELECT Id, UserRole.Name FROM User 
                WHERE UserRole.Name IN ('GM SALES', 'VP', 'DIRECTOR') 
                AND IsActive = TRUE
            ]) {
                if (!roleUserMap.containsKey(user.UserRole.Name)) {
                    roleUserMap.put(user.UserRole.Name, user.Id);
                }
            }

            return roleUserMap;
        }
    }
}