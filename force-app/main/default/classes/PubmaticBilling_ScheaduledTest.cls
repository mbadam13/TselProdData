@isTest
public with sharing class PubmaticBilling_ScheaduledTest {
    @isTest
    public static void runScheduled(){
        test.startTest();
        PubmaticBilling_Scheaduled PubmaticBilling_ScheaduledClass = new PubmaticBilling_Scheaduled();
            String sch = '0 0 23 * * ?'; system.schedule('Test  scheduledPubmaticBilling', sch, PubmaticBilling_ScheaduledClass); Test.stopTest(); 
        
    }
}