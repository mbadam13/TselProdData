public class Schedule_QuoteDocQueuebleJob implements Queueable, Database.AllowsCallouts {

    private List<Quote> lstQuoteDoc;
    
    public Schedule_QuoteDocQueuebleJob (List<Quote> lstQuoteDoctemp){
        this.lstQuoteDoc= lstQuoteDoctemp;
    }

    public void execute(QueueableContext context) {
        if(!lstQuoteDoc.isEmpty()){
            for(Quote a: lstQuoteDoc){
                Schedule_SendQuoteDocsUsingRESTAPI.callcekQuoteDoc(a.Name, a.docToken__c);
            }
        }
        
    }
}