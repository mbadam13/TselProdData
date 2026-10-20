/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Doddy Prima
**/

public with sharing class TA_AT_Opp_AU_CreateOrderItem implements TriggerAction.AfterUpdate {
    public void AfterUpdate(List<Opportunity> newList, List<Opportunity> oldList){
        System.debug('=== TA_AT_Opp_AU_CreateOrderItem ===');
        String errMessage;

        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>(oldList);

        for(Opportunity oppNEWRec : newList){
                Opportunity oppOLDRec = oldMap.get(oppNEWRec.Id);



                if ( oppNEWRec.StageName == 'Closed Won' 
                    && oppNEWRec.StageName != oppOLDRec.StageName 
                    && oppNEWRec.Adjustment_Version__c >= 1 
                    && oppNEWRec.Check_PO__c == 'OK'
                    && oppNEWRec.isSubmitCheckPOApproval__c == true
                    && oppNEWRec.Approval_Status__c == 'Approved') {
                

                    // delete order first
                    List<Order> orderList = [
                        SELECT id, status
                        FROM Order
                        WHERE opportunity.id = :oppNEWRec.id
                    ];

                    system.debug (' === orderList.size() : ' + orderList.size() + ' === ');
                    system.debug (' === orderList : ' + orderList + ' === ');


                    if ( orderList.size() > 0 ) {
                        // set status to Draft first
                        for (Order orderRec : orderList) {
                            orderRec.Status = 'Draft';
                        }
                        update orderList;


                        // TODO: implement try catch 
                        delete orderList;                    
                    }
                    // -- end of delete order ---


                    // Create Order based on SOA
                    if ( oppNEWRec.Penagihan_based_on__c == 'Postpaid' ) {
                        SOA__c soaRec = New SOA__c();

                        List<SOA__c> soaList = [
                            SELECT 
                                id, 
                                SOA_Start_Date__c,
                                SOA_End_Date__c, 
                                Opportunity__c,
                                Account__c, 
                                Brand__c,
                                SOA_Type__c, 
                                name
                            FROM SOA__c
                            WHERE opportunity__c = :oppNEWRec.id
                            LIMIT 1
                        ];

                        if ( soaList.size() > 0 ) {
                            soaRec = soaList[0];
                        
                        
                            Order newOrder = new order();
                            newOrder.SOA__c = soaRec.id;
                            newOrder.EffectiveDate = soaRec.SOA_Start_Date__c;
                            newOrder.EndDate= soaRec.SOA_End_Date__c;
                            if(soaRec.Opportunity__c != null){
                                //oppIds.add(soaRec.Opportunity__c);
                                //oppSoaMap.put(soaRec.Opportunity__c,soaRec);
                                newOrder.OpportunityId = soaRec.Opportunity__c;
                            }
                            newOrder.AccountId = soaRec.Account__c; //mandatory
                            newOrder.Brand__c = soaRec.Brand__c;
                            newOrder.Order_Type__c = soaRec.SOA_Type__c;
                            newOrder.Status = 'Draft';
                            newOrder.SOA_Quotation_No__c = soaRec.Name;

                            try {
                                insert newOrder;
                            }
                            catch (Exception e) {
                                errMessage = 'Error on TA_AT_Opp_AU_CreateOrderItem -> Create Order based on SOA::' + e.getmessage() + ' - ' + e.getStacktraceString() + e.getLineNumber() ;
                                system.debug('=== error message : ' + errMessage);
                                AppUtils.putError(errMessage );
                            }
                        
                        }

                    }
                    // Create Order based on Quotation
                    else if ( oppNEWRec.Penagihan_based_on__c == 'Prepaid' ) {
                        
                        Quote quoteRec = [
                            SELECT 
                                id, 
                                Start_Date__c,
                                End_Date__c, 
                                OpportunityId,
                                AccountId, 
                                brandId__c,
                                Name, 
                                Opportunity.contractId, 
                                No_Quote__c,
                                Opportunity.brand__r.pic_advertiser__c
                            FROM Quote
                            WHERE opportunityId = :oppNEWRec.id
                        ];
                        

                        List<Contract> contractList = [
                            SELECT Id, 
                                Opportunity__r.brand__c 
                            FROM Contract 
                            WHERE 
                                Id = :oppNEWRec.contractId 
                            LIMIT 1
                        ];  
                                        

                        Order newOrder = new order();
                        newOrder.QuoteId = quoteRec.id;
                        newOrder.order_type__c = 'Opportunity'; 
                        newOrder.EffectiveDate = quoteRec.Start_Date__c;
                        newOrder.Pricebook2Id = oppNEWRec.Pricebook2Id;
                        newOrder.brand__c = quoteRec.brandId__c; //dari oppty
                        newOrder.EndDate = quoteRec.End_Date__c;
                        newOrder.OpportunityId = quoteRec.OpportunityId;
                        newOrder.AccountId = quoteRec.AccountId;
                        newOrder.ContractId = contractList[0].Id;
                        newOrder.Status = 'Draft';
                        newOrder.SOA_Quotation_No__c = quoteRec.No_Quote__c;
                        if(quoteRec.Opportunity.brand__r.pic_advertiser__c != null){
                            newOrder.pic_advertiser__c = quoteRec.Opportunity.brand__r.pic_advertiser__c;
                        }
                        
                        system.System.debug('== contractList +' + contractList);
                        system.System.debug('== newOrder +' + newOrder);
                        
                        try {
                            insert newOrder;
                        }
                        catch (Exception e) {
                            errMessage = 'Error on TA_AT_Opp_AU_CreateOrderItem -> Create Order based on Quote::' + e.getmessage() + ' - ' + e.getStacktraceString() + e.getLineNumber() ;
                            system.debug('=== error message : ' + errMessage);
                            AppUtils.putError(errMessage );
                        }

                    }




                    
                }
                // -- end of if Opp_StageName__c == 'Closed Won'
            


             
        }
        


    }
    
}