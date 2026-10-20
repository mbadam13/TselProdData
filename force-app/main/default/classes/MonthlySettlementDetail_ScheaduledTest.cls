@isTest
public with sharing class MonthlySettlementDetail_ScheaduledTest {
    @isTest
    public static void testMonthlySettlementDetail_Scheaduled(){
        test.startTest();
        MonthlySettlementDetail_Scheaduled MonthlySettlementDetail_ScheaduledClass = new MonthlySettlementDetail_Scheaduled();
        String sch = '0 0 23 * * ?'; system.schedule('Test  MonthlySettlementDetail_ScheaduledClass', sch, MonthlySettlementDetail_ScheaduledClass); 
        Test.stopTest(); 
    }
}