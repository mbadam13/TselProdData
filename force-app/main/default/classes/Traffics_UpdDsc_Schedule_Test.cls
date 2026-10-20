/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest()
public class Traffics_UpdDsc_Schedule_Test {
    public static testMethod void testMethodD(){
        Datetime nextSchedule = system.now().addSeconds(1);

        String hour = String.valueOf( nextSchedule.hour());
        String min = String.valueOf( nextSchedule.minute()); 
        String ss = String.valueOf( nextSchedule.second());
        String sDay = string.valueof( nextSchedule.day() ); 
        String sYear = string.valueof( nextSchedule.year() );
        String sMonth = string.valueof( nextSchedule.month() );
        
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
        
        Traffics_UpdDsc_Schedule Traffics_UpdDsc_Schedule_Class = new Traffics_UpdDsc_Schedule();

        System.schedule('Traffics_UpdDsc_Schedule ' + AppUtils.getNewGUID() + '-' + String.valueOf(system.now()), nextFireTime, Traffics_UpdDsc_Schedule_Class);
    }
}