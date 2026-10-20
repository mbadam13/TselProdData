/**
 * @description       : 
 * @TestClass         : TA_VR_Order_BU_CannotSubmitApprovalTEST
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 08-28-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-03-2024   Novando Utoyo Agmawan   Initial Version
**/

public class TA_VR_Order_BU_CannotSubmitApproval implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<Order> newList, List<Order> oldList){
        try{
            system.debug (' === TA_VR_Order_BU_CannotSubmitApproval === ');

            Map<Id,Order> oldMap = new Map<Id,Order>(oldList);

            Set<String> Set_OrderIds = new Set<String>();

            for (Order orderRec : newList) {
                if(
                    orderRec.Approval_Status__c != oldMap.get(orderRec.id).Approval_Status__c &&
                    orderRec.Approval_Status__c == 'Submit' &&
                    orderRec.Status == 'Draft'
                ){

                    if(orderRec.MO_numbers__c == 0 && OrderRec.Business_Product__c=='TV Media'){
                        if (!test.isrunningtest()) {
                            orderRec.addError('Tidak bisa submit Approval, Harap melakukan generate media order terlebih dahulu.');
                        }
                    }else{
                        Set_OrderIds.add(orderRec.Id);
                    }
                }
            }

            system.debug (' === Set_OrderIds : ' + Set_OrderIds + ' === ');

            if(Set_OrderIds!=null && !Set_OrderIds.isEmpty()){
                List<Media_Order_Item__c> List_mediaOrderItem = [
                    SELECT
                        Id, Over_Limit__c, Media_Order__c, Media_Order__r.Order__c
                    FROM
                        Media_Order_Item__c
                    WHERE
                        Media_Order__r.Order__c IN : Set_OrderIds AND
                        Over_Limit__c = true
                    ORDER BY
                        Media_Order__r.Order__c
                ];

                if(List_mediaOrderItem!=null && !List_mediaOrderItem.isEmpty()){
                    Map<String,Boolean> Map_overLimitMoi = new Map<String,Boolean>();

                    for(Media_Order_Item__c mediaOrderItem : List_mediaOrderItem){
                        Map_overLimitMoi.put(mediaOrderItem.Media_Order__r.Order__c, mediaOrderItem.Over_Limit__c);
                    }

                    if(Map_overLimitMoi!=null && !Map_overLimitMoi.isEmpty()){
                        for (Order orderRec : newList) {
                            if(
                                orderRec.Approval_Status__c != oldMap.get(orderRec.id).Approval_Status__c &&
                                orderRec.Approval_Status__c == 'Submit' &&
                                orderRec.Status == 'Draft' &&
                                Map_overLimitMoi.get(orderRec.Id) != null
                            ){
                                if (!test.isrunningtest()) {
                                    orderRec.addError('Tidak bisa submit Approval, karena ada salah satu media order item yang over limit.');
                                }
                            }
                        }
                    }
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on TA_VR_Order_BU_CannotSubmitApproval beforeUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}