/**
 * @description       : 
 * @Test Class       : MonthlyDiscountIMSCreate_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 09-01-2023
 * @last modified by  : Ahmat Zulkifli Murad
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-27-2023   Novando Utoyo Agmawan   Initial Version
**/

global class MonthlyDiscountIMSCreate_LstMnth_Schdlr implements Schedulable{
    global void execute(SchedulableContext sc){
        /* Testing Purpose
        MonthlyDiscountIMSCreate_LstMnth_Batch MonthlyDiscountIMSCreate_LstMnth_Batch_Class = new MonthlyDiscountIMSCreate_LstMnth_Batch(date.newinstance(2023, 01, 01));
        
        Database.executebatch(MonthlyDiscountIMSCreate_LstMnth_Batch_Class,1);
        */
        
        //last month
        date lastMonth = system.today().addMonths(-1);
        MonthlyDiscountIMSCreate_LstMnth_Batch MonthlyDiscountIMSCreate_LstMnth_Batch_Class = new MonthlyDiscountIMSCreate_LstMnth_Batch(lastMonth);
    
        Database.executebatch(MonthlyDiscountIMSCreate_LstMnth_Batch_Class,1);
    }
}