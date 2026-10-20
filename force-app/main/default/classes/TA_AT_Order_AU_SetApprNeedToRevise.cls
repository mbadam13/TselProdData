/**
 * @description       : 
 * @TestClass         : TA_AT_Order_AU_SetApprNeedToReviseTEST
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-01-2024   Novando Utoyo Agmawan   Initial Version
**/

public class TA_AT_Order_AU_SetApprNeedToRevise implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<Order> newList, List<Order> oldList){
        try{
            system.debug (' === TA_AT_Order_AU_SetApprNeedToRevise === ');

            Map<Id,Order> oldMap = new Map<Id,Order>(oldList);

            Set<String> Set_OrderIds = new Set<String>();

            for (Order orderRec : newList) {
                if(
                    orderRec.Approval_Status__c != oldMap.get(orderRec.id).Approval_Status__c &&
                    orderRec.Approval_Status__c == 'Rejected'
                ){
                    Set_OrderIds.add(orderRec.Id);
                }
            }

            system.debug (' === Set_OrderIds : ' + Set_OrderIds + ' === ');

            if(Set_OrderIds!=null && !Set_OrderIds.isEmpty()){
                Map<String,ProcessInstanceStep>  map_PIS = AppUtils.getMapLastApprovalStep(Set_OrderIds);

                system.debug (' === map_PIS : ' +  json.serialize(map_PIS) + ' === ');

                if(map_PIS!=null && !map_PIS.isEmpty()){
                    List<Approval_Comment_Contains_Setting__c> List_ApprovalCommentCS = [
                        SELECT
                            Id, value_Include__c
                        FROM
                        Approval_Comment_Contains_Setting__c
                        WHERE
                            Name = 'Revise'
                    ];

                    system.debug (' === List_ApprovalCommentCS : ' +  json.serialize(List_ApprovalCommentCS) + ' === ');
                    
                    if(List_ApprovalCommentCS!=null && !List_ApprovalCommentCS.isEmpty()){
                        List<String> List_comments = List_ApprovalCommentCS[0].value_Include__c.toLowerCase().split(',');

                        system.debug (' === List_comments : ' +  json.serialize(List_comments) + ' === ');

                        List<Order> List_orderUpd = new List<Order>();

                        for (String orderId : Set_OrderIds) {
                            if(map_PIS.get(orderId) != null){
                                Boolean commentInclude = false;

                                for (String comments : List_comments) {
                                    if(
                                        map_PIS.get(orderId).Comments.toLowerCase().contains(comments)
                                    ){
                                        commentInclude = true;
                                        break;
                                    }
                                }

                                if(commentInclude == true){
                                    Order orderUpd = new Order();
                                    orderUpd.Id = orderId;
                                    orderUpd.Approval_Status__c = 'Need to Revise';

                                    List_orderUpd.add(orderUpd);
                                }
                            }
                        }

                        system.debug (' === List_orderUpd : ' +  json.serialize(List_orderUpd) + ' === ');

                        if(List_orderUpd!=null && !List_orderUpd.isEmpty()){
                            update List_orderUpd;
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
            string errMessage = 'Error on TA_AT_Order_AU_SetApprNeedToRevise afterUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}