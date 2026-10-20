@isTest
public class Test_Trigger_CO {

    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
        Kategori_Industri__c kategInd = new Kategori_Industri__c();
        kategInd.Name = 'Banking';
        kategInd.prefix_ms__c = 'ban';
        insert kategInd; 
        
        Order_Non_Bulk__c ordnonbulk = new Order_Non_Bulk__c();
        ordnonbulk.Kategori_Industri__c = kategInd.id;
        ordnonbulk.Campaign_Name__c = 'Dummy Campaign';
        ordnonbulk.Campaign_Type__c = 'LBA';
        insert ordnonbulk;
        
        Campaign_Order__c campOrder = new Campaign_Order__c();
        campOrder.Order_Non_Bulk__c = ordnonbulk.id;
        campOrder.Masking_Sender_Brand__c = 'Dummy';
        campOrder.Profiling_Lokasi__c = 'Jakarta';
        campOrder.Channel__c = 'SMS LBA';
        campOrder.Start_Campaign__c = system.today();
        campOrder.End_Campaign__c = (system.today()).adddays(5);
        campOrder.Impression_Click__c = 10;
        campOrder.SMS_Per_Day_Location__c = 10;
        campOrder.WORDING_PICTURE_VIDEO__c = 'test';
        campOrder.Placement__c = 'test';
        insert campOrder;
        
        Campaign_Order__c campOrder1 = new Campaign_Order__c();
        //campOrder1.Order_Non_Bulk__c = ordnonbulk.id;
        campOrder1.Masking_Sender_Brand__c = 'Dummy';
        campOrder1.Profiling_Lokasi__c = 'Jakarta';
        campOrder1.Channel__c = 'SMS LBA';
        campOrder1.Start_Campaign__c = system.today();
        campOrder1.End_Campaign__c = (system.today()).adddays(5);
        campOrder1.Impression_Click__c = 10;
        campOrder1.SMS_Per_Day_Location__c = 10;
        campOrder1.WORDING_PICTURE_VIDEO__c = 'test';
        campOrder1.Placement__c = 'test';
        insert campOrder1;
      
    }
}