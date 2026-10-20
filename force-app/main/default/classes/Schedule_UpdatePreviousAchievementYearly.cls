/**
 * @description       : 
 * @author            : M B Adam
 * @group             : 
 * @last modified on  : 07-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class  Schedule_UpdatePreviousAchievementYearly implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdatePreviousAchievementBatchYearly(), 200);
    }
}