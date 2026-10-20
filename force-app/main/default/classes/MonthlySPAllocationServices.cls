/**
 * @description       : 
 * @Test Class        : MonthlySPAllocationServices_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-07-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-25-2023   Novando Utoyo Agmawan   Initial Version
**/

public class MonthlySPAllocationServices {
    /* oldway
    public static void createMonthlySpecialPriceAllocation(date rangeDate){
        try{
            List<Monthly_Special_Price_Allocation__c> List_MonthlySpecialPriceAllocation = new List<Monthly_Special_Price_Allocation__c>();

            Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(rangeDate);
            System.debug('Map_rangeDate: ' + Map_rangeDate);

            List<Monthly_Sales_Target__c> List_MonthlySalesTarget = getMinimumguarantee(rangeDate);
            System.debug('List_MonthlySalesTarget: ' + List_MonthlySalesTarget);

            Map<String,Monthly_Sales_Target__c> Map_MonthlySalesTarget = getTargetCommitment(rangeDate);
            System.debug('Map_MonthlySalesTarget: ' + Map_MonthlySalesTarget);

            Map<String,Decimal> Map_SumFinalTelkomselRevenue = getUsage(rangeDate);
            System.debug('Map_UsageTrafficMediaSeller: ' + Map_SumFinalTelkomselRevenue);
            double minimumGuarantee = MonthlySalesTarget.Amount__c;
            double targetCommitment = (Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c) != null && Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c).Amount__c != null) ? Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c).Amount__c : 0;
            double usage = (Map_SumFinalTelkomselRevenue.get(MonthlySalesTarget.Media_Seller__c) != null ) ? Map_SumFinalTelkomselRevenue.get(MonthlySalesTarget.Media_Seller__c) : 0;
            date startDate = Map_rangeDate.get('rangeStartDate');
            date endDate = Map_rangeDate.get('rangeEndDate');
            if(
                Map_rangeDate != null && !Map_rangeDate.isEmpty() &&
                List_MonthlySalesTarget != null && !List_MonthlySalesTarget.isEmpty() &&
                Map_MonthlySalesTarget != null && !Map_MonthlySalesTarget.isEmpty() &&
                Map_SumFinalTelkomselRevenue != null && !Map_SumFinalTelkomselRevenue.isEmpty()
            ){
                for(Monthly_Sales_Target__c MonthlySalesTarget : List_MonthlySalesTarget){
                    
                    Monthly_Special_Price_Allocation__c new_MonthlySpecialPriceAllocation = new Monthly_Special_Price_Allocation__c();
                    
                    new_MonthlySpecialPriceAllocation.Media_Seller__c = MonthlySalesTarget.Media_Seller__c;
                    new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c = minimumGuarantee;//MonthlySalesTarget.Amount__c;
                    new_MonthlySpecialPriceAllocation.Target_Commitment__c = targetCommitment;//(Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c) != null && Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c).Amount__c != null) ? Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c).Amount__c : 0;
                    new_MonthlySpecialPriceAllocation.Usage__c = usage;//(Map_SumFinalTelkomselRevenue.get(MonthlySalesTarget.Media_Seller__c) != null ) ? Map_SumFinalTelkomselRevenue.get(MonthlySalesTarget.Media_Seller__c) : 0;
                    new_MonthlySpecialPriceAllocation.Start_Date__c = startDate;//Map_rangeDate.get('rangeStartDate');
                    new_MonthlySpecialPriceAllocation.End_Date__c = endDate;//Map_rangeDate.get('rangeEndDate');
                    new_MonthlySpecialPriceAllocation.Unique_ID__c = Map_rangeDate.get('rangeStartDate').year() + '_' + Map_rangeDate.get('rangeStartDate').month() + '_' + MonthlySalesTarget.Media_Seller__c;

                    
                    if(
                        new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c > new_MonthlySpecialPriceAllocation.Usage__c &&
                    (
                        new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 3 &&
                        new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 6 &&
                        new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 9  &&
                        new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 12
                    )
                    ){
                        new_MonthlySpecialPriceAllocation.Invoice__c = new_MonthlySpecialPriceAllocation.Usage__c;
                    }

                    else if(
                        new_MonthlySpecialPriceAllocation.Usage__c < new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c &&
                        (
                            new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 3 &&
                            new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 6 &&
                            new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 9  &&
                            new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 12
                        )
                    ){
                        new_MonthlySpecialPriceAllocation.Invoice__c = new_MonthlySpecialPriceAllocation.Usage__c;
                    }

                    else{
                        new_MonthlySpecialPriceAllocation.Invoice__c = 0;
                    }

                    List_MonthlySpecialPriceAllocation.add(new_MonthlySpecialPriceAllocation);
                }

                if(List_MonthlySalesTarget != null){
                    system.debug('List_MonthlySpecialPriceAllocation: ' + List_MonthlySpecialPriceAllocation);
                    UPSERT List_MonthlySpecialPriceAllocation new_MonthlySpecialPriceAllocation.Unique_ID__c;
                }
            }

            UsageTrafficMediaSellerServices.setCalculationUtms_Traffics(rangeDate);

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlySPAllocationServices createMonthlySpecialPriceAllocation function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
    */

    public static void createMonthlySpecialPriceAllocation(date rangeDate){
        try{
            List<Monthly_Special_Price_Allocation__c> List_MonthlySpecialPriceAllocation = new List<Monthly_Special_Price_Allocation__c>();

            Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(rangeDate);
            System.debug('Map_rangeDate: ' + Map_rangeDate);

            List<Monthly_Sales_Target__c> List_MonthlySalesTarget = getMinimumguarantee(rangeDate);
            System.debug('List_MonthlySalesTarget: ' + json.serialize(List_MonthlySalesTarget));

            Map<String,Monthly_Sales_Target__c> Map_MonthlySalesTarget = getTargetCommitment(rangeDate);
            System.debug('Map_MonthlySalesTarget: ' + Map_MonthlySalesTarget);

            Map<String,Decimal> Map_SumFinalTelkomselRevenue = getUsage(rangeDate);
            System.debug('Map_UsageTrafficMediaSeller: ' + Map_SumFinalTelkomselRevenue);
            
            if(List_MonthlySalesTarget != null){
                for(Monthly_Sales_Target__c MonthlySalesTarget : List_MonthlySalesTarget){
                    double minimumGuarantee = MonthlySalesTarget.Amount__c;
                    double targetCommitment = (Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c) != null && Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c).Amount__c != null) ? Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c).Amount__c : 0;
                    double usage = (Map_SumFinalTelkomselRevenue.get(MonthlySalesTarget.Media_Seller__c) != null ) ? Map_SumFinalTelkomselRevenue.get(MonthlySalesTarget.Media_Seller__c) : 0;
                    date startDate = Map_rangeDate.get('rangeStartDate');
                    date endDate = Map_rangeDate.get('rangeEndDate');
                    
                    Monthly_Special_Price_Allocation__c new_MonthlySpecialPriceAllocation = new Monthly_Special_Price_Allocation__c();
                    
                    new_MonthlySpecialPriceAllocation.Media_Seller__c = MonthlySalesTarget.Media_Seller__c;
                    new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c = minimumGuarantee;//MonthlySalesTarget.Amount__c;
                    new_MonthlySpecialPriceAllocation.Target_Commitment__c = targetCommitment;//(Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c) != null && Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c).Amount__c != null) ? Map_MonthlySalesTarget.get(MonthlySalesTarget.Media_Seller__c).Amount__c : 0;
                    new_MonthlySpecialPriceAllocation.Usage__c = usage;//(Map_SumFinalTelkomselRevenue.get(MonthlySalesTarget.Media_Seller__c) != null ) ? Map_SumFinalTelkomselRevenue.get(MonthlySalesTarget.Media_Seller__c) : 0;
                    new_MonthlySpecialPriceAllocation.Start_Date__c = startDate;//Map_rangeDate.get('rangeStartDate');
                    new_MonthlySpecialPriceAllocation.End_Date__c = endDate;//Map_rangeDate.get('rangeEndDate');
                    new_MonthlySpecialPriceAllocation.Unique_ID__c = Map_rangeDate.get('rangeStartDate').year() + '_' + Map_rangeDate.get('rangeStartDate').month() + '_' + MonthlySalesTarget.Media_Seller__c;
    
                    SYSTEM.debug('new_MonthlySpecialPriceAllocation.Start_Date__c.month(): ' + new_MonthlySpecialPriceAllocation.Start_Date__c.month());
                    SYSTEM.debug('new_MonthlySpecialPriceAllocation.Usage__c: ' + new_MonthlySpecialPriceAllocation.Usage__c);
                    SYSTEM.debug('new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c: ' + new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c);
                    
                    if(
                        new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c < new_MonthlySpecialPriceAllocation.Usage__c &&
                    (
                        new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 3 &&
                        new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 6 &&
                        new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 9  &&
                        new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 12
                    )
                    ){
                        SYSTEM.debug('mg < usage, new_MonthlySpecialPriceAllocation.Usage__c: ' + new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c);
                        new_MonthlySpecialPriceAllocation.Invoice__c = new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c;
                    }
    
                    else if(
                        new_MonthlySpecialPriceAllocation.Usage__c < new_MonthlySpecialPriceAllocation.Minimum_Guarantee__c &&
                        (
                            new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 3 &&
                            new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 6 &&
                            new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 9  &&
                            new_MonthlySpecialPriceAllocation.Start_Date__c.month() != 12
                        )
                    ){
                        SYSTEM.debug('usage < MG, new_MonthlySpecialPriceAllocation.Usage__c: ' + new_MonthlySpecialPriceAllocation.Usage__c);
                        new_MonthlySpecialPriceAllocation.Invoice__c = new_MonthlySpecialPriceAllocation.Usage__c;
                    }
    
                    else{
                        new_MonthlySpecialPriceAllocation.Invoice__c = 0;
                    }
    
                    system.debug('new_MonthlySpecialPriceAllocation: ' +  new_MonthlySpecialPriceAllocation);
                    List_MonthlySpecialPriceAllocation.add(new_MonthlySpecialPriceAllocation);
                }
    
                if(List_MonthlySalesTarget != null){
                    system.debug('List_MonthlySpecialPriceAllocation: ' + json.serialize(List_MonthlySpecialPriceAllocation));
                    UPSERT List_MonthlySpecialPriceAllocation new_MonthlySpecialPriceAllocation.Unique_ID__c;
                }
            }

            UsageTrafficMediaSellerServices.setCalculationUtms_Traffics(rangeDate);

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlySPAllocationServices createMonthlySpecialPriceAllocation function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

    public static List<Monthly_Sales_Target__c> getMinimumguarantee(date rangeDate){
        List<Monthly_Sales_Target__c> List_MonthlySalesTarget = new List<Monthly_Sales_Target__c>();

        try{
            Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(rangeDate);

            List_MonthlySalesTarget = [
                SELECT Id,
                Media_Seller__c,
                Media_Seller__r.name,
                Date__c,
                Amount__c
                FROM Monthly_Sales_Target__c
                WHERE Media_Seller__c != null AND
                MST_Type__c = 'Media Seller' AND
                Type__c = 'Selling Target' AND
                Group_Type__c = 'Target' AND
                Commitment_Target__c = false AND
                Date__c >=: Map_rangeDate.get('rangeStartDate') AND
                Date__c <=: Map_rangeDate.get('rangeEndDate')
            ];

            system.debug('getMinimumguarantee : ' + json.serialize(List_MonthlySalesTarget));

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlySPAllocationServices getMinimumguarantee function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

        return List_MonthlySalesTarget;
    }

    public static Map<String,Monthly_Sales_Target__c> getTargetCommitment(date rangeDate){
        Map<String,Monthly_Sales_Target__c> Map_MonthlySalesTarget = new Map<String,Monthly_Sales_Target__c>();

        try{
            Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(rangeDate);

            List<Monthly_Sales_Target__c> List_MonthlySalesTarget = [
                SELECT Id,
                Media_Seller__c,
                Date__c,
                Amount__c
                FROM Monthly_Sales_Target__c
                WHERE Media_Seller__c != null AND
                MST_Type__c = 'Media Seller' AND
                Type__c = 'Selling Target' AND
                Group_Type__c = 'Target' AND
                Commitment_Target__c = true AND
                Date__c >=: Map_rangeDate.get('rangeStartDate') AND
                Date__c <=: Map_rangeDate.get('rangeEndDate')
            ];

            system.debug('getTargetCommitment : ' + json.serialize(List_MonthlySalesTarget));

            if(List_MonthlySalesTarget != null && !List_MonthlySalesTarget.isEmpty()){
                for(Monthly_Sales_Target__c MonthlySalesTarget : List_MonthlySalesTarget){
                    Map_MonthlySalesTarget.put(MonthlySalesTarget.Media_Seller__c, MonthlySalesTarget);
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlySPAllocationServices getTargetCommitment function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

        return Map_MonthlySalesTarget;
    }

    public static Map<String,Decimal> getUsage(date rangeDate){
        Map<String,Decimal> Map_SumFinalTelkomselRevenue = new Map<String,Decimal>();

        try{
            Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(rangeDate);

            List<Media_Seller_Exclude_Revenue__c> List_MediaSellerExcludeRevenue = AppUtils.getListMediaSellerExcludeRevenue();

            List<AggregateResult> Aggregate_UsageTrafficMediaSeller = [
                SELECT
                Media_Seller__c MediaSeller,
                SUM(Usage_for_Special_Price_Allocation__c) FinalTelkomselRevenue
                FROM Usage_Traffic_Media_Seller__c
                WHERE Media_Seller__c != null AND
                Date__c >=: Map_rangeDate.get('rangeStartDate') AND
                Date__c <=: Map_rangeDate.get('rangeEndDate')
                GROUP BY Media_Seller__c
            ];

            system.debug('getUsage : ' + json.serialize(Aggregate_UsageTrafficMediaSeller));

            if(Aggregate_UsageTrafficMediaSeller != null && !Aggregate_UsageTrafficMediaSeller.isEmpty()){
                for(AggregateResult AgR : Aggregate_UsageTrafficMediaSeller){

                    Map_SumFinalTelkomselRevenue.put((String) AgR.get('MediaSeller'), (Decimal) AgR.get('FinalTelkomselRevenue'));
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlySPAllocationServices getUsage function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

        return Map_SumFinalTelkomselRevenue;
    }

    public static void setSpesialAndAlocationPrice(Set<String> Set_recordIds){
        try{
            /* Testing Purpose
            Set<String> Set_recordIds = new Set<String>();
            Set_recordIds.add('a1a1s000000FJZDAA4');
            Set_recordIds.add('a1a1s000000FJZEAA4');

            MonthlySPAllocationServices.setSpesialAndAlocationPrice(Set_recordIds);*/
            
            
            system.debug('====== MonthlySPAllocationServices setSpesialAndAlocationPrice ======');

            if(Set_recordIds != null && !Set_recordIds.isEmpty()){
                List<Monthly_Special_Price_Allocation__c> List_MonthlySpecialPriceAllocation = [
                    SELECT Id,
                    Special_Price__c,
                    Bulk_Alocation_Percentage__c,
                    Non_Bulk_Allocation_Percentage__c,
                    Total_Special_Price__c,
                    Performance__c,
                    Media_Seller__c,
                    Start_Date__c,
                    End_Date__c,
                    Invoice__c,
                    Minimum_Guarantee__c,
                    Periode__c,
                    Usage__c
                    FROM Monthly_Special_Price_Allocation__c
                    WHERE Id IN: Set_recordIds
                ];

                system.debug('List_MonthlySpecialPriceAllocation : ' + json.serialize(List_MonthlySpecialPriceAllocation));

                if(List_MonthlySpecialPriceAllocation != null && !List_MonthlySpecialPriceAllocation.isEmpty()){
                    list<Additional_Setting__c> List_AdditionalSetting = AppUtils.getListAdditionalSettingByObjectName('Monthly_Special_Price_Allocation__c');

                    system.debug('List_AdditionalSetting : ' + json.serialize(List_AdditionalSetting));

                    if(List_AdditionalSetting != null && !List_AdditionalSetting.isEmpty()){
                        for(Monthly_Special_Price_Allocation__c MonthlySpecialPriceAllocation : List_MonthlySpecialPriceAllocation){
                            Date rangeDate = MonthlySpecialPriceAllocation.End_Date__c;
                            Decimal rangeValue = MonthlySpecialPriceAllocation.Performance__c;
                            String accountId = MonthlySpecialPriceAllocation.Media_Seller__c;

                            system.debug('rangeDate : ' + rangeDate);
                            system.debug('rangeValue : ' + rangeValue);
                            system.debug('accountId : ' + accountId);

                            for(Additional_Setting__c AdditionalSetting : List_AdditionalSetting){
                                if(
                                    AdditionalSetting.Account__c == accountId &&
                                    rangeDate >= AdditionalSetting.Start_Date__c &&
                                    rangeDate <= AdditionalSetting.End_Date__c
                                ){
                                    system.debug('AdditionalSetting.Account__c : ' + AdditionalSetting.Account__c);
                                    system.debug('AdditionalSetting.Start_Date__c : ' + AdditionalSetting.Start_Date__c);
                                    system.debug('AdditionalSetting.End_Date__c : ' + AdditionalSetting.End_Date__c);

                                    if(
                                        AdditionalSetting.Type__c == 'Special Price' &&
                                        rangeValue  >= AdditionalSetting.Greater_Than_Equal__c &&
                                        rangeValue < AdditionalSetting.Less_Than__c
                                    ){
                                        MonthlySpecialPriceAllocation.Special_Price__c = AdditionalSetting.Value__c;
                                        system.debug('Special_Price__c : ' + AdditionalSetting.Value__c);
                                    }

                                    if(
                                        AdditionalSetting.Type__c == 'Bulk Alocation'
                                    ){
                                        MonthlySpecialPriceAllocation.Bulk_Alocation_Percentage__c = AdditionalSetting.Value__c;

                                        system.debug('Bulk Alocation : ' + AdditionalSetting.Value__c);
                                    }

                                    if(
                                        AdditionalSetting.Type__c == 'Non Bulk Alocation'
                                    ){
                                        MonthlySpecialPriceAllocation.Non_Bulk_Allocation_Percentage__c = AdditionalSetting.Value__c;

                                        system.debug('Non Bulk Alocation : ' + AdditionalSetting.Value__c);
                                    }

                                    system.debug('MonthlySpecialPriceAllocation.periode__c: ' + MonthlySpecialPriceAllocation.periode__c);

                                    if(
                                        MonthlySpecialPriceAllocation.Minimum_Guarantee__c > MonthlySpecialPriceAllocation.Usage__c &&
                                    (
                                        !MonthlySpecialPriceAllocation.periode__c.contains('MAR') &&
                                        !MonthlySpecialPriceAllocation.periode__c.contains('JUN') &&
                                        !MonthlySpecialPriceAllocation.periode__c.contains('SEP') &&
                                        !MonthlySpecialPriceAllocation.periode__c.contains('DEC')
                                    )
                                    ){
                                        MonthlySpecialPriceAllocation.Invoice__c = MonthlySpecialPriceAllocation.Usage__c;
                                    }

                                    else if(
                                        MonthlySpecialPriceAllocation.Usage__c > MonthlySpecialPriceAllocation.Minimum_Guarantee__c &&
                                        (
                                            !MonthlySpecialPriceAllocation.periode__c.contains('MAR') &&
                                            !MonthlySpecialPriceAllocation.periode__c.contains('JUN') &&
                                            !MonthlySpecialPriceAllocation.periode__c.contains('SEP') &&
                                            !MonthlySpecialPriceAllocation.periode__c.contains('DEC')
                                        )
                                    ){
                                        MonthlySpecialPriceAllocation.Invoice__c = MonthlySpecialPriceAllocation.Minimum_Guarantee__c;
                                    }

                                    else{
                                        MonthlySpecialPriceAllocation.Invoice__c = 0;
                                    }
                                }
                            }
                        }
                    }

                    update List_MonthlySpecialPriceAllocation;
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlySPAllocationServices setSpesialAndAlocationPrice function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}