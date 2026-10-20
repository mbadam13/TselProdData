public class Schedule_CampMyadsDocQueuebleJob implements Queueable, Database.AllowsCallouts {

    private List<Campaign_MyAds__c> lstCampDoc;
    
    public Schedule_CampMyadsDocQueuebleJob(List<Campaign_MyAds__c> lstCampDoctemp){
        this.lstCampDoc= lstCampDoctemp;
    }

    public void execute(QueueableContext context) {
        if(!lstCampDoc.isEmpty()){
            for(Campaign_MyAds__c a: lstCampDoc){
                Schedule_SendCampMyadsDocsUsingRESTAPI.callcekCampMyadDoc(a.Name, a.docToken__c);
            }
        }
        
    }
}