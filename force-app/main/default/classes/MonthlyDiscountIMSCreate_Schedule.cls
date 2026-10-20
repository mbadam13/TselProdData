/**
 * @description       : 
 * @Test Class        : MonthlyDiscountIMSCreate_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 09-01-2023
 * @last modified by  : Ahmat Zulkifli Murad
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-29-2023   Novando Utoyo Agmawan   Initial Version
**/

global class MonthlyDiscountIMSCreate_Schedule implements Schedulable{
    global void execute(SchedulableContext sc){
        /* Testing Purpose
        MonthlyDiscountIMSCreate_Batch MonthlyDiscountIMSCreate_Batch_Class = new MonthlyDiscountIMSCreate_Batch(date.newinstance(2023, 01, 01));
        
        Database.executebatch(MonthlyDiscountIMSCreate_Batch_Class,1);
        */

        //this month
        date periodeNow = date.valueOf(system.today());
        MonthlyDiscountIMSCreate_Batch MonthlyDiscountIMSCreate_Batch_ClassThisMonth = new MonthlyDiscountIMSCreate_Batch(periodeNow);
        
        Database.executebatch(MonthlyDiscountIMSCreate_Batch_ClassThisMonth,1);
    }
}