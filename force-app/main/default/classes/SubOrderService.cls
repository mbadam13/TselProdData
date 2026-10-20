/**
 * @description       : 
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 03-26-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SubOrderService {

    public static void handleSubOrderApprovals(List<Id> orderIds) {
        try {
            if (orderIds == null || orderIds.isEmpty()) {
                System.debug('No Order IDs provided.');
                return;
            }

            // Query untuk mendapatkan semua Sub Orders yang terkait dengan Order(s)
            List<Sub_Order__c> subOrders = [SELECT Id, Approval_Status__c, Order__c 
                                            FROM Sub_Order__c 
                                            WHERE Order__c IN :orderIds];

            if (!subOrders.isEmpty()) {
                List<Id> subOrderIds = new List<Id>();
                for (Sub_Order__c so : subOrders) {
                    subOrderIds.add(so.Id);
                }

                // Query untuk mendapatkan approval instances yang masih pending
                List<ProcessInstance> processInstances = [SELECT Id, TargetObjectId 
                                                          FROM ProcessInstance 
                                                          WHERE TargetObjectId IN :subOrderIds 
                                                          AND Status = 'Pending'];

                // Map untuk mengecek Sub Orders yang memiliki approval process
                Set<Id> subOrdersWithApproval = new Set<Id>();
                for (ProcessInstance instance : processInstances) {
                    subOrdersWithApproval.add(instance.TargetObjectId);
                }

                List<Sub_Order__c> subOrdersToUpdate = new List<Sub_Order__c>();

                for (Sub_Order__c subOrder : subOrders) {
                    if (subOrdersWithApproval.contains(subOrder.Id)) {
                        // Jika ada approval instance, reject approval process
                        rejectApprovalProcess(subOrder.Id);
                        subOrder.Is_Active__c = false; 
                        subOrder.Approval_Status__c = 'Rejected';
                        subOrdersToUpdate.add(subOrder);
                    } else {
                        if (subOrder.Approval_Status__c != 'Rejected') {
                            subOrder.Approval_Status__c = 'Rejected';
                            subOrder.Is_Active__c = false; 
                            subOrdersToUpdate.add(subOrder);
                        }
                    }
                }

                // Update semua sub order yang tidak memiliki approval instance
                if (!subOrdersToUpdate.isEmpty()) {
                    update subOrdersToUpdate;
                    System.debug('Sub Orders have been marked as Rejected.');
                }
            }
        } catch (Exception e) {
            System.debug('Error handling Sub Order approvals: ' + e.getMessage());
        }
    }

    /**
     * Method untuk menolak approval process pada Sub Order.
     * @param subOrderId - ID dari Sub Order yang memiliki approval process.
     */
    private static void rejectApprovalProcess(Id subOrderId) {
        try {
            // Query untuk mendapatkan Work Item ID dari approval instance
            ProcessInstanceWorkItem workItem = [SELECT Id FROM ProcessInstanceWorkItem 
                                                WHERE ProcessInstance.TargetObjectId = :subOrderId
                                                LIMIT 1];
    
            if (workItem != null) {
                // Membuat request untuk reject approval
                Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
                req.setWorkItemId(workItem.Id);
                req.setComments('Rejected Because ACW');
                req.setAction('Reject');
    
                // Submit rejection request
                Approval.ProcessResult result = Approval.process(req);
    
                if (result.isSuccess()) {
                    System.debug('Approval rejected successfully for Sub Order: ' + subOrderId);
                } else {
                    System.debug('Failed to reject approval: ' + result);
                }
            }
        } catch (Exception e) {
            System.debug('Error rejecting Sub Order approval: ' + e.getMessage());
        }
    }
    
    

    public static void generateSubOrders(List<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            System.debug('No Order IDs provided.');
            return;
        }
    
        // Ambil OrderItem beserta PIC Product dari Product2
        List<OrderItem> orderItems = [
            SELECT Id, OrderId, Product2.PIC_Product__c, Product2.PIC_Product_Type__c
            FROM OrderItem
            WHERE OrderId IN :orderIds AND Product2.PIC_Product__c != null
        ];
    
        if (orderItems.isEmpty()) {
            System.debug('No OrderItems found for provided Order IDs.');
            return;
        }
    
        // Kumpulkan nama unik PIC Product dari Product2
        Set<String> picNames = new Set<String>();
        for (OrderItem oi : orderItems) {
            picNames.add(oi.Product2.PIC_Product__c);
        }
    
        // Query User berdasarkan nama PIC dari Product2
        List<User> users = [SELECT Id, Name FROM User WHERE Name IN :picNames];
    
        // Mapping nama User ke Id
        Map<String, Id> userMap = new Map<String, Id>();
        for (User u : users) {
            userMap.put(u.Name, u.Id);
        }
    
        // Tracking PIC User yang sudah diproses per Order
        Map<Id, Set<Id>> processedPICPerOrder = new Map<Id, Set<Id>>();
    
        List<Sub_Order__c> subOrdersToInsert = new List<Sub_Order__c>();
    
        for (OrderItem oi : orderItems) {
            String picName = oi.Product2.PIC_Product__c;
            Id managerId = userMap.get(picName);
    
            if (managerId != null) {
                // Cek apakah Order sudah ada dalam map, jika belum, inisialisasi Set baru
                if (!processedPICPerOrder.containsKey(oi.OrderId)) {
                    processedPICPerOrder.put(oi.OrderId, new Set<Id>());
                }
    
                // Cek apakah PIC sudah diproses dalam Order tersebut
                if (!processedPICPerOrder.get(oi.OrderId).contains(managerId)) {
                    Sub_Order__c subOrder = new Sub_Order__c();
                    subOrder.Manager_Approval__c = managerId;
                    subOrder.Approval_Status__c = 'Submit';
                    subOrder.Order__c = oi.OrderId;
                    subOrder.Is_Active__c = true;
    
                    subOrdersToInsert.add(subOrder);
    
                    // Tandai User sudah diproses untuk Order tersebut
                    processedPICPerOrder.get(oi.OrderId).add(managerId);
                }
            }
        }
    
        // Insert semua Sub Orders sekaligus
        if (!subOrdersToInsert.isEmpty()) {
            insert subOrdersToInsert;
            System.debug('Sub Orders inserted successfully.');
        } else {
            System.debug('No Sub Orders to insert.');
        }

    }

    public static void generateSubOrders_V2(List<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            System.debug('No Order IDs provided.');
            return;
        }
    
        // Ambil OrderItem beserta PIC Product dari Product2
        List<OrderItem> orderItems = [
            SELECT Id, OrderId, Product2.PIC_Product__c, Product2.PIC_Product_Type__c
            FROM OrderItem
            WHERE OrderId IN :orderIds AND Product2.PIC_Product__c != null
        ];
    
        if (orderItems.isEmpty()) {
            System.debug('No OrderItems found for provided Order IDs.');
            return;
        }
    
        // Kumpulkan nama unik PIC Product dari Product2
        Set<String> picNames = new Set<String>();
        for (OrderItem oi : orderItems) {
            picNames.add(oi.Product2.PIC_Product__c);
        }
    
        // Query User berdasarkan nama PIC dari Product2
        List<User> users = [SELECT Id, Name FROM User WHERE Name IN :picNames];
    
        // Mapping nama User ke Id
        Map<String, Id> userMap = new Map<String, Id>();
        for (User u : users) {
            userMap.put(u.Name, u.Id);
        }
    
        // Query existing Sub Orders yang sudah Approved
        List<Sub_Order__c> existingApprovedSubs = [
            SELECT Id, Order__c, Manager_Approval__c
            FROM Sub_Order__c
            WHERE Order__c IN :orderIds AND 
            (Approval_Status__c = 'Approved' OR Approval_Status__c = 'Submit')
        ];
    
        // Buat Set untuk mengecek apakah kombinasi Order + Manager sudah ada dan Approved
        Set<String> approvedKeys = new Set<String>();
        for (Sub_Order__c sub : existingApprovedSubs) {
            approvedKeys.add(sub.Order__c + '-' + sub.Manager_Approval__c);
        }
    
        // Tracking PIC User yang sudah diproses per Order
        Map<Id, Set<Id>> processedPICPerOrder = new Map<Id, Set<Id>>();
    
        List<Sub_Order__c> subOrdersToInsert = new List<Sub_Order__c>();
    
        for (OrderItem oi : orderItems) {
            String picName = oi.Product2.PIC_Product__c;
            Id managerId = userMap.get(picName);
    
            if (managerId != null) {
                String key = oi.OrderId + '-' + managerId;
    
                // Lewati jika sudah ada Sub Order yang approved untuk Order + Manager ini
                if (approvedKeys.contains(key)) {
                    continue;
                }
    
                if (!processedPICPerOrder.containsKey(oi.OrderId)) {
                    processedPICPerOrder.put(oi.OrderId, new Set<Id>());
                }
    
                if (!processedPICPerOrder.get(oi.OrderId).contains(managerId)) {
                    Sub_Order__c subOrder = new Sub_Order__c();
                    subOrder.Manager_Approval__c = managerId;
                    subOrder.Approval_Status__c = 'Submit';
                    subOrder.Order__c = oi.OrderId;
                    subOrder.Is_Active__c = true;
    
                    subOrdersToInsert.add(subOrder);
    
                    processedPICPerOrder.get(oi.OrderId).add(managerId);
                }
            }
        }
    
        if (!subOrdersToInsert.isEmpty()) {
            insert subOrdersToInsert;
            System.debug('Sub Orders inserted successfully.');
        } else {
            System.debug('No Sub Orders to insert.');
        }
    }
    
    
}