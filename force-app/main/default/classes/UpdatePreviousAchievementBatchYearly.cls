/**
 * @description       : 
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class UpdatePreviousAchievementBatchYearly implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Date__c, LOB__c, Type__c, Adjustment_Amount__c, Previous_Achievement_Yearly__c
            FROM Monthly_Sales_Target__c
            WHERE Type__c = 'Revenue Actual'
            AND Date__c != null
            AND LOB__c != null
            AND Previous_Achievement_Yearly__c = null
            
            ORDER BY Date__c ASC
        ]);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
     try {
        List<Monthly_Sales_Target__c> records = (List<Monthly_Sales_Target__c>) scope;
        List<Monthly_Sales_Target__c> updates = new List<Monthly_Sales_Target__c>();

        // Ambil LOB dan tahun dari record scope
        Set<String> lobIds = new Set<String>();
        Set<Integer> prevYears = new Set<Integer>();
        for (Monthly_Sales_Target__c rec : records) {
            if (rec.Date__c != null && rec.LOB__c != null) {
                lobIds.add(rec.LOB__c);
                prevYears.add(rec.Date__c.year() - 1);
            }
        }

        // Query summary data dari tahun sebelumnya (dengan GROUP BY)
        List<AggregateResult> summaryResults = [
            SELECT CALENDAR_YEAR(Date__c) year, LOB__c lobId, SUM(Adjustment_Amount__c) total
            FROM Monthly_Sales_Target__c
            WHERE Type__c = 'Revenue Actual'
            AND Date__c != null
            AND LOB__c IN :lobIds
            AND CALENDAR_YEAR(Date__c) IN :prevYears
            GROUP BY CALENDAR_YEAR(Date__c), LOB__c
        ];

        // Simpan hasil summary ke dalam map
        Map<String, Decimal> yearLobSummary = new Map<String, Decimal>();
        for (AggregateResult ar : summaryResults) {
            Integer year = (Integer) ar.get('year');
            String lobId = (String) ar.get('lobId');
            Decimal total = (Decimal) ar.get('total');
            String key = lobId + '-' + String.valueOf(year);
            yearLobSummary.put(key, total);
        }

        // Update record scope berdasarkan summary tahun sebelumnya
        for (Monthly_Sales_Target__c rec : records) {
            if (rec.Date__c != null && rec.LOB__c != null) {
                Integer prevYear = rec.Date__c.year() - 1;
                String key = rec.LOB__c + '-' + String.valueOf(prevYear);

                if (yearLobSummary.containsKey(key)) {
                    rec.Previous_Achievement_Yearly__c = yearLobSummary.get(key);
                    updates.add(rec);
                }
            }
        }

       
        if (!updates.isEmpty()) {
            update updates;
            System.debug('Updated: ' + updates.size());
        } else {
            System.debug(' No records to update in this batch.');
        }

      } catch (Exception e) {
        String errMessage = ' ERROR in execute(): ' + e.getMessage() + ' at line ' + e.getLineNumber();
        System.debug(errMessage);
        AppUtils.putError(errMessage);
      }
  }


    public void finish(Database.BatchableContext BC) {
        System.debug('Batch finished.');

         String jobName = 'UpdatePreviousAchievementYearly';
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

    // Helper method to create a key based on LOB and Year
    private String buildYearKey(String lob, Date dt) {
        return lob + '-' + dt.year();
    }
}