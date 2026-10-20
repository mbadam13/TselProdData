/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * test class         : RabatRevenueCalculationServicesTest
 * @last modified on  : 10-20-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class RabatRevenueCalculationServices {
    
    public static void createRabatRevenueItems(set<id> newRabatRevenueCalculationIds){
        System.debug(' in createRabatRevenueItems ');
        try {
            list<Rabat_Revenue_Calculation__c> newRabatRevenueCalculationList = [
                SELECT
                id,
                name,
                start_date__c,
                end_date__c,
                account__c,
                rabat_configuration_setting__c

                FROM Rabat_Revenue_Calculation__c

                WHERE id in:newRabatRevenueCalculationIds
            ];
            system.debug('newRabatRevenueCalculationList: ' + json.serialize(newRabatRevenueCalculationList)); 
            
            set<date> startDate = new set<date>();
            set<date> endDate = new set<date>();
            set<String> accountIds = new set<String>();
            for(Rabat_Revenue_Calculation__c newRabatRevenueCalculationListRec :newRabatRevenueCalculationList){
                startDate.add(newRabatRevenueCalculationListRec.start_date__c);
                endDate.add(newRabatRevenueCalculationListRec.end_date__c);
                accountIds.add(newRabatRevenueCalculationListRec.account__c);
            }

            /*
            list<usage__c> usageList = [
                SELECT 
                id,
                Bucket_Detail__r.order.opportunityid ,
                Bucket_Detail__r.order.opportunity.accountid,
                Bucket_Detail__r.order.opportunity.Agency_Name__c,
                Bucket_Detail__r.order.opportunity.brand__c,
                Bucket_Detail__c

                FROM usage__c
                
                WHERE 
                Bucket_Detail__r.order.opportunity.accountid IN:accountIds AND
                Usage_Date__c >=:startDate AND 
                Usage_Date__c <=:endDate
            ];
            system.debug('usageList: ' + json.serialize(usageList)); 
            */
            
            list<AggregateResult> usageList = [
                SELECT 
                Bucket_Detail__r.order.opportunity.accountid accountId,
                Bucket_Detail__r.order.opportunity.Agency_Name__c agencyId,
                Bucket_Detail__r.order.opportunity.brand__c brandId,
                Bucket_Detail__r.No_Invoice_Tsel__c noInvocieTsel,
                //Bucket_Detail__r.Campaign_Status__c campaignStatus,
                Bucket_Detail__r.No_FBO__c poNumber,
                Bucket_Detail__r.campaign_name__c campaignName,

                //Bucket_Detail__c orderProductId,
                calendar_month(Date__c) usageDateMonth,
                calendar_year(Date__c) usageDateYear,

                sum(Telkomsel_Revenue__c) revAfterCPShare

                FROM usage__c
                
                WHERE 
                Bucket_Detail__r.order.opportunity.accountid IN:accountIds AND
                Usage_Date__c >=:startDate AND 
                Usage_Date__c <=:endDate AND
                Bucket_Detail__r.order.opportunityId != null AND
                Bucket_Detail__r.order.opportunity.Agency_Name__c != null AND
                Bucket_Detail__r.order.opportunity.brand__c != null 
                //AND Bucket_Detail__c != null

                GROUP BY
                Bucket_Detail__r.order.opportunity.accountid,
                Bucket_Detail__r.order.opportunity.Agency_Name__c,
                Bucket_Detail__r.order.opportunity.brand__c,
                Bucket_Detail__r.No_Invoice_Tsel__c,
                //Bucket_Detail__r.Campaign_Status__c,
                Bucket_Detail__r.No_FBO__c,
                Bucket_Detail__r.campaign_name__c,
                //Bucket_Detail__c,
                calendar_month(Date__c),
                calendar_year(Date__c) 
            ];

            System.debug('usageList: ' + usageList);
            list<Rabat_Revenue_Item__c> rabatRevenueItemtoInsertList = new list<Rabat_Revenue_Item__c>();
            for(Rabat_Revenue_Calculation__c newRabatRevenueCalculationListRec :newRabatRevenueCalculationList){
                for(AggregateResult usageListRec :usageList){
                    
                    Rabat_Revenue_Item__c newRabatRevenueItem = new Rabat_Revenue_Item__c();
                    newRabatRevenueItem.account__c = (id) usageListRec.get('accountId'); //usageListRec.Bucket_Detail__r.order.opportunity.AccountId;
                    newRabatRevenueItem.agency_name__c = (id) usageListRec.get('agencyId');//usageListRec.Bucket_Detail__r.order.opportunity.Agency_Name__c;
                    newRabatRevenueItem.brand__c = (id) usageListRec.get('brandId');//usageListRec.Bucket_Detail__r.order.opportunity.brand__c;
                    newRabatRevenueItem.No_Invoice_Tsel__c = (string) usageListRec.get('noInvocieTsel');
                    newRabatRevenueItem.No_FBO__c = (string) usageListRec.get('poNumber');
                    //newRabatRevenueItem.Campaign_Status__c = (string) usageListRec.get('campaignStatus');
                    newRabatRevenueItem.Campaign_Name__c = (string) usageListRec.get('campaignName');

                    //newRabatRevenueItem.order_product__c = (id) usageListRec.get('orderProductId');//usageListRec.Bucket_Detail__c;

                    newRabatRevenueItem.Rabat_Revenue_Calculation__c = newRabatRevenueCalculationListRec.id;
                    newRabatRevenueItem.Spending_Amount__c = (double) usageListRec.get('revAfterCPShare');//newRabatRevenueCalculationListRec.id;
                    newRabatRevenueItem.periode_date__c = date.newInstance((integer) usageListRec.get('usageDateYear'), (integer) usageListRec.get('usageDateMonth'), 1);
                    rabatRevenueItemtoInsertList.add(newRabatRevenueItem);
                }
            }

            if(!rabatRevenueItemtoInsertList.isempty()){

                set<date> revenueItemDate = new set<date>();
                set<string> accountId = new set<string>();
                decimal totalSpendingAmount; 
                
                list<AggregateResult> getSpendingAmount = [
                    SELECT 
                    Bucket_Detail__r.order.opportunity.accountid accountId,

                    sum(Telkomsel_Revenue__c) revAfterCPShare

                    FROM usage__c
                    
                    WHERE 
                    Bucket_Detail__r.order.opportunity.accountid IN:accountIds AND
                    Usage_Date__c >=:startDate AND 
                    Usage_Date__c <=:endDate AND
                    Bucket_Detail__r.order.opportunityId != null AND
                    Bucket_Detail__r.order.opportunity.Agency_Name__c != null AND
                    Bucket_Detail__r.order.opportunity.brand__c != null AND
                    Bucket_Detail__c != null

                    GROUP BY
                    Bucket_Detail__r.order.opportunity.accountid
                ];

                
                for(AggregateResult getSpendingAmountValue :getSpendingAmount){
                    totalSpendingAmount = (decimal) getSpendingAmountValue.get('revAfterCPShare');
                }
            

                for(Rabat_Revenue_Item__c rabatRevenueItemtoInsertListRec :rabatRevenueItemtoInsertList ){
                    revenueItemDate.add(rabatRevenueItemtoInsertListRec.periode_date__c);
                    accountId.add(rabatRevenueItemtoInsertListRec.Account__c);
                    //totalSpendingAmount = totalSpendingAmount + rabatRevenueItemtoInsertListRec.Spending_Amount__c;
                }

                System.debug('revenueItemDate :' + revenueItemDate);
                System.debug('totalSpendingAmount :' + totalSpendingAmount);
                System.debug('accountId :' + accountId);

                list<Rabat_Configuration_Setting__c> rabatConfigurationSettingRecList = [
                    SELECT 
                    Id,
                    name,
                    start_date__c,
                    end_date__c,
                    Discount_Percentage__c,
                    Group_Incentive__c,
                    Spending_Amount_LessThan__c,
                    Spending_Amount_Greater_Than__c
    
                    FROM Rabat_Configuration_Setting__c
    
                    WHERE 
                    //start_date__c <= :revenueItemDate AND end_date__c >= :revenueItemDate AND
                    Account__c in :accountId
                ];

                for(Rabat_Revenue_Item__c rabatRevenueItemtoInsertListRec :rabatRevenueItemtoInsertList ){
                    for(Rabat_Configuration_Setting__c rabatConfigurationSettingRec :rabatConfigurationSettingRecList){
                        if(
                            (rabatConfigurationSettingRec.Spending_Amount_Greater_Than__c <= totalSpendingAmount  && totalSpendingAmount <= rabatConfigurationSettingRec.Spending_Amount_LessThan__c) &&
                            (rabatConfigurationSettingRec.start_date__c <= rabatRevenueItemtoInsertListRec.periode_date__c  && rabatRevenueItemtoInsertListRec.periode_date__c <= rabatConfigurationSettingRec.end_date__c )
                        ){
                            System.debug('in rabatRevenueItemtoInsertListRec');
                            system.debug('totalSpendingAmount: ' + rabatConfigurationSettingRec.Spending_Amount_LessThan__c + ' <= ' + totalSpendingAmount + ' && ' + totalSpendingAmount + ' <= ' + rabatConfigurationSettingRec.Spending_Amount_Greater_Than__c);
                            system.debug('periode_date__c: ' + rabatConfigurationSettingRec.start_date__c + ' >= ' + rabatRevenueItemtoInsertListRec.periode_date__c + ' && ' + rabatRevenueItemtoInsertListRec.periode_date__c + ' <= ' + rabatConfigurationSettingRec.end_date__c);
                            rabatRevenueItemtoInsertListRec.Rabat_Configuration_Setting__c = rabatConfigurationSettingRec.id;
    
                            break;
                        }                        
                    }
                }

                System.debug('rabatRevenueItemtoInsertList: ' + json.serialize(rabatRevenueItemtoInsertList));
                insert rabatRevenueItemtoInsertList;
            }
                      
        } catch (Exception e) {
            string errMessage = 'Error on RabatRevenueCalculationServices.createRabatRevenueItems function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
}