@isTest
public with sharing class dataTableSettlementWeekly_ControllerTest {
   
    @TestSetup
    static void makeData(){
        Trigger_Setting__c triggerSettingsRecValidationStartDateIsExist = new Trigger_Setting__c();
        triggerSettingsRecValidationStartDateIsExist.IsActive__c = true;
        triggerSettingsRecValidationStartDateIsExist.name = 'validation:_StartDateIsExist';
        triggerSettingsRecValidationStartDateIsExist.Error_Message__c = 'Tidak bisa membuat additional setting karena sudah tersedia, silahkan buat ditanggal berbeda';
        triggerSettingsRecValidationStartDateIsExist.Object_Name__c = 'Additional_setting__c';

        insert triggerSettingsRecValidationStartDateIsExist;
        
        Trigger_Setting__c triggerSettingsRecValidationDataExchangesRateisExist = new Trigger_Setting__c();
        triggerSettingsRecValidationDataExchangesRateisExist.IsActive__c = true;
        triggerSettingsRecValidationDataExchangesRateisExist.name = 'Validation:_ExcRateisExist';
        triggerSettingsRecValidationDataExchangesRateisExist.Error_Message__c = 'tidak bisa membuat data karena sudah ada dalam periode yang ditentukan';
        triggerSettingsRecValidationDataExchangesRateisExist.Object_Name__c = 'ExchangeRates__c';

        insert triggerSettingsRecValidationDataExchangesRateisExist;  
    }
    
    @isTest 
    static void testCreateOrderforOppty() {
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'    ,
            Reason_by_Settlement__c = 'Reason'  
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

        acc.ContractId__c = contract.Id;
        update acc;
        
        
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
        
        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2023',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2023-09-21'),                                                  // Close Date
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
            SME__c = false,                                                                          // SME
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId()
            
        );
        insert oppRecord;

        contract.Status = 'Activated';
        contract.Opportunity__c = oppRecord.Id;
        update contract;
     
        Id pricebookId = Test.getStandardPricebookId();
        
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
            Description = '500',                                // Product Description
            Business_Product__c = 'Digital Media'
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;
        oppRecord.StageName = 'Closed Won';
        update oppRecord;
        acc.ContractId__c = contract.Id;
        update acc;
        Test.startTest();
       
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2023-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2023-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;
        
        Order newOrder = new order();
            newOrder.SOA__c = soaRecord.id;
            //newOrder.Monthly_Traffic_Unique_Id__c = monthlyTTDListRec.UniqueKey__c;
            newOrder.EffectiveDate = soaRecord.soa_start_date__c;
            newOrder.EndDate = soaRecord.SOA_End_Date__c;
            newOrder.Sales__c = UserInfo.getUserId();
            newOrder.AccountId = acc.id; //mandatory
            newOrder.OpportunityId = oppRecord.id;
            newOrder.Order_Type__c = 'TTD';
            newOrder.Status = 'Draft';
            newOrder.Pricebook2Id = Test.getStandardPricebookId();
        insert newOrder;

        OrderItem newOrderItem = new OrderItem();
            newOrderItem.OrderId = newOrder.Id;
            newOrderItem.PricebookEntryId = pbEntry.id;
            newOrderItem.Product2Id = prod.id;
            newOrderItem.Quantity = 200;
            newOrderItem.UnitPrice = 150;
            newOrderItem.Sales__c = UserInfo.getUserId();
            newOrderItem.ServiceDate = newOrder.EffectiveDate;
            newOrderItem.EndDate = newOrder.EndDate;
           
        insert newOrderItem;

        dataTableSettlementWeekly_Controller.getOrderItem();
        test.stopTest();    
    }
    
    @isTest
    static void getSobjectpicklistValues(){
        dataTableSettlementWeekly_Controller.getSobjectpicklistValues('orderItem', 'Payment_Status__c' );
    }
}