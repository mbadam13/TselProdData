global class ScheduleQuoteQueueableUpdate implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        List<Quote> QuoteList = [Select Id , Name,docToken__c from Quote where documentStatus__c='In Progress' limit 50];
        ID jobID = System.enqueueJob(new Schedule_QuoteDocQueuebleJob(QuoteList));
        System.debug('jobID'+jobID);
    }
   
}