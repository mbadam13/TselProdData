public with sharing class PubmaticBilling_Scheaduled implements Schedulable {
    
    public void execute (SchedulableContext sc){
        pubmaticBillingServices.generatePubmatticBilling(system.today().addMonths(-1));
    }

}