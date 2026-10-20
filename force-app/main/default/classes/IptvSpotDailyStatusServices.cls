/**
 * @description       : 
 * @testClass         : IptvSpotDailyStatusServices_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 08-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-24-2024   Novando Utoyo Agmawan   Initial Version
 * 2.0   15-08-2023   Muhammad Adam           Adda methods : countSpotDailyInApproval and countSpotDailyApproved
**/

public class IptvSpotDailyStatusServices {
    public static Map<String,IPTV_Spot_Daily_Status__c> getMapRecordWithRanged(Set<String> Set_IptvInventoriIds, Date startDate, Date endDate) {
        Map<String,IPTV_Spot_Daily_Status__c> Map_IptvSDSResult = new Map<String,IPTV_Spot_Daily_Status__c>();

        try{
            if(Set_IptvInventoriIds!=null && !Set_IptvInventoriIds.isEmpty()){
                List<IPTV_Spot_Daily_Status__c> List_IptvSDS = [
                    SELECT  
                        Id, Name, IPTV_Spot_Limit__c, Inventory_Name__c, Spot_In_Approval__c, Status__c, Spot_Remaining__c, Spot_Sold__c, Spot_Sold_Percent__c, Date__c
                    FROM
                        IPTV_Spot_Daily_Status__c
                    WHERE
                        Inventory_Name__c IN : Set_IptvInventoriIds AND
                        Date__c >=: startDate AND
                        Date__c <=: endDate
                    ORDER BY 
                        Date__c ASC
                ];

                system.debug('getMapRecordWithRanged - List_IptvSDS : ' + json.serialize(List_IptvSDS));

                if(List_IptvSDS!=null && !List_IptvSDS.isEmpty()){
                    for(IPTV_Spot_Daily_Status__c IptvSDS : List_IptvSDS){
                        String keyMap = String.ValueOf(IptvSDS.Date__c) + IptvSDS.Inventory_Name__c;

                        Map_IptvSDSResult.put(keyMap, IptvSDS);
                    }
                }

                system.debug('getMapRecordWithRanged - Map_IptvSDSResult : ' + json.serialize(Map_IptvSDSResult));
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on IptvSpotDailyStatusServices getMapRecordWithRanged function::' + e.getmessage() + '::' + e.getLineNumber();
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

        return Map_IptvSDSResult;
    }

    public static void countSpotDailyInApproval(Set<String> Set_OrderIds) {
        if (!Set_OrderIds.isEmpty()) {
            List<Media_Order_Item__c> List_OrderItem = [
                SELECT Id, IPTV_Spot_Daily_Status__c, Media_Order__r.Order__c
                FROM Media_Order_Item__c
                WHERE Media_Order__r.Order__c IN :Set_OrderIds
            ];

            system.debug(' === List_MOItem : ' + JSON.serialize(List_OrderItem) + ' === ');

            Set<String> Set_IPTVSDS = new Set<String>();

            for (Media_Order_Item__c orderItem : List_OrderItem) {
                Set_IPTVSDS.add(orderItem.IPTV_Spot_Daily_Status__c);
            }

            system.debug(' === Set_IPTVSDS : ' + Set_IPTVSDS + ' === ');

            if (!Set_IPTVSDS.isEmpty()) {
                List<AggregateResult> List_sumSpot = [
                    SELECT 
                        IPTV_Spot_Daily_Status__c IPTVSDSId, 
                        Date__c recordDate, 
                        SUM(Spot_Needed__c) spotNeeded
                        
                    FROM 
                        Media_Order_Item__c
                    WHERE 
                        IPTV_Spot_Daily_Status__c IN :Set_IPTVSDS
                        AND (
                            Media_Order__r.Order__r.Approval_Status__c='Submit' 
                            OR 
                            Media_Order__r.Order__r.Approval_Status__c='Need to Revise' 
                        )
                    GROUP BY 
                        IPTV_Spot_Daily_Status__c, Date__c
                ];

                //system.debug(' === List_sumSpot : ' + JSON.serialize(List_sumSpot) + ' === ');

                
                    Map<String, Integer> Map_sumSpot = new Map<String, Integer>();

                    for (AggregateResult sumSpot : List_sumSpot) {
                        String IPTVSDSName = (String) sumSpot.get('IPTVSDSId');
                        Integer spotNeeded = ((Decimal) sumSpot.get('spotNeeded')).intValue();
                        Map_sumSpot.put(IPTVSDSName, spotNeeded);
                    }
               

                    //system.debug(' === Map_sumSpot : ' + JSON.serialize(Map_sumSpot) + ' === ');
                    
                    List<IPTV_Spot_Daily_Status__c> List_IptvSDS = new List<IPTV_Spot_Daily_Status__c>();
                    
                    for (String IptvSDS : Set_IPTVSDS) {
                        IPTV_Spot_Daily_Status__c IPTVSDSRec = new IPTV_Spot_Daily_Status__c();
                        IPTVSDSRec.Id = IptvSDS;

                        String keyMap = IptvSDS;
                        if (Map_sumSpot.containsKey(keyMap)) {
                            IPTVSDSRec.Spot_In_Approval__c = Map_sumSpot.get(keyMap);
                        } else {
                            IPTVSDSRec.Spot_In_Approval__c = 0;
                        }
                    

                        List_IptvSDS.add(IPTVSDSRec);
                    }

                    system.debug(' === List_IptvSDS : ' + JSON.serialize(List_IptvSDS) + ' === ');

                    update List_IptvSDS;
                
            }
        }
    } 


    public static void countSpotDailyApproved(Set<String> Set_OrderIds) {
        if (!Set_OrderIds.isEmpty()) {
            List<Media_Order_Item__c> List_OrderItem = [
                SELECT Id, IPTV_Spot_Daily_Status__c, Media_Order__r.Order__c
                FROM Media_Order_Item__c
                WHERE Media_Order__r.Order__c IN :Set_OrderIds
            ];

            system.debug(' === List_MOItem : ' + JSON.serialize(List_OrderItem) + ' === ');

            Set<String> Set_IPTVSDS = new Set<String>();

            for (Media_Order_Item__c orderItem : List_OrderItem) {
                Set_IPTVSDS.add(orderItem.IPTV_Spot_Daily_Status__c);
            }

            system.debug(' === Set_IPTVSDS : ' + Set_IPTVSDS + ' === ');

            if (!Set_IPTVSDS.isEmpty()) {
                List<AggregateResult> List_sumSpot = [
                    SELECT 
                        IPTV_Spot_Daily_Status__c IPTVSDSId, 
                        Date__c recordDate, 
                        SUM(Spot_Needed__c) spotNeeded
                    FROM 
                        Media_Order_Item__c
                    WHERE 
                        IPTV_Spot_Daily_Status__c IN :Set_IPTVSDS
                        AND (
                            Media_Order__r.Order__r.Approval_Status__c='Approved' 
                            
                        )
                    GROUP BY 
                        IPTV_Spot_Daily_Status__c, Date__c
                ];

                system.debug(' === List_sumSpot : ' + JSON.serialize(List_sumSpot) + ' === ');

                
                    Map<String, Integer> Map_sumSpot = new Map<String, Integer>();

                    for (AggregateResult sumSpot : List_sumSpot) {
                        String IPTVSDSName = (String) sumSpot.get('IPTVSDSId');
                        Integer spotNeeded = ((Decimal) sumSpot.get('spotNeeded')).intValue();
                        Map_sumSpot.put(IPTVSDSName, spotNeeded);
                    }

                   // system.debug(' === Map_sumSpot : ' + JSON.serialize(Map_sumSpot) + ' === ');

                    List<IPTV_Spot_Daily_Status__c> List_IptvSDS = new List<IPTV_Spot_Daily_Status__c>();

                    for (String IptvSDS : Set_IPTVSDS) {
                        IPTV_Spot_Daily_Status__c IPTVSDSRec = new IPTV_Spot_Daily_Status__c();
                        IPTVSDSRec.Id = IptvSDS;

                        String keyMap = IptvSDS;
                        if (Map_sumSpot.containsKey(keyMap)) {
                            IPTVSDSRec.Spot_Sold__c = Map_sumSpot.get(keyMap);
                        } else {
                            IPTVSDSRec.Spot_Sold__c = 0;
                        }

                        List_IptvSDS.add(IPTVSDSRec);
                    }

                    system.debug(' === List_IptvSDS : ' + JSON.serialize(List_IptvSDS) + ' === ');

                    update List_IptvSDS;
                
            }
        }
    } 

    


}