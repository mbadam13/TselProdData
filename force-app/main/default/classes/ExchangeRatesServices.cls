/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class ExchangeRatesServices {
    public static Trigger_Setting__c triggerSettingsRecValidationDataExchangesRateisExist = Trigger_Setting__c.getInstance('Validation:_ExcRateisExist');

    public static void validationDuplicateExchangesRate(list<ExchangeRates__c> newExchangeRatesList) {
        if(triggerSettingsRecValidationDataExchangesRateisExist.isActive__c == true){
            List<ExchangeRates__c> existingExchangeRateList = [
                SELECT 
                Id, 
                OwnerId, 
                Name, 
                CreatedById, 
                LastModifiedById, 
                Start_Date__c, 
                End_Date__c, 
                CurrencyType__c, 
                ConversionRate__c,
                isActive__c  
                
                FROM ExchangeRates__c

                WHERE isActive__c = true
            ];

            for(ExchangeRates__c newExchangeRatesListRec :newExchangeRatesList){
                Date startDate = newExchangeRatesListRec.start_date__c;
                Date endDate = newExchangeRatesListRec.end_date__c;

                for(ExchangeRates__c existingExchangeRateListRec :existingExchangeRateList){
                    if(
                        (
                            (
                                startDate >= existingExchangeRateListRec.Start_Date__c &&
                                startDate <= existingExchangeRateListRec.End_Date__c 
                            )  
                            ||
                            (   
                                endDate >= existingExchangeRateListRec.Start_Date__c &&
                                endDate <= existingExchangeRateListRec.End_Date__c

                            )
                        )
                            &&
                            newExchangeRatesListRec.isActive__c == existingExchangeRateListRec.isActive__c   
                        ){
                            newExchangeRatesListRec.addError(triggerSettingsRecValidationDataExchangesRateisExist.Error_Message__c);
                    } 
                }
            }
        }
    }

}