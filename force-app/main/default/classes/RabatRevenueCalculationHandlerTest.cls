/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-19-2023
 * @last modified by  : Diky Tampan
**/
@isTest
public class RabatRevenueCalculationHandlerTest {
    
    @isTest
    static void testCreateRabatRevenueItems() {
        Trigger_Setting__c triggerSettingsRecValidationDataRabatisExist = new Trigger_Setting__c();
        triggerSettingsRecValidationDataRabatisExist.Name = 'Validation:DataRabatisExist';
        triggerSettingsRecValidationDataRabatisExist.isActive__c = true;
        triggerSettingsRecValidationDataRabatisExist.object_name__c = 'Rabat_Configuration_Setting__c';
        triggerSettingsRecValidationDataRabatisExist.error_message__c = 'DataRabatisExist';

        insert triggerSettingsRecValidationDataRabatisExist;

        Trigger_Setting__c triggerSettingsRecValidation_CantdeleteWhenRRCUsed = new Trigger_Setting__c();
        triggerSettingsRecValidation_CantdeleteWhenRRCUsed.Name = 'Validation:_CantdeleteWhenRRCUsed';
        triggerSettingsRecValidation_CantdeleteWhenRRCUsed.isActive__c = true;
        triggerSettingsRecValidation_CantdeleteWhenRRCUsed.object_name__c = 'Rabat_Configuration_Setting__c';
        triggerSettingsRecValidation_CantdeleteWhenRRCUsed.error_message__c = '_CantdeleteWhenRRCUsed';

        insert triggerSettingsRecValidation_CantdeleteWhenRRCUsed;       

       Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
           // Opportunity__c = oppRecord.Id
        );
        insert contract;

        contract.Status = 'Activated';
        update contract;

        Contact contactRec = new Contact(
            AccountId = acc.id,       // Account Name
            lastname = 'DigiAds',
            Active__c = false,               // Active?
            Converted_from_Lead__c = false  // Converted from Lead
        );
        insert contactRec;

        Rabat_Configuration_Setting__c rabatConfSetting1 = new Rabat_Configuration_Setting__c(
            Account__c = acc.id,                       // Account
            Start_Date__c = Date.valueOf('2024-01-01'),       // Start Date
            End_Date__c = Date.valueOf('2024-12-31'),         // End Date
            Spending_Amount_Greater_Than__c = 2500000000.00,  // Spending Amount Greater Than (>=)
            Spending_Amount_LessThan__c = 6000000000.00,      // Spending Amount LessThan (<)
            isActive__c = true,                              // isActive
            Group_Incentive__c = 6.00                        // Group Incentive
        );
        insert rabatConfSetting1;

        Rabat_Configuration_Setting__c rabatConfSetting2 = new Rabat_Configuration_Setting__c(
            Account__c = acc.id,                       // Account
            Start_Date__c = Date.valueOf('2024-01-01'),       // Start Date
            End_Date__c = Date.valueOf('2024-12-31'),         // End Date
            Spending_Amount_Greater_Than__c = 6000000001.00,  // Spending Amount Greater Than (>=)
            Spending_Amount_LessThan__c = 10000000000.00,      // Spending Amount LessThan (<)
            isActive__c = true,                              // isActive
            Group_Incentive__c = 8.00                        // Group Incentive
        );
        insert rabatConfSetting2;

        Rabat_Configuration_Setting__c rabatConfSetting3 = new Rabat_Configuration_Setting__c(
            Account__c = acc.id,                       // Account
            Start_Date__c = Date.valueOf('2024-01-01'),       // Start Date
            End_Date__c = Date.valueOf('2024-12-31'),         // End Date
            Spending_Amount_Greater_Than__c = 10000000001.00,  // Spending Amount Greater Than (>=)
            Spending_Amount_LessThan__c = 999999999999999.00,      // Spending Amount LessThan (<)
            isActive__c = true,                              // isActive
            Group_Incentive__c = 10.00                        // Group Incentive
        );
        insert rabatConfSetting3;
        
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
         Brand__c brand = new Brand__c(Name = 'BCA');
     insert brand;
        list<opportunity> newOpptyList = new list<opportunity>();
        for(integer i = 1; i <= 1; i++){
            Opportunity oppRecord = new Opportunity(
                RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
                Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
                AccountId = acc.Id,                                                           // Account Name
                CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
                Account_Type__c = 'Agency',                                                              // Account Type
                StageName = 'Proposal',                                                                // Stage
                Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
                Probability = 100,                                                                       // Probability (%)
                Agency_Name__c = acc.Id,                                                      // Agency Name
                Campaign_Customize__c = false,                                                           // Campaign Customize
                Templated_Proposal__c = true,                                                            // Own Proposal?
                Approval_Remark__c = 'Approved',                                                         // Approval Remark
                Document_Version__c = 'Submit',                                                          // Document Version
                Approval_Status__c = 'Approved',                                                         // Approval Status
                Marketing_Package__c = false,                                                            // Marketing Package
                SME__c = false,      
                ContractId = contract.id,                                                                    // SME
                Brand__c = brand.Id,                                                            // Brand
                Type = 'Existing Business',                                                              // Type
                Penagihan_based_on__c = 'prepaid',                                                      // Penagihan based on
                Performance_Product__c = false,                                                          // Performance Product
                Programmatic_Product__c = false,                                                         // Programmatic Product
                Performance_Done__c = false,                                                             // Performance Done
                RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
                Check_PO__c = 'OK',
                Pricebook2Id = Test.getStandardPricebookId()
            );

            newOpptyList.add(oppRecord);
        }
        
        insert newOpptyList;

        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            IsActive = true,                                    // Active
            Family = 'Messaging',                               // Product Family
            Product_Type__c = 'SMS',                            // Product Type
            ProductCode = 'SMS',                                // Product Code
            Ads_Format__c = 'Text',                             // Ads Format
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            Ads_Size__c = 'Standard',                           // Ads Size
            Product_Channel__c = 'Mobile',                      // Product Channel
            Channel_Detail__c = 'Mobile',                       // Channel Detail
            Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500'                                // Product Description
        );
        insert prod;
        
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        list<OpportunityLineItem> OpportunityLineItem = new list<OpportunityLineItem>();
        for(opportunity newOpptyListRec :newOpptyList){
            OpportunityLineItem OLI = new OpportunityLineItem();
            OLI.OpportunityId = newOpptyListRec.Id; 
            OLI.PricebookEntryId = pbEntry.id; 
            OLI.Quantity = 331;
            OLI.UnitPrice = 15000;
            
            OpportunityLineItem.add(OLI);
        }

        insert OpportunityLineItem;

        list<opportunity> oppptyToUpdate = new list<opportunity>();
        for(opportunity newOpptyListRec :newOpptyList){
            newOpptyListRec.stagename = 'closed won';
            
            oppptyToUpdate.add(newOpptyListRec);
        }
        update oppptyToUpdate;
        System.debug('oppptyToUpdate: ' + oppptyToUpdate);

        list<Quote> QuoteList = new list <Quote>();
        for(opportunity oppptyToUpdateRec :oppptyToUpdate){
        Quote quotation = new Quote();
            quotation.name = 'asd';
            quotation.OpportunityId = oppptyToUpdateRec.id;
            quotation.ContactId = contactRec.id;
            quotation.Start_Date__c = date.newinstance(2024, 10, 01);
            quotation.End_Date__c = date.newinstance(2024, 10, 30);
            
            QuoteList.add(quotation);
        }

        insert QuoteList;
        System.debug('QuoteList: ' + QuoteList);

        list<quote> quoteListafterUpdate = new list<Quote>();
        set<string> quoteListafterUpdateIds = new set<string>();
        for(quote QuoteListRec :QuoteList){
            QuoteListRec.Upload_Bukti_Pembayaran__c = true;
            QuoteListRec.Invoice_Status__c = 'Done';
            QuoteListRec.Invoice_Finance__c = 'Done';
            QuoteListRec.Invoice_Finance__c = 'Done';
            QuoteListRec.Invoice_Date__c = date.newinstance(2024, 10, 02);
            
            update QuoteListRec;
            quoteListafterUpdate.add(QuoteListRec);
            
        }

        System.debug('quoteListafterUpdate: ' + quoteListafterUpdate);
        for(quote QuoteListRec :quoteListafterUpdate){
            QuoteListRec.Status = 'final';
            
            update QuoteListRec;

            quoteListafterUpdateIds.add(QuoteListRec.id);
        }

        System.debug('quoteListafterUpdateIds: ' + quoteListafterUpdateIds);
        list<Order> orderList = [
            select
            id, 
            QuoteId
            ,opportunity.accountid
            ,opportunityId
            ,opportunity.Agency_Name__c
            ,opportunity.brand__c
            
            FROM Order
            
            where QuoteId IN:quoteListafterUpdateIds
        ];

        System.debug('orderList: ' + orderList);
        set<id> orderIds = new set<id>();
        for(Order OrderListRec :orderList){
            orderIds.add(OrderListRec.id);
        }

        list<OrderItem> orderitemlist = [select id, campaign_id__c from orderitem where orderid in:orderIds ];

        system.debug('orderitemlist : ' + json.serialize(orderitemlist));
        set<string> orderitemIds = new set<string>();
        for(OrderItem orderitemlistRec :orderitemlist){
        orderitemIds.add(orderitemlistRec.id);
        }
		

        Test.startTest();
        list<usage__c> usageList = new List<usage__c>();
        list<orderItem> newOrderItemList = [select id, campaign_id__c from orderItem item where id in:orderitemIds];
        for(OrderItem newOrderItemListRec :newOrderItemList){
            system.debug('newOrderItemListRec.Campaign_ID__: ' + newOrderItemListRec.Campaign_ID__c);
            usage__c newUsageRec = new usage__c();
            
            newUsageRec.nik__c = '87152';
            newUsageRec.amount__c = 331;
            newUsageRec.bucket_detail__c = newOrderItemListRec.id;
            newUsageRec.date__c = date.newinstance(2024, 10, 11);
            newUsageRec.Campaign_ID__c = newOrderItemListRec.Campaign_ID__c;
            
            usageList.add(newUsageRec);

            System.debug('newUsageRec: ' + newUsageRec);
        }
        
        insert usageList;
        Rabat_Revenue_Calculation__c sobj = new Rabat_Revenue_Calculation__c(
            Start_Date__c = Date.valueOf('2024-01-01'),// Start Date
            End_Date__c = Date.valueOf('2024-12-31'),    // End Date
            Account__c = acc.id                    // Account
        );
        insert sobj;
        Test.stopTest();
        
    }
}