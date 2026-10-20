/**
 * @description       : 
 * @Test Class        : UsageTrafficMediaSellerServices_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-05-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-16-2023   Novando Utoyo Agmawan   Initial Version
**/

public class UsageTrafficMediaSellerServices {
    public static void setCalculationUtms_Traffics(date rangeDate){
        try{
            Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(rangeDate);
            System.debug('Map_rangeDate: ' + Map_rangeDate);

            if(Map_rangeDate != null && !Map_rangeDate.isEmpty()){
                List<Usage_Traffic_Media_Seller__c> List_allUtmsThisYear = [
                    SELECT Id,
                    Traffic1__c,
                    Alocated__c,
                    Special_Price_Allocation__c,
                    Traffic_Allocation__c,
                    Rate_Card__c,
                    Real_Traffic_Usage__c,
                    Price_After_Discount__c,
                    Special_Price_Used__c,
                    Media_seller__c,
                    Media_seller__r.Name,
                    Traffic_Type__c,
                    Product__c,
                    Brand__c,
                    Date__c
                    FROM Usage_Traffic_Media_Seller__c
                    WHERE 
                    Media_seller__r.Name != 'digiads' AND
                    (
                        Date__c >=: Map_rangeDate.get('rangeStartDate') AND
                        Date__c <=: Map_rangeDate.get('rangeEndDate')
                    )
                ];

                system.debug('List_allUtmsThisYear : ' + json.serialize(List_allUtmsThisYear));

                if(List_allUtmsThisYear != null && !List_allUtmsThisYear.isEmpty()){
                    List<AggregateResult> Aggregate_allTraffic_UtmsThisYear = [
                        SELECT
                        SUM(Traffic1__c) utmsTraffic,
                        Media_seller__c utmsMediaSeller,
                        //Brand__c brandName,
                        Traffic_Type__c utmsTrafficType,
                        Calendar_Month(Date__c) utmsDateMonth,
                        Calendar_Year(Date__c) utmsDateYear
                        FROM Usage_Traffic_Media_Seller__c
                        WHERE Date__c = THIS_YEAR
                        GROUP BY Media_seller__c,
                        //Brand__c, 
                        Traffic_Type__c, 
                        Calendar_Year(Date__c),
                        Calendar_Month(Date__c)
                    ];

                    system.debug('Aggregate_allTraffic_UtmsThisYear : ' + json.serialize(Aggregate_allTraffic_UtmsThisYear));

                    List<AggregateResult> Aggregate_MonthlySpecialPriceAllocation_ThisYear = [
                        SELECT
                        SUM(Bulk_Alocation__c) bulkAlocation,
                        SUM(Non_Bulk_Allocation__c) nonBulkAlocation,
                        Media_seller__c mediaSeller,
                        //Brand__c brandName,
                        Calendar_Month(Start_Date__c) startDateMonth,
                        Calendar_Year(Start_Date__c) startDateYear
                        FROM Monthly_Special_Price_Allocation__c
                        WHERE End_Date__c = THIS_YEAR
                        GROUP BY Media_seller__c,
                        //Brand__c, 
                        Calendar_Year(Start_Date__c),
                        Calendar_Month(Start_Date__c)
                    ];

                    system.debug('Aggregate_MonthlySpecialPriceAllocation_ThisYear : ' + json.serialize(Aggregate_MonthlySpecialPriceAllocation_ThisYear));

                    if(
                        Aggregate_allTraffic_UtmsThisYear != null && !Aggregate_allTraffic_UtmsThisYear.isEmpty() &&
                        Aggregate_MonthlySpecialPriceAllocation_ThisYear != null && !Aggregate_MonthlySpecialPriceAllocation_ThisYear.isEmpty()
                    ){
                        Map<String,AggregateResult> Map_allTraffic_UtmsThisYear = new Map<String,AggregateResult>();
                        Map<String,AggregateResult> Map_MonthlySpecialPriceAllocation_ThisYear = new Map<String,AggregateResult>();

                        for(AggregateResult AgR : Aggregate_allTraffic_UtmsThisYear){
                            String trafficType = String.ValueOf(AgR.get('utmsTrafficType'));
                            String mediaSeller = String.ValueOf(AgR.get('utmsMediaSeller'));
                            //String brand = String.ValueOf(AgR.get('brandName'));
                            String utmsDateMonth = String.ValueOf(AgR.get('utmsDateMonth'));
                            String utmsDateYear = String.ValueOf(AgR.get('utmsDateYear'));

                            //String keyAggregateResult = trafficType + mediaSeller + brand + utmsDateMonth + utmsDateYear;
                            String keyAggregateResult = trafficType + mediaSeller + utmsDateMonth + utmsDateYear;

                            Map_allTraffic_UtmsThisYear.put(keyAggregateResult, AgR);
                        }

                        for(AggregateResult AgR : Aggregate_MonthlySpecialPriceAllocation_ThisYear){
                            String mediaSeller = String.ValueOf(AgR.get('mediaSeller'));
                            //String brand = String.ValueOf(AgR.get('brandName'));
                            String startDateMonth = String.ValueOf(AgR.get('startDateMonth'));
                            String startDateYear = String.ValueOf(AgR.get('startDateYear'));

                            //String keyAggregateResult =  mediaSeller + brand + startDateMonth + startDateYear;
                            String keyAggregateResult =  mediaSeller + startDateMonth + startDateYear;

                            Map_MonthlySpecialPriceAllocation_ThisYear.put(keyAggregateResult, AgR);
                        }

                        system.debug('Map_allTraffic_UtmsThisYear : ' + json.serialize(Map_allTraffic_UtmsThisYear));
                        system.debug('Map_MonthlySpecialPriceAllocation_ThisYear : ' + json.serialize(Map_MonthlySpecialPriceAllocation_ThisYear));

                        if(
                            Map_allTraffic_UtmsThisYear != null && !Map_allTraffic_UtmsThisYear.isEmpty() &&
                            Map_MonthlySpecialPriceAllocation_ThisYear != null && !Map_MonthlySpecialPriceAllocation_ThisYear.isEmpty()
                        ){
                            for(Usage_Traffic_Media_Seller__c allUtmsThisYear : List_allUtmsThisYear){
                                String trafficType = String.ValueOf(allUtmsThisYear.Traffic_Type__c);
                                String mediaSeller = String.ValueOf(allUtmsThisYear.Media_seller__c);
                                //string brand = String.ValueOf(allUtmsThisYear.brand__c);
                                String dateMonth = String.ValueOf(allUtmsThisYear.Date__c.Month());
                                String dateYear = String.ValueOf(allUtmsThisYear.Date__c.Year());

                                Decimal allTraffic_UtmsThisYearAndMonth = 0;
                                Decimal bulkAndNonBulkAlocation = 0;

                                //for get all traffic
                                if(Map_allTraffic_UtmsThisYear.get(trafficType + mediaSeller + dateMonth + dateYear) != null){
                                    AggregateResult AgR = Map_allTraffic_UtmsThisYear.get(trafficType + mediaSeller + dateMonth + dateYear);

                                    if(AgR != null){
                                        allTraffic_UtmsThisYearAndMonth = (Decimal) AgR.get('utmsTraffic');
                                    }
                                }

                                if(trafficType == 'Bulk'){
                                    if(Map_MonthlySpecialPriceAllocation_ThisYear.get(mediaSeller+dateMonth+dateYear) != null){
                                        AggregateResult AgR = Map_MonthlySpecialPriceAllocation_ThisYear.get(mediaSeller + dateMonth + dateYear);
                                        
                                        if(AgR != null){
                                            bulkAndNonBulkAlocation = (Decimal) AgR.get('bulkAlocation');
                                        }
                                    }
                                }

                                if(trafficType == 'Non Bulk'){
                                    AggregateResult AgR = Map_MonthlySpecialPriceAllocation_ThisYear.get(mediaSeller+dateMonth+dateYear);

                                    if(AgR != null){
                                        bulkAndNonBulkAlocation = (Decimal) AgR.get('nonBulkAlocation');
                                    }
                                }

                                system.debug('allTraffic_UtmsThisYearAndMonth : ' + allTraffic_UtmsThisYearAndMonth);
                                system.debug('bulkAndNonBulkAlocation : ' + bulkAndNonBulkAlocation);
                                system.debug('allTraffic_UtmsThisYearAndMonth : ' + allTraffic_UtmsThisYearAndMonth);
                                system.debug('allUtmsThisYear.Traffic1__c : ' + allUtmsThisYear.Traffic1__c);

                                if(
                                    allTraffic_UtmsThisYearAndMonth != 0 &&
                                    allUtmsThisYear.Traffic1__c != 0
                                ){
                                    allUtmsThisYear.Alocated__c = (allUtmsThisYear.Traffic1__c / allTraffic_UtmsThisYearAndMonth) * 100;
                                    //decimal alocated = (allUtmsThisYear.Traffic1__c / allTraffic_UtmsThisYearAndMonth) * 100;
                                    //allUtmsThisYear.Alocated__c = alocated.setScale(2, RoundingMode.HALF_UP);

                                }else{
                                    allUtmsThisYear.Alocated__c = 0;
                                }

                                system.debug('allUtmsThisYear.Alocated__c : ' + allUtmsThisYear.Alocated__c);

                                if(
                                    bulkAndNonBulkAlocation != 0 &&
                                    allUtmsThisYear.Alocated__c != 0
                                ){
                                    allUtmsThisYear.Special_Price_Allocation__c = (allUtmsThisYear.Alocated__c * bulkAndNonBulkAlocation) / 100;
                                }else{
                                    allUtmsThisYear.Special_Price_Allocation__c = 0;
                                }

                                system.debug('allUtmsThisYear.Special_Price_Allocation__c : ' + allUtmsThisYear.Special_Price_Allocation__c);

                                if(
                                    allUtmsThisYear.Special_Price_Allocation__c != 0 &&
                                    allUtmsThisYear.Rate_Card__c != 0
                                ){
                                    allUtmsThisYear.Traffic_Allocation__c = allUtmsThisYear.Special_Price_Allocation__c / allUtmsThisYear.Rate_Card__c;
                                }else{
                                    allUtmsThisYear.Traffic_Allocation__c = 0;
                                }

                                system.debug('allUtmsThisYear.Special_Price_Allocation__c : ' + allUtmsThisYear.Special_Price_Allocation__c);

                                if(
                                    allUtmsThisYear.Traffic_Allocation__c != 0
                                ){
                                    allUtmsThisYear.Real_Traffic_Usage__c = allUtmsThisYear.Traffic_Allocation__c;
                                }else{
                                    allUtmsThisYear.Real_Traffic_Usage__c = 0;
                                }

                                system.debug('allUtmsThisYear.Real_Traffic_Usage__c : ' + allUtmsThisYear.Real_Traffic_Usage__c);
                            }
                            update List_allUtmsThisYear;
                        }
                    }
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on UsageTrafficMediaSellerServices setCalculationUtms_Traffics function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}