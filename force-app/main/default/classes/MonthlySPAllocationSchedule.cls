/**
 * @description       : 
 * @Test Class        : MonthlySPAllocationSchedule_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-25-2023   Novando Utoyo Agmawan   Initial Version
**/

global class MonthlySPAllocationSchedule implements Schedulable{
    global void execute(SchedulableContext sc){
        /* Testing Purpose
        MonthlySPAllocationServices.createMonthlySpecialPriceAllocation(date.newinstance(2023, 01, 01));
        */
        
        Date scheduleRunDate = system.today();

        MonthlySPAllocationServices.createMonthlySpecialPriceAllocation(scheduleRunDate);
    }
}