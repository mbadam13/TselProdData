/**
 * @description       : 
 * @Test Class        : MonthlySPAllocationTrigger_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 06-22-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-25-2023   Novando Utoyo Agmawan   Initial Version
**/

public class MonthlySPAllocationTriggerHandler {
    public static void afterInsertHandler(list<Monthly_Special_Price_Allocation__c> List_MonthlySpecialPriceAllocation){
        try{
            Set<String> Set_MonthlySpecialPriceAllocation_Id = new Set<String>();
            
            if(List_MonthlySpecialPriceAllocation != null && !List_MonthlySpecialPriceAllocation.isEmpty()){
                for (Monthly_Special_Price_Allocation__c MonthlySpecialPriceAllocation : List_MonthlySpecialPriceAllocation){
                    Set_MonthlySpecialPriceAllocation_Id.add(MonthlySpecialPriceAllocation.Id);
                }

                if(Set_MonthlySpecialPriceAllocation_Id != null && !Set_MonthlySpecialPriceAllocation_Id.isEmpty()){
                    MonthlySPAllocationServices.setSpesialAndAlocationPrice(Set_MonthlySpecialPriceAllocation_Id);
                }
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlySPAllocationTriggerHandler afterInsertHandler function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }

    public static void afterUpdateHandler(list<Monthly_Special_Price_Allocation__c> List_MonthlySpecialPriceAllocation, Map<Id, Monthly_Special_Price_Allocation__c> Map_OldMonthlySpecialPriceAllocation ){
        try{
            Set<String> Set_MonthlySpecialPriceAllocation_Id = new Set<String>();
            
            if(List_MonthlySpecialPriceAllocation != null && !List_MonthlySpecialPriceAllocation.isEmpty()){
                for (Monthly_Special_Price_Allocation__c MonthlySpecialPriceAllocation : List_MonthlySpecialPriceAllocation){
                    Monthly_Special_Price_Allocation__c old_MonthlySpecialPriceAllocation = Map_OldMonthlySpecialPriceAllocation.get(MonthlySpecialPriceAllocation.Id);

                    if(
                        (MonthlySpecialPriceAllocation.Usage__c != old_MonthlySpecialPriceAllocation.Usage__c) && 
                        MonthlySpecialPriceAllocation.Usage__c != null
                    ){
                        Set_MonthlySpecialPriceAllocation_Id.add(MonthlySpecialPriceAllocation.Id);
                    }
                }

                if(Set_MonthlySpecialPriceAllocation_Id != null && !Set_MonthlySpecialPriceAllocation_Id.isEmpty()){
                    MonthlySPAllocationServices.setSpesialAndAlocationPrice(Set_MonthlySpecialPriceAllocation_Id);
                }
            }
        }catch(exception e){
            string errMessage = 'Error on MonthlySPAllocationTriggerHandler afterUpdateHandler function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}