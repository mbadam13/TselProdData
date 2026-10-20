trigger Trigger_CampaignMyads_Before_Update on Campaign_MyAds__c (Before update) {

if (label.Trigger_CampaignMyads_Before_Update== 'YES') {
    if(trigger.isBefore)
     {
		if(trigger.isUpdate)
        {
        String recordid;
        String ownerid;
        Date enddate;
        Double Usertopup;
        Double Userretopup;
        Double UserReg;
        List<Monthly_Sales_Target__c> MSTlist = new List<Monthly_Sales_Target__c> ();
            for(Campaign_MyAds__c newCamp:trigger.new) {
            recordid=newCamp.id;
            ownerid=newCamp.ownerid;
            enddate=newCamp.End_Date__c;
            integer countcamps;
                if(newCamp.Stage__c=='Closed Won')
                {
                 List<ContentVersion> attachments = AppUtils.getPrivyFilesOnBase64(newCamp.id);
                    if (attachments.size()==0)
                    {
                         newCamp.addError('Closed Won Need Upload File');
                    }
                }
            
                Date startdt = newCamp.Start_Date__c;
                Date enddt = newCamp.End_Date__c;
                Campaign_MyAds__c oldCamp = trigger.oldMap.get(newCamp.Id);
                if(newCamp.Stage__c == 'Completed' && oldCamp.Stage__c <> 'Completed')
                {
                 try {
                   List<Account> ListAcc = [SELECT id FROM Account WHERE Tanggal_Daftar__c >= :startdt and Tanggal_Daftar__c <=:enddt];
                   newCamp.Actual_User_Register__c=ListAcc.size();
                    double topup;
                    double retopup;
                    double sot;
                    double som;
                    double Amount_id_top = 0;
                    double Amount_id_re = 0;
                    double Amount_id_top_Voucher = 0;
                    double Amount_id_re_Voucher = 0;
                    //set<string> setTopup = new Set <String>();
                    //set<string> setRetopup = new Set <String>();
                      if(newCamp.Voucher__c =='Tanpa Kode Voucher')
                      {
                        Integer dstart  = newCamp.Start_Date__c.day();
                        Integer mostart = newCamp.Start_Date__c.month();
                        Integer yrstart = newCamp.Start_Date__c.year();
                        
                        Integer dend  = newCamp.End_Date__c.day();
                        Integer moend = newCamp.End_Date__c.month();
                        Integer yrend = newCamp.End_Date__c.year();
                        
                        //DateTime tmpStart = DateTime.newInstance(yrstart, mostart, dstart,Time.newInstance);
                        TimeZone tz = UserInfo.getTimeZone();
                        //Milliseconds to Day
                        /*Double offset= tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
                        DateTime tmpStart = DateTime.newInstance(yrstart, mostart, dstart);
                        tmpStart =tmpStart +offset;
                        DateTime tmpEnd = DateTime.newInstance(yrend, moend, dend).adddays(1);
                        tmpEnd = tmpEnd+offset;
                        system.debug('ini tmpStart'+tmpStart);
                        system.debug('ini tmpEnd'+tmpEnd);*/
                          AggregateResult[] ListTopInvoiceretopAM = [SELECT SUM(amount__c)sot,User_Id__c FROM Top_Up_Invoice__c WHERE Top_Up_Voucher__c = NULL and Paid_Date_Date__c>=:startdt AND Paid_Date_Date__c <=:enddt and Status_Topup__c='Re-Top Up' group by User_Id__c];
                          AggregateResult[] ListTopInvoicetopAM   = [SELECT SUM(amount__c)sor,User_Id__c FROM Top_Up_Invoice__c WHERE Top_Up_Voucher__c = NULL and Paid_Date_Date__c>=:startdt AND Paid_Date_Date__c <=:enddt and Status_Topup__c='First Top Up' group by User_Id__c];
                          
                          for (AggregateResult art : ListTopInvoiceretopAM)  
                          {
                              Amount_id_top = Amount_id_top + (double) art.get('sot');
                          }
                          for (AggregateResult arr : ListTopInvoicetopAM)  
                          {
                              Amount_id_re = Amount_id_re + (double) arr.get('sor');                            
                          }
                          
                          AggregateResult[] ListTopInvoiceretop = [SELECT count(Id)sob,User_Id__c FROM Top_Up_Invoice__c WHERE Top_Up_Voucher__c = NULL and Paid_Date_Date__c>=:startdt AND Paid_Date_Date__c <=:enddt and Status_Topup__c='Re-Top Up' group by User_Id__c];
                          AggregateResult[] ListTopInvoicetop   = [SELECT count(Id)sob,User_Id__c FROM Top_Up_Invoice__c WHERE Top_Up_Voucher__c = NULL and Paid_Date_Date__c>=:startdt AND Paid_Date_Date__c <=:enddt and Status_Topup__c='First Top Up' group by User_Id__c];
                          
                          newCamp.User_Top_Up__c=ListTopInvoicetop.size();
                          newCamp.User_Retopup__c=ListTopInvoiceretop.size();
                           if(Amount_id_top == null)
                              {
                                Amount_id_top = 0;
                              }
                           if(Amount_id_re == null)
                              {
                                Amount_id_re = 0;
                              }
                          newCamp.Actual_User_Topup_Invoice__c= Amount_id_top+Amount_id_re;
                          //newCamp.Actual_User_Topup_Invoice__c = 
                          
                          //AggregateResult[] ListTopInvoiceretop = [SELECT id FROM Top_Up_Invoice__c WHERE Paid_Date__c=THIS_YEAR and User_Id__c=:newCamp.User_id__c and Status_Top_Up__c='Re-Top Up']; 
                        /*List<Top_Up_Invoice__c> ListTopInvoicetop = [SELECT User_id__c FROM Top_Up_Invoice__c WHERE Status_Top_Up__c='First Top Up' and Paid_Date__c>=:tmpStart AND Paid_Date__c <=:tmpEnd];
                          set<Top_Up_Invoice__c> settopup = new Set <Top_Up_Invoice__c>(ListTopInvoicetop);
                          
                          List<Top_Up_Invoice__c> ListTopInvoiceretop = [SELECT User_id__c FROM Top_Up_Invoice__c WHERE Status_Top_Up__c='Re-Top Up' and Paid_Date__c>=:tmpStart AND Paid_Date__c <=:tmpEnd];
                          set<Top_Up_Invoice__c> setRetopup = new Set <Top_Up_Invoice__c>(ListTopInvoiceretop);
                          newCamp.User_Top_Up__c=settopup.size();
                          newCamp.User_Retopup__c=setRetopup.size();*/
                      }
                      else
                      {    
                          AggregateResult[] ListTopVoucherretopAM = [SELECT SUM(amount__c)sot1,User_Id__c FROM Top_Up_Invoice__c WHERE Top_Up_Voucher__c != NULL and Top_Up_Voucher__r.Campaign_MyAds__c =:newCamp.id and Status_Topup__c='Re-Top Up' group by User_Id__c];
                          AggregateResult[] ListTopVoucherfirstAM = [SELECT SUM(amount__c)sor1,User_Id__c FROM Top_Up_Invoice__c WHERE Top_Up_Voucher__c != NULL and Top_Up_Voucher__r.Campaign_MyAds__c =:newCamp.id and Status_Topup__c='First Top Up' group by User_Id__c];
                          
                          for (AggregateResult art : ListTopVoucherretopAM)  
                          {
                              Amount_id_top_Voucher = Amount_id_top_Voucher + (double) art.get('sot1');
                          }
                          for (AggregateResult arr : ListTopVoucherfirstAM)  
                          {
                              Amount_id_re_Voucher = Amount_id_re_Voucher + (double) arr.get('sor1');                            
                          }
                          
                          AggregateResult[] ListTopVoucherfirst = [SELECT User_Id__c FROM Top_Up_Invoice__c WHERE Top_Up_Voucher__c != NULL and Top_Up_Voucher__r.Campaign_MyAds__c =:newCamp.id and Status_Topup__c='First Top Up' group by User_Id__c];
                          AggregateResult[] ListTopVoucherretop = [SELECT User_Id__c FROM Top_Up_Invoice__c WHERE Top_Up_Voucher__c != NULL and Top_Up_Voucher__r.Campaign_MyAds__c =:newCamp.id and Status_Topup__c='Re-Top Up' group by User_Id__c];
                          newCamp.User_Top_Up__c  = ListTopVoucherfirst.size();
                          newCamp.User_Retopup__c = ListTopVoucherretop.size();    
                          
                          if(Amount_id_top_Voucher == null)
                              {
                                Amount_id_top_Voucher = 0;
                              }
                           if(Amount_id_re_Voucher == null)
                              {
                                Amount_id_re_Voucher = 0;
                              }
                          system.debug('masuk');
                      }
                      Usertopup=newCamp.User_Top_Up__c;
                      Userretopup=newCamp.User_Retopup__c;
                      UserReg=newCamp.Actual_User_Register__c;
                      countcamps=1;
                      	
                   }
                   catch (Exception e) 
                   {
                       string errMessage = 'Error on AppUtils Trigger_CampaignMyads_Before_Update method.::' + e.getmessage() + '::' + e.getLineNumber() ;
                       system.debug('==================== error message : ' + errMessage);
                       AppUtils.putError(errMessage );
                   }
                    
                    
                  //mst
                    if(Usertopup>0)
                    {
                       Monthly_Sales_Target__c new_mst = new Monthly_Sales_Target__c();
                       new_mst.date__c=enddate;
                       new_mst.Number_of__c=newCamp.User_Top_Up__c;
                       new_mst.Type__c='Actual User Top Up';
                       new_mst.group_type__c='Actual';
                       new_mst.Campaign_MyAds__c=recordid;
                       new_mst.Campaign_Name__c=newCamp.Campaign_Name__c;
                       new_mst.MST_Type__c='SME';
                       new_mst.sales__c=ownerid;
                       new_mst.ownerid=ownerid;
                       new_mst.Unique_ID__c=recordid+'_'+ownerid+'_'+new_mst.Type__c+'_'+enddate.month()+'_'+enddate.year();
                       MSTlist.add(new_mst);
                       upsert MSTlist new_mst.Unique_ID__c;
                    }
                    if(Userretopup>0)
                    {
                       Monthly_Sales_Target__c new_mst = new Monthly_Sales_Target__c();
                       new_mst.date__c=enddate;
                       new_mst.Number_of__c=newCamp.User_Top_Up__c;
                       new_mst.Type__c='Actual User Re-top';
                       new_mst.group_type__c='Actual';
                       new_mst.Campaign_MyAds__c=recordid;
                       new_mst.Campaign_Name__c=newCamp.Campaign_Name__c;
                       new_mst.MST_Type__c='SME';
                       new_mst.sales__c=ownerid;
                       new_mst.ownerid=ownerid;
                       new_mst.Unique_ID__c=recordid+'_'+ownerid+'_'+new_mst.Type__c+'_'+enddate.month()+'_'+enddate.year();
                       MSTlist.add(new_mst);
                       upsert MSTlist new_mst.Unique_ID__c;
                    }
                    if(UserReg>0)
                    {
                       Monthly_Sales_Target__c new_mst = new Monthly_Sales_Target__c();
                       new_mst.date__c=enddate;
                       new_mst.Number_of__c=UserReg;
                       new_mst.Type__c='Actual User Register';
                       new_mst.group_type__c='Actual';
                       new_mst.Campaign_MyAds__c=recordid;
                       new_mst.Campaign_Name__c=newCamp.Campaign_Name__c;
                       new_mst.MST_Type__c='SME';
                       new_mst.sales__c=ownerid;
                       new_mst.ownerid=ownerid;
                       new_mst.Unique_ID__c=recordid+'_'+ownerid+'_'+new_mst.Type__c+'_'+enddate.month()+'_'+enddate.year();
                       MSTlist.add(new_mst);
                       upsert MSTlist new_mst.Unique_ID__c;
                    }
                    /*if(countcamps>0)
                    {
                       Monthly_Sales_Target__c new_mst = new Monthly_Sales_Target__c();
                       new_mst.date__c=enddate;
                       new_mst.Number_of__c=countcamps;
                       new_mst.Type__c='Actual Campaigns';
                       new_mst.group_type__c='Actual';
                       new_mst.Campaign_MyAds__c=recordid;
                       new_mst.Campaign_Name__c=newCamp.Campaign_Name__c;
                       new_mst.MST_Type__c='SME';
                       new_mst.sales__c=ownerid;
                       new_mst.ownerid=ownerid;
                       new_mst.Unique_ID__c=recordid+'_'+ownerid+'_'+new_mst.Type__c+'_'+enddate.month()+'_'+enddate.year();
                       MSTlist.add(new_mst);
                       upsert MSTlist Unique_ID__c;
                    } */
                }//endifcondisicompleted
                
                
            }
        }
    }
  }
}