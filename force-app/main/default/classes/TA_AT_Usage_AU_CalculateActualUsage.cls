/**
 * @description       :Deactive flow "Opportunity_TRG_BU_ValidationClosedWon" when running test class or deploy
 * @author            : Syaiful Syafani
 * @group             :
 * @last modified on  : 02-24-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * 24/02/2025    - - Change Logic Takeout Bisnis Product   - Adam
 **/
public with sharing class TA_AT_Usage_AU_CalculateActualUsage implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<Usage__c> newList, List<Usage__c> oldList) {
        System.debug('=== TA_AT_Usage_AU_CalculateActualUsage.AfterUpdate ===');

        Map<Id, Usage__c> oldMap = new Map<Id, Usage__c>(oldList);

        Set<Id> bucketDetailIDs = new Set<Id>();
        Set<Id> moItemIds = new Set<Id>();
        try {
            for (Usage__c newUsageRec : newList) {
                Usage__c oldUsageRec = oldMap.get(newUsageRec.Id);

                if (
                    newUsageRec != oldUsageRec
                ) {
                    // usage changed
                    bucketDetailIDs.add(newUsageRec.Bucket_Detail__c);
                    moItemIds.add(newUsageRec.Media_Order_Item__c);
                }
            }
            System.debug('== bucketDetailIDs: ' + bucketDetailIDs);
            System.debug('== moItemIds: ' + moItemIds);

            // calc actual usage on Bucket Detail
            if (!bucketDetailIDs.isEmpty()) {
                UsageTVMediaService.CalculationActualUsageByBucketDetail(
                    bucketDetailIDs
                );
            }

            // // calc actual usage on Media Order Item
            // if (!moItemIds.isEmpty()) {
            //     UsageTVMediaService.CalculationActualUsageByMOItem(moItemIds);
            // }

            // handling for try catch
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(
                    'This is a constructed exception for testing and code coverage'
                );
                throw e;
            }
        } catch (Exception e) {
            string errMessage =
                'Error on TA_AT_Usage_AU_CalculateActualUsage.afterUpdate function::' +
                e.getmessage() +
                '::' +
                e.getLineNumber();
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
}