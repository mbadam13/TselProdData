@isTest
private class ScheduleSOATest {
// Dummy CRON expression: midnight on Feb 28.
// Because this is a test, job executes
// immediately after Test.stopTest().
public static String CRON_EXP = '0 6 * * * ?';

    static testmethod void testScheduledJob() {
        // Create Test Data
        Test.startTest();
        // Schedule the test job
        List<SOA__c> soaList = [Select Id , Name,docToken__c from SOA__c where documentStatus__c='In Progress' limit 50];
        //ID jobID = System.enqueueJob(new Schedule_CampMyadsDocQueuebleJob(campList));
        
        ID jobID = System.schedule('SOA Updates',CRON_EXP,new ScheduleSOAQueueableUpdate());
        // Key thing to Note: Stopping the test will run the job synchronously
        Test.stopTest();
        // Now that the scheduled job has executed,
        //Use System.assertEquals to confirm test success
    }
}