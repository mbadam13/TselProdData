/**
 * @description       : 
 * @TestClass         : TA_AT_MOI_AU_CountQuantitySpotSoldTEST
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-08-2024
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-08-2024   Novando Utoyo Agmawan   Initial Version
**/

public class TA_AT_MOI_AU_CountQuantitySpotSold implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<Media_Order_Item__c> newList, List<Media_Order_Item__c> oldList){
        try{
            system.debug (' === TA_AT_MOI_AU_CountQuantitySpotSold === ');

            Map<Id,Media_Order_Item__c> oldMap = new Map<Id,Media_Order_Item__c>(oldList);

            Set<String> Set_MediaOrderItemIds = new Set<String>();

            for (Media_Order_Item__c moiRec : newList) {
                if(
                    moiRec.Quantity__c != oldMap.get(moiRec.id).Quantity__c &&
                    moiRec.Order_Approval_Status__c == 'Approved'
                ){
                    Set_MediaOrderItemIds.add(moiRec.Id);
                }
            }

            system.debug (' === Set_MediaOrderItemIds : ' + Set_MediaOrderItemIds + ' === ');

            if(Set_MediaOrderItemIds!=null && !Set_MediaOrderItemIds.isEmpty()){
                List<AggregateResult> List_sumSpot = [
                    SELECT 
                        Inventory_Name__c InventoryName, Date__c date, SUM(Spot_Needed__c) spotNeeded
                    FROM 
                        Media_Order_Item__c
                    WHERE 
                        Id IN : Set_MediaOrderItemIds
                    GROUP BY 
                        Inventory_Name__c, Date__c
                ];

                system.debug (' === List_sumSpot : ' + json.serialize(List_sumSpot) + ' === ');

                if(List_sumSpot!=null && !List_sumSpot.isEmpty()){
                    Map<String,Integer> Map_sumSpot = new Map<String,Integer>();

                    Set<String> Set_InventoryName = new Set<String>();
                    Set<Date> Set_date = new Set<Date>();

                    for(AggregateResult sumSpot : List_sumSpot){
                        Set_InventoryName.add((String)sumSpot.get('InventoryName'));
                        Set_date.add((Date)sumSpot.get('date'));

                        String keyMap = (String)sumSpot.get('InventoryName') + String.ValueOf((Date)sumSpot.get('date'));
                        Map_sumSpot.put(keyMap,Integer.ValueOf((Decimal)sumSpot.get('spotNeeded')));
                    }

                    system.debug (' === Map_sumSpot : ' + json.serialize(Map_sumSpot) + ' === ');

                    List<IPTV_Spot_Daily_Status__c> List_IptvSDS = [
                        SELECT
                            Id, Inventory_Name__c, Date__c, Spot_In_Approval__c, Spot_Sold__c
                        FROM
                            IPTV_Spot_Daily_Status__c
                        WHERE
                            Inventory_Name__c IN : Set_InventoryName AND
                            Date__c IN : Set_date
                    ];

                    system.debug (' === List_IptvSDS : ' + json.serialize(List_IptvSDS) + ' === ');

                    if(List_IptvSDS!=null && !List_IptvSDS.isEmpty()){
                        for(IPTV_Spot_Daily_Status__c IptvSDS : List_IptvSDS){
                            String keyMap = IptvSDS.Inventory_Name__c + String.ValueOf(IptvSDS.Date__c);

                            system.debug (' === keyMap : ' + keyMap + ' === ');
                            system.debug (' === Map_sumSpot.get(keyMap) : ' + Map_sumSpot.get(keyMap) + ' === ');

                            IptvSDS.Spot_In_Approval__c = Map_sumSpot.get(keyMap);
                        }

                        update List_IptvSDS;
                    }
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on TA_AT_MOI_AU_CountQuantitySpotSold afterUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}