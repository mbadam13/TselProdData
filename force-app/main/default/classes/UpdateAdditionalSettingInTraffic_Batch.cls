/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
global with sharing class UpdateAdditionalSettingInTraffic_Batch implements Database.Batchable<sObject>, Database.stateful {

    public static list<Additional_Setting__c> addistionalSettingList = new list<Additional_Setting__c>(); 
    public static map<string, Additional_Setting__c> mapAdditoinalRecord = new map<string, Additional_Setting__c>();
    public static List<Traffic__c> newTrafficList = new List<Traffic__c>();

    global UpdateAdditionalSettingInTraffic_Batch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('in start.11');    
        Date today = Date.today();
        Date lastMonthStartDate = today.addMonths(-1).toStartOfMonth();
        Date lastMonthEndDate = today.toStartOfMonth().addDays(-1);
        String lastMonthStartDateStr = String.valueOf(lastMonthStartDate);
        String lastMonthEndDateStr = String.valueOf(lastMonthEndDate);
        
        list<string> lastMonthStartDateStrList = lastMonthStartDateStr.split(' ');
        list<string> lastMonthEndDateStrList = lastMonthEndDateStr.split(' ');

        
        System.debug('lastMonthStartDate: ' + lastMonthStartDate);
        System.debug('lastMonthEndDate: ' + lastMonthEndDate);

        String query = 'SELECT Id, Additional_Setting__c, date__c FROM Traffic__c where  Additional_Setting__c = null and date__c >= ' + lastMonthStartDateStrList[0] + ' and date__c <= ' + lastMonthEndDateStrList[0];

        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<traffic__C> trafficList){
        System.debug('trafficList: ' + trafficList);
        List<Traffic__c> newTrafficList = new List<Traffic__c>();
        
        Date currentDate = Date.today();
        Date oneMonthAgo = currentDate.addMonths(-1);
        Additional_Setting__c getAdditionalValueRec = AppUtils.getAdditionalValue('VAT', 'VAT', oneMonthAgo);
        system.debug('getAdditionalValueRec: ' + getAdditionalValueRec);
        if(trafficList != null){
            for(traffic__C trafficListRec :trafficList){
                trafficListRec.Additional_Setting__c = getAdditionalValueRec.id;
                newTrafficList.add(trafficListRec);
            }
        }
        update newTrafficList;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}