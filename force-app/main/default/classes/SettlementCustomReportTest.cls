@isTest(seeAllData=true)
private class SettlementCustomReportTest {

    @IsTest
    static void testGenerateAndSendCSV() {
        // Simulasikan Custom Label
        Test.setFixedSearchResults(new List<String>{ 'test@example.com' });

        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES' LIMIT 1];
        User userRec = new User(
            FirstName           = 'Sales',
            LastName            = 'All',
            NIK__c              = '123',
            Username            = 'Sales@digiads.com.invalid',
            Alias               = 'sall',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'Sales@digiads.com.invalid',
            ProfileId           = proRec.Id,
            LocaleSidKey        = 'en_US',
            LanguageLocaleKey   = 'en_US',
            TimeZoneSidKey      = 'America/Los_Angeles'
        );
        insert userRec;
        
        Account accRec = new Account(Name = 'Test Account',Legal_Name__c ='Test Account, PT.',NPWP__c ='1234567890123456');
        insert accRec;
        
        Contact conRec = new Contact(Salutation='Mr',FirstName ='Test',LastName='Contact',AccountId= accRec.Id);
        insert conRec;
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = accRec.Id,
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

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = accRec.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;
        
        Id pricebookId = Test.getStandardPricebookId();
     
        Product2 prod = new Product2(
            Name = 'Test Product 1',
            ProductCode = 'Reward',
            Product_Type__c = 'Data Reward',
            Buying_Method__c = 'I/O',
            Business_Product__c = 'Digital Media',
            Product_Category__c = 'Advertising',
            Family = 'Reward',
            PIC_Product_Type__c = 'Messaging',
            IsActive = true
       );
       insert prod;
       System.Debug('Prod :'+prod);
       System.Debug('Product Id :'+prod.Id);
       
       //Create your pricebook entry
       PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
       );
       System.Debug('pbEntry :'+pbEntry);
       insert pbEntry;
       
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;
        
        
        opp.ContractId = contract.Id;
        opp.Check_PO__c = 'OK';
        opp.OwnerId = userRec.Id;
        opp.StageName = 'Closed Won';
        update opp;
       
        SOA__c soaRecord = new SOA__c(
               OwnerId = userRec.Id,
               Opportunity__c = opp.Id,              // Opportunity
               SOA_Type__c = 'Opportunity',
               Account__c = accRec.Id,
               SOA_Start_Date__c = Date.valueOf('2025-10-01'),  // SOA Start Date
               SOA_End_Date__c = Date.valueOf('2025-10-31'),    // SOA End Date
               SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;
        System.Debug('soaRecord :'+soaRecord);
        
        List<Order> orderRec = [SELECT Id
                                FROM Order
                                WHERE SOA__c = :soaRecord.Id                                       
                               ];
        System.Debug('orderRec.Size :'+orderRec.size());
        System.Debug('orderRec :'+orderRec);
        
        List<OrderItem> orderItemRec = [
            							SELECT Id, OrderItemNumber, Campaign_id__c
                                        FROM OrderItem
                                        //WHERE Order.SOA__c = :soaRecord.Id
                                        WHERE Opportunity_Product__c = :oli.Id                                       
                                       ];
        System.Debug('orderItemRec.Size :'+orderItemRec.size());
        System.Debug('orderItemRec :'+orderItemRec);

        if (!orderItemRec.isEmpty()) {
            // Ambil campaign_id__c dari OrderItem pertama (atau lakukan loop jika ingin banyak)
            String campaignId = orderItemRec[0].Campaign_id__c;
        	System.Debug('Order Item tidak kosong');
            // Buat record Usage__c dan isi Campaign_id__c
            Usage__c usageRec = new Usage__c(          
                Campaign_id__c = campaignId,
                Date__c = Date.valueOf('2025-11-02'),
                Amount__c = 100            
            );
            insert usageRec;
            System.Debug('usageRec :'+usageRec);
            
            List<Usage__c> usageList = [SELECT Id, Name, Campaign_id__c, date__c, Amount__c, Monthly_Sales_Target__c
                                        FROM Usage__c
                                        WHERE Id = :usageRec.Id                                      
                                       ];
            System.Debug('usageList :'+usageList);
		}
    }
    @isTest
    static void testEmptyLabel() {
        // Simulasikan label kosong
        Test.startTest();
        //System.Label.Settlement_Report_Email_recipientEmail1 = '';
        SettlementCustomReport.generateAndSendCSV(); // harus return tanpa error
        Test.stopTest();
    }
}