@isTest
private class ScheduleQuoteTest {
// Dummy CRON expression: midnight on Feb 28.
// Because this is a test, job executes
// immediately after Test.stopTest().
public static String CRON_EXP = '0 6 * * * ?';

    static testmethod void testScheduledJob() {
        // Create Test Data
        Test.startTest();
        // Schedule the test job
        List<Quote> QuoteList = [Select Id , Name,docToken__c from Quote where documentStatus__c='In Progress' limit 50];
        //ID jobID = System.enqueueJob(new Schedule_CampMyadsDocQueuebleJob(campList));
        
        ID jobID = System.schedule('Quote Updates',CRON_EXP,new ScheduleQuoteQueueableUpdate());
        // Key thing to Note: Stopping the test will run the job synchronously
        Test.stopTest();
        // Now that the scheduled job has executed,
        //Use System.assertEquals to confirm test success
    }
}