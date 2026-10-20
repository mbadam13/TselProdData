@isTest()
public class IptvSpotDailyStatusServices_Test {

    private static User createUser() {
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES' LIMIT 1];
        UserRole roleRec = [SELECT Id, Name, PortalRole FROM UserRole WHERE Name='SALES DA' LIMIT 1];
        User userRec = new User(
            FirstName           = 'Admin',
            LastName            = 'TV Ads',
            NIK__c              = '444999',
            Username            = 'admintv@digiads.com.invalid',
            Alias               = 'AdmTV',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'admintv@digiads.com.invalid',
            ProfileId           = proRec.Id,
            UserRoleId          = roleRec.Id,
            LocaleSidKey        = 'en_US',
            LanguageLocaleKey   = 'en_US',
            TimeZoneSidKey      = 'America/Los_Angeles'
        );
        insert userRec;
        return userRec;
    }

    @TestSetup
    static void makeData() {
        User testUser = createUser();

        System.runAs(testUser) {

            Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            Account acc = new Account(
                Name = 'Wira Pamungkas Pratama #2',
                RecordTypeId = recordTypeAccId,
                Account_Type__c = 'Agency',
                Direct_Indirect__c = 'Direct',
                Status__c = 'Approved by Settlement',
                No_PKS__c = '123456',
                NPWP__c = '1234567890123456',
                NPWP_Address__c = 'Jakarta',
                PKS_Tracker__c = 'Pending',
                Reason_by_Settlement__c = 'reason'
            );
            insert acc;

            Contact contactRec = new Contact(
                AccountId = acc.id,
                Title = 'Planner',
                Email = 'test@gmail.com',
                Phone = '231313123123',
                LastName = 'user1',
                MobilePhone = '231313123123',
                Active__c = true,
                Priority__c = 'Priority 1',
                Converted_from_Lead__c = false
            );
            insert contactRec;

            Contract contract = new Contract(
                StartDate = Date.valueOf('2019-09-01'),
                ContractTerm = 9999,
                AccountId = acc.Id,
                OwnerExpirationNotice = '120',
                Status = 'Draft',
                Terminate__c = false,
                Archive__c = false,
                No_PKS__c = '123456',
                Contract_Signed__c = 'Circulation'
            );
            insert contract;

            contract.Status = 'Activated';
            update contract;

            Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();

            acc.ContractId__c = contract.Id;
            update acc;

            Id pricebookId = Test.getStandardPricebookId();

            Product2 prod = new Product2(
                Name = 'BULK (SMS Premium)',
                IsActive = true,
                Family = 'Messaging',
                Product_Type__c = 'SMS',
                ProductCode = 'SMS',
                Ads_Format__c = 'Text',
                Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',
                Ads_Size__c = 'Standard',
                Product_Channel__c = 'Mobile',
                Channel_Detail__c = 'Mobile',
                Buying_Method__c = 'I/O',
                Rate_Card_Refference__c = 'Messaging',
                List_Price__c = 500.00,
                Business_Product__c = 'Digital Media',
                Product_Category__c = 'Advertising',
                Description = '500'
            );
            insert prod;

            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pbEntry;

            Opportunity oppRecord = new Opportunity(
                RecordTypeId = recordTypeOppId,
                Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',
                AccountId = acc.Id,
                CloseDate = Date.valueOf('2024-09-21'),
                Account_Type__c = 'Agency',
                StageName = 'Proposal',
                Regional__c = 'HEAD OFFICE',
                Probability = 100,
                Agency_Name__c = acc.Id,
                Campaign_Customize__c = false,
                Templated_Proposal__c = true,
                Approval_Remark__c = 'Approved',
                Document_Version__c = 'Submit',
                Approval_Status__c = 'Approved',
                Marketing_Package__c = false,
                SME__c = false,
                Type = 'Existing Business',
                Penagihan_based_on__c = 'Postpaid',
                Performance_Product__c = false,
                Programmatic_Product__c = false,
                Performance_Done__c = false,
                RFP_Status_sales__c = 'Completed',
                Check_PO__c = 'OK',
                Pricebook2Id = Test.getStandardPricebookId(),
                OwnerId = testUser.Id            
            );
            insert oppRecord;

            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = oppRecord.Id,
                Product2Id = prod.Id,
                Discount__c = 0.00,
                PricebookEntryId = pbEntry.Id,
                UnitPrice = 500.00,
                Quantity = 1234.00
            );
            insert oli;

            oppRecord.StageName = 'Closed Won';
            update oppRecord;

            Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
            Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

            SOA__c soaRecord = new SOA__c(
                Opportunity__c = oppRecord.Id,
                SOA_Type__c = 'Opportunity',
                SOA_Start_Date__c = startDate,
                SOA_End_Date__c = endDate,
                SOA_Sources__c = 'Opportunity'
            );
            insert soaRecord;

            Order order = new Order(
                Status = 'Draft',
                SOA__c = soaRecord.Id,
                EffectiveDate = Date.newInstance(2024, 12, 01),
                EndDate = Date.newInstance(2024, 12, 31),
                AccountId = acc.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                OwnerId=testUser.Id
            );
            insert order;

            OrderItem orderItem = new OrderItem();
            orderItem.OrderId = order.id; 
            orderItem.Product2Id = prod.Id;
            orderItem.PricebookEntryId = pbEntry.id;
            orderItem.Quantity = 10; 
            orderItem.UnitPrice = 100.00; 
            insert orderItem;

            Media_Order__c aMediaOrder = new Media_Order__c(
                Name = 'TSEL/TMS0000003/Admin TV Ads/7/2024',
                Order_Item_ID__c = '0000013121',
                Product_Name__c = 'TVC PLATINUM (Regular) 120" AllPlay.ent',
                House_Number__c = 'CRHD2102053',
                Brand__c = 'Mie Sedaap Soto',
                Versi__c = '15',
                Channel__c = 'AllPlay.ent',
                Product_Inventory__c = 'TVC PLATINUM',
                Showtimes__c = 'REGULAR TIME',
                Time__c = '00.00 - 17.00',
                Duration__c = 120,
                Start_Date__c = System.date.today(),
                End_Date__c = System.date.today()+30,
                Quantity__c = 10,
                Net__c = 5000000.00,
                Amount__c = 0.00,
                Order_Product__c = orderItem.Id,
                Order__c = order.Id
            );
            insert aMediaOrder;

            IPTV_Channel__c IPTVChannelMO = new IPTV_Channel__c(
                Name = 'AllPlay.ent Test', 
                Product_Inventory__c = 'TVC PLATINUM TEST', 
                Keyword__c = 'PLATINUM JAYA'  
            );
            insert IPTVChannelMO;
            

            IPTV_Inventory__c IPTVInventoryMO = new IPTV_Inventory__c(
               Name                    = 'AFN PRIME TIME',
            IPTV_Channels__c        = IPTVChannelMO.Id,
            Show_Time__c            = 'PRIME TIME',
            Time__c                 = '17.00 - 24.00',
            keyword__c              = 'all',
            Type__c                 = 'IPTV',
            Product_Inventory__c    = 'TVC PLATINUM;TVC ROS',
                OwnerId = testUser.Id 
            );
            insert IPTVInventoryMO;

            IPTV_Spot_Limit__c IPTVSpotLimit1 = new IPTV_Spot_Limit__c(
                Name = 'SL / AllPlay.ent / REGULAR TIME / 1-31/1/2024',
                IPTV_Inventory__c = IPTVInventoryMO.Id,
                is_Active__c = true,
                Spot_Limit__c = 4320,
                Start_Date__c = system.today(),
                End_Date__c = system.today()
            );
            insert IPTVSpotLimit1;

            IPTV_Spot_Daily_Status__c IptvSDS1 = new IPTV_Spot_Daily_Status__c(
                Name = 'SDS / AllPlay.ent / REGULAR TIME / 2024 - 1 - 1',
                Date__c = system.today(),
                IPTV_Spot_Limit__c = IPTVSpotLimit1.Id,
                Inventory_Name__c = IPTVInventoryMO.Id
            );
            insert IptvSDS1;

            List<Media_Order_Item__c> mediaOrderItems = new List<Media_Order_Item__c>();
            for (Integer i = 0; i < 9; i++) {
                Media_Order_Item__c aMOI = new Media_Order_Item__c(
                    Name = 'TSEL/TMS0000003/Admin TV Ads/7/2024/'+i,
                    Media_Order__c = aMediaOrder.Id,
                    Order_Product__c = orderItem.Id,
                    Product_Name__c = 'TVC PLATINUM (Regular) 120" AllPlay.ent',
                    House_Number__c = 'CRHD2102053',
                    Versi__c = '15',
                    Duration__c = 120,
                    Date__c = System.date.today(),
                    Time__c = '00.00 - 17.00',
                    Net__c = 5000000.00,
                    Amount__c = 0.00,
                    IPTV_Spot_Daily_Status__c=IptvSDS1.Id,
                    Inventory_Name__c = IPTVInventoryMO.Id,
                    Channel__c = 'AllPlay.ent'
                );
                mediaOrderItems.add(aMOI);
            }
            insert mediaOrderItems;
        }
    }

    @isTest
    static void MediaOrdeUpdateDataApproved() {
         User userRec                = [SELECT Id FROM User WHERE Username = 'admintv@digiads.com.invalid'];
        Media_Order_Item__c MOItemRec = [SELECT Id, Media_Order__r.Order__c FROM Media_Order_Item__c WHERE House_Number__c = 'CRHD2102053' LIMIT 1];
        String OrderIdMoItemRec = MOItemRec.Media_Order__r.Order__c;

        Order OrderRec = [SELECT Id, OwnerId FROM Order WHERE Id = :OrderIdMoItemRec LIMIT 1];
        OrderRec.Approval_Status__c = 'Approved';

        Test.startTest();
        update OrderRec;

       Set<String> setOrderIds = new Set<String>{OrderRec.Id};
        IptvSpotDailyStatusServices.countSpotDailyInApproval(setOrderIds);
        Test.stopTest();
    }

    @isTest
    static void MediaOrdeUpdateDataNeedtoRevise() {
        User userRec                = [SELECT Id FROM User WHERE Username = 'admintv@digiads.com.invalid'];
        Media_Order_Item__c MOItemRec = [SELECT Id, Media_Order__r.Order__c FROM Media_Order_Item__c WHERE House_Number__c = 'CRHD2102053' LIMIT 1];
        String OrderIdMoItemRec = MOItemRec.Media_Order__r.Order__c;

        Order OrderRec = [SELECT Id, OwnerId FROM Order WHERE Id = :OrderIdMoItemRec LIMIT 1];
        OrderRec.Approval_Status__c = 'Submit';

        Test.startTest();
        update OrderRec;
        Set<String> setOrderIds = new Set<String>{OrderRec.Id};
        IptvSpotDailyStatusServices.countSpotDailyApproved(setOrderIds);
        Test.stopTest();
    }
    
     @isTest
    static void MediaOrdeUpdateDataNoNeedtoRevise() {
        User userRec                = [SELECT Id FROM User WHERE Username = 'admintv@digiads.com.invalid'];
        Media_Order_Item__c MOItemRec = [SELECT Id, Media_Order__r.Order__c FROM Media_Order_Item__c WHERE House_Number__c = 'CRHD2102053' LIMIT 1];
        String OrderIdMoItemRec = MOItemRec.Media_Order__r.Order__c;

        Order OrderRec = [SELECT Id, OwnerId FROM Order WHERE Id = :OrderIdMoItemRec LIMIT 1];
        OrderRec.Approval_Status__c = 'Approved';

        Test.startTest();
        update OrderRec;
        Set<String> setOrderIds = new Set<String>{OrderRec.Id};
        IptvSpotDailyStatusServices.countSpotDailyApproved(setOrderIds);
        Test.stopTest();
    }

    @isTest
    static void testMethodD() {
        IPTV_Channel__c IPTVChannel1 = new IPTV_Channel__c(
            Name = 'AllPlay.ent', 
            Product_Inventory__c = 'TVC PLATINUM', 
            Keyword__c = 'PLATINUM'     
        );
        insert IPTVChannel1;

        IPTV_Inventory__c IPTVInventory1 = new IPTV_Inventory__c(
            Name                    = 'AFN PRIME TIME',
            IPTV_Channels__c        = IPTVChannel1.Id,
            Show_Time__c            = 'PRIME TIME',
            Time__c                 = '17.00 - 24.00',
            keyword__c              = 'all',
            Type__c                 = 'IPTV',
            Product_Inventory__c    = 'TVC PLATINUM;TVC ROS'
        );
        insert IPTVInventory1;

        IPTV_Spot_Limit__c IPTVSpotLimit1 = new IPTV_Spot_Limit__c(
            Name = 'SL / AllPlay.ent / REGULAR TIME / 1-31/1/2024',
            IPTV_Inventory__c = IPTVInventory1.Id,
            is_Active__c = true,
            Spot_Limit__c = 4320,
            Start_Date__c = system.today(),
            End_Date__c = system.today()
        );
        insert IPTVSpotLimit1;

        IPTV_Spot_Daily_Status__c IptvSDS1 = new IPTV_Spot_Daily_Status__c(
            Name = 'SDS / AllPlay.ent / REGULAR TIME / 2024 - 1 - 1',
            Date__c = system.today(),
            IPTV_Spot_Limit__c = IPTVSpotLimit1.Id,
            Inventory_Name__c = IPTVInventory1.Id
        );
        insert IptvSDS1;

        Test.startTest();  
        IPTVInventory1.Current_Spotlimit__c = IPTVSpotLimit1.Id;
        update IPTVInventory1;

        Set<String> Set_IptvInventoriIds = new Set<String>();
        Set_IptvInventoriIds.Add(IPTVInventory1.Id);

        List<IPTV_Spot_Limit__c> spotLimits = new List<IPTV_Spot_Limit__c>();
        spotLimits.add(IPTVSpotLimit1);

        IptvSpotDailyStatusServices.getMapRecordWithRanged(Set_IptvInventoriIds, system.today(), system.today());
        IPTVSpotlimitservice.createYearlyRecords(2024, 3400, IPTVInventory1.Id);
        IPTVSpotlimitservice.createCustomDateRangeRecords(system.today(), system.today() + 15, 3400, IPTVInventory1.Id);
        IPTVSpotlimitservice.createDailySpotLimitRecords(spotLimits);
        IPTVSpotlimitservice.getMOItemOnIPTVDailyStatus(IPTVSpotLimit1.Id);
        Test.stopTest();
    }
    
    
    @isTest
    private static void test_MediaOrderItemExpController() {
         User userRec                = [SELECT Id FROM User WHERE Username = 'admintv@digiads.com.invalid'];
        Id MOItemRec = [SELECT Id, Media_Order__r.Order__c FROM Media_Order_Item__c WHERE House_Number__c = 'CRHD2102053' LIMIT 1].Id;
        
        Test.startTest();
        String contentCSV = MediaOrderItemExpController.getMediaOrderItems(MOItemRec);
        Test.stopTest();
    
        // Asserts
        System.assertEquals(true, String.isNotBlank(contentCSV));
    }

    @isTest
    private static void test_MediaOrderItemOrderExp() {
         User userRec                = [SELECT Id FROM User WHERE Username = 'admintv@digiads.com.invalid'];
        Media_Order_Item__c MOItemRec = [SELECT Id, Media_Order__r.Order__c FROM Media_Order_Item__c WHERE House_Number__c = 'CRHD2102053' LIMIT 1];
        String OrderIdMoItemRec = MOItemRec.Media_Order__r.Order__c;

        Id OrderRec = [SELECT Id, OwnerId FROM Order WHERE Id = :OrderIdMoItemRec LIMIT 1].Id;
        // Run Test
        Test.startTest();
        String contentCSV = MediaOrderItemExpController.getMediaOrderItemsByOrderId(OrderRec);
        Test.stopTest();
    
        // Asserts
        System.assertEquals(true, String.isNotBlank(contentCSV));
    }
}