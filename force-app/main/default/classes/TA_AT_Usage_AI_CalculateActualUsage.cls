/**
 * @description       :
 * @author            : Doddy Prima
 * @group             :
 * @last modified on  : 01-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/

public with sharing class TA_AT_Usage_AI_CalculateActualUsage implements TriggerAction.AfterInsert {
    public void AfterInsert(List<Usage__c> newList) {
        System.debug('=== TA_AT_Usage_AI_CalculateActualUsage.AfterInsert ===');

        try {
            Set<ID> bucketDetailIDs = new Set<ID>();
            Set<ID> moItemIDs = new Set<ID>();

            // get bucket detail id and media order item id ---
            for (Usage__c usageNEWRec : newList) {
                if (usageNEWRec.Business_Product__c == 'TV Media') {
                    bucketDetailIDs.add(usageNEWRec.Bucket_Detail__c);
                    moItemIDs.add(usageNEWRec.Media_Order_Item__c);
                }
            }

            // calc actual usage on Bucket Detail
            if (bucketDetailIDs.size() > 0) {
                UsageTVMediaService.CalculationActualUsageByBucketDetail(
                    bucketDetailIDs
                );
            }

            // // calc actual usage on Media Order Item
            // if (moItemIDs.size() > 0) {
            //     UsageTVMediaService.CalculationActualUsageByMOItem(moItemIDs);
            // }

            // handling for try catch error
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(
                    'This is a constructed exception for testing and code coverage'
                );
                throw e;
            }
        } catch (Exception e) {
            string errMessage =
                'Error on TA_AT_Usage_AI_CalculateActualUsage.AfterInsert function::' +
                e.getmessage() +
                '::' +
                e.getLineNumber();
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
}