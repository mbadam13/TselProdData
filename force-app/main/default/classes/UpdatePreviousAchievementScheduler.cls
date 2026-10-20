/**
 * @description       : Scheduler for UpdatePreviousAchievementBatch
 * @author            : M B Adam
 * @last modified on  : 06-25-2025
**/
global class UpdatePreviousAchievementScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
       
            
        
            UpdatePreviousAchievementBatch batch = new UpdatePreviousAchievementBatch();
            Database.executeBatch(batch, 40); 
       
    }
}