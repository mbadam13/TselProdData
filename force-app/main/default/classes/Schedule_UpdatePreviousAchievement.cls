/**
 * @description       : Scheduler for UpdatePreviousAchievementBatch
 * @author            : M B Adam
 * @last modified on  : 07-01-2025
**/
global class Schedule_UpdatePreviousAchievement implements Schedulable {

    global void execute(SchedulableContext sc) {
       
        UpdatePreviousAchievementBatch batch = new UpdatePreviousAchievementBatch();
        Database.executeBatch(batch, 200); 
       
    }
}