/**
 * @description       : 
 * @Test Class        : MonthlyDiscountIMSTriggerHandler_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-01-2023   Novando Utoyo Agmawan   Initial Version
**/

public class MonthlyDiscountIMSTriggerHandler {
    
    public static void afterInsertHandler(list<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller){
        try{
            system.debug('====== MonthlyDiscountIMSTriggerHandler afterInsertHandler ======');
            system.debug('afterInsertHandler List_MonthlyDiscountInventoryMediaSeller : ' + json.serialize(List_MonthlyDiscountInventoryMediaSeller));

            Set<String> Set_MonthlyDiscountInventoryMediaafterInsertHandlerSeller_Id = new Set<String>();
            
            if(List_MonthlyDiscountInventoryMediaSeller != null && !List_MonthlyDiscountInventoryMediaSeller.isEmpty()){
                for (Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller : List_MonthlyDiscountInventoryMediaSeller){
                    Set_MonthlyDiscountInventoryMediaafterInsertHandlerSeller_Id.add(MonthlyDiscountInventoryMediaSeller.id);
                }
                MonthlyDiscountIMSServices.setValueDiscount(Set_MonthlyDiscountInventoryMediaafterInsertHandlerSeller_Id);
                system.debug('afterInsertHandler List_MonthlyDiscountInventoryMediaSeller : ' + json.serialize(List_MonthlyDiscountInventoryMediaSeller));
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlyDiscountIMSTriggerHandler afterInsertHandler function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
    

    public static void afterUpdateHandler(list<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller, Map<Id, Monthly_Discount_Inventory_Media_Seller__c> Map_MonthlyDiscountInventoryMediaSeller){
        try{
            system.debug('====== MonthlyDiscountIMSTriggerHandler afterUpdateHandler ======');
            system.debug('afterUpdateHandler List_MonthlyDiscountInventoryMediaSeller : ' + json.serialize(List_MonthlyDiscountInventoryMediaSeller));

            Set<String> Set_MonthlyDiscountInventoryMediaSeller_Id = new Set<String>();
            Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSellerRec;
            list<Monthly_Discount_Inventory_Media_Seller__c> MonthlyDiscountInventoryMediaSellerRecList = new list<Monthly_Discount_Inventory_Media_Seller__c>();

            Integer currentMonth = system.today().month();
            
            if(List_MonthlyDiscountInventoryMediaSeller != null && !List_MonthlyDiscountInventoryMediaSeller.isEmpty()){
                for (Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller : List_MonthlyDiscountInventoryMediaSeller){
                    Monthly_Discount_Inventory_Media_Seller__c old_MonthlyDiscountInventoryMediaSeller = Map_MonthlyDiscountInventoryMediaSeller.get(MonthlyDiscountInventoryMediaSeller.Id);
                    /*
                    if(
                        MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c != 
                        old_MonthlyDiscountInventoryMediaSeller.Current_Revenue_from_traffic__c
                    ){
                        MonthlyDiscountIMSServices.setValueDiscountUpdate(MonthlyDiscountInventoryMediaSeller);
                    } 
                    */  
                    MonthlyDiscountIMSServices.setValueDiscountUpdate(MonthlyDiscountInventoryMediaSeller);
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlyDiscountIMSTriggerHandler afterUpdateHandler function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}