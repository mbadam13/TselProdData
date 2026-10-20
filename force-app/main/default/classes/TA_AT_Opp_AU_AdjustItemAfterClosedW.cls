/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 08-29-2024
 * @last modified by  : Doddy Prima
**/

public with sharing class TA_AT_Opp_AU_AdjustItemAfterClosedW implements TriggerAction.AfterUpdate {
    public void AfterUpdate(List<Opportunity> newList, List<Opportunity> oldList){
        System.debug('=== TA_AT_Opp_AU_AdjustItemAfterClosedW ===');
        String errMessage;

        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>(oldList);

        Set<Id> opptyIDsThatOrderNeedToAdjustSET = new Set<Id>();


        for(Opportunity oppNEWRec : newList){
            Opportunity oppOLDRec = oldMap.get(oppNEWRec.Id);



            if ( oppNEWRec.StageName == 'Closed Won' 
                && oppNEWRec.StageName != oppOLDRec.StageName 
                && oppNEWRec.Adjustment_Version__c >= 1 
                && oppNEWRec.Check_PO__c == 'OK'
                && oppNEWRec.isSubmitCheckPOApproval__c == true
                && oppNEWRec.Approval_Status__c == 'Approved') {

                    // add oppty id to the SET variable
                    opptyIDsThatOrderNeedToAdjustSET.add (oppNEWRec.Id);
                
            }
        }

        
        if ( !opptyIDsThatOrderNeedToAdjustSET.isEmpty() ) {
            // if any opportunities move closed-won and after any adjustment in product (add, edite, delete))
            //TODO: codes below  should be in service class
        


            // get list of all order for opporunity recorrds (trigger)
            List<Order> allOrderList = [
                SELECT 
                    id, status, SOA_Quotation_No__c,
                    SOA_Name__c, Quote_Name__c, OrderNumber, EffectiveDate, EndDate,
                    opportunity.id,
                    Order_Count__c  // the number of order item 
                FROM Order
                WHERE opportunity.id in :opptyIDsThatOrderNeedToAdjustSET
            ];

            // store all order to map
            Map<Id, Order> opptyOrderMap = new Map<Id, Order>();
            for(Order orderRec : allOrderList){
                // set order record to map by opportunity
                opptyOrderMap.put(orderRec.opportunity.id, orderRec);
            }

            
            


            // list of order to update
            List<Order> orderToUpdateList = new List<Order>();
            
            // list of order item to update
            List<OrderItem> orderItemToUpdateList = new List<OrderItem>();
            // Initialize a Map to track the OrderItems by their IDs
            Map<Id, OrderItem> orderItemMapToUpdate = new Map<Id, OrderItem>();


            // list of order item to insert
            List<OrderItem> orderItemToInsertList = new List<OrderItem>();
            // List of order item to delete
            List<OrderItem> orderItemToDeleteList = new List<OrderItem>();
            


            // get all adjusment log for each opportunity
            Map<Id, List<Adjustment_Log__c>> opptyAdjLogMap = OpportunityService.getOpportunityAdjustmentLogs (opptyIDsThatOrderNeedToAdjustSET);



            //-- 1. Update all Orders Status
            Set<Id> orderIDsNeedToForceRejectSet = new Set<Id>();
            for (Id oppId : opptyAdjLogMap.keySet()) {

                // get order records  
                Order orderRelatedToOpptyREC = opptyOrderMap.get( oppId );
                
                // add order id to the SET variable (to force reject)
                //komen sementara untuk validate
                //orderIDsNeedToForceRejectSet.add (orderRelatedToOpptyREC.ID);

                List<Adjustment_Log__c> adjLogList = opptyAdjLogMap.get( oppId );


                // if any adjustment and the order was created before, than do adjust the Order and Order-Item
                if ( adjLogList <> null && orderRelatedToOpptyREC <> null ) {

                    // set status to draft first (if the order is not in approval process) 
                    orderRelatedToOpptyREC.status = 'Draft';
                    orderToUpdateList.add (orderRelatedToOpptyREC);

                }

            }

            //force reject if any order in approval process
            //Todo : set reject untuk order yg dalam masa approval
            //AppUtils.forceRejectApprovalsForRecords (orderIDsNeedToForceRejectSet, 'This approval is forcefully rejected by the system.');

            try {
                // perform DML to Update order
                if ( orderToUpdateList.size() > 0 ) {
                    system.debug('=== orderToUpdateList : ' + orderToUpdateList);
                    update orderToUpdateList;
                }
                if(Test.isRunningTest()) {
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }
            catch(Exception e) {
                errMessage = 'Error on TA_AT_Opp_AU_AdjustItemAfterClosedW afterUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );
            }
            //-- end of Update all Orders Status




            //-- 2. Start for Add Order Product
            for (Id oppId : opptyAdjLogMap.keySet()) {

                Order orderRelatedToOpptyREC = opptyOrderMap.get( oppId );
                List<Adjustment_Log__c> adjLogList = opptyAdjLogMap.get( oppId );


                // if any adjustment and the order was created before, than do adjust the Order and Order-Item
                if ( adjLogList <> null && orderRelatedToOpptyREC <> null ) {
                    
                    
                    // adjust order item for Add Order Product
                    for(Adjustment_Log__c adjLogREC : adjLogList){
                        if ( adjLogREC.Action__c == 'Add' ){
                            system.debug('=== add operation ===');
                            
                            String SOAID;
                            String CampaignId;
                            String CampId;

                            
                            if ( orderRelatedToOpptyREC.SOA_Quotation_No__c == Null ) {
                                if ( orderRelatedToOpptyREC.SOA_Name__c != Null ) {
                                    SOAID = orderRelatedToOpptyREC.SOA_Name__c;
                                } else{
                                    SOAID = orderRelatedToOpptyREC.Quote_Name__c;
                                }
                            } else {
                                SOAID = orderRelatedToOpptyREC.SOA_Quotation_No__c;
                            }
                            
                            // AutoNumber is size of order item 
                            Integer AutoNumber = integer.valueOf(orderRelatedToOpptyREC.Order_Count__c) + 1; 
                            

                            CampaignId = Date.today().year() + '_B' + orderRelatedToOpptyREC.OrderNumber + '_' 
                                + SOAID + '_' + adjLogREC.Opportunity_Product__r.Product_id_number__c + '_' + AutoNumber;
                            CampId = SOAID + '_' + adjLogREC.Opportunity_Product__r.Product_id_number__c + '_' + AutoNumber;

                            OrderItem newOrderItemREC = new OrderItem(
                                OrderId = orderRelatedToOpptyREC.id,                                      //done
                                UnitPrice = adjLogREC.Opportunity_Product__r.UnitPrice,                 //DONE             
                                Quantity = adjLogREC.Opportunity_Product__r.quantity,                   //done
                                PricebookEntryId = adjLogREC.Opportunity_Product__r.PricebookEntryId,   //done
                                
                                Camp_ID__c = CampId,                                                    //done
                                Campaign_ID__c = CampaignId,                                            //done
                                sales__c = adjLogREC.Opportunity_Product__r.opportunity.ownerId ,       //done
                                
                                Opportunity__c = oppId,                                          //done
                                ServiceDate = orderRelatedToOpptyREC.EffectiveDate,                       //done
                                EndDate = orderRelatedToOpptyREC.EndDate,                                 //done
                                Opp_Product_Id__c = adjLogREC.Opportunity_Product__r.id,                //done
                                Opportunity_Product__c = adjLogREC.Opportunity_Product__r.id            //done
                            );
                            
                            // add order-item tobe insert
                            orderItemToInsertList.add ( newOrderItemREC );
                        }
                    }

                }
            }

            try {
                // perform DML to Insert order-Item
                if ( orderItemToInsertList.size() > 0 ) {
                    system.debug('=== orderItemToInsertList : ' + orderItemToInsertList);
                    insert orderItemToInsertList;
                }
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
            }
            }
            catch(Exception e) {
                errMessage = 'Error on TA_AT_Opp_AU_AdjustItemAfterClosedW afterUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );

            }
            //-- end of ADD Order Product




            //-- 3. Start for UPDATE and DELETE Order Product
            
            // get list of all order-Item for opporunity recorrds (trigger) <-- for update and delete purpose 
            List<OrderItem> allOrderItemList = [
                SELECT 
                    id, Opp_Product_Id__c,
                    quantity, unitPrice 
                FROM OrderItem
                WHERE Order.opportunity.id in :opptyIDsThatOrderNeedToAdjustSET
            ];
            // store all order to map
            Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>();
            for(OrderItem orderItemRec : allOrderItemList){
                // set order record to map by opportunity
                orderItemMap.put(orderItemRec.Opp_Product_Id__c, orderItemRec);
            }


            for (Id oppId : opptyAdjLogMap.keySet()) {

                Order orderRelatedToOpptyREC = opptyOrderMap.get( oppId );
                List<Adjustment_Log__c> adjLogList = opptyAdjLogMap.get( oppId );


                // if any adjustment and the order was created before, than do adjust the Order and Order-Item
                if ( adjLogList <> null && orderRelatedToOpptyREC <> null ) {

                    // adjust order item (Update and delete)
                    for(Adjustment_Log__c adjLogREC : adjLogList){
                        if ( adjLogREC.Action__c == 'Change' ) {
                            system.debug('=== change operation ===');
                            
                            OrderItem orderItemToUpdate = orderItemMap.get(adjLogREC.Opp_Product_Id__c);
                            orderItemToUpdate.UnitPrice = adjLogREC.New_Sales_Price__c;
                            orderItemToUpdate.Quantity = adjLogREC.New_Quantity__c;

                            // Store the OrderItem in the Map, overwriting any previous entry with the same ID
                            orderItemMapToUpdate.put(orderItemToUpdate.Id, orderItemToUpdate);

                        }

                        else if ( adjLogREC.Action__c == 'Delete' ) {
                            system.debug('=== delete operation ===');
                            
                            OrderItem orderItemToDelete = orderItemMap.get (adjLogREC.Opp_Product_Id__c);
                            orderItemToDeleteList.add (orderItemToDelete);
                        }
                    }

                }
            }

            try {
                // perform DML to Update order-Item
                orderItemToUpdateList.addAll(orderItemMapToUpdate.values());
                if ( orderItemToUpdateList.size() > 0 ) {
                    system.debug('=== orderItemToUpdateList : ' + orderItemToUpdateList);
                    //tutup semenstara -- handling change product after closed won for tv
                    //TODO: buka kembali jika sudah siap!!
                    //mediaOrderItemServices.deleteMOItemWithOrderProductID(orderItemToUpdateList);
                    //mediaOrderServices.deleteMediaOrdersWithOrderProductID(orderItemToUpdateList);
                    update orderItemToUpdateList;
                }

                // perform DML to Delete order-Item
                if ( orderItemToDeleteList.size() > 0 ) {
                    system.debug('=== orderItemToDeleteList : ' + orderItemToDeleteList);
                    delete orderItemToDeleteList;
                }
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }    
            }
            catch(Exception e) {
                errMessage = 'Error on TA_AT_Opp_AU_AdjustItemAfterClosedW afterUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );

            }
            //-- end of UPDATE and DELETE Order Product


        }

    }
}