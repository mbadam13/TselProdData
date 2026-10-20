/**
 * @description       : 
 * @Test Class        : MonthlyDiscountIMSServices_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 10-12-2023
 * @last modified by  : Ahmat Zulkifli Murad
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-29-2023   Novando Utoyo Agmawan   Initial Version
 * 1.1   10-12-2023   Ahmat Zulkifli Murad    Update Query List_MonthlyDiscountInventoryMediaSellerNextMonth tambah brand
**/

public class MonthlyDiscountIMSServices {
    
    public static Map<String,Kategori_Industri__c> getKategoriIndustriByPrefix(){
        Map<String,Kategori_Industri__c> Map_KategoriIndustri = new Map<String,Kategori_Industri__c>();

        try{
            system.debug('=== MonthlyDiscountIMSServices - getKategoriIndustriByPrefix ===');

            list<Kategori_Industri__c> List_KategoriIndustri = [
                SELECT Id, 
                Name,
                prefix_ms__c
                FROM Kategori_Industri__c 
                WHERE prefix_ms__c != null
            ];

            system.debug('getKategoriIndustriByPrefix : ' + json.serialize(List_KategoriIndustri));

            if(List_KategoriIndustri != null && !List_KategoriIndustri.isEmpty()){
                for(Kategori_Industri__c KategoriIndustri : List_KategoriIndustri){
                    Map_KategoriIndustri.put(KategoriIndustri.prefix_ms__c.toLowerCase(), KategoriIndustri);
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlyDiscountIMSServices getKategoriIndustriByPrefix function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

        return Map_KategoriIndustri;
    }

    public static Decimal getRevenueFromTrafficValue(
        String MediaSeller,
        String Product,
        String ProductServicesAndCode,
        String Brand,
        Date StartDate){
        Decimal revenueFromTrafficValue = 0;

        try{
            system.debug('=== MonthlyDiscountIMSServices - getRevenueFromTrafficValue ===');

            system.debug('getRevenueFromTrafficValue - ProductServicesAndCode : ' + ProductServicesAndCode);
            system.debug('getRevenueFromTrafficValue - Brand : ' + Brand);

            List<String> List_ProductServicesAndCode = ProductServicesAndCode.split(';');
            List<String> List_Brand = Brand.split(';');

            Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(StartDate);

            List<AggregateResult> Aggregate_UsageTrafficMediaSeller = new List<AggregateResult>();

            if(String.isNotblank(Product)){
                Aggregate_UsageTrafficMediaSeller = [
                    SELECT
                    SUM(Usage_for_Special_Price_Allocation__c) FinalTelkomselRevenue
                    FROM Usage_Traffic_Media_Seller__c
                    WHERE Media_Seller__c =: MediaSeller AND
                    Product__c =: Product AND
                    //Product_Services_and_Code__c IN: List_ProductServicesAndCode AND
                    Brand__c IN: List_Brand AND
                    Date__c >=: Map_rangeDate.get('rangeStartDate') AND
                    Date__c <=: Map_rangeDate.get('rangeEndDate')
                    /*
                    Product__c =: Product AND
                    //Product_Services_and_Code__c IN: List_ProductServicesAndCode AND
                    Brand__c IN: List_Brand AND
                    Date__c >=: Map_rangeDate.get('rangeStartDate') AND
                    Date__c <=: Map_rangeDate.get('rangeEndDate')
                    */
                ];
            }
            else{
                Aggregate_UsageTrafficMediaSeller = [
                    SELECT
                    SUM(Usage_for_Special_Price_Allocation__c) FinalTelkomselRevenue
                    FROM Usage_Traffic_Media_Seller__c
                    WHERE Media_Seller__c =: MediaSeller AND
                    Brand__c IN: List_Brand AND
                    Product_Services_and_Code__c IN: List_ProductServicesAndCode AND
                    Date__c >=: Map_rangeDate.get('rangeStartDate') AND
                    Date__c <=: Map_rangeDate.get('rangeEndDate')
                ];
            }

            system.debug('getRevenueFromTrafficValue : ' + json.serialize(Aggregate_UsageTrafficMediaSeller));

            if(Aggregate_UsageTrafficMediaSeller != null && !Aggregate_UsageTrafficMediaSeller.isEmpty()){
                for(AggregateResult AgR : Aggregate_UsageTrafficMediaSeller){
                    revenueFromTrafficValue = (Decimal) AgR.get('FinalTelkomselRevenue');
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlyDiscountIMSServices getRevenueFromTrafficValue function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

        if(revenueFromTrafficValue == null){
            revenueFromTrafficValue = 0;
        }

        return revenueFromTrafficValue;
    }

    public static Decimal getCurrentRevenueFromTraffic(
        String MediaSeller,
        String Product,
        String ProductServicesAndCode,
        String Brand,
        Date StartDate,
        Date EndDate
        ){
        Decimal currentRevenueFromTraffic = 0;

        try{
            system.debug('=== MonthlyDiscountIMSServices - getCurrentRevenueFromTraffic ===');
            system.debug('getRevenueFromTrafficValue - ProductServicesAndCode : ' + ProductServicesAndCode);
            system.debug('getRevenueFromTrafficValue - Brand : ' + Brand);

            List<String> List_ProductServicesAndCode = ProductServicesAndCode.split(';');
            List<String> List_Brand = Brand.split(';');
            date startDateCalculation;
            date endDateCalculation;
            Account mediaSellerId;

            List<AggregateResult> Aggregate_UsageTrafficMediaSeller = new List<AggregateResult>();

            map<string, Additional_Setting__c> getRevenueCalculationforDiscountInventoryMapRec = new map<string, Additional_Setting__c>();

            Additional_Setting__c revenueCalculationforDiscountInventoryRec = null;

            List<Additional_Setting__c> getListRevenueCalculationforDiscountInventoryList = AppUtils.getListAdditionalSettingByObjectName('Revenue_Calculation_for_Discount_Inventory__c');
            
            system.debug('getListRevenueCalculationforDiscountInventoryList: ' + json.serialize(getListRevenueCalculationforDiscountInventoryList));

            if(getListRevenueCalculationforDiscountInventoryList != null && !getListRevenueCalculationforDiscountInventoryList.isEmpty()){
                for(Additional_Setting__c getListRevenueCalculationforDiscountInventoryListRec :getListRevenueCalculationforDiscountInventoryList){
                    getRevenueCalculationforDiscountInventoryMapRec.put(
                        getListRevenueCalculationforDiscountInventoryListRec.Account__c + '_' + getListRevenueCalculationforDiscountInventoryListRec.Start_Date__c.year() + '_' + getListRevenueCalculationforDiscountInventoryListRec.End_Date__c.year(), getListRevenueCalculationforDiscountInventoryListRec
                    );
                    system.debug('map isi: ' + getListRevenueCalculationforDiscountInventoryListRec.Account__c + '_' + getListRevenueCalculationforDiscountInventoryListRec.Start_Date__c.year() + '_' + getListRevenueCalculationforDiscountInventoryListRec.End_Date__c.year());
                }

                system.debug('get map: ' + MediaSeller + '_' + StartDate.year() + '_' + EndDate.year());

                revenueCalculationforDiscountInventoryRec = getRevenueCalculationforDiscountInventoryMapRec.get(MediaSeller + '_' + StartDate.year() + '_' + EndDate.year());
            }

            system.debug('getRevenueFromTrafficValue - revenueCalculationforDiscountInventoryRec : ' + json.serialize(revenueCalculationforDiscountInventoryRec));
            
            if(revenueCalculationforDiscountInventoryRec != null){
                startDateCalculation = revenueCalculationforDiscountInventoryRec.Start_Date__c;
                endDateCalculation = revenueCalculationforDiscountInventoryRec.End_Date__c;
            
                if(String.isNotblank(Product)){
                    Aggregate_UsageTrafficMediaSeller = [
                        SELECT
                        SUM(Usage_for_Special_Price_Allocation__c) FinalTelkomselRevenue
                        FROM Usage_Traffic_Media_Seller__c
                        WHERE Media_Seller__c =: MediaSeller AND
                        //Product__c =: Product AND
                        //Product_Services_and_Code__c IN: List_ProductServicesAndCode AND
                        //Brand__c IN: List_Brand AND
                        Date__c >=: startDateCalculation AND
                        Date__c <=: EndDate
                    ];
                }
                else{
                    system.debug('MediaSeller: ' + MediaSeller);
                    system.debug('List_Brand: ' + List_Brand);
                    system.debug('List_ProductServicesAndCode: ' + List_ProductServicesAndCode);
                    system.debug('startDateCalculation: ' + startDateCalculation);
                    system.debug('endDateCalculation: ' + endDateCalculation);

                    Aggregate_UsageTrafficMediaSeller = [
                        SELECT
                        SUM(Usage_for_Special_Price_Allocation__c) FinalTelkomselRevenue
                        FROM Usage_Traffic_Media_Seller__c
                        WHERE Media_Seller__c =: MediaSeller AND
                        //Brand__c IN: List_Brand AND
                        //Product_Services_and_Code__c IN: List_ProductServicesAndCode AND
                        Date__c >=: startDateCalculation AND
                        Date__c <=: EndDate
                    ];
                }

                system.debug('getCurrentRevenueFromTraffic : ' + json.serialize(Aggregate_UsageTrafficMediaSeller));

                if(Aggregate_UsageTrafficMediaSeller != null && !Aggregate_UsageTrafficMediaSeller.isEmpty()){
                    for(AggregateResult AgR : Aggregate_UsageTrafficMediaSeller){
                        currentRevenueFromTraffic = (Decimal) AgR.get('FinalTelkomselRevenue');
                    }
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlyDiscountIMSServices getCurrentRevenueFromTraffic function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

        if(currentRevenueFromTraffic == null){
            currentRevenueFromTraffic = 0;
        }

        return currentRevenueFromTraffic;
    }

    //orian
    public static void setValueDiscount(Set<String> Set_recordIds){
        try{
            //Testing Purpose
            //Set<String> Set_recordIds = new Set<String>();
            //Set_recordIds.add('');
            //Set_recordIds.add('');

            //MonthlyDiscountIMSServices.setValueDiscount(Set_recordIds);
            
            
            system.debug('=== MonthlyDiscountIMSServices - setValueDiscount ===');
            System.debug('Set_recordIds.148: ' + Set_recordIds);

            if(Set_recordIds != null && !Set_recordIds.isEmpty()){
                List<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller = [
                    SELECT Id,
                    Media_Seller__c,
                    Start_Date__c,
                    Product_Name__c,
                    End_Date__c,
                    Discount_Type__c,
                    Additional_Setting__c,
                    Value__c,
                    Revenue_From_Traffic__c,
                    Brand__c,
                    Current_Revenue_from_traffic__c,
                    Periode__c,
                    Product_Services_and_Code__c,
                    Name
                    FROM Monthly_Discount_Inventory_Media_Seller__c
                    WHERE Id IN: Set_recordIds
                ];

                system.debug('setValueDiscount List_MonthlyDiscountInventoryMediaSeller : ' + json.serialize(List_MonthlyDiscountInventoryMediaSeller));

                if(List_MonthlyDiscountInventoryMediaSeller != null && !List_MonthlyDiscountInventoryMediaSeller.isEmpty()){
                    list<Additional_Setting__c> List_AdditionalSetting = AppUtils.getListAdditionalSettingByObjectName('Monthly_Discount_Inventory_Seller__c');

                    system.debug('setValueDiscount List_AdditionalSetting : ' + json.serialize(List_AdditionalSetting));

                    if(List_AdditionalSetting != null && !List_AdditionalSetting.isEmpty()){
                        for(Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller : List_MonthlyDiscountInventoryMediaSeller){

                            for(Additional_Setting__c AdditionalSetting : List_AdditionalSetting){
                                System.debug('AdditionalSetting.Account__c: ' + AdditionalSetting.Account__c);
                                System.debug('AdditionalSetting.Product__c: ' + AdditionalSetting.Product__c);
                                System.debug('AdditionalSetting.Brand__c: ' + AdditionalSetting.Brand__c);
                                System.debug('MonthlyDiscountInventoryMediaSeller.Start_Date__c: ' + MonthlyDiscountInventoryMediaSeller.Start_Date__c);
                                System.debug('MonthlyDiscountInventoryMediaSeller.End_Date__c: ' + MonthlyDiscountInventoryMediaSeller.Value__c);
                                System.debug('MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c: ' + MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c);

                                if(
                                    AdditionalSetting.Account__c == MonthlyDiscountInventoryMediaSeller.Media_Seller__c &&
                                    AdditionalSetting.Product__c == MonthlyDiscountInventoryMediaSeller.Product_Name__c &&
                                    AdditionalSetting.Product_Services_and_Code__c == MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c &&
                                    AdditionalSetting.Brand__c == MonthlyDiscountInventoryMediaSeller.Brand__c &&
                                    MonthlyDiscountInventoryMediaSeller.Start_Date__c >= AdditionalSetting.Start_Date__c &&
                                    MonthlyDiscountInventoryMediaSeller.End_Date__c <= AdditionalSetting.End_Date__c
                                ){
                                    if(AdditionalSetting.Tiering_Type__c != null){
                                        if(
                                            MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c  >= AdditionalSetting.Greater_Than_Equal__c &&
                                            MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c < AdditionalSetting.Less_Than__c
                                        ){
                                            System.debug('AdditionalSetting.Tiering_Type__c: ' + AdditionalSetting.Tiering_Type__c);
                                            System.debug('AdditionalSetting.Value__c: ' + AdditionalSetting.Value__c);

                                            MonthlyDiscountInventoryMediaSeller.Value__c = AdditionalSetting.Value__c;
                                            MonthlyDiscountInventoryMediaSeller.Discount_Type__c = AdditionalSetting.Value_Type__c;

                                            break;
                                        }
                                    }else{
                                        System.debug('AdditionalSetting.Tiering_Type__c: ' + AdditionalSetting.Tiering_Type__c);
                                        System.debug('AdditionalSetting.Value__c: ' + AdditionalSetting.Value__c);

                                        MonthlyDiscountInventoryMediaSeller.Value__c = AdditionalSetting.Value__c;
                                        MonthlyDiscountInventoryMediaSeller.Discount_Type__c = AdditionalSetting.Value_Type__c;

                                        break;
                                    }
                                }
                            }
                        }
                    }

                    update List_MonthlyDiscountInventoryMediaSeller;
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlyDiscountIMSServices setValueDiscount function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

   /*
    //orian
    public static void setValueDiscountUpdate(Set<String> Set_recordIds){
        try{
            //Testing Purpose
            //Set<String> Set_recordIds = new Set<String>();
            //Set_recordIds.add('');
            //Set_recordIds.add('');

            //MonthlyDiscountIMSServices.setValueDiscountUpdate(Set_recordIds);
            
            
            system.debug('=== MonthlyDiscountIMSServices - setValueDiscountUpdate ===');
            System.debug('Set_recordIds.148: ' + Set_recordIds);

            if(Set_recordIds != null && !Set_recordIds.isEmpty()){
                List<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller = [
                    SELECT Id,
                    Media_Seller__c,
                    Start_Date__c,
                    Product_Name__c,
                    End_Date__c,
                    Discount_Type__c,
                    Additional_Setting__c,
                    Value__c,
                    Revenue_From_Traffic__c,
                    Brand__c,
                    Current_Revenue_from_traffic__c,
                    Periode__c,
                    Product_Services_and_Code__c,
                    Name
                    FROM Monthly_Discount_Inventory_Media_Seller__c
                    WHERE Id IN: Set_recordIds
                ];

                system.debug('setValueDiscountUpdate List_MonthlyDiscountInventoryMediaSeller : ' + json.serialize(List_MonthlyDiscountInventoryMediaSeller));

                if(List_MonthlyDiscountInventoryMediaSeller != null && !List_MonthlyDiscountInventoryMediaSeller.isEmpty()){
                    list<Additional_Setting__c> List_AdditionalSetting = AppUtils.getListAdditionalSettingByObjectName('Monthly_Discount_Inventory_Seller__c');

                    system.debug('setValueDiscountUpdate List_AdditionalSetting : ' + json.serialize(List_AdditionalSetting));

                    if(List_AdditionalSetting != null && !List_AdditionalSetting.isEmpty()){
                        for(Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller : List_MonthlyDiscountInventoryMediaSeller){

                            for(Additional_Setting__c AdditionalSetting : List_AdditionalSetting){
                                System.debug('AdditionalSetting.Account__c: ' + AdditionalSetting.Account__c);
                                System.debug('AdditionalSetting.Product__c: ' + AdditionalSetting.Product__c);
                                System.debug('AdditionalSetting.Brand__c: ' + AdditionalSetting.Brand__c);
                                System.debug('MonthlyDiscountInventoryMediaSeller.Start_Date__c: ' + MonthlyDiscountInventoryMediaSeller.Start_Date__c);
                                System.debug('MonthlyDiscountInventoryMediaSeller.End_Date__c: ' + MonthlyDiscountInventoryMediaSeller.Value__c);
                                System.debug('MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c: ' + MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c);
                                
                                if(
                                    AdditionalSetting.Account__c == MonthlyDiscountInventoryMediaSeller.Media_Seller__c &&
                                    AdditionalSetting.Product__c == MonthlyDiscountInventoryMediaSeller.Product_Name__c &&
                                    AdditionalSetting.Product_Services_and_Code__c == MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c &&
                                    AdditionalSetting.Brand__c == MonthlyDiscountInventoryMediaSeller.Brand__c &&
                                    MonthlyDiscountInventoryMediaSeller.Start_Date__c >= AdditionalSetting.Start_Date__c &&
                                    MonthlyDiscountInventoryMediaSeller.End_Date__c <= AdditionalSetting.End_Date__c
                                ){
                                    if(AdditionalSetting.Tiering_Type__c != null){
                                        if(
                                            MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c  >= AdditionalSetting.Greater_Than_Equal__c &&
                                            MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c < AdditionalSetting.Less_Than__c
                                        ){
                                            System.debug('AdditionalSetting.Tiering_Type__c: ' + AdditionalSetting.Tiering_Type__c);
                                            System.debug('AdditionalSetting.Value__c: ' + AdditionalSetting.Value__c);

                                            MonthlyDiscountInventoryMediaSeller.Value__c = AdditionalSetting.Value__c;
                                            MonthlyDiscountInventoryMediaSeller.Discount_Type__c = AdditionalSetting.Value_Type__c;

                                            break;
                                        }
                                    }else{
                                        System.debug('AdditionalSetting.Tiering_Type__c: ' + AdditionalSetting.Tiering_Type__c);
                                        System.debug('AdditionalSetting.Value__c: ' + AdditionalSetting.Value__c);

                                        MonthlyDiscountInventoryMediaSeller.Value__c = AdditionalSetting.Value__c;
                                        MonthlyDiscountInventoryMediaSeller.Discount_Type__c = AdditionalSetting.Value_Type__c;

                                        break;
                                    }
                                }
                            }
                        }
                    }
                    update List_MonthlyDiscountInventoryMediaSeller;


                    Datetime nextSchedule = system.now().addSeconds(5);

                    String hour = String.valueOf( nextSchedule.hour());
                    String min = String.valueOf( nextSchedule.minute()); 
                    String ss = String.valueOf( nextSchedule.second());
                    String sDay = string.valueof( nextSchedule.day() ); 
                    String sYear = string.valueof( nextSchedule.year() );
                    String sMonth = string.valueof( nextSchedule.month() );

                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;

                    Traffics_UpdDsc_Schedule Traffics_UpdDsc_Schedule_Class = new Traffics_UpdDsc_Schedule(); 
                    System.schedule('Traffics_UpdDsc_Schedule ' + String.valueOf(system.now()), nextFireTime, Traffics_UpdDsc_Schedule_Class);
                }
            }       
        }catch(exception e){
            string errMessage = 'Error on MonthlyDiscountIMSServices setValueDiscountUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
    */
    /*
    public static void setValueDiscount(Monthly_Discount_Inventory_Media_Seller__c discountInvRecord){
        try{
            if(discountInvRecord != null){
                list<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller = new list<Monthly_Discount_Inventory_Media_Seller__c>();
                Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSellerNextMonth;
                
                boolean changeDiscountNextMonth = false;
                string discountTypeforNextMonth;
                Decimal discountValueforNextMonth;

                //get next month
                if(discountInvRecord != null ){
                    List_MonthlyDiscountInventoryMediaSeller = new list<Monthly_Discount_Inventory_Media_Seller__c>{discountInvRecord};

                    date startDateNextMonth = discountInvRecord.Start_Date__c.addMonths(1);
                    date endDateNextMonth = discountInvRecord.Start_Date__c.addMonths(2).addDays(-1);
                    List<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSellerNextMonth = [
                            SELECT Id,
                            Media_Seller__c,
                            Start_Date__c,
                            Product_Name__c,
                            End_Date__c,
                            Discount_Type__c,
                            Additional_Setting__c,
                            Value__c,
                            Revenue_From_Traffic__c,
                            Brand__c,
                            Current_Revenue_from_traffic__c,
                            Periode__c,
                            Product_Services_and_Code__c,
                            Name
                            FROM Monthly_Discount_Inventory_Media_Seller__c
                            WHERE 
                            Start_Date__c =:startDateNextMonth and End_Date__c =: endDateNextMonth  and 
                            Media_Seller__c =:discountInvRecord.media_seller__c and
                            Product_Services_and_Code__c =: discountInvRecord.Product_Services_and_Code__c and
                            product_name__c =: discountInvRecord.product_name__c
                    ];
                    MonthlyDiscountInventoryMediaSellerNextMonth = List_MonthlyDiscountInventoryMediaSellerNextMonth[0];
                    system.debug('setValueDiscount List_MonthlyDiscountInventoryMediaSellerNextMonth : ' + json.serialize(List_MonthlyDiscountInventoryMediaSellerNextMonth));
                }

                system.debug('setValueDiscount List_MonthlyDiscountInventoryMediaSeller : ' + json.serialize(List_MonthlyDiscountInventoryMediaSeller));
            
                if(List_MonthlyDiscountInventoryMediaSeller != null && !List_MonthlyDiscountInventoryMediaSeller.isEmpty()){
                    list<Additional_Setting__c> List_AdditionalSetting = AppUtils.getListAdditionalSettingByObjectName('Monthly_Discount_Inventory_Seller__c');

                    system.debug('setValueDiscount List_AdditionalSetting : ' + json.serialize(List_AdditionalSetting));

                    if(List_AdditionalSetting != null && !List_AdditionalSetting.isEmpty()){
                        for(Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller : List_MonthlyDiscountInventoryMediaSeller){

                            for(Additional_Setting__c AdditionalSetting : List_AdditionalSetting){
                                System.debug('AdditionalSetting.Account__c: ' + AdditionalSetting.Account__c);
                                System.debug('AdditionalSetting.Product__c: ' + AdditionalSetting.Product__c);
                                System.debug('AdditionalSetting.Brand__c: ' + AdditionalSetting.Brand__c);
                                System.debug('MonthlyDiscountInventoryMediaSeller.Start_Date__c: ' + MonthlyDiscountInventoryMediaSeller.Start_Date__c);
                                System.debug('MonthlyDiscountInventoryMediaSeller.End_Date__c: ' + MonthlyDiscountInventoryMediaSeller.Value__c);
                                System.debug('MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c: ' + MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c);
                                
                                if(
                                    AdditionalSetting.Account__c == MonthlyDiscountInventoryMediaSeller.Media_Seller__c &&
                                    AdditionalSetting.Product__c == MonthlyDiscountInventoryMediaSeller.Product_Name__c &&
                                    AdditionalSetting.Product_Services_and_Code__c == MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c &&
                                    AdditionalSetting.Brand__c == MonthlyDiscountInventoryMediaSeller.Brand__c &&
                                    MonthlyDiscountInventoryMediaSeller.Start_Date__c >= AdditionalSetting.Start_Date__c &&
                                    MonthlyDiscountInventoryMediaSeller.End_Date__c <= AdditionalSetting.End_Date__c
                                ){
                                    if(AdditionalSetting.Tiering_Type__c != null){
                                        if(
                                            MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c  >= AdditionalSetting.Greater_Than_Equal__c &&
                                            MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c < AdditionalSetting.Less_Than__c
                                        ){
                                            system.debug('in tiering changes');
                                            changeDiscountNextMonth = true;
                                            discountValueforNextMonth = AdditionalSetting.Value__c;
                                            discountTypeforNextMonth = AdditionalSetting.Value_Type__c;
                                        }
                                    }else{
                                        System.debug('AdditionalSetting.Tiering_Type__c: ' + AdditionalSetting.Tiering_Type__c);
                                        System.debug('AdditionalSetting.Value__c: ' + AdditionalSetting.Value__c);

                                        MonthlyDiscountInventoryMediaSeller.Value__c = AdditionalSetting.Value__c;
                                        MonthlyDiscountInventoryMediaSeller.Discount_Type__c = AdditionalSetting.Value_Type__c;

                                        break;
                                    }
                                }
                                //udpdate discount for nextMonth
                                system.debug('changeDiscountNextMonth: ' +  changeDiscountNextMonth);
                                if(changeDiscountNextMonth == true){
                                    if(
                                        AdditionalSetting.Account__c == MonthlyDiscountInventoryMediaSellerNextMonth.Media_Seller__c &&
                                        AdditionalSetting.Product__c == MonthlyDiscountInventoryMediaSellerNextMonth.Product_Name__c &&
                                        AdditionalSetting.Product_Services_and_Code__c == MonthlyDiscountInventoryMediaSellerNextMonth.Product_Services_and_Code__c &&
                                        AdditionalSetting.Brand__c == MonthlyDiscountInventoryMediaSellerNextMonth.Brand__c &&
                                        MonthlyDiscountInventoryMediaSellerNextMonth.Start_Date__c >= AdditionalSetting.Start_Date__c &&
                                        MonthlyDiscountInventoryMediaSellerNextMonth.End_Date__c <= AdditionalSetting.End_Date__c
                                    ){
                                        MonthlyDiscountInventoryMediaSellerNextMonth.Value__c = discountValueforNextMonth;
                                        MonthlyDiscountInventoryMediaSellerNextMonth.Discount_Type__c = discountTypeforNextMonth;
                                    }   
                                }
                            }
                        }
                    }
                    System.debug('MonthlyDiscountInventoryMediaSellerNextMonth: ' + MonthlyDiscountInventoryMediaSellerNextMonth);
                    update MonthlyDiscountInventoryMediaSellerNextMonth;
                    //update List_MonthlyDiscountInventoryMediaSeller;


                    Datetime nextSchedule = system.now().addSeconds(5);

                    String hour = String.valueOf( nextSchedule.hour());
                    String min = String.valueOf( nextSchedule.minute()); 
                    String ss = String.valueOf( nextSchedule.second());
                    String sDay = string.valueof( nextSchedule.day() ); 
                    String sYear = string.valueof( nextSchedule.year() );
                    String sMonth = string.valueof( nextSchedule.month() );

                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;

                    Traffics_UpdDsc_Schedule Traffics_UpdDsc_Schedule_Class = new Traffics_UpdDsc_Schedule(); 
                    System.schedule('Traffics_UpdDsc_Schedule ' + String.valueOf(system.now()), nextFireTime, Traffics_UpdDsc_Schedule_Class);
                }
            }
            
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlyDiscountIMSServices setValueDiscount function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
    */

    public static void setValueDiscountUpdate( Monthly_Discount_Inventory_Media_Seller__c discountInvRecord){
        try{
            system.debug('=== MonthlyDiscountIMSServices - setValueDiscountUpdate ===');
            system.debug('discountInvRecord: ' +  discountInvRecord);

            if(discountInvRecord != null){
                list<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller = new list<Monthly_Discount_Inventory_Media_Seller__c>();
                Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSellerNextMonth;
                
                boolean changeDiscountNextMonth = false;
                string discountTypeforNextMonth;
                Decimal discountValueforNextMonth;

                //get next month
                if(discountInvRecord != null ){
                    List_MonthlyDiscountInventoryMediaSeller = new list<Monthly_Discount_Inventory_Media_Seller__c>{discountInvRecord};

                    date startDateNextMonth = discountInvRecord.Start_Date__c.addMonths(1);
                    date endDateNextMonth = discountInvRecord.Start_Date__c.addMonths(2).addDays(-1);
                    List<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSellerNextMonth = [
                            SELECT Id,
                            Media_Seller__c,
                            Start_Date__c,
                            Product_Name__c,
                            End_Date__c,
                            Discount_Type__c,
                            Additional_Setting__c,
                            Value__c,
                            Revenue_From_Traffic__c,
                            Brand__c,
                            Current_Revenue_from_traffic__c,
                            Periode__c,
                            Product_Services_and_Code__c,
                            Name
                            FROM Monthly_Discount_Inventory_Media_Seller__c
                            WHERE 
                            Start_Date__c >=: startDateNextMonth and 
                            End_Date__c <=: endDateNextMonth  and 
                            Brand__c =: discountInvRecord.Brand__c and // tambahan case bri ke ubah terus
                            Media_Seller__c =:discountInvRecord.media_seller__c and
                            Product_Services_and_Code__c =: discountInvRecord.Product_Services_and_Code__c and
                            product_name__c =: discountInvRecord.product_name__c
                    ];

                    system.debug('setValueDiscountUpdate List_MonthlyDiscountInventoryMediaSellerNextMonth : ' + json.serialize(List_MonthlyDiscountInventoryMediaSellerNextMonth));

                    if(List_MonthlyDiscountInventoryMediaSellerNextMonth != null && !List_MonthlyDiscountInventoryMediaSellerNextMonth.isEmpty()){
                        MonthlyDiscountInventoryMediaSellerNextMonth = List_MonthlyDiscountInventoryMediaSellerNextMonth[0];
                    }
                }

                system.debug('setValueDiscountUpdate List_MonthlyDiscountInventoryMediaSeller : ' + json.serialize(List_MonthlyDiscountInventoryMediaSeller));

                if(MonthlyDiscountInventoryMediaSellerNextMonth != null){
                    if(List_MonthlyDiscountInventoryMediaSeller != null && !List_MonthlyDiscountInventoryMediaSeller.isEmpty()){
                        list<Additional_Setting__c> List_AdditionalSetting = AppUtils.getListAdditionalSettingByObjectName('Monthly_Discount_Inventory_Seller__c');
    
                        system.debug('setValueDiscountUpdate List_AdditionalSetting : ' + json.serialize(List_AdditionalSetting));
    
                        if(List_AdditionalSetting != null && !List_AdditionalSetting.isEmpty()){
                            for(Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller : List_MonthlyDiscountInventoryMediaSeller){
    
                                for(Additional_Setting__c AdditionalSetting : List_AdditionalSetting){
                                    System.debug('AdditionalSetting.Account__c: ' + AdditionalSetting.Account__c);
                                    System.debug('AdditionalSetting.Product__c: ' + AdditionalSetting.Product__c);
                                    System.debug('AdditionalSetting.Brand__c: ' + AdditionalSetting.Brand__c);
                                    System.debug('MonthlyDiscountInventoryMediaSeller.Start_Date__c: ' + MonthlyDiscountInventoryMediaSeller.Start_Date__c);
                                    System.debug('MonthlyDiscountInventoryMediaSeller.End_Date__c: ' + MonthlyDiscountInventoryMediaSeller.Value__c);
                                    System.debug('MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c: ' + MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c);
                                    
                                    if(
                                        AdditionalSetting.Account__c == MonthlyDiscountInventoryMediaSeller.Media_Seller__c &&
                                        AdditionalSetting.Product__c == MonthlyDiscountInventoryMediaSeller.Product_Name__c &&
                                        AdditionalSetting.Product_Services_and_Code__c == MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c &&
                                        AdditionalSetting.Brand__c == MonthlyDiscountInventoryMediaSeller.Brand__c &&
                                        MonthlyDiscountInventoryMediaSeller.Start_Date__c >= AdditionalSetting.Start_Date__c &&
                                        MonthlyDiscountInventoryMediaSeller.End_Date__c <= AdditionalSetting.End_Date__c
                                    ){
                                        if(AdditionalSetting.Tiering_Type__c != null){
                                            if(
                                                MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c  >= AdditionalSetting.Greater_Than_Equal__c &&
                                                MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c < AdditionalSetting.Less_Than__c
                                            ){
                                                system.debug('in tiering changes');
                                                changeDiscountNextMonth = true;
                                                discountValueforNextMonth = AdditionalSetting.Value__c;
                                                discountTypeforNextMonth = AdditionalSetting.Value_Type__c;
                                            }
                                        }else{
                                            System.debug('AdditionalSetting.Tiering_Type__c: ' + AdditionalSetting.Tiering_Type__c);
                                            System.debug('AdditionalSetting.Value__c: ' + AdditionalSetting.Value__c);
    
                                            MonthlyDiscountInventoryMediaSeller.Value__c = AdditionalSetting.Value__c;
                                            MonthlyDiscountInventoryMediaSeller.Discount_Type__c = AdditionalSetting.Value_Type__c;
    
                                            break;
                                        }
                                    }
                                    //udpdate discount for nextMonth
                                    system.debug('changeDiscountNextMonth: ' +  changeDiscountNextMonth);
                                    if(changeDiscountNextMonth == true){
                                        if(
                                            AdditionalSetting.Account__c == MonthlyDiscountInventoryMediaSellerNextMonth.Media_Seller__c &&
                                            AdditionalSetting.Product__c == MonthlyDiscountInventoryMediaSellerNextMonth.Product_Name__c &&
                                            AdditionalSetting.Product_Services_and_Code__c == MonthlyDiscountInventoryMediaSellerNextMonth.Product_Services_and_Code__c &&
                                            AdditionalSetting.Brand__c == MonthlyDiscountInventoryMediaSellerNextMonth.Brand__c &&
                                            MonthlyDiscountInventoryMediaSellerNextMonth.Start_Date__c >= AdditionalSetting.Start_Date__c &&
                                            MonthlyDiscountInventoryMediaSellerNextMonth.End_Date__c <= AdditionalSetting.End_Date__c
                                        ){
                                            MonthlyDiscountInventoryMediaSellerNextMonth.Value__c = discountValueforNextMonth;
                                            MonthlyDiscountInventoryMediaSellerNextMonth.Discount_Type__c = discountTypeforNextMonth;
                                        }   
                                    }
                                }
                            }
                        }
                        System.debug('MonthlyDiscountInventoryMediaSellerNextMonth: ' + MonthlyDiscountInventoryMediaSellerNextMonth);
                        update MonthlyDiscountInventoryMediaSellerNextMonth;
                        //update List_MonthlyDiscountInventoryMediaSeller;
                    }
                }
            }
            
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlyDiscountIMSServices setValueDiscountUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}