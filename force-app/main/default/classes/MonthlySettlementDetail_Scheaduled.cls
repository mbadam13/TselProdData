public with sharing class MonthlySettlementDetail_Scheaduled implements Schedulable {
    public void execute (SchedulableContext sc){
        
        MonthlySettlementDetailServices.getRevenueAdvertiser(system.today().addMonths(-1));
        MonthlySettlementDetailServices.getRevenueDSPFee(system.today().addMonths(-1));
        MonthlySettlementDetailServices.getRevenueFromPublisherShare(system.today().addMonths(-1));
        
    }
}