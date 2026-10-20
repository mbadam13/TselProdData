global with sharing class Schedule_Revise_TSID implements Schedulable {
    
    // Daily Scheduler
    global void execute(SchedulableContext sc){
        
        String emailErrorRecipient = Label.Adm_EmailError_Recipient;
        emailErrorRecipient = emailErrorRecipient.trim();
        String [] email = emailErrorRecipient.split(','); system.debug('*** email = ' + email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        try
        {
            List<Traffics_SID__c> tsidListToBeUpdated = new List<Traffics_SID__c>();
            Map<String,Traffics_SID__c> map_id_tsidRec = new Map<String,Traffics_SID__c>();
            List<Change_Log_Traffic__c> clt_list = new List<Change_Log_Traffic__c>();
            
            String creator_userId = Label.Integration_UserId;
            if(Test.isRunningTest()){creator_userId = UserInfo.getUserId();}
            system.debug('*** creator_userId = ' + creator_userId);
            
            Date td = system.today();
            if(label.ManualRun_Schedule_Revise_TSID == 'YES'){td = date.parse(Label.SchDateForTesting);} // For Run Manual
            system.debug('*** td = ' + td);
            
            Date cutoff_date = Date.newInstance(td.year(), td.month(), Integer.valueOf(Label.clt_cutoff_date));
            Date cutoff_tsid_date = Date.newInstance(td.year(), td.month(), 1);
            
            if(td >= cutoff_date){
                
            	clt_list = [SELECT Id, Name, New_Value__c, Old_Value__c, Record_ID__c, Revise_Traffic__c, Traffic_New__c, CreatedDate, CLT_CreatedDate__c  
                            FROM Change_Log_Traffic__c 
                            WHERE Traffic_Type__c = 'Traffic SID' 
                            AND Change_Type__c = 'Change' 
                            AND CLT_CreatedDate__c =: td 
                            AND CreatedBy.Id =: creator_userId
                            AND Event_Date_Traffic__c <: cutoff_tsid_date
                            AND Revise_Traffic__c = false 
                            ORDER BY CreatedDate DESC
                           ];
                system.debug('*** clt_list atas cut off = ' + clt_list.size() + ' | ' + clt_list);
                
            }
            else if(td >= cutoff_tsid_date && td <  cutoff_date){
                
                system.debug('*** cutoff_tsid_date.addMonths(-1) = ' + cutoff_tsid_date.addMonths(-1));
                
                clt_list = [SELECT Id, Name, New_Value__c, Old_Value__c, Record_ID__c, Revise_Traffic__c, Traffic_New__c, CreatedDate, CLT_CreatedDate__c 
                            FROM Change_Log_Traffic__c 
                            WHERE Traffic_Type__c = 'Traffic SID' 
                            AND Change_Type__c = 'Change' 
                            AND CLT_CreatedDate__c =: td 
                            AND CreatedBy.Id =: creator_userId 
                            AND Event_Date_Traffic__c <: cutoff_tsid_date.addMonths(-1)
                            AND Revise_Traffic__c = false 
                            ORDER BY CreatedDate DESC
                           ];
                system.debug('*** clt_list bwh cut off= ' + clt_list.size() + ' | ' + clt_list);
                
            }
            
            for(Change_Log_Traffic__c clt_rec : clt_list){
            	Traffics_SID__c tsid = new Traffics_SID__c();
                tsid.Id = clt_rec.Record_ID__c;
                if(label.Reset_Traffic == 'YES'){tsid.Traffic__c = clt_rec.Old_Value__c;}
                if(clt_rec.Traffic_New__c == 0){
                	tsid.Traffic_New__c = clt_rec.Old_Value__c + clt_rec.New_Value__c;
                }else{
                	tsid.Traffic_New__c = clt_rec.Traffic_New__c + clt_rec.New_Value__c;
                }
                tsidListToBeUpdated.add(tsid);
                    
                clt_rec.Revise_Traffic__c = true;
          	}
            system.debug('*** tsidListToBeUpdated = ' + tsidListToBeUpdated.size() + ' | ' + tsidListToBeUpdated);
            
            if(Label.Execute_Revise_TSID == 'YES'){
                if(tsidListToBeUpdated.size() > 0){update tsidListToBeUpdated;}
				if(clt_list.size() > 0){update clt_list;}
            }
            
        }
        catch(exception e)
        {
            // Below code will send an email to User about the status
            mail.setToAddresses(email);
            mail.setReplyTo(Label.Adm_EmailError_ReplyTo);
            mail.setSenderDisplayName('Apex Catch Processing Module');
            mail.setSubject('Catch Processing');
            String body = 'Error on Schedule_Revise_TSID function <br/><br/> Error Message :: ' + e.getmessage() + '<br/> Line :: ' + e.getLineNumber();
            mail.setHtmlBody(body);
            system.debug('*** Error on Schedule_Revise_TSID function == Line ' + e.getLineNumber() + ' | Message : ' + e.getmessage());
            Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
        }
    }
}