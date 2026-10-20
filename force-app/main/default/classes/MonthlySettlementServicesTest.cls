@isTest
public with sharing class MonthlySettlementServicesTest {
    @isTest
    public static void testMonthlySettlementServices(){
        Date someDate = Date.today();
        List<Date> dateNow = new List<Date>();
        dateNow.add(someDate);
        MonthlySettlementServices.refreshMonthlySettlementDetail(dateNow);
    }
    
}