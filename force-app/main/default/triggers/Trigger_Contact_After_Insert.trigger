/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-13-2024
 * @last modified by  : Syaiful Syafani
**/
trigger Trigger_Contact_After_Insert on Contact (after insert) {
if (label.Trigger_Contact_After_Insert_On== 'YES') {
    List <Brand__c> Brand_list = new List <Brand__c>();
    String BrandId;
    String BrandIdAcc;
    String BrandName;
    String PIC;
    String Account_Id;
    String BrandCategory;

    if(trigger.isafter)
     {
       if(trigger.isinsert)
        {
        List<Brand__c> lNewBrand = new List<Brand__c>();
            for(Contact ConNew : system.trigger.new)
            {
                if(ConNew.Converted_from_Lead__c==TRUE){
                    List<Contact> myContact = [SELECT Id,AccountId FROM Contact WHERE Id = :ConNew.id];
                    if(myContact.size()>0){
                        PIC=myContact[0].Id;
                        Account_Id=myContact[0].AccountId;
                    }
                    
                    List<Account> myAccount = [SELECT Id,Name, Brand_Name_txt__c, Brand_Name__c, Brand_Category__c FROM Account WHERE Id = :Account_Id];
                    if(myAccount .size()>0){
                        BrandId=myAccount[0].Brand_Name__c;
                        BrandIdAcc=myAccount[0].Id;
                        BrandName=myAccount[0].Brand_Name_txt__c;
                        BrandCategory = myAccount[0].Brand_Category__c;
                    }

                    LOB__c lobRec = [SELECT Id, Name FROM LOB__c WHERE Name = :BrandCategory];
                    
                    system.debug('++++myContact='+myContact);
                    system.debug('++++PIC='+PIC);
                    Brand__c newBrand = new Brand__c();
                    newBrand.id=BrandId;
                    newBrand.Name=BrandName;
                    newBrand.PIC_Advertiser__c=PIC;
                    newBrand.Advertiser__c=Account_Id;
                    newBrand.Brand_Category__c = lobRec.Id;
                    lNewBrand.add(newBrand);
                }
                upsert lNewBrand;
            }
        }
     }
   }
}