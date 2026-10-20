global class ScheduleSOAQueueableUpdate implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        List<SOA__c> soaList = [Select Id , Name,docToken__c from SOA__c where documentStatus__c='In Progress' limit 50];
        ID jobID = System.enqueueJob(new Schedule_SOADocQueuebleJob(soaList));
        System.debug('jobID'+jobID);
    }
   
}