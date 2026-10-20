/**
 * @description       : 
 * @Test Class        : Traffics_UpdDsc_Schedule_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 06-27-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-26-2023   Novando Utoyo Agmawan   Initial Version
**/

global class Traffics_UpdDsc_Schedule implements Schedulable{
    global void execute(SchedulableContext sc){
        /* Testing Purpose
        TrafficsSID_UpdDsc_Batch TrafficsSID_UpdDsc_Batch_Class = new TrafficsSID_UpdDsc_Batch(date.newinstance(2023, 01, 01));
        
        Database.executebatch(TrafficsSID_UpdDsc_Batch_Class,170);
        */
        
        TrafficsSID_UpdDsc_Batch TrafficsSID_UpdDsc_Batch_Class = new TrafficsSID_UpdDsc_Batch(system.today());
        Database.executebatch(TrafficsSID_UpdDsc_Batch_Class,20);



        TrafficsNB_UpdDsc_Batch TrafficsNB_UpdDsc_Batch_Class = new TrafficsNB_UpdDsc_Batch(system.today());
        Database.executebatch(TrafficsNB_UpdDsc_Batch_Class,20);
    }
}