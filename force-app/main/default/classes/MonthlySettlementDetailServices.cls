global with sharing class MonthlySettlementDetailServices {
    //get monthly settlement details
    global static list<Monthly_Settlement_Detail__c> getMonhtlySettlementDetail(){
        
        list<Monthly_Settlement_Detail__c> newMonthlySettlementDetailList = [ SELECT Id, 
                                                                                    Name, 
                                                                                    Deal_ID__c, 
                                                                                    Opportunity__c, 
                                                                                    Account__c, 
                                                                                    Brand__c, 
                                                                                    Date__c, 
                                                                                    DSP_Fee__c,
                                                                                    publisher_share__c,
                                                                                    Revenue_From_Advertiser__c, 
                                                                                    Monthly_Settlement__c, 
                                                                                    //Opportunity_Product__c, 
                                                                                    Unique_Key__c, 
                                                                                    Revenue_Telkomsel_Net__c 
                                                                                    FROM Monthly_Settlement_Detail__c 
        ];
        return newMonthlySettlementDetailList;
    }

    global static string upsertMonthlySettlement(string uniqueKey, date monthlySettlementDate){
        id newMonthlySettlementObjId ;
        try {
            Monthly_Settlement__c newMonthlySettlementObj = new Monthly_Settlement__c();
                newMonthlySettlementObj.Unique_Key__c = uniqueKey;
                newMonthlySettlementObj.Date__c = monthlySettlementDate;
                System.debug('newMonthlySettlementObj.uniqueKey: ' + uniqueKey);
            upsert newMonthlySettlementObj Unique_Key__c;
            newMonthlySettlementObjId = newMonthlySettlementObj.id;

            
        } catch (Exception e) {
            string errMessage = 'Error on MonthlySettlementDetailServices.upsertMonthlySettlement method.::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
        return newMonthlySettlementObjId;
    }
    
    //get revenue from advertiser
    global static void getRevenueAdvertiser(date rangeDate){

        try {
            string dateRange = '';
            dateRange = string.valueOf(rangeDate);
            list<string> splitDate = dateRange.split(' ');
            dateRange = splitDate[0];

            list<string> dateSplit = dateRange.split('-');

            integer rangeYear = integer.valueOf(dateSplit[0]);
            integer rangeMonth = integer.valueOf(dateSplit[1]);
            System.debug('rangeYear: ' + rangeYear);
            System.debug('rangeMonth: ' + rangeMonth);


            Date rangeStartDate = date.newInstance(rangeYear, rangeMonth,1); system.debug('rangeStartDate: ' + rangeStartDate);
            Date rangeEndDate = date.newInstance(rangeYear, rangeMonth+1,1).addDays(-1); system.debug('rangeEndDate: ' + rangeEndDate);

            list<AggregateResult> usageRecordList = [SELECT opportunity__c opportunityId,
                                                            Bucket_Detail__r.deal_id__c dealId,
                                                            opportunity__r.accountid accountId,
                                                            opportunity__r.brand__c brandId,
                                                            //Bucket_Detail__r.opportunity_product__c opportunityProduct, 
                                                            calendar_year(Date__c) dateYear, 
                                                            calendar_month(Date__c) dateMonth,
                                                            
                                                            sum(Telkomsel_Revenue__c) revAfterCPShare 
                                                            
                                                            FROM Usage__c 
                                                            
                                                            WHERE 
                                                            Date__c >= :rangeStartDate and Date__c <= :rangeEndDate 
                                                            and Bucket_Detail__r.Product_Name__c like '%tadex%'
                                                            and Bucket_Detail__r.deal_id__c != null
                                                            //and Bucket_Detail__r.opportunity_product__c != null

                                                            group by
                                                            calendar_year(Date__c), 
                                                            calendar_month(Date__c),
                                                            opportunity__c,
                                                            opportunity__r.accountid,
                                                            opportunity__r.brand__c,
                                                            //ucket_Detail__r.opportunity_product__c,
                                                            Bucket_Detail__r.deal_id__c
            ];

            System.debug('usageRecordList.size: ' + usageRecordList.size());
            System.debug('usageRecordList: ' + usageRecordList);

            if(usageRecordList.size() > 0){
                list<Monthly_Settlement__c> newMonthlySettlementList = new list<Monthly_Settlement__c>();
                list<Monthly_Settlement_Detail__c> newMonthlySettlementDetailList = new list<Monthly_Settlement_Detail__c>();
                
                for(AggregateResult usageRecordListAggregat : usageRecordList){
                    id opportunityId = (id) usageRecordListAggregat.get('opportunityId');
                    id accountId = (id) usageRecordListAggregat.get('accountId');
                    id brandId = (id) usageRecordListAggregat.get('brandId');
                    //id opportunityProductId = (id) usageRecordListAggregat.get('opportunityProduct');
                    string dealId = (string) usageRecordListAggregat.get('dealId');
                    //date usageDate = (date) usageRecordListAggregat.get('usageDate');
                    string dateYear = string.valueOf((integer) usageRecordListAggregat.get('dateYear')); 
                    string dateMonth = string.valueOf((integer) usageRecordListAggregat.get('dateMonth')); 
                    string convertDateMonth = '';
                    if( dateMonth != '10' && dateMonth != '11' && dateMonth != '12'  ){
                        convertDateMonth = '0' + dateMonth;
                        
                    }else{
                        convertDateMonth = dateMonth;
                    }
                    date usageDate = date.valueOf(dateYear + '-' + convertDateMonth + '-01');
                    double reveneuAfterCPShare = 0;
                    reveneuAfterCPShare = (double) usageRecordListAggregat.get('revAfterCPShare');
    
                    System.debug('usageDate:' + usageDate);
                    
                    //1. create parent first
                    id newMonthlySettlementObjId = upsertMonthlySettlement('MS' + '_' +  dateYear + convertDateMonth, usageDate);

                    /*
                    Monthly_Settlement__c newMonthlySettlementObj = new Monthly_Settlement__c();
                    newMonthlySettlementObj.Unique_Key__c = 'MS' + '_' +  convertionDate[0] + convertionDate [1];
                    newMonthlySettlementObj.Date__c = usageDate;
                    
                    upsert newMonthlySettlementObj Unique_Key__c;
                    */
                    
                    //then create child 
                    Monthly_Settlement_Detail__c newMonthlySettlementDetailsObj = new Monthly_Settlement_Detail__c();
                    newMonthlySettlementDetailsObj.Unique_Key__c = 'MSD' + '_' + dateYear + convertDateMonth +  '_' + dealId;
                    newMonthlySettlementDetailsObj.Deal_Id__c = dealId;
                    newMonthlySettlementDetailsObj.Opportunity__c = opportunityId;
                    //newMonthlySettlementDetailsObj.Opportunity_Product__c = opportunityProductId;
                    newMonthlySettlementDetailsObj.account__c = accountId;
                    newMonthlySettlementDetailsObj.brand__c = brandId;
                    newMonthlySettlementDetailsObj.Revenue_From_Advertiser__c = reveneuAfterCPShare;
                    newMonthlySettlementDetailsObj.Date__c = usageDate;
                    newMonthlySettlementDetailsObj.Monthly_Settlement__c = newMonthlySettlementObjId;
        
                    newMonthlySettlementDetailList.add(newMonthlySettlementDetailsObj);
                    
                }
                    upsert newMonthlySettlementDetailList newMonthlySettlementDetailsObj.Unique_Key__c;
            }
        } catch (Exception e) {
            string errMessage = 'Error on MonthlySettlementDetailServices.getRevenueAdvertiser method.::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

    //get revenue from dsp fee
    global static void getRevenueDSPFee(date rangeDate){
        try {
            string dateRange = '';
            dateRange = string.valueOf(rangeDate);
            list<string> splitDate = dateRange.split(' ');
            dateRange = splitDate[0];

            list<string> dateSplit = dateRange.split('-');

            integer rangeYear = integer.valueOf(dateSplit[0]);
            integer rangeMonth = integer.valueOf(dateSplit[1]);
            System.debug('rangeYear: ' + rangeYear);
            System.debug('rangeMonth: ' + rangeMonth);


            Date rangeStartDate = date.newInstance(rangeYear, rangeMonth,1); system.debug('rangeStartDate: ' + rangeStartDate);
            Date rangeEndDate = date.newInstance(rangeYear, rangeMonth+1,1).addDays(-1); system.debug('rangeEndDate: ' + rangeEndDate);

            //map to get monthly settlement details record
            map<string, Monthly_Settlement_Detail__c> monthluSettlementDetailMap = new map <string, Monthly_Settlement_Detail__c>();

            //first get the monthly settlement details record list
            list<Monthly_Settlement_Detail__c> monhtlySettlementDetailList = getMonhtlySettlementDetail();
            for(Monthly_Settlement_Detail__c monhtlySettlementDetailListRec :monhtlySettlementDetailList){
                monthluSettlementDetailMap.put(monhtlySettlementDetailListRec.Unique_Key__c, monhtlySettlementDetailListRec);
            }

            list <AggregateResult> DSPFeeRecAggregateList = [ select deal_id__c dealId, 
                                                                calendar_year(Date__c) dateYear, 
                                                                calendar_month(Date__c) dateMonth,
                                                                sum(amount__c) DSPAmmount 

                                                                from 
                                                                DSP_Fee__c 

                                                                WHERE date__c >= :rangeStartDate and date__c <= :rangeEndDate and deal_id__c != null
                                                                and deal_id__c != null

                                                                GROUP BY
                                                                deal_id__c,
                                                                calendar_year(Date__c), 
                                                                calendar_month(Date__c)
            ];
            System.debug('DSPFeeRecAggregateList: ' + DSPFeeRecAggregateList);
            list<Monthly_Settlement_Detail__c> newMonthlySettlementDetailList = new list<Monthly_Settlement_Detail__c>();
            for(AggregateResult DSPFeeRecListAggregateRec :DSPFeeRecAggregateList){
                string DSPdealId = (string) DSPFeeRecListAggregateRec.get('dealId');
                string dateMonth = (string) string.valueOf(DSPFeeRecListAggregateRec.get('dateMonth'));
                string dateYear = (string) string.valueOf(DSPFeeRecListAggregateRec.get('dateYear'));
                double DSPAmount = 0;
                DSPAmount = (Double) DSPFeeRecListAggregateRec.get('DSPAmmount');
                string convertDateMonth = '';
                    if( dateMonth != '10' && dateMonth != '11' && dateMonth != '12'  ){
                        convertDateMonth = '0' + dateMonth;
                        
                    }else{
                        convertDateMonth = dateMonth;
                    }
                date DSPDateConvert = date.valueOf(dateYear + '-' + convertDateMonth + '-01');

                string foreignKeytoMonthlySettlementDetails = 'MSD_' +  dateYear + convertDateMonth + '_' + DSPdealId; 
                string foreignKeytoMonthlySettlement = 'MS_' +  dateYear + convertDateMonth; 

                //get monthly settlement record by unique key
                Monthly_Settlement_Detail__c monthlySettlementRecord = monthluSettlementDetailMap.get(foreignKeytoMonthlySettlementDetails);
                System.debug('monthlySettlementRecord: ' + monthlySettlementRecord);

                if(monthlySettlementRecord != null){
                    System.debug('monthlySettlementRecord: ' + monthlySettlementRecord);
                    System.debug('monthlySettlementRecord: ' + monthlySettlementRecord.DSP_Fee__c);
                    System.debug('in existigng');

                    monthlySettlementRecord.DSP_Fee__c = DSPAmount;
                    newMonthlySettlementDetailList.add(monthlySettlementRecord);
                    System.debug('newMonthlySettlementDetailList: ' + newMonthlySettlementDetailList);

                }else{
                    System.debug(' in create DSP');
                    //1. create parent first
                    id newMonthlySettlementObjId = upsertMonthlySettlement(foreignKeytoMonthlySettlement, DSPDateConvert);

                    //then create child 
                    Monthly_Settlement_Detail__c newMonthlySettlementDetailsObj = new Monthly_Settlement_Detail__c();
                    newMonthlySettlementDetailsObj.Unique_Key__c = foreignKeytoMonthlySettlementDetails;
                    newMonthlySettlementDetailsObj.Deal_Id__c = DSPdealId;
                    newMonthlySettlementDetailsObj.DSP_Fee__c = DSPAmount;
                    newMonthlySettlementDetailsObj.Date__c = DSPDateConvert;
                    newMonthlySettlementDetailsObj.Monthly_Settlement__c = newMonthlySettlementObjId;

                    newMonthlySettlementDetailList.add(newMonthlySettlementDetailsObj);
                    System.debug('newMonthlySettlementDetailList: ' + newMonthlySettlementDetailList);

                }   
            }
            upsert newMonthlySettlementDetailList newMonthlySettlementDetailsObj.Unique_Key__c;
        } catch (Exception e) {
            string errMessage = 'Error on MonthlySettlementDetailServices.getRevenueDSPFee method.::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
    
    //get revenue from publisher Share (traffic)
    global static void getRevenueFromPublisherShare(date rangeDate){

        try {
            //map to get monthly settlement details record
            map<string, Monthly_Settlement_Detail__c> monthluSettlementDetailMap = new map <string, Monthly_Settlement_Detail__c>();
            //get value of VAT

            string dateRange = '';
            dateRange = string.valueOf(rangeDate);
            list<string> splitDate = dateRange.split(' ');
            dateRange = splitDate[0];
    
            list<string> dateSplit = dateRange.split('-');
    
            integer rangeYear = integer.valueOf(dateSplit[0]);
            integer rangeMonth = integer.valueOf(dateSplit[1]);
            System.debug('rangeYear: ' + rangeYear);
            System.debug('rangeMonth: ' + rangeMonth);
    
    
            Date rangeStartDate = date.newInstance(rangeYear, rangeMonth,1); system.debug('rangeStartDate: ' + rangeStartDate);
            Date rangeEndDate = date.newInstance(rangeYear, rangeMonth+1,1).addDays(-1); system.debug('rangeEndDate: ' + rangeEndDate);
            
            Additional_Setting__c additionalRec =  apputils.getAdditionalValue('VAT', 'pubmatic_billing__c', rangeStartDate);
            System.debug('additionalRec.Value__c.239: ' + additionalRec.Value__c);
            //first get the monthly settlement details record list
            list<Monthly_Settlement_Detail__c> monhtlySettlementDetailList = getMonhtlySettlementDetail();
            for(Monthly_Settlement_Detail__c monhtlySettlementDetailListRec :monhtlySettlementDetailList){
                monthluSettlementDetailMap.put(monhtlySettlementDetailListRec.Unique_Key__c, monhtlySettlementDetailListRec);
            }

            list <AggregateResult> publisherShareList = [ select deal_id__c dealId, 
                                                                calendar_year(Date__c) dateYear, 
                                                                calendar_month(Date__c) dateMonth,
                                                                sum(Publisher_Share__c) trafficNetRevenue 
                                                                
                                                                from 
                                                                traffic__c 

                                                                WHERE date__c >= :rangeStartDate and date__c <= :rangeEndDate
                                                                and deal_id__c != null
                                                                and (NOT deal__c like '%TADEX_OMP_%')

                                                                GROUP BY
                                                                deal_id__c,
                                                                calendar_year(Date__c), 
                                                                calendar_month(Date__c)
                                                                
            ];
            System.debug('publisherShareList: ' + publisherShareList);

            list<Monthly_Settlement_Detail__c> newMonhtlySettlementDetailList = new list<Monthly_Settlement_Detail__c>();
            for(AggregateResult trafficRecListAggregateRec :publisherShareList){
                string trafficDealId = (string) trafficRecListAggregateRec.get('dealId');
                string dateMonth = (string) string.valueOf(trafficRecListAggregateRec.get('dateMonth'));
                string dateYear = (string) string.valueOf(trafficRecListAggregateRec.get('dateYear'));
                double trafficAmount = 0;
                trafficAmount = (Double) trafficRecListAggregateRec.get('trafficNetRevenue');


                string convertDateMonth = '';
                if( dateMonth != '10' && dateMonth != '11' && dateMonth != '12'  ){
                    convertDateMonth = '0' + dateMonth;
                    
                }else{
                    convertDateMonth = dateMonth;
                }
                date TrafficDateConvert = date.valueOf(dateYear + '-' + convertDateMonth + '-01');

                string foreignKeytoMonthlySettlementDetails = 'MSD_' +  dateYear + convertDateMonth + '_' + trafficDealId; 
                string foreignKeytoMonthlySettlement = 'MS_' +  dateYear + convertDateMonth; 
                //get monthly settlement record by unique key
                Monthly_Settlement_Detail__c monthlySettlementRecord = monthluSettlementDetailMap.get(foreignKeytoMonthlySettlementDetails);
                if(monthlySettlementRecord != null){
                    System.debug('monthlySettlementRecord: ' + monthlySettlementRecord);
                    System.debug('monthlySettlementRecord.Publisher_Share__c: ' + monthlySettlementRecord.Publisher_Share__c);
                    System.debug('additionalRec.Value__c.277: ' + additionalRec.Value__c);
                    System.debug('trafficAmount.279: ' + trafficAmount);
                    
                    monthlySettlementRecord.Publisher_Share__c = trafficAmount;
                    newMonhtlySettlementDetailList.add(monthlySettlementRecord);
                }else{

                    System.debug('trafficAmount.284: ' + trafficAmount);
                    System.debug('additionalRec.Value__c.285: ' + additionalRec.Value__c);

                    //1. create parent first
                    id newMonthlySettlementObjId = upsertMonthlySettlement(foreignKeytoMonthlySettlement, TrafficDateConvert);

                    //then create child 
                    Monthly_Settlement_Detail__c newMonthlySettlementDetailsObj = new Monthly_Settlement_Detail__c();
                    newMonthlySettlementDetailsObj.Unique_Key__c = foreignKeytoMonthlySettlementDetails;
                    newMonthlySettlementDetailsObj.Deal_Id__c = trafficDealId;
                    newMonthlySettlementDetailsObj.Publisher_Share__c = trafficAmount;
                    newMonthlySettlementDetailsObj.Date__c = TrafficDateConvert;
                    newMonthlySettlementDetailsObj.Monthly_Settlement__c = newMonthlySettlementObjId;
    
                    newMonhtlySettlementDetailList.add(newMonthlySettlementDetailsObj);
                }
            }
            System.debug('newMonhtlySettlementDetailList.298: ' + newMonhtlySettlementDetailList);
            upsert newMonhtlySettlementDetailList newMonthlySettlementDetailsObj.Unique_Key__c;
        } catch (Exception e) {
            string errMessage = 'Error on MonthlySettlementDetailServices.getRevenueFromPublisherShare method.::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}