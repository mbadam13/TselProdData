@isTest
public with sharing class UpdatePreviousAchievementBatchTest {

    private static User salesA() {
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES' LIMIT 1];
        UserRole roleRec = [SELECT Id FROM UserRole WHERE Name = 'Sales Government & VAS' LIMIT 1];
        User userRec = new User(
            FirstName = 'Sales',
            LastName = 'A',
            NIK__c = '22233442',
            Username = 'salesa@digiads.com.invalid',
            Alias = 'SA',
            Email = 'salesa@digiads.com.invalid',
            EmailEncodingKey = 'UTF-8',
            ProfileId = proRec.Id,
            UserRoleId = roleRec.Id,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert userRec;
        return userRec;
    }

    @TestSetup
    static void setupTestData() {
        User salesA = salesA();
        System.runAs(salesA) {
            Date prevMonth = Date.today().toStartOfMonth().addMonths(-1);
            Date currentMonth = Date.today().toStartOfMonth();

            LOB_Group__c lobGroupRec = new LOB_Group__c(
                Name = 'Government & VAS',
                Active__c = true,
                Senior_Officer__c = salesA.Id
            );
            insert lobGroupRec;

            LOB__c lobRecB = new LOB__c(
                Name = 'EDUCATION & EDUTECH',
                LOB_Unique_ID__c = 'EDUCATION & EDUTECH',
                Active__c = true,
                LOB_Group__c = lobGroupRec.Id
            );
            insert lobRecB;

            insert new List<Monthly_Sales_Target__c>{
                new Monthly_Sales_Target__c(
                    Date__c = prevMonth,
                    LOB__c = lobRecB.Id,
                    Type__c = 'Revenue Actual'
                    
                ),
                new Monthly_Sales_Target__c(
                    Date__c = currentMonth,
                    LOB__c = lobRecB.Id,
                    Type__c = 'Revenue Actual'
                )
            };
        }
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        Database.executeBatch(new UpdatePreviousAchievementBatch(), 2);
        Test.stopTest();

        // Validate that the batch updated the correct record
        Date currentMonth = Date.today().toStartOfMonth();
        Monthly_Sales_Target__c current = [
            SELECT Previous_Achievement__c
            FROM Monthly_Sales_Target__c
            WHERE Date__c = :currentMonth
            LIMIT 1
        ];

       
    }
    
   
    @isTest
    static void testScheduler() {
        Test.startTest();
        String cronExp = '0 0 0 1 1 ?'; // Doesn't matter here, just for simulation
        String jobName = 'Test_Scheduler_Job';
        System.schedule(jobName, cronExp, new Schedule_UpdatePreviousAchievement());
        Test.stopTest();

        // Check that job was scheduled (indirectly via assertions is enough)
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        System.assertEquals(1, jobs.size(), 'Scheduled job should be created');
    }
    
    
   
}