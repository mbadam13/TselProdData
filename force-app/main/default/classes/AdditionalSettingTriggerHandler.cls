/**
 * @description       : 
 * @Test Class        : AdditionalSettingTriggerHandlerTest
 * @author            : 
 * @group             : 
 * @last modified on  : 18-01-2024
 * @last modified by  : Andhito Diaz Revandra
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-19-2023   Novando Utoyo Agmawan   Initial Version
**/

public with sharing class AdditionalSettingTriggerHandler {
    public AdditionalSettingTriggerHandler() {

    }

    public static Trigger_Setting__c triggerSettingsRecValidationStartDateIsExist = Trigger_Setting__c.getInstance('validation:_StartDateIsExist');

    public static Trigger_Setting__c triggerSettingsRecValidationCantdeleteWhenRecordUsed = Trigger_Setting__c.getInstance('Validation:_CantdeleteWhenRecordUsed');

    public static void validationCannotInsertRecordWhenStartDateIsExist(List<Additional_Setting__c> newAdditionalSettingList){
        date startDate;
        date endDate;
        string type = '';
        string objectName = '';
        Boolean isActive;

        //get additionalSettingListRec
        /*if(triggerSettingsRecValidationStartDateIsExist.IsActive__c == true){
            List<Additional_Setting__c> currentAdditionalSettingList = [
                select id, 
                start_date__c, 
                end_date__c, 
                Type__c, 
                object_name__c 
                from Additional_Setting__c 
                where  object_name__c = 'Traffic__c' and Active__c = true
            ];

            if(currentAdditionalSettingList.size() > 0 ){
                for(Additional_Setting__c newAdditionalSettingListRec: newAdditionalSettingList){
                    startDate = newAdditionalSettingListRec.start_date__c;
                    endDate = newAdditionalSettingListRec.end_date__c;
                    type = newAdditionalSettingListRec.type__c;
                    objectName = newAdditionalSettingListRec.object_name__c;
        
                    for(Additional_Setting__c currentAdditionalSettingListRec :currentAdditionalSettingList){
                        System.debug('condition: ' + startDate + ' >= ' + currentAdditionalSettingListRec.start_date__c + ' && ' +  startDate + ' <= ' + endDate  + ' && ' + currentAdditionalSettingListRec.type__c + ' == ' + type + ' && ' + currentAdditionalSettingListRec.object_name__c + ' == ' + objectName );
                        if(
                            startDate >= currentAdditionalSettingListRec.start_date__c && 
                            startDate <= currentAdditionalSettingListRec.end_date__c && 
                            currentAdditionalSettingListRec.type__c == type  &&  
                            currentAdditionalSettingListRec.object_name__c == objectName 
                        ){
                            newAdditionalSettingListRec.addError(triggerSettingsRecValidationStartDateIsExist.Error_Message__c);
                        }
                    }
                }
            }
        }*/

        if(triggerSettingsRecValidationStartDateIsExist.IsActive__c == true){
            List<Additional_Setting__c> currentAdditionalSettingList = [
                select Id,
                Active__c,
                Applies_to_Category__c,
                Brand__c,
                End_Date__c,
                Greater_Than_Equal__c,
                Group_Incentive__c,
                Account__c,
                Less_Than__c,
                Name,
                Object_Name__c,
                OwnerId,
                Product__c,
                Product_Services_and_Code__c,
                RecordTypeId,
                recordType.Name,
                Start_Date__c,
                Tiering_Type__c,
                Type__c,
                Unique_Key__c,
                Value__c,
                channel__c,
                Value_Type__c
                from Additional_Setting__c 
                where Active__c = true
            ];

            if(currentAdditionalSettingList != null && !currentAdditionalSettingList.isEmpty()){
                for(Additional_Setting__c newAdditionalSettingListRec: newAdditionalSettingList){
                    startDate = newAdditionalSettingListRec.start_date__c;
                    endDate = newAdditionalSettingListRec.end_date__c;
                    
                    for(Additional_Setting__c currentAdditionalSettingListRec :currentAdditionalSettingList){
                        System.debug('startDate: ' + startDate + ' >= ' + currentAdditionalSettingListRec.start_date__c + ' &&' );
                        System.debug('startDate: ' + startDate + ' <= ' + currentAdditionalSettingListRec.end_date__c + ' &&' );
                        System.debug('endDate: ' + endDate + ' >= ' + currentAdditionalSettingListRec.end_date__c + ' &&' );
                        System.debug('Active__c: ' + newAdditionalSettingListRec.Active__c + ' = ' + currentAdditionalSettingListRec.Active__c + ' &&' );
                        System.debug('Applies_to_Category__c: ' + newAdditionalSettingListRec.Applies_to_Category__c + ' = ' + currentAdditionalSettingListRec.Applies_to_Category__c + ' &&' );
                        System.debug('Brand__c: ' + newAdditionalSettingListRec.Brand__c + ' = ' + currentAdditionalSettingListRec.Brand__c + ' &&' );
                        System.debug('Greater_Than_Equal__c: ' + newAdditionalSettingListRec.Greater_Than_Equal__c + ' = ' + currentAdditionalSettingListRec.Greater_Than_Equal__c + ' &&' );
                        System.debug('Group_Incentive__c: ' + newAdditionalSettingListRec.Group_Incentive__c + ' >= ' + currentAdditionalSettingListRec.Group_Incentive__c + ' &&' );
                        System.debug('Account__c: ' + newAdditionalSettingListRec.Account__c + ' = ' + currentAdditionalSettingListRec.Account__c + ' &&' );
                        System.debug('Less_Than__c: ' + newAdditionalSettingListRec.Less_Than__c + ' = ' + currentAdditionalSettingListRec.Less_Than__c + ' &&' );
                        System.debug('Object_Name__c: ' + newAdditionalSettingListRec.Object_Name__c + ' = ' + currentAdditionalSettingListRec.Object_Name__c + ' &&' );
                        System.debug('Product__c: ' + newAdditionalSettingListRec.Product__c + ' = ' + currentAdditionalSettingListRec.Object_Name__c + ' &&' );
                        System.debug('Product_Services_and_Code__c: ' + newAdditionalSettingListRec.Product_Services_and_Code__c + ' = ' + currentAdditionalSettingListRec.Product_Services_and_Code__c + ' &&' );
                        System.debug('RecordTypeId: ' + newAdditionalSettingListRec.RecordTypeId + ' = ' + currentAdditionalSettingListRec.RecordTypeId + ' &&' );
                        System.debug('Tiering_Type__c: ' + newAdditionalSettingListRec.Tiering_Type__c + ' = ' + currentAdditionalSettingListRec.Tiering_Type__c + ' &&' );
                        System.debug('Type__c: ' + newAdditionalSettingListRec.Tiering_Type__c + ' = ' + currentAdditionalSettingListRec.Type__c + ' &&' );
                        System.debug('Value__c: ' + newAdditionalSettingListRec.Value__c + ' = ' + currentAdditionalSettingListRec.Value__c + ' &&' );
                        System.debug('Value_Type__c: ' + newAdditionalSettingListRec.Value_Type__c + ' = ' + currentAdditionalSettingListRec.Value_Type__c + ' &&' );

                        if(currentAdditionalSettingListRec.recordType.Name == 'VAT'){
                            if(
                            (
                                (
                                    startDate >= currentAdditionalSettingListRec.start_date__c && 
                                    startDate <= currentAdditionalSettingListRec.end_date__c
                                ) 
                                    ||
                                (
                                    endDate >= currentAdditionalSettingListRec.start_date__c && 
                                    endDate <= currentAdditionalSettingListRec.end_date__c 

                                )
                            )
                                &&
                                newAdditionalSettingListRec.Active__c == currentAdditionalSettingListRec.Active__c   &&
                                newAdditionalSettingListRec.Object_Name__c == currentAdditionalSettingListRec.Object_Name__c   && 
                                newAdditionalSettingListRec.RecordTypeId == currentAdditionalSettingListRec.RecordTypeId   && 
                                newAdditionalSettingListRec.Type__c == currentAdditionalSettingListRec.Type__c   && 
                                newAdditionalSettingListRec.Value_Type__c == currentAdditionalSettingListRec.Value_Type__c 
                            ){
                                newAdditionalSettingListRec.addError(triggerSettingsRecValidationStartDateIsExist.Error_Message__c);
                            }  
                        }
                        else if(currentAdditionalSettingListRec.recordType.Name == 'Discount'){
                            if(
                            (
                                (
                                    startDate >= currentAdditionalSettingListRec.start_date__c && 
                                    startDate <= currentAdditionalSettingListRec.end_date__c
                                ) 
                                    ||
                                (
                                    endDate >= currentAdditionalSettingListRec.start_date__c && 
                                    endDate <= currentAdditionalSettingListRec.end_date__c 

                                )
                            )
                                &&
                                newAdditionalSettingListRec.Active__c == currentAdditionalSettingListRec.Active__c   &&
                                newAdditionalSettingListRec.Object_Name__c == currentAdditionalSettingListRec.Object_Name__c   && 
                                newAdditionalSettingListRec.RecordTypeId == currentAdditionalSettingListRec.RecordTypeId   && 
                                newAdditionalSettingListRec.Type__c == currentAdditionalSettingListRec.Type__c   && 
                                newAdditionalSettingListRec.Value_Type__c == currentAdditionalSettingListRec.Value_Type__c 
                            ){
                                newAdditionalSettingListRec.addError(triggerSettingsRecValidationStartDateIsExist.Error_Message__c);
                            }  
                        }else {
                            if(
                            (
                                (
                                    startDate >= currentAdditionalSettingListRec.start_date__c && 
                                    startDate <= currentAdditionalSettingListRec.end_date__c
                                ) 
                                    ||
                                (
                                    endDate >= currentAdditionalSettingListRec.start_date__c && 
                                    endDate <= currentAdditionalSettingListRec.end_date__c 

                                )
                            )
                                &&
                                newAdditionalSettingListRec.Active__c == currentAdditionalSettingListRec.Active__c   &&
                                newAdditionalSettingListRec.Applies_to_Category__c == currentAdditionalSettingListRec.Applies_to_Category__c   && 
                                newAdditionalSettingListRec.Brand__c == currentAdditionalSettingListRec.Brand__c   && 
                                newAdditionalSettingListRec.Greater_Than_Equal__c == currentAdditionalSettingListRec.Greater_Than_Equal__c   && 
                                newAdditionalSettingListRec.Group_Incentive__c == currentAdditionalSettingListRec.Group_Incentive__c   && 
                                newAdditionalSettingListRec.Account__c == currentAdditionalSettingListRec.Account__c   &&  
                                newAdditionalSettingListRec.Less_Than__c == currentAdditionalSettingListRec.Less_Than__c   && 
                                newAdditionalSettingListRec.Object_Name__c == currentAdditionalSettingListRec.Object_Name__c   && 
                                newAdditionalSettingListRec.Product__c == currentAdditionalSettingListRec.Product__c   && 
                                newAdditionalSettingListRec.Product_Services_and_Code__c == currentAdditionalSettingListRec.Product_Services_and_Code__c   && 
                                newAdditionalSettingListRec.RecordTypeId == currentAdditionalSettingListRec.RecordTypeId   && 
                                newAdditionalSettingListRec.Tiering_Type__c == currentAdditionalSettingListRec.Tiering_Type__c   && 
                                newAdditionalSettingListRec.Type__c == currentAdditionalSettingListRec.Type__c   && 
                                newAdditionalSettingListRec.Value__c == currentAdditionalSettingListRec.Value__c   && 
                                newAdditionalSettingListRec.channel__c == currentAdditionalSettingListRec.channel__c   &&
                                newAdditionalSettingListRec.Value_Type__c == currentAdditionalSettingListRec.Value_Type__c 
                            ){
                                newAdditionalSettingListRec.addError(triggerSettingsRecValidationStartDateIsExist.Error_Message__c);
                            }    
                        }
                        

                    }
                }
            }
        }
    }

    public static void validationCannotdeleteWhenRecordUsedInPubmaticBillingRecord(List<Additional_Setting__c> oldAdditionalSettingList){
        //getPubmaticBillingRecordSize
        list<id> idList = new list<id>();

        if(triggerSettingsRecValidationCantdeleteWhenRecordUsed.IsActive__c == true){
            for(Additional_Setting__c oldAdditionalSettingListRec :oldAdditionalSettingList){
                idList.add(oldAdditionalSettingListRec.id);
            }

            integer pubmaticBillingListSize = [
                select count() 
                from pubmatic_billing__c 
                where Additional_Setting__r.id in:idList 
            ];

            System.debug('pubmaticBillingListSize: ' + pubmaticBillingListSize);

            if(pubmaticBillingListSize != 0){
                for(Additional_Setting__c oldAdditionalSettingListRec: oldAdditionalSettingList){
                    oldAdditionalSettingListRec.addError(triggerSettingsRecValidationCantdeleteWhenRecordUsed.Error_Message__c);
                }
            }
        }
    }

    public static void validationCannotdeleteWhenRecordUsedInTrafficRecord(List<Additional_Setting__c> oldAdditionalSettingList){
        //getPubmaticBillingRecordSize
        list<id> idList = new list<id>();
        
        if(triggerSettingsRecValidationCantdeleteWhenRecordUsed.IsActive__c == true){
            for(Additional_Setting__c oldAdditionalSettingListRec :oldAdditionalSettingList){
                idList.add(oldAdditionalSettingListRec.id);
            }

            integer pubmaticBillingListSize = [
                select count() 
                from traffic__c 
                where Additional_Setting__r.id in:idList 
            ];

            System.debug('pubmaticBillingListSize: ' + pubmaticBillingListSize);

            if(pubmaticBillingListSize != 0){
                for(Additional_Setting__c oldAdditionalSettingListRec: oldAdditionalSettingList){
                    oldAdditionalSettingListRec.addError(triggerSettingsRecValidationCantdeleteWhenRecordUsed.Error_Message__c);
                }
            }
        }
    }

    public static void validationCannotdeleteWhenRecordUsedInMonthlyDiscountInventoryRecord(List<Additional_Setting__c> oldAdditionalSettingList){
        //getPubmaticBillingRecordSize
        list<id> idList = new list<id>();
        
        if(triggerSettingsRecValidationCantdeleteWhenRecordUsed.IsActive__c == true){
            for(Additional_Setting__c oldAdditionalSettingListRec :oldAdditionalSettingList){
                idList.add(oldAdditionalSettingListRec.id);
            }

            integer MonthlyDiscountInventoryMediaSellerListSize = [
                select count() 
                from Monthly_Discount_Inventory_Media_Seller__c 
                where Additional_Setting__r.id in:idList 
            ];

            System.debug('MonthlyDiscountInventoryMediaSellerListSize: ' + MonthlyDiscountInventoryMediaSellerListSize);
            
            if(MonthlyDiscountInventoryMediaSellerListSize != 0){
                for(Additional_Setting__c oldAdditionalSettingListRec: oldAdditionalSettingList){
                    oldAdditionalSettingListRec.addError(triggerSettingsRecValidationCantdeleteWhenRecordUsed.Error_Message__c);
                }
            }
        }
    }
    
    public void OnBeforeInsert(List<Additional_Setting__c> newAdditionalSettingList){
        validationCannotInsertRecordWhenStartDateIsExist(newAdditionalSettingList);
    }

    public void OnBeforeUpdate(List<Additional_Setting__c> newAdditionalSettingList){
        validationCannotInsertRecordWhenStartDateIsExist(newAdditionalSettingList);
    }

    public void OnBeforeDelete(List<Additional_Setting__c> oldAdditionalSettingList, Map<Id, Additional_Setting__c> oldAdditionalSettingMap) {
        validationCannotdeleteWhenRecordUsedInPubmaticBillingRecord(oldAdditionalSettingList);

        validationCannotdeleteWhenRecordUsedInTrafficRecord(oldAdditionalSettingList);

        validationCannotdeleteWhenRecordUsedInMonthlyDiscountInventoryRecord(oldAdditionalSettingList);
    }
}