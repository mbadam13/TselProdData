public with sharing class MonthlySettlementServices {
    
    @InvocableMethod(label='refreshMonthlySettlementDetail')
    public static void refreshMonthlySettlementDetail(list<date> rangeDate){
        System.debug('== MonthlySettlementServices.refreshMonthlySettlementDetail ==');
        System.debug('refreshMonthlySettlementDetail.rangeDate: ' + rangeDate);


        MonthlySettlementDetailServices.getRevenueAdvertiser(rangeDate[0]);
        MonthlySettlementDetailServices.getRevenueDSPFee(RangeDate[0]);
        MonthlySettlementDetailServices.getRevenueFromPublisherShare(rangeDate[0]);
        pubmaticBillingServices.generatePubmatticBilling(rangeDate[0]);
    }
}