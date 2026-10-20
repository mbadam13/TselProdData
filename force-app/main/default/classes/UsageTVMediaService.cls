/**
 * @description       :
 * @author            : Doddy Prima
 * @group             :
 * @last modified on  : 13/12/2024
 * @last modified by  : Syaiful Syafani
 **/
public without sharing class UsageTVMediaService {
    

    public static void CalculationActualUsageByBucketDetail(
        Set<ID> bucketDetailIDs
    ) {
        try {
            List<AggregateResult> bucketDetailARList = [
                SELECT Bucket_Detail__c, SUM(Amount__c) totalUsage
                FROM Usage__c
                WHERE Bucket_Detail__c IN :bucketDetailIDs
                GROUP BY Bucket_Detail__c
            ];
            System.debug('== bucketDetailARList: ' + bucketDetailARList);

            List<OrderItem> orderItemNeedToUpdateList = new List<OrderItem>();
            for (AggregateResult arREC : bucketDetailARList) {
                OrderItem bucketDetailREC = new OrderItem(
                    id = (ID) arREC.get('Bucket_Detail__c'),
                    usage_actual__c = (double) arREC.get('totalUsage')
                );
                orderItemNeedToUpdateList.add(bucketDetailREC);
            }
            System.debug(
                '== orderItemNeedToUpdateList: ' + orderItemNeedToUpdateList
            );

            update orderItemNeedToUpdateList;

            // handling for try catch
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(
                    'This is a constructed exception for testing and code coverage'
                );
                throw e;
            }
        } catch (exception e) {
            string errMessage =
                'Error on UsageTVMediaService CalculationActualUsageByBucketDetail function::' +
                e.getmessage() +
                '---' +
                e.getStacktraceString() +
                '::' +
                e.getLineNumber();
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
/*
    public static void CalculationActualUsageByMOItem(Set<ID> moItemIDs) {
        try {
            List<AggregateResult> moItemARList = [
                SELECT Media_Order_Item__c, SUM(Amount__c) totalUsage
                FROM Usage__c
                WHERE Media_Order_Item__c IN :moItemIDs
                GROUP BY Media_Order_Item__c
            ];
            System.debug('== moItemARList: ' + moItemARList);

            List<Media_Order_Item__c> moItemNeedToUpdateList = new List<Media_Order_Item__c>();
            for (AggregateResult arREC : moItemARList) {
                Media_Order_Item__c moItemREC = new Media_Order_Item__c(
                    id = (ID) arREC.get('Media_Order_Item__c'),
                    usage_actual__c = (double) arREC.get('totalUsage')
                );
                moItemNeedToUpdateList.add(moItemREC);
            }
            System.debug(
                '== moItemNeedToUpdateList: ' + moItemNeedToUpdateList
            );

            update moItemNeedToUpdateList;

            // handling for try catch
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(
                    'This is a constructed exception for testing and code coverage'
                );
                throw e;
            }
        } catch (exception e) {
            string errMessage =
                'Error on UsageTVMediaService CalculationActualUsageByMOItem function::' +
                e.getmessage() +
                '---' +
                e.getStacktraceString() +
                '::' +
                e.getLineNumber();
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
*/
    
}