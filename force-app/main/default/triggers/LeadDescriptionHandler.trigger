/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 05-17-2024
 * @last modified by  : Syaiful Syafani
**/
trigger LeadDescriptionHandler on Lead (before insert, before update) {
    
    if(label.LeadDescriptionHandler == 'Yes'){
        if (Trigger.isBefore) {
            if (Trigger.isUpdate) {
                for(Lead leadList : Trigger.New){
                    if(leadList.Description != null){
                        if(leadList.Description.length()>= 255 ){
                           leadList.Text_Description__c = leadList.Description.left(230)+ 'read more ...';
                        }else{
                            leadList.Text_Description__c = leadList.Description; 
                        }
                    }                     
                }
            }
        }
    }    
}