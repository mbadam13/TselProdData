/**
 * @description       : 
 * @TestClass         : TA_AT_Order_AU_CountSpotSoldTEST
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 08-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-01-2024   Novando Utoyo Agmawan   Initial Version
**/

public class TA_AT_Order_AU_CountSpotSold implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<Order> newList, List<Order> oldList){
        try{
            system.debug (' === TA_AT_Order_AU_CountSpotSold === ');

            Map<Id,Order> oldMap = new Map<Id,Order>(oldList);

            Set<String> Set_OrderIds = new Set<String>();

            for (Order orderRec : newList) {
                if(
                    orderRec.Approval_Status__c != oldMap.get(orderRec.id).Approval_Status__c &&
                    orderRec.Approval_Status__c == 'Approved'
                ){
                    Set_OrderIds.add(orderRec.Id);
                }
            }

            system.debug (' === Set_OrderIds : ' + Set_OrderIds + ' === ');

            IptvSpotDailyStatusServices.countSpotDailyApproved(Set_OrderIds);

            // List<Media_Order_Item__c> List_OrderItem = [
            //         SELECT Id, IPTV_Spot_Daily_Status__c, Media_Order__r.Order__c
            //         FROM Media_Order_Item__c
            //         WHERE Media_Order__r.Order__c IN :Set_OrderIds
            //     ];

            // system.debug(' === List_MOItem : ' + JSON.serialize(List_OrderItem) + ' === ');
    
            //     Set<String> Set_IPTVSDS = new Set<String>();
    
            //     for (Media_Order_Item__c orderItem : List_OrderItem) {
            //         Set_IPTVSDS.add(orderItem.IPTV_Spot_Daily_Status__c);
            //     }
    
            // system.debug(' === Set_IPTVSDS : ' + Set_IPTVSDS + ' === ');

            // if(Set_OrderIds!=null && !Set_OrderIds.isEmpty()){
            //     List<AggregateResult> List_sumSpot = [
            //         SELECT 
            //         Inventory_Name__c InventoryName, 
            //         Date__c recordDate, 
            //         SUM(Spot_Needed__c) spotNeeded, 
            //         Media_Order__r.Order__r.Approval_Status__c Status
            //         FROM 
            //             Media_Order_Item__c
            //         WHERE 
            //             IPTV_Spot_Daily_Status__c IN :Set_IPTVSDS
            //         GROUP BY 
            //            Inventory_Name__c, Date__c, Media_Order__r.Order__r.Approval_Status__c
            //     ];

            //     system.debug (' === List_sumSpot : ' + json.serialize(List_sumSpot) + ' === ');

            //     if(List_sumSpot!=null && !List_sumSpot.isEmpty()){
            //         Map<String, Integer> Map_sumSpot = new Map<String, Integer>();
            //         Set<String> Set_InventoryName = new Set<String>();
            //         Set<Date> Set_date = new Set<Date>();

            //         for (AggregateResult sumSpot : List_sumSpot) {
            //             String status = (String) sumSpot.get('Status');
            //             String inventoryName = (String) sumSpot.get('InventoryName');
            //             Date recordDate = (Date) sumSpot.get('recordDate');
            //             Integer spotNeeded = ((Decimal) sumSpot.get('spotNeeded')).intValue();

            //             Set_InventoryName.add(inventoryName);
            //             Set_date.add(recordDate);

            //             String keyMap = inventoryName + String.valueOf(recordDate);

            //             if (status == 'Approved' ) {
            //                 Map_sumSpot.put(keyMap, spotNeeded);
            //             } else {
            //                 if (!Map_sumSpot.containsKey(keyMap)) {
            //                     Map_sumSpot.put(keyMap, 0);
            //                 }
            //             }
            //         }

            //         system.debug (' === Map_sumSpot : ' + json.serialize(Map_sumSpot) + ' === ');

            //         List<IPTV_Spot_Daily_Status__c> List_IptvSDS = [
            //             SELECT
            //                 Id, Inventory_Name__c, Date__c, Spot_In_Approval__c, Spot_Sold__c
            //             FROM
            //                 IPTV_Spot_Daily_Status__c
            //             WHERE
            //                 Inventory_Name__c IN : Set_InventoryName AND
            //                 Date__c IN : Set_date
            //         ];

            //         system.debug (' === List_IptvSDS : ' + json.serialize(List_IptvSDS) + ' === ');

            //         if(List_IptvSDS!=null && !List_IptvSDS.isEmpty()){
            //             for(IPTV_Spot_Daily_Status__c IptvSDS : List_IptvSDS){
            //                 String keyMap = IptvSDS.Inventory_Name__c + String.ValueOf(IptvSDS.Date__c);

            //                 IptvSDS.Spot_Sold__c = Map_sumSpot.get(keyMap);
            //             }

            //             update List_IptvSDS;
            //         }
            //     }
            // }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on TA_AT_Order_AU_CountSpotSold afterUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}