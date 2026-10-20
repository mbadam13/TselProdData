global class ScheduleCampMyadsQueueableUpdate implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        List<Campaign_MyAds__c> campList = [Select Id , Name,docToken__c from Campaign_MyAds__c where documentStatus__c='In Progress' limit 50];
        ID jobID = System.enqueueJob(new Schedule_CampMyadsDocQueuebleJob(campList));
        System.debug('jobID'+jobID);
    }
   
}