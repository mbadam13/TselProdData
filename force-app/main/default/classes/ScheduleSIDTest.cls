@isTest
private class ScheduleSIDTest {
// Dummy CRON expression: midnight on Feb 28.
// Because this is a test, job executes
// immediately after Test.stopTest().
public static String CRON_EXP = '0 6 * * * ?';

    static testmethod void testScheduledJob() {
        // Create Test Data
        Test.startTest();
        // Schedule the test job
        List<SID_Tools__c> campList = [Select Id , Name,docToken__c from SID_Tools__c where documentStatus__c='In Progress' limit 50];
        //ID jobID = System.enqueueJob(new Schedule_SIDDocQueuebleJob(campList));
        
        ID jobID = System.schedule('SID Updates',CRON_EXP,new ScheduleSIDQueueableUpdate());
        // Key thing to Note: Stopping the test will run the job synchronously
        Test.stopTest();
        // Now that the scheduled job has executed,
        //Use System.assertEquals to confirm test success
    }
}