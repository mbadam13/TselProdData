public class TH_SID_Tools_TriggerHandler 
{
    public static void setUpInfoPNV(list<SID_Tools__c> lstSIDTools)
    {
        
		Decimal lastCounter = Decimal.valueOf(Label.client_ID);
        List <SID_Tools__c> SIDlst = [SELECT  Client_id__c FROM SID_Tools__c WHERE RecordType.DeveloperName = 'PNV' Order By CreatedDate  DESC limit 1];
        if(SIDlst.size() > 0){
            lastCounter = SIDlst[0].Client_ID__c;
        }
        system.debug('SIDlst = ' +  SIDlst);
        
        Map<Id,user> map_id_usRec = new Map<Id,user>();
	  	List<user> userList = [SELECT Id, suffix FROM User];
	  	for(user ust : userList){
	  		map_id_usRec.put(ust.Id,ust);
	  	}
        
        for(SID_Tools__c SIDTools:lstSIDTools ){   
            
			String recordTypeName = Schema.getGlobalDescribe().get('SID_Tools__c').getDescribe().getRecordTypeInfosById().get(SIDTools.RecordTypeId).getName();
            System.debug('recType = ' + recordTypeName);
           
         	User userMediaSeller = map_id_usRec.get(SIDTools.OwnerId);
         	system.debug('user =' + userMediaSeller.suffix);
            
           	if(recordTypeName == 'PNV'){
                
                //Start stamping Media seller
                if(userMediaSeller.suffix == 'dws' ){
                    SIDTools.Media_Seller__c = Label.MediaSeller_DWS;
                }else if(userMediaSeller.suffix == 'mustika' ){
                    SIDTools.Media_Seller__c = Label.MediaSeller_Mustika;
                }
                //End stamping Media seller
                
                //start create Combine CPName
                system.debug('in recType.DeveloperName');
                Map<String, Decimal> lastClientId = new Map<String, Decimal>();
                String Usecase = SIDTools.Use_Case__c;
                Use_Case_Setting__c useCaseSettings = Use_Case_Setting__c.getValues(Usecase);
                SIDTools.PNV_Code__c = useCaseSettings.Code__c;
                system.debug('PNV Code = ' + useCaseSettings.Code__c);
                
                String appname = SIDTools.app_name__c;
                String appname2 = appname.replace(' ','').toLowerCase();
                system.debug('check =' + appname2);
                
                String PNV = recordTypeName;
                String lowPNV = PNV.toLowerCase();

                SIDTools.SID__c = SIDTools.Client_Name__c;
                SIDTools.Company__c = SIDTools.Legal_Name__c;
                SIDTools.Sender_ID__c = SIDtools.App_Name__c;

            }
           
            //Start Create random Password
            if(SIDTools.Password__c == NULL){
            	Integer len = 10;
            	Blob blobKey = crypto.generateAesKey(128);
            	String key = EncodingUtil.convertToHex(blobKey);
            	String pwd = key.substring(0,len);
            	SIDTools.Password__c = pwd;
                
                SIDTools.Client_ID__c = lastCounter+1; //Create Client Id
            } 
            //End Create random Password
            
        }
        
    }
 
}