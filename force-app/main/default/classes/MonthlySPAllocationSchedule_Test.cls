/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 10-12-2023
 * @last modified by  : Ahmat Zulkifli Murad
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest()
public class MonthlySPAllocationSchedule_Test {
    public static testMethod void testMethodD(){
        Test.startTest();
        Datetime nextSchedule = system.now().addSeconds(1);

        String hour = String.valueOf( nextSchedule.hour());
        String min = String.valueOf( nextSchedule.minute()); 
        String ss = String.valueOf( nextSchedule.second());
        String sDay = string.valueof( nextSchedule.day() ); 
        String sYear = string.valueof( nextSchedule.year() );
        String sMonth = string.valueof( nextSchedule.month() );
        
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
        
        MonthlySPAllocationSchedule MonthlySPAllocationSchedule_Class = new MonthlySPAllocationSchedule();
        MonthlySPAllocationSchedule_LastMonth MonthlySPAllocationScheduleLastMonth_Class = new MonthlySPAllocationSchedule_LastMonth(); 

        System.schedule('MonthlySPAllocationSchedule ' + AppUtils.getNewGUID() + '-' + String.valueOf(system.now()), nextFireTime, MonthlySPAllocationSchedule_Class);
        System.schedule('MonthlySPAllocationSchedule ' + AppUtils.getNewGUID() + '-' + String.valueOf(system.now()), nextFireTime, MonthlySPAllocationScheduleLastMonth_Class);
        Test.stopTest();
    }
}