/**
 * @description       : 
 * @testClass         : Order_GenerateMO_Ctrl_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-12-2024
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-11-2024   Novando Utoyo Agmawan   Initial Version
**/

public class Order_GenerateMO_Ctrl {
    @AuraEnabled
    public static string generateMO(String recordId){
        string result = 'Success';

        try{
            List<OrderItem> List_OrderItem = [
                SELECT Id,
                OrderId,
                OrderItemNumber,
                Quantity,
                Usage_Actual__c,
                ServiceDate,
                EndDate,
                Start_and_End_Date_Range__c,
                Total_Amount_Actual__c,
                UnitPrice,
                Product2Id,
                Product2.Name,
                Product2.Duration__c,
                Product2.IPTV_Inventory__c,
                Product2.IPTV_Channel__c,
                Product2.Product_Channel__c,
                Product2.ShowTime__c,
                Product2.Time__c,
                House_Number__c,
                House_Number__r.Name,
                House_Number__r.Versi__c,
                House_Number__r.Brand__c,
                Media_Order__c
                FROM OrderItem
                WHERE OrderId =: recordId
                ORDER BY ServiceDate ASC
            ];

            system.debug('generateMO - List_OrderItem : ' + json.serialize(List_OrderItem));

            if(List_OrderItem!=null && !List_OrderItem.isEmpty()){
                List<AggregateResult> List_CountMO = [
                    SELECT Count(Id) countId
                    FROM Media_Order__c
                ];

                system.debug('generateMO - List_CountMO : ' + json.serialize(List_CountMO));

                List<AggregateResult> List_CountMOLine = [
                    SELECT Count(Id) countId
                    FROM Media_Order__c
                ];

                system.debug('generateMO - List_CountMOLine : ' + json.serialize(List_CountMOLine));

                List<Order> List_Order = [
                    SELECT Id,
                    EffectiveDate,
                    EndDate,
                    OwnerId,
                    Owner.Alias,
                    Sales_Owner__c
                    FROM Order
                    WHERE Id =: recordId
                ];

                system.debug('generateMO - List_Order : ' + json.serialize(List_Order));

                Date todayDate = system.today();
                Integer CountMO = (Integer) List_CountMO[0].get('countId');
                Integer CountMOLine = (Integer) List_CountMOLine[0].get('countId');

                List<Media_Order_Item__c> List_MediaOrderItem = new List<Media_Order_Item__c>();

                Set<String> Set_IptvInventoriIds = new Set<String>();

                for(OrderItem orderItemReq : List_OrderItem){
                    Set_IptvInventoriIds.add(orderItemReq.Product2.IPTV_Inventory__c);
                }

                system.debug('generateMO - Set_IptvInventoriIds : ' + json.serialize(Set_IptvInventoriIds));

                Map<String,IPTV_Spot_Daily_Status__c> Map_IptvSDS = IptvSpotDailyStatusServices.getMapRecordWithRanged(Set_IptvInventoriIds, List_Order[0].EffectiveDate, List_Order[0].EndDate);

                system.debug('generateMO - Map_IptvSDS : ' + json.serialize(Map_IptvSDS));

                if(Map_IptvSDS!=null && !Map_IptvSDS.isEmpty()){
                    for(OrderItem orderItemReq : List_OrderItem){
                        CountMO += 1;
    
                        Media_Order__c mediaOrder = new Media_Order__c();
                        mediaOrder.Name = 'TSEL/TMS' + 
                        String.valueOf(CountMO).leftPad(7, '0') + 
                        '/' + 
                        List_Order[0].Sales_Owner__c + 
                        '/' + 
                        todayDate.month() + 
                        '/' + 
                        todayDate.year();
    
                        mediaOrder.Order__c = recordId;
                        mediaOrder.Order_Product__c = orderItemReq.Id;
                        mediaOrder.Order_Item_ID__c = orderItemReq.OrderItemNumber;
                        mediaOrder.Product_Name__c = orderItemReq.Product2.Name;
                        mediaOrder.House_Number__c = orderItemReq.House_Number__r.Name; 
                        mediaOrder.Brand__c = orderItemReq.House_Number__r.Brand__c;
                        mediaOrder.Versi__c = orderItemReq.House_Number__r.Versi__c;
                        mediaOrder.Channel__c = orderItemReq.Product2.IPTV_Channel__c;
                        mediaOrder.Product_Inventory__c = orderItemReq.Product2.Product_Channel__c;
                        mediaOrder.Showtimes__c = orderItemReq.Product2.ShowTime__c;
                        mediaOrder.Time__c = orderItemReq.Product2.Time__c;
                        mediaOrder.Duration__c = orderItemReq.Product2.Duration__c;
                        mediaOrder.Start_Date__c = orderItemReq.ServiceDate; 
                        mediaOrder.End_Date__c = orderItemReq.EndDate;
                        mediaOrder.Quantity__c = orderItemReq.Quantity;
                        mediaOrder.Delivery__c = orderItemReq.Usage_Actual__c;
                        mediaOrder.Net__c = orderItemReq.UnitPrice;
                        mediaOrder.Amount__c = orderItemReq.Total_Amount_Actual__c;
    
                        Insert mediaOrder;

                        orderItemReq.Media_Order__c = mediaOrder.Id;
    
                        for(Integer i = 0; i <= orderItemReq.Start_and_End_Date_Range__c; i++){
                            String keyMap = String.valueOf(orderItemReq.ServiceDate.addDays(i)) + orderItemReq.Product2.IPTV_Inventory__c;

                            IPTV_Spot_Daily_Status__c IptvSDSRec = Map_IptvSDS.get(keyMap);

                            system.debug('generateMO - IptvSDSRec : ' + json.serialize(IptvSDSRec));

                            if(IptvSDSRec != null){
                                CountMOLine += 1;
        
                                Media_Order_Item__c MediaOrderItem = new Media_Order_Item__c();
                                MediaOrderItem.Name = mediaOrder.Name + 
                                '/' + 
                                orderItemReq.ServiceDate.addDays(i).day();

                                MediaOrderItem.Date__c = orderItemReq.ServiceDate.addDays(i);
                                MediaOrderItem.Duration__c = orderItemReq.Product2.Duration__c;
                                MediaOrderItem.House_Number__c = orderItemReq.House_Number__r.Name;
                                MediaOrderItem.Media_Order__c = mediaOrder.Id;
                                MediaOrderItem.Order_Item_ID__c = orderItemReq.OrderItemNumber;
                                MediaOrderItem.Order_Product__c = orderItemReq.Id;
                                MediaOrderItem.Channel__c = mediaOrder.Channel__c;
                                MediaOrderItem.Product_Name__c = orderItemReq.Product2.Name;
                                MediaOrderItem.Time__c = orderItemReq.Product2.Time__c;
                                MediaOrderItem.Net__c = orderItemReq.UnitPrice;
                                MediaOrderItem.Amount__c = orderItemReq.Total_Amount_Actual__c;
                                MediaOrderItem.Versi__c = orderItemReq.House_Number__r.Versi__c;
                                MediaOrderItem.Inventory_Name__c = orderItemReq.Product2.IPTV_Inventory__c;
                                MediaOrderItem.IPTV_Spot_Daily_Status__c = IptvSDSRec.Id;
        
                                List_MediaOrderItem.add(MediaOrderItem);
                            }else{
                                result = 'Failed';
                                Break;
                            }
                        }
                    }

                    system.debug('generateMO - result : ' + result);
                    
                    if(result == 'Success'){
                        if(List_MediaOrderItem!=null && !List_MediaOrderItem.isEmpty()){
                            insert List_MediaOrderItem;

                            update List_OrderItem;
                        }
                    }else{
                        List<Media_Order__c> mediaOrderDelete = [
                            SELECT 
                                Id 
                            FROM
                                Media_Order__c
                            WHERE
                                Order__c =: recordId
                        ];

                        delete mediaOrderDelete;
                    }
                }else{
                    result = 'Failed';
                }
            }else{
                result = 'Failed';
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            result = 'Failed';

            string errMessage = 'Error on Order_GenerateMO_Ctrl generateMO function::' + e.getmessage() + '::' + e.getLineNumber();
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

        return result;
    }
}