public class Schedule_SOADocQueuebleJob implements Queueable, Database.AllowsCallouts {

    private List<SOA__c> lstSOADoc;
    
    public Schedule_SOADocQueuebleJob (List<SOA__c> lstSOADoctemp){
        this.lstSOADoc= lstSOADoctemp;
    }

    public void execute(QueueableContext context) {
        if(!lstSOADoc.isEmpty()){
            for(SOA__c a: lstSOADoc){
                Schedule_SendSOADocsUsingRESTAPI.callcekSOADoc(a.Name, a.docToken__c);
            }
        }
        
    }
}