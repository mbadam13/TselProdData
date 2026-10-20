/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class RFPValidationHandler {
    public static void validationRules(List<Request_for_Proposal__c> newRFPList, List<Request_for_Proposal__c> oldRFPList){
        System.debug('== in stage is change method ==');

        Map<Id, Request_for_Proposal__c> newMap = new Map<Id, Request_for_Proposal__c>(newRFPList);
        Map<Id, Request_for_Proposal__c> oldMap = new Map<Id, Request_for_Proposal__c>(oldRFPList);

        Id currentUserProfileId = System.UserInfo.getProfileId();
        PROFILE currentProfile = [SELECT Id, Name FROM Profile WHERE Id =: currentUserProfileId];

        for (Request_for_proposal__c newRFPRec : newRFPList) {
            Request_for_proposal__c oldRFPRec = oldMap.get(newRFPRec.Id);

            String ownerRecordProfile   = newRFPRec.Owner_Profile__c;
            String currentProfileAs     = currentProfile.Name;

            if (!currentProfileAs.contains('System Administrator')) {
                // cant move stage
                if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Progress' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Ask Revision'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Progress to Ask Revision!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Progress' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'In_Revision'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Progress to In Revision!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c != 'Send Proposal' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Send Proposal'
                ) {
                    newRFPRec.addError('Only System Admin can move stage to Send Proposal!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c != 'Closed' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Closed'
                ) {
                    newRFPRec.addError('Only System Admin can move stage to Closed!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c != newRFPRec.Request_for_Proposal_Status__c && ( // status berubah dengan kondisi status oldnya (Request Queue) dan newnya (selain 'Assigned')
                        oldRFPRec.Request_for_Proposal_Status__c == 'Request' && 
                        newRFPRec.Request_for_Proposal_Status__c != 'Request Assign' &&
                        (oldRFPRec.OwnerId == newRFPRec.OwnerId || currentProfileAs.contains('Marketing')) // tidak dalam keadaan change owner
                    )
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Request Queue to other Stage excepted Assigned!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Request Assign' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Ask Revision'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Request Assign to Ask Revision!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Request Assign' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'In_Revision'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Request Assign to In Revision!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Ask Revision' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Completed'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Ask Revision to Completed!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Request Assign' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Completed'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Assigned to Completed!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Completed' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Request Assign'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Completed to Assigned!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Completed' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Progress'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Completed to Progress!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Ask Revision' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Progress'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Ask Revision to Progress!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'In_Revision' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Ask Revision'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from In_Revision to Ask Revision!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Send Proposal' && 
                    newRFPRec.Request_for_Proposal_Status__c != 'Send Proposal'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Send Proposal to other Stage!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Closed' && 
                    newRFPRec.Request_for_Proposal_Status__c != 'Closed'
                ) {
                    newRFPRec.addError('Only System Admin can move stage from Closed to other Stage!');
                }

                // cant edit record
                if (
                    newRFPRec != oldRFPRec && 
                    oldRFPRec.Request_for_Proposal_Status__c == 'Send Proposal' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Send Proposal' &&
                    oldRFPRec.OwnerId == newRFPRec.OwnerId // tidak dalam keadaan change owner
                ) {
                    newRFPRec.addError('Only System Admin can Edit at stage Send Proposal!');
                } else if (
                    newRFPRec != oldRFPRec && 
                    oldRFPRec.Request_for_Proposal_Status__c == 'Closed' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Closed' &&
                    oldRFPRec.OwnerId == newRFPRec.OwnerId // tidak dalam keadaan change owner
                ) {
                    newRFPRec.addError('Only System Admin can Edit at stage Closed!');
                }
            }  
            
            if (!currentProfileAs.contains('Sales')) {
                // cant move stage
                if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Request' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Request Assign'
                ) {
                    newRFPRec.addError('Only Sales can move stage from Request Queue to Assigned!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Completed' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Ask Revision'
                ) {
                    newRFPRec.addError('Only Sales can move stage from Completed to Ask Revision!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Ask Revision' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'In_Revision'
                ) {
                    newRFPRec.addError('Only Sales can move stage from Ask Revision to In Revision!');
                }

                // cant edit record
                if (
                    newRFPRec != oldRFPRec && 
                    oldRFPRec.Request_for_Proposal_Status__c == 'Request' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Request' &&
                    !currentProfileAs.contains('System Administrator')
                ) {
                    newRFPRec.addError('Only Sales can Edit at stage Request Queue!');
                } else if (
                    newRFPRec != oldRFPRec && 
                    oldRFPRec.Request_for_Proposal_Status__c == 'Completed' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Completed' &&
                    oldRFPRec.OwnerId == newRFPRec.OwnerId &&  // tidak dalam keadaan change owner
                    currentProfile.Name != ownerRecordProfile
                ) {
                    newRFPRec.addError('Only Sales can Edit at stage Completed!');
                } else if (
                    newRFPRec != oldRFPRec && 
                    oldRFPRec.Request_for_Proposal_Status__c == 'Ask Revision' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Ask Revision' &&
                    oldRFPRec.OwnerId == newRFPRec.OwnerId &&  // tidak dalam keadaan change owner
                    currentProfile.Name != ownerRecordProfile
                ) {
                    newRFPRec.addError('Only Sales can Edit at stage Ask Revision!');
                }
            }  
            
            if (!currentProfileAs.contains('Marketing')) {
                // cant move stage
                if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Request Assign' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Progress'
                ) {
                    newRFPRec.addError('Only Marketing can move stage from Assigned to Progress!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Progress' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Completed'
                ) {
                    newRFPRec.addError('Only Marketing can move stage from Progress to Completed!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'In_Revision' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Completed'
                ) {
                    newRFPRec.addError('Only Marketing can move stage from In Revision to Completed!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Ask Revision' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Request Assign'
                ) {
                    newRFPRec.addError('Only Marketing can move stage from In Ask Revision to Assigned!');
                } 

                // cant edit record
                if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Request Assign' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Request Assign' && 
                    oldRFPRec.OwnerId == newRFPRec.OwnerId &&  // tidak dalam keadaan change owner
                    currentProfile.Name != ownerRecordProfile
                ) { 
                    newRFPRec.addError('Only Marketing can Edit at stage Assigned!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'Progress' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'Progress' && 
                    oldRFPRec.OwnerId == newRFPRec.OwnerId &&  // tidak dalam keadaan change owner
                    currentProfile.Name != ownerRecordProfile
                ) { 
                    newRFPRec.addError('Only Marketing can Edit at stage Progress!');
                } else if (
                    oldRFPRec.Request_for_Proposal_Status__c == 'In_Revision' && 
                    newRFPRec.Request_for_Proposal_Status__c == 'In_Revision' && 
                    oldRFPRec.OwnerId == newRFPRec.OwnerId &&  // tidak dalam keadaan change owner
                    currentProfile.Name != ownerRecordProfile
                ) { 
                    newRFPRec.addError('Only Marketing can Edit at stage In Revision!');
                }
            }
        }
    }
}