global class ScheduleSIDQueueableUpdate implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        List<SID_Tools__c> campList = [Select Id , Name,docToken__c from SID_Tools__c where documentStatus__c='In Progress' limit 50];
        ID jobID = System.enqueueJob(new Schedule_SIDDocQueuebleJob(campList));
        System.debug('jobID'+jobID);
    }
   
}