trigger Trigger_Update_Account on Account (before update) {

if (label.Trigger_Update_Account_On == 'YES') {
    
    for(Account accRec : trigger.new){
        
        Account accRecOld = trigger.oldMap.get(accRec.Id);
        
        if(accRec.Account_Type__c == 'Publisher' && accRec.Publisher_Status__c != accRecOld.Publisher_Status__c){
            
            if(accRec.Publisher_Status__c == 'Contract Signed'){
                
                List<User> checkUser = [SELECT Id, Name, Username FROM User WHERE Username =: accRec.Chatter_Email__c];
                system.debug('*** checkUser = ' + checkUser.size() + ' | ' + checkUser);
                
                Id userChatterId = null;
                User uchatter = new User();
                
                if(checkUser.size() > 0){
                    userChatterId = checkUser[0].Id;
                } else{
                    uchatter.Lastname = accRec.Name;
                    uchatter.Alias = accRec.Chatter_Name__c.left(5);
                    uchatter.Email = accRec.Chatter_Email__c;
                    uchatter.Username = accRec.Chatter_Email__c;
                    uchatter.CommunityNickname = accRec.Chatter_Name__c;
                    uchatter.ProfileId = label.Chatter_Free_ProfileId;
                    uchatter.EmailEncodingKey = 'ISO-8859-1';
                    uchatter.TimeZoneSidKey = 'Asia/Jakarta';
                    uchatter.LocaleSidKey = 'in_ID';
                    uchatter.LanguageLocaleKey = 'en_US';
                    insert uchatter;
                    system.debug('*** uchatter = ' + uchatter);
                    
                    userChatterId = uchatter.Id;
                    
                }
                
                // Create Chatter Group
		        String chatterGroupName = accRec.Name + '- Group';                
                CollaborationGroup chatterGroup = new CollaborationGroup();
                chatterGroup.Name = chatterGroupName.Left(40) ;
                //chatterGroup.Name = accRec.Name + ' - Group';
                chatterGroup.CollaborationType = 'Private';
                chatterGroup.IsAutoArchiveDisabled = TRUE;
				chatterGroup.IsArchived = FALSE;
                insert chatterGroup;
                system.debug('*** chatterGroup = ' + chatterGroup);
                
                // Create Chatter Group Member for Publisher
                CollaborationGroupMember chatterGroupMember = new CollaborationGroupMember();
                chatterGroupMember.memberid = userChatterId;
                chatterGroupMember.CollaborationGroupId = chatterGroup.Id;
                chatterGroupMember.NotificationFrequency = 'P';
                insert chatterGroupMember;
                system.debug('*** chatterGroupMember = ' + chatterGroupMember);
                
                // Create Chatter Group Member for Tsel users
                List<Id> userIdTsel_list = new List<Id>();
                for(TadexMemberSetting__c member : TadexMemberSetting__c.getAll().values()){
                userIdTsel_list.add(member.ID_User__c);                
                }
                system.debug('*** userIdTsel_list = ' + userIdTsel_list.size() + ' | ' + userIdTsel_list);
                
                Id runningUserId = UserInfo.getUserId();
                system.debug('*** runningUserId = ' + runningUserId);
                
                List<CollaborationGroupMember> cgmList = new List<CollaborationGroupMember>();
                for(Id userId : userIdTsel_list){
                    if(userId != runningUserId){
                    
                    CollaborationGroupMember chatterGroupMember_tsel = new CollaborationGroupMember();
                    chatterGroupMember_tsel.memberid = userId;
                    chatterGroupMember_tsel.CollaborationGroupId = chatterGroup.Id;
                    chatterGroupMember_tsel.NotificationFrequency = 'P';
                    cgmList.add(chatterGroupMember_tsel);
                    system.debug('*** chatterGroupMember_tsel = ' + chatterGroupMember_tsel);
                    
                    }
                }
                insert cgmList;
                
                if(runningUserId != system.label.Tadex_Admin_ChatterUserId){
                    CollaborationGroupMember chatterGroupMember_admin = new CollaborationGroupMember();
                    chatterGroupMember_admin.memberid = system.label.Tadex_Admin_ChatterUserId;
                    chatterGroupMember_admin.CollaborationGroupId = chatterGroup.Id;
                    chatterGroupMember_admin.NotificationFrequency = 'P';
                    insert chatterGroupMember_admin;
                    system.debug('*** chatterGroupMember_admin = ' + chatterGroupMember_admin);
                }
                
                // Update Account with Chatter Information
                accRec.Chatter_Group_Id__c = chatterGroup.Id;
                system.debug('*** accRec.Chatter_Group_Id__c = ' + accRec.Chatter_Group_Id__c);
                
                // Reset Password userChatter 
                if(uchatter.Id != null)
                	{system.resetPassword(uchatter.Id, true);}
                
                
            }
            
            if(accRec.Publisher_Status__c == 'Ad Tag Shared'){
            
                List<Contract> contractList = [SELECT Id, Name FROM Contract WHERE AccountId =: accRec.Id AND Status = 'Activated'];
                system.debug('*** contractList = ' + contractList.size() + ' | ' + contractList);
                
                if(contractList.size() == 0){
                    if(accRec.Contract_Bypass_Approval__c != 'Approved'){
                        accRec.addError('The Publisher has not been approved yet to proceed further. Please check contract or approval accordingly...');
                    }
                }
                
            }
            
        }
    }
    
}
    
}