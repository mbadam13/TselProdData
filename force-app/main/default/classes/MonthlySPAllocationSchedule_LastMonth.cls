/*
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @Test Class        : MonthlySPAllocationSchedule_Test
 * @group             : 
 * @last modified on  : 10-12-2023
 * @last modified by  : Ahmat Zulkifli Murad
 */

global with sharing class MonthlySPAllocationSchedule_LastMonth implements Schedulable{
    global void execute(SchedulableContext sc){
        
        Date scheduleRunDate = system.today();

        MonthlySPAllocationServices.createMonthlySpecialPriceAllocation(scheduleRunDate.addMonths(-1));
    }
}