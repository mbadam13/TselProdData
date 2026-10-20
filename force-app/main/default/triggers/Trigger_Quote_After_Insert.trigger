/**
 * @description       : 
 * @author            : Victor S
 * @group             : 
 * @last modified on  : 04-29-2024
 * @last modified by  : Ahmat Zulkifli Murad
 
 @Modification Log   : 
 * Ver       Date    Author                     Modification
 * 1.0    14/01/2020   Victor S                 Initial Version
 * 1.1    6/10/2020   Debora E P                Udpate
 * 1.2    21/09/2023   Ahmat Zulkifli Murad     Update Rapihin Code, handling update prepaid order wajib ada pricebook2id
 * 1.3    17/04/2024   Ahmat Zulkifli Murad     adding after update ketika invoice ada perubahan updata value di order item
**/ 

// Created By Victor S
// 14 January 2020
// Modified by Debora E P - 6 October 2020

trigger Trigger_Quote_After_Insert on Quote (after insert,after update) {

    if (label.Trigger_Quote_After_Insert_On== 'YES') {
        if(trigger.isafter){
            if(trigger.isInsert){
                
                List<QuoteBU__c> quotebu_list = new List<QuoteBU__c>();
                
                for(Quote q : trigger.New){
                    
                    Quote qrec = [SELECT Id, No_Quote__c, OwnerId, Owner.LastName, CreatedDate, Penagihan__c, OpportunityId,  
                                           AccountId, ContactId, ContractId, Discount, SOA__c, SOA_Quotation_No__c 
                                  FROM Quote WHERE Id =: q.Id];
                    
                    system.debug('*** qrec = ' + qrec);
                    
                    String qbu_name = '';
                    
                    if(qrec.Penagihan__c == 'Postpaid'){
                        qbu_name = 'SOA / ' + qrec.No_Quote__c + ' / ' + qrec.Owner.LastName + '/' + qrec.CreatedDate.month() + '/' + qrec.CreatedDate.day() + '/' + qrec.CreatedDate.year();
                    }else{
                        qbu_name = 'TSEL / ' + qrec.No_Quote__c + ' / ' + qrec.Owner.LastName + '/' + qrec.CreatedDate.month() + '/' + qrec.CreatedDate.day() + '/' + qrec.CreatedDate.year();
                    }
                    system.debug('*** qbu_name = ' + qbu_name);
                    
                    QuoteBU__c qbu = new QuoteBU__c();
                    qbu.Name = qbu_name;
                    qbu.Quote__c = qrec.Id;
                    qbu.Opportunity__c = qrec.OpportunityId;
                    qbu.Account__c = qrec.AccountId;
                    qbu.Contact__c = qrec.ContactId;
                    qbu.Owner__c = qrec.OwnerId;
                    qbu.Contract__c = qrec.ContractId;
                    qbu.Discount__c = qrec.Discount;
                    qbu.SOA__c = qrec.SOA__c;
                    qbu.SOA_Quotation_No__c = qrec.SOA_Quotation_No__c;
                    
                    quotebu_list.add(qbu);
                    
                    system.debug('*** quotebu_list loop = ' + quotebu_list);
                }
                
                system.debug('*** quotebu_list.size() = ' + quotebu_list.size());
                system.debug('*** quotebu_list = ' + quotebu_list);
                
                if(quotebu_list.size() > 0){
                    insert quotebu_list;
                }
            }
             
                             
            if(trigger.isupdate){
                
                List<QuoteBU__c> list_qbuToUpdate = new List<QuoteBU__c>();
                list<string> QuoteRecIdListForInvoiceUpdate = new list<string>();

                for(Quote newQuote :trigger.new) {
                    
                    Quote oldQuote = trigger.oldMap.get(newQuote.Id);
                    
                    Quote myQuote = [
                        SELECT 
                            AccountId, 
                            Status,
                            Opportunity.Id ,
                            Opportunity.Penagihan_based_on__c,  
                            Id, 
                            No_Quote__c, 
                            OwnerId, 
                            Owner.LastName, 
                            CreatedDate, 
                            Penagihan__c,   
                            ContactId, 
                            ContractId,
                            Opportunity.ContractId, 
                            Discount, 
                            SOA__c, 
                            SOA_Quotation_No__c, 
                            Opportunity.StageName, 
                            Opportunity.Approval_Status__c, 
                            opportunity.brand__r.pic_advertiser__c, 
                            invoice__c
                        FROM 
                            Quote 
                        WHERE 
                            id = :newQuote.id
                    ];
                    
                    system.debug('*** myQuote = ' + myQuote);
                    system.debug('*** myQuote.Status = ' + myQuote.Status);
                    system.debug('*** oldQuote.Status = ' + oldQuote.Status);
                    system.debug('*** myQuote.Opportunity.StageName = ' + myQuote.Opportunity.StageName);
                    system.debug('*** myQuote.Opportunity.Approval_Status__c = ' + myQuote.Opportunity.Approval_Status__c);
                    system.debug('*** myQuote.Opportunity.Penagihan_based_on__c = ' + myQuote.Opportunity.Penagihan_based_on__c);
                        
                    if(myQuote.Status== 'Final' && oldQuote.Status <> 'Final'){
                        
                        if(myQuote.Opportunity.StageName == 'Closed Won' && myQuote.Opportunity.Approval_Status__c == 'Approved'){
                            
                            if(myQuote.Opportunity.Penagihan_based_on__c == 'Prepaid'){
                                
                                List<Order> orderlist_check = [SELECT Id, Name FROM Order WHERE QuoteId =: myQuote.Id AND OpportunityId =: myQuote.Opportunity.Id];
                                
                                system.debug('*** orderlist_check.size() = ' + orderlist_check.size());
                                system.debug('*** orderlist_check = ' + orderlist_check);
                                
                                if(orderlist_check.size() == 0){
                                    
                                    // Delete existing QBU Detail
                                    system.debug('*** myQuote.Opportunity.Id = ' + myQuote.Opportunity.Id);
                                    system.debug('*** myQuote.Id = ' + myQuote.Id);
                                    
                                    String opp_id = myQuote.Opportunity.Id;
                                    String quote_id = myQuote.Id;
                                    if(opp_id != '')
                                        {opp_id = opp_id.left(15);}
                                    if(quote_id != '')
                                        {quote_id = quote_id.left(15);}
                                    system.debug('*** opp_id = ' + opp_id);
                                    system.debug('*** quote_id = ' + quote_id);
                                    List<QuoteBU_Detail__c> qbud_all = [SELECT Id FROM QuoteBU_Detail__c WHERE Quote_Id__c =: quote_id AND Opportunity_ID__c =: opp_id];
                                    
                                    system.debug('*** qbud_all.size() = ' + qbud_all.size());
                                    system.debug('*** qbud_all = ' + qbud_all);
                                    
                                    if(qbud_all.size() > 0){
                                        delete qbud_all;
                                    }
                                    
                                    // Create QBU Detail based on OLI
                                    List<OpportunityLineItem> oli_list = [SELECT Id, OpportunityId, UnitPrice, ListPrice, Discount__c, Quantity, PricebookEntryId, 
                                                                            PricebookEntry.UnitPrice, Product_id_number__c, opportunity.Pricebook2Id, Product2Id 
                                                                            FROM OpportunityLineItem WHERE OpportunityId =: myQuote.Opportunity.Id ORDER BY CreatedDate ASC];
                                    
                                    system.debug('*** oli_list.size() = ' + oli_list.size());
                                    system.debug('*** oli_list = ' + oli_list);
                                    
                                    List<QuoteBU_Detail__c> list_qbud_insert = new List<QuoteBU_Detail__c>();
                                    Integer AutoNumber = 0;
                                    
                                    id Pricebook2Id;
                                    for(OpportunityLineItem oli_rec : oli_list){
                                        Pricebook2Id = oli_rec.opportunity.Pricebook2Id;
                                        
                                        List<QuoteBU__c> qbu_rec = [SELECT Id FROM QuoteBU__c WHERE Quote__c =: myQuote.Id AND Opportunity__c =: myQuote.Opportunity.Id ORDER BY CreatedDate ASC];
                                        
                                        system.debug('*** qbu_rec.size() = ' + qbu_rec.size());
                                        system.debug('*** qbu_rec = ' + qbu_rec);
                                        
                                        AutoNumber = AutoNumber + 1;
                                        
                                        String CampaignId = myQuote.No_Quote__c +'_' + oli_rec.Product_id_number__c + '_' + AutoNumber;
                                        
                                        system.debug('*** CampaignId = ' + CampaignId);
                                        
                                        QuoteBU_Detail__c qbud = new QuoteBU_Detail__c();
                                        if(qbu_rec.size() > 0)
                                            {qbud.QuoteBU__c = qbu_rec[0].Id;}
                                        qbud.Campaign_ID__c = CampaignId;
                                        qbud.PricebookEntryId__c = oli_rec.PricebookEntryId;
                                        qbud.Product__c = oli_rec.Product2Id;
                                        qbud.Quantity__c = oli_rec.Quantity;
                                        qbud.List_Price__c = oli_rec.ListPrice;
                                        qbud.Unit_Price__c = oli_rec.UnitPrice;
                                        qbud.Discount__c = oli_rec.Discount__c;
                                        qbud.Opp_Product_Id__c = oli_rec.Id;
                                        qbud.Unit_Price_PBE__c = oli_rec.PricebookEntry.UnitPrice;
                                        
                                        system.debug('*** qbud : ' + qbud);
                                        
                                        list_qbud_insert.add(qbud);
                                        
                                        system.debug('*** list_qbud_insert loop = ' + list_qbud_insert);
                                    }
                                    if(list_qbud_insert.size() > 0){
                                        insert list_qbud_insert;
                                    }
                                    
                                    // Create Order
                                    //List<Contract> myContract = [SELECT Id, ContractNumber, Opportunity__r.brand__c FROM Contract WHERE Opportunity__c = :myQuote.Opportunity.Id LIMIT 1]; >>> Old Query
                                    List<Contract> myContract = [SELECT Id, Opportunity__r.brand__c FROM Contract WHERE Id = :myQuote.Opportunity.contractId LIMIT 1]; // Adjustment Query (2023/01/06) 
                                    
                                    system.debug('myContract >>> ' + myContract);
                                    Order newOrder = new order();
                                    newOrder.QuoteId = newQuote.id;
                                    newOrder.order_type__c = 'Opportunity'; 
                                    newOrder.EffectiveDate = newQuote.Start_Date__c;
                                    newOrder.Pricebook2Id = Pricebook2Id;
                                    newOrder.brand__c = newQuote.brandId__c; //dari oppty
                                    newOrder.EndDate = newQuote.End_Date__c;
                                    newOrder.OpportunityId = newQuote.OpportunityId;
                                    newOrder.AccountId = myQuote.AccountId;
                                    newOrder.ContractId = myContract[0].Id;
                                    newOrder.Status = 'Draft';
                                    newOrder.SOA_Quotation_No__c = newQuote.No_Quote__c;
                                    if(myQuote.Opportunity.brand__r.pic_advertiser__c != null){
                                        newOrder.pic_advertiser__c = myQuote.Opportunity.brand__r.pic_advertiser__c;
                                    }
                                    
                                    system.System.debug('== myContract +' + myContract);
                                    system.System.debug('== newOrder +' + newOrder);
                                    insert newOrder;
                                    
                                }else{
                                    system.debug('*** Sudah ada ORDER !!!');
                                }
                            }
                        }else{
                            newQuote.addError('Only Closed Won & Approved Opportunity can be set to final Quotation.');
                        }
                    }
                    
                    system.debug('*** myQuote.AccountId = ' + myQuote.AccountId); system.debug('*** myQuote.AccountId = ' + myQuote.AccountId);
                    system.debug('*** myQuote.ContactId = ' + myQuote.ContactId); system.debug('*** myQuote.ContactId = ' + myQuote.ContactId);
                    system.debug('*** myQuote.ContractId = ' + myQuote.ContractId); system.debug('*** myQuote.ContractId = ' + myQuote.ContractId);
                    system.debug('*** myQuote.Discount = ' + myQuote.Discount); system.debug('*** myQuote.Discount = ' + myQuote.Discount);
                    system.debug('*** myQuote.OwnerId = ' + myQuote.OwnerId); system.debug('*** myQuote.OwnerId = ' + myQuote.OwnerId);
                    system.debug('*** myQuote.SOA__c = ' + myQuote.SOA__c); system.debug('*** myQuote.SOA__c = ' + myQuote.SOA__c);
                    system.debug('*** myQuote.SOA_Quotation_No__c = ' + myQuote.SOA_Quotation_No__c); system.debug('*** myQuote.SOA_Quotation_No__c = ' + myQuote.SOA_Quotation_No__c);
                    
                    if(myQuote.AccountId <> oldQuote.AccountId 
                        || myQuote.ContactId <> oldQuote.ContactId 
                        || myQuote.ContractId <> oldQuote.ContractId 
                        || myQuote.Discount <> oldQuote.Discount 
                        || myQuote.OwnerId <> oldQuote.OwnerId 
                        || myQuote.SOA__c <> oldQuote.SOA__c 
                        || myQuote.SOA_Quotation_No__c <> oldQuote.SOA_Quotation_No__c){
                        
                        QuoteBU__c qbu_update = [SELECT Id, Name, Opportunity__c, Owner__c, Quote__c, Account__c, 
                                                    Contact__c, Contract__c, Discount__c, SOA__c, SOA_Quotation_No__c 
                                                 FROM QuoteBU__c WHERE Quote__c =: myQuote.Id];
                            
                        system.debug('*** qbu_update = ' + qbu_update);
                    
                        qbu_update.Account__c = myQuote.AccountId;
                        qbu_update.Contact__c = myQuote.ContactId;
                        qbu_update.Contract__c = myQuote.ContractId;
                        qbu_update.Discount__c = myQuote.Discount;
                        qbu_update.Owner__c = myQuote.OwnerId;
                        qbu_update.SOA__c = myQuote.SOA__c;
                        qbu_update.SOA_Quotation_No__c = myQuote.SOA_Quotation_No__c;
                        
                        list_qbuToUpdate.add(qbu_update);
                            
                        system.debug('*** list_qbuToUpdate loop = ' + list_qbuToUpdate);
                    }
                    
                    if(myQuote.Invoice__c <> oldQuote.Invoice__c){
                        QuoteRecIdListForInvoiceUpdate.add(myQuote.id);
                    }
                }
                
                system.debug('*** list_qbuToUpdate.size() = ' + list_qbuToUpdate.size());
                system.debug('*** list_qbuToUpdate = ' + list_qbuToUpdate);
                
                if(list_qbuToUpdate.size() > 0){
                    update list_qbuToUpdate;
                }

                if(!QuoteRecIdListForInvoiceUpdate.isEmpty()){
                    RefreshInvoiceValueinOrderItem_Batch myBatch = new RefreshInvoiceValueinOrderItem_Batch(QuoteRecIdListForInvoiceUpdate);
                    Database.executeBatch(myBatch);
                }
    
            }
             
           }
       }
    }