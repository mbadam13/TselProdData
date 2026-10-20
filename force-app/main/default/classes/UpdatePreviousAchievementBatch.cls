/**
 * @description       : 
 * @author            : M B Adam
 * @group             : 
 * @last modified on  : 07-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class UpdatePreviousAchievementBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Date__c, LOB__c, Type__c, Adjustment_Amount__c, Previous_Achievement__c
            FROM Monthly_Sales_Target__c
            WHERE Type__c = 'Revenue Actual'
            AND Date__c != null
            AND LOB__c != null
            AND Previous_Achievement__c = null
            ORDER BY Date__c DESC
        ]);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            List<Monthly_Sales_Target__c> records = (List<Monthly_Sales_Target__c>) scope;
            List<Monthly_Sales_Target__c> updates = new List<Monthly_Sales_Target__c>();

            Set<String> lobIds = new Set<String>();
            Set<String> prevKeys = new Set<String>();

            
            for (Monthly_Sales_Target__c rec : records) {
                if (rec.LOB__c != null && rec.Date__c != null) {
                    lobIds.add(rec.LOB__c);
                    Date prevMonth = rec.Date__c.toStartOfMonth().addMonths(-1);
                    String key = buildKey(rec.LOB__c, prevMonth);
                    prevKeys.add(key);
                }
            }

        
            List<AggregateResult> summaryResults = [
                SELECT CALENDAR_YEAR(Date__c) yr, CALENDAR_MONTH(Date__c) mth, LOB__c lobId, SUM(Adjustment_Amount__c) total
                FROM Monthly_Sales_Target__c
                WHERE Type__c = 'Revenue Actual'
                AND Date__c != null
                AND LOB__c IN :lobIds
                GROUP BY CALENDAR_YEAR(Date__c), CALENDAR_MONTH(Date__c), LOB__c
            ];

           
            Map<String, Decimal> summaryMap = new Map<String, Decimal>();
            for (AggregateResult ar : summaryResults) {
                Integer year = (Integer) ar.get('yr');
                Integer month = (Integer) ar.get('mth');
                String lobId = (String) ar.get('lobId');
                Decimal total = (Decimal) ar.get('total');

                String key = buildKey(lobId, year, month);
                summaryMap.put(key, total);
            }

          
            for (Monthly_Sales_Target__c rec : records) {
                if (rec.LOB__c != null && rec.Date__c != null) {
                    Date prevMonth = rec.Date__c.toStartOfMonth().addMonths(-1);
                    String prevKey = buildKey(rec.LOB__c, prevMonth);

                    if (summaryMap.containsKey(prevKey)) {
                        rec.Previous_Achievement__c = summaryMap.get(prevKey);
                        updates.add(rec);
                    }
                }
            }

            if (!updates.isEmpty()) {
                Database.update(updates, false); 
                System.debug('Updated ' + updates.size() + ' records.');
            } else {
                System.debug('No records to update.');
            }

        } catch (Exception e) {
            String errMsg = 'Error in execute(): ' + e.getMessage() + ' at line ' + e.getLineNumber();
            System.debug(errMsg);
            AppUtils.putError(errMsg);
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch finished.');

         String jobName = 'UpdatePreviousAchievementMonthly';
        String cronExpr = '0 0 * * * ?';

       
        for (CronTrigger ct : [
            SELECT Id, CronJobDetail.Name 
            FROM CronTrigger 
            WHERE CronJobDetail.Name = :jobName
        ]) {
            System.abortJob(ct.Id);
            System.debug('Removed existing job: ' + ct.Id);
        }

            
            System.schedule(jobName, cronExpr, new Schedule_UpdatePreviousAchievement());
            
    }

 
    private String buildKey(String lobId, Date dt) {
        Integer year = dt.year();
        Integer month = dt.month();
        return lobId + '-' + year + '-' + month;
    }

   
    private String buildKey(String lobId, Integer year, Integer month) {
        return lobId + '-' + year + '-' + month;
    }
}