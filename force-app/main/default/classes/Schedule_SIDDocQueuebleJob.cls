public class Schedule_SIDDocQueuebleJob implements Queueable, Database.AllowsCallouts {

    private List<SID_Tools__c> lstCampDoc;
    
    public Schedule_SIDDocQueuebleJob(List<SID_Tools__c> lstCampDoctemp){
        this.lstCampDoc= lstCampDoctemp;
    }

    public void execute(QueueableContext context) {
        if(!lstCampDoc.isEmpty()){
            for(SID_Tools__c a: lstCampDoc){
                Schedule_SendSIDDocsUsingRESTAPI.callcekSIDDoc(a.Name, a.docToken__c);
            }
        }
        
    }
}