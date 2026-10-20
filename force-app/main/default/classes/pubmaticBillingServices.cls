/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
global with sharing class pubmaticBillingServices {

    public static map<string, monthly_settlement__c> mapMonthlySettlement = new map<string, monthly_settlement__c>();
    //get Monthly Settlement
    global static list<monthly_settlement__c> getMonthlySettlement(){
        System.debug('in getMonthlySettlement');
        
        list<monthly_settlement__c> monthmonthlySettlementList = [
            SELECT  Id, 
                    OwnerId, 
                    Name, 
                    CreatedById, 
                    LastModifiedById, 
                    Date__c, 
                    unique_key__c,
                    Total_Revenue_Net__c, 
                    Total_Revenue_Advertiser_Payment__c, 
                    Total_DSP_Fee__c, 
                    Total_Publisher_Share__c, 
                    Month__c 
                    FROM Monthly_Settlement__c 
        ];

        return monthmonthlySettlementList;

    }
    //TODO: dibuatkan perbulan tahun dan per site name
    global static void  generatePubmatticBilling(date rangeDate){
        try {
            integer rangeYear = rangeDate.year();
            integer rangeMonth = rangeDate.month();
            System.debug('rangeYear: ' + rangeYear);
            System.debug('rangeMonth: ' + rangeMonth);

            Date rangeStartDate = rangeDate.toStartOfMonth();//date.newInstance(rangeYear, rangeMonth, 1); system.debug('rangeStartDate: ' + rangeStartDate);
            Date rangeEndDate = rangeDate.addMonths(1).toStartofMonth().addDays(-1);//date.newInstance(rangeYear, rangeMonth +1, 1).addDays(-1); system.debug('rangeEndDate: ' + rangeEndDate);

            Additional_Setting__c additionalRec =  apputils.getAdditionalValue('VAT', 'VAT', rangeStartDate);
            
            //get exchangeRate from berita acara
            Double exchangeRate = 0;
           
            Map<string, Berita_Acara__c> mapBeritaAcara = new map<string, Berita_Acara__c>();
            list<berita_acara__c> beritaAcaraList = [SELECT Id, Name, account__r.name, account__c, Exchange_Rate__c, BA_unique_key__c FROM Berita_Acara__c 
                                                    WHERE Month_Number__c =: rangeMonth AND year__c =: string.valueof(rangeYear)];
            if(beritaAcaraList != null){
                for(Berita_Acara__c beritaAcaraRec: beritaAcaraList){
                    //exchangeRate = beritaAcaraRec.exchange_rate__c;
                    mapBeritaAcara.put(beritaAcaraRec.BA_unique_key__c,  beritaAcaraRec);
                }
            }
            System.debug('mapBeritaAcara: ' + mapBeritaAcara);
            list<AggregateResult> pubmaticBillingAggregatList = [   select Sites__r.Domain__r.Account__c publisherId,
                                                                    Sites__r.Site_ID__c siteId, 
                                                                    Sites__c siteSFID,
                                                                    calendar_year(Date__c) dateYear, 
                                                                    calendar_month(Date__c) dateMonth,
                                                                    
                                                                    SUM(Paid_Impressions__c) paidImpression,
                                                                    SUM(Revenue_USD__c) revenueUSD,
                                                                    SUM(Net_Revenue__c) netRevenueUSD

                                                                    from traffic__c
                                                                    
                                                                    WHERE Date__c >= :rangeStartDate and Date__c <= :rangeEndDate
                                                                    and (NOT deal__c like '%TADEX_OMP_%')

                                                                    GROUP BY 
                                                                    Sites__r.Domain__r.Account__c ,
                                                                    Sites__r.Site_ID__c,
                                                                    Sites__c,
                                                                    calendar_year(Date__c), 
                                                                    calendar_month(Date__c)
                                                                    
            ];
            
            //map to get monthly settlement details record
            map<string, Monthly_Settlement_Detail__c> monthluSettlementDetailMap = new map <string, Monthly_Settlement_Detail__c>();
            list<pubmatic_billing__c> newPubmaticBillingRecList = new list<pubmatic_billing__c>();
            if(pubmaticBillingAggregatList.size() > 0 ){

                //get list of monthly settlement
                list<monthly_settlement__c> getMonthlySettlementList = getMonthlySettlement();

                if(getMonthlySettlementList.size() > 0 ){
                    for(monthly_settlement__c getMonthlySettlementListRec :getMonthlySettlementList){
                        mapMonthlySettlement.put(getMonthlySettlementListRec.unique_key__c, getMonthlySettlementListRec);
                        System.debug('mapMonthlySettlement: ' + mapMonthlySettlement);
                    }
                }

                for(AggregateResult pubmaticBillingAggregatListRec :pubmaticBillingAggregatList){
                    monthly_settlement__c getMonthlySettlementMapRec = new monthly_settlement__c();
                    Monthly_Settlement__c newMonthlySettlementObj = new Monthly_Settlement__c();

                    id accountId = (id) pubmaticBillingAggregatListRec.get('publisherId');
                    string siteId = (string) pubmaticBillingAggregatListRec.get('siteId');
                    id siteSFId = (id) pubmaticBillingAggregatListRec.get('siteSFID');
                    string dateMonth = (string) string.valueOf(pubmaticBillingAggregatListRec.get('dateMonth'));
                    string dateYear = (string) string.valueOf(pubmaticBillingAggregatListRec.get('dateYear'));
                    Double paidImpression = (Double) pubmaticBillingAggregatListRec.get('paidImpression');
                    Double revenueUSD = (Double) pubmaticBillingAggregatListRec.get('revenueUSD');
                    Double netRevenueUSD = (Double) pubmaticBillingAggregatListRec.get('netRevenueUSD');
                    string convertDateMonth = ('0' + dateMonth).right(2);
                    
                    System.debug('convertDateMonth: ' + convertDateMonth);
                    string convertDate = dateYear + '-' + convertDateMonth + '-' + '01';
                
                    System.debug('foreignMonthlySettlement: ' + 'MS' + '_' + dateYear + convertDateMonth );
                    getMonthlySettlementMapRec = mapMonthlySettlement.get('MS' + '_' + dateYear + convertDateMonth );
                    if(getMonthlySettlementMapRec == null){
                        //1. if monthly settlemen null upsert parent first
                        
                        newMonthlySettlementObj.Unique_Key__c = 'MS' + '_' +  dateYear + convertDateMonth;
                        newMonthlySettlementObj.Date__c = date.valueOf(convertDate);
                        System.debug('newMonthlySettlementObj.Unique_Key__c: ' + newMonthlySettlementObj.Unique_Key__c);

                        upsert newMonthlySettlementObj Unique_Key__c;
                        
                    }else{
                        newMonthlySettlementObj = getMonthlySettlementMapRec;
                    }
                    
                    berita_acara__c beritaAcaraRec = mapBeritaAcara.get(accountId+'-'+ dateYear + '-' + convertDateMonth);
                    exchangeRate = 0;
                    if(beritaAcaraRec != null){
                        exchangeRate = beritaAcaraRec.exchange_rate__c;
                    }
                    System.debug('newMonthlySettlementObj: ' + newMonthlySettlementObj);
                    pubmatic_billing__c newPubmaticBillingRec = new pubmatic_billing__c();
                    newPubmaticBillingRec.Monthly_Settlement__c = newMonthlySettlementObj.id;
                    newPubmaticBillingRec.Publisher__c = accountId;
                    newPubmaticBillingRec.Site__c = siteSFId;
                    newPubmaticBillingRec.date__c = date.valueOf(convertDate);
                    newPubmaticBillingRec.Sum_of_Paid_Impressions__c = paidImpression;
                    newPubmaticBillingRec.Sum_of_Revenue_USD__c = revenueUSD;
                    newPubmaticBillingRec.Sum_of_Net_Revenue_USD__c = netRevenueUSD;
                    newPubmaticBillingRec.Additional_Setting__c = additionalRec.id;
                    newPubmaticBillingRec.exchange_rate__c = exchangeRate;
                    newPubmaticBillingRec.Unique_Key__c = 'PB' + '_' + dateYear + convertDateMonth + '_' + siteId;
                    newPubmaticBillingRecList.add(newPubmaticBillingRec);
                }
            }

            upsert newPubmaticBillingRecList newPubmaticBillingRec.Unique_Key__c;
        } catch (Exception e) {
            string errMessage = 'Error on pubmaticBillinsgServices.generatePubmatticBilling method.::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}