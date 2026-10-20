@isTest
private class ExchangeRatesTriggerHandlerTest {
    @isTest
    static void testValidationDuplicateExchangesRate() {
        Trigger_Setting__c triggerSettingsRecValidationDataExchangesRateisExist = new Trigger_Setting__c();
        triggerSettingsRecValidationDataExchangesRateisExist.IsActive__c = true;
        triggerSettingsRecValidationDataExchangesRateisExist.name = 'Validation:_ExcRateisExist';
        triggerSettingsRecValidationDataExchangesRateisExist.Error_Message__c = 'tidak bisa membuat data karena sudah ada dalam periode yang ditentukan';
        triggerSettingsRecValidationDataExchangesRateisExist.Object_Name__c = 'ExchangeRates__c';

        insert triggerSettingsRecValidationDataExchangesRateisExist;
        
        // Simulasi data
        ExchangeRates__c existingExchangeRate = new ExchangeRates__c(
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(10),
            isActive__c = true
        );
        insert existingExchangeRate;

        ExchangeRates__c newExchangeRate = new ExchangeRates__c(
            Start_Date__c = Date.today().addDays(-5),
            End_Date__c = Date.today().addDays(5),
            isActive__c = true
        );

        List<ExchangeRates__c> newExchangeRatesList = new List<ExchangeRates__c>();
        newExchangeRatesList.add(newExchangeRate);

       	

        Test.startTest();
        // Memanggil metode yang akan diuji
        ExchangeRatesServices.validationDuplicateExchangesRate(newExchangeRatesList);
        Test.stopTest();

        // Memeriksa apakah rekaman baru telah menerima pesan kesalahan yang diharapkan
        System.assertEquals('tidak bisa membuat data karena sudah ada dalam periode yang ditentukan', triggerSettingsRecValidationDataExchangesRateisExist.Error_Message__c);
    }
}