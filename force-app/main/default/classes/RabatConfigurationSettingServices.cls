/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-19-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class RabatConfigurationSettingServices {
    public static Trigger_Setting__c triggerSettingsRecValidationDataRabatisExist = Trigger_Setting__c.getInstance('Validation:DataRabatisExist');
    public static Trigger_Setting__c triggerSettingsCantdeleteWhenRRCUsed = Trigger_Setting__c.getInstance('Validation:_CantdeleteWhenRRCUsed');

    public static void validationCannotInsertRecordWhenStartDateIsExist(List<Rabat_Configuration_Setting__c> newrabatConfigurationsettingList){
        if(triggerSettingsRecValidationDataRabatisExist.isActive__c == true){
            List<Rabat_Configuration_Setting__c> existingRabatConfigurationSettingList = [
                SELECT Id, 
                OwnerId, 
                Name, 
                CreatedById, 
                isActive__c,
                LastModifiedById, 
                Account__c, 
                Group_Incentive__c, 
                Spending_Amount_Greater_Than__c, 
                Spending_Amount_LessThan__c, 
                Start_Date__c, 
                End_Date__c 
                
                FROM Rabat_Configuration_Setting__c

                WHERE isActive__c = true
            ];

            for(Rabat_Configuration_Setting__c newrabatConfigurationsettingListRec :newrabatConfigurationsettingList){
                Date startDate = newrabatConfigurationsettingListRec.start_date__c;
                Date endDate = newrabatConfigurationsettingListRec.end_date__c;

                for(Rabat_Configuration_Setting__c existingrabatConfigurationsettingListRec :existingRabatConfigurationSettingList){
                    if(
                        (
                            (
                                newrabatConfigurationsettingListRec.Spending_Amount_Greater_Than__c > existingrabatConfigurationsettingListRec.Spending_Amount_Greater_Than__c &&
                                newrabatConfigurationsettingListRec.Spending_Amount_Greater_Than__c < existingrabatConfigurationsettingListRec.Spending_Amount_LessThan__c 
                            )  
                            ||
                            (   
                                newrabatConfigurationsettingListRec.Spending_Amount_LessThan__c > existingrabatConfigurationsettingListRec.Spending_Amount_Greater_Than__c &&
                                newrabatConfigurationsettingListRec.Spending_Amount_LessThan__c < existingrabatConfigurationsettingListRec.Spending_Amount_LessThan__c

                            )
                        )
                            &&
                            newrabatConfigurationsettingListRec.isActive__c == existingrabatConfigurationsettingListRec.isActive__c   &&
                            newrabatConfigurationsettingListRec.Account__c == existingrabatConfigurationsettingListRec.Account__c    
                        ){
                            newrabatConfigurationsettingListRec.addError(triggerSettingsRecValidationDataRabatisExist.Error_Message__c);
                    } 
                }
            }
        }
    }

    public static void validationCannotDeleteDatawhenisAlreadyUsed(List<Rabat_Configuration_Setting__c> oldRabatConfigurationsettingList){

        list<id> idList = new list<id>();
    
        if(triggerSettingsCantdeleteWhenRRCUsed.IsActive__c == true){
            for(Rabat_Configuration_Setting__c oldRabatConfigurationSettingListRec :oldRabatConfigurationsettingList){
                idList.add(oldRabatConfigurationSettingListRec.id);
            }

            integer rabatRevenueItemList = [
                SELECT count() 
                FROM Rabat_Revenue_Item__c 
                WHERE Rabat_Configuration_Setting__c IN:idList 
            ];

            System.debug('rabatRevenueItemList: ' + rabatRevenueItemList);
        
            if(rabatRevenueItemList != 0){
                for(Rabat_Configuration_Setting__c oldRabatConfigurationSettingListRec: oldRabatConfigurationSettingList){
                    oldRabatConfigurationSettingListRec.addError(triggerSettingsCantdeleteWhenRRCUsed.Error_Message__c);
                }
            }
        }
    
    }
}