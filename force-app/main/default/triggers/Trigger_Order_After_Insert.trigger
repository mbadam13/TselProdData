/**
 * @File Name          : Trigger_Order_After_Insert.trigger
 * @Description        : 
 * @Author             : david wong
 * @Group              : 
 * @Last Modified By   : Ahmat Zulkifli Murad
 * @Last Modified On   : 04-17-2024
 * @Modification Log   : 
 * Ver       Date    Author                     Modification
 * 1.0    2/3/2020   david wong                 Initial Version
 * 1.1    6/10/2020   Debora E P                Udpate
 * 1.2    21/09/2023   Ahmat Zulkifli Murad     Update Rapihin Code, handling isi sales, brand postpaid prepaid
 * 1.3    17/04/2024   Ahmat Zulkifli Murad     Update tambahin handler call CalculateSOAorQuoteFinalRev_Batch after update is changes Final_Sum_Revenue_Telkomsel__c value
**/
// Modified by Debora E P - 6 October 2020

trigger Trigger_Order_After_Insert on Order (before insert, after insert, after update) {
    if (label.Trigger_Order_After_Insert_ON == 'YES') {
        
        Trigger_Setting__c triggerSettingsRec = Trigger_Setting__c.getInstance('validation:_orderMustHaveOpportunity');
        String orderID;
        String QuoteId;
        Integer AutoNumber;
        String OpportunityId;
        String CampaignId;
        String CampId;
        String SOAID;
        List <OrderItem> OrderItemlist = new List <OrderItem>();
        if(trigger.isbefore){
            if(trigger.isinsert) {
                for(Order Odr :system.trigger.new){

                    List<Opportunity> opp = [SELECT Id, Name, StageName, Approval_Status__c FROM Opportunity WHERE Id =: Odr.OpportunityId];
                        system.debug('== opp > '+ opp);
                    system.debug('== opp.size() > ' + opp.size());
                    
                    if(opp.size() > 0){
                        
                        if(opp[0].StageName == 'Closed Won' && opp[0].Approval_Status__c == 'Approved'){
                            
                            list<SOA__c> ListSOA = [
                                SELECT 
                                id,
                                name,
                                Opportunity__c,
                                Opportunity__r.brand__r.PIC_Advertiser__c, 
                                Account_ID__c 
                                from SOA__c 
                                where id=: Odr.SOA__c
                            ];

                            system.debug('== Listsoa + ' + ListSOA);
                            list<Pricebook2> PB = [ 
                                SELECT 
                                id,
                                name 
                                from Pricebook2 
                                WHERE Name = 'Standard Price Book'
                            ];

                            system.debug('== PB + ' + PB);
                            for(Pricebook2 PBE :PB){
                                Odr.Pricebook2Id=PBE.id;
                            }

                            if(Test.isRunningTest()){
                                Odr.Pricebook2Id = Test.getStandardPricebookId();
                            }

                            for(SOA__c newSOA :ListSOA){
                                    Odr.AccountId = newSOA.Account_ID__c;
                                    Odr.OpportunityId = newSOA.Opportunity__c;
                                    
                                    if(newSOA.Opportunity__r.brand__r.PIC_Advertiser__c != null ){
                                    odr.PIC_Advertiser__c = newSOA.Opportunity__r.brand__r.PIC_Advertiser__c;
                                }
                            }
                            system.debug(' == odr.PIC_Advertiser__c +  ' + odr.PIC_Advertiser__c);
                        }else{
                            Odr.addError('Opportunity "' + opp[0].Name + '" has not Closed Won / Approved yet.');
                        }
                    }else{
                        if(Odr.order_type__c == '' && Odr.order_type__c == null){
                            if(triggerSettingsRec.IsActive__c == true){
                                Odr.addError(triggerSettingsRec.Error_Message__c);
                            }   
                        }   
                    }
                }
            } 
        }

        if(trigger.isafter){
            if(trigger.isinsert){
                system.debug('in TriggerOrder.afterinsert');
                // new way to give action trigger
                OrderTriggerHandler.afterInsert(Trigger.new);

                //oldway for oppty not changes tis is existing
                AutoNumber=1;
                double sq;
                for(Order orderNew : system.trigger.new){
                    if(orderNew.order_type__c == 'Opportunity' || orderNew.order_type__c == ''){
                        System.debug('in trigger.orderNew ');
                        Order allOrder = [
                        SELECT Id,
                        OpportunityId,
                        OrderNumber, 
                        QuoteId,
                        Name,
                        SOA_Quotation_No__c,
                        SOA_Name__c,
                        Quote_Name__c,
                        Opportunity.Adjustment_Version__c, 
                        Opportunity.Check_PO__c, 
                        Opportunity.isSubmitCheckPOApproval__c, 
                        Opportunity.StageName, 
                        Opportunity.Penagihan_based_on__c, 
                        Opportunity.Approval_Status__c 
                        FROM Order WHERE Id = :orderNew.id
                        ];
                        system.debug('hasil allOrder ' + allOrder);                   
                        //String NoOrder = allOrder.OrderNumber.substring(0,2);
                        if(allOrder.SOA_Quotation_No__c == Null){
                            if(allOrder.SOA_Name__c != Null){
                                SOAID = allOrder.SOA_Name__c;
                            } else{
                                SOAID = allOrder.Quote_Name__c;
                            }
                        } else {
                            SOAID = allOrder.SOA_Quotation_No__c;
                        }
                        
                        system.debug('*** allOrder.OpportunityId = ' + allOrder.OpportunityId);
                        system.debug('*** allOrder.Opportunity.Adjustment_Version__c = ' + allOrder.Opportunity.Adjustment_Version__c);
                        system.debug('*** allOrder.Opportunity.Check_PO__c = ' + allOrder.Opportunity.Check_PO__c);
                        system.debug('*** allOrder.Opportunity.isSubmitCheckPOApproval__c = ' + allOrder.Opportunity.isSubmitCheckPOApproval__c);
                        system.debug('*** allOrder.Opportunity.Approval_Status__c = ' + allOrder.Opportunity.Approval_Status__c);
                        system.debug('*** allOrder.Opportunity.StageName = ' + allOrder.Opportunity.StageName);
                        
                        if(allOrder.OpportunityId != Null){
                            
                            if(allOrder.Opportunity.Adjustment_Version__c == 0 
                                || allOrder.Opportunity.Adjustment_Version__c == null){
                                
                                List<OpportunityLineItem> opplis = [
                                    SELECT Id,
                                    OpportunityId,
                                    UnitPrice,
                                    Quantity,
                                    PricebookEntryId,
                                    Product_id_number__c,
                                    opportunity.Pricebook2Id,
                                    opportunity.ownerid,
                                    Product2Id 
                                    FROM OpportunityLineItem 
                                    WHERE OpportunityId =:allOrder.OpportunityId 
                                    ORDER BY CreatedDate ASC
                                ];

                                AggregateResult[] orderlis = [
                                    SELECT 
                                    sum(Quantity) sq,
                                    Opp_Product_Id__c 
                                    FROM OrderItem 
                                    WHERE Opportunity__c =:allOrder.OpportunityId 
                                    GROUP by Opp_Product_Id__c
                                ];

                                double totAmount=0;
                                Map < String, Integer> orderlistMap = new Map < String, Integer > ();
                                for (AggregateResult ar : orderlis)  {
                                    sq= (Decimal) ar.get('sq') ;
                                    totAmount=sq ;
                                    orderlistMap.put( (String) ar.get('Opp_Product_Id__c'), Integer.valueof(totAmount));
                                }
        
                                List<OrderItem> orderProds = new List<OrderItem>();
                                for(OpportunityLineItem thisItem : opplis) {
                                    CampaignId = Date.today().year()+'_B'+allOrder.OrderNumber+'_'+SOAID+'_'+thisItem.Product_id_number__c+'_'+AutoNumber;
                                    CampId = SOAID+'_'+thisItem.Product_id_number__c+'_'+AutoNumber;	
                                    AutoNumber=AutoNumber+1;
                                    Integer tampungqty;
                                    tampungqty = orderlistMap.get(thisItem.Id);
                                    
                                    if(tampungqty==Null) {
                                        tampungqty= 0;
                                    }
            
                                    OrderItem newOi = new OrderItem(
                                        OrderId = allOrder.id,
                                        UnitPrice = thisItem.UnitPrice,
                                        Quantity = (thisItem.Quantity-tampungqty),
                                        PricebookEntryId = thisItem.PricebookEntryId,
                                        Camp_ID__c = CampId,
                                        sales__c = thisItem.opportunity.ownerid,
                                        Campaign_ID__c = CampaignId,
                                        Opportunity__c = thisItem.OpportunityId,
                                        ServiceDate = orderNew.EffectiveDate,
                                        EndDate = orderNew.EndDate,
                                        Opp_Product_Id__c = thisItem.Id,
                                        Opportunity_Product__c = thisItem.Id
                                    );

                                    system.debug('+++++ newOi : ' + newOi );
                                    if(newOi.Quantity>0){
                                        OrderItemlist.add(newOi);
                                    }
                                    system.debug('+++++ OrderItemlist: ' + OrderItemlist);
                                }                               
                                insert OrderItemlist;   
                                                                    
                            }else{
                                
                                if(allOrder.Opportunity.Check_PO__c == 'OK' 
                                    && allOrder.Opportunity.isSubmitCheckPOApproval__c == true 
                                    && allOrder.Opportunity.Approval_Status__c == 'Approved' 
                                    && allOrder.Opportunity.StageName == 'Closed Won'){
                                    
                                    List<Order> lastOrder = [SELECT Id, Name, OrderNumber, OpportunityId, SOA__c, QuoteId 
                                                                FROM Order WHERE Id <>: orderNew.Id AND OpportunityId =: allOrder.OpportunityId 
                                                                ORDER BY CreatedDate DESC LIMIT 1
                                                                ];
                                    
                                    system.debug('*** lastOrder.size() = ' + lastOrder.size());
                                    system.debug('*** lastOrder = ' + lastOrder);
                                    
                                    if(lastOrder.size() > 0){
                                        
                                        Map<String,OpportunityLineItem> mapIdOli = new Map<String,OpportunityLineItem>();
                                        
                                        List<OpportunityLineItem> oli_list = [
                                            SELECT 
                                            Id, 
                                            OpportunityId, 
                                            UnitPrice, 
                                            Quantity, 
                                            PricebookEntryId, 
                                            Product_id_number__c, 
                                            opportunity.Pricebook2Id, 
                                            Product2Id,
                                            opportunity.ownerId
                                            
                                            FROM OpportunityLineItem 
                                            
                                            WHERE OpportunityId =: lastOrder[0].OpportunityId 

                                            ORDER BY CreatedDate ASC
                                        ];
                                        
                                        system.debug('*** oli_list.size() = ' + oli_list.size());
                                        system.debug('*** oli_list = ' + oli_list);
                                        
                                        for(OpportunityLineItem olirec : oli_list){
                                            mapIdOli.put(olirec.Id,olirec);
                                        }
                                        
                                        system.debug('*** mapIdOli.size() = ' + mapIdOli.size());
                                        system.debug('*** mapIdOli = ' + mapIdOli);
                                        
                                        AggregateResult[] ordli_aggr1 = [
                                            SELECT sum(Quantity) sq, 
                                            Opp_Product_Id__c 
                                            
                                            FROM OrderItem 
                                            
                                            WHERE Opportunity__c= : lastOrder[0].OpportunityId 
                                            GROUP BY Opp_Product_Id__c
                                        ];
                                        
                                        system.debug('*** ordli_aggr1.size() = ' + ordli_aggr1.size());
                                        system.debug('*** ordli_aggr1 = ' + ordli_aggr1);
                                        
                                        Double totAmount1 = 0;
                                        Map<String,Integer> ordliMap1 = new Map <String,Integer>();
                                                    
                                        for(AggregateResult ar : ordli_aggr1)  {
                                            sq = (Decimal) ar.get('sq');
                                            totAmount1 = sq ;
                                            ordliMap1.put((String) ar.get('Opp_Product_Id__c'),Integer.valueof(totAmount1));
                                        }
                                        
                                        system.debug('*** ordliMap1.size() = ' + ordliMap1.size());
                                        system.debug('*** ordliMap1 = ' + ordliMap1);
                                        system.debug('*** allOrder.Opportunity.Penagihan_based_on__c = ' + allOrder.Opportunity.Penagihan_based_on__c);
                                        
                                        if(allOrder.Opportunity.Penagihan_based_on__c == 'Postpaid'){
                                            
                                            List<SOA_Detail__c> soad_list = [SELECT Id, Opp_Product_Id__c FROM SOA_Detail__c WHERE SOA__c =: lastOrder[0].SOA__c ORDER BY CreatedDate ASC];
                                            
                                            system.debug('*** soad_list.size() = ' + soad_list.size());
                                            system.debug('*** soad_list = ' + soad_list);
                                            
                                            for(SOA_Detail__c soadrec : soad_list){
                                                
                                                OpportunityLineItem oli_temp = mapIdOli.get(soadrec.Opp_Product_Id__c);
                                                
                                                system.debug('*** oli_temp = ' + oli_temp);
                                                
                                                OrderItem oirec = new OrderItem();
                                                                                
                                                if(oli_temp != null){
                                                    
                                                    CampaignId = Date.today().year() + '_B' + orderNew.OrderNumber + '_' + SOAID + '_' + oli_temp.Product_id_number__c + '_' + AutoNumber;
                                                    CampId = SOAID + '_' + oli_temp.Product_id_number__c + '_' + AutoNumber;	
                                                    
                                                    system.debug('*** CampaignId = ' + CampaignId);
                                                    system.debug('*** CampId = ' + CampId);
                                                    
                                                    Integer tampungqty1;
                                                    tampungqty1 = ordliMap1.get(oli_temp.Id);
                                                    if(tampungqty1 == Null)
                                                    {
                                                        tampungqty1 = 0;
                                                    }
                                                    
                                                    oirec.OrderId = orderNew.Id;
                                                    oirec.UnitPrice = oli_temp.UnitPrice;
                                                    oirec.Quantity = (oli_temp.Quantity - tampungqty1);
                                                    oirec.PricebookEntryId = oli_temp.PricebookEntryId;
                                                    oirec.Camp_ID__c = CampId;
                                                    oirec.Campaign_ID__c = CampaignId;
                                                    oirec.Opportunity__c = oli_temp.OpportunityId;
                                                    oirec.ServiceDate = orderNew.EffectiveDate;
                                                    oirec.EndDate = orderNew.EndDate;
                                                    oirec.Opp_Product_Id__c = oli_temp.Id;
                                                    oirec.opportunity_product__c = oli_temp.Id;
                                                    
                                                    system.debug('*** oirec oi_temp!=null = ' + oirec);
                                                    
                                                }else{
                                                    
                                                    system.debug('*** lastOrder[0].Id = ' + lastOrder[0].Id);
                                                    system.debug('*** soadrec.Opp_Product_Id__c = ' + soadrec.Opp_Product_Id__c);
                                                    
                                                    List<OrderItem> oi_list = [
                                                        SELECT Id, 
                                                        OrderId, 
                                                        Quantity, 
                                                        UnitPrice, 
                                                        PricebookEntryId, 
                                                        Camp_ID__c, 
                                                        Campaign_ID__c, 
                                                        Opportunity__c, 
                                                        ServiceDate, 
                                                        EndDate, 
                                                        Opp_Product_Id__c, 
                                                        Product_id_number__c 
                                                        
                                                        FROM OrderItem 
                                                        
                                                        WHERE OrderId =: lastOrder[0].Id AND 
                                                        Opp_Product_Id__c =:soadrec.Opp_Product_Id__c 
                                                        
                                                        ORDER BY CreatedDate ASC
                                                    ];
                                                            
                                                    system.debug('*** oi_list.size() = ' + oi_list.size());
                                                    system.debug('*** oi_list = ' + oi_list);
                                                    
                                                    if(oi_list.size() == 1){
                                                        
                                                        CampaignId = Date.today().year() + '_B' + orderNew.OrderNumber + '_' + SOAID + '_' + oi_list[0].Product_id_number__c + '_' + AutoNumber;
                                                        CampId = SOAID + '_' + oi_list[0].Product_id_number__c + '_' + AutoNumber;	
                                                        
                                                        system.debug('*** CampaignId oli_temp null = ' + CampaignId);
                                                        system.debug('*** CampId oli_temp null = ' + CampId);
                                                        
                                                        oirec = oi_list[0];
                                                        oirec.Quantity = 0; // Tidak bisa set Qty jadi 0, tapi ini tidak di-insert
                                                        oirec.UnitPrice = 0;
                                                        oirec.Campaign_ID__c = CampaignId;
                                                        oirec.Camp_ID__c = CampId;
                                                        
                                                    }else{
                                                        if(oi_list.size() == 0){
                                                            oirec = null;
                                                        }else{
                                                            orderNew.addError('More than 1 Order Product: (' + oi_list.size() + '). For Order Id ' + lastOrder[0].Id + ' & Opp Product Id ' + soadrec.Opp_Product_Id__c);
                                                        }
                                                    }
                                                    
                                                    system.debug('*** oirec oi_temp==null = ' + oirec);
                                                }
                                                
                                                if(oirec <> null){
                                                    if(oirec.Quantity > 0){
                                                        OrderItemlist.add(oirec); 
                                                        system.debug('*** OrderItemlist qty>0 = ' + OrderItemlist);
                                                    }
                                                }
                                                
                                                system.debug('*** OrderItemlist luar = ' + OrderItemlist);
                                                
                                                AutoNumber = AutoNumber + 1;
                                            }
                                            
                                        }else if(allOrder.Opportunity.Penagihan_based_on__c == 'Prepaid'){
                                            
                                            List<QuoteBU_Detail__c> qbud_list = [
                                                SELECT Id, 
                                                QuoteBU__c, 
                                                Unit_Price__c, 
                                                Quantity__c, 
                                                PricebookEntryId__c, 
                                                Product_id_number__c, 
                                                QuoteBU__r.Quote__r.Pricebook2Id, 
                                                Opp_Product_Id__c 

                                                FROM QuoteBU_Detail__c 
                                                
                                                WHERE QuoteBU__r.Quote__c =:lastOrder[0].QuoteId 
                                                ORDER BY CreatedDate ASC
                                            ];
                                            
                                            system.debug('*** qbud_list.size() = ' + qbud_list.size());
                                            system.debug('*** qbud_list = ' + qbud_list);
                                            
                                            for(QuoteBU_Detail__c qbudrec : qbud_list){
                                                
                                                OpportunityLineItem oli_temp_q = mapIdOli.get(qbudrec.Opp_Product_Id__c);
                                                
                                                system.debug('*** oli_temp_q = ' + oli_temp_q);
                                                
                                                OrderItem oirec_q = new OrderItem();
                                                
                                                if(oli_temp_q != null){
                                                    
                                                    CampaignId = Date.today().year() + '_B' + orderNew.OrderNumber + '_' + SOAID + '_' + oli_temp_q.Product_id_number__c + '_' + AutoNumber;
                                                    CampId = SOAID + '_' + oli_temp_q.Product_id_number__c + '_' + AutoNumber;
                                                    
                                                    system.debug('*** CampaignId q = ' + CampaignId);
                                                    system.debug('*** CampId q = ' + CampId);
                                                    
                                                    Integer tampungqty2;
                                                    tampungqty2 = ordliMap1.get(oli_temp_q.Id);
                                                    if(tampungqty2 == Null)
                                                    {
                                                        tampungqty2 = 0;
                                                    }
                                                    
                                                    oirec_q.OrderId = orderNew.Id;
                                                    oirec_q.UnitPrice = oli_temp_q.UnitPrice;
                                                    oirec_q.Quantity = (oli_temp_q.Quantity - tampungqty2);
                                                    oirec_q.PricebookEntryId = oli_temp_q.PricebookEntryId;
                                                    oirec_q.Camp_ID__c = CampId;
                                                    oirec_q.Campaign_ID__c = CampaignId;
                                                    oirec_q.Opportunity__c = oli_temp_q.OpportunityId;
                                                    oirec_q.sales__c = oli_temp_q.opportunity.ownerId;
                                                    oirec_q.ServiceDate = orderNew.EffectiveDate;
                                                    oirec_q.EndDate = orderNew.EndDate;
                                                    oirec_q.Opp_Product_Id__c = oli_temp_q.Id;
                                                    oirec_q.opportunity_product__c = oli_temp_q.Id;
                                                    
                                                    system.debug('*** oirec_q oi_temp!=null = ' + oirec_q);
                                                    
                                                }else{
                                                    
                                                    system.debug('*** lastOrder[0].Id = ' + lastOrder[0].Id);
                                                    system.debug('*** qbudrec.Opp_Product_Id__c = ' + qbudrec.Opp_Product_Id__c);
                                                    
                                                    List<OrderItem> oi_list_q = [
                                                        SELECT 
                                                        Id, 
                                                        OrderId, 
                                                        Quantity, 
                                                        UnitPrice, 
                                                        PricebookEntryId, 
                                                        Camp_ID__c, 
                                                        Campaign_ID__c, 
                                                        Opportunity__c, 
                                                        ServiceDate, 
                                                        EndDate, 
                                                        Opp_Product_Id__c, 
                                                        Product_id_number__c  

                                                        FROM OrderItem 

                                                        WHERE OrderId =: lastOrder[0].Id AND Opp_Product_Id__c =:qbudrec.Opp_Product_Id__c 

                                                        ORDER BY CreatedDate ASC
                                                    ];
                                                            
                                                    system.debug('*** oi_list_q.size() = ' + oi_list_q.size());
                                                    system.debug('*** oi_list_q = ' + oi_list_q);
                                                    
                                                    if(oi_list_q.size() == 1){
                                                        
                                                        CampaignId = Date.today().year() + '_B' + orderNew.OrderNumber + '_' + SOAID + '_' + oi_list_q[0].Product_id_number__c + '_' + AutoNumber;
                                                        CampId = SOAID + '_' + oi_list_q[0].Product_id_number__c + '_' + AutoNumber;	
                                                        
                                                        system.debug('*** CampaignId oli_temp null q = ' + CampaignId);
                                                        system.debug('*** CampId oli_temp null q = ' + CampId);
                                                        
                                                        oirec_q = oi_list_q[0];
                                                        oirec_q.Quantity = 0; // Tidak bisa set Qty jadi 0, tapi ini tidak di-insert
                                                        oirec_q.UnitPrice = 0;
                                                        oirec_q.Campaign_ID__c = CampaignId;
                                                        oirec_q.Camp_ID__c = CampId;
                                                        
                                                    }else{
                                                        if(oi_list_q.size() == 0){
                                                            oirec_q = null;
                                                        }else{
                                                            orderNew.addError('More than 1 Order Product: (' + oi_list_q.size() + '). For Order Id ' + lastOrder[0].Id + ' & Opp Product Id ' + qbudrec.Opp_Product_Id__c);
                                                        }
                                                    }
                                                    
                                                    system.debug('*** oirec oli_temp==null = ' + oirec_q);                                                    
                                                }
                                                
                                                if(oirec_q <> null){
                                                    if(oirec_q.Quantity > 0){
                                                        OrderItemlist.add(oirec_q); system.debug('*** OrderItemlist qty>0 = ' + OrderItemlist);
                                                    }
                                                }
                                                
                                                system.debug('*** OrderItemlist luar = ' + OrderItemlist);
                                                
                                                AutoNumber = AutoNumber + 1;
                                            }
                                            
                                        }else{
                                            orderNew.addError('Set Opportunity field "Penagihan based on" : Prepaid / Postpaid');
                                        }                                        
                                    }else{
                                        
                                        // Sama seperti code existing create OrderItem -start
                                        // Jika AdjVer > 0, Approved & Closed Won Opp dan belum ada Order
                                        
                                        List<OpportunityLineItem> oli_list_1 = [
                                            SELECT 
                                            Id, 
                                            OpportunityId, 
                                            UnitPrice, 
                                            Quantity, 
                                            PricebookEntryId, 
                                            Product_id_number__c, 
                                            opportunity.Pricebook2Id, 
                                            Product2Id  
                                            FROM OpportunityLineItem 
                                            WHERE OpportunityId =:allOrder.OpportunityId 
                                            ORDER BY CreatedDate ASC
                                        ];
                                        
                                        system.debug('*** oli_list_1.size() = ' + oli_list_1.size());
                                        system.debug('*** oli_list_1 = ' + oli_list_1);
                                        
                                        AggregateResult[] ordli_aggr = [
                                            SELECT sum(Quantity) sq, 
                                            Opp_Product_Id__c 
                                            FROM OrderItem 
                                            WHERE Opportunity__c =:allOrder.OpportunityId 
                                            GROUP BY Opp_Product_Id__c
                                        ];
                                            
                                        system.debug('*** ordli_aggr.size() = ' + ordli_aggr.size());
                                        system.debug('*** ordli_aggr = ' + ordli_aggr);
                                        
                                        Double totAmount=0;
                                        Map<String,Integer> ordliMap = new Map <String,Integer>();
                                        for(AggregateResult ar : ordli_aggr)  {
                                            sq = (Decimal) ar.get('sq');
                                            totAmount = sq ;
                                            ordliMap.put((String) ar.get('Opp_Product_Id__c'),Integer.valueof(totAmount));
                                        }
                                        
                                        system.debug('*** ordliMap.size() = ' + ordliMap.size());
                                        system.debug('*** ordliMap = ' + ordliMap);
    
                                        for(OpportunityLineItem thisItem : oli_list_1){
                                            
                                            CampaignId = Date.today().year() + '_B' + allOrder.OrderNumber + '_' + SOAID + '_' + thisItem.Product_id_number__c + '_' + AutoNumber;
                                            CampId = SOAID + '_' + thisItem.Product_id_number__c + '_' + AutoNumber;	
                                            AutoNumber = AutoNumber + 1;
                                            
                                            system.debug('*** CampaignId = ' + CampaignId);
                                            system.debug('*** CampId = ' + CampId);
                                            system.debug('*** AutoNumber = ' + AutoNumber);
                                            
                                            Integer tampungqty;
                                            tampungqty = ordliMap.get(thisItem.Id);
                                            if(tampungqty==Null)
                                            {
                                                tampungqty= 0;
                                            }
                                            system.debug('*** tampungqty = ' + tampungqty);
                    
                                            OrderItem newOi = new OrderItem(OrderId = allOrder.id,UnitPrice= thisItem.UnitPrice,Quantity = (thisItem.Quantity-tampungqty),PricebookEntryId = thisItem.PricebookEntryId,Camp_ID__c=CampId,Campaign_ID__c=CampaignId,Opportunity__c=thisItem.OpportunityId,ServiceDate=orderNew.EffectiveDate,EndDate=orderNew.EndDate,Opp_Product_Id__c=thisItem.Id);
                                            system.debug('+++++ newOi : ' + newOi );
                                            if(newOi.Quantity>0)
                                            {
                                                OrderItemlist.add(newOi);
                                            }
                                            system.debug('+++++ OrderItemlist: ' + OrderItemlist);
                                        }
                                        // Sama seperti code existing create OrderItem -end
                                    }
                                    
                                    system.debug('*** OrderItemlist.size() = ' + OrderItemlist.size());
                                    system.debug('*** OrderItemlist = ' + OrderItemlist);
                                        
                                    insert OrderItemlist;
                                }                                
                            }
                                                         
                        }else{                   
                            List<QuoteLineItem> orderlis = [
                                SELECT 
                                Id,
                                QuoteId,
                                UnitPrice,
                                Quantity,
                                PricebookEntryId,
                                Product_id_number__c,
                                quote.Pricebook2Id 
                                
                                FROM QuoteLineItem 
                                
                                WHERE QuoteId =:allOrder.QuoteId
                            ];

                            List<OrderItem> orderProds = new List<OrderItem>();
                            for(QuoteLineItem thisItem : orderlis){
                                CampaignId = Date.today().year()+'_B'+allOrder.OrderNumber+'_'+SOAID+'_'+thisItem.Product_id_number__c+'_'+AutoNumber;
                                AutoNumber=AutoNumber+1;
                                OrderItem newOi = new OrderItem(
                                    OrderId = allOrder.id,
                                    UnitPrice = thisItem.UnitPrice,
                                    Quantity = thisItem.Quantity,
                                    PricebookEntryId = thisItem.PricebookEntryId,
                                    Campaign_ID__c = CampaignId,
                                    QuoteLineItemId = thisItem.Id,
                                    ServiceDate = orderNew.EffectiveDate,
                                    EndDate = orderNew.EndDate
                                );
                                system.debug('+++++ newOi : ' + newOi );
                                OrderItemlist.add(newOi);
                                system.debug('+++++ OrderItemlist: ' + OrderItemlist);
                            }
                            
                            upsert OrderItemlist Campaign_ID__c;
                        }
                    }
                }                      
            }
            if(trigger.isUpdate){
                OrderTriggerHandler.afterUpdate(Trigger.old, Trigger.new);
            }
        }
    }
}